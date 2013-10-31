#!/usr/bin/env ruby
# encoding: utf-8

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

      def initialize(file)
        require_relative 'Colors'
        require_relative 'Spaces'

        @colors       = Apti::Config::Colors.new
        @display_size = true
        @spaces       = Apti::Config::Spaces.new
        @no_confirm   = false

        path = get_dir + file

        if not File.exists? path
          create_default_file(file)
        end
      end

      def read_from(file)
        require 'yaml'

        config = YAML::load_file(get_dir + file)

        @colors.read_from(config['colors'])
        @spaces.read_from(config['spaces'])

        @display_size = read_boolean(config['display_size'], @display_size)
        @no_confirm   = read_boolean(config['no_confirm'],   @no_confirm)
      end

      private
      def get_dir
        return get_env_dir + '/apti/'
      end

      def get_env_dir
        if ENV["XDG_CONFIG_HOME"].nil?
          return "#{ENV["HOME"]}/.config"
        else
          return ENV["XDG_CONFIG_HOME"]
        end
      end

      def create_default_file(file)
        require 'yaml'

        yaml = {
          'colors'        =>  {
            'install'       =>  'green',
            'remove'        =>  'red',
            'description'   =>  'gray'
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

        File.open("#{get_dir}#{file}", 'w') do |file|
          file.write(yaml)
        end
      end

      def read_boolean(bool, default_value)
        if bool.nil?
          return default_value
        end

        return bool
      end
    end

  end

end
