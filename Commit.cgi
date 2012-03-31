#!/usr/bin/perl
# Variables: 
require 'dahdiHW-lib.pl';
use CGI qw(:standard);
# Get UID and GID for asterisk user
($name, $pass, $uid, $gid, $quota, $comment, $gcos, $dir, $shell) = getpwnam("asterisk");

ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

print ("<P>\n<h2>", $text{'Commit'},"</h2><P>\n<P>\n");


print ("<h4>Commit Information </h4><P>");
print ("<B>", $text{'CommitInfo0'}, "</B><P>");
print ($text{'CommitInfo1'}, "<P>");

# Backup system.conf to system.conf.bak
open (SYSTEMCONFBAK, '>/etc/dahdi/system.conf.bak');
my $lref = &read_file_lines('/etc/dahdi/system.conf');
# Prints each line of /etc/dahdi/system.conf
foreach my $line (@$lref) 
  {
  print SYSTEMCONFBAK ($line, "\n");
  }	
close (SYSTEMCONFBAK);
print ($text{'Done0'}, "<br>");

# Backup chan_dahdi_trunk.conf to chan_dahdi_trunk.conf.bak
open (CHANDAHDITRUNKBAK, '>/etc/asterisk/chan_dahdi_trunk.conf.bak');
my $lref = &read_file_lines('/etc/asterisk/chan_dahdi_trunk.conf');
# Prints each line of /etc/asterisk/chan_dahdi_trunk.conf
foreach my $line (@$lref) 
  {
  print CHANDAHDITRUNKBAK ($line, "\n");
  }	
close (CHANDAHDITRUNKBAK);
# Change file ownership from root to asterisk
chown ($uid, $gid, "/etc/asterisk/chan_dahdi_trunk.conf.bak"); 
print ($text{'Done1'}, "<br>");

# Backup chan_dahdi.conf to chan_dahdi.conf.bak
open (CHANDAHDIBAK, '>/etc/asterisk/chan_dahdi.conf.bak');
my $lref = &read_file_lines('/etc/asterisk/chan_dahdi.conf');
# Prints each line of /etc/asterisk/chan_dahdi.conf
foreach my $line (@$lref) 
  {
  print CHANDAHDIBAK ($line, "\n");
  }	
close (CHANDAHDIBAK);
# Change file ownership from root to asterisk
chown ($uid, $gid, "/etc/asterisk/chan_dahdi.conf.bak"); 
print ($text{'Done2'}, "<P>");

# Checks /etc/asterisk/chan_dahdi.conf, comments out #include dahdi_channels.conf, adds #include chan_dahdi_trunk.conf if not present
print ($text{'CommitInfo2'}, "<P>");
open (CHANDAHDI, '>/etc/asterisk/chan_dahdi.conf');
my $lref = &read_file_lines('/etc/asterisk/chan_dahdi.conf');
# Prints each line of /etc/asterisk/chan_dahdi.conf
foreach my $line (@$lref) 
  {
  $line =~ s/^(#include dahdi_channels.conf)/;#include dahdi_channels.conf/;  	#comments out dahdi_channels.conf
  print CHANDAHDI ($line, "\n");
  if ($line =~ /#include chan_dahdi_trunk.conf/) 	# check to see if this include is present
    {
    $CDT = 1 ; # flag it as present
    }
  }	
if (!$CDT) # if include is not present, add it to the end of the file
  {
  print CHANDAHDI ("#include chan_dahdi_trunk.conf\n");
  }  
close (CHANDAHDI);
print ($text{'Done3'}, "<br>");
print ($text{'Done4'}, "<P>");

# Updates system.conf and chan_dahdi_trunk.conf with new configuration
print ($text{'CommitInfo3'}, "<p>");
# Updates system.conf
open (SYSTEMCONF, '>/etc/dahdi/system.conf');
my $lref = &read_file_lines('/etc/dahdi/system.conf.temp');
# Prints each line of /etc/dahdi/system.conf.temp
foreach my $line (@$lref) 
  {
  print SYSTEMCONF ($line, "\n");
  }	
close (SYSTEMCONF);
print ($text{'Done5'}, "<br>");

# updates chan_dahdi_trunk.conf
open (CHANDAHDITRUNK, '>/etc/asterisk/chan_dahdi_trunk.conf');
my $lref = &read_file_lines('/etc/asterisk/chan_dahdi_trunk.conf.temp');
# Prints each line of /etc/asterisk/chan_dahdi_trunk.conf.temp
foreach my $line (@$lref) 
  {
  print CHANDAHDITRUNK ($line, "\n");
  }	
close (CHANDAHDITRUNK);
print ($text{'Done6'}, "<p>");

# Stop asterisk, stop dahdi, stop Wanrouter if exists, start wanrouter if exists, start dahdi, start asterisk
# Wanrouter is required for Sangoma cards, if there aren't any Sangoma cards it won't matter.
print ($text{'CommitInfo4'}, "<p>");
print ($text{'Done7'});
stop_pbx();  				# stops asterisk, runs "amportal kill"
#$dummy = sleep(3);			# pause for 3 seconds
print ($text{'Done8'});
stop_dahdi(); 			# run  "/etc/init.d/dahdi stop"
#restart_Wanrouter();			# restarts Wanrouter for Sangoma cards
start_dahdi();			# starts dahdi "/etc/init.d/dahdi start"
print ($text{'Done9'});
start_pbx(); 				# starts asterisk "amportal start"

print ($text{'CommitInfo5'}, "<p>");	# runs asterisk CLI command "dahdi show channels" to verify configuration success
print ($text{'Done10'}, "<p>");		# prints to screen output
dahdi_show_channels();			# runs - asterisk -rx "dahdi show channels"
print ($text{'CommitInfo6'}, "<p>");


#Print return to mainmenu link
print (ui_nav_link(left, "index.cgi", 0), "<B><a href=\"index.cgi\">", $text{'ReturnToDahdiHW'}, "</a></b><p>\n");
ui_print_footer("/", $text{'index'});

