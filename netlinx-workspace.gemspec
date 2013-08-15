version = File.read(File.expand_path('../version', __FILE__)).strip

Gem::Specification.new do |s|
  s.name      = 'netlinx-workspace'
  s.version   = version
  s.date      = Time.now.strftime '%Y-%m-%d'
  s.summary   = 'A library for working with AMX NetLinx Studio workspaces in Ruby.'
  s.description = ''
  s.homepage  = ''
  s.authors   = ['Alex McLain']
  s.email     = 'alex@alexmclain.com'
  s.license   = 'Apache 2.0'
  
  s.files     =
    ['license.txt', 'README.html'] +
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['doc/**/*']
  
  s.executables = [
  ]
  
  s.add_development_dependency('netlinx-compile')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('pry')
end
