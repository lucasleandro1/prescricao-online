class Prescription < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by_id, optional: true

  validates :title, presence: true, uniqueness: true
  validates :content, presence: true

  before_save :set_category

  scope :ordered, -> { order(Arel.sql("position ASC NULLS LAST, title ASC")) }
  scope :search, ->(query) { where("title LIKE ? OR category LIKE ?", "%#{query}%", "%#{query}%") }

  private

  def set_category
    self.category = title.split(/\s*[-–\/]\s*/).first.strip if category.blank?
  end
end
