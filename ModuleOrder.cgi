#!/usr/bin/perl

# Webmin-Dahdi HW Config -ModuleOrder.cgi
# Configures the order of loading of Dahdi Kernel drivers
# Author: Eugene Blanchard
# Revision: 0.10
# Date: Sept 2, 2010
#


require 'dahdiHW-lib.pl';

MAIN:
{
ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

print ("<P><h2>", $text{'ModOrder'},"</h2><P>\n");
print ($text{'ModOrderInfo'}, "<P>");

#ReadParse();
#$DeviceNumber = $in{'DahdiDevice'};
#print ($DeviceNumber, "<P>");
#$DeviceNumber++;
#print ($DeviceNumber, "<P>");

#Reference information
print ("<b>wct4xxp</b>:<br>", $text{'wct4xxp'}, "<p>");
print ("<b>wcte12xp</b>:<br>", $text{'wcte12xp'}, "<p>");
print ("<b>wct1xxp</b>:<br>", $text{'wct1xxp'}, "<p>");
print ("<b>wcte11xp</b>:<br>", $text{'wcte11xp'}, "<p>");
print ("<b>wcfxo</b>:<br>", $text{'wcfxo'}, "<p>");
print ("<b>wctdm</b>:<br>", $text{'wctdm'}, "<p>");
print ("<b>wcb4xxp</b>:<br>", $text{'wcb4xxp'}, "<p>");
print ("<b>wctc4xxp</b>:<br>", $text{'wctc4xxp'}, "<p>");
print ("<b>xpp_usb</b>:<br>", $text{'xpp_usb'}, "<hr><P>");

#Select Dahdi driver order - send to System Modules and have it write it out then display new settings?
print ($text{'SelectDeviceOrder'}, "<p>");

# Select Dadhi 1
print ("<form method=POST action=\"SystemModules.cgi\">\n");
print ("<b>Dahdi 1</b> => <select name=\"Dahdi1\">\n");
print (" <option selected value=\"#\">none</option>\n");
print (" <option value=\"wct4xxp\">wct4xxp</option>\n");
print (" <option value=\"wcte12xp\">wcte12xp</option>\n");
print (" <option value=\"wct1xxp\">wct1xxp</option>\n");
print (" <option value=\"wcte11xp\">wcte11xp</option>\n");
print (" <option value=\"wcfxo\">wcfxo</option>\n");
print (" <option value=\"wctdm\">wctdm</option>\n");
print (" <option value=\"wcb4xxp\">wcb4xxp</option>\n");
print (" <option value=\"wctc4xxp\">wctc4xxp</option>\n");
print (" <option value=\"xpp_usb\">xpp_usb</option>\n");
print (" </select>");
# Select Dadhi 2
print ("<form method=POST action=\"SystemModules.cgi\">\n");
print ("<b>Dahdi 2</b> => <select name=\"Dahdi2\">\n");
print (" <option selected value=\"#\">none</option>\n");
print (" <option value=\"wct4xxp\">wct4xxp</option>\n");
print (" <option value=\"wcte12xp\">wcte12xp</option>\n");
print (" <option value=\"wct1xxp\">wct1xxp</option>\n");
print (" <option value=\"wcte11xp\">wcte11xp</option>\n");
print (" <option value=\"wcfxo\">wcfxo</option>\n");
print (" <option value=\"wctdm\">wctdm</option>\n");
print (" <option value=\"wcb4xxp\">wcb4xxp</option>\n");
print (" <option value=\"wctc4xxp\">wctc4xxp</option>\n");
print (" <option value=\"xpp_usb\">xpp_usb</option>\n");
print (" </select>");
# Select Dadhi 3
print ("<form method=POST action=\"SystemModules.cgi\">\n");
print ("<b>Dahdi 3</b> => <select name=\"Dahdi3\">\n");
print (" <option selected value=\"#\">none</option>\n");
print (" <option value=\"wct4xxp\">wct4xxp</option>\n");
print (" <option value=\"wcte12xp\">wcte12xp</option>\n");
print (" <option value=\"wct1xxp\">wct1xxp</option>\n");
print (" <option value=\"wcte11xp\">wcte11xp</option>\n");
print (" <option value=\"wcfxo\">wcfxo</option>\n");
print (" <option value=\"wctdm\">wctdm</option>\n");
print (" <option value=\"wcb4xxp\">wcb4xxp</option>\n");
print (" <option value=\"wctc4xxp\">wctc4xxp</option>\n");
print (" <option value=\"xpp_usb\">xpp_usb</option>\n");
print (" </select>");
# Select Dadhi 4
print ("<form method=POST action=\"SystemModules.cgi\">\n");
print ("<b>Dahdi 4</b> => <select name=\"Dahdi4\">\n");
print (" <option selected value=\"#\">none</option>\n");
print (" <option value=\"wct4xxp\">wct4xxp</option>\n");
print (" <option value=\"wcte12xp\">wcte12xp</option>\n");
print (" <option value=\"wct1xxp\">wct1xxp</option>\n");
print (" <option value=\"wcte11xp\">wcte11xp</option>\n");
print (" <option value=\"wcfxo\">wcfxo</option>\n");
print (" <option value=\"wctdm\">wctdm</option>\n");
print (" <option value=\"wcb4xxp\">wcb4xxp</option>\n");
print (" <option value=\"wctc4xxp\">wctc4xxp</option>\n");
print (" <option value=\"xpp_usb\">xpp_usb</option>\n");
print (" </select><P>");

#The NewOrder hidden value is to indicate that the order has changed
print ("<input type=\"hidden\" name=\"NewOrder\" value=\"1\">");
print ("<input type=\"submit\" name=\"ModOrder\" value=\"", $text{'Save'}, "\"></form><P><i>", $text{'DeviceSaveMsg'}, "</i><P>");
#Print return to mainmenu link
print (ui_nav_link(left, "SystemModules.cgi", 0), "<B><a href=\"SystemModules.cgi\">", $text{'ReturnToSystemModules'}, "</a></b><P>\n");
print (ui_nav_link(left, "index.cgi", 0), "<B><a href=\"index.cgi\">", $text{'ReturnToDahdiHW'}, "</b><p>\n");

ui_print_footer("/", $text{'index'});
}