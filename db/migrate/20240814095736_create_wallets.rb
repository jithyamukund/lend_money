class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.integer :user_id
      t.string :balance
      t.string :float

      t.timestamps
    end
  end
end
