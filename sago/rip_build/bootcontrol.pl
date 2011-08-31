#!/usr/bin/perl -w



########################################################## {COPYRIGHT-TOP} ###

# Licensed Materials - Property of IBM

# Bootcontrol

#

# (C) Copyright IBM Corp. 2005, 2006

#

# US Government Users Restricted Rights - Use, duplication, or

# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

########################################################## {COPYRIGHT-END} ###



# IBM developerWorks

# mcarter@uk.ibm.com, phil.willoughby@uk.ibm.com



use strict;



if (scalar @ARGV != 2 or $ARGV[0] eq "-h" or $ARGV[0] eq "--help" or $ARGV[0] eq "/?") {

  print <<END_OF_HELP;

Usage:

        $0 <grub-config-file> <platform-title>

Where

  grub-config-file   the path to the menu.lst or grub.conf you want to edit.

  platform-title     a substring of the grub name of the image you wish to

                     boot.



You may specify an integer rather than a string for the platform-title argument;

in this case that number will be used as the grub menu option to boot.

END_OF_HELP

  exit 1;

}



#

# 1. Read in parameters

#

my $config_file_name = $ARGV[0];

my $platform_tag = $ARGV[1];



#

# 2. Read in GRUB file

#

if (!open GRUB_CONFIG_FILE, "<$config_file_name") {

  $! = 2;

  die "ERROR: Could not open target config file for reading.\n";

}



my @grub_config_file = <GRUB_CONFIG_FILE>;

close GRUB_CONFIG_FILE;



my $desired_target = undef;

my $default_target_line = undef;

my $current_target = undef;

my $menu_options_seen = 0;



if ( $platform_tag =~ m/^\d+$/ ) {

  # If we specified a number then preset that

  $desired_target = $platform_tag 

}



#

# 3. Parse each line to set $default_target_line and $desired_target

#

foreach my $line (@grub_config_file)

{

 

  # Remember which line sets the default. 

  if ( $line =~ m/^default/ ) {

    $default_target_line = \$line;

    ($current_target) = $line =~ m/default\s+(\d+)/;

  }

  

  # If we need to search

  unless ( defined($desired_target) ) {

    # If we have a new stanza

    if ($line =~ m/^title/) {

      # If the title matches our tag

      if ($line =~ m/$platform_tag/i) {

      	$desired_target = $menu_options_seen;

      }

      ++$menu_options_seen;      

    } # end if matched new stanza

  } # end unless defined target_number

  

} # end foreach line



#

# 4. Sanity checking

#

if ( !defined($desired_target) ) {

  $! = 3;

  die "ERROR: Could not find menu item to switch to.\n";

}



if ( !defined($default_target_line) ) {

  $! = 4;

  die "ERROR: Could not find a default menu item entry to change.\n";

}



if ( $desired_target == $current_target ) {

  warn "INFO: Default not changed\n";

  exit 0;

}







#

# 5. Write updated file

#



# Update the default

$$default_target_line = "default $desired_target\n";



if ( !open GRUB_CONFIG_FILE, ">$config_file_name" ) {

  $! = 5;

  die "ERROR: Could not open target config file for writing.\n";

}



print GRUB_CONFIG_FILE @grub_config_file;

close GRUB_CONFIG_FILE;



exit 0;

    } # end if matched new stanza

  } # end unless defined target_number

  

} # end foreach line



#

# 4. Sanity checking

#

if ( !defined($desired_target) ) {

  $! = 3;

  die "ERROR: Could not find menu item to switch to.\n";

}



if ( !defined($default_target_line) ) {

  $! = 4;

  die "ERROR: Could not find a default menu item entry to change.\n";

}



if ( $desired_target == $current_target ) {

  warn "INFO: Default not changed\n";

  exit 0;

}







#

# 5. Write updated file

#



# Update the default

$$default_target_line = "default $desired_target\n";



if ( !open GRUB_CONFIG_FILE, ">$config_file_name" ) {

  $! = 5;

  die "ERROR: Could not open target config file for writing.\n";

}



print GRUB_CONFIG_FILE @grub_config_file;

close GRUB_CONFIG_FILE;



exit 0;
