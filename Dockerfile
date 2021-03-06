FROM centos:6

MAINTAINER Yu Nishimura <gacharion@gmail.com>

# setup remi repository
RUN yum -y install wget
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN curl -O http://rpms.famillecollet.com/RPM-GPG-KEY-remi; rpm --import RPM-GPG-KEY-remi
RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
RUN yum -y update && yum -y upgrade

# setup tools
# RUN yum -y groupinstall --enablerepo=epel,remi "Development Tools"
RUN yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make \
        net-snmp rsyslog rsync tar gzip

# Preparing to Nagios Install
RUN cd /tmp     && \
    wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.8.tar.gz && \
    wget http://nagios-plugins.org/download/nagios-plugins-2.0.tar.gz   && \
    tar zxvf nagios-4.0.8.tar.gz        && \
    tar zxvf nagios-plugins-2.0.tar.gz
RUN useradd nagios
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios

# Nagios Install
RUN cd /tmp/nagios-4.0.8 && \
    ./configure --with-command-group=nagcmd && \
    make all                    && \
    make install                && \
    make install-init           && \
    make install-config         && \
    make install-commandmode    && \
    make install-webconf
RUN cp -R /tmp/nagios-4.0.8/contrib/eventhandlers/ /usr/local/nagios/libexec/
RUN chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

# set nagios web password
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios

# set plugin
RUN cd /tmp/nagios-plugins-2.0/     && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios    && \
    make          && \
    make install

# service start
CMD ["service","nagios","start"]
CMD ["service","httpd","start"]

# expose http port
EXPOSE 80
