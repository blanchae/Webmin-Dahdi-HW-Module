#!/usr/bin/perl
# Variables: 
require 'dahdiHW-lib.pl';
use CGI qw(:standard);

#html forms parameters passed 

$DahdiDevice = 0 ;				# Initialize no spans configured
$DahdiDevice = param('DahdiDevice');	# Keep track of the span number for each configuration
$Go2Global = param('Go2Global');	       # Flag to let us know that it's time to go config the Global variables
$Loadzone = param('Loadzone');		# Global variable Loadzone
$Defaultzone = param('Defaultzone');	# Global variable Defaultzone
$CardType = param('CardType');		# Cardtype: FX, PRI or DYN for FXO/FXS, E1/T1/BRI or Dynamic respectively
$ChRange1 = param('ChRange1');		# Channel ranges for FXO/FXS cards
$ChRange2 = param('ChRange2');
$ChRange3 = param('ChRange3');
$ChRange4 = param('ChRange4');
$ChRange5 = param('ChRange5');
$ChRange6 = param('ChRange6');
$ChRange7 = param('ChRange7');
$ChRange8 = param('ChRange8');
$FXPort1 = param('FXPort1');		# FX port type for FXO/FXS cards
$FXPort2 = param('FXPort2');
$FXPort3 = param('FXPort3');
$FXPort4 = param('FXPort4');
$FXSignaling1 = param('FXSignaling1');	# Signaling for FXO/FXS cards
$FXSignaling2 = param('FXSignaling2');
$FXSignaling3 = param('FXSignaling3');
$FXSignaling4 = param('FXSignaling4');
$FXEcho1 = param('FXEcho1');		# Echocanceller for FXO/FXS cards
$FXEcho2 = param('FXEcho2');
$FXEcho3 = param('FXEcho3');
$FXEcho4 = param('FXEcho4');
$ISDN = param('ISDN');			# E1, T1 or BRI
$ISDN2 = param('ISDN2');			# E1 or T1 for Dynamic span
$Timing = param('Timing');			# Timing for PRI and DYN cards
$LBO = param('LBO');				# Line Build-up for E1/T1/BRI
$Framing = param('Framing');		# Framing for PRI cards
$Coding = param('Coding');			# Coding for PRI cards
$CRC4 = param('CRC4');			# CRC4 for E1 option
$Yellow = param('Yellow');			# Yellow alarm option
$bchan1 = param('bchan1');			# bchan range
$bchan2 = param('bchan2');
$bchan3 = param('bchan3');
$bchan4 = param('bchan4');
$dchan = param('dchan');			# dchan
$Review = param('Review');			# Flag to Review config then Commit
$PRIEcho = param('PRIEcho');		# PRI echocancellor
$Group1 = param('Group1');			# Group settings
$Group2 = param('Group2');
$Group3 = param('Group3');
$Group4 = param('Group4');
$SwitchType = param('SwitchType');		# Switchtype: national, dms100, 4ess, 5ess, euroisdn, ni1, qsig
$DYN = param('DYN');				# Dynamic span
$ETH = param('ETH');				# Ethernet port #
$SUB = param('SUB');				# Dynamic subinterface
$MAC1 = param('MAC1');			# 1st byte of MAC address in hex
$MAC2 = param('MAC2');			# 2nd byte and so on
$MAC3 = param('MAC3');
$MAC4 = param('MAC4');
$MAC5 = param('MAC5');
$MAC6 = param('MAC6');
$Commit = param('Commit');			#Used for final commit of changes


ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

print ("<P>\n<h2>", $text{'CreatingConfig'},"</h2><P>\n<P>\n");

# Using a hidden form to pass info back to this cgi script
   print ("<form action=\"CreatingConfig.cgi\" method=\"post\">\n");

if($Review)  #Getting down to the wire and ready to review
{
print ("<h4>Final Review before Commit</h4><P>");
print ("<b>", $text{'ReviewSystemConf'}, "</b><P>");
open (TRUNKTEMP2, '>>/etc/dahdi/system.conf.temp');
print TRUNKTEMP2 ("\n\n# Global data\n\n");
print TRUNKTEMP2 ("loadzone = ", $Loadzone, "\n");
print TRUNKTEMP2 ("defaultzone = ", $Defaultzone, "\n");
close (TRUNKTEMP2);
Review_SystemConf();
Review_ChanDahdiTrunk();
  print ("<h4>Commit Information </h4><P>");
print ($text{'CommitInfo'}, "<P>");
print ($text{'CommitInfo1'}, "<br>");
print ($text{'CommitInfo2'}, "<br>");
print ($text{'CommitInfo3'}, "<br>");
print ($text{'CommitInfo4'}, "<br>");
print ($text{'CommitInfo5'}, "<p>");
print ($text{'CommitInfo6'}, "<p>");
#print ("<input type=\"hidden\" name=\"Commit\" value=\"1\" />");
#print ("<input type=\"submit\" name=\"\" value=\"", $text{'Commit'}, "\"><P> ");
#Print Commit link
print (ui_nav_link(right, "Commit.cgi", 0), "<B><a href=\"Commit.cgi\">", $text{'Commit'}, "</a></b><P>\n ");
}
else
{
if($DahdiDevice)  # we are configuring dahdi devices
  {
  if ($DahdiDevice > 1) # If greater than 1 start printing to the temp file
    {
    Update_SystemConfTemp();  # This prints to the temp file /etc/dahdi/system.conf.temp and displays the content on the gui
    Update_ChanDahdiTrunk(); # This prints to the temp file /etc/asterisk/chan_dahdi_trunk.conf.temp and displays the content on the gui
    }
  if ($Go2Global) # Go to configure the global settings
    {
    print ("<P>\n<h3>", $text{'CreatingConfigGlobal'},"</h3><P>\n<P>\n");
    printGlobal();
    #Print Review and Submit link
	# The following prints the submit button and passes the dahdi device number
	print ("<input type=\"hidden\" name=\"Review\" value=\"1\" />");
	print ("<input type=\"submit\" name=\"\" value=\"", $text{'ReviewSubmit'}, "\"><P> ");

    }
  else
    {
    $Go2Global = 0;		# set some variables to 0 
    $Review = 0;

    if ($DahdiDevice)
	{
   	print ("<P><B>Configure Dahdi Span #", $DahdiDevice, "</b><P>\n" );
	print ($text{'SelectCard'}, "<p>\n");

	# Prints FXO/FXS menu
	print ("<img src=\"images/rd_tri.gif\"> <input  type=\"radio\" name=\"CardType\" value=\"FX\"> <B>FXO/FXS card</B>  (Default Choice)<P>\n");
	printFX();  # prints FXO/FXS configuration menu

	#Configure E1/T1/BRI devices
	print ("<img src=\"images/rd_tri.gif\"> <input  type=\"radio\" name=\"CardType\" value=\"PRI\"> <B>E1/T1/BRI ISDN card</B><P>\n");
	printISDN(); # prints E1/T1/BRI configuration menu


	#Configure Dynamic devices - Experimental
	#print ("<img src=\"images/rd_tri.gif\"> <input  type=\"radio\" name=\"CardType\" value=\"DYN\"> <B>Dynamic Spans</B><P>\n");
	#printDYN(); # prints Dynamic configuration menu


       print ("<P><HR><P>");
	$DahdiDevice = $DahdiDevice + 1;
	# The following prints the submit button and passes the dahdi device number
	print ("<input type=\"hidden\" name=\"DahdiDevice\" value=\"", $DahdiDevice, "\" />");
	print ("<input type=\"submit\" name=\"\" value=\"", $text{'SelectNextDevice'}, "\"><P> ");
	print ($text{'Go2Global2'}, "<p>\n");
	# The following prints the Go to Global button and passes the Go2Global variable
	print ("<input type=\"submit\" name=\"Go2Global\" value=\"", $text{'Go2Global'}, "\"> ");
	}
    }
  }
else  #First time through
  {
  $DahdiDevice = 1; 	# set to the first one and ask to check how many devices to be configured?
  print ($text{'CreatingConfigInfo'},"<P>\n");
  print ($text{'CreatingConfigNotes'},"<P>\n");
  print ($text{'MaxDeviceInfo'}, "<P>");
  print ("<img src=\"images/DahdiDevices.jpg\"><p> ");
  #create a temporary /etc/dahdi/system.conf.temp file
  open (SYSTEMCONFTEMP, '>/etc/dahdi/system.conf.temp');
  print SYSTEMCONFTEMP ("# ", $text{'WriteConfHeading'}, "\n");
  close (SYSTEMCONFTEMP);
  #create a temporary /etc/asterisk/chan_dahdi_trunk.conf.temp file
  open (TRUNKTEMP, '>/etc/asterisk/chan_dahdi_trunk.conf.temp');
  print TRUNKTEMP ("; ", $text{'WriteConfHeading'}, "\n");
  print TRUNKTEMP ("; ", $text{'ChanDahdiTrunkInfo'}, "\n");
  print TRUNKTEMP ("; ", $text{'ChanDahdiTrunkInfo1'}, "\n");
  close (TRUNKTEMP);
  print ("<input type=\"hidden\" name=\"DahdiDevice\" value=\"", $DahdiDevice, "\" />");
  print ("<input type=\"submit\" name=\"\" value=\"", $text{'SelectFirstDevice'}, "\"> ");
  }
}

print ("</form><P>");
#Print Checking for Dahdi devices
print (ui_nav_link(left, "FoundDevices.cgi", 0), "<B><a href=\"FoundDevices.cgi\">", $text{'FoundDevices'}, "</a></b><p>\n");
#Print return to mainmenu link
print (ui_nav_link(left, "index.cgi", 0), "<B><a href=\"index.cgi\">", $text{'ReturnToDahdiHW'}, "</a></b><p>\n");
ui_print_footer("/", $text{'index'});
