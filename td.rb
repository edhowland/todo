#!/usr/bin/env ruby -wKU
#  td TODO list manager
require 'yaml'

def todo_path
  "./.todo" # or ~/.todo
end

def yamlize path, object=nil, &blk 
  begin
    yield path, object
  rescue Exception => e
    $stderr.puts "Unable to #{object.nil? ? "open" : "write"} yaml : #{path} :  #{e.message}"
  end
end

def from_yaml
  yamlize todo_path do |p, o| 
    File.open(p) {|f| YAML::load(f)}
  end
end

def dump_yaml object
  yamlize todo_path, object do |p, o|
    File.open(p, "w") {|f| YAML::dump(o, f)}
  end
end

@queue = []
@queue = from_yaml if File.exists? todo_path

if ARGV.empty?
  puts @queue.last
  exit
end
message = ARGV.join ' ' unless ARGV.empty?
@queue << message

dump_yaml @queue
