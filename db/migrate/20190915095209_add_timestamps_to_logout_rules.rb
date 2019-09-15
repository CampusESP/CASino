class AddTimestampsToLogoutRules < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :casino_logout_rules
  end
end
