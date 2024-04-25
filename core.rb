require 'pg'

module Core
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      attr_accessor :id
    end
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", cast_value(name, value))
    end
  end

  private

  def cast_value(name, value)
    column_type = self.class.columns.find { |column_name, _| column_name == name.to_sym }&.last

    case column_type
    when 'integer'
      value.to_i
    when 'text'
      value.to_s
    else
      value
    end
  end

  module ClassMethods
    def table_name
      name.downcase + 's'
    end

    def column(name, type)
      columns << [name, type]
  
      define_method(name) do
        instance_variable_get("@#{name}")
      end
  
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  
    def columns
      @columns ||= []
    end
  
    def create_table
      return if connection.exec("SELECT to_regclass('#{table_name}')").getvalue(0, 0) != nil
  
      columns_definition = columns.map { |name, type| "#{name} #{type}" }.join(', ')
      connection.exec("CREATE TABLE IF NOT EXISTS #{table_name} (id SERIAL PRIMARY KEY, #{columns_definition})")
    end
  
    def create(attributes)
      create_table

      validate_columns(new(attributes))
      
      columns_names = columns.map(&:first).join(', ')
      columns_values_placeholders = columns.map.with_index { |_, i| "$#{i + 1}" }.join(', ')
      columns_values = columns.map { |name, _| attributes[name] }

      result = connection.exec_params(
        "INSERT INTO #{table_name} (#{columns_names}) VALUES (#{columns_values_placeholders}) RETURNING *",
        columns_values
      )
  
      new(result[0])
    end
  
    def find(id)
      create_table
  
      result = connection.exec("SELECT * FROM #{table_name} WHERE id = #{id}").first
  
      result.nil? ? nil : new(result)
    end

    def find_by(attributes)
      create_table

      conditions = attributes.map { |name, value| "#{name} = '#{value}'" }.join(' AND ')
      result = connection.exec("SELECT * FROM #{table_name} WHERE #{conditions}").first

      result.nil? ? nil : new(result)
    end

    def all
      create_table
  
      result = connection.exec("SELECT * FROM #{table_name}")
  
      result.map { |row| new(row) }
    end

    def where(attributes)
      create_table

      conditions = attributes.map { |name, value| "#{name} = '#{value}'" }.join(' AND ')
      result = connection.exec("SELECT * FROM #{table_name} WHERE #{conditions}")

      result.map { |row| new(row) }
    end
  
    private
  
    def connection
      @connection ||= PG::Connection.new(
        host: 'localhost',
        port: 5432,
        dbname: 'ruby_romania',
        user: 'postgres',
        password: 'password'
      )
    end

    def validate_columns(record)
      columns.each do |name, _|
        record.send("validate_#{name}") if record.respond_to?("validate_#{name}")
      end
    end
  end
end
