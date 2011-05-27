# DataMapper Setup
# TODO: create production/dev confs here, see:
# https://github.com/tricycle/vote_your_album/blob/master/lib/config.sample.rb
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db/esms.db")
# save our anonymous model for many-to-many
DataMapper.finalize  

# DataMapper Migrations
#DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

# rack-flash
use Rack::Session::Cookie
use Rack::Flash
use Rack::Flash, :sweep => true
enable :sessions

# NOTE: 1.9.2 passenger/rvm fix, remove if rvm isn't being used
#set :views, File.dirname(__FILE__) + "/views"
#set :public, File.dirname(__FILE__) + "/public"
#set :run, true

# Twilio setup
TNUM = "YOUR_TWILIO_NUMBER"
Twilio::Config.setup do
  account_sid 'YOUR_SID_HERE'
  auth_token 'YOUR_TOKEN_HERE'
end
