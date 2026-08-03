require "rails_helper"

RSpec.describe "Admin::Prescriptions", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated requests to login" do
      get admin_prescriptions_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /admin/prescriptions" do
    before { sign_in admin }

    it "returns 200" do
      get admin_prescriptions_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by query" do
      p1 = create(:prescription, title: "Abscesso algo")
      p2 = create(:prescription, title: "Zoonose outra")
      get admin_prescriptions_path, params: { q: "Abscesso" }
      expect(response.body).to include(p1.title)
      expect(response.body).not_to include(p2.title)
    end
  end

  describe "GET /admin/prescriptions/new" do
    before { sign_in user }

    it "returns 200 for any authenticated user" do
      get new_admin_prescription_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/prescriptions" do
    before { sign_in user }

    let(:valid_attrs) { { title: "Nova Prescrição", content: "Conteúdo válido", category: "Geral" } }
    let(:invalid_attrs) { { title: "", content: "" } }

    it "creates a prescription and records the creator" do
      expect {
        post admin_prescriptions_path, params: { prescription: valid_attrs }
      }.to change(Prescription, :count).by(1)

      expect(response).to redirect_to(admin_prescriptions_path)
      expect(Prescription.last.created_by_id).to eq(user.id)
      expect(Prescription.last.updated_by_id).to eq(user.id)
    end

    it "does not create with invalid params and re-renders form" do
      expect {
        post admin_prescriptions_path, params: { prescription: invalid_attrs }
      }.not_to change(Prescription, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/prescriptions/:id/edit" do
    before { sign_in user }
    let(:prescription) { create(:prescription) }

    it "returns 200" do
      get edit_admin_prescription_path(prescription)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/prescriptions/:id" do
    before { sign_in user }
    let(:prescription) { create(:prescription) }

    it "updates the prescription and records the updater" do
      patch admin_prescription_path(prescription), params: { prescription: { title: "Título Atualizado" } }
      expect(response).to redirect_to(admin_prescriptions_path)
      expect(prescription.reload.title).to eq("Título Atualizado")
      expect(prescription.reload.updated_by_id).to eq(user.id)
    end

    it "re-renders form on invalid params" do
      patch admin_prescription_path(prescription), params: { prescription: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /admin/prescriptions/:id" do
    let!(:prescription) { create(:prescription) }

    context "as admin" do
      before { sign_in admin }

      it "deletes the prescription" do
        expect {
          delete admin_prescription_path(prescription)
        }.to change(Prescription, :count).by(-1)
        expect(response).to redirect_to(admin_prescriptions_path)
      end
    end

    context "as regular user" do
      before { sign_in user }

      it "does not delete and redirects with alert" do
        expect {
          delete admin_prescription_path(prescription)
        }.not_to change(Prescription, :count)
        expect(response).to redirect_to(admin_prescriptions_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
