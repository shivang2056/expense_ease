require 'test_helper'

class ExpenseTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
    @user2 = users(:user2)
    @user3 = users(:user3)
    @user4 = users(:user4)
  end

  class RelatedToUserTest < ExpenseTest
    def setup
      super

      @expense1 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user2)
                                ])])
      @expense2 = Expense.create(user: @user3,
                                items: [Item.new(splits: [
                                  Split.new(amount: 20, user: @user2)
                                ])])
      @expense3 = Expense.create(user: @user2,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user1)
                                ])])
      @expense4 = Expense.create(user: @user3,
                                items: [Item.new(splits: [
                                  Split.new(amount: 20, user: @user1)
                                ])])
    end

    test 'should return expenses created by user' do
      assert_includes Expense.related_to_user(@user1), @expense1
      assert_not_includes Expense.related_to_user(@user1), @expense2
    end

    test 'should return empty when no expenses related to user' do
      assert_empty Expense.related_to_user(@user4)
    end

    test 'should return expenses where user is participant' do
      assert_includes Expense.related_to_user(@user1), @expense3
      assert_not_includes Expense.related_to_user(@user1), @expense2
    end

    test 'should return expenses where user is participant or user created the expense' do
      assert_includes Expense.related_to_user(@user1), @expense1
      assert_includes Expense.related_to_user(@user1), @expense3
      assert_includes Expense.related_to_user(@user1), @expense4
      assert_not_includes Expense.related_to_user(@user1), @expense2
    end
  end

  class BetweenUsersTest < ExpenseTest
    def setup
      super

      @expense1 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user2)
                                ])])
      @expense2 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 20, user: @user3)
                                ])])
      @expense3 = Expense.create(user: @user2,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user1)
                                ])])
      @expense4 = Expense.create(user: @user2,
                                items: [Item.new(splits: [
                                  Split.new(amount: 20, user: @user3)
                                ])])
      @expense5 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user2),
                                  Split.new(amount: 20, user: @user3)
                                ])])
      @expense6 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user3),
                                  Split.new(amount: 20, user: @user4)
                                ])])
    end

    test 'should return expenses when user1 created the expense and user2 is participant' do
      assert_includes Expense.between_users(@user1, @user2), @expense1
      assert_not_includes Expense.between_users(@user1, @user2), @expense2
    end

    test 'should return expenses when user2 created the expense and user1 is participant' do
      assert_includes Expense.between_users(@user1, @user2), @expense3
      assert_not_includes Expense.between_users(@user1, @user2), @expense4
    end

    test 'should return expenses when user1 created the expense and user2 is participant along with others' do
      assert_includes Expense.between_users(@user1, @user2), @expense5
      assert_not_includes Expense.between_users(@user1, @user2), @expense6
    end

    test 'should return empty when no expenses exist involving both users' do
      assert_empty Expense.between_users(@user3, @user4)
    end
  end

  class WithUsersAsParticipantsOnlyTest < ExpenseTest
    def setup
      super

      @expense1 = Expense.create(user: @user1,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user3),
                                  Split.new(amount: 20, user: @user4)
                                ])])
      @expense2 = Expense.create(user: @user3,
                                items: [Item.new(splits: [
                                  Split.new(amount: 10, user: @user3),
                                  Split.new(amount: 20, user: @user4)
                                ])])
    end

    test 'should return expenses when both users are participant but none of the user created the expense' do
      assert_includes Expense.with_users_as_participants_only(@user3, @user4), @expense1
      assert_not_includes Expense.with_users_as_participants_only(@user3, @user4), @expense2
    end

    test 'should return empty if no expense exist with both users as participant only' do
      assert_empty Expense.with_users_as_participants_only(@user1, @user4)
      assert_empty Expense.with_users_as_participants_only(@user2, @user4)
      assert_empty Expense.with_users_as_participants_only(@user2, @user3)
    end
  end
end