class CreateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refresh_tokens, primary_key: :crypted_token, id: :string, force: :cascade do |t|
      t.bigint :user_id, null: false 
      t.timestamps

      t.index :crypted_token, unique: true
      t.index :user_id
    end
    add_foreign_key :refresh_tokens, :users, column: :user_id
  end
end
