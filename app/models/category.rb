class Category < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def self.find_or_create(name, user)
    Category.find_by(name: name, user: user) || Category.create(name: name, user: user)
  end
end
