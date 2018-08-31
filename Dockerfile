FROM alpine:3.7
LABEL maintainer "yanbe <y.yanbe@gmail.com>"

RUN set -x \
	&& apk upgrade --update \
	&& apk add --virtual .build-deps \
		curl \
		bzip2 \
		bash \
		autoconf \
		automake \
		gcc \
		g++ \
		make \
	\
	# get foltia's recpt1 and generate patch
	&& mkdir /tmp/recpt1-original \
	&& curl http://aniloc.foltia.com/opensource/recpt1/{pt1-b14397800eae.tar.bz2} --output "/tmp/#1" \
	&& tar -jxvf /tmp/pt1-b14397800eae.tar.bz2 --strip-components 1 --directory /tmp/recpt1-original \
	&& cp -r /tmp/recpt1-original /tmp/recpt1-foltia \
	&& curl http://aniloc.foltia.com/opensource/recpt1/{Makefile.in,pt1_dev.h,recpt1.h,recpt1.c} --output "/tmp/recpt1-foltia/recpt1/#1" \
	&& diff -u /tmp/recpt1-original/recpt1 /tmp/recpt1-foltia/recpt1 > /tmp/recpt1-foltia.patch \
	|| : \
	\
	# generate patch for 2018 BS transponder migraiton
	&& mkdir /tmp/recpt1-bsbase \
	&& curl http://hg.honeyplanet.jp/pt1/archive/{d56831676696.tar.bz2} --output "/tmp/pt1-#1" \
	&& tar -jxvf /tmp/pt1-d56831676696.tar.bz2 --strip-components 1 --directory /tmp/recpt1-bsbase \
	&& mkdir /tmp/recpt1-bs2018 \
	&& curl http://hg.honeyplanet.jp/pt1/archive/{17b4f7b5dccb.tar.bz2} --output "/tmp/pt1-#1" \
	&& tar -jxvf /tmp/pt1-17b4f7b5dccb.tar.bz2 --strip-components 1 --directory /tmp/recpt1-bs2018 \
	&& diff -u /tmp/recpt1-bsbase/recpt1/pt1_dev.h /tmp/recpt1-bs2018/recpt1/pt1_dev.h > /tmp/recpt1-bs2018.patch \
	|| perl -MEncode -pe 'Encode::from_to($_, "utf8", "eucjp");' /tmp/recpt1-bs2018.patch > /tmp/recpt1-bs2018-euc-jp.patch \
	\
	# get official pt1 with latest foltia compatible revision
	&& mkdir /tmp/recpt1-latest \
	&& curl http://hg.honeyplanet.jp/pt1/archive/{61ff9cabf962.tar.bz2} --output "/tmp/pt1-#1" \
	&& tar -jxvf /tmp/pt1-61ff9cabf962.tar.bz2 --strip-components 1 --directory /tmp/recpt1-latest \
	\
	# then patch them
	&& cd /tmp/recpt1-latest/recpt1 \
	&& patch -u < /tmp/recpt1-foltia.patch \
	&& patch -u < /tmp/recpt1-bs2018-euc-jp.patch \
	\
	# patch for musl environment
	&& cd /tmp/recpt1-latest/recpt1 \
	&& sed -i -E 's!(typedef struct )msgbuf!\1!' recpt1.c \
	&& sed -i -E 's!(typedef struct )msgbuf!\1!' recpt1ctl.c \
	&& sed -i -E 's!(#include <sys/stat.h>)!\1\n#include <sys/types.h>!' tssplitter_lite.c \
	\
	# get as5220 driver from plex
	&& curl http://plex-net.co.jp/download/linux/{Linux_Driver.zip} --output "/tmp/#1" \
	&& unzip /tmp/Linux_Driver.zip -d /tmp \
	&& cp /tmp/Linux_Driver/MyRecpt1/MyRecpt1/recpt1/asicen_dtv.c \
		/tmp/Linux_Driver/MyRecpt1/MyRecpt1/recpt1/asicen_dtv.h /tmp/recpt1-latest/recpt1 \
	\
	# build recpt1 for PX-W3PE dtv tuners
	&& cd /tmp/recpt1-latest/recpt1 \
 	&& bash autogen.sh \
	&& ./configure \
	&& make \
	&& make install \
	\
	# cleaning
	&& cd / \
	&& apk del --purge .build-deps \
	&& rm -rf /tmp/pt1-* \
	&& rm -rf /tmp/recpt1-* \
	&& rm -rf /tmp/Linux_Driver* \
	&& rm -rf /var/cache/apk/*
