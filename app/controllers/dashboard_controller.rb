class DashboardController < ApplicationController
  # before_action :authenticate_user!

  def index
  end

  def all_expenses
  end

  def test
  end

  def search_user
    if params.dig(:search).present?
      @users = User.by_name(params[:search]).order(created_at: :desc)
    else
      @users = []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("search_results",
          partial: "dashboard/search_results",
          locals: { users: @users })
        ]
      end
    end
  end
end
