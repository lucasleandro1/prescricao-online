require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:created_prescriptions).class_name("Prescription").with_foreign_key(:created_by_id) }
    it { is_expected.to have_many(:updated_prescriptions).class_name("Prescription").with_foreign_key(:updated_by_id) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:role).in_array(User::ROLES) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "defaults" do
    it "has 'user' as default role" do
      u = User.new
      expect(u.role).to eq("user")
    end
  end

  describe "#admin?" do
    it "returns true when role is admin" do
      expect(build(:user, :admin).admin?).to be true
    end

    it "returns false when role is user" do
      expect(build(:user).admin?).to be false
    end
  end

  describe "ROLES constant" do
    it "includes admin and user" do
      expect(User::ROLES).to contain_exactly("admin", "user")
    end
  end
end
