FROM centos/httpd

LABEL MAINTAINER="Justin Bradley <justin@soton.ac.uk>"

ARG EPRINTS_HOSTNAME=localhost
ENV EPRINTS_HOSTNAME="${EPRINTS_HOSTNAME}"

RUN yum -y -q install httpd; yum clean all; systemctl enable httpd.service

RUN yum -y -q install epel-release
RUN yum -y -q install perl-DBI perl-DBD-MySQL perl-CGI perl-XML-LibXML perl-XML-LibXSLT perl-XML-SAX perl-Digest-SHA perl-IO-Socket-SSL \
    perl-MIME-Lite 
RUN yum -y -q install tetex-latex perl-IO-String perl-Text-Unidecode perl-Apache-DBI
RUN yum -y -q install perl-JSON libselinux-utils

RUN yum -y -q install search wget mod_perl unzip elinks poppler-utils ImageMagick

RUN rpm --install https://files.eprints.org/2715/8/eprints-3.4.4-1.el7.noarch.rpm
RUN touch /usr/share/eprints/cfg/apache/tmp.conf

ADD https://files.eprints.org/2715/2/eprints-3.4.4-flavours.tar.gz /usr/share/eprints/flavours.tgz
RUN cd /usr/share/eprints && tar -xzvf flavours.tgz && mv eprints-3.4.4/flavours/* flavours/

ADD https://files.eprints.org/2411/3/pub.conf.template /usr/share/eprints/cfg/apache/pub.conf.template
ADD https://files.eprints.org/2411/2/pub.tgz /usr/share/eprints/archives/

RUN cd /usr/share/eprints/archives/ && tar -xzvf pub.tgz && rm pub.tgz

RUN cd /usr/share/eprints/archives/pub/cfg/cfg.d && sed -e s/docker/${EPRINTS_HOSTNAME}/ 10_core.pl.template > 10_core.pl
RUN cd /usr/share/eprints/cfg/apache && sed -e s/docker/${EPRINTS_HOSTNAME}/ pub.conf.template > pub.conf

# run it all as the eprints user
RUN cd /etc/httpd/conf/ &&  sed -e 's/User apache/User eprints/' -e 's/Group apache/Group eprints/' httpd.conf > c && mv -f c httpd.conf
RUN chown -R eprints:eprints /usr/share/eprints/

# start the indexer
RUN su eprints -c "/usr/share/eprints/bin/indexer start"

EXPOSE 80