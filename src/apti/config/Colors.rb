# encoding: utf-8
#===============================================================================
#
# This file is part of Apti.
#
# Copyright (C) 2013-2015 by Florent Lévigne <florent.levigne at mailoo dot org>
# Copyright (C) 2013-2014 by Julien Rosset <jul.rosset at gmail dot com>
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
      #   @return [Apti::Config::Color] Color of install.
      #
      # @!attribute upgrade [r]
      #   @return [Apti::Config::ColorsUpgrade] Colors of upgrade.
      #
      # @!attribute remove [r]
      #   @return [Apti::Config::Color] Color of remove.
      #
      # @!attribute description [r]
      #   @return [Apti::Config::Color] Color of description.
      #
      # @!attribute size [r]
      #   @return [Apti::Config::Color] Color of size.
      #
      # @!attribute text [r]
      #   @return [Apti::Config::Color] Color of text (operation, confirmation, ...).
      attr_reader :install, :upgrade, :remove, :description, :size, :text

      # Initialize colors to default.
      def initialize
        require_relative 'Color'
        require_relative 'ColorsUpgrade'

        @install      = Color.new(Color::TEXT_GREEN, nil, Color::EFFECT_BOLD)
        @upgrade      = ColorsUpgrade.new
        @remove       = Color.new(Color::TEXT_RED,   nil, Color::EFFECT_BOLD)
        @description  = Color.new(Color::TEXT_BLACK, nil, Color::EFFECT_BOLD)
        @size         = Color.new(Color::TEXT_BLACK, nil, Color::EFFECT_BOLD)
        @text         = Color.new(Color::TEXT_WHITE, nil, Color::EFFECT_BOLD)
      end

      # Read colors from a YAML configuration (itself from a configuration file).
      #
      # @param  colors  [Hash{String => String, Fixnum}]   YAML colors part.
      #
      # @return [void]
      def read_from(colors)
        return if colors.nil?

        @install.read_from(colors['install'])
        @upgrade.read_from(colors['upgrade'])
        @remove.read_from(colors['remove'])
        @description.read_from(colors['description'])
        @size.read_from(colors['size'])
        @text.read_from(colors['text'])
      end
    end
  end
end
