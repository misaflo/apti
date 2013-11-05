#===============================================================================
#
# This file is part of Apti.
#
# Copyright (C) 2013 by Florent Lévigne <florent.levigne at mailoo dot com>
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

  # Apti configuration module
  module Config

    # Apti general configuration
    class Config
      #
      # @!attribute colors [r]
      #   @return [Colors] Colors.
      #
      # @!attribute display_size [r]
      #   @return [Boolean] Display packages size or not ?
      #
      # @!attribute spaces [r]
      #   @return [Spaces] Spaces.
      #
      # @!attribute no_confirm [r]
      #   @return [String] Ask operation confirmation or not ?
      attr_reader :colors, :display_size, :spaces, :no_confirm

      # Initialize configuration : read configuration file or, if not exists, create it with default configuration.
      #
      # @param  file    [String]    Configuration filename (without path).
      def initialize(file = 'aptirc.yml')
        require_relative 'Colors'
        require_relative 'Spaces'

        @colors       = Apti::Config::Colors.new
        @display_size = true
        @spaces       = Apti::Config::Spaces.new
        @no_confirm   = false

        path = get_dir + file

        if not File.exists? path
          create_default_file(file)
        else
          read_from(file)
        end
      end

      # Read a configuration file (it must exists).
      #
      # @param  file    [String]    Filename (without path) to read.
      def read_from(file)
        require 'yaml'

        config = YAML::load_file("#{get_dir}#{file}")

        @colors.read_from(config['colors'])
        @spaces.read_from(config['spaces'])

        @display_size = read_boolean(config['display_size'], @display_size)
        @no_confirm   = read_boolean(config['no_confirm'],   @no_confirm)
      end

      private
      # Get path to Apti configuration directory.
      #
      # @return [String]  Path of Apti configuration directory.
      def get_dir
        return get_env_dir + '/apti/'
      end

      # Get path to system configuration directory.
      #
      # @return [String]  Path of sytem configuration directory.
      def get_env_dir
        if ENV["XDG_CONFIG_HOME"].nil?
          return "#{ENV["HOME"]}/.config"
        else
          return ENV["XDG_CONFIG_HOME"]
        end
      end

      # Create a configuration file with default values.
      #
      # @param  filename    [String]    Filename (without path) of configuration file to create.
      def create_default_file(filename)
        require 'yaml'

        yaml = {
          'colors'        =>  {
            'install'       =>  'green',
            'remove'        =>  'red',
            'description'   =>  'grey'
          },
          'display_size'  =>  true,
          'spaces'        =>  {
            'columns'       =>   2,
            'unit'          =>   1,
            'search'        =>  40
          },
          'no_confirm'    =>  false
        }.to_yaml

        if not File.directory? get_dir
          require 'fileutils'
          FileUtils.mkdir_p = get_dir
        end

        File.open("#{get_dir}#{filename}", 'w') do |file|
          file.write(yaml)
        end
      end

      # Get correct value of boolean from YAML configuration (cf. read_from).
      #
      # @param  bool            [Boolean]   The value to "read".
      # @param  default_value   [Boolean]   Default value to use if @a bool is not valid.
      #
      # @return [Boolean]   The correct value.
      def read_boolean(bool, default_value)
        if bool.nil?
          return default_value
        end

        return bool
      end
    end

  end

end
