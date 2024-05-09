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

	def find_contact(id)
		sql = "SELECT * FROM contacts WHERE id = $1"
		result = @db.exec_params(sql, [id]).first
		format_tuple(result)
	end

	def format_tuple(tuple)
		{ id: tuple["id"].to_i,
			first_name: tuple["first_name"],
			last_name: tuple["last_name"],
			phone_number: tuple["phone_number"],
			email: tuple["email"] }
	end
end