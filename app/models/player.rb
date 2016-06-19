class Player < ApplicationRecord
  has_many :moves
  has_many :games, through: :moves
  validates :name, presence: true, uniqueness: true
end
