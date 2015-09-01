# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mr-clean-css/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ['Kyle Conroy']
  gem.email = ['kjc@stripe.com']
  gem.description = 'A Ruby wrapper to the Clean-CSS minifier for Node.'
  gem.summary = 'Clean-CSS for Ruby.'
  gem.homepage = 'https://github.com/kyleconroy/mr-clean-css'
  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^test/})
  gem.name = 'mr-clean-css'
  gem.require_paths = ['lib']
  gem.version = MrCleanCSS::VERSION
  gem.add_development_dependency('rake')

  # Append all submodule files to the list of gem files.
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  `git submodule --quiet foreach pwd`.split($\).each { |submodule_path|
    Dir.chdir(submodule_path) {
      submodule_relative_path = submodule_path.sub gem_dir, ""
      `git ls-files`.split($\).each { |filename|
        gem.files << "#{submodule_relative_path}/#{filename}"
      }
    }
  }
end
