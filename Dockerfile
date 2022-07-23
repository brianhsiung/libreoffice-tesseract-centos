FROM centos:7.8.2003

LABEL maintainer=brianhsiung@outlook.com

WORKDIR /usr/local

RUN mkdir -p /usr/share/fonts /opt/tesseract-4.1.0

COPY leptonica-1.74.4 /tmp/leptonica-1.74.4
COPY LibreOffice_7.0.6 /tmp/LibreOffice_7.0.6
COPY LibreOffice_7.0.6_zh-CN /tmp/LibreOffice_7.0.6_zh-CN
COPY tesseract-4.1.0 /tmp/tesseract-4.1.0
COPY libiconv-1.16 /tmp/libiconv-1.16
COPY jdk1.8.0_281 /usr/local/java
COPY ./fonts/* /usr/share/fonts/
COPY ./traineddata/* /opt/tesseract-4.1.0/tessdata/

RUN yum update -y && yum makecache && yum install -y nc \
  && rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && yum install -y kde-l10n-Chinese && yum reinstall -y glibc-common \
  && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && echo "export LANG=zh_CN.utf8" >> /etc/profile && echo "export LC_ALL=zh_CN.utf8" >> /etc/profile \
  && yum install -y fontconfig mkfontscale \
  && yum install -y gcc-c++ make zlib-devel pkg-config libtool automake autoconf libjpeg-devel libpng-devel libtiff-devel xorg-x11-xinit xorg-x11-server-Xorg \
  && yum install -y /tmp/LibreOffice_7.0.6/RPMS/*.rpm && yum install -y /tmp/LibreOffice_7.0.6_zh-CN/RPMS/*.rpm && yum install -y cairo cups-libs \
  && cd /tmp/leptonica-1.74.4 && ./configure --prefix=/usr/local/ && make && make install \
  && cd /tmp/libiconv-1.16 && ./configure --prefix=/usr/local && make && make install \
  && export LD_LIBRARY_PATH=/usr/local/lib \
  && export LIBLEPT_HEADERSDIR=/usr/local/include \
  && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
  && cd /tmp/tesseract-4.1.0 && ./autogen.sh && ./configure --with-extra-includes=/usr/local/include --with-extra-libraries=/usr/local/include && make && make install \
  && cp /usr/local/lib/*.so.* /usr/lib64/ \
  && yum clean all && make clean && rm -rf /var/cache/yum && rm -rf /usr/local/src/* && rm -rf /tmp/* 

ENV JAVA_OPTS=""
ENV LC_ALL=zh_CN.utf8
ENV JAVA_VERSION=8u281
ENV JAVA_HOME=/usr/local/java
ENV LIBREOFFICE_HOME=/opt/libreoffice7.0
ENV TESSDATA_PREFIX=/opt/tesseract-4.1.0/tessdata
ENV PATH=$PATH:$JAVA_HOME/bin:$LIBREOFFICE_HOME/program:$TESSDATA_PREFIX

RUN echo -e "JAVA_HOME=/usr/local/java\n\
LIBRARY_PATH=/usr/local/lib\n\
LD_RUN_PATH=/usr/local/lib\n\
LD_LIBRARY_PATH=/usr/local/lib\n\
LIBLEPT_HEADERSDIR=/usr/local/include\n\
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig\n\
TESSDATA_PREFIX=/opt/tesseract-4.1.0/tessdata\n\
C_INCLUDE_PATH=/usr/local/include/leptonica\n\
export JAVA_HOME LIBRARY_PATH LD_RUN_PATH LD_LIBRARY_PATH LIBLEPT_HEADERSDIR PKG_CONFIG_PATH TESSDATA_PREFIX C_INCLUDE_PATH" >> /etc/bashrc 

EXPOSE 8080

CMD ["java","-version"]
