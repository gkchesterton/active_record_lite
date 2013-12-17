require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
		where_line = params.keys.join(" = ? AND ") + " = ?"

  	object = DBConnection.execute(<<-SQL, *params.values)
  		SELECT
  			*
			FROM
				#{self.table_name}
			WHERE 
				#{where_line}	
  	SQL

  	parse_all(object)

  end
end

class SQLObject
  extend Searchable
end
