#!/bin/sh

VNC_PASSWORD=${VNC_PASSWORD:-"password"}
LOGFILE='/opt/selenium/node.log'

echo $VNC_PASSWORD | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

unset DBUS_SESSION_BUS_ADDRESS
/usr/bin/vncserver $DISPLAY -geometry ${SCREEN_WIDTH}x${SCREEN_HEIGHT} -depth ${SCREEN_DEPTH}

bash /add_clock.sh
service ssh start
eval /clear_dangling_driver.sh chromedriver &>/dev/null &disown

java ${JAVA_OPTS} -jar /opt/selenium/selenium-server-standalone.jar \
    -role node \
    -hub http://$HUB_PORT_4444_TCP_ADDR:$HUB_PORT_4444_TCP_PORT/grid/register \
    -nodeConfig /opt/selenium/config.json \
    -log ${LOGFILE} \
    ${SE_OPTS}
