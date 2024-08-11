class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.bigint :wallet_id, null: false  
      t.string :transaction_type, limit: 10
      t.integer :amount
      t.jsonb :details

      t.timestamps
      t.index :wallet_id
    end
    add_foreign_key :transactions, :wallets, column: :wallet_id
  end
end
