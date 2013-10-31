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
