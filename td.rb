#!/usr/bin/env ruby -wKU
#  td TODO list manager
require 'yaml'

def todo_path
  "./.todo" # or ~/.todo
end

def from_yaml
  begin
    File.open(todo_path) do |f|  
      YAML::load(f)
    end
  rescue Exception => e
    $stderr.puts "Unable to open yaml : #{todo_path} :  #{e.message}"
  end
end

def dump_yaml object
  begin
    File.open(todo_path, "w") do |f|  
      YAML::dump(object, f)
    end
    true
  rescue Exception => e
    $stderr.puts "Unable to write yaml #{e.message}"
    false
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
