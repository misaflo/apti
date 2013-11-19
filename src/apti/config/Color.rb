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

    class Color
      #
      # @!attribute COLOR_END [r]
      #   @return [Fixnum] Shell color id for stopping color style.
      STYLE_END   = 0

      #
      # @!attribute COLOR_BLACK [r]
      #   @return [Fixnum] Shell text color id for black.
      #
      # @!attribute COLOR_RED [r]
      #   @return [Fixnum] Shell text color id for red.
      #
      # @!attribute COLOR_GREEN [r]
      #   @return [Fixnum] Shell text color id for green.
      #
      # @!attribute COLOR_ORANGE [r]
      #   @return [Fixnum] Shell text color id for orange.
      #
      # @!attribute COLOR_BLUE [r]
      #   @return [Fixnum] Shell text color id for blue.
      #
      # @!attribute COLOR_MAGENTA [r]
      #   @return [Fixnum] Shell text color id for magenta.
      #
      # @!attribute COLOR_CYAN [r]
      #   @return [Fixnum] Shell text color id for cyan.
      #
      # @!attribute COLOR_WHITE [r]
      #   @return [Fixnum] Shell text color id for WHITE.
      TEXT_BLACK   = 30
      TEXT_RED     = 31
      TEXT_GREEN   = 32
      TEXT_ORANGE  = 33
      TEXT_BLUE    = 34
      TEXT_MAGENTA = 35
      TEXT_CYAN    = 36
      TEXT_WHITE   = 37

      #
      # @!attribute BACKGROUND_BLACK [r]
      #   @return [Fixnum] Shell background color id for black.
      #
      # @!attribute BACKGROUND_RED [r]
      #   @return [Fixnum] Shell background color id for red.
      #
      # @!attribute BACKGROUND_GREEN [r]
      #   @return [Fixnum] Shell background color id for green.
      #
      # @!attribute BACKGROUND_ORANGE [r]
      #   @return [Fixnum] Shell background color id for orange.
      #
      # @!attribute BACKGROUND_BLUE [r]
      #   @return [Fixnum] Shell background color id for blue.
      #
      # @!attribute BACKGROUND_MAGENTA [r]
      #   @return [Fixnum] Shell background color id for magenta.
      #
      # @!attribute BACKGROUND_CYAN [r]
      #   @return [Fixnum] Shell background color id for cyan.
      #
      # @!attribute BACKGROUND_WHITE [r]
      #   @return [Fixnum] Shell background color id for WHITE.
      BACKGROUND_BLACK   = 40
      BACKGROUND_RED     = 41
      BACKGROUND_GREEN   = 42
      BACKGROUND_ORANGE  = 43
      BACKGROUND_BLUE    = 44
      BACKGROUND_MAGENTA = 45
      BACKGROUND_CYAN    = 46
      BACKGROUND_WHITE   = 47

      #
      # @!attribute EFFECT_NORMAL [r]
      #   @return [Fixnum] Shell effect id for normal text.
      #
      # @!attribute EFFECT_BOLD [r]
      #   @return [Fixnum] Shell effect id for bold text.
      #
      # @!attribute EFFECT_UNDERLINE [r]
      #   @return [Fixnum] Shell effect id for underlined text.
      #
      # @!attribute EFFECT_BLINK [r]
      #   @return [Fixnum] Shell effect id for blink text.
      #
      # @!attribute EFFECT_HIGHLIGHT [r]
      #   @return [Fixnum] Shell effect id for highlighted text.
      EFFECT_NORMAL    = 0
      EFFECT_BOLD      = 1
      EFFECT_UNDERLINE = 4
      EFFECT_BLINK     = 5
      EFFECT_HIGHLIGHT = 7

      #
      # @!attribute text [r]
      #   @return Shell text color id.
      #
      # @!attribute background [r]
      #   @return Shell background color id.
      #
      # @!attribute effect [r]
      #   @return Shell effect id.
      attr_reader :text, :background, :effect

      # Initialize color to default.
      # 
      # @param  text        [Fixnum]   Shell text color id.
      # @param  background  [Fixnum]   Shell background color id.
      # @param  effect      [Fixnum]   Shell effect id.
      def initialize(text = TEXT_BLACK, background = nil, effect = EFFECT_NORMAL)
        @text = text
        @background = background
        @effect = effect
      end

      # Read a color from a YAML configuration (itself from a configuration file).
      #
      # @param  color  [String, Fixnum, Hash{String => String, Fixnum}]   YAML color part.
      def read_from (color)
        if color.nil?
          return
        end

        if color.class == String || color.class == Integer
          @text = read_property(:text, color, @text)
        else
          @text       = read_property(:text,        color[:text],       @text)
          @background = read_property(:background,  color[:background], @background)
          @effect     = read_property(:effect,      color[:effect],     @effect)
        end
      end

      # Write the color to a YAML configuration (itself to a configuration file)
      #
      # @return YAML color part.
      def write_to
        return {
          'text'        =>  write_property(:text,       @text),
          'background'  =>  write_property(:background, @background),
          'effect'      =>  write_property(:effect,     @effect)
        }
      end

      # Get Shell notation for the color.
      #
      # @return [String] Shell notation.
      def to_shell_color
        if @text == STYLE_END
          return "\e[#{@text}m";
        end

        color = "\e[#{@effect};#{@text}"

        if !@background.nil?
          color = color + ";#{@background}"
        end

        return color + "m"
      end

      private
      # Get correct value of a "color" from YAML configuration (cf. read_from).
      #
      # @note If *property* is a String, Color will try to convert it to a shell id using "COLOR_*", "BACKGROUND_*" or "EFFECT_*" constants (according to *type* parameter).
      #
      # @param  type          [String]          The "type" of property to read. Must only be "color", "background" or "effect".
      # @param  property      [String, Fixnum]  The value to read.
      # @param  default_value [Fixnum]          The default value to use if *property* is not valid.
      # 
      # @return [Fixnum] The correct shell id.
      def read_property(type, property, default_value)
        if property.nil?
          return default_value
        end

        # If property is a number (always between 0 and 255 inclusive).
        if property.class == Integer || !(property.to_s =~ /^[[:digit:]]{1,3}$/).nil?
          return property
        end

        property_constant = "#{type.upcase}_#{property.upcase}"
        if Color.const_defined?(property_constant, false)
          return Color.const_get(property_constant, false)
        end

        print "Configuration: Unable to get property #{type} from \"#{property}\"\n"
        default_value
      end
      # Get correct value of a "color" to YAML configuration (cf. write_to).
      #
      # @note Color will try to convert *property* to a string using "COLOR_*", "BACKGROUND_*" or "EFFECT_*" constants (according to *type* parameter).
      #
      # @param  type      [String]  The "type" of property to read. Must only be "color", "background" or "effect".
      # @param  property  [Fixnum]  The value to read.
      # 
      # @return [String,Fixnum] The string according to property value, or his direct value
      def write_property(type, property)
        constants_array = Color.constants;
        constants = {}

        constant_start = "#{type.upcase}_"
        constants_array.each do |constant_name|
          if constant_name.to_s.start_with? constant_start
            constants[constant_name.slice(constant_start.length..-1)] = Color.const_get(constant_name)
          end
        end

        constant_name = constants.key(property)
        if constant_name.nil?
          return property
        else
          return constant_name
        end
      end
    end

  end

end

