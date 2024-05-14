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

	# Format sql tuple to application hash
	def format_tuple(tuple)
		{ id: tuple["id"].to_i,
			first_name: tuple["first_name"],
			last_name: tuple["last_name"],
			phone_number: tuple["phone_number"],
			email: tuple["email"] }
	end

	# Update row of table 
	def update_contact(id, fields)
		method_args = create_update_fields_sql(id, fields)
		sql = method_args[0]
		sql_args = method_args[1]
		@db.exec_params(sql, sql_args)
	end

	private

	# Return sql statement and arguments to exec_params method
	def create_update_fields_sql(id, fields)
		set_conditions = []
		sql_args = []
		ind = 1
		fields.each do |key, val|
			if val == nil
				next
			elsif val == ""
				set_conditions << "#{key.to_s} = NULL"
			else
				sql_args << val
				set_conditions << "#{key.to_s} = $#{ind}"
				ind += 1
			end
		end
		set_conditions = set_conditions.join(", ")
		["UPDATE contacts SET #{set_conditions} WHERE id = #{id}", sql_args]
	end 
end