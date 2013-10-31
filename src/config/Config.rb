#!/usr/bin/env ruby
# encoding: utf-8

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
      @colors       = Config::Colors.new
      @display_size = true
      @spaces       = Config::Spaces.new
      @no_confirm   = false

      path = getDir + file

      if not File.exists? path
        createDefaultFile(file)
      end
    end

    def readFrom(file)
      require 'yaml'

      config = YAML::load_file(getDir + file)

      @colors.readFrom(config['colors'])
      @spaces.readFrom(config['spaces'])
      
      @display_size = readBoolean(config['display_size'], @display_size)
      @no_confirm   = readBoolean(config['no_confirm'],   @no_confirm)
    end

    private
    def getDir
      return getEnvDir + '/apti/'
    end
    def getEnvDir
      if ENV["XDG_CONFIG_HOME"].nil?
        return "#{ENV["HOME"]}/.config"
      else
        return ENV["XDG_CONFIG_HOME"]
      end
    end

    def createDefaultFile (file)
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

      if not File.directory? getDir
        require 'fileutils'
        FileUtils.mkdir_p = getDir
      end

      File.open(getDir + file) do |file|
        file.write(yaml)
      end
    end
  
    def readBoolean (bool, default_value)
      if bool.nil?
        return default_value
      end

      return bool
    end
  end
end

