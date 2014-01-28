# encoding: utf-8
#===============================================================================
#
# This file is part of Apti.
#
# Copyright (C) 2012-2014 by Florent Lévigne <florent.levigne at mailoo dot com>
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

  require 'i18n'
  require_relative 'config/Config'

  class Apti
    VERSION = '0.5.1'
    NEED_SUPERUSER_RIGHTS = [
      'install', 'remove', 'purge', 'hold', 'unhold', 'keep', 'reinstall',
      'markauto', 'unmarkauto', 'build-depends', 'build-dep', 'forbid-version',
      'update', 'safe-upgrade', 'full-upgrade', 'keep-all', 'forget-new',
      'clean', 'autoclean'
    ]

    #
    # @!attribute config [r]
    #   @return [Apti::Config::Config] Config.
    #
    # @!attribute VERSION [r]
    #   @return [String] Apti's version.
    attr_reader :config, :VERSION

    # Reads the configuration file.
    #
    # @return [void]
    def initialize
      @config = Config::Config.new

      locales_path = File.dirname("#{__FILE__}") + '/../../locales'

      I18n.load_path = Dir[File.join(locales_path, '*.yml')]

      if defined? I18n.enforce_available_locales
        I18n.enforce_available_locales = true
      end

      lang = `echo $LANG`

      if lang =~ /fr_.*/
        I18n.locale = :fr
      else
        I18n.locale = :en
      end
    end

    # Display help.
    #
    # @return [void]
    def help
      puts "usage: #{File.basename $0} commande"
      puts 'Commandes:'
      puts '  update'
      puts '  safe-upgrade'
      puts '  search package'
      puts '  install package'
      puts '  remove package'
      puts '  others aptitude commande...'
      puts '  stats'
    end

    # Display version.
    #
    # @return [void]
    def version
      puts "apti #{VERSION}"
      puts I18n.t(:using)
      puts "  aptitude #{`aptitude --version | head -n 1 | cut -d ' ' -f 2`}"
      puts "  ruby #{`ruby --version | cut -d ' ' -f 2`}"
    end

    # Install packages.
    #
    # @param package [String] List of packages to install
    #
    # @return [void]
    def install(package)

      if package.eql? nil
        usage
      end
      # Check if some packages does not exist.
      packages_not_found = get_packages_not_found(package.split)

      if !packages_not_found.empty?
        puts I18n.t(:'error.package.not_found', packages: packages_not_found.join(' '))
        exit 1
      end

      # Check if all packages are not already installed.
      packages_already_installed = all_installed?(package.split)

      if packages_already_installed
        puts I18n.t(:'error.package.installed')
        exit 1
      end

      aptitude_string = `aptitude install -VZs --allow-untrusted --assume-yes #{package}`
      command = "aptitude install #{package}"

      # If problem with dependencies: display aptitude's message.
      if aptitude_string.include?('1)')
        puts aptitude_string
        exit 1
      end

      packages = aptitude_string.split(/ {2}/)
      operation = I18n.t(:'operation.installing')
      question = I18n.t(:'operation.question.installation')

      if display_packages(packages, operation, @config.colors.install, question, aptitude_string.split(/\n/)[-2])
        execute_command(command, true)
      end
    end

    # Remove / Purge packages.
    #
    # @param package  [String]  List of packages to remove / purge.
    # @param purge    [Boolean] True if purging packages, else removing.
    #
    # @return [void]
    def remove(package, purge = false)
      require_relative 'Package'

      # Check if some packages does not exist.
      packages_not_found = get_packages_not_found(package.split)

      if !packages_not_found.empty?
        puts I18n.t(:'error.package.not_found', packages: packages_not_found.join(' '))
        exit 1
      end

      # Check if all packages are not uninstalled (only for remove).
      if !purge
        packages_not_installed = all_not_installed?(package.split)

        if packages_not_installed
          puts I18n.t(:'error.package.not_installed')
          exit 1
        end
      end

      if purge
        aptitude_string = `aptitude purge -VZs --assume-yes #{package}`
        command = "aptitude purge #{package}"
        operation = I18n.t(:'operation.purging')
        question = I18n.t(:'operation.question.purge')

      else
        aptitude_string = `aptitude remove -VZs --assume-yes #{package}`
        command = "aptitude remove #{package}"
        operation = I18n.t(:'operation.removing')
        question = I18n.t(:'operation.question.remove')
      end

      # If problem with dependencies, wrong name given,
      # or trying to remove a virtual package : display aptitude's message.
      if aptitude_string.include?('1)') || aptitude_string.include?('«')
        puts aptitude_string
        exit 0

      # If the package is not installed.
      elsif !aptitude_string.include?(':')
        puts I18n.t(:package_not_installed)
        exit 0
      end

      # Remove the "p" parameter on packages to purge.
      aptitude_string.sub!(/\{p\}/, '')

      # Split packages.
      packages = aptitude_string.split(/ {2}/)

      if display_packages(packages, operation, @config.colors.remove, question, aptitude_string.split(/\n/)[-2])
        execute_command(command, true)
      end
    end

    # Do upgrade (safe-upgrade or full-upgrade).
    #
    # @param packages     [String]  List of packages to upgrade.
    # @param full_upgrade [Boolean] True if full-upgrade, else safe-upgrade.
    #
    # @return [void]
    def upgrade(packages, full_upgrade = false)
      if full_upgrade
        aptitude_string = `aptitude full-upgrade -VZs --allow-untrusted --assume-yes #{packages}`
        command = "aptitude full-upgrade #{packages}"

      else
        aptitude_string = `aptitude safe-upgrade -VZs --allow-untrusted --assume-yes #{packages}`
        command = "aptitude safe-upgrade #{packages}"
      end
     
      # If problem with dependencies, use aptitude.
      if aptitude_string.include?('1)')
        execute_command(command)
        exit 0

      # If there is no package to upgrade.
      elsif !aptitude_string.include?(':')
        puts I18n.t(:system_is_up_to_date)
        exit 0
      end

      # Split packages.
      packages = aptitude_string.split(/ {2}/)
      operation = I18n.t(:'operation.upgrading')
      question = I18n.t(:'operation.question.upgrade')

      if display_packages(packages, operation, @config.colors.remove, question, aptitude_string.split(/\n/)[-2])
        execute_command(command, true)
      end
    end

    # Search packages.
    #
    # @param package_name [String] Package(s) to search.
    #
    # @return [void]
    def search(package_name)
      require_relative 'Package'

      aptitude_string = `aptitude search --disable-columns #{package_name}`
      terminal_width  = `tput cols`.to_i

      # Information size (i, p, A, ...) : 6 seems to be good.
      package_parameter_length_alignment = 6

      get_search_packages(aptitude_string).each do |package|
        print package.parameter

        print ''.rjust(package_parameter_length_alignment - package.parameter.length)

        # Display package name: if the package is installed, we display it in color.
        if package.parameter.include?('i')
          print "#{@config.colors.install.to_shell_color}#{package.name}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        else
          print package.name
        end

        print ''.rjust(@config.spaces.search - package.name.length)

        size_of_line = package_parameter_length_alignment + @config.spaces.search + package.description.length

        # If description is too long, we shorten it.
        if size_of_line > terminal_width
          package.description = package.description[0..(terminal_width - package_parameter_length_alignment - @config.spaces.search - 1)]
        end

        puts "#{@config.colors.description.to_shell_color}#{package.description.chomp}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
      end
    end

    # Print stats about packages.
    #
    # @return [void]
    def stats
      packages_installed            = `dpkg --get-selections | grep -v deinstall | wc -l`
      packages_installed_explicitly = `aptitude search '~i !~M' | wc -l`
      cache_size                    = `du -sh /var/cache/apt/archives/ | cut -f 1`

      puts "#{`lsb_release -ds`}\n"

      puts I18n.t(:'stat.total_installed', number: packages_installed)
      puts I18n.t(:'stat.explicitly_installed', number: packages_installed_explicitly)
      puts I18n.t(:'stat.space_used_in_cache', size: cache_size)
    end

    # Execute the command with superuser rights if needed.
    #
    # @param command    [String]  Command to execute.
    # @param no_confirm [Boolean] If true execute the command without asking confirmation (--assume-yes).
    #
    # @return [void]
    def execute_command(command, no_confirm = false)
      if not NEED_SUPERUSER_RIGHTS.include?(command.split[1])
        system(command)

      elsif `groups`.split.include?('sudo')
        if no_confirm && @config.no_confirm
          system "sudo #{command} --assume-yes"
        else
          system "sudo #{command}"
        end

      else
        if no_confirm && @config.no_confirm
          system "su -c '#{command} --assume-yes'"
        else
          system "su -c '#{command}'"
        end
      end
    end

    private

    # Return an array of packages that does not exist.
    #
    # @param packages [Array<String>] Packages to check.
    #
    # @return [Array<String>] Packages not found.
    def get_packages_not_found(packages)
      require_relative 'Package'

      not_found = []

      packages.each do |package_name|
        # If we use option (ex: -t sid), we don't check if packages exist.
        if package_name =~ /^-.*$/
          return []
        end

        pkg = Package.new
        pkg.name = package_name
        if !pkg.exist?
          not_found.push(package_name)
        end
      end

      not_found
    end

    # Check if all packages are already installed.
    #
    # @param packages [Array<String>] Packages to check.
    #
    # @return [Boolean]
    def all_installed?(packages)
      require_relative 'Package'

      all_installed = true

      packages.each do |package_name|
        pkg = Package.new
        pkg.name = package_name
        if !pkg.is_installed?
          all_installed = false
        end
      end

      all_installed
    end

    # Check if all packages are not installed.
    #
    # @param packages [Array<String>] Packages to check.
    #
    # @return [Boolean]
    def all_not_installed?(packages)
      require_relative 'Package'

      all_not_installed = true

      packages.each do |package_name|
        pkg = Package.new
        pkg.name = package_name
        if pkg.is_installed?
          all_not_installed = false
        end
      end

      all_not_installed
    end

    # Separate packages in analysis parts (only for install, remove and upgrade).
    # 
    # Return a Hash like +Hash{max, packages}+ with:
    #
    # * max: Apti::Package,             Fake package with max lengths of all attributs.
    # * packages: Array<Apti::Package>, Array of packages.
    # @param packages_line [Array<String>] List of packages, as outputted by aptitude.
    #
    # @return [Hash]
    def analysis_packages(packages_line)
      require_relative 'Package'

      max = Package.new
      max.name                = I18n.t(:'header.package')
      max.version_old         = I18n.t(:'header.version')
      max.version_new         = ''
      max.size_before_decimal = ''
      max.size_after_decimal  = ''
      max.size_unit           = ''

      thousands_separator = I18n.t(:'number.separator.thousands')
      decimal_separator   = I18n.t(:'number.separator.decimal')

      packages = []

      packages_line.delete_if { |package| package == '' || package == "\n" }

      packages_line.each do |package_line|
        # ex: brasero-common{a} [3.8.0-2] <+11,2 MB>
        #                      name                  parameter           version_old                    ->  version_new                 size_before                                                       size_after                            size_unit
        if package_line =~ /^([[:alnum:]+.:-]*)(?:\{([[:alpha:]])\})? \[([[:alnum:][:space:]+.:~-]*)(?: -> ([[:alnum:]+.:~-]*))?\](?: <([+-]?[[:digit:]]{1,3}(?:[#{thousands_separator}]?[[:digit:]]{3})*)([#{decimal_separator}][[:digit:]]+)? ([[:alpha:]]+)>)?$/
          package = Package.new

          package.name                = Regexp.last_match[1]
          package.parameter           = Regexp.last_match[2]
          package.version_old         = Regexp.last_match[3]
          package.version_new         = Regexp.last_match[4]
          package.size_before_decimal = Regexp.last_match[5]
          package.size_after_decimal  = Regexp.last_match[6]
          package.size_unit           = Regexp.last_match[7]

          if package.name.length > max.name.length
            max.name = package.name
          end

          if package.version_old.length > max.version_old.length
            max.version_old = package.version_old
          end
          if !package.version_new.nil? && package.version_new.length > max.version_new.length
            max.version_new = package.version_new
          end

          if !package.size_before_decimal.nil? && package.size_before_decimal.length > max.size_before_decimal.length
            max.size_before_decimal = package.size_before_decimal
          end
          if !package.size_after_decimal.nil? && package.size_after_decimal.length > max.size_after_decimal.length
            max.size_after_decimal = package.size_after_decimal
          end
          if !package.size_unit.nil? && package.size_unit.length > max.size_unit.length
            max.size_unit = package.size_unit
          end

          packages.push(package)
        end
      end

      out            = {}
      out['max']     = max
      out['packages'] = packages

      out
    end

    # Return an Array of the package(s) searched.
    #
    # @param aptitude_string [String] Output of aptitude search's command.
    #
    # @return [Array<Apti::Package>] Array of packages.
    def get_search_packages(aptitude_string)
      require_relative 'Package'

      packages = []

      aptitude_string.each_line do |package_line|
        package = Package.new

        package_str = package_line.split '- '

        # Parameter and name, ex: i A aptitude-common.
        package_parameter_and_name = package_str.first

        package.description = ''

        # Construct the description (all after the first '-').
        name_passed = false
        package_str.each do |str|
          if not name_passed
            name_passed = true
          else
            package.description.concat "- #{str }"
          end
        end

        # The package name (without informations).
        package.name = package_parameter_and_name.split.last

        # Informations of the package: i, p, A, ...
        package_info = package_parameter_and_name.split
        package_info.pop
        package.parameter = package_info.join(' ')

        packages.push(package)
      end

      packages
    end

    # Display all packages of an operation (install, remove or upgrade).
    #
    # @param packages       [Array<String>] List of packages as outputted by aptitude.
    # @param operation      [String]        Operation requested : "Installing", "Upgrading" or "Removing".
    # @param color          [String]        Color (Linux bash color notation) to use for old / current package version.
    # @param question       [String]        Question to ask for continuing operation after displaying packages list.
    # @param download_size  [String]        Aptitude's text about download sizes.
    #
    # @return [void]
    def display_packages(packages, operation, color, question, download_size)
      analysis  = analysis_packages(packages)
      max       = analysis['max']
      packages  = analysis['packages']

      explicit    = []
      dep_install = []
      dep_remove  = []

      packages.each do |package|
        case package.parameter
        when 'a'
          dep_install.push(package)

        when 'u'
          dep_remove.push(package)

        else
          explicit.push(package)
        end
      end

      if explicit.empty?
        puts I18n.t(:'operation.nothing_to_do')
        exit 1
      end

      # Have we packages to upgrade?
      # If yes, we display them at the end (after news to install, and those to remove).
      if !explicit.first.version_new.nil?
        upgrade = true
      end

      print_header(max.name.length, max.version_all.length)

      if !upgrade
        puts "#{@config.colors.text.to_shell_color}#{operation}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        explicit.each { |package| display_package_line(package, max, color) }
        puts ''
      end

      if !dep_install.empty?
        puts "#{@config.colors.text.to_shell_color}#{I18n.t(:installing_for_dependencies)}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        dep_install.each { |package| display_package_line(package, max, @config.colors.install) }
        puts ''
      end

      if !dep_remove.empty?
        puts "#{@config.colors.text.to_shell_color}#{I18n.t(:removing_unused_dependencies)}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        dep_remove.each { |package| display_package_line(package, max, @config.colors.remove) }
        puts ''
      end

      if upgrade
        puts "#{@config.colors.text.to_shell_color}#{operation}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        explicit.each { |package| display_package_line(package, max, color) }
        puts ''
      end

      # Size to download and install.
      puts "#{download_size}"

      answer = ''
      while !answer.downcase.eql?('y') && !answer.downcase.eql?('n')
        print "\n#{@config.colors.text.to_shell_color}#{question} (Y/n)#{Config::Color.new(Config::Color::STYLE_END).to_shell_color} "
        answer = STDIN.gets.chomp
        if answer.empty?
          answer = 'y'
        end
      end

      answer.downcase.eql?('y')
    end

    # Displaying the line of ONE package (for install, remove and upgrade).
    #
    # @param package  [Apti::Package]       The package to display.
    # @param max      [Apti::Package]       Fake package with max lengths of all attributs.
    # @param color    [Apti::Config::Color] Color to use for old / current package version.
    #
    # @return [void]
    def display_package_line(package, max, color)
      # Name.
      print "  #{package.name}"
      # Spaces.
      print ''.rjust((max.name.length - package.name.length) + @config.spaces.columns)
      # Version old.
      print "#{color.to_shell_color}#{package.version_old}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"

      if !package.version_new.nil?
        print "#{' -> '.rjust((max.version_old.length - package.version_old.length) + ' -> '.length)}#{@config.colors.install.to_shell_color}#{package.version_new}#{Config::Color.new(Config::Color::STYLE_END).to_shell_color}"
        rjust_size = max.version_new.length - package.version_new.length
      else
        rjust_size = max.version_all.length - package.version_old.length
      end

      if @config.display_size && !package.size_before_decimal.nil?
        line_size_after_length = (package.size_after_decimal.nil? ? 0 : package.size_after_decimal.length)

        # Spaces.
        print ''.rjust(rjust_size + @config.spaces.columns + max.size_before_decimal.length - package.size_before_decimal.length)
        # Start color.
        print @config.colors.size.to_shell_color
        # Size.
        print "#{package.size_before_decimal}#{package.size_after_decimal}"
        # Spaces and unit.
        print package.size_unit.rjust((max.size_after_decimal.length - line_size_after_length) + (max.size_unit.length) + @config.spaces.unit)
        # End color.
        print Config::Color.new(Config::Color::STYLE_END).to_shell_color
      end

      print "\n"
    end

    # Print header for install, remove and upgrade.
    #
    # @param largest_name     [Fixnum]  Largest size of package name.
    # @param largest_version  [Fixnum]  Largest size of complete version (old / current AND new).
    #
    # @return [void]
    def print_header(largest_name, largest_version)
      terminal_width  = `tput cols`.to_i

      # Top line.
      terminal_width.times do
        print '='
      end
      print "\n"

      # Column's names.
      header_package = I18n.t(:'header.package')
      header_version = I18n.t(:'header.version')
      header_size    = I18n.t(:'header.size')

      print "  #{header_package}"
      print "#{''.rjust(largest_name - header_package.length + @config.spaces.columns)}"
      print "#{header_version}"
      if @config.display_size
        print "#{''.rjust(largest_version - header_version.length + @config.spaces.columns + 1)}"
        print "#{header_size}"
      end
      print "\n"

      # Bottom line.
      terminal_width.times do
        print '='
      end
      print "\n"
    end

  end
end