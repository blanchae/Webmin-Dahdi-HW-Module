#!/usr/bin/perl

require 'dahdiHW-lib.pl';

use CGI qw(:standard);
$DahdiDevice = param('DahdiDevice');

ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

# The following allows a link to submit a hidden form value
# In this case it is used to pass the dahdi process number to create a new page
# that will display "cat /proc/dahdi/<process number>"
print ("<form action=\"FoundDevices.cgi\" method=\"post\">\n");
# Prints page name

print ("<P>\n<h2>", $text{'FoundDevices'},"</h2><P>\n<P>\n");

if ($DahdiDevice)
 {
 open_execute_command(DAHDIPROC, 'cat /proc/dahdi/$DahdiDevice', 1, 0);
 print ("<B>Dahdi Device: ", $DahdiDevice, "</B><P>");
 while(<DAHDIPROC>)
  {
  # Print the line to the screen and add a newline
  print "$_<P>\n";
  }
 #Print return to mainmenu link
 print (ui_nav_link(left, "FoundDevices.cgi", 0), "<B><a href=\"FoundDevices.cgi\">", $text{'FoundDevicesReturn'}, "</a></b><P>  ");
 ui_print_footer("/", $text{'index'});

 }
else
{
print ($text{'FoundDevicesExplanation'},"<P>\n");
print ("<blockqoute>", $text{'FoundDevicesWarning'},"</blockquote><P>\n");

#This command executes dahdi_scan and writes to the hash SCANNEDDEVICES immediately
open_execute_command(SCANNEDDEVICES, dahdi_scan, 1, 0);

 @Dahdi_Devices = ("Test OK!");
 $ArrayCount = 1; #Start count for filling array
 $DeviceCount = 1;
while(<SCANNEDDEVICES>)
 {

# $Devicetype = $_ ; # stores the devicetype= information
$Description = $_ ; # stores the description= information
# $BaseChannel = $_ ; # stores the basechan= information
# $TotalChannels = $_; # stores the totchans= information


# search for "description=" on a single line globally. Returns all lines with "devicetype=" in $string
 while ($Description =~  /\[/sg )  # description
 { 
 $Dahdi_Devices[$ArrayCount] = "$'" ;
# Using a hidden form to pass info back to this cgi script
print ("<img src=\"images/rd_tri.gif\"> <B> Span ",  $DeviceCount, "</b><br>");
  $ArrayCount = $ArrayCount + 1;
  $DeviceCount = $DeviceCount +1;
  }
  print "$_<P>\n";
# search for "devicetype=" on a single line globally. Returns all lines with "devicetype=" in $string
# while ($Devicetype =~  /devicetype=/sg )  # devicetype
#  {
#  $Dahdi_Devices[$ArrayCount] = "$'" ;   
#  print (" - Card Model = ", $Dahdi_Devices[$ArrayCount], "<br>");
#  $ArrayCount = $ArrayCount + 1;
#  }
# search for "basechan=" on a single line globally. Returns all lines with "devicetype=" in $string
# while ($BaseChannel =~  /basechan=/sg )  # basechan
# { 
#  $Dahdi_Devices[$ArrayCount] = "$'" ;
#  print (" - Base Channel = ", $Dahdi_Devices[$ArrayCount], "<br>");
#  $ArrayCount = $ArrayCount + 1;
#  }
# search for "totchans=" on a single line globally. Returns all lines with "devicetype=" in $string
# while ($TotalChannels =~  /totchans=/sg )  # totchans
#  {
#  $Dahdi_Devices[$ArrayCount] = "$'" ;
#  print (" - Total Channels = ", $Dahdi_Devices[$ArrayCount], "<br>");
#  $ArrayCount = $ArrayCount + 1 ;               # keep track of occurence
# The following prints the submit button and passes the dahdi device number
#  print ("<input type=\"hidden\" name=\"DahdiDevice\" value=\"", $DeviceCount-1, "\"><br> <input type=\"submit\" value=\"Click for more Info for Dahdi ", $DeviceCount-1, "\"> </form><P>");
  }
print ("</form><P>");
#open_execute_command(DAHDIHARDWARE, dahdi_hardware, 1, 0);
#print "<B>dahdi_hardware</B><P>";
#while(<DAHDIHARDWARE>)
 #{
 # Print the line to the screen and add a newline
 #print "$_<P>\n";
 #}
print ($text{'FoundDevicesPrint'}, "<P>");
#Print return to mainmenu link
print (ui_nav_link(left, "index.cgi", 0), "<B><a href=\"index.cgi\">", $text{'ReturnToDahdiHW'}, "</a></b><P>  ");
ui_print_footer("/", $text{'index'});
}

