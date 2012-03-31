=head1 dahdiHW-lib.pl

Functions for managing the Dahdi HW configuration file.
Ver 0.10
Date July 2010
Author Eugene Blanchard

=cut

BEGIN { push(@INC, ".."); };
use WebminCore;
init_config();

=head2 write_modules(Dahdi1, Dahdi2, Dahdi3, Dahdi4, DateTime)

After ModOrder.cgi configures the new order of dahdi drivers, it is sent back to SystemModules.cgi which adds 
a time stamp: DateTime and calls this subroutine. This subroutine copies the existing /etc/dahdi/modules as 
modules.bak and writes the new /etc/dahdi/module file with the first comment as the timestamp. Variables Dahdi1-4 
contain the dahdi driver names.

=cut

#sub write_modules(Dahdi1, Dahdi2, Dahdi3, Dahdi4, DateTime)
sub write_modules()
{
 my($Dahdi1, $Dahdi2, $Dahdi3, $Dahdi4, $DateTime) = @_;
 &rename_file('/etc/dahdi/modules','/etc/dahdi/modules.bak');
 open (MODULES, '>/etc/dahdi/modules');
 print MODULES ("#", $DateTime, "\n", $Dahdi1, "\n", $Dahdi2,"\n", $Dahdi3,"\n", $Dahdi4);
 close (MODULES);
}

=head3 restart_dahdi()

Restarts dahdi kernel service

=cut
sub restart_dahdi()
{
open_execute_command(DAHDI_RESTART, '/etc/init.d/dahdi restart', 1, 0);
print ("<B>", $text{'ServiceDahdiRestart'},"</B><p>");
while(<DAHDI_RESTART>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_RESTART);
print "<hr><P>";
}

=head4 stop_pbx()

Stops asterisks

=cut

sub stop_pbx()
{
open_execute_command(PBX_STOP, 'amportal kill', 1, 0);
print ("<B>", $text{'AsteriskStopped'},"</B><P><hr><P>");
#while(<PBX_STOP>)
# {
 # Print the line to the screen and add a newline
# print "$_<P>\n";
# }
close (PBX_STOP);
}

=head5 start_pbx()

Starts asterisk
=cut

sub start_pbx()
{
open_execute_command(PBX_START, 'amportal start', 1, 0);
print ("<B>", $text{'AsteriskStarted'},"</B><p>");
close (PBX_START);
}

=head6 reload_dahdi()

Reloads the dahdi configuration in Asterisk

=cut

sub reload_dahdi()
{
open_execute_command(DAHDI_RELOAD, 'asterisk -rx "dahdi reload"', 1, 0);
print ("<B>", $text{'DahdiReload'},"</B><P>");;
while(<DAHDI_RELOAD>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_RELOAD);
}

=head7 Update_SystemConfTemp()

Updates and Displays the current configuration of the /etc/dahdi/system.conf.temp file

=cut

sub Update_SystemConfTemp()
{
# Append to the temporary /etc/dahdi/system.conf.temp file
open (SYSTEMCONFTEMP, '>>/etc/dahdi/system.conf.temp');
# Checks if the card type has been selected. Defaults to FX
if ($CardType eq 'PRI')  # configuring PRI card
  {
  print SYSTEMCONFTEMP ("\n\n# Span ", $DahdiDevice - 1, " is a ", $ISDN, " card");
  print SYSTEMCONFTEMP ("\nspan=", $DahdiDevice - 1, ",", $Timing, ",");
  if ($ISDN eq 'BRI')
    {
    # BRI has a LBO of 0 
    print SYSTEMCONFTEMP ("0");
    }
  else
    {
    print SYSTEMCONFTEMP ($LBO);
    }
  print SYSTEMCONFTEMP (",", $Framing, ",", $Coding);
  if ($CRC4)
    {
    print SYSTEMCONFTEMP (",", $CRC4);	
    }
  if ($Yellow)
    {
    print SYSTEMCONFTEMP (",", $Yellow);	
    }
  if($bchan1)
    {
    print SYSTEMCONFTEMP ("\nbchan=", $bchan1);
    if($bchan2)
      {
      print SYSTEMCONFTEMP ("-", $bchan2);
      }
    }
  print SYSTEMCONFTEMP ("\ndchan=", $dchan);
  if($bchan3)
    {
    print SYSTEMCONFTEMP ("\nbchan=",$bchan3);
    if($bchan4)
      {
      print SYSTEMCONFTEMP ("-", $bchan4);
      }
    }
  if($bchan1)
    {
    print SYSTEMCONFTEMP ("\nechocanceller=", $PRIEcho, ",", $bchan1);
    if($bchan2)
      {
      print SYSTEMCONFTEMP ("-", $bchan2);
      }
    }
  if($bchan3)
    {
    print SYSTEMCONFTEMP ("\nechocanceller=", $PRIEcho, ",", $bchan3);
    if($bchan4)
      {
      print SYSTEMCONFTEMP ("-", $bchan4);
      }
    }



  }
elsif ($CardType eq 'DYN')    # configuring Dynamic Span
  {
  print SYSTEMCONFTEMP ("\n\n# Span ", $DahdiDevice - 1, " is a Dynamic Span");
  print SYSTEMCONFTEMP ("\ndynamic=eth,eth", $ETH, "/", $MAC1, ":", $MAC2, ":", $MAC3, ":", $MAC4, ":", $MAC5, ":", $MAC6, "/", $SUB, ",", $ISDN2, ",", $Timing);
  if($bchan1)
    {
    print SYSTEMCONFTEMP ("\n\nbchan=", $PRIEcho, ",", $bchan1);
    if($bchan2)
      {
      print SYSTEMCONFTEMP ("-", $bchan2);
      }
    }
  print SYSTEMCONFTEMP ("\ndchan=", $dchan);
  if($bchan3)
    {
    print SYSTEMCONFTEMP ("\nbchan=", $PRIEcho, ",", $bchan3);
    if($bchan4)
      {
      print SYSTEMCONFTEMP ("-", $bchan4);
      }
    }  
  }
else # configuring FXO/FXS card  - default
  { 
  print SYSTEMCONFTEMP ("\n\n# Span ", $DahdiDevice - 1);
  if ($FXPort1 eq 'unused')
    {
    print SYSTEMCONFTEMP ("\n", $FXPort1, "=", $ChRange1);
    if ($ChRange2)
      {
      print SYSTEMCONFTEMP ("-", $ChRange2);
      }
     }
  else
    {
    print SYSTEMCONFTEMP ("\n", $FXPort1, $FXSignaling1, "=", $ChRange1);
    if ($ChRange2)
      {
      print SYSTEMCONFTEMP ("-", $ChRange2);
      }
    print SYSTEMCONFTEMP ("\nechocanceller=", $FXEcho1, ",", $ChRange1);
    if ($ChRange2)
      {
      print SYSTEMCONFTEMP ("-", $ChRange2);
      }
    }
  if($ChRange3)
    {
    if ($FXPort2 eq 'unused')
      {
      print SYSTEMCONFTEMP ("\n", $FXPort2, "=", $ChRange3);
      if ($ChRange4)
        {
        print SYSTEMCONFTEMP ("-", $ChRange4);
        }
      }
    else
      {
      print SYSTEMCONFTEMP ("\n", $FXPort2, $FXSignaling2, "=", $ChRange3);
      if ($ChRange4)
        {
        print SYSTEMCONFTEMP ("-", $ChRange4);
        }
      print SYSTEMCONFTEMP ("\nechocanceller=", $FXEcho2, ",", $ChRange3);
      if ($ChRange4)
        {
        print SYSTEMCONFTEMP ("-", $ChRange4);
        }
      }
    }
  if($ChRange5)
    {
    if ($FXPort3 eq 'unused')
      {
      print SYSTEMCONFTEMP ("\n", $FXPort3, "=", $ChRange5);
      if ($ChRange6)
        {
        print SYSTEMCONFTEMP ("-", $ChRange6);
        }
      }
    else
      {
      print SYSTEMCONFTEMP ("\n", $FXPort3, $FXSignaling3, "=", $ChRange5);
      if ($ChRange6)
        {
        print SYSTEMCONFTEMP ("-", $ChRange6);
        }
      print SYSTEMCONFTEMP ("\nechocanceller=", $FXEcho3, ",", $ChRange5);
      if ($ChRange6)
        {
        print SYSTEMCONFTEMP ("-", $ChRange6);
        }
      }
    }
  if($ChRange7)
    {
    if ($FXPort4 eq 'unused')
      {
      print SYSTEMCONFTEMP ("\n", $FXPort4, "=", $ChRange7);
      if ($ChRange8)
        {
        print SYSTEMCONFTEMP ("-", $ChRange8);
        }
      }
    else
      {
      print SYSTEMCONFTEMP ("\n", $FXPort4, $FXSignaling4, "=", $ChRange7);
      if ($ChRange8)
        {
        print SYSTEMCONFTEMP ("-", $ChRange8);
        }
      print SYSTEMCONFTEMP ("\nechocanceller=", $FXEcho4, ",", $ChRange7);
      if ($ChRange8)
        {
        print SYSTEMCONFTEMP ("-", $ChRange8);
        }
      }
    }
  }
  
close (SYSTEMCONFTEMP);
print ($text{'TempSpan'}, "<P><P>");
print ("<b>", $text{'ReviewSystemConf'}, "</b><P>");
Review_SystemConf();
}

=head8 restart_Wanrouter()

Reloads the Sangoma wanpipe/dahdi configuration from the Linux command prompt

=cut

sub restart_Wanrouter()
{
open_execute_command(WANROUTER_RELOAD, 'wanrouter restart', 1, 0);
print ("<B>", $text{'WanrouterReload'},"</B><P>");;
while(<WANROUTER_RELOAD>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (WANROUTER_RELOAD);
}

=head9 printFX()

Prints FXO/FXS menus 

=cut

sub printFX()
{
	print ($text{'FXInstructions1'},"<p>\n");
	print ($text{'FXInstructions2'},"<p>\n");
	print ($text{'FXInstructions3'},"<p>\n");
 	#First Channel range
 	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Channel <input type=\"number\" min=\"0\" max=\"255\" value=\"1\" name=\"ChRange1\"/> to <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange2\"/>\n");
 	#First Channel range port type
 	print (" Port type => <select name=\"FXPort1\">\n");
 	print (" <option value=\"unused\"> Unused</option>\n");
 	print (" <option selected value=\"fxo\"> FXS</option>\n"); # reverse signaling compared to port
 	print (" <option value=\"fxs\"> FXO</option>\n");
 	print (" </select>");
 	#First Channel range Signaling type
 	print (" Signaling => <select name=\"FXSignaling1\">\n");
 	print (" <option selected value=\"ks\"> ks (KewlStart)</option>\n");
 	print (" <option value=\"ls\"> ls (LoopStart)</option>\n");
 	print (" <option value=\"gs\"> gs (GroundStart)</option>\n");
 	print (" </select>");
 	#First Channel range Echocanceller type
 	print (" Echocanceller => <select name=\"FXEcho1\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#First Group
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group1\"/><P> \n");
	#Second Channel range
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Channel <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange3\"/> to <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange4\"/>\n");
	#Second Channel range port type
	print (" Port type => <select name=\"FXPort2\">\n");
	print (" <option value=\"unused\"> Unused</option>\n");
 	print (" <option selected value=\"fxo\"> FXS</option>\n"); # reverse signaling compared to port
 	print (" <option value=\"fxs\"> FXO</option>\n");
	print (" </select>");
	#Second Channel range Signaling type
	print (" Signaling => <select name=\"FXSignaling2\">\n");
 	print (" <option selected value=\"ks\"> ks (KewlStart)</option>\n");
 	print (" <option value=\"ls\"> ls (LoopStart)</option>\n");
 	print (" <option value=\"gs\"> gs (GroundStart)</option>\n");
	print (" </select>");
	#Second Channel range Echocanceller type
	print (" Echocanceller => <select name=\"FXEcho2\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#Second Group
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group2\"/><P> \n");
	#Third Channel range
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Channel <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange5\"/> to <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange6\"/>\n");
	#Third Channel range port type
	print (" Port type => <select name=\"FXPort3\">\n");
	print (" <option value=\"unused\"> Unused</option>\n");
 	print (" <option selected value=\"fxo\"> FXS</option>\n"); # reverse signaling compared to port
 	print (" <option value=\"fxs\"> FXO</option>\n");
	print (" </select>");
	#Third Channel range Signaling type
	print (" Signaling => <select name=\"FXSignaling3\">\n");
 	print (" <option selected value=\"ks\"> ks (KewlStart)</option>\n");
 	print (" <option value=\"ls\"> ls (LoopStart)</option>\n");
 	print (" <option value=\"gs\"> gs (GroundStart)</option>\n");
	print (" </select>");
	#Third Channel range Echocanceller type
	print (" Echocanceller => <select name=\"FXEcho3\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#Third Group
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group3\"/><P> \n");
	#Forth Channel range
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Channel <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange7\"/> to <input type=\"number\" min=\"0\" max=\"255\" value=\"0\" name=\"ChRange8\"/>\n");
	#Forth Channel range port type
	print (" Port type => <select name=\"FXPort4\">\n");
	print (" <option value=\"unused\"> Unused</option>\n");
 	print (" <option selected value=\"fxo\"> FXS</option>\n"); # reverse signaling compared to port
 	print (" <option value=\"fxs\"> FXO</option>\n");
	print (" </select>");
	#Forth Channel range Signaling type
	print (" Signaling => <select name=\"FXSignaling4\">\n");
 	print (" <option selected value=\"ks\"> ks (KewlStart)</option>\n");
 	print (" <option value=\"ls\"> ls (LoopStart)</option>\n");
 	print (" <option value=\"gs\"> gs (GroundStart)</option>\n");
	print (" </select>");
	#Forth Channel range Echocanceller type
	print (" Echocanceller => <select name=\"FXEcho4\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#Forth Group
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group4\"/><P> \n");

}

=head10 printISDN()

Prints E1/T1/BRI menus 

=cut

sub printISDN()
{
	print ($text{'ISDNinfo1'}, "<p>\n");
	print ($text{'ISDNinfo2'}, "<p>\n");
	print ($text{'ISDNinfo3'}, "<p>\n");
	print ("<b>Line Configuration</b><p>\n");
	# Select interface type: E1/T1/BRI
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Interface type => <select name=\"ISDN\">\n");
	print (" <option selected value=\"T1\"> T1</option>\n");
	print (" <option value=\"E1\"> E1</option>\n");
	print (" <option value=\"BRI\"> BRI</option>\n");
	print (" </select>");
	# Select Clock Source 0 - Slave, 1- Slave/1st backup, 2- Slave/2nd backup, etc..
	print (" Timing => <select name=\"Timing\">\n");
	print (" <option selected value=\"0\"> Slave (TE)</option>\n");
	print (" <option value=\"1\"> Slave: 1st Backup to Master</option>\n");
	print (" <option value=\"2\"> Slave: 2nd Backup to Master</option>\n");
	print (" <option value=\"3\"> Slave: 3rd Backup to Master</option>\n");
	print (" <option value=\"4\"> Slave: 4th Backup to Master</option>\n");
	print (" <option value=\"5\"> Slave: 5th Backup to Master</option>\n");
	print (" <option value=\"6\"> Slave: 6th Backup to Master</option>\n");
	print (" <option value=\"7\"> Slave: 7th Backup to Master</option>\n");
	print (" <option value=\"8\"> Slave: 8th Backup to Master</option>\n");
	print (" </select>");
	# Select Line Build Out (LBO)
	print (" Line Build Out (LBO) => <select name=\"LBO\">\n");
	print (" <option selected value=\"0\"> 0-133 ft / 0 db <= T1/E1/BRI</option>\n");
	print (" <option value=\"1\"> 133-266 ft <= T1/E1</option>\n");
	print (" <option value=\"2\"> 266-399 ft <= T1/E1</option>\n");
	print (" <option value=\"3\"> 399-533 ft <= T1/E1</option>\n");
	print (" <option value=\"4\"> 533-655 ft <= T1/E1</option>\n");
	print (" <option value=\"5\"> -7.5 db <= T1/E1</option>\n");
	print (" <option value=\"6\"> -15 db <= T1/E1</option>\n");
	print (" <option value=\"7\"> -22. db <= T1/E1</option>\n");
	print (" </select><P>");
	# Select Framing
		print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Framing => <select name=\"Framing\">\n");
	print (" <option value=\"d4\"> d4/sf (T1 only)</option>\n");
	print (" <option selected value=\"esf\"> esf (T1 only)</option>\n");
	print (" <option value=\"cas\"> cas (E1 only)</option>\n");
	print (" <option value=\"ccs\"> ccs (E1/BRI only)</option>\n");
	print (" </select>");
	# Select Coding
	print ("Coding => <select name=\"Coding\">\n");
	print (" <option value=\"ami\"> ami (T1/E1/BRI)</option>\n");
	print (" <option selected value=\"b8zs\"> b8zs (T1 only)</option>\n");
	print (" <option value=\"hdb3\"> hdb3 (E1 only)</option>\n");
	print (" </select>");
	# Select Switchtype
	print (" Switchtype => <select name=\"SwitchType\">\n");
	print (" <option selected value=\"national\"> National ISDN 2 (default)</option>\n");
	print (" <option value=\"dms100\"> Nortel DMS100</option>\n");
	print (" <option value=\"4ess\"> AT&T 4ESS</option>\n");
	print (" <option value=\"5ess\"> Lucent 5ESS</option>\n");
	print (" <option value=\"euroisdn\"> EuroISDN</option>\n");
	print (" <option value=\"ni1\"> Old National ISDN 1</option>\n");
	print (" <option value=\"qsig\"> Q.SIG</option>\n");
	print (" </select>");

	# Options: CRC4 for E1 and the Yellow alarm
	print ("<b>&nbsp;&nbsp;&nbsp;Options:</b> <input type=\"checkbox\" name=\"CRC4\" value=\"crc4\"/> E1-CRC4,");
	print (" &nbsp;&nbsp;&nbsp;<input type=\"checkbox\" name=\"Yellow\" value=\"yellow\" checked=\"checked\"/> Yellow Alarm<P>");

	# Channel configuration
	print ("<b>Channel Configuration</b><p>\n");
 	#First Channel range Echocanceller type
 	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Echocanceller => <select name=\"PRIEcho\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#ISDN Group (use same group variable as first FX
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group1\"/><P> \n");
	# First bchan range. E1 likes to put the dchan in the middle at channel 15
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1st bchan Range = <input type=\"number\" min=\"1\" max=\"254\" value=\"1\" name=\"bchan1\"/> to <input type=\"number\" min=\"1\" max=\"254\" value=\"23\" name=\"bchan2\"/>\n");
	# Select dchan
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dchan = <input type=\"number\" min=\"1\" max=\"254\" value=\"24\" name=\"dchan\"/>\n");
	# Second bchan range if necessary - mainly for E1.
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Optional 2nd bchan Range = <input type=\"number\" min=\"0\" max=\"254\" value=\"0\" name=\"bchan3\"/> to <input type=\"number\" min=\"0\" max=\"254\" value=\"0\" name=\"bchan4\"/><P>\n");

}

=head11 printDYN()

Prints Dynamic Span menus - Temporarily on hold while testing whether PRI works or E&M should be used.

=cut

sub printDYN()
{
	print ($text{'DynamicInfo1'}, "<p>\n");
	print ($text{'DynamicInfo2'}, "<p>\n");
	print ($text{'DynamicInfo3'}, "<p>\n");
	print ("<b>Line Configuration</b><p>\n");
	#Select E1 or T1, this will determine the number of channels per subinterface
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Interface type => <select name=\"ISDN2\">\n");
	print (" <option selected value=\"24\"> T1</option>\n");
	print (" <option value=\"31\"> E1</option>\n");
	print (" </select>");
	# Select Ethernet port: eth0, eth1, eth2, 
	print (" Ethernet Port => <select name=\"ETH\">\n");
	print (" <option selected value=\"0\"> eth0</option>\n");
	print (" <option value=\"1\"> eth1</option>\n");
	print (" <option value=\"2\"> eth2</option>\n");
	print (" <option value=\"3\"> eth3</option>\n");
	print (" </select>");
	# Enter destination's MAC address
	print (" Peer's MAC Address => <input type=\"text\" name=\"MAC1\" size=\"2\" maxlength=\"2\">");
 	print (" : <input type=\"text\" name=\"MAC2\" size=\"2\" maxlength=\"2\">");
 	print (" : <input type=\"text\" name=\"MAC3\" size=\"2\" maxlength=\"2\">");
 	print (" : <input type=\"text\" name=\"MAC4\" size=\"2\" maxlength=\"2\">");
 	print (" : <input type=\"text\" name=\"MAC5\" size=\"2\" maxlength=\"2\">");
 	print (" : <input type=\"text\" name=\"MAC6\" size=\"2\" maxlength=\"2\"> (Allowed characters 0-9, a-f)<P>");
	# Select Clock Source 0 - Slave, 1- Slave/1st backup, 2- Slave/2nd backup, etc..
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Timing => <select name=\"Timing\">\n");
	print (" <option selected value=\"0\"> Slave (TE)</option>\n");
	print (" <option value=\"1\"> Slave: 1st Master</option>\n");
	print (" <option value=\"2\"> Slave: 2nd Backup Master</option>\n");
	print (" <option value=\"3\"> Slave: 3rd Backup Master</option>\n");
	print (" <option value=\"4\"> Slave: 4th Backup Master</option>\n");
	print (" <option value=\"5\"> Slave: 5th Backup Master</option>\n");
	print (" <option value=\"6\"> Slave: 6th Backup Master</option>\n");
	print (" <option value=\"7\"> Slave: 7th Backup Master</option>\n");
	print (" <option value=\"8\"> Slave: 8th Backup Master</option>\n");
	print (" </select>");
	# Select # of Dynamic Subinterface to create
 	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Number of Subinterface to create => <input type=\"number\" min=\"0\" max=\"7\" value=\"0\" name=\"SUB\"/> (Starts counting at 0) \n");
	# Channel configuration
	print ("<P><b>Channel Configuration</b><p>\n");
 	#First Channel range Echocanceller type
 	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Echocanceller => <select name=\"PRIEcho\">\n");
 	print (" <option selected value=\"mg2\"> mg2</option>\n");
 	print (" <option value=\"hwec\"> hwec</option>\n");
 	print (" <option value=\"kbl\"> kb1</option>\n");
	print (" <option value=\"sec\"> sec</option>\n");
	print (" <option value=\"sec2\"> sec2</option>\n");
	print (" <option value=\"hpec\"> hpec</option>\n");
	print (" <option value=\"oslec\"> oslec</option>\n");
	print (" <option value=\"\"> none</option>\n");
	print (" </select>");
 	#ISDN Group (use same group variable as first FX
 	print (" Group => <input type=\"number\" min=\"0\" max=\"255\" value=\"", $DahdiDevice, "\" name=\"Group1\"/><P> \n");
	# First bchan range. E1 likes to put the dchan in the middle at channel 15
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1st bchan Range = <input type=\"number\" min=\"1\" max=\"254\" value=\"1\" name=\"bchan1\"/> to <input type=\"number\" min=\"1\" max=\"254\" value=\"23\" name=\"bchan2\"/>\n");
	# Select dchan
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dchan = <input type=\"number\" min=\"1\" max=\"254\" value=\"24\" name=\"dchan\"/>\n");
	# Second bchan range if necessary - mainly for E1.
	print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Optional 2nd bchan Range = <input type=\"number\" min=\"0\" max=\"254\" value=\"0\" name=\"bchan3\"/> to <input type=\"number\" min=\"0\" max=\"254\" value=\"0\" name=\"bchan4\"/><P>\n");

}

=head12 printGlobal()

Prints Global menu 

=cut

sub printGlobal()
{
    print ($text{'Go2GlobalInfo'}, "<p>\n");
    #Select Loadzone
    print ("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Load Zone => <select name=\"Loadzone\">\n");
    print (" <option value=\"ar\"> Argentina</option>\n");
    print (" <option value=\"at\"> Austria</option>\n");
    print (" <option value=\"au\"> Australia</option>\n");
    print (" <option value=\"be\"> Belgium</option>\n");
    print (" <option value=\"br\"> Brazil</option>\n");
    print (" <option value=\"bg\"> Bulgaria</option>\n");
    print (" <option value=\"cl\"> Chile</option>\n");
    print (" <option value=\"cn\"> China</option>\n");
    print (" <option value=\"cz\"> Czech Republic</option>\n");
    print (" <option value=\"dk\"> Denmark</option>\n");
    print (" <option value=\"ee\"> Estonia</option>\n");
    print (" <option value=\"fi\"> Finland</option>\n");
    print (" <option value=\"fr\"> France</option>\n");
    print (" <option value=\"de\"> Germany</option>\n");
    print (" <option value=\"gr\"> Greece</option>\n");
    print (" <option value=\"hu\"> Hungary</option>\n");
    print (" <option value=\"il\"> Israel</option>\n");
    print (" <option value=\"in\"> India</option>\n");
    print (" <option value=\"it\"> Italy</option>\n");
    print (" <option value=\"jp\"> Japan</option>\n");
    print (" <option value=\"lt\"> Lithuania</option>\n");
    print (" <option value=\"my\"> Malaysia</option>\n");
    print (" <option value=\"mx\"> Mexico</option>\n");
    print (" <option value=\"ni\"> Netherlands</option>\n");
    print (" <option value=\"nz\"> New Zealand</option>\n");
    print (" <option value=\"no\"> Norway</option>\n");
    print (" <option value=\"ph\"> Philippines</option>\n");
    print (" <option value=\"pl\"> Poland</option>\n");
    print (" <option value=\"pt\"> Portugal</option>\n");
    print (" <option value=\"sg\"> Singapore</option>\n");
    print (" <option value=\"za\"> South Africa</option>\n");
    print (" <option value=\"es\"> Spain</option>\n");
    print (" <option value=\"se\"> Sweden</option>\n");
    print (" <option value=\"ch\"> Switzerland</option>\n");
    print (" <option value=\"th\"> Thailand</option>\n");
    print (" <option value=\"uk\"> United Kingdom</option>\n");
    print (" <option selected value=\"us\"> USA/Canada</option>\n");
    print (" <option value=\"us-old\"> USA 1950s</option>\n");
    print (" <option value=\"ve\"> Venezuela</option>\n");
    print (" </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
    #Select Default Zone
    print ("Default Zone => <select name=\"Defaultzone\">\n");
    print (" <option value=\"ar\"> Argentina</option>\n");
    print (" <option value=\"at\"> Austria</option>\n");
    print (" <option value=\"au\"> Australia</option>\n");
    print (" <option value=\"be\"> Belgium</option>\n");
    print (" <option value=\"br\"> Brazil</option>\n");
    print (" <option value=\"bg\"> Bulgaria</option>\n");
    print (" <option value=\"cl\"> Chile</option>\n");
    print (" <option value=\"cn\"> China</option>\n");
    print (" <option value=\"cz\"> Czech Republic</option>\n");
    print (" <option value=\"dk\"> Denmark</option>\n");
    print (" <option value=\"ee\"> Estonia</option>\n");
    print (" <option value=\"fi\"> Finland</option>\n");
    print (" <option value=\"fr\"> France</option>\n");
    print (" <option value=\"de\"> Germany</option>\n");
    print (" <option value=\"gr\"> Greece</option>\n");
    print (" <option value=\"hu\"> Hungary</option>\n");
    print (" <option value=\"il\"> Israel</option>\n");
    print (" <option value=\"in\"> India</option>\n");
    print (" <option value=\"it\"> Italy</option>\n");
    print (" <option value=\"jp\"> Japan</option>\n");
    print (" <option value=\"lt\"> Lithuania</option>\n");
    print (" <option value=\"my\"> Malaysia</option>\n");
    print (" <option value=\"mx\"> Mexico</option>\n");
    print (" <option value=\"ni\"> Netherlands</option>\n");
    print (" <option value=\"nz\"> New Zealand</option>\n");
    print (" <option value=\"no\"> Norway</option>\n");
    print (" <option value=\"ph\"> Philippines</option>\n");
    print (" <option value=\"pl\"> Poland</option>\n");
    print (" <option value=\"pt\"> Portugal</option>\n");
    print (" <option value=\"sg\"> Singapore</option>\n");
    print (" <option value=\"za\"> South Africa</option>\n");
    print (" <option value=\"es\"> Spain</option>\n");
    print (" <option value=\"se\"> Sweden</option>\n");
    print (" <option value=\"ch\"> Switzerland</option>\n");
    print (" <option value=\"th\"> Thailand</option>\n");
    print (" <option value=\"uk\"> United Kingdom</option>\n");
    print (" <option selected value=\"us\"> USA/Canada</option>\n");
    print (" <option value=\"us-old\"> USA 1950s</option>\n");
    print (" <option value=\"ve\"> Venezuela</option>\n");
    print (" </select><P>");
}

=head13 Update_ChanDahdiTrunk()

Prints Global menu 

=cut

sub Update_ChanDahdiTrunk()
{
# Append to the temporary /etc/asterisk/chan_dahdi_trunk.conf.temp file
open (TRUNKTEMP, '>>/etc/asterisk/chan_dahdi_trunk.conf.temp');
if ($CardType eq 'PRI')  # configuring PRI card
  {
  print TRUNKTEMP ("\n\n; Span ", $DahdiDevice - 1, " is a ", $ISDN, " card");
  print TRUNKTEMP ("\ngroup = ", $Group1);
  print TRUNKTEMP ("\ncontext = from-pstn");
  print TRUNKTEMP ("\nswitchtype = ", $SwitchType);
  print TRUNKTEMP ("\nsignalling = ");
  if ($Timing)
    {
      print TRUNKTEMP ("pri_net");
    }
  else
    {
      print TRUNKTEMP ("pri_cpe");
    }
  if($bchan1)
    {
    print TRUNKTEMP ("\nchannel = ", $bchan1);
    if($bchan2)
      {
      print TRUNKTEMP ("-", $bchan2);
      }
    }
  if($bchan3)
    {
    print TRUNKTEMP ("\nchannel = ", $bchan3);
    if($bchan4)
      {
      print TRUNKTEMP ("-", $bchan4);
      }
    }
  print TRUNKTEMP ("\ncontext = default");
  }
  # dynamice Spans to be configured after testing and verification...
  
else # configuring FXO ports
  { 
  if ($FXPort1 eq 'fxs')  # Reverse signalling for FXO ports
    {
    print TRUNKTEMP ("\n\n; Span ", $DahdiDevice - 1, " - FXO Port with ", $FXPort1, "_", $FXSignaling1, " signalling, Channel = ", $ChRange1);
    if ($ChRange2)
      {
      print TRUNKTEMP ("-", $ChRange2);
      }
    print TRUNKTEMP ("\nsignalling=", $FXPort1, "_", $FXSignaling1); 
    print TRUNKTEMP ("\ncallerid=asreceived"); 
    print TRUNKTEMP ("\ngroup=", $Group1); 
    print TRUNKTEMP ("\ncontext=from-pstn"); 
    print TRUNKTEMP ("\nchannel => ", $ChRange1); 
    if ($ChRange2)
      {
      print TRUNKTEMP ("-", $ChRange2);
      }
    print TRUNKTEMP ("\ncontext=default"); 
    }
if ($FXPort2 eq 'fxs')  # Reverse signalling for FXO ports
    {
    if($ChRange3)  # Stops printing when ChRange = 0
      { 
      print TRUNKTEMP ("\n\n; Span ", $DahdiDevice - 1, " - FXO Port with ", $FXPort2, "_", $FXSignaling2, " signalling, Channel = ", $ChRange3);
      if ($ChRange4)
        {
        print TRUNKTEMP ("-", $ChRange4);
        }
      print TRUNKTEMP ("\nsignalling=", $FXPort2, "_", $FXSignaling2); 
      print TRUNKTEMP ("\ncallerid=asreceived"); 
      print TRUNKTEMP ("\ngroup=", $Group2); 
      print TRUNKTEMP ("\ncontext=from-pstn"); 
      print TRUNKTEMP ("\nchannel => ", $ChRange3); 
      if ($ChRange4)
        {
        print TRUNKTEMP ("-", $ChRange4);
        }
      print TRUNKTEMP ("\ncontext=default"); 
      }
    }
if ($FXPort3 eq 'fxs')  # Reverse signalling for FXO ports
    {
    if($ChRange5)      # Stops printing when ChRange = 0
      {
      print TRUNKTEMP ("\n\n; Span ", $DahdiDevice - 1, " - FXO Port with ", $FXPort3, "_", $FXSignaling3, " signalling, Channel = ", $ChRange5);
      if ($ChRange6)
        {
        print TRUNKTEMP ("-", $ChRange6);
        }
      print TRUNKTEMP ("\nsignalling=", $FXPort3, "_", $FXSignaling3); 
      print TRUNKTEMP ("\ncallerid=asreceived"); 
      print TRUNKTEMP ("\ngroup=", $Group3); 
      print TRUNKTEMP ("\ncontext=from-pstn"); 
      print TRUNKTEMP ("\nchannel => ", $ChRange5); 
      if ($ChRange6)
        {
        print TRUNKTEMP ("-", $ChRange6);
        }
      print TRUNKTEMP ("\ncontext=default"); 
      }
    }
if ($FXPort4 eq 'fxs')  # Reverse signalling for FXO ports
    {
    if($ChRange7)   # Stops printing when ChRange = 0
      {
      print TRUNKTEMP ("\n\n; Span ", $DahdiDevice - 1, " - FXO Port with ", $FXPort4, "_", $FXSignaling4, " signalling, Channel = ", $ChRange7);
      if ($ChRange8)
        {
        print TRUNKTEMP ("-", $ChRange8);
        }
      print TRUNKTEMP ("\nsignalling=", $FXPort4, "_", $FXSignaling4); 
      print TRUNKTEMP ("\ncallerid=asreceived"); 
      print TRUNKTEMP ("\ngroup=", $Group4); 
      print TRUNKTEMP ("\ncontext=from-pstn"); 
      print TRUNKTEMP ("\nchannel => ", $ChRange7); 
      if ($ChRange8)
        {
        print TRUNKTEMP ("-", $ChRange8);
        }
      print TRUNKTEMP ("\ncontext=default"); 
      }
    }
  }
close (TRUNKTEMP);
Review_ChanDahdiTrunk(); 
}

=head14 Review_ChanDahdiTrunk()

Prints /etc/asterisk/Chan_Dahdi_Trunk.conf.temp

=cut

sub Review_ChanDahdiTrunk()
{
print ("<b>", $text{'ReviewChanDahdiTrunk'}, "</b><P>");
# Prints last span config to screen for verification.
# Reads /etc/dahdi/chan_dahdi_trunk.conf.temp line by line and puts it into the array $lref
my $lref = &read_file_lines('/etc/asterisk/chan_dahdi_trunk.conf.temp');
# Prints each line of /etc/asterisk/chan_dahdi_trunk.conf.temp
foreach my $line (@$lref) 
  {
  print (" ", $line,"<br>\n");
  }
  print ("<P>");	
}

=head13 Review_SystemConf()

Prints /etc/dahdi/system.conf.temp 

=cut

sub Review_SystemConf()
{
# Prints last span config to screen for verification.
# Reads /etc/dahdi/system.conf.temp line by line and puts it into the array $lref
my $lref = &read_file_lines('/etc/dahdi/system.conf.temp');
# Prints each line of /etc/dahdi/system.conf.temp
foreach my $line (@$lref) 
  {
  print (" ", $line,"<br>\n");
  }
  print ("<P>");
}

=head14 start_dahdi()

Starts dahdi kernel service

=cut
sub start_dahdi()
{
open_execute_command(DAHDI_START, '/etc/init.d/dahdi start', 1, 0);
print ("<B>", $text{'ServiceDahdiStart'},"</B><p>");
while(<DAHDI_START>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_START);
print "<hr><P>";
}

=head15 stop_dahdi()

Stops dahdi kernel service

=cut
sub stop_dahdi()
{
open_execute_command(DAHDI_STOP, '/etc/init.d/dahdi stop', 1, 0);
print ("<B>", $text{'ServiceDahdiStop'},"</B><p>");
while(<DAHDI_STOP>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_STOP);
print "<hr><P>";
}

=head16 run_dahdi_cfg()

Runs dahdi_cfg to reload with new configuration

=cut
sub run_dahdi_cfg()
{
open_execute_command(DAHDI_CFG, 'dahdi_cfg -v', 1, 0);
print ("<B>", $text{'Run_Dahdi_Cfg'},"</B><p>");
while(<DAHDI_CFG>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_CFG);
print "<hr><P>";
}

=head17 dahdi_show_channels()

Runs asterisk CLI dahdi_show_channels

=cut
sub dahdi_show_channels()
{
open_execute_command(DAHDI_SHOW_CHANNELS, 'asterisk -rx "dahdi show channels"', 1, 0);
print ("<B>", $text{'DahdiShowChannels'},"</B><p>");
while(<DAHDI_SHOW_CHANNELS>)
 {
 # Print the line to the screen and add a newline
 print "$_<P>\n";
 }
close (DAHDI_SHOW_CHANNELS);
print "<hr><P>";
}

