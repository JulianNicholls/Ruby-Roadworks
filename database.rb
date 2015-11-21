require 'sequel'

class Database
  def self.connect_postgres(db_name)
    new(Sequel.postgres db_name)
  end

  def self.connect_via_path(path)
    new(Sequel.connect path)
  end

  def initialize(connection)
    @db = connection
  end

  def use_table(name)
    puts name
    self.class.send(:define_method, name) do
      @db[name.to_sym]
    end
  end

  def [](table)
    @db[table]
  end
end
