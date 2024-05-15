class SettlementDecorator

  attr_accessor :total_owed_amount
  def initialize(user, friend_id)
    @user = user
    @user.current_user = true
    @friend = User.find(friend_id) if friend_id

    compute_settlement_details
  end

  def self.decorate(user, friend_id: nil)
    self.new(user, friend_id)
  end

  def paid_by_dropdown
    {
      input_field_name: :user_id,
      default: @paid_by.as_dropdown_option,
      options: @user_dropdown_options.map(&:as_dropdown_option)
    }
  end

  def paid_to_dropdown
    {
      input_field_name: :user_id,
      default: @paid_to.as_dropdown_option,
      options: @user_dropdown_options.map(&:as_dropdown_option)
    }
  end

  private

  def compute_settlement_details
    if @friend
      @total_owed_amount = (amount_owed_to_friend - amount_owed_to_user).abs
      @user_dropdown_options = user_with_friend

      if amount_owed_to_user > amount_owed_to_friend
        @paid_by = @friend
        @paid_to = @user
      else
        @paid_by = @user
        @paid_to = @friend
      end
    else
      @total_owed_amount = 0
      @user_dropdown_options = user_with_friends
      @paid_by = @user
      @paid_to = @user.friends.first
    end
  end

  def amount_owed_to_friend
    @_amount_owed_to_friend ||= owed_amount(@friend, @user)
  end

  def amount_owed_to_user
    @_amount_owed_to_user ||= owed_amount(@user, @friend)
  end

  def owed_amount(paid_by, paid_to)
    Split.joins(item: :expense).where(user: paid_to).where(items: {expenses: {user: paid_by}}).sum(:amount)
  end

  def user_with_friend
    [@user, @friend]
  end

  def user_with_friends
    @user.friends.to_a.prepend(@user)
  end
end
