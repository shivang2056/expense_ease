class CreateSplits < ActiveRecord::Migration[7.1]
  def change
    create_table :splits do |t|
      t.decimal :amount
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
