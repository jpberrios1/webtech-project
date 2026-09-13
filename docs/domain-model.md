# Domain Model

![Domain Model Diagram](/docs/domain-model.png)

## Code

```sql
Enum user_role {
  member
  moderator
}

Enum property_type {
  house
  apartment
  other
}

Enum listing_status {
  draft
  published
  reserved
  rented
  withdrawn
}

Enum application_status {
  pending
  shortlisted
  accepted
  rejected
  withdrawn
}

Enum visit_status {
  proposed
  confirmed
  cancelled
  completed
}

Enum report_reason {
  fraudulent
  misleading
  offensive
  other
}

Enum report_status {
  pending
  reviewed
  dismissed
  actioned
}

Table users {
  id integer [pk, increment]
  role user_role [not null, default: 'member']
  name varchar(120) [not null]
  email_address varchar(255) [not null, unique]
  password_digest varchar(255) [not null]
  phone varchar(30)
  created_at timestamp [not null]
  updated_at timestamp [not null]

  Note: '''
  A VISITOR is not stored as a role here: it is the absence of an account'''
}

Table neighborhoods {
  id integer [pk, increment]
  name varchar(120) [not null]
  city varchar(120) [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (name, city) [unique]
  }
  Note: 'Indexed like this because there can be two neigborhoods with same names.'
}

Table amenities {
  id integer [pk, increment]
  name varchar(80) [not null, unique]
  description text
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (name) [unique]
  }
}

Table shared_spaces {
  id integer [pk, increment]
  name varchar(80) [not null, unique]
  description text
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (name) [unique]
  }
}

Table properties {
  id integer [pk, increment]
  user_id integer [not null, note: 'The host who owns the property']
  neighborhood_id integer [not null]
  title varchar(150) [not null]
  address varchar(255) [not null]
  property_type property_type [not null]
  bedrooms integer [not null]
  bathrooms integer [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    user_id
    neighborhood_id
  }
}

Table property_amenities {
  id integer [pk, increment]
  property_id integer [not null]
  amenity_id integer [not null]

  indexes {
    (property_id, amenity_id) [unique]
  }
}

Table property_shared_spaces {
  id integer [pk, increment]
  property_id integer [not null]
  shared_space_id integer [not null]

  indexes {
    (property_id, shared_space_id) [unique]
  }
}

Table listings {
  id integer [pk, increment]
  property_id integer [not null]
  title varchar(150) [not null]
  monthly_rent decimal(10,2) [not null]
  deposit decimal(10,2) [not null, default: 0]
  available_from date [not null]
  minimum_stay_days integer [note: 'nullable => host can set no minimum']
  is_furnished boolean [not null, default: false]
  has_private_bathroom boolean [not null, default: false]
  description text
  house_rules text
  status listing_status [not null, default: 'draft']
  published_at timestamp
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    property_id
    status
    available_from
  }
  Note: '''
  One listing per available room.'''
}

Table listing_photos {
  id integer [pk, increment]
  listing_id integer [not null]
  url varchar(500) [not null]
  caption varchar(255)
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    listing_id
  }
}

Table saved_listings {
  id integer [pk, increment]
  user_id integer [not null]
  listing_id integer [not null]
  created_at timestamp [not null]

  indexes {
    (user_id, listing_id) [unique]
  }
}

Table applications {
  id integer [pk, increment]
  listing_id integer [not null]
  seeker_id integer [not null, note: 'FK -> users']
  message text [not null]
  desired_move_in_date date [not null]
  length_of_stay_days integer [not null]
  status application_status [not null, default: 'pending']
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    (listing_id, seeker_id) [unique]
    status
  }
  Note: '''
  No seeker applies twice to the same listing.
  Seeker cannot apply to a listing whose property they own
  Seeker cannot apply to a listing that is not "published"
  Only one accepted application per listing
  '''
}

Table visits {
  id integer [pk, increment]
  application_id integer [not null]
  scheduled_at datetime [not null]
  status visit_status [not null, default: 'proposed']
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    application_id
  }
  Note: '''
  A visit ALWAYS belongs to an application (NOT NULL FK)
  '''
}

// ------------------ REVIEWS AND REPORTS ---------------------

Table reviews {
  id integer [pk, increment]
  visit_id integer [not null, unique, note: 'visit must have completed state']
  property_id integer [not null]
  user_id integer [not null, note: 'FK -> The seeker who visited']
  rating integer [not null, note: 'between 1 and 5']
  comment text
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    property_id
  }
}

Table reports {
  id integer [pk, increment]
  listing_id integer [not null]
  user_id integer [not null, note: 'FK -> users, the reporter']
  reason report_reason [not null]
  description text
  status report_status [not null, default: 'pending']
  reviewer_id integer [note: 'FK -> users, the moderator who handled it']
  reviewed_at timestamp
  created_at timestamp [not null]
  updated_at timestamp [not null]

  indexes {
    listing_id
    status
  }
}

// users
Ref: properties.user_id > users.id
Ref: applications.seeker_id > users.id
Ref: reviews.user_id > users.id
Ref: saved_listings.user_id > users.id
Ref: reports.user_id > users.id
Ref: reports.reviewer_id > users.id

// catalogs
Ref: properties.neighborhood_id > neighborhoods.id

// properties <-> amenities  (M:N)
Ref: property_amenities.property_id > properties.id
Ref: property_amenities.amenity_id > amenities.id

// properties <-> shared spaces  (M:N)
Ref: property_shared_spaces.property_id > properties.id
Ref: property_shared_spaces.shared_space_id > shared_spaces.id

// properties -> listings
Ref: listings.property_id > properties.id
Ref: listing_photos.listing_id > listings.id

// users <-> listings  (M:N)
Ref: saved_listings.listing_id > listings.id
Ref: applications.listing_id > listings.id
Ref: reports.listing_id > listings.id

// the application links
Ref: visits.application_id > applications.id
Ref: reviews.visit_id - visits.id
Ref: reviews.property_id > properties.id
```
