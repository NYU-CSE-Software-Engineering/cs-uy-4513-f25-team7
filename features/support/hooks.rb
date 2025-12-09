# Additional setup if needed

# Ensure migrations run before each test scenario for in-memory databases
# This is critical because in-memory databases are wiped between scenarios
Before do
  # Ensure database connection is established
  ActiveRecord::Base.connection
  
  # Run migrations if using in-memory SQLite database
  db_config = ActiveRecord::Base.connection_db_config.configuration_hash
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
  end
end
