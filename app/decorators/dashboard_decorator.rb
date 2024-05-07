class DashboardDecorator
  def initialize(user)
    @user = user

    process_user_splits
  end

  def self.decorate(user)
    self.new(user)
  end

  def amount_owed_by
    @_amount_owed_by ||= @splits_for_owed_by.sum(:amount)
  end

  def amount_owed_to
    @_amount_owed_to ||= @splits_for_owed_to.sum(:amount)
  end

  def balance
    amount_owed_to - amount_owed_by
  end

  def users_owed_by
    owed_amounts = @splits_for_owed_by.group('expenses.user_id').sum(:amount)

    decorated_list(owed_amounts)
  end

  def users_owed_to
    owed_amounts = @splits_for_owed_to.group('splits.user_id').sum(:amount)

    decorated_list(owed_amounts)
  end

  private

  def process_user_splits
    user_expenses = Expense.where(user: @user)

    @splits_for_owed_to = Split.joins(:item)
                               .where(items: { expense: user_expenses })
                               .where.not(user: @user)

    @splits_for_owed_by = Split.joins(item: :expense)
                               .where(user: @user)
                               .where.not(items: { expenses: { user: @user } })
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

