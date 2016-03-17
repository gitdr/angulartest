#!/usr/bin/env ruby
require 'csv'
require 'fileutils'
require 'pp'

file = '/tmp/test/inst9k_tuned_300s_allFlows_only-run-64k-100pcread-2drives-1250qdpth.csv'

# fields we're after
fields = %i(read_i/os write_i/os average_read_response_time average_write_response_time)

# for debugging purposes - limit number of lines to process
index = 1

# vars to store extracted field names
capture_keys = false
next_key = []

# this is where final results will be stored
data = {}

# hash of fields we need selected from all available
mh = {}
# current worker id
wcc = 0
# max id of a worker in the test
WCCMAX = 6
# current time stamp
cur_ts = nil

CSV.foreach(file) do |row|
  #break if index >32
  index += 1

  keys = []

  if row[0] =~/^'/
    keys = row.map! {|el| el.gsub(/'/,'').gsub(/\s/,'_').downcase.to_sym}

    next_key = []

    case keys[0]
    when :results
      capture_keys = true
    end
      
    next
  end


  # if flag to capture is set and current row is not empty
  if capture_keys && row.count > 0
    # transform keys into symbols
    next_key = row.map {|el| el.nil? ? nil : el.gsub(/'/,'').gsub(/\s/,'_').downcase.to_sym}
    
    # drop first 3 elements (timestamp, target type, target name)
    next_key.shift(3)
    # stop capturing keys
    capture_keys = false

    # build hash to select only columnds we need
    next_key.each_with_index do |k,index|
      mh[k] = index if fields.include?(k)
    end
    next
  end
  
  if next_key.count > 0 && row[3].nil?
    # if current worker # is zero 
    if wcc.eql?(0)
      # reset timestamp
      cur_ts = row.shift 
    else
      # drop timestamp of the current row
      row.shift
    end
    
    # increment worker #
    wcc += 1
    
    # skip target type
    row.shift

    # worker #
    wn = row.shift

    # select only elements we need based on mh settings
    mh.each do |k,v|
      ((data[cur_ts] ||={})[wn] ||={})[k] = row[v]
    end
    wcc = 0 if wcc.eql?(WCCMAX)
  end
  
end

# this is where we calculate arithmetic average per timestamp
data.each do |ts,v|
  
  data[ts][:average] = {}
  mh.keys.each { |key| data[ts][:average][key] = 0 }

  v.values.each do |wdata|
    mh.keys.each { |key| data[ts][:average][key] += wdata.delete(key).to_f }
  end
  v.keys.each { |key| v.delete(key) if key =~ /Worker/ }
  mh.keys.each { |key| data[ts][:average][key] = sprintf "%.3f", data[ts][:average][key] / WCCMAX }
end

# write files
dir = file.split('.')[0]
FileUtils::mkdir_p dir

mh.keys.each do |key|
  fn = key.to_s.gsub(/\//,'')

  CSV.open([dir,fn].join('/'), "wb") do |csv|
    csv << data.keys.unshift(nil)
    csv << data.values.map {|el| el[:average][key]}.unshift(key)
  end
end
