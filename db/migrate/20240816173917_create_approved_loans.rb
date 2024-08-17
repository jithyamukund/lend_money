class CreateApprovedLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :approved_loans do |t|
      t.references :loan_request, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.decimal :interest_rate, null: false
      t.integer :approved_by, null: false
      t.decimal :interest_amount, null: false, default: 0
      t.boolean :is_closed, default: false
      t.decimal :closed_amount
      t.datetime :closed_at

      t.timestamps
    end

    add_foreign_key :approved_loans, :users, column: :approved_by
    add_index :approved_loans, :approved_by
  end
end
