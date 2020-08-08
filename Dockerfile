ARG VERSION=3.4.0-einsteinium
FROM selenium/node-chrome:$VERSION

#RUN wget --no-verbose https://selenium-release.storage.googleapis.com/3.3/selenium-server-standalone-3.3.1.jar -O /opt/selenium/selenium-server-standalone.jar

USER root

MAINTAINER gaainf "infinum@mail.ru"
ENV DEBIAN_FRONTEND noninteractive
ENV USER root

RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    software-properties-common build-essential \
    gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal \
    ubuntu-desktop \
    tightvncserver sudo \
    xterm gedit \
    fonts-unfonts-core \
    dbus xfonts-100dpi xfonts-75dpi xfonts-cyrillic dbus-x11 \
    ibus dconf-tools \
    gnome-screenshot \
    gnome-shell \
    openssh-server

RUN echo "\nStrictHostKeyChecking no\nLogLevel QUIET\n" >> /etc/ssh/ssh_config

RUN locale-gen ru_RU.UTF-8
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8

ADD start_node.sh /start_node.sh
RUN chmod 777 /start_node.sh

#USER seluser

RUN mkdir /root/.vnc
ADD xstartup /root/.vnc/xstartup
ADD add_clock.sh /add_clock.sh
RUN chmod 777 /add_clock.sh
ADD clear_dangling_driver.sh /clear_dangling_driver.sh
RUN chmod 777 /clear_dangling_driver.sh

#for selenium 3.3.0
#RUN /opt/selenium/generate_config > /opt/selenium/config.json
# for selenium 3.4.0

#========================
## Selenium Configuration
##========================
# As integer, maps to "maxInstances"
ENV NODE_MAX_INSTANCES 5
# As integer, maps to "maxSession"
ENV NODE_MAX_SESSION 5
# As integer, maps to "port"
ENV NODE_PORT 5555
# In milliseconds, maps to "registerCycle"
ENV NODE_REGISTER_CYCLE 5000
# In seconds, maps to "timeout"
ENV NODE_TIMEOUT 60
# In milliseconds, maps to "cleanUpCycle"
ENV NODE_CLEAN_UP_CYCLE 1800
# In milliseconds, maps to "nodePolling"
ENV NODE_POLLING 15000
# In milliseconds, maps to "unregisterIfStillDownAfter"
ENV NODE_UNREGISTER_IF_STILL_DOWN_AFTER 60000
# As integer, maps to "downPollingLimit"
ENV NODE_DOWN_POLLING_LIMIT 2
## As string, maps to "applicationName"
#ENV NODE_APPLICATION_NAME ""
## Debug - not working
#ENV NODE_DEBUG true

RUN /opt/bin/generate_config > /opt/selenium/config.json

RUN sed -i 's/: 2$/: 2,\n"debug": true/' /opt/selenium/config.json

CMD /start_node.sh

#uncomment for vnc
#EXPOSE 5901
