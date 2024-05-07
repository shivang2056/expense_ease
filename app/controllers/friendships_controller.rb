class FriendshipsController < ApplicationController

  def new

  end

  def new
    byebug
    # @user = User.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("selected_users", partial: "selected_user", locals: { user: @user }),
            turbo_stream.append("paid_by_dropdown", partial: "dropdown_user", locals: { user: @user })
          ]
      end
    end
  end

  def create

  end
end
