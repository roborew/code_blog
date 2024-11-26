class Category < ApplicationRecord
  belongs_to :user
  has_many :articles, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
