#!/usr/bin/env ruby -wKU
#  td TODO list manager
require 'yaml'

def die message=''
  $stderr.puts message
  exit
end

def walk tree, stack=[]
  return stack if tree.nil? or tree.empty?
  stack << tree.first
  walk tree[1], stack
  walk tree[2], stack
  stack 
end

def command argv, tree
  tree[0] = argv.shift
end

def option argv, tree
  raise "Syntax error: expected option" unless argv[0] =~ /^-/
  tree[2] = [argv.shift]
end

def arg argv, tree
  raise "Argument empty error" if argv.empty?
  if tree[1].nil?
    tree[1] = [argv.shift]
  else
    tree[1] = [tree[1][0] + ' ' + argv.shift]
  end
end

def zero_or_one argv, tree, &blk
  begin
    yield argv, tree
  rescue Exception => e
  end
end

def zero_or_more argv, tree, &blk
  begin
    yield argv, tree
    zero_or_more argv, tree, &blk
  rescue Exception => e
  end
end

def expression argv, tree=[]
  command argv, tree
  zero_or_one(argv, tree) {|a, t| option a,t }
  zero_or_more(argv, tree) {|a, t| arg a,t}
  tree
end


class Internals
  attr_accessor :path, :queue
  
  def initialize path='./.todo'
    @path = path
    @path = File.expand_path '~/.todo' unless File.exists?(@path)
    @queue = load_yaml 
  end

  def init path=nil
    @path="#{path}/.todo" unless path.nil?
    @queue.clear
    "#{@path} initialized"
  end

  def info
    die "TODO list atL #{@path}"
  end

  def aliases
    puts <<-EOA
alias td.='td last'
alias td.add='td push'
alias td.clear='td clear'
alias td.head='td first'
alias td.help='td help'
alias td.alias='td aliases'
alias td.init='td init'
alias td.info='td info'
alias td.list='td clone'
alias td.pop='td pop'
alias td.shift='td shift'
alias td.put='td unshift'
alias td.path='td info'
EOA
  die ''
  end

  def help
    die <<-EOH
  Usage: td command [option] [argument, ...]
    Description: td manages a TODO list (./.todo) in a folder.
  
    Commands:
       aliases        Prints a list of aliases
       clear          Clears the list
       clone          Prints the entire list
       first          Display the hea of the list
       help           This message
       init           Creates an empty ./.todo file
       info           Display location of .todo file
       last           Display the last message
       pop            Display and remove the last message
       push    ARGs   Adds ARGs to the end of the list 
       shift          Display and remove the first message
       unshift ARGs   Add ARGs to the head of the list

       Options: N/A
  EOH
  end
  
  def save
    dump_yaml @queue
  end
  
  private
  def seriallize path, object=nil, &blk 
    result=[]
    begin
      args = [path]; args << "w" unless object.nil?
        File.open(*args) do |f| 
        result = yield f, object
      end
    rescue Errno::ENOENT => e
      # puts "#{@path} : not found"
      #  be silent
    rescue Exception => e
      die "Unable to #{object.nil? ? "open" : "write"} yaml : #{path} :  #{e.class.name}"
    end
    result
  end
  
  def load_yaml
    seriallize(@path) {|f, o| YAML::load(f)}
  end

  def dump_yaml object
    seriallize(@path, object) {|f, o| YAML::dump(o, f)}
  end
end

# main routine

def execute queue, cmd
  com = cmd.shift.to_sym
  if queue.respond_to? com
    queue.send com, *cmd
  elsif @internals.respond_to? com
    @internals.send com, *cmd
  else
    die "td: Unknown command: #{com}"
  end
end

tree = expression ARGV  # parse ARGV to AST
cmd = walk(tree)        # form command stack of primatives

@internals = Internals.new
puts execute @internals.queue, cmd
@internals.save
