#!/usr/bin/env ruby

require 'json'

def delete(object)
  {delete: {_index: ".kibana", _type: object["_type"], _id: object["_id"]}}
end

def create(object)
  {index: {_index: ".kibana", _type: object["_type"], _id: object["_id"]}}
end

def data(object)
  object["_source"]
end

objects = []
$*.each do |file|
  objects << JSON.load(File.read(file))
end

objects.flatten!

objects.each do |object|
  puts delete(object).to_json
  puts create(object).to_json
  puts data(object).to_json
end


