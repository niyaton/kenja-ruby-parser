require 'parser/current'
require 'unparser'

module KenjaRubyParser
  class RubyTreeCreator
    def initialize(src)
      @src = src
    end

    def create_tree
      root = Parser::CurrentRuby.parse(@src)
      class_contents = []
      function_contents = []
      others = []

      root.children.each do |child|
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
        tree << GitObject.new(:blob, TOPLEVEL_BLOB_NAME, src)
      end
      tree
    end

    def create_func_tree(node)
      name = node.children[0].to_s
      body = Unparser.unparse(node.children[2])
      contents = []
      contents << GitObject.new(:blob, BODY_BLOB_NAME, body)
      GitObject.new(:tree, name, contents)
    end

    def create_class_tree(node)
      func_defs = []
      name = node.children[0].children[1].to_s
      if node.children[2].type == :begin
        definitions = node.children[2].children
      else
        definitions = [node.children[2]]
      end

      definitions.each do |child|
        child.type == :def && func_defs << child
      end

      function_contents = []
      func_defs.each do |func_def|
        function_contents << create_func_tree(func_def)
      end
      class_contents = []
      class_contents << GitObject.new(:tree, METHOD_ROOT_NAME, function_contents)
      GitObject.new(:tree, name, class_contents)
    end
  end
end
