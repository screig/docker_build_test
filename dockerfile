# Container image that runs your code
ARG ROOT_CONTAINER=krallin/ubuntu-tini:bionic
ARG BASE_CONTAINER=$ROOT_CONTAINER
FROM $BASE_CONTAINER


LABEL maintainer="Sean Creighton <sean.creighton@gmail.com.com>"
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install most things as root
USER root

# Write out the linux version
RUN cat /etc/*release

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    apt-utils \
    locales \
    fonts-liberation \
    run-one \
	software-properties-common \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8


# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc 


# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME 


###################################################################
## Install all OS dependencies for fully functional notebook server
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    build-essential \
    emacs-nox \
    vim-tiny \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    python3-dev \
	python3-pip \
    # ---- nbconvert dependencies ----
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    # ----
    tzdata \
    unzip \
    nano-tiny \
 && apt-get clean && rm -rf /var/lib/apt/lists/*





###################################################################
## Install all OS dependencies 
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
	# ---- We need this in order to be able to pip install jupyterhub
	npm \
	nodejs \ 
	# ---- We need this in order to be able to pip install psycopg2
	libpq-dev \
	# ---- We need this in order to be able to pip install matplotlib
	libftgl-dev \
	libfreetype6-dev \
	# ---- We need this in order to be able to pip install pyodbc	
	unixodbc-dev \
	# ---- We need this in order to be able to pip install cffi	
	libffi-dev \
	# ---- We need this in order to be able to pip install 
	libxml2-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN npm install -g configurable-http-proxy



###################################################################
# Sort out the version of python are we running
RUN which python
RUN ls /usr/bin/python*
RUN python --version
RUN python3 --version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 10
RUN python --version

# Sort out the version of pip are we running
RUN pip3 --version
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
RUN pip --version

# Upgrade pip
RUN pip install -U pip 
RUN pip --version



###################################################################
##	Switch to the local user
USER $NB_UID
WORKDIR /home/$NB_USER


pip list




































