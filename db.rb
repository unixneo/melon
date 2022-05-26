class DB
  attr_reader :connection

  def initialize
     
    db_name = "#{ENV['MELON_DB_NAME'] || 'melon'}_#{ENV['MELON_PORT'] || '4567'}.rb"
    @connection = SQLite3::Database.new(db_name)

    rows = @connection.execute(%(SELECT name FROM sqlite_master WHERE type='table' AND name='blocks';))

    # No rows means the table containing blocks doesn't exist.
    return if rows.size > 0

    File.open("schema.sql").read.split(";").each do |statement|
      @connection.execute(statement)
    end
  end
end
