#!/usr/bin/env ruby
#require 'celluloid/autostart'
#require 'reel/rack/server'
require 'sinatra/base'
require 'tilt/haml'
require 'tilt/sass'
require 'chartkick'
require 'csv'
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

    @dirs = Dir.glob('/tmp/test/**').select { |fn| File.directory?(fn) }.map {|file| file.split('/').last}
    pp @dirs

    @dirs.each do |dir|
      Dir.glob('/tmp/test/'+ dir +'/*').map {|file| file.split('/').last}.each_with_index do |file, index|
        if index ==0 
          @result << [dir,file]
        else
           @result << [nil,file]
        end
      end
    end
    #
    haml :app
  end

  get '/upload_dialogue' do
    haml :upload_dialogue
  end

  get '/chart/:name' do
    fn = '/tmp/test/' + params[:name].split(':').join('/')
    data = CSV.read(fn)
    data[0].shift
    @chartname = data[1].shift
    @result = data[0].select.each_with_index { |_,i| i % 10 == 0 }.zip(data[1].select.each_with_index { |_,i| i % 10 == 0 })
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