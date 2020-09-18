# HELK script: HELK Elastalert Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-base:latest
LABEL maintainer="Nate Guagenti @neu5ron"
LABEL description="Dockerfile base for the HELK Zeek."

USER root

# Zeek Version
ARG zeek_ver='v3.0.10'

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
  git clone --recursive https://github.com/zeek/zeek -b $zeek_ver zeek
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
  zkg install --force zeek/corelight/log-add-http-post-bodies && \
  zkg install --force zeek/corelight/log-add-vlan-everywhere && \
  zkg install --force zeek/corelight/zeek-community-id
## Salesforce
RUN zkg install --force zeek/salesforce/hassh && \
 zkg install --force zeek/salesforce/ja3
## Etc..
RUN zkg install --force zeek/0xxon/zeek-tls-log-alternative
RUN zkg install --force zeek/0xxon/cve-2020-13777
RUN zkg install --force zeek/fatemabw/kyd
RUN zkg install --force zeek/lexibrent/zeek-EternalSafety
RUN zkg install --force zeek/micrictor/smbfp
RUN zkg install --force zeek/theparanoids/rdfp
RUN zkg install --force zeek/scebro/ldap-analyzer
RUN zkg install --force zeek/mitre-attack/bzar

## Enable as necessary / future
#RUN zkg install --force zeek/apache/metron-bro-plugin-kafka
#RUN zkg install --force zeek/corelight/json-streaming-logs

## Not working But want to enable #TODO:, these all install but have runtime errors. actual errors not warning
#RUN zkg install --force zeek/ukncsc/zeek-plugin-ikev2 
#RUN zkg install --force zeek/salesforce/GQUIC_Protocol_Analyzer
#RUN zkg install --force zeek/corelight/bro-quic || cat /root/.zkg/logs/bro-quic-build.log
#RUN zkg install --force zeek/stratosphereips/IRC-Zeek-package
#RUN zkg install --force zeek/amzn/zeek-plugin-bacnet && \
#  zkg install --force zeek/amzn/zeek-plugin-profinet && \
#  zkg install --force zeek/amzn/zeek-plugin-enip && \
#  zkg install --force zeek/amzn/zeek-plugin-s7comm && \
#  zkg install --force zeek/amzn/zeek-plugin-tds
# || cat /root/.zkg/logs/zeek-plugin-ikev2-build.log && exit 1
## Etc... maybe
#RUN zkg install --force zeek/initconf/phish-analysis
#RUN zkg install --force zeek/corelight/bro-xor-exe-plugin
#RUN zkg install --force zeek/sethhall/unknown-mime-type-discovery
#RUN zkg install --force zeek/precurse/zeek-httpattacks

# Set interface/packet capture
#setcap cap_net_raw,cap_net_admin=eip $ZEEKDIR/bin/zeek

# Cleanup
RUN rm -R ${SRC_DIR}/zeek

WORKDIR /pcap
ENTRYPOINT ["zeek"]