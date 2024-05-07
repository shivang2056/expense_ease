class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validate :not_self
  validates :friend_id, uniqueness: { scope: :user_id }

  after_create :create_inverse_relationship
  after_destroy :destroy_inverse_relationship

  private

  def create_inverse_relationship
    friend.friendships.create(friend: user) unless friendship_exists?
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.find_by(friend: user)
    friendship.destroy if friendship
  end

  def friendship_exists?
    Friendship.where(user: self.friend, friend: self.user).any?
  end

  def not_self
    errors.add(:friend, "can't be the same as the user") if user.id == friend.id
  end
end
