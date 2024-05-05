class Item < ApplicationRecord
  belongs_to :expense

  has_many :splits

  accepts_nested_attributes_for :splits
end
