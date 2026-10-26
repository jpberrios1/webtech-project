# HOW THIS FILE WORKS
# 1. All the data is declared first, in plain lists (hashes) at the top.
# 2. Each list is then turned into "events": things that happened at a given moment
#    (a listing was published, someone applied, a visit was confirmed...).
# 3. The events are sorted by time and replayed in order. Before each one, the seed
#    travels back to that moment (travel_to), so every record goes through the real
#    validations and lifecycle methods of the models. Nothing uses validate: false.

require "active_support/testing/time_helpers"
extend ActiveSupport::Testing::TimeHelpers

# ---------------------------------------------------------------------------
# Clean the database
# ---------------------------------------------------------------------------
Report.destroy_all
Review.destroy_all
Visit.destroy_all
SavedListing.destroy_all
Application.destroy_all
ListingPhoto.destroy_all
Listing.destroy_all
PropertySharedSpace.destroy_all
PropertyAmenity.destroy_all
SharedSpace.destroy_all
Amenity.destroy_all
Property.destroy_all
Neighborhood.destroy_all
User.destroy_all

# ---------------------------------------------------------------------------
# DATA
# ---------------------------------------------------------------------------

USERS = {
  alice:    { name: "Alice Rojas",     email_address: "alice@roomies.com",    phone: "555-0001" },
  carlos:   { name: "Carlos Muñoz",    email_address: "carlos@roomies.com",   phone: "555-0002" },
  elena:    { name: "Elena Soto",      email_address: "elena@roomies.com",    phone: "555-0003" },
  bob:      { name: "Bob Pérez",       email_address: "bob@roomies.com",      phone: "555-0101" },
  diana:    { name: "Diana Torres",    email_address: "diana@roomies.com",    phone: "555-0102" },
  felipe:   { name: "Felipe Araya",    email_address: "felipe@roomies.com",   phone: "555-0103" },
  gabriela: { name: "Gabriela Díaz",   email_address: "gabriela@roomies.com", phone: "555-0104" },
  ignacia:  { name: "Ignacia Fuentes", email_address: "ignacia@roomies.com",  phone: "555-0105" },
  joaquin:  { name: "Joaquín Vera",    email_address: "joaquin@roomies.com",  phone: "555-0106" },
  karen:    { name: "Karen Lagos",     email_address: "karen@roomies.com",    phone: "555-0107" },
  admin:    { name: "Admin Mod",       email_address: "admin@roomies.com",    role: "moderator" },
  # Edge: no phone, upper-case email, default role (member)
  hugo:     { name: "Hugo Reyes",      email_address: "HUGO@Roomies.com" }
}

NEIGHBORHOODS = {
  providencia:  { name: "Providencia",     city: "Santiago" },
  las_condes:   { name: "Las Condes",      city: "Santiago" },
  santiago:     { name: "Santiago Centro", city: "Santiago" },
  nunoa:        { name: "Ñuñoa",           city: "Santiago" },
  # Edge: same name, different city (names are unique per city, not globally)
  centro_valpo: { name: "Centro",          city: "Valparaíso" },
  centro_vina:  { name: "Centro",          city: "Viña del Mar" },
  bellavista:   { name: "Bellavista",      city: "Santiago" },
  italia:       { name: "Barrio Italia",   city: "Santiago" },
  cerro_alegre: { name: "Cerro Alegre",    city: "Valparaíso" }
}

AMENITIES = {
  wifi:    { name: "Gigabit WiFi",     description: "900 Mbps fiber optic" },
  laundry: { name: "In-unit Laundry",  description: "Washer and dryer available" },
  ac:      { name: "Air Conditioning", description: "Split AC in all rooms" },
  # Edge: description is optional
  parking: { name: "Parking" },
  heating: { name: "Central Heating",  description: "Radiators in every room" },
  gym:     { name: "Building Gym",     description: "Open 6:00 to 23:00" }
}

SHARED_SPACES = {
  living_room: { name: "Living Room",  description: "Large couch and 65-inch TV" },
  kitchen:     { name: "Full Kitchen", description: "Oven, microwave, dishwasher" },
  balcony:     { name: "Balcony",      description: "Great city view" },
  rooftop:     { name: "Rooftop",      description: "Shared terrace with a grill" },
  garden:      { name: "Garden",       description: "Small garden with lemon trees" }
}

PROPERTIES = {
  duplex: { host: :alice, neighborhood: :providencia, title: "Modern Duplex in Pedro de Valdivia",
            address: "Av. Pedro de Valdivia 123", property_type: "apartment", bedrooms: 3, bathrooms: 2,
            amenities: [ :wifi ], shared_spaces: [ :kitchen, :balcony ] },
  house:  { host: :carlos, neighborhood: :las_condes, title: "Spacious House in El Golf",
            address: "Isidora Goyenechea 456", property_type: "house", bedrooms: 5, bathrooms: 3,
            amenities: [ :wifi, :laundry ], shared_spaces: [ :kitchen ] },
  loft:   { host: :elena, neighborhood: :santiago, title: "Artsy Loft in Lastarria",
            address: "José Victorino Lastarria 789", property_type: "apartment", bedrooms: 2, bathrooms: 1,
            amenities: [ :wifi, :ac ], shared_spaces: [ :kitchen ] },
  flat:   { host: :alice, neighborhood: :nunoa, title: "Cozy Flat near Plaza Ñuñoa",
            address: "Irarrázaval 321", property_type: "apartment", bedrooms: 3, bathrooms: 2,
            amenities: [ :wifi ], shared_spaces: [ :kitchen, :living_room ] },
  # Edge: no property_type (defaults to "other"), 0 bathrooms, no amenities or shared spaces
  studio: { host: :elena, neighborhood: :centro_valpo, title: "Studio by the Port",
            address: "Blanco 1500", bedrooms: 1, bathrooms: 0,
            amenities: [], shared_spaces: [] },
  # Owned by members who also apply to other people's rooms
  townhouse: { host: :bob, neighborhood: :italia, title: "Townhouse in Barrio Italia",
               address: "Av. Italia 1180", property_type: "house", bedrooms: 3, bathrooms: 2,
               amenities: [ :wifi, :heating ], shared_spaces: [ :kitchen, :garden ] },
  bellavista_apt: { host: :diana, neighborhood: :bellavista, title: "Apartment in Bellavista",
                    address: "Constitución 90", property_type: "apartment", bedrooms: 2, bathrooms: 1,
                    amenities: [ :ac, :gym ], shared_spaces: [ :rooftop ] },
  cerro_house: { host: :ignacia, neighborhood: :cerro_alegre, title: "Colorful House on Cerro Alegre",
                 address: "Templeman 245", property_type: "house", bedrooms: 4, bathrooms: 2,
                 amenities: [ :parking, :heating ], shared_spaces: [ :garden, :living_room ] }
}

# Each listing says when it was created and, if it happened, when it was published,
# withdrawn or rented. "reserved" is never written here: it only happens by accepting
# an application
LISTINGS = {
  sunny: {
    property: :duplex, created: 10.days.ago, published: 10.days.ago,
    photo: { url: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267", caption: "Bedroom view" },
    attributes: { title: "Sunny Master Bedroom", monthly_rent: 450.0, deposit: 450.0, is_furnished: true,
                  has_private_bathroom: true, minimum_stay_days: 90, available_from: Date.current + 10.days,
                  description: "Beautiful room with plenty of light." }
  },
  cozy: {
    property: :duplex, created: 5.days.ago, published: 5.days.ago,
    attributes: { title: "Small Cozy Room", monthly_rent: 300.0, deposit: 300.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: Date.current + 5.days,
                  description: "Perfect for students." }
  },
  luxury: {
    property: :house, created: 1.day.ago, # stays a draft
    attributes: { title: "Luxury Room (Not ready yet)", monthly_rent: 600.0, deposit: 600.0, is_furnished: true,
                  has_private_bathroom: true, minimum_stay_days: 180, available_from: Date.current + 30.days,
                  description: "Still painting the walls." }
  },
  quiet: {
    # Published 20 days ago (not 2) so Bob's application from 15 days ago was made on a published listing.
    # Reserved, not rented: Bob was accepted but his move-in date is still 15 days away.
    property: :flat, created: 20.days.ago, published: 20.days.ago,
    attributes: { title: "Quiet Room near Plaza Ñuñoa", monthly_rent: 380.0, deposit: 380.0, is_furnished: true,
                  has_private_bathroom: false, minimum_stay_days: 60, available_from: Date.current + 5.days,
                  description: "Great location, lots of bars and restaurants nearby." }
  },

  # Past tenancies. The historical tenants used to be accepted on the same listing as Bob,
  # which breaks "a listing has at most one accepted application". Each tenancy is now
  # its own (already rented) listing. The Lastarria one goes on Elena's loft in Lastarria,
  # which is what its application message and review talk about.
  loft_2024: {
    property: :loft, created: 430.days.ago, published: 425.days.ago, rented: 400.days.ago,
    attributes: { title: "Artsy Loft Room (2024)", monthly_rent: 350.0, deposit: 350.0,
                  is_furnished: true, has_private_bathroom: false, minimum_stay_days: 60,
                  available_from: 410.days.ago.to_date, description: "Loft room in the heart of Lastarria." }
  },
  quiet_2025: {
    property: :flat, created: 320.days.ago, published: 315.days.ago, rented: 300.days.ago,
    attributes: { title: "Quiet Room near Plaza Ñuñoa (2025)", monthly_rent: 370.0, deposit: 370.0,
                  is_furnished: true, has_private_bathroom: false, minimum_stay_days: 60,
                  available_from: 305.days.ago.to_date, description: "Great location, lots of bars and restaurants nearby." }
  },
  cozy_2025: {
    property: :duplex, created: 215.days.ago, published: 212.days.ago, rented: 200.days.ago,
    attributes: { title: "Small Cozy Room (2025)", monthly_rent: 280.0, deposit: 280.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: 205.days.ago.to_date,
                  description: "Perfect for students." }
  },

  # Edge: reserved (an applicant was accepted, nobody has moved in yet)
  terrace: {
    property: :loft, created: 8.days.ago, published: 8.days.ago,
    attributes: { title: "Loft Room with Terrace", monthly_rent: 520.0, deposit: 520.0, is_furnished: true,
                  has_private_bathroom: true, minimum_stay_days: 120, available_from: Date.current + 10.days,
                  description: "Bright room with access to a private terrace.",
                  house_rules: "No parties on weeknights. Keep the terrace plants watered." }
  },
  # Edge: taken down (withdrawn) by the moderator after a fraud report, while it had a pending application
  artsy: {
    property: :loft, created: 12.days.ago, published: 12.days.ago, withdrawn: 7.days.ago,
    attributes: { title: "Artsy Room in Lastarria", monthly_rent: 410.0, deposit: 200.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: Date.current + 3.days,
                  description: "Small room full of character." }
  },
  # Edge: deposit 0 (allowed), no minimum stay (nil), available from today (the limit of "not in the past")
  studio: {
    property: :studio, created: 1.hour.ago, published: 1.hour.ago,
    attributes: { title: "Studio Room by the Port", monthly_rent: 250.0, deposit: 0, is_furnished: false,
                  has_private_bathroom: true, minimum_stay_days: nil, available_from: Date.current,
                  description: "Simple room, two blocks from the sea." }
  },

  # Listings of members who are also seekers
  italia_room: {
    property: :townhouse, created: 6.days.ago, published: 6.days.ago,
    attributes: { title: "Garden Room in Barrio Italia", monthly_rent: 420.0, deposit: 420.0, is_furnished: true,
                  has_private_bathroom: false, minimum_stay_days: 90, available_from: Date.current + 15.days,
                  description: "Quiet room facing the garden, close to cafés and bike lanes.",
                  house_rules: "Shared cleaning every Sunday. Bikes stay in the garden, not inside." }
  },
  italia_room_2025: {
    property: :townhouse, created: 150.days.ago, published: 148.days.ago, rented: 120.days.ago,
    attributes: { title: "Garden Room in Barrio Italia (2025)", monthly_rent: 390.0, deposit: 390.0,
                  is_furnished: true, has_private_bathroom: false, minimum_stay_days: 90,
                  available_from: 125.days.ago.to_date, description: "Quiet room facing the garden." }
  },
  bellavista_room: {
    property: :bellavista_apt, created: 3.days.ago, published: 3.days.ago,
    attributes: { title: "Room with Rooftop Access", monthly_rent: 480.0, deposit: 240.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: Date.current + 7.days,
                  description: "Lively neighborhood, five minutes from the metro." }
  },
  bellavista_draft: {
    property: :bellavista_apt, created: 6.hours.ago, # still a draft
    attributes: { title: "Second Room (photos coming soon)", monthly_rent: 430.0, deposit: 430.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: Date.current + 40.days,
                  description: "Will publish once the room is painted." }
  },
  # Edge: withdrawn while still a draft (the host changed their mind before publishing)
  house_draft: {
    property: :house, created: 9.days.ago, withdrawn: 8.days.ago,
    attributes: { title: "Basement Room", monthly_rent: 280.0, deposit: 280.0, is_furnished: false,
                  has_private_bathroom: false, minimum_stay_days: 30, available_from: Date.current + 20.days,
                  description: "Decided to keep it as a home office." }
  },
  # Edge: withdrawn while reserved. Carlos had been accepted; withdrawing rejects him too.
  attic: {
    property: :townhouse, created: 18.days.ago, published: 18.days.ago, withdrawn: 9.days.ago,
    attributes: { title: "Attic Room in Barrio Italia", monthly_rent: 360.0, deposit: 360.0, is_furnished: true,
                  has_private_bathroom: false, minimum_stay_days: 60, available_from: 10.days.ago.to_date,
                  description: "Cozy attic with a skylight. Family is moving in instead." }
  },
  cerro_room: {
    property: :cerro_house, created: 40.days.ago, published: 38.days.ago, rented: 25.days.ago,
    attributes: { title: "Room with Sea View", monthly_rent: 350.0, deposit: 350.0, is_furnished: true,
                  has_private_bathroom: true, minimum_stay_days: 180, available_from: 30.days.ago.to_date,
                  description: "Wake up to the bay. Steep stairs, great views." }
  }
}

APPLICATIONS = {
  app1: { listing: :quiet, seeker: :bob, message: "I love Ñuñoa, moving in ASAP!",
          desired_move_in_date: Date.current + 15.days, length_of_stay_days: 180,
          applied: 15.days.ago, shortlisted: (14.days + 2.hours).ago, accepted: 11.days.ago },
  app2: { listing: :sunny, seeker: :diana, message: "Is the private bathroom inside the room?",
          desired_move_in_date: Date.current + 20.days, length_of_stay_days: 90,
          applied: 5.days.ago, shortlisted: (4.days + 3.hours).ago },
  app3: { listing: :sunny, seeker: :felipe, message: "I can pay 6 months upfront.",
          desired_move_in_date: Date.current + 12.days, length_of_stay_days: 180,
          applied: 2.days.ago },

  app_old_lastarria: { listing: :loft_2024, seeker: :felipe, message: "I lived here last year, moving back!",
                       desired_move_in_date: 400.days.ago.to_date, length_of_stay_days: 180,
                       applied: 420.days.ago, shortlisted: 419.days.ago, accepted: 414.days.ago },
  app_nunoa:         { listing: :quiet_2025, seeker: :diana, message: "Moving for a new job nearby.",
                       desired_move_in_date: 300.days.ago.to_date, length_of_stay_days: 90,
                       applied: 310.days.ago, shortlisted: 309.days.ago, accepted: 304.days.ago },
  app_providencia:   { listing: :cozy_2025, seeker: :gabriela, message: "Perfect for my semester abroad.",
                       desired_move_in_date: 200.days.ago.to_date, length_of_stay_days: 120,
                       applied: 210.days.ago, shortlisted: 209.days.ago, accepted: 204.days.ago },

  # Edge: withdrawn by the seeker; move-in date is today; stays only 1 day
  # (on the studio, the only listing with no minimum stay)
  gabriela_studio: { listing: :studio, seeker: :gabriela, message: "Just need a place for one night between flats.",
                     desired_move_in_date: Date.current, length_of_stay_days: 1,
                     applied: 50.minutes.ago, withdrawn: 10.minutes.ago },

  # Edge: accepting Ignacia rejects Joaquín (pending) and Gabriela (shortlisted, with a proposed visit)
  terrace_ignacia:  { listing: :terrace, seeker: :ignacia, message: "Back in Santiago for work, the terrace sold me.",
                      desired_move_in_date: Date.current + 10.days, length_of_stay_days: 365,
                      applied: 7.days.ago, shortlisted: 6.days.ago, accepted: 2.days.ago },
  terrace_gabriela: { listing: :terrace, seeker: :gabriela, message: "Is the terrace shared with the other rooms?",
                      desired_move_in_date: Date.current + 14.days, length_of_stay_days: 180,
                      applied: 6.days.ago, shortlisted: 5.days.ago },
  terrace_joaquin:  { listing: :terrace, seeker: :joaquin, message: "Still looking, this one looks great.",
                      desired_move_in_date: Date.current + 20.days, length_of_stay_days: 150,
                      applied: 4.days.ago },

  # Edge: rejected automatically when the host withdrew the listing
  artsy_diana: { listing: :artsy, seeker: :diana, message: "Love the style of this room!",
                 desired_move_in_date: Date.current + 5.days, length_of_stay_days: 60,
                 applied: 9.days.ago },

  # Hosts applying to other people's rooms
  # Rejected directly by the host (Bob), without accepting anyone
  alice_italia:      { listing: :italia_room, seeker: :alice, message: "Renting out my flat and moving closer to work.",
                       desired_move_in_date: Date.current + 20.days, length_of_stay_days: 270,
                       applied: 5.days.ago, rejected: 1.day.ago },
  joaquin_italia:    { listing: :italia_room, seeker: :joaquin, message: "I bike everywhere, the garden storage is perfect.",
                       desired_move_in_date: Date.current + 15.days, length_of_stay_days: 180,
                       applied: 4.days.ago, shortlisted: 3.days.ago },
  ignacia_italia:    { listing: :italia_room_2025, seeker: :ignacia, message: "Need a room in Santiago on weekdays.",
                       desired_move_in_date: 120.days.ago.to_date, length_of_stay_days: 120,
                       applied: 140.days.ago, shortlisted: 139.days.ago, accepted: 135.days.ago },
  hugo_bellavista:   { listing: :bellavista_room, seeker: :hugo, message: "Is the rooftop available at night?",
                       desired_move_in_date: Date.current + 10.days, length_of_stay_days: 60,
                       applied: 2.days.ago },
  carlos_bellavista: { listing: :bellavista_room, seeker: :carlos, message: "Looking for something closer to my office.",
                       desired_move_in_date: Date.current + 7.days, length_of_stay_days: 120,
                       applied: 1.day.ago },
  carlos_attic:      { listing: :attic, seeker: :carlos, message: "Looking for something for a few months.",
                       desired_move_in_date: Date.current + 5.days, length_of_stay_days: 120,
                       applied: 16.days.ago, shortlisted: 15.days.ago, accepted: 12.days.ago },
  karen_cerro:       { listing: :cerro_room, seeker: :karen, message: "Remote worker, I love the sea.",
                       desired_move_in_date: 25.days.ago.to_date, length_of_stay_days: 180,
                       applied: 35.days.ago, shortlisted: 34.days.ago, accepted: 30.days.ago }
}

# Each visit: its application, its date and time, and when it was proposed / confirmed / cancelled.
# "completed: true" marks it completed one hour after its scheduled time (it cannot be completed
# before it happens). Cancellations caused by rejecting an application are not written here.
VISITS = {
  visit1:              { application: :app1, scheduled_at: 12.days.ago.change(hour: 17),
                         proposed: 14.days.ago, confirmed: 13.days.ago, completed: true },
  # The host had a conflict: this visit was cancelled and a new one proposed (rescheduling
  # creates a new visit, as in our decisions document)
  visit_app2_first:    { application: :app2, scheduled_at: 2.days.ago.change(hour: 10),
                         proposed: (4.days + 2.hours).ago, cancelled: (4.days + 1.hour).ago },
  visit_app2: { application: :app2, scheduled_at: 2.days.ago.change(hour: 10),
                proposed: (4.days + 2.hours).ago,
                rescheduled: { at: (4.days + 1.hour).ago, to: 1.day.from_now.change(hour: 18) },
                confirmed: 3.days.ago },
  visit_old_lastarria: { application: :app_old_lastarria, scheduled_at: 415.days.ago.change(hour: 12),
                         proposed: 418.days.ago, confirmed: 417.days.ago, completed: true },
  visit_nunoa:         { application: :app_nunoa, scheduled_at: 305.days.ago.change(hour: 19),
                         proposed: 308.days.ago, confirmed: 307.days.ago, completed: true },
  visit_providencia:   { application: :app_providencia, scheduled_at: 205.days.ago.change(hour: 16),
                         proposed: 208.days.ago, confirmed: 207.days.ago, completed: true },
  visit_terrace_ignacia:  { application: :terrace_ignacia, scheduled_at: 3.days.ago.change(hour: 11),
                            proposed: 5.days.ago, confirmed: 4.days.ago, completed: true },
  # Edge: still proposed when Ignacia was accepted, so it ends up cancelled
  visit_terrace_gabriela: { application: :terrace_gabriela, scheduled_at: 3.days.from_now.change(hour: 16),
                            proposed: 4.days.ago },
  visit_joaquin_italia:   { application: :joaquin_italia, scheduled_at: 2.days.from_now.change(hour: 11),
                            proposed: 2.days.ago },  # still waiting for Joaquín to confirm
  visit_ignacia_italia:   { application: :ignacia_italia, scheduled_at: 137.days.ago.change(hour: 18),
                            proposed: 139.days.ago, confirmed: 138.days.ago, completed: true },
  visit_carlos_attic:     { application: :carlos_attic, scheduled_at: 13.days.ago.change(hour: 19),
                            proposed: (15.days - 1.hour).ago, confirmed: 14.days.ago, completed: true },
  visit_karen_cerro:      { application: :karen_cerro, scheduled_at: 31.days.ago.change(hour: 12),
                            proposed: 33.days.ago, confirmed: 32.days.ago, completed: true }
}

# The reviewer is always the seeker of the visit, and the property is the visited one.
REVIEWS = [
  { visit: :visit1, rating: 5, at: 2.days.ago,
    comment: "Host is amazing, area is noisy but the room is great." },
  { visit: :visit_old_lastarria, rating: 4, at: 200.days.ago,
    comment: "Really nice loft. The only downside is the lack of parking, but the subway is very close." },
  { visit: :visit_providencia, rating: 5, at: 80.days.ago,
    comment: "Super cozy room and great location. Alice is a wonderful host!" },
  { visit: :visit_nunoa, rating: 5, at: 200.days.ago,
    comment: "Very quiet neighborhood, exactly what I needed to study and work. Highly recommended." },
  # Edge: lowest rating, and no comment (the comment is optional)
  { visit: :visit_terrace_ignacia, rating: 1, at: 1.day.ago, comment: nil },
  # A host (Ignacia) reviewing someone else's property: allowed, it is not hers
  { visit: :visit_ignacia_italia, rating: 4, at: 100.days.ago,
    comment: "Lovely garden and a very respectful host. The room gets cold in winter." },
  { visit: :visit_karen_cerro, rating: 3, at: 20.days.ago,
    comment: "The view is unbeatable, but the stairs are no joke with groceries." }
]

SAVED_LISTINGS = [
  { user: :diana,    listing: :cozy,   at: 4.days.ago },
  { user: :gabriela, listing: :sunny,  at: 4.days.ago },
  # Edge: a brand-new user saving a listing published an hour ago
  { user: :hugo,     listing: :studio, at: 30.minutes.ago },
  { user: :joaquin,  listing: :bellavista_room, at: 2.days.ago },
  { user: :karen,    listing: :italia_room,     at: 3.days.ago },
  { user: :alice,    listing: :terrace,         at: 6.days.ago }
]

REPORTS = [
  { user: :gabriela, listing: :cozy, reason: "misleading",
    description: "The room is much smaller than the host claims.",
    at: 3.days.ago, reviewed: 1.day.ago, status: "reviewed", reviewer: :admin },
  # The moderator took the listing down (see artsy: withdrawn the same day)
  { user: :bob, listing: :artsy, reason: "fraudulent",
    description: "The host asked for the deposit by bank transfer before any visit.",
    at: 10.days.ago, reviewed: 7.days.ago, status: "actioned", reviewer: :admin },
  # Edge: still pending, reason "other" and no description
  { user: :hugo, listing: :studio, reason: "other", at: 20.minutes.ago },
  { user: :joaquin, listing: :cozy, reason: "offensive",
    description: "The description has a rude comment about tenants.", at: 2.days.ago },
  # Edge: dismissed at the exact moment it was created (reviewed_at == created_at is allowed)
  { user: :karen, listing: :italia_room, reason: "misleading",
    description: "Photos look much bigger than the real room.",
    at: 4.days.ago, reviewed: :immediately, status: "dismissed", reviewer: :admin }
]

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

# Every event goes here as [time, order, action] and is replayed in time order.
# "order" keeps events with the same time in the order they were added.
TIMELINE = []

def happened_at(time, &action)
  TIMELINE << [ time, TIMELINE.size, action ] if time
end

# Lifecycle methods (publish, accept...) return false instead of raising.
# This stops the seed with the model's own error message if one of them fails.
def must(record, method)
  return if record.public_send(method)

  raise "Seed failed: #{record.class} ##{record.id} could not #{method}: #{record.errors.full_messages.to_sentence}"
end

# ---------------------------------------------------------------------------
# RECORDS WITH NO HISTORY: created right away
# ---------------------------------------------------------------------------

users         = USERS.transform_values         { |data| User.create!(password_digest: "pwd", **data) }
neighborhoods = NEIGHBORHOODS.transform_values { |data| Neighborhood.create!(**data) }
amenities     = AMENITIES.transform_values     { |data| Amenity.create!(**data) }
shared_spaces = SHARED_SPACES.transform_values { |data| SharedSpace.create!(**data) }

properties = PROPERTIES.transform_values do |data|
  property = Property.create!(
    user: users.fetch(data[:host]),
    neighborhood: neighborhoods.fetch(data[:neighborhood]),
    **data.slice(:title, :address, :property_type, :bedrooms, :bathrooms)
  )
  data[:amenities].each     { |key| PropertyAmenity.create!(property: property, amenity: amenities.fetch(key)) }
  data[:shared_spaces].each { |key| PropertySharedSpace.create!(property: property, shared_space: shared_spaces.fetch(key)) }
  property
end

# ---------------------------------------------------------------------------
# RECORDS WITH HISTORY: turned into events
# ---------------------------------------------------------------------------

listings     = {}
applications = {}
visits       = {}

LISTINGS.each do |key, data|
  happened_at(data[:created]) do
    listings[key] = Listing.create!(property: properties.fetch(data[:property]), **data[:attributes])
    ListingPhoto.create!(listing: listings[key], **data[:photo]) if data[:photo]
  end
  happened_at(data[:published]) { must(listings[key], :publish) }
  happened_at(data[:withdrawn]) { must(listings[key], :withdraw) }
  happened_at(data[:rented])    { must(listings[key], :mark_as_rented) }
end

APPLICATIONS.each do |key, data|
  happened_at(data[:applied]) do
    applications[key] = Application.create!(
      listing: listings.fetch(data[:listing]),
      seeker: users.fetch(data[:seeker]),
      **data.slice(:message, :desired_move_in_date, :length_of_stay_days)
    )
  end
  happened_at(data[:shortlisted]) { must(applications[key], :shortlist) }
  happened_at(data[:accepted])    { must(applications[key], :accept) }
  happened_at(data[:rejected])    { must(applications[key], :reject) }
  happened_at(data[:withdrawn])   { must(applications[key], :withdraw) }
end

VISITS.each do |key, data|
  happened_at(data[:proposed]) do
    visits[key] = applications.fetch(data[:application]).visits.create!(scheduled_at: data[:scheduled_at])
  end
  happened_at(data.dig(:rescheduled, :at)) do
    new_visit = visits[key].reschedule(data[:rescheduled][:to])
    raise "Seed failed: could not reschedule #{key}: #{visits[key].errors.full_messages.to_sentence}" unless new_visit
 
    visits[key] = new_visit # the events after this one (confirm, complete) apply to the new visit
  end
  happened_at(data[:confirmed]) { must(visits[key], :confirm) }
  happened_at(data[:completed] && (data.dig(:rescheduled, :to) || data[:scheduled_at]) + 1.hour) do
    must(visits[key], :complete)
  end
end

REVIEWS.each do |data|
  happened_at(data[:at]) do
    visit = visits.fetch(data[:visit])
    Review.create!(
      visit: visit,
      property: visit.application.listing.property,
      user: visit.application.seeker,
      rating: data[:rating],
      comment: data[:comment]
    )
  end
end

SAVED_LISTINGS.each do |data|
  happened_at(data[:at]) { SavedListing.create!(user: users.fetch(data[:user]), listing: listings.fetch(data[:listing])) }
end

REPORTS.each do |data|
  report = nil
  happened_at(data[:at]) do
    report = Report.create!(user: users.fetch(data[:user]), listing: listings.fetch(data[:listing]),
                            reason: data[:reason], description: data[:description])
  end
  reviewed = data[:reviewed] == :immediately ? data[:at] : data[:reviewed]
  happened_at(reviewed) do
    report.update!(status: data[:status], reviewer: users.fetch(data[:reviewer]), reviewed_at: Time.current)
  end
end

# ---------------------------------------------------------------------------
# REPLAY: oldest event first, each one "at" its own moment
# ---------------------------------------------------------------------------

TIMELINE.sort_by { |time, order, _| [ time, order ] }.each do |time, _, action|
  travel_to(time) { action.call }
end

# ---------------------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------------------

puts "Seeded the database:"
puts "  Users: #{User.count} | Neighborhoods: #{Neighborhood.count} | Properties: #{Property.count}"
puts "  Listings:     #{Listing.group(:status).count}"
puts "  Applications: #{Application.group(:status).count}"
puts "  Visits:       #{Visit.group(:status).count}"
puts "  Reviews: #{Review.count} | Saved listings: #{SavedListing.count} | Reports: #{Report.group(:status).count}"
