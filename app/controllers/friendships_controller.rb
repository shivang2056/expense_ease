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
    current_user.friendships.create!(friend: friend)

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("friends_list",
            partial: "friend",
            locals: { name: friend.name }),

            turbo_stream.remove("user_search_results"),

            turbo_stream.remove("new_friend")
          ]
      end
    end
  end

  private

  def friend_create_params
    params.permit(:friend_id)
  end
end
