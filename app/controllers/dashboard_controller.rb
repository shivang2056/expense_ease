class DashboardController < ApplicationController

  def index
    @decorator = DashboardDecorator.decorate(current_user)
  end
end
