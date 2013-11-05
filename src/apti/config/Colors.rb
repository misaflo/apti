# encoding: utf-8
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

  module Config

    # Colors to use in apti.
    class Colors
      #
      # @!attribute COLOR_END [r]
      #   @return [Fixnum] Shell color id for stopping color (e.g. black).
      #
      # @!attribute COLOR_GREY [r]
      #   @return [Fixnum] Shell color id for grey.
      #
      # @!attribute COLOR_RED [r]
      #   @return [Fixnum] Shell color id for red.
      #
      # @!attribute COLOR_GREEN [r]
      #   @return [Fixnum] Shell color id for green.
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

      # Initialize colors to default.
      def initialize
        @install     = COLOR_GREEN
        @remove      = COLOR_RED
        @description = COLOR_GREY
      end

      # Read colors from a YAML configuration (itself from a configuration file).
      #
      # @param  colors  [Hash{String => String, Fixnum}]   YAML colors part.
      def read_from(colors)
        if colors.nil?
          return
        end

        @install     = read_color(colors['install'],     @install)
        @remove      = read_color(colors['remove'],      @remove)
        @description = read_color(colors['description'], @description)
      end

      private

      # Get correct value of a "color" from YAML configuration (cf. read_from).
      #
      # @note If *color* is a String, Colors will try to convert it to a shell color using "COLOR_*" Colors constants.
      #
      # @param  color           [String, Fixnum]      The *color* to read.
      # @param  default_value   [Fixnum]              The default value to use if a color is not valid.
      # 
      # @return [Fixnum] The correct shell color id.
      def read_color(color, default_value)
        if color.nil?
          return default_value
        end

        # If color is a number (always between 0 and 255 inclusive).
        if !(color.to_s =~ /^[[:digit:]]{1,3}$/).nil?
          return color
        end

        color_constant = "#{COLOR_}#{color.upcase}"
        if Colors.const_defined?(color_constant, false)
          return Colors.const_get(color_constant, false)
        end

        print "Configuration: Unable to get color from \"#{color}\"\n"
        default_value
      end
    end

  end

end
