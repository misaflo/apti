#!/usr/bin/env ruby
# encoding: utf-8

module Apti

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

      def read_from(colors)
        if colors.nil?
          return
        end

        @install     = read_color(colors['install'],     @install)
        @remove      = read_color(colors['remove'],      @remove)
        @description = read_color(colors['description'], @description)
      end

      private
      def read_color(color, default_value)
        if color.nil?
          return default_value
        end

        if !(color.to_s =~ /^[[:digit:]]{1,3}$/).nil?    # Si un nombre (forcément compris entre 0 et 255 inclus)
          return color
        end

        color_constant = 'COLOR_' + color.upcase
        if Colors.const_defined?(color_constant, false)
          return Colors.const_get(color_constant, false)
        end

        print "Configuration : Unable to get color from \"#{color}\"\n"
        return default_value
      end
    end

  end

end
