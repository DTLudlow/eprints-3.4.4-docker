FROM centos/httpd

MAINTAINER "Justin Bradley" <justin@soton.ac.uk>

ARG EPRINTS_HOSTNAME=localhost
ENV EPRINTS_HOSTNAME="${EPRINTS_HOSTNAME}"

RUN yum -y install httpd; yum clean all; systemctl enable httpd.service

RUN yum -y install epel-release
RUN yum -y install perl-DBI perl-DBD-MySQL perl-CGI perl-XML-LibXML perl-XML-LibXSLT perl-XML-SAX perl-Digest-SHA perl-IO-Socket-SSL perl-MIME-Lite
RUN yum -y install perl-JSON libselinux-utils

# dont really need this and its massive
# RUN yum -y install texlive-latex 

RUN yum -y install search wget mod_perl unzip elinks poppler-utils ImageMagick
# also need perl(Apache::DBI) apparently

# no deps as this is sufficiently met in the above
RUN rpm --install --nodeps https://files.eprints.org/2401/11/eprints-3.4.1-1.el7.noarch.rpm
RUN touch /usr/share/eprints/cfg/apache/tmp.conf

ADD https://files.eprints.org/2401/8/eprints-3.4.1-flavours.tar.gz /usr/share/eprints/flavours.tgz
RUN cd /usr/share/eprints && tar -xzvf flavours.tgz && mv eprints-3.4.1/flavours/* flavours/

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

CMD ./run-httpd.sh 

