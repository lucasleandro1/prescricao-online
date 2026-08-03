class Admin::PrescriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prescription, only: [ :edit, :update, :destroy ]

  def index
    @query = params[:q]
    @prescriptions = @query.present? ? Prescription.search(@query).ordered : Prescription.ordered
    @prescriptions = @prescriptions.page(params[:page]).per(50) if @prescriptions.respond_to?(:page)
  end

  def new
    @prescription = Prescription.new
  end

  def create
    @prescription = Prescription.new(prescription_params)
    if @prescription.save
      redirect_to admin_prescriptions_path, notice: "Prescrição criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prescription.update(prescription_params)
      redirect_to admin_prescriptions_path, notice: "Prescrição atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prescription.destroy
    redirect_to admin_prescriptions_path, notice: "Prescrição deletada com sucesso!"
  end

  private

  def set_prescription
    @prescription = Prescription.find(params[:id])
  end

  def prescription_params
    params.require(:prescription).permit(:title, :content, :category, :position)
  end
end
