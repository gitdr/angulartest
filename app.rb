#require 'celluloid/autostart'
#require 'reel/rack/server'
require 'sinatra/base'
require 'tilt/haml'
require 'tilt/sass'
require './helpers'

class App < Sinatra::Base

  helpers Helpers

  set :views, :scss => 'views/scss', :default => 'views'

  configure :development do
    enable :dump_errors, :logging
    #set :server, 'reel'
    set :bind, '0.0.0.0'
    set :port, 3000
  end

  get '/css/:file.css' do
    halt 404 unless File.exist?("views/scss/#{params[:file]}.scss")
    time = File.stat("views/scss/#{params[:file]}.scss").ctime
    last_modified(time)
    scss params[:file].intern
  end

  get '/*' do
    haml :app
  end

  post '/login' do
  end

  run! if app_file == $0
end