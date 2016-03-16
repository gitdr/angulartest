#!/usr/bin/env ruby
require 'csv'
require 'pp'

file = '/tmp/test/inst9k_tuned_300s_allFlows_only-run-64k-100pcread-2drives-1250qdpth.csv'

# data = CSV.read('/tmp/test/inst9k_tuned_300s_allFlows_only-run-64k-100pcread-2drives-1250qdpth.csv')

# [:test_type, :test_description]
# [:version]
# [:time_stamp]
# [:access_specification_name, :default_assignment]
# [:size, :"%_of_size", :"%_reads", :"%_random", :delay, :burst, :align, :reply]
fields = %i(read_i/os write_i/os average_read_response_time average_write_response_time)

index = 1
next_key = []
data = {}
capture_keys = false
mh = {}

CSV.foreach(file) do |row|
  break if index >15
  index += 1

  keys = []

  if row[0] =~/^'/
    keys = row.map! {|el| el.gsub(/'/,'').gsub(/\s/,'_').downcase.to_sym}

    next_key = []

    case keys[0]
    when :results
      capture_keys = true
    end
      
    # next_key = [] if next_key.count > 0
    # next_key << row.map! {|el| el.gsub(/'/,'').gsub(/\s/,'_').downcase.to_sym}.shift
    # next_key.push(*row)
    next
  end



  if capture_keys && row.count > 0
    next_key = row.map {|el| el.nil? ? nil : el.gsub(/'/,'').gsub(/\s/,'_').downcase.to_sym}
    next_key.shift(3)
    capture_keys = false
    next_key.each_with_index do |k,index|
      mh[k] = index if fields.include?(k)
    end
    next
  end
  pp next_key
  if next_key.count > 0
    ts = row.shift
    row.shift
    wn = row.shift
    mh.each do |k,v|
      
      ((data[ts] ||={})[wn] ||={})[k] = row[v]
    end

  end
  
end

pp data
