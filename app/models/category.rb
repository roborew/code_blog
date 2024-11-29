class Category < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def self.find_or_create(name, user)
    return nil if name.blank?
    capitalized_name = name.capitalize
    Category.find_by(name: capitalized_name, user: user) ||
      Category.create(name: capitalized_name, user: user)
  end
end
