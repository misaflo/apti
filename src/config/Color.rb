#!/usr/bin/env ruby
# encoding: utf-8

module Config

  # Shell colors code.
  class Color
    # @!attribute install
    #   @return [String] Color of install.
    #
    # @!attribute remove
    #   @return [String] Color of remove.
    #
    # @!attribute description
    #   @return [String] Color of description.
    #
    # @!attribute end [r]
    #   @return [String] Constant for stopping color.

    attr_accessor :install, :remove, :description

    attr_reader :end
  end
end
