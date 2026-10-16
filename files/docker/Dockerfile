FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

# Install build prerequisites, runtime dependencies, and OpenJDK 21 directly from Debian repos
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    ant \
    wget \
    curl \
    unzip \
    openjdk-21-jdk \
    libfontconfig1 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libsqlite3-dev \
    zlib1g-dev \
    libewf-dev \
    libvhdi-dev \
    libqcow-dev \
    libafflib-dev \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Accept build arguments and persist them
ARG AUTOPSY_VERSION=4.23.1
ENV AUTOPSY_VERSION=${AUTOPSY_VERSION}
ARG SLEUTHKIT_VERSION=4.15.0

# Download and set up Autopsy
RUN wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-${AUTOPSY_VERSION}/autopsy-${AUTOPSY_VERSION}.zip -O /tmp/autopsy.zip \
    && unzip -q /tmp/autopsy.zip -d /opt/ \
    && chmod +x /opt/autopsy-${AUTOPSY_VERSION}/bin/autopsy \
    && sed -i 's|default_options="|default_options="-J-Djava.library.path=/usr/local/lib |g' /opt/autopsy-${AUTOPSY_VERSION}/etc/autopsy.conf \
    && rm /tmp/autopsy.zip

# Build and install The Sleuth Kit from release tarball, and copy JNI files into Autopsy
RUN wget https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-${SLEUTHKIT_VERSION}/sleuthkit-${SLEUTHKIT_VERSION}.tar.gz -O /tmp/sleuthkit.tar.gz \
    && tar -xzf /tmp/sleuthkit.tar.gz -C /tmp/ \
    && cd /tmp/sleuthkit-${SLEUTHKIT_VERSION} \
    && ./configure --enable-java \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    # Copy TSK jar and native libraries directly into the versioned Autopsy module path
    && mkdir -p /opt/autopsy-${AUTOPSY_VERSION}/autopsy/modules/ext/ \
    && cp /usr/local/share/java/sleuthkit*.jar /opt/autopsy-${AUTOPSY_VERSION}/autopsy/modules/ext/ 2>/dev/null || true \
    && find /usr/local/lib -name "libtsk_jni*" -exec cp {} /opt/autopsy-${AUTOPSY_VERSION}/autopsy/modules/ext/ \; \
    && rm -rf /tmp/sleuthkit*

CMD /opt/autopsy-${AUTOPSY_VERSION}/bin/autopsy --jdkhome /usr/lib/jvm/java-21-openjdk-amd64