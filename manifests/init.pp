# Class: graphical_client
# ===========================
#
# Full description of class graphical_client here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `disable_lock_screens`
#  Three types of similar lock scrren, lock, screensaver and shield.  Disable these all on systems
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# Examples
# --------
#
# @example
#    class { 'graphical_client':
#      disable_clock_screens => false,
#    }
#
# Authors
# -------
#
# Sean Brsbane <sean.brisbane@securelinx.com>
#
# Copyright
# ---------
#
# Copyright 2019 Sean Brisbane, unless otherwise noted.
#
class graphical_client ( $disable_lock_screens = false ) {
   
   # kernel for nvidia
   ensure_packages (["xcb-util-keysyms.i686", "xcb-util-keysyms", "kernel-devel"])
	exec { 'dconfupdate' :
	    command     => '/usr/bin/dconf update',
	    refreshonly => true,
	}

  
   #Note, module does not support adding new RHEL6 only maintaining
   if $facts['os']['release']['major'] != '6'
   {

       yumgroup { "graphical-server-environment": ensure => "present"}
       ensure_packages (['dconf.x86_64', 'dconf.i686', 'dconf-editor'])    
       ensure_packages (['xorg-x11-fonts-ISO8859-1-75dpi', 'xorg-x11-fonts-misc', 'xorg-x11-fonts-ISO8859-1-100dpi', 'xorg-x11-fonts-100dpi', 'ucs-miscfixed-fonts', 'vlgothic-fonts', 'dejavu-serif-fonts', 'dejavu-sans-mono-fonts', 'xorg-x11-apps'] )


	#doesnt work runlevel { 'graphical': persist => true }
	if $disable_lock_screens {
	  $ensure_lock_suppression = present #"puppet:///modules/$name/dconf-db-01-screenlocks"
	  $ensure_shield_suppression = present #"puppet:///modules/$name/autostart.inhibit-idle-shield"
	}
	else {
	  $ensure_lock_suppression   = "absent"
	  $ensure_shield_suppression = "absent"
	}
	file {'/etc/dconf/db/local.d/02-animations':
	   source => "puppet:///modules/$name/dconf-db-02-animations",
	    mode   => "0644",
	    notify => Exec['dconfupdate'],
	    ensure => "$ensure_lock_suppression"
	}
	file {'/etc/dconf/db/local.d/03-local-tweaks':
	  source => "puppet:///modules/$name/dconf-db-03-local-tweaks",
	  mode   => "0644",
	  notify => Exec['dconfupdate'],
	  ensure => "$ensure_lock_suppression"
	}

	file { '/etc/dconf/db/local.d/01-screenlocks':
	  source => "puppet:///modules/$name/dconf-db-01-screenlocks",
	  mode   => "0644",
	  notify => Exec['dconfupdate'], 
	  ensure => "$ensure_lock_suppression"
	 }
	#there is a screen saver, a screen lock AND a screen shield
	# This setting should just cause a session never to become idle
	file { "/etc/xdg/autostart/10-inhibit-idle-shield":
	 source => "puppet:///modules/$name/autostart.inhibit-idle-shield",
	 mode   => "0644",
	 ensure => "$ensure_shield_suppression"
	}     
	   
   #From https://www.reddit.com/r/Puppet/comments/455gst/using_puppet_to_do_a_dconf_load/

    #scrollbars in reveal requre TraditionalOK theme here
    ensure_packages (["mate-themes"])
    file {'/etc/dconf/db/local.d/04-mate-themes':
      source => "puppet:///modules/$name/dconf-db-04-mate-themes",
      mode   => "0644",
      notify => Exec['dconfupdate'],
      ensure => "$ensure_lock_suppression"
    }
  }#!RHEL6
  file { '/etc/cron.d/gmetric_nvidia' :
      source => "puppet:///modules/$name/cron.d.gmetric_nvidia"
  }
}

