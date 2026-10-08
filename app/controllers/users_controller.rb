class UsersController < ApplicationController
  def create
    # Just leaving this open for now- anybody can create.
    # We'd scope to the org or require a user get created by an admin if this wasn't internal.
    @user = User.new(user_params)

    if user.save
      render json: @user.slice(:id, :email, :username), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password)
  end
end
