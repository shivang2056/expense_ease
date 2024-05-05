class AddDescriptionToExpenses < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :description, :string
  end
end
