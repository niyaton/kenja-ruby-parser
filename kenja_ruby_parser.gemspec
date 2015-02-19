# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kenja_ruby_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "kenja_ruby_parser"
  spec.version       = KenjaRubyParser::VERSION
  spec.authors       = ["Kenji Fujiwara"]
  spec.email         = ["kenji-f@is.naist.jp"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{Ruby parser for kenja}
  spec.homepage      = "https://github.com/niyaton/kenja-ruby-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   << "parse_ruby"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "parser"
  spec.add_runtime_dependency "unparser"
end
