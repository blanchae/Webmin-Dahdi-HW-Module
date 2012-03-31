#!/usr/bin/perl

# Webmin-Dahdi HW Config -SystemModules.cgi
# Displays information on the order of loading of Dahdi Kernel drivers and the current configuration
# Author: Eugene Blanchard
# Revision: 0.10
# Date: Sept 2, 2010
# ToDo: It would be nice to read the timestamp on the first line. Should be able to munge the line then determine
# if the line has a timestamp or not.
#

require 'dahdiHW-lib.pl';

MAIN:
{
ReadParse();
ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

# Prints Module name
print ("<P>\n<h2>", $text{'SystemModules'},"</h2><P>\n<P>\n");

print ($text{'SystemModulesInfo'}, "<P><hr><P>");

#Checks to see if the driver was loaded more than once - not allowed
if ($in{'NewOrder'})
  {
  my $DateTime = localtime time;
  my $Dahdi1 = $in{'Dahdi1'};
  my $Dahdi2 = $in{'Dahdi2'};
  my $Dahdi3 = $in{'Dahdi3'};
  my $Dahdi4 = $in{'Dahdi4'};
  print ($text{'SysModNewConfig'}, "<b>", $DateTime, "</b><P>");
  if($Dahdi1 eq '#' && $Dahdi2 eq '#' && $Dahdi3 eq '#' && $Dahdi4 eq '#')
    {
    print ($text{'1234eqZtdummy'}, "<p>");
    webmin_log('configured', "/etc/dahdi/modules", "- NO Dahdi Modules Selected", , , );
    }
  else
   {
  if($Dahdi4 eq $Dahdi1 || $Dahdi4 eq $Dahdi2 || $Dahdi4 eq $Dahdi3)
    {
    $Dahdi4 = '#';
    print ($text{'4eq123'}, "<p>"); 
    }
  if($Dahdi3 eq $Dahdi1 || $Dahdi3 eq $Dahdi2)
    {
    $Dahdi3 = '#';
    print ($text{'3eq12'}, "<p>"); 
    }
  if($Dahdi2 eq $Dahdi1)
    {
    $Dahdi2 = '#';
    print ($text{'2eq1'}, "<p>"); 
    }
  }
  write_modules($Dahdi1, $Dahdi2, $Dahdi3, $Dahdi4, $DateTime);
  webmin_log('configured', "/etc/dahdi/modules", "- Changed dahdi module order", , , );
  }
else
  {
  print ($text{'SysModCurrentConfig'}, "<P>");
  }
#Read current configuration and lists order!!!

# Reads /etc/dahdi/modules line by line and puts it into the array $lref
my $lref = &read_file_lines('/etc/dahdi/modules');
my $lnum =0;

# Prints each line of /etc/dahdi/modules
foreach my $line (@$lref) 
 {
# Very ugly way to NOT print comment lines (begins with #) but it works..
if ($line =~ m/(#)/)
  {
  }
else
  {
  # only print lines that start with a word (should be driver name) - this ignores blank lines
  if ($line =~ m/\w/)
   {
   print (++$lnum,".<B> ",$line,"</b><br>\n");
   print ($text{$line}, "<P>");
   }
  }
 }
print ($text{'RestartDahdiWarning1'});
print ("<form method=POST action=\"StopStart.cgi\">\n");
print ("<input type=\"hidden\" name=\"Stop_Asterisk\" value=\"1\">");
print ("<input type=\"hidden\" name=\"Restart_Dahdi\" value=\"1\">");
print ("<input type=\"hidden\" name=\"Start_Asterisk\" value=\"1\">");
print ("<input type=\"hidden\" name=\"Caller\" value=\"SystemModules.cgi\">");
print ("<input type=\"submit\" name=\"\" value=\"", $text{'RestartDahdi'}, "\"></form><P>");

#Print return to mainmenu link
print ("</blockquote><P>", ui_nav_link(right, "ModuleOrder.cgi", 0), "<B><a href=\"ModuleOrder.cgi\">", $text{'ChangeModOrder'}, "</a></b><p>\n");
#Print return to mainmenu link
print (ui_nav_link(left, "index.cgi", 0), "<B><a href=\"index.cgi\">", $text{'ReturnToDahdiHW'}, "</a></b><P>  ");
ui_print_footer("/", $text{'index'});
}