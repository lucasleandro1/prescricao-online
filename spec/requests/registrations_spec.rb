require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "POST /auth (sign up)" do
    let(:valid_attrs) do
      { user: { name: "Maria Silva", email: "maria@exemplo.com",
                password: "Senha@123", password_confirmation: "Senha@123" } }
    end

    it "creates a new user with the name parameter" do
      expect {
        post user_registration_path, params: valid_attrs
      }.to change(User, :count).by(1)
      expect(User.last.name).to eq("Maria Silva")
    end

    it "does not create user with blank name" do
      expect {
        post user_registration_path, params: {
          user: { name: "", email: "teste@exemplo.com",
                  password: "Senha@123", password_confirmation: "Senha@123" }
        }
      }.not_to change(User, :count)
    end
  end
end
