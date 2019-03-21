require 'terminal-table'

namespace :casino do
  namespace :logout_rule do
    desc 'Add a logout regular expression'
    task :add, [:name, :regex, :url, :order] => :environment do |task, args|
      logout_rule = CASino::LogoutRule.new name: args[:name]
      logout_rule.regex = args[:regex]
      logout_rule.url = args[:url]
      logout_rule.order = Integer(args[:order]) rescue 10
      if !logout_rule.save
        fail logout_rule.errors.full_messages.join("\n")
      elsif logout_rule.regex[0] != '^'
        puts 'Warning: Potentially unsafe regex! Use ^ to match the beginning of the URL. Example: ^https://'
      end
    end

    desc 'Remove a logout rule.'
    task :delete, [:id] => :environment do |task, args|
      CASino::LogoutRule.find(args[:id]).delete
      puts "Successfully deleted logout rule ##{args[:id]}."
    end

    desc 'Delete all logout rules.'
    task :flush => :environment do |task, args|
      CASino::LogoutRule.delete_all
      puts 'Successfully deleted all logout rules.'
    end

    desc 'List all logout rules.'
    task list: :environment do
      table = Terminal::Table.new :headings => ['Enabled', 'ID', 'Name', 'Regex', 'URL'] do |t|
        CASino::LogoutRule.all.each do |logout_rule|
          t.add_row [logout_rule.enabled, logout_rule.id, logout_rule.name, logout_rule.regex, logout_rule.url]
        end
      end
      puts table
    end
  end
end
