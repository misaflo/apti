#!/usr/bin/env ruby
# encoding: utf-8

module Config

  # Shell colors code.
  class Colors
    COLOR_END   = 0
    COLOR_GREY  = 30
    COLOR_RED   = 31
    COLOR_GREEN = 32

    #
    # @!attribute install [r]
    #   @return [Fixnum] Color of install.
    #
    # @!attribute remove [r]
    #   @return [Fixnum] Color of remove.
    #
    # @!attribute description [r]
    #   @return [Fixnum] Color of description.
    attr_reader :install, :remove, :description

    def initialize
      @install     = COLOR_GREEN
      @remove      = COLOR_RED
      @description = COLOR_GREY
    end

    def readFrom(colors)
      if colors.nil?
        return
      end

      @install     = readColor(colors['install'],     @install)
      @remove      = readColor(colors['remove'],      @remove)
      @description = readColor(colors['description'], @description)
    end

    private
    def readColor(color, default_value)
      if color.nil?
        return default_value
      end

      if color =~ /^[[:digit:]]{1,3}$/    # Si un nombre (forcément compris entre 0 et 255 inclus)
        return color
      end

      cst = 'COLOR_' + color.upcase
      if self.const_defined? cst, false
        return self.const_get cst, false
      end

      print "Configuration : Unable to get color from \"#{color}\""
      return default_value
    end
  end
end
