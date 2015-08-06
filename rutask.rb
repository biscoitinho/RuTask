require 'rubygems'
require "bundler/setup"
require 'commander/import'
require 'sequel'

program :name, "RuTask"
program :version, '1.0.0'
program :description, 'Command line task manager written in Ruby'

DB = Sequel.sqlite('tasks_db.db')

unless DB.table_exists? :tasks
  DB.create_table(:tasks) do
      primary_key :id
  String :title
  String :description
  Boolean :completed
  end
end

ds = DB[:tasks]

command :new do |c|
  c.syntax = 'RuTask new'
  c.description = 'Creates a new task'
  c.option '--title STRING', String, 'Title of the task'
  c.option '--description STRING', String, 'Task Description'
  c.action do |args, options|
    if options.title.nil?
      options.title = ask('Provide a title for the task :')
    end
    if options.description.nil?
      options.description = ask('Provide a description for the task :')
    end
    ds.insert(:title => options.title, :description => options.description, :completed => false)
    say 'Task added'
  end
end

command :list do |c|
  c.syntax = 'RuTask list'
  c.description = 'Lists the tasks.'
  c.action do |args, options|
    ds.each do |task|
      status = if task[:completed] then "completed" else "pending" end
      puts "Task id [#{task[:id]}] - <#{status}> : #{task[:title]}"
    end
    pending_count = ds.where(:completed => false).count
    count = ds.count
    completed_count = count - pending_count
    puts "\n"
    puts "Out of #{count} Total Tasks : #{pending_count} pending, #{completed_count} completed."
  end
end

command :done do |c|
  c.syntax = 'RuTask done <id>'
  c.description = 'Mark a task as done'
  c.action do |args, options|
    if args.first.nil?
      puts 'Please specify task id to be marked as complete'
    else
      items = ds.where(:id => args.first)
      if items.count > 0
        items.update(:completed => true)
        puts "Updated"
      else
        puts 'No item found'
      end
    end
  end
end

command :show do |c|
  c.syntax = 'RuTask show <id>'
  c.description = 'Shows the description of a task'
  c.action do |args, options|
    if args.first.nil?
      puts "Please specify task id to be shown."
    else
      ds.where(:id => args.first).each do |task|
        puts "| Id:          | #{task[:id]}"
        puts "| Title:       | #{task[:title]}"
        puts "| Description: | #{task[:description]}"
        puts "| Completed:   | #{task[:completed]}"
      end
    end
  end
end

command :delete do |c|
  c.syntax = 'RuTask delete <id>'
  c.description = 'Delete a task'
  c.action do |args, options|
    if args.first.nil?
      puts "Please specify task id to be deleted"
    else
      items = ds.where(:id => args.first)
      if items.count > 0
        items.delete
        puts "Deleted"
      else
        puts "No task found"
      end
    end
  end
end
