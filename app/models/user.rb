class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expenses
  has_many :splits
  has_many :friendships
  has_many :friends, through: :friendships

  scope :by_name, -> (name) { where('name ILIKE ?', "%#{name}%") }

  def shortened_name
    parts = name.split(' ')

    if parts.length > 1
      "#{parts[0]} #{parts[1][0]}."
    else
      parts[0]
    end
  end
end
