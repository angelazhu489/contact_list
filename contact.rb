require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
	also_reload "database_persistence.rb"
end

helpers do
	def format_sym_to_label(sym)
		sym.to_s.gsub("_", " ").capitalize
	end

	def field_type(field)
		type = field.to_s
		case type
		when "phone_number"
			"tel"
		when "email"
			"email"
		else
			"text"
		end
	end
end

# Returns string error for any input of fields
def error_for_params(fields)
	first_name, last_name, phone, email = fields.values
	if first_name.empty? || last_name.empty?
		"A first and last name is required."
	elsif phone.length != 10 && !phone.empty?
		"A phone number must be 10 digits."
	elsif !email.match(/\A[a-z0-9+_.-]+@[a-z0-9.-]+\Z/i) && !email.empty?
		"Please enter a valid email"
	end
end

# Returns hash of fields with fields that have been unchanged set to nil
def updated_fields(contact, fields)
	updated = {}
	fields.each do |key, val|
		val != contact[key] ? updated[key] = val : updated[key] = nil
	end
	updated
end

before do
	@storage = DatabasePersistence.new
end

get "/" do
	redirect "/contacts"
end

# Render add contact form
get "/contacts/new" do
	erb :new_contact, layout: :layout
end

# Add a contact
post "/contacts/new" do
	@id = params[:id].to_i
	fields = { first_name: params[:first_name].capitalize,
						 last_name: params[:last_name].capitalize,
						 phone_number: params[:phone_number],
						 email: params[:email] }
	p fields
	error = error_for_params(fields)
	if error
		session[:message] = error
		erb :new_contact, layout: :layout
	else
		@storage.add_contact(fields)
		session[:message] = "The contact has been added."
		redirect "/"
	end
end

# View all contacts
get "/contacts" do
	@contacts = @storage.all_contacts
	erb :contacts
end

# View a single contact
get "/contacts/:id" do
	@id = params[:id].to_i
	@contact = @storage.find_contact(@id)
	erb :contact
end

# Render edit contact form
get "/contacts/:id/edit" do
	@id = params[:id].to_i
	@contact = @storage.find_contact(@id)
	erb :edit_contact, layout: :layout
end

# Edit a contact
post "/contacts/:id" do
	@id = params[:id].to_i
	fields = { first_name: params[:first_name].capitalize,
						 last_name: params[:last_name].capitalize,
						 phone_number: params[:phone_number],
						 email: params[:email] }
	@contact = @storage.find_contact(@id)
	error = error_for_params(fields)
	if error
		session[:message] = error
		erb :edit_contact, layout: :layout
	else
		updated = updated_fields(@contact, fields)
		@storage.update_contact(@id, updated) unless updated.values.all?(nil)
		session[:message] = "The contact has been updated."
		redirect "/contacts/#{@id}"
	end
end

# Delete a contact

# Delete all contacts