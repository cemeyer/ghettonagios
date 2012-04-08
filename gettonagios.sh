#!/bin/bash

#   Ghetto NAGIOS
#   Copyright (C) 2011  Conrad Meyer <cemeyer@cs.washington.edu>

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.


echo "<html><head>"
echo "<style>.good { background-color: green } .bad { background-color: red }"
echo ".maybe { background-color: yellow }"
echo "body { font-size: 5pt }"
echo "sup { font-size: 4pt }"
echo ".n { background-color: #cccccc; }"
echo ".n2 { background-color: #ffcccc; }"
echo "b { background-color: #cccccc; }"
echo "</style>"
echo "<meta http-equiv='refresh' content='2'></head><body>"

echo "<h1>Nagios<sup>TM</sup></h1>"
echo "<img width='200' src='gettonagios.PNG'>"

tmpfile20=$(mktemp)
tmpfile30=$(mktemp)
tmpfile40=$(mktemp)
tmpfile50=$(mktemp)
tmpfile60=$(mktemp)
tmpfile70=$(mktemp)
tmpfilefw=$(mktemp)

nmap -T insane -P0 -p53,389,636 192.168.5.40 > "${tmpfile40}" &
nmap -T insane -P0 -p80,443     192.168.5.50 > "${tmpfile50}" &
nmap -T insane -P0 -p80,443,22  192.168.5.60 > "${tmpfile60}" &
nmap -T insane -P0 -p80,443,22  192.168.5.70 > "${tmpfile70}" &
nmap -T insane -P0 -p25,110,995 192.168.5.20 > "${tmpfile20}" &
nmap -T insane -P0 -p80,443     192.168.5.30 > "${tmpfile30}" &
nmap -T insane -P0 -p139,445,1037 192.168.5.50 > "${tmpfilefw}" &

while [ "x$(ps aux|grep '[n]map')" != "x" ]; do
  sleep 1
done

tcp20="$(grep "/tcp" "$tmpfile20")"
tcp30="$(grep "/tcp" "$tmpfile30")"
tcp40="$(grep "/tcp" "$tmpfile40")"
tcp50="$(grep "/tcp" "$tmpfile50")"
tcp60="$(grep "/tcp" "$tmpfile60")"
tcp70="$(grep "/tcp" "$tmpfile70")"
tcpfw="$(grep "/tcp" "$tmpfilefw")"

tcp_53_40="$(echo "$tcp40" | grep "53/tcp")"
tcp_389_40="$(echo "$tcp40" | grep "389/tcp")"
tcp_636_40="$(echo "$tcp40" | grep "636/tcp")"
tcp_80_50="$(echo "$tcp50" | grep "80/tcp")"
tcp_443_50="$(echo "$tcp50" | grep "443/tcp")"
tcp_80_60="$(echo "$tcp60" | grep "80/tcp")"
tcp_443_60="$(echo "$tcp60" | grep "443/tcp")"
tcp_22_60="$(echo "$tcp60" | grep "22/tcp")"
tcp_80_70="$(echo "$tcp70" | grep "80/tcp")"
tcp_443_70="$(echo "$tcp70" | grep "443/tcp")"
tcp_22_70="$(echo "$tcp70" | grep "22/tcp")"

tcp_25_20="$(echo "$tcp20" | grep "25/tcp")"
tcp_110_20="$(echo "$tcp20" | grep "110/tcp")"
tcp_995_20="$(echo "$tcp20" | grep "995/tcp")"

echo "<table>"
echo "<tr><td><strong>Last octet</strong></td><td><strong>Service</strong></td></tr>"
echo "<tr><td class='n'>.20</td><td class='n2'>Exchange (SMTP, POP3, POP3S)</td></tr>"
echo "<tr><td class='n'>.40</td><td class='n2'>DNS,DC,DHCP</td></tr>"
echo "<tr><td class='n'>.50</td><td class='n2'>IIS</td></tr>"
echo "<tr><td class='n'>.60</td><td class='n2'>LAMP</td></tr>"
echo "<tr><td class='n'>.70</td><td class='n2'>LAMP</td></tr>"
echo "</table>"

echo "<h2>Firewall</h2>"
echo "<table>"
echo "<tr>"
fwtest="$(echo "$tcpfw" | grep "open" | wc -l)"
if [ "x$fwtest" = "x0" ]; then
  echo "<td class='good'>firewall functional</td>"
else
  echo "<td class='bad'>firewall left something open:<br>$(echo "$tcpfw" | grep "open")</td>"
fi
echo "</tr>"
echo "</table>"

echo "<table>"
echo "<tr><td class='n'>.20</td><td class='n'>.40</td><td class='n'>.50</td><td class='n'>.60</td><td class='n'>.70</td></tr>"

echo "<tr>"
if echo "$tcp_25_20" | grep -q "open" ; then
  echo "<td class='good'>SMTP</td>"
else
  echo "<td class='bad'>SMTP</td>"
fi
if echo "$tcp_53_40" | grep -q "open" ; then
  echo "<td class='good'>DNS</td>"
else
  echo "<td class='bad'>DNS</td>"
fi
if echo "$tcp_80_50" | grep -q "open" ; then
  echo "<td class='good'>HTTP</td>"
else
  echo "<td class='bad'>HTTP</td>"
fi
if echo "$tcp_80_60" | grep -q "open" ; then
  echo "<td class='good'>HTTP</td>"
else
  echo "<td class='bad'>HTTP</td>"
fi
if echo "$tcp_80_70" | grep -q "open" ; then
  echo "<td class='good'>HTTP</td>"
else
  echo "<td class='bad'>HTTP</td>"
fi
echo "</tr>"

echo "<tr>"
if echo "$tcp_110_20" | grep -q "open" ; then
  echo "<td class='good'>POP3</td>"
else
  echo "<td class='bad'>POP3</td>"
fi
if echo "$tcp_389_40" | grep -q "open" ; then
  echo "<td class='good'>LDAP</td>"
else
  echo "<td class='bad'>LDAP</td>"
fi
if echo "$tcp_443_50" | grep -q "open" ; then
  echo "<td class='good'>HTTPS</td>"
else
  echo "<td class='bad'>HTTPS</td>"
fi
if echo "$tcp_443_60" | grep -q "open" ; then
  echo "<td class='good'>HTTPS</td>"
else
  echo "<td class='bad'>HTTPS</td>"
fi
if echo "$tcp_443_70" | grep -q "open" ; then
  echo "<td class='good'>HTTPS</td>"
else
  echo "<td class='bad'>HTTPS</td>"
fi
echo "</tr>"

echo "<tr>"
if echo "$tcp_995_20" | grep -q "open" ; then
  echo "<td class='good'>POP3S</td>"
else
  echo "<td class='bad'>POP3S</td>"
fi
if echo "$tcp_636_40" | grep -q "open" ; then
  echo "<td class='good'>LDAPS</td>"
else
  echo "<td class='bad'>LDAPS</td>"
fi
echo "<td>&nbsp;</td>"
if echo "$tcp_22_60" | grep -q "open" ; then
  echo "<td class='good'>SSH</td>"
else
  echo "<td class='bad'>SSH</td>"
fi
if echo "$tcp_22_70" | grep -q "open" ; then
  echo "<td class='good'>SSH</td>"
else
  echo "<td class='bad'>SSH</td>"
fi
echo "</tr>"

echo "</table>"


posts="$(curl 192.168.5.70 2>/dev/null | grep '<b><a href="http://employeeconnect.vaprgamz.org/pg/thewire/owner/')"
toppost="$(echo "$posts" | head -n 1)"

echo "<h2>Most recent post on ELGG:</h2>"

echo "$toppost"

echo "<h2>Mail</h2>"

echo "<table>"
mailhead="$(echo -en "QUIT\r\n" | nc 192.168.5.20 25  | head -n 1)"
if echo "$mailhead" | grep -q "220 Exchange.vaprgamz.org Microsoft ESMTP MAIL Service ready a"; then
  echo "<tr><td class='good'>SMTP seems responsive</td></tr>"
else
  echo "<tr><td class='bad'>SMTP seems unresponsive</td></tr>"
fi
mailhead="$(echo -en "QUIT\r\n" | nc 192.168.5.20 110 | head -n 1)"
if echo "$mailhead" | grep -q "+OK Microsoft Exchange Server 2007 POP3 service ready"; then
  echo "<tr><td class='good'>POP3 seems responsive</td></tr>"
else
  echo "<tr><td class='bad'>POP3 seems unresponsive</td></tr>"
fi
echo "</table>"

#tmpfile_ping100=$(mktemp)
#ping -c 4 192.168.5.100 > "$tmpfile_ping100" &
#while [ "x$(ps aux|grep '[p]ing')" != "x" ]; do
#  sleep 1
#done

echo "<h2>Zen web</h2>"

LAMPintact="$(curl 192.168.5.60 2>/dev/null )"
LAMPintacts="$(curl --insecure https://192.168.5.60/ 2>/dev/null )"

echo "<table>"
LAMPsize="$(echo "$LAMPintact" | wc -c)"
LAMPsizes="$(echo "$LAMPintacts" | wc -c)"
echo -n "<tr><td class='"
if [ "$LAMPsize" -lt 16000 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>LAMP size: ${LAMPsize}</td>"
echo -n "<td class='"
if [ "$LAMPsizes" -lt 16000 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>LAMP(s) size: ${LAMPsize}</td>"
echo "</tr>"
if echo "$LAMPintact" | grep -q 'Powered by <a href="http://www.zen-cart.com" target="_blank">Zen Cart'; then
  echo "<tr><td colspan='2' class='good'>Website seems to be running Zen</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website seems to be not running Zen</td></tr>"
fi
if echo "$LAMPintacts" | grep -q 'Powered by <a href="http://www.zen-cart.com" target="_blank">Zen Cart'; then
  echo "<tr><td colspan='2' class='good'>Website (HTTPS) seems to be running Zen</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website (HTTPS) seems to be not running Zen</td></tr>"
fi
echo "</table>"

echo "<h2>ELGG web</h2>"

ELGGintact="$(curl 192.168.5.70 2>/dev/null )"
ELGGintacts="$(curl --insecure https://192.168.5.70/ 2>/dev/null )"

echo "<table>"
ELGGsize="$(echo "$ELGGintact" | wc -c)"
ELGGsizes="$(echo "$ELGGintacts" | wc -c)"
echo -n "<tr><td class='"
if [ "$ELGGsize" -lt 16000 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>ELGG size: ${ELGGsize}</td>"
echo -n "<td class='"
if [ "$ELGGsizes" -lt 16000 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>ELGG(s) size: ${ELGGsize}</td>"
echo "</tr>"
if echo "$ELGGintact" | grep -q '<img src="http://employeeconnect.vaprgamz.org/_graphics/powered_by_elgg_badge_drk_bckgnd.gif" border="0" />'; then
  echo "<tr><td colspan='2' class='good'>Website seems to be running ELGG</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website seems to be not running ELGG</td></tr>"
fi
if echo "$ELGGintacts" | grep -q '<img src="http://employeeconnect.vaprgamz.org/_graphics/powered_by_elgg_badge_drk_bckgnd.gif" border="0" />'; then
  echo "<tr><td colspan='2' class='good'>Website (HTTPS) seems to be running ELGG</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website (HTTPS) seems to be not running ELGG</td></tr>"
fi
echo "</table>"

echo "<h2>IIS (Apache) web</h2>"

IISintact="$(curl 192.168.5.50 2>/dev/null )"
IISintacts="$(curl --insecure https://192.168.5.50/ 2>/dev/null )"

echo "<table>"
IISsize="$(echo "$IISintact" | wc -c)"
IISsizes="$(echo "$IISintacts" | wc -c)"
echo "<tr>"
echo -n "<td class='"
if [ "$IISsize" -ne 3737 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>IIS size: ${IISsize}</td>"
echo -n "<td class='"
if [ "$IISsizes" -ne 3737 ]; then
  echo -n "bad"
else
  echo -n "good"
fi
echo "'>IIS(s) size: ${IISsizes}</td>"
echo "</tr>"
if echo "$IISintact" | grep -q '2024 Blotto Finacial Corporation | Designed by Rich, Ieng, Sam, Robert'; then
  echo "<tr><td colspan='2' class='good'>Website seems to be running blotto page</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website seems to be not running blotto page</td></tr>"
fi
if echo "$IISintacts" | grep -q '2024 Blotto Finacial Corporation | Designed by Rich, Ieng, Sam, Robert'; then
  echo "<tr><td colspan='2' class='good'>Website (HTTPS) seems to be running blotto page</td></tr>"
else
  echo "<tr><td colspan='2' class='bad'>Website (HTTPS) seems to be not running blotto page</td></tr>"
fi
echo "</table>"

echo "<h2>Pings</h2>"
ping100="$(ping -c 4 192.168.5.100 | grep transmitted)"
#pingint="$(ping -c 4 8.8.8.8 | grep transmitted)"
#4 packets transmitted, 4 received, 0% packet loss, time 3008ms
pingres100="$(echo "$ping100" | cut -d, -f3 | sed -e "s|^ \([0-9]*\).*$|\1|")"
#pingresint="$(echo "$pingint" | cut -d, -f3 | sed -e "s|^ \([0-9]*\).*$|\1|")"
pingresp100=$((100-pingres100))
#pingrespint=$((100-pingresint))
# ^ % dropped, "0" "25" "50" "75" "100"
pingcolor="maybe"
if [ "x$pingresp100" = "x100" ]; then
  pingcolor="good"
elif [ "x$pingresp100" = "x0" ]; then
  pingcolor="bad"
fi
#pingcolorint="maybe"
#if [ "x$pingrespint" = "x100" ]; then
#  pingcolorint="good"
#elif [ "x$pingrespint" = "x0" ]; then
#  pingcolorint="bad"
#fi
echo "<table>"
echo "<tr><td class='${pingcolor}'>Ping for .100 (Admin): (${pingresp100}%)</td></tr>"
#echo "<tr><td class='${pingcolorint}'>Ping for internet: (${pingrespint}%)</td></tr>"
echo "</table>"

echo "<h2>DNS check</h2>"
resolvecheck="$(dig @192.168.5.40 ubuntu.vaprgamz.org | grep -A 1 "ANSWER SECTION")"
resolvelinecount="$(echo "$resolvecheck" | grep 192.168.5.60 | wc -l)"
if [ "x$resolvelinecount" = "x1" ]; then
  rescol="good"
else
  rescol="bad"
fi
echo "<table>"
echo "<tr><td class='${rescol}'>DNS for ubuntu resolves to 192.168.5.60</td></tr>"
echo "</table>"

echo "<p>Last update: $(date)</p>"

echo "</body></html>"
