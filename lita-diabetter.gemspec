Gem::Specification.new do |spec|
  spec.name          = 'lita-diabetter'
  spec.version       = '1.1.0'

  branch_name = ENV['TRAVIS_BRANCH']
  tag_name = ENV['TRAVIS_TAG']

  puts branch_name
  puts tag_name

  spec.version       = "#{spec.version}.alpha.#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.authors       = ['Cas Eliëns']
  spec.email         = ['cas.eliens@gmail.com']
  spec.description   = 'A better diabetes handler for Lita'
  spec.summary       = 'Provides diabetes-related commands like glucose value conversions'
  spec.homepage      = 'https://github.com/cascer1/lita-diabetter'
  spec.license       = 'GPL-3.0+'
  spec.metadata      = {'lita_plugin_type' => 'handler'}

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '~> 4.7'
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.4.2'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
end
