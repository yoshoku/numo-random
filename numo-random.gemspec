# frozen_string_literal: true

require_relative 'lib/numo/random/version'

Gem::Specification.new do |spec|
  spec.name = 'numo-random'
  spec.version = Numo::Random::VERSION
  spec.authors = ['yoshoku']
  spec.email = ['yoshoku@outlook.com']

  spec.summary = 'Numo::Random provides random number generation with several distributions for Numo::NArray.'
  spec.description = 'Numo::Random provides random number generation with several distributions for Numo::NArray.'
  spec.homepage = 'https://github.com/yoshoku/numo-random'
  spec.license = 'Apache-2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/numo-random'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
                     .select { |f| f.match(/\.(?:rb|rbs|h|hpp|c|cpp|md|txt)$/) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/numo/random/extconf.rb']

  spec.add_dependency 'numo-narray', '>= 0.9.1'
end
