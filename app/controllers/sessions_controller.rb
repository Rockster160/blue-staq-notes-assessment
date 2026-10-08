class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  rate_limit(
    to: 10,
    within: 3.minutes,
    only: :create,
    with: -> { render json: { error: "Try again later" }, status: :too_many_requests }
  )

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for user
      render json: user.slice(:id, :email, :username), status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    terminate_session

    head :no_content
  end
end
