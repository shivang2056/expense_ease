class Expense < ApplicationRecord
  belongs_to :user

  has_many :items
  has_many :splits, through: :items

  accepts_nested_attributes_for :items
end
