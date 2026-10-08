class NoteController < ApplicationController
  before_action :set_team, only: [:index, :create]
  before_action :set_note, only: [:show, :update]

  def index
    render json: @team.notes
  end

  def show
    render json: @note
  end

  def create
    @note = @team.notes.new(note_params.merge(author: current_user))

    if @note.save
      render json: @note, status: :created
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      render json: @note
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @note = current_user.authored_notes.find(params[:id]).destroy!

    head :no_content
  end

  private

  def set_team
    @team = current_user.teams.find(params[:team_id])
  end

  def set_note
    @note = current_user.viewable_notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end
end
