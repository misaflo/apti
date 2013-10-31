#!/usr/bin/env ruby
# encoding: utf-8

module Apti

  # Debian package.
  class Package
    # @!attribute name
    #   @return [String] Name of the package.
    #
    # @!attribute version_old
    #   @return [String] Old / current version of the package.
    #
    # @!attribute version_new
    #   @return [String] New version of the package.
    #
    # @!attribute size_before_decimal
    #   @return [String] Size of the package, before the decimal.
    #
    # @!attribute size_after_decimal
    #   @return [String] Size of the package, after the decimal.
    #
    # @!attribute size_unit
    #   @return [String] Size's unit (B, kB, ...)

    attr_accessor :name, :version_old, :version_new,
      :size_before_decimal, :size_after_decimal, :size_unit
  end

end
