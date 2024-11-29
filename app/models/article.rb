class Article < ApplicationRecord
  STATUSES = %w[draft published archived scheduled].freeze

  belongs_to :user
  belongs_to :category, optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_one_attached :cover_image

  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES }
end
