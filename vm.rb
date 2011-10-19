@t = [:cmd, nil, nil]
@tdo = [:cmd, ["arg|"], [:op1]]
@td = [:cmd, nil, ["arg|"]]


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

def expression argv, tree
  command argv, tree
  zero_or_one(argv, tree) {|a, t| option a,t }
  zero_or_more(argv, tree) {|a, t| arg a,t}
end

@argvs=[
  ["cmd", "-f","arg"],
  ["cmd", "-f","arg1", "arg2"],
  ["cmd", "arg1", "arg2", "arg3"],
  ["cmd", "-t"], 
  ["cmd"]
]

 
@argvs.each do |argv|
  tree = []
  expression argv, tree
  p walk(tree)
end
 
