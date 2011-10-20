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


@queue = []

class Internals
  def initialize queue
    @queue = queue
  end

  def init
    @queue.clear
    dump_yaml @queue
    ".todo initialized"
  end

  def aliases
    <<-EOA
alias td.='td last'
alias td.add='td push'
alias td.clear='td clear'
alias td.head='td first'
alias td.alias='td aliases'
alias td.init='td init'
alias td.list='td clone'
alias td.pop='td pop'
alias td.shift='td shift'
alias td.put='td unshift'
EOA
  end

  def help
    puts <<-EOH
  Usage: td command [option] [argument, ...]
    Description: td manages a TODO list (./.todo) in a folder.
  
    Commands:
       aliases        Prints a list of aliases
       clear          Clears the list
       clone          Prints the entire list
       first          Display the hea of the list
       help           This message
       init           Creates an empty ./.todo file
       last           Display the last message
       pop            Display and remove the last message
       push    ARGs   Adds ARGs to the end of the list 
       shift          Display and remove the first message
       unshift ARGs   Add ARGs to the head of the list

       Options: N/A
  EOH
  end
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

# main routine
@internals = Internals.new @queue

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

tree = expression ARGV
cmd = walk(tree)

@queue = load_yaml
puts execute @queue, cmd
dump_yaml @queue
