class Page < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many_attached :content_images

  validates :title, presence: true
  validates :content, presence: true

  before_destroy :purge_content_images

  private

  def purge_content_images
    content_images.purge_later if content_images.attached?
  end
end
