class TeamsController < ApplicationController
  def index
    render json: current_user.teams.select(:id, :name)
  end

  def create
    @team = current_user.owned_teams.new(team_params)
    @team.memberships.build(user: current_user)

    if @team.save
      render json: @team.slice(:id, :name), status: :created
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @team = current_user.teams.find(params[:id])

    if @team.update(team_params)
      render json: @team.slice(:id, :name), status: :ok
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
