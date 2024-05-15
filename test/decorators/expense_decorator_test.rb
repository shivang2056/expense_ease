require "test_helper"

class ExpenseDecoratorTest < ActiveSupport::TestCase
  def setup
    @user = users(:user1)
    @friend1 = users(:user2)
    @friend2 = users(:user3)
  end

  def decorator
    ExpenseDecorator.decorate(@user)
  end

  def created_month(expense)
    expense.created_at.strftime("%^b")
  end

  def created_date(expense)
    expense.created_at.strftime("%d")
  end

  class InvolvedExpensesTest < ExpenseDecoratorTest
    test "#involved_expenses returns decorated expenses for the user" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses
      expected = { created_month: created_month(expense1), created_date: created_date(expense1),
                description: "expense_1", paid_label: "you paid", paid_amount: 15,
                lent_label: "you lent #{@friend1.shortened_name}", lent_amount: 10 }

      assert_kind_of Array, result
      assert_kind_of Array, result[0]
      assert_equal expense1.created_at.strftime("%B %Y"), result[0][0]
      assert_kind_of Array, result[0][1]
      assert_equal expected, result[0][1][0]
    end

    test "#involved_expenses paid_label -> returns 'you paid' when current user created the expense" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses

      assert_equal 'you paid', result[0][1][0][:paid_label]
    end

    test "#involved_expenses paid_label -> returns 'user_name paid' when someone else created the expense" do
      expense1 = Expense.create(user: @friend2,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses

      assert_equal "#{@friend2.shortened_name} paid", result[0][1][0][:paid_label]
    end

    test "#involved_expenses lent_label -> returns 'you lent' when current user created the expense and more than 1 participants in the expense" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @friend2)
                    ])])

      result = decorator.involved_expenses

      assert_equal 'you lent', result[0][1][0][:lent_label]
    end

    test "#involved_expenses lent_label -> returns 'you lent user_name' when current user created the expense and only 1 person participated in the expense." do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses

      assert_equal "you lent #{@friend1.shortened_name}", result[0][1][0][:lent_label]
    end

    test "#involved_expenses lent_label -> returns 'user_name lent you' when someone else created the expense." do
      expense1 = Expense.create(user: @friend2,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses

      assert_equal "#{@friend2.shortened_name} lent you", result[0][1][0][:lent_label]
    end

    test "#involved_expenses lent_amount -> returns total amount lent as part of the expense when current user created the expense" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses

      assert_equal 10, result[0][1][0][:lent_amount]
    end

    test "#involved_expenses lent_amount -> returns current user's total splits of the expense when someone else created the expense" do
      expense1 = Expense.create(user: @friend1,
                    description: "expense_1",
                    amount: 25,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 10, user: @friend2),
                      Split.new(amount: 5, user: @user),
                    ])])

      result = decorator.involved_expenses

      assert_equal 5, result[0][1][0][:lent_amount]
    end
  end

  class InvolvedExpensesWith < ExpenseDecoratorTest
    test "#involved_expenses_with returns decorated expenses for the user considering the given friend" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)
      expected = { created_month: created_month(expense1), created_date: created_date(expense1),
                description: "expense_1", paid_label: "you paid", paid_amount: 15,
                lent_label: "you lent #{@friend1.shortened_name}", lent_amount: 10 }

      assert_kind_of Array, result
      assert_kind_of Array, result[0]
      assert_equal expense1.created_at.strftime("%B %Y"), result[0][0]
      assert_kind_of Array, result[0][1]
      assert_equal expected, result[0][1][0]
    end

    test "#involved_expenses_with paid_label -> returns 'you paid' when current user created the expense" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal 'you paid', result[0][1][0][:paid_label]
    end

    test "#involved_expenses_with paid_label -> returns 'friend_name paid' when friend created the expense" do
      expense1 = Expense.create(user: @friend1,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal "#{@friend1.shortened_name} paid", result[0][1][0][:paid_label]
    end

    test "#involved_expenses_with lent_label -> returns 'you lent friend_name' when current user created the expense and more than 1 participants in the expense along with friend" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @friend2)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal "you lent #{@friend1.shortened_name}", result[0][1][0][:lent_label]
    end

    test "#involved_expenses_with lent_label -> returns 'you lent friend_name' when current user created the expense and only friend participated in the expense." do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal "you lent #{@friend1.shortened_name}", result[0][1][0][:lent_label]
    end

    test "#involved_expenses_with lent_label -> returns 'you borrowed nothing' when neither current user nor friend created the expense" do
      expense1 = Expense.create(user: @friend2,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal "you borrowed nothing", result[0][1][0][:lent_label]
    end

    test "#involved_expenses_with lent_label -> returns 'friend_name lent you' when friend created the expense." do
      expense1 = Expense.create(user: @friend1,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend2),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal "#{@friend1.shortened_name} lent you", result[0][1][0][:lent_label]
    end

    test "#involved_expenses_with lent_amount -> returns amount lent to friend when current user created the expense" do
      expense1 = Expense.create(user: @user,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal 10, result[0][1][0][:lent_amount]
    end

    test "#involved_expenses_with lent_amount -> returns nil as amount when neither current user nor friend created the expense" do
      expense1 = Expense.create(user: @friend2,
                    description: "expense_1",
                    amount: 15,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal nil, result[0][1][0][:lent_amount]
    end

    test "#involved_expenses_with lent_amount -> returns current user's total splits of the expense when friend created the expense" do
      expense1 = Expense.create(user: @friend1,
                    description: "expense_1",
                    amount: 25,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 10, user: @friend2),
                      Split.new(amount: 5, user: @user)
                    ])])

      result = decorator.involved_expenses_with(@friend1)

      assert_equal 5, result[0][1][0][:lent_amount]
    end
  end
end
