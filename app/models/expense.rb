class Expense < ApplicationRecord
  belongs_to :user

  has_many :items
  has_many :splits, through: :items

  accepts_nested_attributes_for :items

  scope :related_to_user, -> (user) {
    where(user: user)
      .or(
          where(splits: {
            user: user
          })
      )
      .joins(:splits)
      .distinct
      .order(created_at: :desc)
  }

  scope :between_users, -> (user1, user2) {
    joins(:splits)
      .where(expenses: {
        user_id: user1.id
      }, splits: {
        user_id: user2.id
      })
      .or(
        joins(:splits)
        .where(expenses: {
          user_id: user2.id
        }, splits: {
          user_id: user1.id
        })
      )
  }

  scope :with_users_as_participants_only, -> (user1, user2) {
    joins(:splits)
      .where(splits: {
        user_id: [user1.id, user2.id]
      })
      .where.not(expenses: {
        user_id: [user1.id, user2.id]
      })
      .group('expenses.id')
      .having('COUNT(DISTINCT splits.user_id) >= 2')
  }

end
