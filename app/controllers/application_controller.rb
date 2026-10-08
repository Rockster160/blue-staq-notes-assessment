class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  def request_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  private

  def current_user = (@current_user ||= Current.user)
end
