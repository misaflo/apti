#!/usr/bin/ruby -w
# encoding: utf-8


=begin
****************************************************************************

  Apti is a frontend for aptitude with improved presentation of packages.
  version: 0.1 (2012/04/18)

  Copyright (C) 2012 by Florent Lévigne <florent.levigne at mailoo dot com>
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************
=end


COLORINSTALL      = "\033[1;32m"  # green
COLORREMOVE       = "\033[1;31m"  # red
COLORDESCRIPTION  = "\033[1;30m"  # gray
COLOREND          = "\033[0m"

USESUDO           = false         # if false, use root password

SPACESNAME        = 40            # spaces between name and version of a package
SPACESVERSION     = 20            # spaces between version installed and version to install




##########################
##      functions       ##
##########################

#
# help
#
def help
  puts "usage: #{File.basename($0)} commande"
  puts "Commandes:"
  puts "  update"
  puts "  upgrade"
  puts "  search package"
  puts "  install package"
  puts "  remove package"
  puts "  others aptitude commande..."
end


#
# upgrade
#
def upgrade full_upgrade = false
  if full_upgrade
    aptitude_string = `aptitude full-upgrade -V -s --allow-untrusted --assume-yes`
  else
    aptitude_string = `aptitude upgrade -V -s --allow-untrusted --assume-yes`
  end

  # if problem with dependencies, use aptitude
  if aptitude_string.include? '1)'

    if USESUDO
      if full_upgrade
        system "sudo aptitude full-upgrade"
      else
        system "sudo aptitude upgrade"
      end

    else
      if full_upgrade
        system "su -c 'aptitude full-upgrade'"
      else
        system "su -c 'aptitude upgrade'"
      end
    end

    exit(0)

  # if there is no package to upgrade
  elsif !aptitude_string.include? ':'
    puts "System is up to date."
    exit(0)
  end

  packages = [[]]

  first_install = false
  first_remove  = false
  first_update  = false

  # split packages
  packages = aptitude_string.split(']')
  packages.each do |ele|

    # if we have a package to install
    # ex: freepats{a} [20060219-1
    if ele =~ /(([a-zA-Z]|[0-9]|-|\+|\.)*)\{a\}.*\[([:alnum:]|-)*/
      package_name = $1
      package_version = ele.split(' [').last

      if first_install == false
        puts "\033[1mNew package(s) to install:\033[0m"
        first_install = true
      end

      print "install: #{package_name}"

      # print spaces between name and version of the package
      (SPACESNAME - package_name.length).times do
        print ' '
      end

      puts "#{COLORINSTALL}#{package_version}#{COLOREND}"

    # if we have a package to remove
    # ex: gcj-4.6-base{u} [4.6.3-1]
    elsif ele =~ /(([a-zA-Z]|[0-9]|-|\+|\.)*)\{u\}.*\[([:alnum:]|-)*/
      package_name = $1
      package_version = ele.split(' [').last

      if first_remove == false
        puts "\n\033[1mPackage(s) to remove:\033[0m"
        first_remove = true
      end

      print "remove: #{package_name} "

      # print spaces between name and version of the package
      (SPACESNAME - package_name.length).times do
        print ' '
      end

      puts "#{COLORREMOVE}#{package_version}#{COLOREND}"

    # if we have a package to upgrade
    # ex: php5 [5.3.10-2 -> 5.4.0-3
    elsif ele =~ /(([a-zA-Z]|[0-9]|-|\+|\.)* \[.* -> .*)/
      package_info = $1

      package_name        = package_info.split[0]
      version_installed   = package_info.split[1].sub('[', '')
      version_to_install  = package_info.split[3]

      if first_update == false
        puts "\n\033[1mPackage(s) to update:\033[0m"
        first_update = true
      end
      
      # package name
      print "update: #{package_name} "

      # print spaces between name and version of the package
      (SPACESNAME - package_name.length).times do
        print ' '
      end

      # version installed
      print "#{COLORREMOVE}#{version_installed}#{COLOREND} "

      # print spaces between version installed and version to install
      (SPACESVERSION - version_installed.length).times do
        print ' '
      end

      # version to install
      puts "-> #{COLORINSTALL}#{version_to_install}#{COLOREND}"
    end

  end

  answer = ''
  while answer.downcase != 'y' && answer.downcase != 'n'
    print "\n\033[1mContinue the upgrade ? (Y/n)\033[0m "
    answer = STDIN.gets.chomp
    if answer == ''
      answer = 'y'
    end
  end

  if answer.downcase == 'n'
    exit(0)
  end

  if USESUDO
    if full_upgrade
      system "sudo aptitude full-upgrade"
    else
      system "sudo aptitude upgrade"
    end

  else
    if full_upgrade
      system "su -c 'aptitude full-upgrade'"
    else
      system "su -c 'aptitude upgrade'"
    end
  end
end


#
# search
#
def search package
  aptitude_string = `aptitude search --disable-columns #{package}`

  # for each package
  aptitude_string.each_line do |package|
    
    package_str = package.split('- ')

    package_name = package_str.first
    package_description = ''

    # construct the description (all after the first '-')
    name_passed = false
    package_str.each do |str|
      if name_passed == false
        name_passed = true
      else
        package_description += "- #{str }"
      end
    end

    # if the package is installed, we display it in color
    if package_name.split.first.include? 'i'
      puts "#{COLORINSTALL}#{package_name}#{COLOREND}"
    else
      puts package_name
    end

    # display the description
    package_description.chomp!
    if package_description != ''
      puts "\t#{COLORDESCRIPTION}#{package_description}#{COLOREND}"
    end
    
  end
end


#
# install
#
def install package
  aptitude_string = `aptitude install -V -s --allow-untrusted --assume-yes #{package}`

  # if problem with dependencies, use aptitude
  if aptitude_string.include? '1)'
    if USESUDO
      system "sudo aptitude install #{package}"
    else
      system "su -c 'aptitude install #{package}'"
    end
    exit(0)

  # if the name is wrong
  elsif aptitude_string.include? '«'
    puts "Wrong name given."
    exit(0)

  # if the package is already installed
  elsif !aptitude_string.include? ':'
    puts "Package(s) already installed."
    exit(0)
  end

  packages = [[]]

  first_install = false

  # split packages
  packages = aptitude_string.split(']')
  packages.each do |ele|

    # if we have a package to install
    # ex: freepats{a} [20060219-1 or freepats [20060219-1
    if ele =~ /(([a-zA-Z]|[0-9]|-|\+|\.|\{|\})*.*)\[([:alnum:]|-)*/
      package_name = $1
      package_version = ele.split(' [').last

      if first_install == false
        puts "\033[1mPackage(s) to install:\033[0m"
        first_install = true
      end

      print "install: #{package_name}"

      # print spaces between name and version of the package
      (SPACESNAME - package_name.length).times do
        print ' '
      end
      
      puts "#{COLORINSTALL}#{package_version}#{COLOREND}"

    end
  end

  answer = ''
  while answer.downcase != 'y' && answer.downcase != 'n'
    print "\n\033[1mContinue the installation ? (Y/n)\033[0m "
    answer = STDIN.gets.chomp
    if answer == ''
      answer = 'y'
    end
  end

  if answer.downcase == 'n'
    exit(0)
  end

  if USESUDO
    system "sudo aptitude install #{package}"
  else
    system "su -c 'aptitude install #{package}'"
  end
end


#
# remove
#
def remove package
  aptitude_string = `aptitude remove -V -s --assume-yes #{package}`

  # if the name is wrong
  if aptitude_string.include? '«'
    puts "Wrong name given."
    exit(0)

  # if the package is not installed
  elsif !aptitude_string.include? ':'
    puts "Package(s) not installed."
    exit(0)
  end

  packages = [[]]

  first_remove = false

  # split packages
  packages = aptitude_string.split(']')
  packages.each do |ele|

    # if we have a package to remove
    # ex: freepats{u} [20060219-1 or freepats [20060219-1
    if ele =~ /(([a-zA-Z]|[0-9]|-|\+|\.|\{|\})*.*)\[([:alnum:]|-)*/
      package_name = $1
      package_version = ele.split(' [').last

      if first_remove == false
        puts "\033[1mPackage(s) to remove:\033[0m"
        first_remove = true
      end

      print "remove: #{package_name}"

      # print spaces between name and version of the package
      (SPACESNAME - package_name.length).times do
        print ' '
      end
      
      puts "#{COLORREMOVE}#{package_version}#{COLOREND}"

    end
  end

  answer = ''
  while answer.downcase != 'y' && answer.downcase != 'n'
    print "\n\033[1mRemove these packages ? (Y/n)\033[0m "
    answer = STDIN.gets.chomp
    if answer == ''
      answer = 'y'
    end
  end

  if answer.downcase == 'n'
    exit(0)
  end

  if USESUDO
    system "sudo aptitude remove #{package}"
  else
    system "su -c 'aptitude remove #{package}'"
  end
end



##########################
##      execution       ##
##########################

case ARGV[0]

  when 'upgrade'
    upgrade

  when 'full-upgrade'
    upgrade true

  when 'search'
    packages_to_search = ''
    first_argv_passed = false
    ARGV.each do |package|
      if first_argv_passed == false
        first_argv_passed = true
      else
        packages_to_search += " #{package}"
      end
    end
    search packages_to_search

  when 'update'
    if USESUDO
      system "sudo aptitude update"
    else
      system "su -c 'aptitude update'"
    end

  when 'remove'
    packages_to_remove = ''
    first_argv_passed = false
    ARGV.each do |package|
      if first_argv_passed == false
        first_argv_passed = true
      else
        packages_to_remove += " #{package}"
      end
    end
    remove packages_to_remove

  when 'install'
    packages_to_install = ''
    first_argv_passed = false
    ARGV.each do |package|
      if first_argv_passed == false
        first_argv_passed = true
      else
        packages_to_install += " #{package}"
      end
    end
    install packages_to_install

  when '--help'
    help

  # other aptitude command
  else
    if ARGV[0] != nil
      arg = ''
      ARGV.each do |ele|
        arg += "#{ele} "
      end
      system "aptitude #{arg}"
    else
      help
    end

end
