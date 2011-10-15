#!/usr/bin/env ruby -wKU
#  td TODO list manager
require 'yaml'

def die message=''
  $stderr.puts message
  exit
end

@queue = []

@internals = [:init, :aliases, :list]
# internal implementations
@aliases = <<-EOA
alias td='/Users/edh/ruby/todo/td.rb'
alias td.clear='td clear'
alias td.head='td first'
alias td.alias='td aliases'
alias td.init='td init'
alias td.list='td list'
alias td.pop='td pop'
alias td.shift='td shift'
EOA

def init
  @queue.clear
  dump_yaml @queue
  seriallize(".alias", @aliases) {|f,o| f.puts o}
  puts "./.todo intialized; Now do: 'source ./.alias'"
end

def aliases
  puts @aliases
end

def list
  puts @queue; die
end

def todo_path
  "./.todo" # or ~/.todo
end

def seriallize path, object=nil, &blk 
  begin
    args = [path]; args << "w" unless object.nil?
    result=[]
      File.open(*args) do |f| 
     result = yield f, object
    end
    result
  rescue Exception => e
    die "Unable to #{object.nil? ? "open" : "write"} yaml : #{path} :  #{e.message}"
  end
end

def load_yaml
  seriallize(todo_path) {|f, o| YAML::load(f)}
end

def dump_yaml object
  seriallize(todo_path, object) {|f, o| YAML::dump(o, f)}
end

if File.exists?(todo_path) and not File.zero?(todo_path)
  @queue = load_yaml 

  if ARGV.empty?
    puts @queue.last
    exit
  end
end

if ARGV.size == 1 # must be command
  cmd=ARGV.shift.to_sym
  if @internals.include?(cmd)
    self.send cmd
  else 
    puts @queue.send(cmd.to_sym)
  end
else
  message = ARGV.join ' '
  @queue << message unless message.empty?
end

dump_yaml @queue
