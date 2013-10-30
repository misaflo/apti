#!/usr/bin/env ruby
# encoding: utf-8

module Config
  class Config
    attr_reader :color, :display_size, :spaces, :no_confirm

    def initialize (file)
      path = getDir + file

      if not File.exists? path
        createDefaultFile(file)
      end
    end

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
        'color'         =>  {
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
  end
end

