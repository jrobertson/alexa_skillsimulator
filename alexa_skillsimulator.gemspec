Gem::Specification.new do |s|
  s.name = 'alexa_skillsimulator'
  s.version = '0.4.0'
  s.summary = 'A local simulator for your Alexa Skill.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/alexa_skillsimulator.rb']
  s.signing_key = '../privatekeys/alexa_skillsimulator.pem'
  s.add_runtime_dependency('askio', '~> 0.1', '>=0.1.1')
  s.add_runtime_dependency('console_cmdr', '~> 0.5', '>=0.5.0')
  s.add_runtime_dependency('alexa_utteranceresponder', '~> 0.2', '>=0.2.0')  
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/alexa_skillsimulator'
end
