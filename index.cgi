#!/usr/bin/perl
# Webmin module to aid in configuring Dahdi drivers for Asterisk
# Typically under the PBX in a Flash distribution
# Expects the following directories:
# Dahdi config directory: /etc/dahdi
# Dahdi config files: system.conf, modules
# Asterisk config directory: /etc/asterisk
# Asterisk config files: chan_dahdi.conf, chan_dahdi_trunks.conf
# Version 0.90
# Author: Eugene Blanchard eugene.blanchard@sait.ca
# Use at your own risk!
# Brute force coder - usually pretty simple methods used as I'm not too smart...

require 'dahdiHW-lib.pl';

MAIN:
{
#print &PrintHeader;
ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

# Prints hostname of server
$hostname=get_system_hostname(1);
print ("<P>\n<h2>Configuring ", $hostname," Server</h2><P>\n<P>\n");
print ("Dahdi HW Config Version 0.97.1<P>");
# Print and check Webmin version - need 1.510 or better
$WebminVersion = get_webmin_version();

# Only works with Webmin version 1.510 and up so better check for it!

if ($WebminVersion < 1.510)
 {
 print ($text{'WebminVersion'}, ' <B>', $WebminVersion ,"</b><p>\n");
 print $text{'OldVersion'};
 }
else
 {
  # Print dahdi version
  open_execute_command(DAHDI_VER, 'modinfo dahdi', 1, 0);
  print "<B>Detected Dahdi ";
  foreach my $line (<DAHDI_VER>) 
   {
   if ($line =~ m/^version/m )
   #matches the beginning of a line with option /m - this is to stop "srcversion" from appearing
    {
    # Print the line to the screen and add a newline
    print "$line\n";
    }    
   }
 print ("</B><P>");
# Print instructions to remove FreePBX Dahdi module ###############
 print ($text{'RemoveFreePBXDahdiModule'});
 print ("</B><P>", $text{'welcome'});
 print ($text{'FoundDevicesWarning'}, "<P>");
 print ("<b><img src=\"images/rd_tri.gif\"> <b>Step 1.</b> ", "<a href=\"SystemModules.cgi\">", $text{'SystemModules'}, "</a></b><p>" );
 print ($text{'SystemModulesBrief'}, "<P>");
 print ("<b><img src=\"images/rd_tri.gif\"> <b>Step 2.</b> ", "<a href=\"FoundDevices.cgi\">", $text{'FoundDevices'}, "</a></b><P>" );
 print ($text{'FoundDevicesInfo'}, "<P>");
 print ("<b><img src=\"images/rd_tri.gif\"> <b>Step 3.</b> ", "<a href=\"CreatingConfig.cgi\">", $text{'CreatingConfig'}, "</a></b><P>" );
 print ($text{'CreatingConfigInfo'}, "<P>");
# print ("<b><img src=\"images/rd_tri.gif\"> <b>Step 3.</b> ", "<a href=\"CreatingHWConfig.cgi\">", $text{'CreatingHWConfig'}, "</a></b><P>" );
# print ($text{'CreatingHWConfigInfo'}, "<P>");
# print ("<b><img src=\"images/rd_tri.gif\"> <b>Step 4.</b> ", "<a href=\"CreatingSWConfig.cgi\">", $text{'CreatingSWConfig'}, "</a></b><P>" );

 print ("<P>" );
 }

# Going to have to think about where to put this code for reloading Asterisk/Dahdi
#Stop asterisk, reload dahdi, start asterisk
# print ("<HR><P><H2>", $text{'RestartDahdiTitle'}, "</h2><P>");
# print ($text{'RestartDahdiWarning'}, "<P>");
# print ($text{'RestartDahdiInfo'}, "<P>");
#open_execute_command(AMP-STOP, 'amportal stop', 1, 0);
#print "<B>amportal Stop:</B><P>";
#while(<AMP-STOP>)
# {
 # Print the line to the screen and add a newline
# print "$_<P>\n";
# }


ui_print_footer("/", $text{'index'});
#print &PrintFooter;
}