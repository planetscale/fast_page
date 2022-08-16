# frozen_string_literal: true

require_relative "lib/fast_page/version"

Gem::Specification.new do |spec|
  spec.name          = "fast_page"
  spec.version       = FastPage::VERSION
  spec.authors       = ["Mike Coutermarsh"]
  spec.email         = ["coutermarsh.mike@gmail.com"]

  spec.summary       = "Blazing fast pagination for ActiveRecord with deferred joins "
  spec.description   = 'FastPage applies the MySQL "deferred join" optimization to your ActiveRecord offset/limit queries.'
  spec.homepage      = "https://github.com/planetscale/fast_page"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = ">= 2.4.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/planetscale/fast_page"
  spec.metadata["changelog_uri"] = "https://github.com/planetscale/fast_page"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_development_dependency "kaminari", "~> 1.2"
  spec.add_development_dependency "pagy", "~> 5.10"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sqlite3"
end
