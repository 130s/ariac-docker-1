ARG UBUNTU_DISTRO
FROM ubuntu:${UBUNTU_DISTRO}

# Re-defining UBUNTU_DISTRO, as 'ARG's need to be defined after FROM, except the one meant to be passed to FROM https://stackoverflow.com/a/63086565/577001
ARG UBUNTU_DISTRO=focal
ARG ROSDISTRO="noetic"

# Hint to dpkg and apt that packages should be installed without asking for human intervention
ENV DEBIAN_FRONTEND noninteractive

# Need these before sources can be set up
RUN apt-get update \
 && apt-get install -y gnupg2 \
 # setup keys and sources for official Gazebo and ROS debian packages
 && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D2486D2DD83DB69272AFE98867170598AF249743 \
 && echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $UBUNTU_DISTRO main" > /etc/apt/sources.list.d/gazebo-latest.list \
 && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
 && echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_DISTRO main" > /etc/apt/sources.list.d/ros-latest.list \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# install OS tools
RUN apt-get update && apt-get install -q -y \
    bash-completion \
    locales \
    psmisc \
    python3-rosdep \
    python3-vcstool \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init

# Expose port used to communicate with gzserver
EXPOSE 11345

# Stuff for nvidia-docker
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# Set encoding to use unicode characters
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create a new user called ariac. Note: we don't add them to the sudo group
ENV USERNAME ariac
ARG USERID=1000
RUN adduser -u $USERID --gecos "Development User" --disabled-password $USERNAME
RUN echo "export QT_X11_NO_MITSHM=1" >> /home/$USERNAME/.bashrc

USER $USERNAME
WORKDIR /home/$USERNAME

ENV CWS_ARIAC=/home/ariac/ariac_ws/
# Get gazebo models early since it is big
##RUN wget -P /tmp/ https://github.com/osrf/gazebo_models/archive/master.zip \
## && mkdir -p $HOME/.gazebo/models \
## && tar -xvf /tmp/default.tar.gz -C $HOME/.gazebo/models --strip 1 \
## && rm /tmp/default.tar.gz


 #Download and compile ARIAC 2020
 RUN mkdir -p $CWS_ARIAC/src
 RUN mkdir -p /tmp/gazebo_ws

 RUN git clone \
      https://github.com/osrf/ariac-gazebo_ros_pkgs.git /tmp/gazebo_ws \
      -b ariac-network-melodic  # This won't work for Noetic as Noetic version doesn't seem to be made yet.
 RUN git clone https://github.com/usnistgov/ARIAC.git  $CWS_ARIAC/src
 RUN /bin/bash -c "cp -rf /tmp/gazebo_ws $CWS_ARIAC/src"

 RUN /bin/bash -c "source /opt/ros/${ROSDISTRO}/setup.bash && \
                   cd $CWS_ARIAC && \
                   rosdep install -y --from-paths src --ignore-src && \
                   catkin_make"

# setup entrypoint
COPY ./ariac_entrypoint.sh /
#USER root
#RUN chmod +x /ariac_entrypoint.sh
COPY ./run_ariac_task.sh /
#RUN chmod +x /run_ariac_task.sh
#USER ariac

ENTRYPOINT ["/ariac_entrypoint.sh"]
