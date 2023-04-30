#FROM centos/httpd
FROM almalinux

LABEL MAINTAINER="Justin Bradley <justin@soton.ac.uk>"

ARG EPRINTS_HOSTNAME=localhost
ENV EPRINTS_HOSTNAME="${EPRINTS_HOSTNAME}"

# Dependencies
RUN yum -y install dnf-plugins-core
RUN yum config-manager --set-enabled powertools
RUN yum -y install elinks
RUN dnf -y -q install epel-release

RUN dnf -y -q install perl libxslt httpd perl-DBI perl-DBD-MySQL perl-IO-Socket-SSL perl-Time-HiRes \
    perl-CGI perl-Digest-MD5 perl-Digest-SHA perl-JSON perl-XML-LibXML perl-XML-SAX \
    perl-Text-Unidecode perl-JSON perl-Unicode-Collate tetex-latex wget \
    poppler-utils unzip cpan

RUN dnf -y -q install ImageMagick ImageMagick-devel

RUN dnf -y -q install mod_perl libxslt
#RUN dnf -y -q install mod_perl libxslt perl-io-string perl-apache-dbi perl-mime-lite

#RUN cpan XML::LibXML
#RUN cpan -i XML::LibXSLT
RUN cpan -i MIME::Lite
RUN cpan -i Apache::DBI
RUN cpan -i IO::String
#RUN cpan -T mod_perl2
RUN cpan -i Pod::LaTeX

RUN rpm --install https://files.eprints.org/2715/8/eprints-3.4.4-1.el7.noarch.rpm
RUN touch /usr/share/eprints/cfg/apache/tmp.conf

ADD https://files.eprints.org/2715/2/eprints-3.4.4-flavours.tar.gz /usr/share/eprints/flavours.tgz
RUN cd /usr/share/eprints && tar -xzvf flavours.tgz && mv eprints-3.4.4/flavours/* flavours/
#RUN rmdir /usr/share/eprints/eprints-3.4.4/

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

