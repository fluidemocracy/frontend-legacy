#!/bin/sh
#
# This command can be used to update the INSTALL.html file after changing the
# INSTALL.mkd file.

echo "<html><head><title>"`grep '[^ \t\r\n][^ \t\r\n]*' INSTALL.mkd | head -n 1`"</title></head><body>" > INSTALL.html
markdown2 INSTALL.mkd >> INSTALL.html
echo "</body></html>" >> INSTALL.html
