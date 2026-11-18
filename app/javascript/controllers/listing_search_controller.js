import { Controller } from "@hotwired/stimulus"

// Search page (app/views/listings/index.html.erb). Rails renders the form and the card template;
// this controller only sends the form to the JSON API with fetch and copies each result into the template.
export default class extends Controller {
  static targets = [ "form", "status", "results", "template", "previous", "next" ]
  static values = { url: String }

  connect() {
    this.search()
  }

  // Runs on load, when the form is submitted and when a filter changes.
  // event.submitter is the button that sent the form: the pagination buttons add their page.
  search(event) {
    event?.preventDefault()

    const query = new URLSearchParams()
    for (const [ name, value ] of new FormData(this.formTarget, event?.submitter)) {
      if (value) query.append(name, value) // empty fields are left out, as the API ignores them anyway
    }

    // The filters stay in the address bar, so a search can be reloaded or shared.
    // history.state is kept as it is, because Turbo stores there what it needs for the back button
    history.replaceState(history.state, "", `?${query}`)
    this.load(query.toString())
  }

  async load(query) {
    this.currentQuery = query
    this.statusTarget.textContent = "Searching..."

    try {
      const response = await fetch(`${this.urlValue}?${query}`, { headers: { Accept: "application/json" } })
      const body = await response.json()
      if (query !== this.currentQuery) return // a newer search started while this one was on its way

      if (response.ok) {
        this.show(body)
      } else {
        this.resultsTarget.replaceChildren()
        this.statusTarget.textContent = body.errors.join(" ") // the 400 messages of the API
      }
    } catch {
      this.statusTarget.textContent = "The search failed. Please try again."
    }
  }

  show({ data, meta }) {
    this.resultsTarget.replaceChildren(...data.map((listing) => this.card(listing)))
    this.statusTarget.textContent = meta.total_count === 1 ? "1 room found" : `${meta.total_count} rooms found`

    this.previousTarget.value = meta.page - 1
    this.previousTarget.hidden = meta.page <= 1
    this.nextTarget.value = meta.page + 1
    this.nextTarget.hidden = meta.page >= meta.total_pages
  }

  // Copies the template and fills it. textContent (not innerHTML) puts the API's text as plain text
  card(listing) {
    const card = this.templateTarget.content.cloneNode(true)
    const field = (name) => card.querySelector(`[data-field="${name}"]`)

    field("title").textContent = listing.title
    field("place").textContent = `${listing.neighborhood.name} / ${listing.neighborhood.city}`
    field("rent").textContent = `$${listing.monthly_rent} / month`
    field("available").textContent = `Available starting ${this.formatDate(listing.available_from)}`
    field("link").href = listing.url

    if (listing.cover_photo_url) {
      field("photo").src = listing.cover_photo_url
      field("photo").alt = listing.title
      field("no-photo").remove()
    } else {
      field("photo").remove()
    }

    return card
  }

  // "2026-11-12" → "November 12, 2026". The API's dates have no time, so they're read in UTC
  // (otherwise in Chile, UTC-3, the day before would show)
  formatDate(date) {
    return new Date(date).toLocaleDateString("en-US", { dateStyle: "long", timeZone: "UTC" })
  }
}
