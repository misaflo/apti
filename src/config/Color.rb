#!/usr/bin/env ruby
# encoding: utf-8

module Config
  class Color
    COLOR_GREY  = 30
    COLOR_RED   = 31
    COLOR_GREEN = 32

    attr_reader :install, :remove, :description
  end
end

