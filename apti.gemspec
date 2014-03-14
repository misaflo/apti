require_relative 'src/apti/version'

Gem::Specification.new do |s|
  s.author = 'Florent Lévigne'
  s.email = 'florent.levigne@mailoo.org'
  s.homepage = 'https://gitorious.org/apti'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Apti is a frontend for aptitude with improved presentation of packages.'
  s.name = 'apti'
  s.version = Apti::Apti::VERSION
  s.license = 'GPL3'
  s.add_runtime_dependency('i18n', '~> 0.6')
  s.require_path = 'src'
  s.bindir = 'bin'
  s.executables << 'apti'
  s.files = Dir['README.md', 'COPYING', 'AUTHORS', 'TODO.md',
    'bin',
    'src/**/*.rb',
    'locales/**/*',
    'initial_config.yml', 'changelog.xml']
  s.description = %Q{Apti is a frontend of aptitude (Debian's package manager) with improved presentation of packages.}
end
