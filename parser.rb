require 'parser/current'
require 'unparser'

lines = open("test.rb").read
#print lines
node = Parser::CurrentRuby.parse(lines)
p node

node.children.each do |child|
	p child.type
	if child.type == :class
		puts "hoge"
		name = child.children[0]
		ext = child.children[1]
		p name.children[1]
		print name.children[0]
		#p ext
		for c in child.children[2..-1]
			if c.type != :def
				next
			end
			p c
			print Unparser.unparse(c.children[2])
		end
		print "\n"
	end
end
