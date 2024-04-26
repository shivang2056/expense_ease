class Expense < ApplicationRecord
  belongs_to :user

  has_many :items
  # has_many :splits
end
