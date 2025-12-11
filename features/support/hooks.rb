# Additional setup if needed

# Ensure migrations run before each test scenario
# For in-memory databases: migrations must run before each scenario (database is wiped)
# For file-based databases: db:prepare should have already handled migrations, but we ensure tables exist
Before do
  begin
    # Ensure database connection is established
    ActiveRecord::Base.connection
    
    db_config = ActiveRecord::Base.connection_db_config.configuration_hash rescue {}
    
    # Handle in-memory SQLite databases
    if db_config[:adapter] == 'sqlite3' && db_config[:database] == ':memory:'
      # Enable foreign keys
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") rescue nil
      
      # Drop all tables first to ensure clean state
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table) rescue nil
      end
      
      # Run all migrations fresh
      migration_context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
      migration_context.migrate
    else
      # For file-based databases (like in CI), db:prepare should have already run migrations
      # Just verify that the users table exists (critical for most tests)
      unless ActiveRecord::Base.connection.table_exists?('users')
        # If users table doesn't exist, try to run migrations
        migration_context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
        migration_context.migrate
      end
    end
  rescue => e
    # Log but don't fail - db:prepare should have handled migrations
    Rails.logger.warn "Database setup warning: #{e.message}" if defined?(Rails.logger)
    # Try to continue anyway
  end
end
