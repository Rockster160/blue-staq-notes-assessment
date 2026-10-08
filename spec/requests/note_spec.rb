require 'rails_helper'

RSpec.describe "Notes", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team) }

  before do
    FactoryBot.create(:membership, user: user, team: team)
    sign_in(user)
  end

  describe "GET /teams/:team_id/notes" do
    it "lists the team's notes for a member" do
      FactoryBot.create(:note, team: team, author: user, title: "A")
      FactoryBot.create(:note, team: team, author: user, title: "B")

      get "/teams/#{team.id}/notes"

      expect(response).to have_http_status(:ok)
      expect(json.map { |n| n[:title] }).to contain_exactly("A", "B")
    end

    it "404s the index for a non-member" do
      other = FactoryBot.create(:team)
      get "/teams/#{other.id}/notes"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /notes/:id" do
    it "lets a teammate read a note" do
      note = FactoryBot.create(:note, team: team, author: user, title: "Roadmap")
      get "/notes/#{note.id}"
      expect(response).to have_http_status(:ok)
      expect(json).to include(title: "Roadmap")
    end

    it "404s a note on a team the user is not on" do
      note = FactoryBot.create(:note)
      get "/notes/#{note.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /teams/:team_id/notes" do
    it "creates a note authored by the current user" do
      expect {
        post "/teams/#{team.id}/notes", params: { note: { title: "Meeting", body: "agenda" } }, as: :json
      }.to change(Note, :count).by(1)

      expect(json).to include(title: "Meeting")
      expect(Note.find(json[:id]).author).to eq(user)
    end

    it "rejects a blank title with 422" do
      expect {
        post "/teams/#{team.id}/notes", params: { note: { title: "", body: "x" } }, as: :json
      }.not_to change(Note, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "404s creating in a team the user is not on" do
      other = FactoryBot.create(:team)
      post "/teams/#{other.id}/notes", params: { note: { title: "Sneaky", body: "x" } }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /notes/:id" do
    it "lets a teammate update a note" do
      note = FactoryBot.create(:note, team: team, author: user, title: "Old")
      patch "/notes/#{note.id}", params: { note: { title: "New" } }, as: :json
      expect(response).to have_http_status(:ok)
      expect(note.reload.title).to eq("New")
    end

    it "404s updating a note on a team the user is not on" do
      note = FactoryBot.create(:note)
      patch "/notes/#{note.id}", params: { note: { title: "Hijack" } }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /notes/:id" do
    it "lets the author delete their note" do
      note = FactoryBot.create(:note, team: team, author: user)
      expect {
        delete "/notes/#{note.id}"
      }.to change(Note, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "404s when a teammate who is not the author tries to delete" do
      teammate = FactoryBot.create(:user)
      FactoryBot.create(:membership, user: teammate, team: team)
      note = FactoryBot.create(:note, team: team, author: teammate)

      delete "/notes/#{note.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
