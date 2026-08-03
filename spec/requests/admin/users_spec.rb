require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  describe "authorization" do
    before { sign_in user }

    it "redirects non-admin to admin root" do
      get admin_users_path
      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "authentication" do
    it "redirects unauthenticated to login" do
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /admin/users" do
    before { sign_in admin }

    it "returns 200 and lists users" do
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/users/new" do
    before { sign_in admin }

    it "returns 200" do
      get new_admin_user_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/users" do
    before { sign_in admin }

    let(:valid_attrs) do
      { name: "João Silva", email: "joao@exemplo.com",
        password: "Senha@123", password_confirmation: "Senha@123", role: "user" }
    end

    it "creates a user" do
      expect {
        post admin_users_path, params: { user: valid_attrs }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(admin_users_path)
    end

    it "does not create with invalid params" do
      expect {
        post admin_users_path, params: { user: { name: "", email: "" } }
      }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/users/:id/edit" do
    before { sign_in admin }

    it "returns 200" do
      get edit_admin_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/users/:id" do
    before { sign_in admin }

    it "updates user name" do
      patch admin_user_path(user), params: { user: { name: "Novo Nome", email: user.email } }
      expect(response).to redirect_to(admin_users_path)
      expect(user.reload.name).to eq("Novo Nome")
    end

    it "updates password when provided" do
      patch admin_user_path(user), params: {
        user: { name: user.name, email: user.email,
                password: "NovaSenha@1", password_confirmation: "NovaSenha@1" }
      }
      expect(response).to redirect_to(admin_users_path)
    end

    it "skips password update when blank" do
      original_password_digest = user.encrypted_password
      patch admin_user_path(user), params: {
        user: { name: "Outro Nome", email: user.email, password: "", password_confirmation: "" }
      }
      expect(user.reload.encrypted_password).to eq(original_password_digest)
    end

    it "re-renders form on invalid params" do
      patch admin_user_path(user), params: { user: { name: "", email: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /admin/users/:id" do
    before { sign_in admin }

    it "deletes another user" do
      other = create(:user)
      expect {
        delete admin_user_path(other)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_users_path)
    end

    it "does not allow admin to delete themselves" do
      expect {
        delete admin_user_path(admin)
      }.not_to change(User, :count)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to be_present
    end
  end
end
