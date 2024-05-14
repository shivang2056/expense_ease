require 'test_helper'

class DashboardDecoratorTest < ActiveSupport::TestCase
  def setup
    @user = users(:user1)
    @friend1 = users(:user2)
    @friend2 = users(:user3)
  end

  def decorator
    DashboardDecorator.decorate(@user)
  end

  class BalanceTest < DashboardDecoratorTest
    test '#balance returns the net balance of the user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      assert_equal -5, decorator.balance
    end

    test '#balance changes when a new expense is added' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1)
                    ])])

      initial_balance = decorator.balance

      Expense.create(user: @user,
                     items: [Item.new(splits: [
                       Split.new(amount: 20, user: @friend1)
                    ])])

      assert_not_equal initial_balance, decorator.balance
    end

    test '#balance is negative when the user owes more than is owed to them' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      assert decorator.balance < 0
    end

    test '#balance is positive when the user is owed more than they owe' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      assert decorator.balance > 0
    end

    test '#balance is zero when there are no expenses' do
      assert_equal 0, decorator.balance
    end

    test '#balance is zero when the user owes and is owed the same amount' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 15, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      assert_equal 0, decorator.balance
    end
  end

  class UsersIOweTest < DashboardDecoratorTest
    test '#users_i_owe returns a hash of users and the amount owed to them' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @friend2,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @user)
                    ])])

      result = decorator.users_i_owe

      assert_kind_of Hash, result
      assert_equal 10, result[@friend1.id]
      assert_equal 20, result[@friend2.id]
    end

    test '#users_i_owe(decorated: true) returns an array of hash of user names and the amount owed to them' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @friend2,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @user)
                    ])])

      result = decorator.users_i_owe(decorated: true)

      assert_kind_of Array, result
      assert_equal 10, result.find{|hash| hash[:user_name] == @friend1.name}[:amount_owed]
      assert_equal 20, result.find{|hash| hash[:user_name] == @friend2.name}[:amount_owed]
    end

    test '#users_i_owe returns empty hash when no users are owed' do
      result = decorator.users_i_owe
      assert_empty result
    end

    test '#users_i_owe does not include users who owe the current user' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2)
                    ])])

      result = decorator.users_i_owe

      refute_includes result.keys, @friend2.id
    end

    test '#users_i_owe returns correct amounts when multiple expenses are with the same user' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 45, user: @user)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend1)
                    ])])

      result = decorator.users_i_owe

      assert_equal 25, result[@friend1.id]
    end
  end

  class UserWhoOweMeTest < DashboardDecoratorTest
    test '#users_who_owe_me returns a hash of users and the amount they owe to the current user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2)
                    ])])

      result = decorator.users_who_owe_me

      assert_kind_of Hash, result
      assert_equal 10, result[@friend1.id]
      assert_equal 20, result[@friend2.id]
    end

    test '#users_who_owe_me(decorated: true) returns an array of hash of user names and the amount they owe to the current user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2)
                    ])])

      result = decorator.users_who_owe_me(decorated: true)

      assert_kind_of Array, result
      assert_equal 10, result.find{|hash| hash[:user_name] == @friend1.name}[:amount_owed]
      assert_equal 20, result.find{|hash| hash[:user_name] == @friend2.name}[:amount_owed]
    end

    test '#users_who_owe_me returns empty hash when no users owe the current user' do
      result = decorator.users_who_owe_me
      assert_empty result
    end

    test '#users_who_owe_me does not include users who the current user owes' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2)
                    ])])

      result = decorator.users_who_owe_me

      refute_includes result.keys, @friend1.id
    end

    test '#users_who_owe_me returns correct amounts when multiple expenses are with the same user' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @user)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 45, user: @friend1)
                    ])])

      result = decorator.users_who_owe_me

      assert_equal 25, result[@friend1.id]
    end
  end

  class TotalAmountOwedByTest < DashboardDecoratorTest
    test '#total_amount_owed_by returns total amount owed by the user' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @friend2,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @user)
                    ])])

      assert_equal 30, decorator.total_amount_owed_by
    end

    test '#total_amount_owed_by returns zero when no amounts are owed by the user' do
      assert_equal 0, decorator.total_amount_owed_by
    end

    test '#total_amount_owed_by returns correct total when multiple expenses are owed to the same user' do
      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @user)
                    ])])

      expected_amount = 30
      assert_equal expected_amount, decorator.total_amount_owed_by
    end
  end

  class TotalAmountOwedToTest < DashboardDecoratorTest
    test '#total_amount_owed_to returns total amount other users owe to the user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2)
                    ])])

      assert_equal 30, decorator.total_amount_owed_to
    end

    test '#total_amount_owed_to returns zero when no amounts are owed to the user' do
      assert_equal 0, decorator.total_amount_owed_to
    end

    test '#total_amount_owed_to returns correct total when multiple expenses are created which are owed by the same user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 10, user: @friend1)
                    ])])

      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend1)
                    ])])

      expected_amount = 30
      assert_equal expected_amount, decorator.total_amount_owed_to
    end
  end
end