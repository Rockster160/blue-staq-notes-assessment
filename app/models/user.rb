class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :owned_teams, class_name: "Team", dependent: :destroy, foreign_key: :owner_id
  has_many :authored_notes, class_name: "Note", dependent: :destroy, foreign_key: :author_id

  has_many :viewable_notes, class_name: "Note", through: :teams, source: :notes
  has_many :viewable_memberships, class_name: "Membership", through: :teams, source: :memberships

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }
end
