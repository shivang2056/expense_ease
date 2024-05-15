require 'test_helper'

class DashboardDecoratorTest < ActiveSupport::TestCase
  def setup
    @user = users(:user1)
    @friend1 = users(:user2)
    @friend2 = users(:user3)
    @friend3 = users(:user4)
    @user.friends << [@friend1, @friend2]
  end

  def decorator(friend_id: nil)
    SettlementDecorator.decorate(@user, friend_id: friend_id)
  end

  class PaidByDropDownTest < DashboardDecoratorTest
    test '#paid_by_dropdown returns the dropdown config details for paid_by dropdown' do
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

      result = decorator.paid_by_dropdown
      expected_default_hash = { name: 'you', value: @user.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
      assert_equal ["you", @friend1.shortened_name, @friend2.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id, @friend2.id].sort, result[:options].pluck(:value).sort
    end

    test '#paid_by_dropdown returns the dropdown config details for paid_by dropdown with given friend_id' do
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

      result = decorator(friend_id: @friend1.id).paid_by_dropdown
      expected_default_hash = { name: 'you', value: @user.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
      assert_equal ["you", @friend1.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id].sort, result[:options].pluck(:value).sort
    end

    test '#paid_by_dropdown returns user details in default if user owes the given friend' do
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

      result = decorator(friend_id: @friend1.id).paid_by_dropdown
      expected_default_hash = { name: 'you', value: @user.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
    end

    test '#paid_by_dropdown returns friend details in default if friend owes the user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 30, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      result = decorator(friend_id: @friend1.id).paid_by_dropdown
      expected_default_hash = { name: @friend1.shortened_name, value: @friend1.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
    end

    test '#paid_by_dropdown returns only the user and friend details in the options' do
      result = decorator(friend_id: @friend1.id).paid_by_dropdown

      assert_kind_of Hash, result

      assert_equal ["you", @friend1.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id].sort, result[:options].pluck(:value).sort
    end
  end

  class PaidToDropdownTest < DashboardDecoratorTest
    test '#paid_to_dropdown returns the dropdown config details for paid_to dropdown' do
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

      result = decorator.paid_to_dropdown

      expected_default_hash = { name: @user.friends.first.shortened_name, value: @user.friends.first.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
      assert_equal ["you", @friend1.shortened_name, @friend2.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id, @friend2.id].sort, result[:options].pluck(:value).sort
    end

    test '#paid_to_dropdown returns the dropdown config details for paid_to dropdown with given friend_id' do
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

      result = decorator(friend_id: @friend1.id).paid_to_dropdown
      expected_default_hash = { name: @friend1.shortened_name, value: @friend1.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
      assert_equal ["you", @friend1.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id].sort, result[:options].pluck(:value).sort
    end

    test '#paid_to_dropdown returns user details in default if friend owes the user' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 30, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      result = decorator(friend_id: @friend1.id).paid_to_dropdown
      expected_default_hash = { name: 'you', value: @user.id }


      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
    end

    test '#paid_to_dropdown returns friend details in default if user owes the given friend' do
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

      result = decorator(friend_id: @friend1.id).paid_to_dropdown
      expected_default_hash = { name: @friend1.shortened_name, value: @friend1.id }

      assert_kind_of Hash, result
      assert_equal :user_id, result[:input_field_name]
      assert_equal expected_default_hash, result[:default]
    end

    test '#paid_to_dropdown returns only the user and friend details in the options' do
      result = decorator(friend_id: @friend1.id).paid_to_dropdown

      assert_kind_of Hash, result

      assert_equal ["you", @friend1.shortened_name].sort, result[:options].pluck(:name).sort
      assert_equal [@user.id, @friend1.id].sort, result[:options].pluck(:value).sort
    end
  end

  class TotalOwedAmount < DashboardDecoratorTest
    test '#total_owed_amount returns 0 if no friend_id is given' do
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

      assert_equal 0, decorator.total_owed_amount
    end

    test '#total_owed_amount returns correct amount if friend owes the user' do
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

      assert_equal 5, decorator(friend_id: @friend1.id).total_owed_amount
    end

    test '#total_owed_amount returns correct amount if user owes the friend' do
      Expense.create(user: @user,
                    items: [Item.new(splits: [
                      Split.new(amount: 30, user: @friend1),
                      Split.new(amount: 5, user: @user)
                    ])])

      Expense.create(user: @friend1,
                    items: [Item.new(splits: [
                      Split.new(amount: 20, user: @friend2),
                      Split.new(amount: 15, user: @user)
                    ])])

      assert_equal 15, decorator(friend_id: @friend1.id).total_owed_amount
    end
  end

end
