require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
	also_reload "database_persistence.rb"
end

before do
	@storage = DatabasePersistence.new
end

get "/" do
	redirect "/contacts"
end

# View all contacts
get "/contacts" do
	@contacts = @storage.all_contacts
	erb :contacts
end

# View a single contact
get "/contacts/:id" do
	id = params[:id].to_i
	@contact = @storage.find_contact(id)
	erb :contact
end

# Render add contact form

# Add a contact

# Render edit contact form

# Edit a contact

# Delete a contact

# Delete all contacts