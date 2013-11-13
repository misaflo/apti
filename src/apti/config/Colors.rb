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
        @install      = Apti::Config::Color.new(Apti::Config::Color::COLOR_GREEN, Apti::Config::Color::BACKGROUND_BLACK, Apti::Config::Color::EFFECT_BOLD)
        @remove       = Apti::Config::Color.new(Apti::Config::Color::COLOR_RED,   Apti::Config::Color::BACKGROUND_BLACK, Apti::Config::Color::EFFECT_BOLD)
        @description  = Apti::Config::Color.new(Apti::Config::Color::COLOR_BLACK, Apti::Config::Color::BACKGROUND_BLACK, Apti::Config::Color::EFFECT_BOLD)
      end

      # Read colors from a YAML configuration (itself from a configuration file).
      #
      # @param  colors  [Hash{String => String, Fixnum}]   YAML colors part.
      #
      # TODO Color can be get with a simple string corresponding to text color.
      def read_from(colors)
        if colors.nil?
          return
        end

        @install.read_from(colors[:install])
        @remove.read_from(colors[:remove])
        @description.read_from(colors[:description])
      end

      # Write colors to a YAML configuration (itself to a configuration file)
      #
      # @return YAML colors part.
      def write_to
        return {
          :install      =>  @install.write_to(),
          :remove       =>  @remove.write_to(),
          :description  =>  @description.write_to()
        }
      end
    end

  end

end
