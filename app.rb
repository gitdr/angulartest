#!/usr/bin/env ruby
#require 'celluloid/autostart'
#require 'reel/rack/server'
require 'sinatra/base'
require 'tilt/haml'
require 'tilt/sass'
require 'chartkick'
require './helpers'
require 'pp'

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

  get '/' do
    @result = []  # this will hold results.

    @result = Dir.glob('/tmp/test/*').map {|file| file.split('/').last}
    haml :app
  end

  get '/upload_dialogue' do
    haml :upload_dialogue
  end

  get '/chart/:name' do
    haml :chart
  end

  post '/upload' do
    params['myfiles'].each do |file|
      tempfile = file[:tempfile]
      filename = file[:filename]
      FileUtils.copy(tempfile.path, "/tmp/test/#{filename}")
      FileUtils.rm(tempfile.path)
    end
   redirect '/'
  end

  run! if app_file == $0
end