class ExpenseDecorator
  def initialize(user)
    @user = user
  end

  def self.decorate(user)
    self.new(user)
  end

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

  private

  def expense_data(expenses)
    expenses.map do |expense|
      {
        created_month: expense.created_at.strftime('%^b'),
        created_date: expense.created_at.strftime('%d'),
        description: expense.description,
        paid_label: paid_label(expense),
        paid_amount: expense.amount,
        lent_label: lent_label(expense),
        lent_amount: lent_amount(expense)
      }
    end
  end

  def paid_label(expense)
    expense.user_id == @user.id ? "you paid" : "#{expense.user.shortened_name} paid"
  end

  def lent_label(expense)
    if expense.user_id == @user.id
      if non_user_splits(expense).pluck(:user_id).uniq.count > 1
        "you lent"
      else
        name = non_user_splits(expense).first.user.shortened_name

        "you lent #{name}"
      end
    else
      "#{expense.user.shortened_name} lent you"
    end
  end

  def lent_amount(expense)
    if expense.user_id == @user.id
      non_user_splits(expense).sum(:amount)
    else
      expense.splits.where(splits: {user: @user}).sum(:amount)
    end
  end

  def non_user_splits(expense)
    @_splits ||= expense.splits.where.not(splits: {user: @user})
  end
end
