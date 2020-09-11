# HELK script: HELK Elastalert Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-base:latest
LABEL maintainer="Nate Guagenti @neu5ron"
LABEL description="Dockerfile base for the HELK Zeek."

USER root
# Main user directory 
ARG HOME_DIR=/root
# Compiled sources
ARG SRC_DIR=${HOME_DIR}/sources
# Base directory for zeek
ARG INSTALL_DIR=/usr/local
# Zeek main directory
ARG ZEEK_BASE_DIR=${INSTALL_DIR}/zeek
RUN mkdir -p ${SRC_DIR} && \
  mkdir /pcap && \
  mkdir -p ${ZEEK_BASE_DIR}

######## Install build requirements ########
RUN apt-get update -qq && apt-get install -qqy --no-install-recommends \
	cmake \
	g++ \
	bison \
	flex \
	libmagic-dev \
	libgeoip-dev \
	libssl-dev \
	build-essential \
	python-dev \
	libpcap-dev \
	cmake \
	swig3.0 \
	libssl-dev \
	libpcap-dev \
	zlib1g-dev \
  git \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools

############ Download and install Zeek ############
RUN cd ${SRC_DIR}; \
  git clone --recursive https://github.com/zeek/zeek
RUN cd ${SRC_DIR}/zeek; \
  ./configure --prefix=${ZEEK_BASE_DIR};
RUN cd ${SRC_DIR}/zeek; \
  make -j 2;
RUN cd ${SRC_DIR}/zeek; \
  make install; \
  cd ..;

############ Set environment variables & paths ############
#RUN ln -s $ZEEKDIR/bin/zeek /usr/bin/zeek \
#	&& ln -s $ZEEKDIR/bin/zeekctl /usr/bin/zeekctl \
#	&& ln -s $ZEEKDIR/bin/zeek-cut /usr/bin/zeek-cut \
#	&& ln -s $ZEEKDIR/bin/zeek-config /usr/bin/zeek-config \
#	&& ln -s $ZEEKDIR/bin/zeek-wrapper /usr/bin/zeek-wrapper
#	#echo "export PATH=$PATH:$ZEEKDIR/bin/" >> .bashrc
#	# now confirm in PATH varaible:
#	#tail --lines 1 .bashrc
ENV ZEEK_HOME ${ZEEK_BASE_DIR}
ENV PATH="${ZEEK_HOME}/bin:${PATH}"
	

############ Install Zeek package manager and packages ############
RUN pip3 install zkg \
  && zkg autoconfig
## Corelight packages
RUN  zkg install --force zeek/corelight/got_zoom && \
  #zkg install --force zeek/corelight/json-streaming-logs && \
  zkg install --force zeek/corelight/log-add-http-post-bodies && \
  zkg install --force zeek/corelight/log-add-vlan-everywhere && \
  zkg install --force zeek/corelight/zeek-community-id
## Salesforce
RUN zkg install --force zeek/salesforce/hassh && \
 zkg install --force zeek/salesforce/ja3
## Etc..
RUN zkg install --force zeek/0xxon/zeek-tls-log-alternative
RUN zkg install --force zeek/0xxon/cve-2020-13777
#RUN zkg install --force zeek/apache/metron-bro-plugin-kafka
RUN zkg install --force zeek/fatemabw/kyd
RUN zkg install --force zeek/lexibrent/zeek-EternalSafety
RUN zkg install --force zeek/micrictor/smbfp
RUN zkg install --force zeek/precurse/zeek-httpattacks
RUN zkg install --force zeek/theparanoids/rdfp
#RUN zkg install --force zeek/ukncsc/zeek-plugin-ikev2 --skiptests  || true && cat /root/.zkg/logs/zeek-plugin-ikev2-build.log && exit 1 #TODO: eventually remove --skiptests when package is updated
#RUN zkg install --force https://github.com/neu5ron/zeek-plugin-ikev2  || true && cat /root/.zkg/logs/zeek-plugin-ikev2-build.log && exit 1 #TODO: eventually remove --skiptests when package is updated
#RUN zkg install --force zeek/salesforce/GQUIC_Protocol_Analyzer
## Etc... maybe
#RUN zkg install --force zeek/initconf/phish-analysis
## Not working #TODO:
#RUN zkg install --force zeek/ukncsc/zeek-plugin-ikev2
#RUN zkg install --force zeek/scebro/ldap-analyzer
#RUN zkg install --force zeek/corelight/bro-xor-exe-plugin
#RUN zkg install --force zeek/corelight/bro-quic
#RUN zkg install --force zeek/stratosphereips/IRC-Zeek-package #error during runtime / processing of packets / replay of pcap
#RUN zkg install --force zeek/mitre-attack/bzar #error during runtime / processing of packets / replay of pcap
#RUN zkg install --force zeek/sethhall/unknown-mime-type-discovery #error during runtime / processing of packets / replay of pcap
## Amazon
#RUN zkg install --force zeek/amzn/zeek-plugin-bacnet && \ #error about ports defined
#  zkg install --force zeek/amzn/zeek-plugin-profinet && \ #error about ports defined
#  zkg install --force zeek/amzn/zeek-plugin-enip && \ #error about ports defined
#  zkg install --force zeek/amzn/zeek-plugin-s7comm && \ #error about ports defined
#  zkg install --force zeek/amzn/zeek-plugin-tds #error about ports defined

# Pcap files
#ENV PCAP_HOME ${PCAP_DIR}
# Set interface/packet capture
#setcap cap_net_raw,cap_net_admin=eip $ZEEKDIR/bin/zeek

COPY ./config/local.zeek $ZEEK_HOME/share/zeek/site

# Cleanup
RUN rm -R ${SRC_DIR}/zeek

WORKDIR /pcap
ENTRYPOINT ["zeek"]