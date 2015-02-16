version = File.read(File.expand_path('../version', __FILE__)).strip

Gem::Specification.new do |s|
  s.name      = 'netlinx-workspace'
  s.version   = version
  s.date      = Time.now.strftime '%Y-%m-%d'
  s.summary   = 'A library for working with AMX NetLinx Studio workspaces in Ruby.'
  s.description = "This library provides a developer API for working with NetLinx Studio workspaces in Ruby. It also adds compiler support to the NetLinx Compile gem for these workspaces."
  s.homepage  = 'https://github.com/amclain/netlinx-workspace'
  s.authors   = ['Alex McLain']
  s.email     = ['alex@alexmclain.com']
  s.license   = 'Apache 2.0'
  
  s.files     =
    ['license.txt', 'README.md'] +
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['doc/**/*']
  
  s.executables = [
  ]
  
  s.add_development_dependency 'netlinx-compile', '~> 3.0'
  
  s.add_development_dependency 'rake',      '~> 10.4'
  s.add_development_dependency 'yard',      '~> 0.8.7'
  s.add_development_dependency 'rspec',     '~> 3.2'
  s.add_development_dependency 'rspec-its', '~> 1.1'
  s.add_development_dependency 'fivemat',   '~> 1.3'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rb-readline'
end
