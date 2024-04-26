require "test_helper"

class SplitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @split = splits(:one)
  end

  test "should get index" do
    get splits_url
    assert_response :success
  end

  test "should get new" do
    get new_split_url
    assert_response :success
  end

  test "should create split" do
    assert_difference("Split.count") do
      post splits_url, params: { split: { amount: @split.amount, item_id: @split.item_id, user_id: @split.user_id } }
    end

    assert_redirected_to split_url(Split.last)
  end

  test "should show split" do
    get split_url(@split)
    assert_response :success
  end

  test "should get edit" do
    get edit_split_url(@split)
    assert_response :success
  end

  test "should update split" do
    patch split_url(@split), params: { split: { amount: @split.amount, item_id: @split.item_id, user_id: @split.user_id } }
    assert_redirected_to split_url(@split)
  end

  test "should destroy split" do
    assert_difference("Split.count", -1) do
      delete split_url(@split)
    end

    assert_redirected_to splits_url
  end
end
