FROM ubuntu:latest

LABEL Version="0.1" \
      Date="2020-Nov-25" \
      Docker_Version="20.11.25 (1)" \
      Maintainer="RedBug/Crazy Piri (@crazypiri)" \
      Description="A basic Docker container to compile and use devkitsms from GIT"

ENV Z88DK_PATH="/opt/z88dk" \
    SDCC_PATH="/tmp/sdcc" \
    SDCC_HOME="/tmp/sdcc"

RUN apt-get update

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y git ca-certificates wget make patch gcc bzip2 unzip g++ texinfo bison flex libboost-dev libsdl1.2-dev pkgconf libfreetype6-dev libncurses-dev cmake vim zip php php-mbstring bsdmainutils imagemagick python

RUN wget -O /tmp/sdcc.tar.bz2 "https://downloads.sourceforge.net/project/sdcc/sdcc/4.0.0/sdcc-src-4.0.0.tar.bz2" \
    && cd /tmp \
    && rm -rf ${SDCC_PATH} \
    && tar xvjf sdcc.tar.bz2 \
    && mv sdcc-4.0.0 sdcc \
    && cd ${SDCC_PATH} \
    && ./configure \
		--disable-avr-port \                                               
        --disable-xa-port \                                                
        --disable-mcs51-port \                                             
        --disable-z180-port \                                              
        --disable-r2k-port \                                               
        --disable-r3ka-port \                                              
        --disable-gbz80-port \                                             
        --disable-ds390-port \                                             
        --disable-ds400-port \                                             
        --disable-pic14-port \                                             
        --disable-pic16-port \                                        
        --disable-hc08-port \                                         
        --disable-s08-port \                                          
        --disable-tlcs90-port \                      
        --disable-st7-port \                         
        --disable-stm8-port \                        
        --disable-ucsim \
    && make \
    && make install

RUN cd /tmp \
	&& git clone https://github.com/sverx/devkitSMS\
	&& cd devkitSMS \
	&& cp ihx2sms/Linux/ihx2sms /usr/local/bin \
	&& cp assets2banks/src/assets2banks.py /usr/local/bin \
	&& chmod 777 /usr/local/bin/assets2banks.py\
	&& cd /tmp/devkitSMS/folder2c/src/\
	&& gcc folder2c.c -o folder2c\
	&& cp folder2c /usr/local/bin/

RUN mkdir -p /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/SMSlib/src/peep-rules.txt /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/SMSlib/src/SMSlib.h /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/SMSlib/SMSlib.lib /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/crt0/crt0_sms.rel /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/PSGlib/PSGlib.rel /opt/toolchains/sms/devkit\
	&& cp /tmp/devkitSMS/PSGlib/src/PSGlib.h /opt/toolchains/sms/devkit

RUN cd /tmp \
	&& git clone https://github.com/yuv422/png2tile.git\
	&& cd png2tile\
	&& cmake .\
	&& make\
	&& cp png2tile /usr/local/bin/

RUN cd /tmp \
	&& git clone https://github.com/sverx/PSGlib.git\
	&& cd PSGlib/tools/src/\
	&& gcc vgm2psg.c -lz -o /usr/local/bin/vgm2psg\
	&& gcc psgcomp.c -lz -o /usr/local/bin/psgcomp


WORKDIR /src/
