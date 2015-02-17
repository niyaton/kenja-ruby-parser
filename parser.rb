require 'parser/current'
require 'unparser'

METHOD_ROOT_NAME = "[MT]"
BODY_BLOB_NAME = "body"

class GitObject
	def initialize(type, name, contents)
		@type = type
		@name = name
		@contents = contents
	end

	def to_s
		lines = []
		case @type
		when :tree then
			lines << "[TS] #{@name}"
			for content in @contents
				lines << content.to_s
			end
			lines << "[TE]"
		when :blob then
			lines << "[BN] #{@name}"
			nlines = @contents.count("\n") + 1
			lines << "[BI] #{nlines}"
			lines << @contents
		end
		lines.join("\n")
	end
end

class RubyTreeCreator
	def initialize src
		@src = src
	end

	def create_tree
		root = Parser::CurrentRuby.parse(@src)
		class_defs = []
		for child in root.children
			if child.type == :class
				puts "class!"
				class_defs << child
			elsif child.type == :def
				puts "function!"
			else
				puts "others!"
			end
		end
		
		lines = []
		for class_def in class_defs
			lines << create_class_tree(class_def)
		end
		lines.join("\n")
	end

	def create_func_tree node
		puts "----start function----"
		name = node.children[0].to_s
		#p node.children[1]
		body = Unparser.unparse(node.children[2])
		contents = []
		contents << GitObject.new(:blob, BODY_BLOB_NAME, body)
		puts "----end   funciton----"
		GitObject.new(:tree, name, contents)
	end

	def create_class_tree node
		func_defs = []
	
		puts "----start class ----"
		for child in node.children[2..-1]
			if child.type == :def
				func_defs << child
			end
		end
		function_contents = []
		for func_def in func_defs
			function_contents << create_func_tree(func_def)
		end
		puts "----end  class ----"
		GitObject.new(:tree, METHOD_ROOT_NAME, function_contents) 
	end
end

lines = open("test.rb").read
puts RubyTreeCreator.new(lines).create_tree
