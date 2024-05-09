require "sinatra"
require "sinatra/reloader"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

get "/" do
	p session
	erb :contacts
end