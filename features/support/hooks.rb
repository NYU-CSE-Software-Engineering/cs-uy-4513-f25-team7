# Additional setup if needed

# Ensure migrations run before each test scenario
# For in-memory databases: migrations must run before each scenario (database is wiped)
# For file-based databases: db:prepare should have already handled migrations, but we ensure tables exist
Before do
  begin
    # Ensure database connection is established
    ActiveRecord::Base.connection
    
    db_config = ActiveRecord::Base.connection_db_config.configuration_hash rescue {}
    database_path = db_config[:database] rescue nil
    
    # Handle in-memory SQLite databases
    if db_config[:adapter] == 'sqlite3' && database_path == ':memory:'
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
      # For file-based databases (like in CI), ensure migrations are up to date
      # CI runs db:prepare, but we need to ensure all migrations are applied
      begin
        migration_context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
        # Check if migrations are pending
        if migration_context.needs_migration?
          migration_context.migrate
        end
      rescue => migration_error
        # If migration fails, try to continue - db:prepare should have handled it
        Rails.logger.warn "Migration check warning: #{migration_error.message}" if defined?(Rails.logger)
      end
      
      # Verify critical tables exist
      unless ActiveRecord::Base.connection.table_exists?('users')
        # If users table doesn't exist, force migration
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
