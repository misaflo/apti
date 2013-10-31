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

    class Spaces
      #
      # @!attribute columns [r]
      #   @return [Fixnum] Number of spaces between two columns.
      #
      # @!attribute unit [r]
      #   @return [Fixnum] Number of spaces before size unit.
      #
      # @!attribute search [r]
      #   @return [Fixnum] Number of spaces with \"search\" between package name and his description.
      attr_reader :columns, :unit, :search

      def initialize
        @columns =  2
        @unit    =  1
        @search  = 40
      end

      def read_from(spaces)
        if spaces.nil?
          return
        end

        @columns = read_space(spaces['columns'], @columns)
        @unit    = read_space(spaces['unit'],    @unit)
        @search  = read_space(spaces['search'],  @search)
      end

      private
      def read_space(space, default_value)
        if space.nil?
          return default_value
        end

        if !(space.to_s =~ /^[[:digit:]]+$/).nil?
          return space
        end

        print "Configuration : Unable to get number of spaces from \"#{space}\"\n"
        return default_value
      end
    end

  end

end
