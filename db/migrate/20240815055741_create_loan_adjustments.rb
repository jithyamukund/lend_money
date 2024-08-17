class CreateLoanAdjustments < ActiveRecord::Migration[7.1]
  def change
    create_table :loan_adjustments do |t|
      t.references :loan_request, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.decimal :interest_rate, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false
      t.string :note

      t.timestamps
    end
  end
end
