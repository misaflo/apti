#!/usr/bin/env ruby
# encoding: utf-8

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
