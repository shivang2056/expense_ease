class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index
    decorator = ExpenseDecorator.decorate(current_user)
    @grouped_expenses = decorator.involved_expenses
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new

    if params[:participant_ids]
      @users = User.find(params[:participant_ids].split(","))
      @cost = params[:cost].to_f
      @per_head_cost = @cost / @users.size
      @split_by = params[:split_by]

      item = @expense.items.build

      item.splits.build
    end
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to expense_url(@expense), notice: "Expense was successfully created." }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to expense_url(@expense), notice: "Expense was successfully updated." }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy!

    respond_to do |format|
      format.html { redirect_to expenses_url, notice: "Expense was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_participant
    participant = User.find(params[:friend_id])

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("participants",
                                partial: "participant",
                                locals: { user: participant }),
            turbo_stream.append("paid_by_dropdown",
                                partial: "dropdown_user",
                                locals: { user: participant })
          ]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.require(:expense).permit(:user_id, :amount, :description,
        items_attributes: [ splits_attributes: [:user_id, :amount] ])
    end
end
