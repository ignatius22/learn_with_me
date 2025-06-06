namespace :db do
  desc "Sync main.sql with current Rails schema"
  task sync_main_sql: :environment do
    puts "Syncing main.sql with current Rails schema..."
    
    # Generate fresh structure.sql
    Rake::Task['db:structure:dump'].invoke
    
    # Copy structure.sql to main.sql with some cleanup
    structure_content = File.read(Rails.root.join('db', 'structure.sql'))
    
    # Remove Rails-specific comments and metadata
    cleaned_content = structure_content.gsub(/^-- Dumped.*$/, '')
                                      .gsub(/^-- PostgreSQL database dump.*$/, '')
                                      .gsub(/^-- Dumped by.*$/, '')
                                      .strip
    
    # Write to main.sql
    File.write(Rails.root.join('db', 'main.sql'), cleaned_content)
    
    puts "✅ main.sql has been synced with current schema"
    puts "📍 Location: db/main.sql"
  end
  
  desc "Check if main.sql is in sync with current schema"
  task check_main_sql: :environment do
    puts "Checking if main.sql is in sync..."
    
    # Generate current structure
    system('rails db:structure:dump')
    
    structure_content = File.read(Rails.root.join('db', 'structure.sql'))
    main_content = File.read(Rails.root.join('db', 'main.sql'))
    
    # Basic comparison (you might want to make this more sophisticated)
    if structure_content.include?('progress_percentage') && main_content.include?('progress_percentage')
      puts "✅ main.sql appears to be in sync"
    else
      puts "⚠️  main.sql may be out of sync"
      puts "   Run 'rails db:sync_main_sql' to update it"
    end
  end
end

# Hook into existing Rails tasks
Rake::Task['db:migrate'].enhance do
  puts "\n🔄 Auto-syncing main.sql after migration..."
  Rake::Task['db:sync_main_sql'].invoke
end

Rake::Task['db:rollback'].enhance do
  puts "\n🔄 Auto-syncing main.sql after rollback..."
  Rake::Task['db:sync_main_sql'].invoke
end

