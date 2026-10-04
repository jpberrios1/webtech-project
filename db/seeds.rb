# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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

hosts = [
  User.create!(name: "Alice Host", email_address: "alice@roomies.com", password_digest: "pwd", phone: "555-0001", role: "member"),
  User.create!(name: "Carlos Host", email_address: "carlos@roomies.com", password_digest: "pwd", phone: "555-0002", role: "member"),
  User.create!(name: "Elena Host", email_address: "elena@roomies.com", password_digest: "pwd", phone: "555-0003", role: "member")
]

seekers = [
  User.create!(name: "Bob Seeker", email_address: "bob@roomies.com", password_digest: "pwd", phone: "555-0101", role: "member"),
  User.create!(name: "Diana Seeker", email_address: "diana@roomies.com", password_digest: "pwd", phone: "555-0102", role: "member"),
  User.create!(name: "Felipe Seeker", email_address: "felipe@roomies.com", password_digest: "pwd", phone: "555-0103", role: "member"),
  User.create!(name: "Gabriela Seeker", email_address: "gabriela@roomies.com", password_digest: "pwd", phone: "555-0104", role: "member")
]

moderator = User.create!(name: "Admin Mod", email_address: "admin@roomies.com", password_digest: "pwd", role: "moderator")

n_providencia = Neighborhood.create!(name: "Providencia", city: "Santiago")
n_las_condes = Neighborhood.create!(name: "Las Condes", city: "Santiago")
n_santiago = Neighborhood.create!(name: "Santiago Centro", city: "Santiago")
n_nunoa = Neighborhood.create!(name: "Ñuñoa", city: "Santiago")

wifi = Amenity.create!(name: "Gigabit WiFi", description: "900 Mbps fiber optic")
laundry = Amenity.create!(name: "In-unit Laundry", description: "Washer and dryer available")
ac = Amenity.create!(name: "Air Conditioning", description: "Split AC in all rooms")
living_room = SharedSpace.create!(name: "Living Room", description: "Large couch and 65-inch TV")
kitchen = SharedSpace.create!(name: "Full Kitchen", description: "Oven, microwave, dishwasher")
balcony = SharedSpace.create!(name: "Balcony", description: "Great city view")

properties = [
  Property.create!(user: hosts[0], neighborhood: n_providencia, title: "Modern Duplex in Pedro de Valdivia", address: "Av. Pedro de Valdivia 123", property_type: "apartment", bedrooms: 3, bathrooms: 2),
  Property.create!(user: hosts[1], neighborhood: n_las_condes, title: "Spacious House in El Golf", address: "Isidora Goyenechea 456", property_type: "house", bedrooms: 5, bathrooms: 3),
  Property.create!(user: hosts[2], neighborhood: n_santiago, title: "Artsy Loft in Lastarria", address: "José Victorino Lastarria 789", property_type: "apartment", bedrooms: 2, bathrooms: 1),
  Property.create!(user: hosts[0], neighborhood: n_nunoa, title: "Cozy Flat near Plaza Ñuñoa", address: "Irarrázaval 321", property_type: "apartment", bedrooms: 3, bathrooms: 2)
]

properties.each do |prop|
  PropertyAmenity.create!(property: prop, amenity: wifi)
  PropertySharedSpace.create!(property: prop, shared_space: kitchen)
end
PropertyAmenity.create!(property: properties[1], amenity: laundry)
PropertyAmenity.create!(property: properties[2], amenity: ac)
PropertySharedSpace.create!(property: properties[0], shared_space: balcony)
PropertySharedSpace.create!(property: properties[3], shared_space: living_room)


list1 = Listing.create!(
  property: properties[0],
  title: "Sunny Master Bedroom",
  status: "published",
  monthly_rent: 450.0,
  deposit: 450.0,
  is_furnished: true,
  has_private_bathroom: true,
  minimum_stay_days: 90,
  available_from: Date.current + 10.days,
  description: "Beautiful room with plenty of light.",
  published_at: 10.days.ago,
  created_at: 10.days.ago
)

ListingPhoto.create!(listing: list1, url: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267", caption: "Bedroom view")

list2 = Listing.create!(
  property: properties[0],
  title: "Small Cozy Room",
  status: "published",
  monthly_rent: 300.0,
  deposit: 300.0,
  is_furnished: false,
  has_private_bathroom: false,
  minimum_stay_days: 30,
  available_from: Date.current + 5.days,
  description: "Perfect for students.",
  published_at: 5.days.ago,
  created_at: 5.days.ago
)

list3 = Listing.create!(
  property: properties[1],
  title: "Luxury Room (Not ready yet)",
  status: "draft",
  monthly_rent: 600.0,
  deposit: 600.0,
  is_furnished: true,
  has_private_bathroom: true,
  minimum_stay_days: 180,
  available_from: Date.current + 30.days,
  description: "Still painting the walls.",
  created_at: 1.day.ago
)

list4 = Listing.create!(
  property: properties[3], 
  title: "Quiet Room near Plaza Ñuñoa", 
  status: "published",
  monthly_rent: 380.0, 
  deposit: 380.0, 
  is_furnished: true, 
  has_private_bathroom: false,
  minimum_stay_days: 60, 
  available_from: Date.current + 5.days, 
  description: "Great location, lots of bars and restaurants nearby.",
  published_at: 2.days.ago, 
  created_at: 2.days.ago
)

app1 = Application.create!(
  listing: list4,
  seeker: seekers[0],
  status: "accepted",
  message: "I love Lastarria, moving in ASAP!",
  desired_move_in_date: Date.current + 15.days,
  length_of_stay_days: 180,
  created_at: 15.days.ago
)

list4.update!(status: "rented")

visit1 = Visit.create!(
  application: app1,
  status: "completed",
  scheduled_at: 12.days.ago,
  created_at: 14.days.ago
)

Review.create!(
  visit: visit1, 
  property: app1.listing.property, # <-- Usamos dinámicamente la propiedad de la postulación
  user: seekers[0], 
  rating: 5,
  comment: "Host is amazing, area is noisy but the room is great.", 
  created_at: 2.days.ago
)

app2 = Application.create!(
  listing: list1,
  seeker: seekers[1],
  status: "shortlisted",
  message: "Is the private bathroom inside the room?",
  desired_move_in_date: Date.current + 20.days,
  length_of_stay_days: 90,
  created_at: 5.days.ago
)
Visit.create!(application: app2, status: "confirmed", scheduled_at: Date.current + 1.day, created_at: 4.days.ago)

app3 = Application.create!(
  listing: list1,
  seeker: seekers[2],
  status: "pending",
  message: "I can pay 6 months upfront.",
  desired_move_in_date: Date.current + 12.days,
  length_of_stay_days: 180,
  created_at: 2.days.ago
)

SavedListing.create!(user: seekers[1], listing: list2)
SavedListing.create!(user: seekers[3], listing: list1)

report1 = Report.create!(
  user: seekers[3],
  listing: list2,
  reason: "misleading",
  status: "reviewed",
  description: "The room is much smaller than the host claims.",
  reviewer_id: moderator.id, created_at: 3.days.ago
)

report1.update_column(:reviewed_at, 1.day.ago) 

app_old_lastarria = Application.new(
  listing: list4,
  seeker: seekers[2],
  status: "accepted",
  message: "I lived here last year, moving back!",
  desired_move_in_date: 400.days.ago,
  length_of_stay_days: 180,
  created_at: 420.days.ago
)
app_old_lastarria.save!(validate: false) 

visit_old_lastarria = Visit.new(
  application: app_old_lastarria,
  status: "completed",
  scheduled_at: 415.days.ago,
  created_at: 418.days.ago
)
visit_old_lastarria.save!(validate: false)

Review.new(
  visit: visit_old_lastarria,
  property: list4.property,
  user: seekers[2],
  rating: 4,
  comment: "Really nice loft. The only downside is the lack of parking, but the subway is very close.", 
  created_at: 200.days.ago
).save!(validate: false)


app_providencia = Application.new(
  listing: list2,
  seeker: seekers[3],
  status: "accepted",
  message: "Perfect for my semester abroad.",
  desired_move_in_date: 200.days.ago,
  length_of_stay_days: 120,
  created_at: 210.days.ago
)

app_providencia.save!(validate: false)

visit_providencia = Visit.new(
  application: app_providencia,
  status: "completed",
  scheduled_at: 205.days.ago,
  created_at: 208.days.ago
)

visit_providencia.save!(validate: false)

Review.new(
  visit: visit_providencia, property: list2.property, user: seekers[3], rating: 5,
  comment: "Super cozy room and great location. Alice is a wonderful host!", 
  created_at: 80.days.ago
).save!(validate: false)

app_nunoa = Application.new(
  listing: list4,
  seeker: seekers[1],
  status: "accepted",
  message: "Moving for a new job nearby.",
  desired_move_in_date: 300.days.ago,
  length_of_stay_days: 90,
  created_at: 310.days.ago
)

app_nunoa.save!(validate: false)

visit_nunoa = Visit.new(
  application: app_nunoa,
  status: "completed",
  scheduled_at: 305.days.ago,
  created_at: 308.days.ago
)

visit_nunoa.save!(validate: false)

Review.new(
  visit: visit_nunoa,
  property: list4.property,
  user: seekers[1],
  rating: 5,
  comment: "Very quiet neighborhood, exactly what I needed to study and work. Highly recommended.", 
  created_at: 200.days.ago
).save!(validate: false)

puts "Base de datos sembrada con éxito. Registros creados:"
puts "Propiedades: #{Property.count} | Listings: #{Listing.count} | Aplicaciones: #{Application.count} | Visitas: #{Visit.count} | Reseñas: #{Review.count}"