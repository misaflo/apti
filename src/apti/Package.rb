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

  # Debian package.
  class Package
    # @!attribute name
    #   @return [String] Name of the package.
    #
    # @!attribute parameter
    #   @return [String] Aptitude's information : a, u, p, i, ...
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
    #   @return [String] Size's unit (B, kB, ...).
    #
    # @!attribute description
    #   @return [String] Description of the package.

    attr_accessor :name, :parameter, :version_old, :version_new,
      :size_before_decimal, :size_after_decimal, :size_unit,
      :description
  end

end
