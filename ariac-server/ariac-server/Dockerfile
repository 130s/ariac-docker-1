ARG UBUNTU_DISTRO
FROM ubuntu:${UBUNTU_DISTRO}

# Re-defining UBUNTU_DISTRO, as 'ARG's need to be defined after FROM, except the one meant to be passed to FROM https://stackoverflow.com/a/63086565/577001
ARG UBUNTU_DISTRO=focal
ARG ROSDISTRO="noetic"

# Hint to dpkg and apt that packages should be installed without asking for human intervention
ENV DEBIAN_FRONTEND noninteractive

# Need these before sources can be set up
RUN apt-get update \
 && apt-get install -y \
    gnupg2 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# setup keys and sources for official Gazebo and ROS debian packages
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D2486D2DD83DB69272AFE98867170598AF249743 \
 && echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $UBUNTU_DISTRO main" > /etc/apt/sources.list.d/gazebo-latest.list \
 && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
 && echo "deb http://packages.ros.org/ros/ubuntu ${ROSDISTRO} main" > /etc/apt/sources.list.d/ros-latest.list

# install ROS and Gazebo packages
RUN apt-get update && apt-get install -q -y \
    bash-completion \
    gazebo9 \
    libgazebo9-dev \
    locales \
    psmisc \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    ros-${ROSDISTRO}-robot-state-publisher \
    ros-${ROSDISTRO}-camera-info-manager \
    ros-${ROSDISTRO}-ros-control \
    ros-${ROSDISTRO}-ros-controllers \
    ros-${ROSDISTRO}-ros-core \
    ros-${ROSDISTRO}-image-transport \
    ros-${ROSDISTRO}-cv-bridge \
    ros-${ROSDISTRO}-joint-limits-interface \
    ros-${ROSDISTRO}-polled-camera \
    ros-${ROSDISTRO}-diagnostic-updater \
    ros-${ROSDISTRO}-transmission-interface \
    ros-${ROSDISTRO}-ros-base \
    ros-${ROSDISTRO}-moveit \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init

# Need to install a specific version of gazebo_ros_pkgs
# 1. Remove official packages
RUN export GZ_VERSION=9 && \
    dpkg -r --force-depends ros-${ROSDISTRO}-gazebo${GZ_VERSION}-ros-pkgs \
                            ros-${ROSDISTRO}-gazebo${GZ_VERSION}-ros \
                            ros-${ROSDISTRO}-gazebo${GZ_VERSION}-plugins \
                            ros-${ROSDISTRO}-gazebo${GZ_VERSION}-msgs \
                            ros-${ROSDISTRO}-gazebo${GZ_VERSION}-ros-control




# RUN /bin/bash -c "cd /tmp/ariac_ws/src && \
#                 git clone https://github.com/usnistgov/ARIAC.git"





# 3. Build the version from source
RUN mkdir -p /tmp/ros_ws/src
RUN /bin/bash -c "source /opt/ros/${ROSDISTRO}/setup.bash && \
                  cd /tmp/ros_ws/src && \
                  catkin_init_workspace"
# RUN git clone \
#       https://github.com/osrf/ariac-gazebo_ros_pkgs.git /tmp/ros_ws/src/gazebo_ros_pkgs \
#       -b ariac-network-${ROSDISTRO}

# RUN /bin/bash -c "source /opt/ros/${ROSDISTRO}/setup.bash && \
#                   cd /tmp/ros_ws/ && \
#                   catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/${ROSDISTRO} -j2 install "




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

# Get gazebo models early since it is big
RUN wget -P /tmp/ https://github.com/osrf/gazebo_models/archive/master.zip \
 && mkdir -p $HOME/.gazebo/models \
 && tar -xvf /tmp/default.tar.gz -C $HOME/.gazebo/models --strip 1 \
 && rm /tmp/default.tar.gz


 #Download and compile ARIAC 2020
 RUN mkdir -p /home/ariac/ariac_ws/src
 RUN mkdir -p /tmp/gazebo_ws

 RUN git clone \
      https://github.com/osrf/ariac-gazebo_ros_pkgs.git /tmp/gazebo_ws \
      -b ariac-network-${ROSDISTRO}
 RUN git clone https://github.com/usnistgov/ARIAC.git  /home/ariac/ariac_ws/src
 RUN /bin/bash -c "cp -rf /tmp/gazebo_ws /home/ariac/ariac_ws/src"

 RUN /bin/bash -c "source /opt/ros/${ROSDISTRO}/setup.bash && \
                   cd /home/ariac/ariac_ws && \
                   catkin_make"


# setup entrypoint
COPY ./ariac_entrypoint.sh /
#USER root
#RUN chmod +x /ariac_entrypoint.sh
COPY ./run_ariac_task.sh /
#RUN chmod +x /run_ariac_task.sh
#USER ariac

ENTRYPOINT ["/ariac_entrypoint.sh"]
