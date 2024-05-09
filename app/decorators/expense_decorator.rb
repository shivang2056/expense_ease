class ExpenseDecorator
  def initialize(user)
    @user = user
  end

  def self.decorate(user)
    self.new(user)
  end

  # Todo: Look for possible Refactor
  def involved_expenses
    expenses = Expense.where(user: @user)
                      .or(Expense.where(splits: { user: @user }))
                      .joins(:splits)
                      .distinct
                      .order(created_at: :desc)

    grouped_expenses = expenses.group_by { |record| record.created_at.strftime("%B %Y") }

    grouped_expenses.map do |month_year, expenses|
      [ month_year, expense_data(expenses) ]
    end
  end

  # Todo: Look for possible Refactor
  def involved_expenses_with(friend)
    expenses = Expense.where(user: [@user, friend])
                      .or(Expense.where(splits: { user: [@user, friend] }))
                      .joins(:splits)
                      .distinct
                      .order(created_at: :desc)

    expenses = expenses.select do |expense|
      paid_by_current_user?(expense) && expense.splits.where(user: friend).exists? ||
      expense.user_id == friend.id && expense.splits.where(user: @user).exists? ||
      expense.splits.where(user: friend).exists? && expense.splits.where(user: @user).exists?
    end

    grouped_expenses = expenses.group_by { |record| record.created_at.strftime("%B %Y") }

    grouped_expenses.map do |month_year, expenses|
      [ month_year, expense_data(expenses, friend: friend) ]
    end
  end

  private

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
    non_user_splits(expense).pluck(:user_id).uniq.count > 1
  end

  def non_user_splits(expense)
    @_splits ||= expense.splits.where.not(splits: {user: @user})
  end
end
