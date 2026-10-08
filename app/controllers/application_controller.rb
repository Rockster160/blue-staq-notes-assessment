class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Authentication

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end
  rescue_from ActiveRecord::RecordNotUnique do
    render json: { error: "Membership already active" }, status: :unprocessable_content
  end

  def request_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  private

  def current_user = (@current_user ||= Current.user)
end
