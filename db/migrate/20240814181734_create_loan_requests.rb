class CreateLoanRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :loan_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.decimal :interest_rate, null: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
