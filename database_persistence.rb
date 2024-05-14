require "pg"

class DatabasePersistence
	def initialize
		@db = PG.connect(dbname: "contact_list")
	end

	# Return array of hashes of all contacts
	def all_contacts
		sql = "SELECT * FROM contacts ORDER BY first_name, last_name"
		result = @db.exec(sql)
		result.map do |tuple|
			format_tuple(tuple)
		end
	end

	# Return row from contacts table
	def find_contact(id)
		sql = "SELECT * FROM contacts WHERE id = $1"
		result = @db.exec_params(sql, [id]).first
		format_tuple(result)
	end

	# Update row of table 
	def update_contact(id, fields)
		method_args = create_update_fields_sql(id, fields)
		sql = method_args[0]
		sql_args = method_args[1]
		@db.exec_params(sql, sql_args)
	end

	# Add row to table
	def add_contact(fields)
		method_args = create_add_fields_sql(fields)
		sql = method_args[0]
		sql_args = method_args[1]
		@db.exec_params(sql, sql_args)
	end

	# Delete row of table
	def delete_contact(id)
		sql = "DELETE FROM contacts WHERE id = $1"
		@db.exec_params(sql, [id])
	end

	# Delete all rows of table
	def delete_all_contacts
		@db.exec("DELETE FROM contacts")
	end

	private

	# Format sql tuple to application hash
	def format_tuple(tuple)
		{ id: tuple["id"].to_i,
			first_name: tuple["first_name"],
			last_name: tuple["last_name"],
			phone_number: tuple["phone_number"],
			email: tuple["email"] }
	end

	# Return sql statement and arguments to exec_params method
	def create_update_fields_sql(id, fields)
		set_conditions = []
		sql_args = []
		bind_param = 1
		fields.each do |key, val|
			if val == nil
				next
			elsif val == ""
				set_conditions << "#{key.to_s} = NULL"
			else
				sql_args << val
				set_conditions << "#{key.to_s} = $#{bind_param}"
				bind_param += 1
			end
		end
		set_conditions = set_conditions.join(", ")
		["UPDATE contacts SET #{set_conditions} WHERE id = #{id}", sql_args]
	end 

	def create_add_fields_sql(fields)
		col_names = []
		sql_args = []
		bind_params = []
		ind = 1
		fields.each do |key, val|
			if val != ""
				col_names << key.to_s
				sql_args << val
				bind_params << "$#{ind}"
				ind += 1
			end
		end
		["INSERT INTO contacts (#{col_names.join(", ")}) VALUES (#{bind_params.join(", ")})", sql_args]
	end

end