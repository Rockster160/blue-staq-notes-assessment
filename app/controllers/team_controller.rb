class TeamController < ApplicationController
  before_action :authenticate!

  def index
    render json: current_user.teams.select(:id, :name)
  end

  def create
    @team = current_user.teams.new(team_params)

    if @team.save
      render json: @team.slice(:id, :name), status: :created
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @team = current_user.teams.find(params[:team_id])

    if @team.save
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
