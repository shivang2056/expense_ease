class ExpenseDecorator
  def initialize(user)
    @user = user
    @expense_fetcher = GroupedExpenseFetcher.new(@user)
  end

  def self.decorate(user)
    self.new(user)
  end

  def involved_expenses
    grouped_expenses = @expense_fetcher.involved_expenses_with_user

    decorated_expenses(grouped_expenses)
  end

  def involved_expenses_with(friend)
    grouped_expenses = @expense_fetcher.involved_expenses_with_user_and_friend(friend)

    decorated_expenses(grouped_expenses, friend: friend)
  end

  private

  def decorated_expenses(expenses, friend: nil)
    expenses.map do |month_year, expenses|
      [ month_year, expense_data(expenses, friend: friend) ]
    end
  end

  def expense_data(expenses, friend: nil)
    expenses.map do |expense|
      {
        created_month: expense.created_at.strftime('%^b'),
        created_date: expense.created_at.strftime('%d'),
        description: expense.description,
        paid_label: paid_label(expense),
        paid_amount: expense.amount,
        lent_label: lent_label(expense, friend),
        lent_amount: lent_amount(expense, friend)
      }
    end
  end

  def paid_label(expense)
    paid_by_current_user?(expense) ? "you paid" : "#{expense.user.shortened_name} paid"
  end

  def lent_label(expense, friend)
    if paid_by_current_user?(expense)
      if more_than_1_participants?(expense)
        friend.present? ? "you lent #{friend.shortened_name}" : "you lent"
      else
        name = non_user_splits(expense).first.user.shortened_name

        "you lent #{name}"
      end
    elsif friend.present? && expense.user_id != friend.id
      "you borrowed nothing"
    else
      "#{expense.user.shortened_name} lent you"
    end
  end

  def lent_amount(expense, friend)
    if paid_by_current_user?(expense)
      friend.present? ? expense.splits.where(splits: {user: friend}).sum(:amount) : non_user_splits(expense).sum(:amount)
    elsif friend.present? && expense.user_id != friend.id
      nil
    else
      expense.splits.where(splits: {user: @user}).sum(:amount)
    end
  end

  def paid_by_current_user?(expense)
    expense.user_id == @user.id
  end

  def more_than_1_participants?(expense)
    non_user_splits(expense).distinct.count(:user_id) > 1
  end

  def non_user_splits(expense)
    @_splits ||= {}
    @_splits[expense.id] ||= expense.splits.where.not(splits: {user: @user})
  end
end
