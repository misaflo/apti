# Description

Apti is a frontend of aptitude (Debian's package manager) with improved presentation of packages.

It uses the same commands as aptitude, and allow you to use it without superuser rights (the sudo or root password is asked if needed).

The improved commands are: `install`, `remove`, `purge`, `safe-upgrade`, `full-upgrade` and `search`.

RSS feed of versions: https://gitorious.org/apti/apti/raw/stable:changelog.xml

# Installation

## With git

Dependencies:

* aptitude (of course)
* ruby >= 1.9
* ruby-i18n

    git clone -b stable git://gitorious.org/apti/apti.git /usr/local/
    ln -s /usr/local/apti/bin/apti /usr/local/bin/apti

## With rubygems

    gem install apti

# Configuration

Configuration file is in ~/.config/apti (by default).

* colors:
    * available colors are: BLACK, RED, GREEN, ORANGE, BLUE, MAGENTA, CYAN and WHITE.
    * available effects are: NORMAL, BOLD, UNDERLINE, BLINK and HIGHLIGHT.
* display_size: displaying size of packages or not (default true).
* spaces:
    * columns: between columns in `install`, `remove`, `upgrade`.
    * unit: juste before size's unit.
    * search: between package name and description.
* no_confirm: if true, don't ask for the aptitude's confirmation.

# Screenshots

![command apti install](http://gnux.legtux.org/src/images/scripts/apti_install.png "command apti install")

![command apti safe-upgrade](http://gnux.legtux.org/src/images/scripts/apti_safe_upgrade.png "command apti safe-upgrade")

![command apti search](http://gnux.legtux.org/src/images/scripts/apti_search.png "command apti search")

