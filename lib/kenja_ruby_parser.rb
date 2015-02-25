require "kenja_ruby_parser/version"
require "kenja_ruby_parser/git_object"
require "kenja_ruby_parser/ruby_tree_creator"

module KenjaRubyParser
  METHOD_ROOT_NAME = '[MT]'
  CLASS_ROOT_NAME = '[CN]'
  BODY_BLOB_NAME = 'body'
  TOPLEVEL_BLOB_NAME = 'top_level_statements'
end
