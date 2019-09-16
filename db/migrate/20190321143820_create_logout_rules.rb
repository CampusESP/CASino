class CreateLogoutRules < ActiveRecord::Migration[5.2]
  def change
    create_table :casino_logout_rules do |t|
      t.boolean :enabled, default: true, null: false
      t.integer :order,   default: 10,   null: false
      t.string  :name,                   null: false
      t.string  :regex,                  null: false
      t.string  :url,                    null: false
    end

    add_index :casino_logout_rules, :regex, unique: true
  end
end
