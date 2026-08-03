class Prescription < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true

  before_save :set_category

  scope :ordered, -> { order(:position, :title) }
  scope :search, ->(query) { where("title LIKE ? OR category LIKE ?", "%#{query}%", "%#{query}%") }

  private

  def set_category
    self.category = title.split(/\s*[-–\/]\s*/).first.strip if category.blank?
  end
end
