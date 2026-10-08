class Note < ApplicationRecord
  belongs_to :team
  belongs_to :author, class_name: "User"

  validates :title, presence: true
end
