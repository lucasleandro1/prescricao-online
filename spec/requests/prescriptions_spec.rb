require "rails_helper"

RSpec.describe "Prescriptions", type: :request do
  describe "GET /" do
    context "with no prescriptions" do
      it "returns 200 and renders the page" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Arquivo de Prescrições")
      end
    end

    context "with prescriptions" do
      before { create_list(:prescription, 3) }

      it "embeds prescription JSON in the page" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("data-prescriptions-data-value")
      end
    end
  end
end
