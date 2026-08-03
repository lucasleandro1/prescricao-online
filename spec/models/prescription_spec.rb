require "rails_helper"

RSpec.describe Prescription, type: :model do
  subject(:prescription) { build(:prescription) }

  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name("User").optional }
    it { is_expected.to belong_to(:updater).class_name("User").optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:title) }
  end

  describe "scopes" do
    let!(:p1) { create(:prescription, title: "Abscesso", category: "Cirurgia", position: 2) }
    let!(:p2) { create(:prescription, title: "Zoonose",  category: "Infectologia", position: 1) }
    let!(:p3) { create(:prescription, title: "Cefaleia", category: "Cirurgia", position: nil) }

    describe ".ordered" do
      it "orders by position first, then title, nulls last" do
        ordered = Prescription.ordered.to_a
        expect(ordered[0]).to eq(p2)  # position 1
        expect(ordered[1]).to eq(p1)  # position 2
        expect(ordered[2]).to eq(p3)  # position nil → last
      end
    end

    describe ".search" do
      it "finds by title substring" do
        expect(Prescription.search("Abscesso")).to include(p1)
        expect(Prescription.search("Abscesso")).not_to include(p2)
      end

      it "finds by category substring" do
        expect(Prescription.search("Cirurgia")).to include(p1, p3)
        expect(Prescription.search("Cirurgia")).not_to include(p2)
      end

      it "returns all matches case-insensitively" do
        expect(Prescription.search("abscesso")).to include(p1)
      end
    end
  end

  describe "#set_category (before_save)" do
    it "sets category from title when blank" do
      p = create(:prescription, title: "Abscesso - tratamento conservador", category: "")
      expect(p.category).to eq("Abscesso")
    end

    it "sets category splitting on em-dash" do
      p = create(:prescription, title: "Dor – analgesia geral", category: "")
      expect(p.category).to eq("Dor")
    end

    it "sets category splitting on slash" do
      p = create(:prescription, title: "Afta / estomatite – TRIANCINOLONA", category: "")
      expect(p.category).to eq("Afta")
    end

    it "does not overwrite existing category" do
      p = create(:prescription, title: "Algo - subtítulo", category: "Categoria Manual")
      expect(p.category).to eq("Categoria Manual")
    end
  end
end
