class SettlementsController < ApplicationController

  def new
    @decorator = SettlementDecorator.decorate(current_user, friend_id: params[:friend_id])
    @expense = Expense.new

    item = @expense.items.build
    item.splits.build
  end

  def create
    settlement_params = permitted_params.dup
    settlement_params[:description] = 'Settlement'
    settlement_params[:items_attributes]['0'][:splits_attributes]['0'][:amount] = settlement_params[:amount]
    Expense.create!(settlement_params)

    redirect_to root_path
  end

  private

  def permitted_params
    params.require(:expense).permit(:user_id, :amount,
        items_attributes: [ :name, :cost, splits_attributes: [:user_id, :amount] ])
  end
end
