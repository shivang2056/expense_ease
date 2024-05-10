class FriendshipsController < ApplicationController

  def new
    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new_friend",
            partial: "new_friend")
          ]
      end
    end
  end

  def create
    friend = User.find(friend_create_params[:friend_id])
    friendship = current_user.friendships.create!(friend: friend)

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("friends_list",
                                  partial: "friend",
                                  locals: { friendship: friendship }),
            turbo_stream.remove("user_search_results"),
            turbo_stream.remove("new_friend")
          ]
      end
    end
  end

  def expenses
    @friend = Friendship.find(params[:id]).friend

    decorator = ExpenseDecorator.decorate(current_user)
    @grouped_expenses = decorator.involved_expenses_with(@friend)
  end

  def search
    if params.dig(:search).present?
      friends = current_user
                  .friends
                  .by_name(params[:search])
                  .order(created_at: :desc)
    else
      friends = []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("friend_search_results",
          partial: "friendships/search_results",
          locals: { friends: friends })
        ]
      end
    end
  end

  private

  def friend_create_params
    params.permit(:friend_id)
  end
end
