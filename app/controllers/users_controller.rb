class UsersController < ApplicationController

  def search
    if params.dig(:search).present?
      @users = User.non_friends_for(current_user)
                   .by_name(params[:search])
                   .order(created_at: :desc)
    else
      @users = []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("user_search_results",
          partial: "users/search_results",
          locals: { users: @users })
        ]
      end
    end
  end
end
