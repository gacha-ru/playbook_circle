FROM centos

MAINTAINER Yu Nishimura

# setup remi repository
RUN yum -y install wget
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN curl -O http://rpms.famillecollet.com/RPM-GPG-KEY-remi; rpm --import RPM-GPG-KEY-remi
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
RUN yum -y update && yum -y upgrade

# setup tools
RUN yum -y groupinstall --enablerepo=epel,remi "Development Tools"

# expose http port
EXPOSE 80
