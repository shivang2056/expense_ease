class SplitsController < ApplicationController
  before_action :set_split, only: %i[ show edit update destroy ]

  # GET /splits or /splits.json
  def index
    @splits = Split.all
  end

  # GET /splits/1 or /splits/1.json
  def show
  end

  # GET /splits/new
  def new
    @split = Split.new
  end

  # GET /splits/1/edit
  def edit
  end

  # POST /splits or /splits.json
  def create
    @split = Split.new(split_params)

    respond_to do |format|
      if @split.save
        format.html { redirect_to split_url(@split), notice: "Split was successfully created." }
        format.json { render :show, status: :created, location: @split }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @split.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /splits/1 or /splits/1.json
  def update
    respond_to do |format|
      if @split.update(split_params)
        format.html { redirect_to split_url(@split), notice: "Split was successfully updated." }
        format.json { render :show, status: :ok, location: @split }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @split.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /splits/1 or /splits/1.json
  def destroy
    @split.destroy!

    respond_to do |format|
      format.html { redirect_to splits_url, notice: "Split was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_split
      @split = Split.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def split_params
      params.require(:split).permit(:amount, :item_id, :user_id)
    end
end
