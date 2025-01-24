FROM gemfield/torchpod
LABEL maintainer="gemfield@civilnet.cn"

ARG GIT_USER=Gemfield
ARG GIT_EMAIL=gemfield@civilnet.cn
#workaround, just delete (or uncomment) it in your local environment.
#COPY apt.conf /etc/apt/apt.conf
  
RUN apt update && \
    apt dist-upgrade -y && \
    apt install -y gperf gcc-multilib g++-multilib gcc-arm-none-eabi git-lfs python3-pip bison flex liblz4-dev liblz4-tool libc-dev libc6-dev-i386 \
    default-jdk openjdk-21-jdk abootimg libelf-dev libxcursor-dev libxrandr-dev libxinerama-dev lib32ncurses-dev libtinfo6 ccache xsltproc gnutls-bin \
    x11proto-core-dev libx11-dev lib32z1-dev genext2fs u-boot-tools mtools mtd-utils scons libgl1-mesa-dev libgles2-mesa-dev mesa-common-dev libegl1-mesa-dev && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED && \
    mkdir -p /usr/local/bin/ && \
    ln -s /usr/bin/python3 /usr/bin/python
    
RUN curl -s https://gitee.com/oschina/repo/raw/fork_flow/repo-py3 > /usr/local/bin/repo && chmod a+x /usr/local/bin/repo

RUN pip3 install -i https://repo.huaweicloud.com/repository/pypi/simple requests && \
    pip3 install -i http://repo.huaweicloud.com/repository/pypi/simple rich

RUN git config --global user.name ${GIT_USER} && \
    git config --global user.email ${GIT_EMAIL} && \
    git config --global credential.helper store

RUN /gemfield/clean.sh
