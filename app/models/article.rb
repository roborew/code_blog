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
  validates :abstract, length: { maximum: 500 }, allow_blank: true
  validate :abstract_word_limit

  private

  def abstract_word_limit
    return if abstract.blank?
    word_count = abstract.split.size
    if word_count > 30
      errors.add(:abstract, "must be 30 words or less (currently: #{word_count} words)")
    end
  end
end
