FROM        perl:5.18
MAINTAINER  Marco Palma simiomalo@gmail.com

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
RUN cpanm --notest IO::All JSON Method::Signatures::Simple Mouse

COPY package-handler automated-package-handler input.txt /root/
COPY PackageHandler.pm /root/
COPY PackageHandler /root/PackageHandler

