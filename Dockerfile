FROM ubuntu:16.04

# ENV로 환경변수 등록시 컨테이너에서 echo를 통해서 확인 가능. 비밀번호 등의 민감한 정보는 등록하지 말 것
# Hadoop 세팅을 위한 환경변수 등록을 위해서 사용 가능하지만 과제 제출시 학생들 컨닝 위험 있으므로 직접 텍스트 편집할때는 sed 사용 권장
ENV USER_NAME=hadoopdocker
ENV HOME=/home/${USER_NAME}


# install require pakage
RUN apt-get update -y && \
    apt-get install -y vim wget rsync openssh-server openssh-client sudo net-tools


# install java
RUN mkdir /usr/lib/jvm && \
    wget -q -P /usr/lib/jvm/ --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/11.0.2+7/f51449fcd52f4d52b93a989c5c56ed3c/jdk-11.0.2_linux-x64_bin.tar.gz && \
    tar -xf /usr/lib/jvm/jdk-11.0.2_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    rm /usr/lib/jvm/jdk-11.0.2_linux-x64_bin.tar.gz


# root password setting
# user add and user password setting
# user can use sudo command without password
RUN echo "root:rootpass" | chpasswd && \
    useradd ${USER_NAME} -m -s /bin/bash && \
    echo "${USER_NAME}:userpass" | chpasswd && \
    adduser ${USER_NAME} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}


# ssh root access permission
# RUN sed -i '/^#/!s/PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config


# user login
USER ${USER_NAME}
WORKDIR ${HOME}

# ssh login without password
RUN mkdir .ssh && \
    ssh-keygen -t rsa -P '' -f .ssh/id_rsa && \
    cp .ssh/id_rsa.pub .ssh/authorized_keys && \
    chmod 600 .ssh/authorized_keys


# java env (use dockerfile ENV)
# ENV JAVA_HOME /usr/lib/jvm/jdk-11.0.2
# ENV PATH $PATH:$JAVA_HOME/bin:$PATH
# ENV CLASS_PATH=$JAVA_HOME/lib:$CLASS_PATH


# java env (edit bashrc)
RUN echo "export JAVA_HOME=/usr/lib/jvm/jdk-11.0.2" >> ~/.bashrc && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc && \
    echo "export CLASS_PATH=\$JAVA_HOME/lib:\$CLASS_PATH" >> ~/.bashrc && \
    /bin/bash -c "source $HOME/.bashrc"
    

# download hadoop
RUN wget -q http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz && \
    tar -xf hadoop-2.9.2.tar.gz && \
    rm hadoop-2.9.2.tar.gz


# hadoop env (use dockerfile ENV)
# HADOOP_HOME은 ADD를 위해서 enable
ENV HADOOP_HOME /home/${USER_NAME}/hadoop-2.9.2
# ENV HADOOP_PREFIX $HADOOP_HOME
# ENV HADOOP_COMMON_HOME $HADOOP_HOME
# ENV HADOOP_HDFS_HOME $HADOOP_HOME
# ENV HADOOP_MAPRED_HOME $HADOOP_HOME
# ENV HADOOP_YARN_HOME $HADOOP_HOME
# ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
# ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop
# ENV PATH $PATH:$JAVA_HOME/bin:$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH


# hadoop-env.sh (edit .sh)
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/jdk-11.0.2\nexport HADOOP_HOME=/home/hadoopdocker/hadoop-2.9.2\nexport HADOOP_PREFIX=$HADOOP_HOME\nexport HADOOP_MAPRED_HOME=$HADOOP_HOME\nexport HADOOP_COMMON_HOME=$HADOOP_HOME\nexport HADOOP_HDFS_HOME=$HADOOP_HOME\nexport YARN_HOME=$HADOOP_HOME:' /home/${USER_NAME}/hadoop-2.9.2/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop\nexport YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop:' /home/${USER_NAME}/hadoop-2.9.2/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/jdk-11.0.2\nexport HADOOP_HOME=/home/hadoopdocker/hadoop-2.9.2:' /home/${USER_NAME}/.bashrc && \
    sed -i '/^export PATH/ s:.*:export PATH=$JAVA_HOME/bin\:$HADOOP_HOME/bin\:$HADOOP_HOME/sbin\:$PATH:' /home/${USER_NAME}/.bashrc && \
    /bin/bash -c "source $HOME/.bashrc" && \
    mkdir hadoop-2.9.2/hdfs


# upload slaves, core-site.xml, hdfs-site.xml, mapred-site.xml, yarn-site.xml
ADD pseudo_distributed/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD pseudo_distributed/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD pseudo_distributed/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD pseudo_distributed/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD pseudo_distributed/slaves $HADOOP_HOME/etc/hadoop/slaves


# HDFS ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000


# Mapred ports
EXPOSE 10020 19888


# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088


# Other ports
EXPOSE 49707 2122


# start ssh service
# ssh 서비스 실행(ssh 접속 활성화)
ENTRYPOINT sudo service ssh start && bash
