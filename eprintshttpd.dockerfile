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
   ImageMagick poppler-utils chkconfig unzip cpan python3-html2text perl-IO-String perl-MIME-Types perl-Digest-SHA1 \
   git

# Install Apache::DBI from cpan, as not available elsewhere
RUN cpan Apache::DBI

# Create the Eprints user
RUN useradd eprints

# Create the EPrints installation directory and set its ownership to the eprints user
RUN mkdir /opt/eprints3
RUN chown eprints:eprints /opt/eprints3
RUN chmod 2775 /opt/eprints3

# Switch to the eprints user and clone EPrints 3.4.5 from the git repository
RUN su eprints
RUN git clone https://github.com/eprints/eprints3.4.git --branch=v3.4.5 /opt/eprints3
RUN cd /opt/eprints3

RUN cp --force /opt/eprints3/perl_lib/EPrints/SystemSettings.pm.tmpl /opt/eprints3/perl_lib/EPrints/SystemSettings.pm

# Download and extract Flavours
ADD https://files.eprints.org/2789/2/eprints-3.4.5-flavours.tar.gz /opt/eprints3/flavours.tgz
RUN cd /opt/eprints3 && tar -xzvf flavours.tgz && cp -r eprints-3.4.5/flavours/* flavours/ && rm -R eprints-3.4.5/flavours/*

# Download and extract sample publications data
ADD https://files.eprints.org/2411/3/pub.conf.template /opt/eprints3/cfg/apache/pub.conf.template
ADD https://files.eprints.org/2411/2/pub.tgz /opt/eprints3/archives/
RUN cd /opt/eprints3/archives/ && tar -xzvf pub.tgz && rm pub.tgz

# Update local Apache config
RUN cd /opt/eprints3/archives/pub/cfg/cfg.d && sed -e s/docker/${EPRINTS_HOSTNAME}/ 10_core.pl.template > 10_core.pl
RUN cd /opt/eprints3/cfg/apache && sed -e s/docker/${EPRINTS_HOSTNAME}/ pub.conf.template > pub.conf

# Switch back to the root user to perform Apache changes
RUN su

# Update global Apache config
RUN cd /etc/httpd/conf/ &&  sed -e 's/User apache/User eprints/' -e 's/Group apache/Group eprints/' \ 
    -e 's/#ServerName www.example.com:80/ServerName localhost/' httpd.conf > c && mv -f c httpd.conf

# Fix Apache segmentation issue
RUN cd /etc/httpd/conf.modules.d/ && \
    sed -e 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' \
    -e 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' \
    00-mpm.conf > d && mv -f d 00-mpm.conf

# Change ownership of the eprints folder to the eprints user (just in case!)
RUN chown -R eprints:eprints /opt/eprints3/

# start the indexer
RUN su eprints -c "/opt/eprints3/bin/indexer start"

EXPOSE 80