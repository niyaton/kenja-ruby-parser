require 'parser/current'
require 'unparser'

METHOD_ROOT_NAME = "[MT]"
CLASS_ROOT_NAME = "[CN]"
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
		class_contents = []
		function_contents = []
		others = []
		for child in root.children
			if child.type == :class
				class_contents << create_class_tree(child)
			elsif child.type == :def
				function_contents << create_func_tree(child)
			else
				others << child
			end
		end

		tree = []
		if class_contents	
			tree << GitObject.new(:tree, CLASS_ROOT_NAME, class_contents)
		end
		
		if function_contents
			tree << GitObject.new(:tree, METHOD_ROOT_NAME, function_contents)
		end

		if others
			statements = others.map { |item| Unparser.unparse(item) }
			src = statements.join("\n")
			tree << GitObject.new(:blob, "others", src)
		end
		tree
	end

	def create_func_tree node
		name = node.children[0].to_s
		body = Unparser.unparse(node.children[2])
		contents = []
		contents << GitObject.new(:blob, BODY_BLOB_NAME, body)
		GitObject.new(:tree, name, contents)
	end

	def create_class_tree node
		func_defs = []
		name = node.children[0].children[1].to_s	
		if node.children[2].type == :begin
			definitions = node.children[2].children
		else
			definitions = [node.children[2]]
		end

		for child in definitions
			if child.type == :def
				func_defs << child
			end
		end

		function_contents = []
		for func_def in func_defs
			function_contents << create_func_tree(func_def)
		end
		class_contents = []
		class_contents << GitObject.new(:tree, METHOD_ROOT_NAME, function_contents)
		GitObject.new(:tree, name, class_contents)
	end
end

lines = open("test.rb").read
puts RubyTreeCreator.new(lines).create_tree
