class CreatePasswordResetTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :casino_password_reset_tokens do |t|
      t.string :authenticator, null: false
      t.string :username, null: false
      t.string :token, null: false

      t.timestamps
    end

    add_index :casino_password_reset_tokens, %w[authenticator username], unique: true
  end
end
