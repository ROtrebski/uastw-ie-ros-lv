FROM ros:melodic
LABEL maintainer = "Richard Otrebski FHTW"
RUN apt update && \
    apt install -y\
    less htop nmon tmux gdb gosu\
    sudo libgl1-mesa-glx libgl1-mesa-dri git xterm curl\
    iproute2 iputils-ping synaptic bash-completion libboost-all-dev clang-format bc\
    imagemagick psmisc protobuf-compiler ros-melodic-dwa-local-planner\
    ros-melodic-costmap-2d ros-melodic-hector-gazebo* ros-melodic-global-planner\
    ros-melodic-turtlebot3* ros-melodic-navigation ros-melodic-pid\
    ros-melodic-rosdoc-lite ros-melodic-gmapping\
    && rm -rf /var/lib/apt/lists/

ENV USERNAME fhtw_user
ARG USER_ID=1000
ARG GROUP_ID=15214

RUN groupadd --gid $GROUP_ID $USERNAME && \
        useradd --gid $GROUP_ID -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        usermod  --uid $USER_ID $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME

RUN echo "export ROS_HOSTNAME=\"\$(hostname -I | awk '{print \$1;}')\"" >> /home/$USERNAME/.bashrc
RUN echo "export ROS_IP=\"\$(hostname -I | awk '{print \$1;}')\"" >> /home/$USERNAME/.bashrc
RUN echo 'echo "ROS_HOSTNAME=>$ROS_HOSTNAME<"' >> /home/$USERNAME/.bashrc
RUN echo 'echo "ROS_IP=>$ROS_IP<"' >> /home/$USERNAME/.bashrc


RUN git clone https://gitlab-mr.technikum-wien.at/otrebski/software.git /home/$USERNAME/fhtw_software
RUN bash /home/$USERNAME/fhtw_software/scripts/bash/install.sh -o &&\
    rm -rf /var/lib/apt/lists/ &&\
    rm -rf /home/$USERNAME/poco &&\
    rm -rf /home/$USERNAME/pistache &&\
    rm -rf /home/$USERNAME/opencv_*
RUN mkdir -p /home/$USERNAME/catkin_ws/src &&\
    cd /home/$USERNAME/catkin_ws/src &&\
    /ros_entrypoint.sh catkin_init_workspace &&\
    cd .. &&\
    /ros_entrypoint.sh catkin_make
RUN chown $USERNAME:$USERNAME --recursive /home/$USERNAME/catkin_ws
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/$USERNAME/.bashrc
RUN echo "source /home/$USERNAME/catkin_ws/devel/setup.bash" >> /home/$USERNAME/.bashrc
RUN pip3 install ipython
RUN pip2 install ipython

COPY ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT [ "/ros_entrypoint.sh" ]
