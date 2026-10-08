class MembershipsController < ApplicationController
  before_action :authenticate!

  def create
    # Could require the current user to be either owner or have invite permissions
    team = current_user.teams.find(params[:team_id])
    user = User.find_by!(email: params[:email].to_s.downcase)

    @membership = team.memberships.new(user: user)

    if @membership.save
      render json: @membership, status: :created
    else
      render json: { errors: @membership.errors.full_messages }, status: :unprocessable_entity
    end

    render json: membership.slice(:id, :team_id, :user_id, :role), status: :created
  end

  def destroy
    @membership = current_user.viewable_memberships.find(params[:id])

    if membership.destroy
      head :no_content
    else
      render json: { errors: @membership.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
