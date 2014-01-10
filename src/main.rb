#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'apti/Apti'

# Enable warnings.
$VERBOSE = true

apti = Apti::Apti.new

if ARGV[0].nil?
  apti.help
  exit(1)
end

packages = ARGV[1..(ARGV.length - 1)].join(' ')

if ['search', 'remove', 'purge', 'install'].include?(ARGV[0]) && packages.empty?
  apti.help
  exit(1)
end

case ARGV[0]

when '--help'
  apti.help
when '-h'
  apti.help

when '--version'
  apti.version

when 'safe-upgrade'
  apti.upgrade(packages)

when 'upgrade'
  puts I18n.t(:'warning.upgrade')
  apti.upgrade(packages)

when 'full-upgrade'
  apti.upgrade(packages, true)

when 'search'
  apti.search(packages)

when 'update'
  apti.execute_command('aptitude update')

when 'remove'
  apti.remove(packages)

when 'purge'
  apti.remove(packages, true)

when 'install'
  apti.install(packages)

when 'stats'
  apti.stats

# other aptitude command
else
  if ARGV[0].eql?(nil)
    help

  else
    apti.execute_command "aptitude #{ARGV[0]} #{packages}"
  end

end
