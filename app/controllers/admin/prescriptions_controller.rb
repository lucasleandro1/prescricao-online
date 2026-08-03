class Admin::PrescriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prescription, only: [ :edit, :update, :destroy ]

  def index
    @query = params[:q]
    @prescriptions = @query.present? ? Prescription.search(@query).ordered : Prescription.ordered
    @prescriptions = @prescriptions.includes(:creator, :updater)
  end

  def new
    @prescription = Prescription.new
  end

  def create
    @prescription = Prescription.new(prescription_params)
    @prescription.created_by_id = current_user.id
    @prescription.updated_by_id = current_user.id
    if @prescription.save
      redirect_to admin_prescriptions_path, notice: "Prescrição criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @prescription.updated_by_id = current_user.id
    if @prescription.update(prescription_params)
      redirect_to admin_prescriptions_path, notice: "Prescrição atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_admin!
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

  def authorize_admin!
    unless current_user.admin?
      redirect_to admin_prescriptions_path, alert: "Apenas administradores podem deletar prescrições."
    end
  end
end
