require 'yaml'

namespace :run do
  task :serve do
    sh 'rackup'
  end

  task :prod do
    sh 'pumactl -F puma.rb start'
  end

  task :stop do
    sh 'pumactl -F puma.rb -S .pids/pte.state -P .pids/pte.pid stop'
  end

  task :restart do
    sh 'pumactl -F puma.rb -S .pids/pte.state -P .pids/pte.pid restart'
  end
end

namespace :db do
  require 'bundler'
  Bundler.require
  Sequel.extension :migration
  require './initializers/sequel'

  task :version do
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0

    puts "Schema Version: #{version}"
  end

  task :migrate do
    Sequel::Migrator.run(DB, 'migrations')
    Rake::Task['db:version'].execute
  end

  task :rollback do |_t, args|
    args.with_defaults(:target => 0)

    Sequel::Migrator.run(DB, 'migrations', :target => args[:target].to_i)
    Rake::Task['db:version'].execute
  end

  task :reset do
    Sequel::Migrator.run(DB, 'migrations', :target => 0)
    Sequel::Migrator.run(DB, 'migrations')
    Rake::Task['db:version'].execute
  end
end
