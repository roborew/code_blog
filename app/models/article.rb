class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  STATUSES = %w[draft published archived scheduled].freeze

  belongs_to :user
  belongs_to :category, optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_one_attached :cover_image
  has_many_attached :content_images

  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :abstract, length: { maximum: 500 }, allow_blank: true
  validate :abstract_word_limit

  before_destroy :purge_cover_image
  before_destroy :purge_content_images

  # Override this method to regenerate the slug when the title changes
  def should_generate_new_friendly_id?
    title_changed?
  end

  has_paper_trail

  private

  def abstract_word_limit
    return if abstract.blank?
    word_count = abstract.split.size
    if word_count > 30
      errors.add(:abstract, "must be 30 words or less (currently: #{word_count} words)")
    end
  end

  def purge_cover_image
    cover_image.purge_later if cover_image.attached?
  end

  def purge_content_images
    content_images.purge_later if content_images.attached?
  end
end
