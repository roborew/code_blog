class Article < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: %w[draft published archived scheduled] }
end
