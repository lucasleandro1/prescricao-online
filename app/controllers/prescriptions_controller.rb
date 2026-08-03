class PrescriptionsController < ApplicationController
  def index
    @prescriptions = Prescription.ordered.select(:id, :title, :content, :category)
    @prescriptions_json = @prescriptions.map { |p|
      { id: p.id, title: p.title, content: p.content, category: p.category }
    }.to_json
  end
end
