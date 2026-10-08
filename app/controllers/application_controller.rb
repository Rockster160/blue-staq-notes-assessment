class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  private

  def current_user
    raise "TODO: Authentication!"
    # @current_user ||= User.authenticate... # TODO: Authorization
  end

  def authenticate!
    render(json: { error: "Unauthorized" }, status: :unauthorized) unless current_user
  end
end
