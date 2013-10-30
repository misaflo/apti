#!/usr/bin/env ruby
# encoding: utf-8

module Config

  # Shell colors code.
  class Color
    COLOR_END   = 0
    COLOR_GREY  = 30
    COLOR_RED   = 31
    COLOR_GREEN = 32

    #
    # @!attribute install
    #   @return [String,Fixnum] Color of install.
    #
    # @!attribute remove
    #   @return [String] Color of remove.
    #
    # @!attribute description
    #   @return [String] Color of description.
    #
    # @!attribute end [r]
    #   @return [String] Constant for stopping color.
    attr_reader :install, :remove, :description
  end
end
