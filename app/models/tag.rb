class Tag < ApplicationRecord
  belongs_to :user, optional: true  # nil means it's a global tag
  has_many :taggings, dependent: :destroy
  has_many :articles, through: :taggings

  scope :global, -> { where(user_id: nil) }
  scope :personal, ->(user) { where(user_id: user.id) }

   # Define common tags - could also be moved to a configuration file
   COMMON_TAGS = Rails.application.config.common_tags

   # Class method to handle finding or creating tags
   def self.find_or_create(name, user)
     # First try to find a global tag
     tag = global.find_by("name ILIKE ?", name)
     # Then try to find a user-specific tag
     tag ||= personal(user).find_by("name ILIKE ?", name)

     # If neither exists, create a new user-specific tag
     tag ||= create(
       name: name,
       user_id: should_be_global?(name) ? nil : user.id
     )

     tag.name = tag.name.downcase
     tag
   end

   private

   def self.should_be_global?(name)
     COMMON_TAGS.include?(name.downcase) ||
       where("name ILIKE ?", name)
           .group(:name)
           .count
           .values
           .first.to_i > 10  # Promote to global if used by >10 users
   end
end
