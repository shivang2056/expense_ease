class DashboardDecorator
  def initialize(user)
    @user = user

    process_user_splits
  end

  def self.decorate(user)
    self.new(user)
  end

  def total_amount_owed_by
    @_amount_owed_by ||= users_i_owe.values.sum
  end

  def total_amount_owed_to
    @_amount_owed_to ||= users_who_owe_me.values.sum
  end

  def balance
    total_amount_owed_to - total_amount_owed_by
  end

  def users_i_owe(decorated: false)
    @_users_i_owe ||= calculate_net_owed(@amount_owed_to_users, @amount_owed_by_users)

    decorated ? decorated_list(@_users_i_owe) : @_users_i_owe
  end

  def users_who_owe_me(decorated: false)
    @_users_who_owe_me ||= calculate_net_owed(@amount_owed_by_users, @amount_owed_to_users)

    decorated ? decorated_list(@_users_who_owe_me) : @_users_who_owe_me
  end

  private

  def process_user_splits
    user_as_participant_splits = Split.joins(item: :expense)
                                       .where(user: @user)
                                       .where.not(items: { expenses: { user: @user } })

    @amount_owed_to_users = user_as_participant_splits.group('expenses.user_id').sum(:amount)

    user_as_paid_splits = Split.joins(item: :expense)
                                .where(items: { expenses: { user: @user } })
                                .where.not(user: @user)

    @amount_owed_by_users = user_as_paid_splits.group('splits.user_id').sum(:amount)
  end

  def calculate_net_owed(owed_by, owed_to)
    net_owed = {}

    owed_by.each do |user_id, amount|
      net_owed[user_id] = amount - (owed_to[user_id] || 0)
    end

    net_owed.select { |_, amount| amount > 0 }
  end

  def decorated_list(owed_amounts)
    User.where(id: owed_amounts.keys).map do |user|
      {
        amount_owed: owed_amounts[user.id],
        user_name: user.name
      }
    end
  end
end

