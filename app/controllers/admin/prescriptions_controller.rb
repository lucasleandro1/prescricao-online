class Admin::PrescriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prescription, only: [ :edit, :update, :destroy ]

  PER_PAGE = 8

  def index
    @query  = params[:q]
    scope   = (@query.present? ? Prescription.search(@query).ordered : Prescription.ordered).includes(:creator, :updater)
    @total  = scope.count
    @page   = [[params[:page].to_i, 1].max, [(@total.to_f / PER_PAGE).ceil, 1].max].min
    @total_pages = [(@total.to_f / PER_PAGE).ceil, 1].max
    @prescriptions = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
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
    unless current_user.admin?
      return redirect_to admin_prescriptions_path, alert: "Apenas administradores podem deletar prescrições."
    end
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
