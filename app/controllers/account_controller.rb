class AccountController < ApplicationController
  before_action :valid_password?, only: :update

  def show
    render json: current_user.slice(:id, :email, :username)
  end

  def update
    if current_user.update(account_params)
      render json: current_user.slice(:id, :email, :username)
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def account_params
    params.require(:user).permit(:email, :username, :password)
  end

  def valid_password?
    return unless params.dig(:user).key?(:password)
    return if current_user.authenticate(params[:user][:current_password])

    render json: { errors: ["Current password is incorrect"] }, status: :unprocessable_content
  end
end
