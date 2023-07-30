FROM almalinux:latest

LABEL ORIGINAL MAINTAINER="Justin Bradley <justin@soton.ac.uk>"

ARG EPRINTS_HOSTNAME=localhost
ENV EPRINTS_HOSTNAME="${EPRINTS_HOSTNAME}"

RUN dnf clean all

# Install necessary additional repositories
RUN dnf -yq install epel-release 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb

# Install and enable Apache
RUN dnf -yq install httpd
RUN systemctl enable httpd.service

# Install Dependencies available from the AlmaLinux repositories
RUN dnf -yq install libxml2 libxslt httpd mod_perl perl-DBI perl-DBD-MySQL perl-IO-Socket-SSL perl-Time-HiRes \
   perl-CGI perl-Digest-MD5 perl-Digest-SHA perl-JSON perl-XML-LibXML perl-XML-LibXSLT perl-XML-SAX \
   perl-MIME-Lite perl-Text-Unidecode perl-JSON perl-Unicode-Collate tetex-latex wget gzip tar \
   ImageMagick poppler-utils chkconfig unzip cpan python3-html2text perl-IO-String perl-MIME-Types perl-Digest-SHA1

# Install Apache::DBI from cpan, as not available elsewhere
RUN cpan Apache::DBI

# Download the Eprints 3.4.4 RPM. Need to use rpm --nodeps, as it doesn't like the cpan version of Apache::DBI
RUN rpm --install --nodeps https://files.eprints.org/2715/8/eprints-3.4.4-1.el7.noarch.rpm
RUN touch /usr/share/eprints/cfg/apache/tmp.conf

# Download and extract Flavours
ADD https://files.eprints.org/2715/2/eprints-3.4.4-flavours.tar.gz /usr/share/eprints/flavours.tgz
RUN cd /usr/share/eprints && tar -xzvf flavours.tgz && mv eprints-3.4.4/flavours/* flavours/

# Download and extract sample publications data
ADD https://files.eprints.org/2411/3/pub.conf.template /usr/share/eprints/cfg/apache/pub.conf.template
ADD https://files.eprints.org/2411/2/pub.tgz /usr/share/eprints/archives/
RUN cd /usr/share/eprints/archives/ && tar -xzvf pub.tgz && rm pub.tgz

# Update local Apache config
RUN cd /usr/share/eprints/archives/pub/cfg/cfg.d && sed -e s/docker/${EPRINTS_HOSTNAME}/ 10_core.pl.template > 10_core.pl
RUN cd /usr/share/eprints/cfg/apache && sed -e s/docker/${EPRINTS_HOSTNAME}/ pub.conf.template > pub.conf

# Update global Apache config
RUN cd /etc/httpd/conf/ &&  sed -e 's/User apache/User eprints/' -e 's/Group apache/Group eprints/' httpd.conf > c && mv -f c httpd.conf
RUN cd /etc/httpd/conf/ && echo 'ServerName localhost' >> httpd.conf

# Fix Apache segmentation issue
RUN cd /etc/httpd/conf.modules.d/ && \
    sed -e 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' \
    -e 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' \
    00-mpm.conf > d && mv -f d 00-mpm.conf

# Change ownership of the eprints folder to the eprints user
RUN chown -R eprints:eprints /usr/share/eprints/

# start the indexer
RUN su eprints -c "/usr/share/eprints/bin/indexer start"

EXPOSE 80