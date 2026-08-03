class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :created_prescriptions, class_name: "Prescription", foreign_key: :created_by_id
  has_many :updated_prescriptions, class_name: "Prescription", foreign_key: :updated_by_id

  validates :name, presence: true

  ROLES = %w[admin user].freeze
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end
end
