require_relative 'db_connection'
require_relative '01_mass_object'

require 'active_support/inflector'
require 'debugger'

class MassObject
  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end
end

class SQLObject < MassObject
  
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    hashes = DBConnection.execute("SELECT * FROM #{self.table_name}")
    self.parse_all(hashes)
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        #{self.table_name}
      WHERE
        id = ?
    SQL
    parse_all(object)[0]
  end

  def insert
    columns, qs = [], []
    self.class.attributes.each do |attr|
      columns << attr 
      qs << "?"
    end

    column_string = columns.join(", ")
    values = self.attribute_values
    q_string = qs.join(", ")

    DBConnection.execute(<<-SQL, *values)
      INSERT INTO 
        #{self.class.table_name} (#{column_string})
      VALUES   
        (#{q_string})
    SQL

    self.id = DBConnection.last_insert_row_id
    update 
    
  end

  def save
    if self.id.nil?
      insert 
    else
      update
    end
  end

  def update
    values = self.attribute_values
    set_string = self.class.attributes.map { |attr| attr }.join(" = ?, ") + " = ?"
    DBConnection.execute(<<-SQL, *values, self.id)
      UPDATE
        #{self.class.table_name}
      SET 
        #{set_string}
      WHERE
        id = ?
    SQL
  end

  def attribute_values
    self.class.attributes.map do |attr|
      self.send("#{attr}") || 0
    end
  end
end
