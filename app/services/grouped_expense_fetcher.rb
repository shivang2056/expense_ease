class GroupedExpenseFetcher

  def initialize(user)
    @user = user
  end

  def involved_expenses_with_user
    expenses = Expense.includes(:user).related_to_user(@user)

    grouped_expenses(expenses)
  end

  def involved_expenses_with_user_and_friend(friend)
    expenses = fetch_involved_expenses_with_friend(friend)
    expenses.sort_by!{ |record| -record.created_at.to_i }

    grouped_expenses(expenses)
  end

  private

  def grouped_expenses(expenses)
    expenses.group_by { |record| record.created_at.strftime("%B %Y") }
  end

  def fetch_involved_expenses_with_friend(friend)
    Expense.includes(:user).between_users(@user, friend) +
    Expense.includes(:user).with_users_as_participants_only(@user, friend)
  end
end
