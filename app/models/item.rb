class Item < ApplicationRecord
  belongs_to :expense

  has_many :splits
end
