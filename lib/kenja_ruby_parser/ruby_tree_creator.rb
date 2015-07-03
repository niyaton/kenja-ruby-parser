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
      module_contents = []
      function_contents = []
      others = []

      root.children.each do |child|
        if child.type == :class
          class_contents << create_class_tree(child)
        elsif child.type == :module
          puts child.to_s
          module_contents << create_module_tree(child)
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

      if module_contents
        tree << GitObject.new(:tree, MODULE_ROOT_NAME, module_contents)
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

    def create_class_module_tree(node, definition_start_index)
      name = node.children[0].children[1].to_s
      puts name
      if node.children[definition_start_index] == nil
        definitions = []
      elsif node.children[definition_start_index].type == :begin
        definitions = node.children[definition_start_index].children
      else
        definitions = [node.children[definition_start_index]]
      end

      function_contents = []
      class_contents = []
      module_contents = []
      definitions.each do |child|
        child.type == :def && function_contents << create_func_tree(child)
        child.type == :class && class_contents << create_class_tree(child)
        child.type == :module && module_contents << create_module_tree(child)
      end

      contents = []
      contents << GitObject.new(:tree, METHOD_ROOT_NAME, function_contents)
      contents << GitObject.new(:tree, CLASS_ROOT_NAME, class_contents)
      contents << GitObject.new(:tree, MODULE_ROOT_NAME, module_contents)
      GitObject.new(:tree, name, contents)
    end

    def create_class_tree(node)
      create_class_module_tree(node, 2)
    end

    def create_module_tree(node)
      create_class_module_tree(node, 1)
    end
  end
end
