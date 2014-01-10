# Description

Apti is a frontend of aptitude (Debian's package manager) with improved presentation of packages.

It uses the same commands as aptitude, and allow you to use it without superuser rights (the sudo or root password is asked if needed).

The improved commands are: `install`, `remove`, `purge`, `safe-upgrade`, `full-upgrade` and `search`.

# Installation

Dependencies:

* aptitude (of course)
* ruby >= 1.9 (may work with ruby1.8, but not tested)
* ruby-i18n

Put apti in /usr/local/, and create a link to main.rb: `ln -s /usr/local/apti/main.rb /usr/local/bin/apti`

# Screenshots

![command apti install](http://gnux.legtux.org/src/images/scripts/apti_install.png "command apti install")

![command apti safe-upgrade](http://gnux.legtux.org/src/images/scripts/apti_safe_upgrade.png "command apti safe-upgrade")

![command apti search](http://gnux.legtux.org/src/images/scripts/apti_search.png "command apti search")

