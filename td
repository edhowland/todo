#!/usr/bin/env ruby -wKU
#  td TODO list manager
require 'yaml'

def die message=''
  $stderr.puts message
  exit
end

class Command
  def initialize queue=[]
    @queue = queue
  end
  
  def execute_with_args command, *args
    @queue.send command.to_sym, *args
  end
  
  def execute_no_args
    @queue.send command.to_sym
  end
  
  def execute command, *args
    result = if args.empty?
              execute_no_args command
            else
              execute_with_args command, *args
            end
    puts result unless result.nil? or not result.kind_of?(String)
  end
  
  def <<(argv, message)
    command = argv.shift
    unless message.nil? or message.empty?
      execute command, message
    else
      execute command
    end
    # p @queue
    # puts "td #{command} #{message}"
  end
end

class Options
  def <<(argv, message)
    if argv.length > 1
    option = argv.pop

      if option =="-f"
        message = 'FIXME: ' + message
      elsif option == '-r'
        message = 'REMOVEME: ' + message
      else
        message = option + '' + message
        message = 'TODO: ' + message
      end
    end
    return argv, message
  end
end

class Arguments
  def <<(argv)
    arry = []
    if argv.length == 1
      return argv, nil
    elsif argv.length == 2
      return argv.pop
    2.times {arry << argv.shift}
    return arry, argv.join(' ')
  end
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

command = Command.new load_yaml
options = Options.new
arguments = Arguments.new

# parse and execute command line
command.<<( *options.<<( *arguments.<<(ARGV) ) )



# if File.exists?(todo_path) and not File.zero?(todo_path)
#   @queue = load_yaml 
# 
#   if ARGV.empty?
#     puts @queue.last
#     exit
#   end
# end
# 
# if ARGV.size == 1 # must be command
#   cmd=ARGV.shift.to_sym
#   if @internals.include?(cmd)
#     self.send cmd
#   else 
#     puts @queue.send(cmd.to_sym)
#   end
# else
#   message = ARGV.join ' '
#   @queue << message unless message.empty?
# end
# 
# dump_yaml @queue
