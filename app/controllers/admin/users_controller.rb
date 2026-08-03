class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.order(:name, :email)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "Usuário criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params_to_use = user_params
    params_to_use = params_to_use.except(:password, :password_confirmation) if params_to_use[:password].blank?
    if @user.update(params_to_use)
      redirect_to admin_users_path, notice: "Usuário atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "Você não pode deletar sua própria conta."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "Usuário removido com sucesso!"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to admin_root_path, alert: "Apenas administradores podem gerenciar usuários."
    end
  end
end
