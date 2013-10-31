#===============================================================================
#
# This file is part of Apti.
#
# Copyright (C) 2012-2013 by Florent Lévigne <florent.levigne at mailoo dot com>
# Copyright (C) 2013 by Julien Rosset <jul.rosset at gmail dot com>
#
#
# Apti is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Apti is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#===============================================================================

module Apti

  class Apti
    # @!attribute config [r]
    #   @return [Apti::Config::Config] Config.
    #
    # @!attribute VERSION [r]
    #   @return [String] Apti's version.

    VERSION = "0.4-dev"

    attr_reader :config, :VERSION

    # Reads the configuration file.
    #
    # @return [void]
    def initialize
      require_relative 'config/Config'

      #@config = Apti::Config::Config.new
    end

    # Display help.
    #
    # @return [void]
    def help
      puts "usage: #{File.basename $0} commande"
      puts "Commandes:"
      puts "  update"
      puts "  safe-upgrade"
      puts "  search package"
      puts "  install package"
      puts "  remove package"
      puts "  others aptitude commande..."
      puts "  stats"
    end

    # Display version.
    #
    # @return [void]
    def version
      puts "apti #{VERSION}"
    end

    # Install packages.
    #
    # @param package [String] List of packages to install
    #
    # @return [void]
    def install(package)
    end

    # Remove / Purge packages.
    #
    # @param package  [String]  List of packages to remove / purge
    # @param purge    [Boolean] True if purging packages else removing
    #
    # @return [void]
    def remove(package, purge = false)
    end

    # Do upgrade (safe-upgrade or full-upgrade).
    #
    # @param packages     [String]  List of packages to upgrade
    # @param full_upgrade [Boolean] True if full-upgrade, else safe-upgrade
    #
    # @return [void]
    def upgrade(packages, full_upgrade = false)
    end

    # Search packages.
    #
    # @param package [String] Package(s) to search.
    #
    # @return [void]
    def search(package)
      require_relative 'Package'

      ###############################
      color_install = "\e[1;32m"
      color_description = "\e[1;30m"
      color_end = "\e[0m"
      spaces_search = 40
      ###############################

      aptitude_string = `aptitude search --disable-columns #{package}`
      terminal_width  = `tput cols`.to_i

      # information size (i, p, A, ...) : 6 seems to be good
      package_parameter_length_alignment = 6

      # for each package
      aptitude_string.each_line do |package_line|
        package = Package.new

        package_str = package_line.split '- '

        # parameter and name, ex: i A aptitude-common
        package_parameter_and_name = package_str.first

        package.description = ''

        # construct the description (all after the first '-')
        name_passed = false
        package_str.each do |str|
          if not name_passed
            name_passed = true
          else
            package.description.concat "- #{str }"
          end
        end

        # informations of the package: i, p, A, ...
        package_info = package_parameter_and_name.split
        package_info.pop
        package.parameter = package_info.join(' ')

        # just the package name (without informations)
        package.name = package_parameter_and_name.split.last

        # display package informations
        print package.parameter

        # print spaces between package_info and package.name
        (package_parameter_length_alignment - package.parameter.length).times do
          print ' '
        end

        # display package name: if the package is installed, we display it in color
        if package_info.include? 'i'
          print "#{color_install}#{package.name}#{color_end}"
        else
          print package.name
        end

        # print spaces between package.name and package_description
        (spaces_search - package.name.length).times do
          print ' '
        end

        size_of_line = package_parameter_length_alignment + spaces_search + package.description.length

        # if description is too long, we shorten it
        if size_of_line > terminal_width
          package.description = package.description[0..(terminal_width - package_parameter_length_alignment - spaces_search - 1)]
        end

        # display the description
        puts "#{color_description}#{package.description.chomp}#{color_end}"
      end
    end

    # Print stats about packages.
    #
    # @return [void]
    def stats
      packages_installed            = `dpkg --get-selections | grep install | grep -v deinstall | wc -l`
      packages_installed_explicitly = `aptitude search '~i !~M' | wc -l`
      cache_size                    = `du -sh /var/cache/apt/archives/ | cut -f 1`

      puts "#{`lsb_release -ds`}\n"

      puts "Total installed packages:         #{packages_installed}"
      puts "Explicitly installed packages:    #{packages_installed_explicitly}"
      puts "Space used by packages in cache:  #{cache_size}"
    end

    private

    # Separate packages in analysis parts.
    # 
    # Return a Hash as bellow :
    #
    #   Hash{max, Array<detail>}
    #
    #   max['name']           : length of largest name
    #   max['version']['old'] : length of largest old (for upgrade) or current version
    #   max['version']['new'] : length of the largest new version (only for upgrade)
    #   max['size']['before'] : length of the size of the package, before the decimal
    #   max['size']['after']  : length of the size of the package, after the decimal
    #   max['size']['unit']   : length of the size's unit
    #
    #   detail['name']            : name of the package
    #   detail['parameter']       : aptitude's information : a, u, p
    #   detail['version']['old']  : old / current version of the package
    #   detail['version']['new']  : new version of the package (only for upgrade)
    #   detail['size']['before']  : size of the package, before the decimal
    #   detail['size']['after']   : size of the package, after the decimal
    #   detail['size']['unit']    : size's unit
    #
    # @param packages [Array<String>] List of packages
    #
    # @return [Hash{String => Hash{String => Fixnum, String, Hash{String => Fixnum, String}}}]
    #   Largest sizes and details of sections of package line : name, version
    #   (old / current and new) and size (integer part, decimal part and unit)
    def analysis_packages(packages)
    end

    # Display all packages of an operation (install, remove or upgrade).
    #
    # @param packages       [Array<String>] List of packages (analysis_packages called automaticaly)
    # @param operation      [String]        Operation requested : "Installing", "Upgrading" or "Removing"
    # @param color          [String]        Color (Linux bash color notation) to use for old / current package version
    # @param question       [String]        Question to ask for continuing operation after displaying packages list
    # @param download_size  [String]        Aptitude's text about download sizes
    #
    # @return [void]
    def display_packages(packages, operation, color, question, download_size)
    end

    # Displaying the line of ONE package.
    #
    # @param line       [Hash{String => String, Hash{String => String}}]  Details of package to display
    # @param max        [Hash{String => Fixnum, Hash{String => Fixnum}}]  Largest sizes of sections
    # @param color      [String]                                          Color (Linux bash color notation) to use for old / current package version
    #
    # @return [void]
    def display_package_line(line, max, color)
    end

    # Print header for install, remove and upgrade.
    #
    # @param largest_name     [Fixnum]  Largest size of package name
    # @param largest_version  [Fixnum]  Largest size of complete version (old / current AND new)
    #
    # @return [void]
    def print_header(largest_name, largest_version)
    end

    # Execute the command with superuser rights if needed.
    #
    # @param command    [String]  Command to execute
    # @param no_confirm [Boolean] If true execute the command without asking confirmation (--assume-yes)
    #
    # @return [void]
    def execute_command(command, no_confirm = false)
    end
  end
end
