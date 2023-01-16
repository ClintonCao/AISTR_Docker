FROM ubuntu:20.04

#######################################
##########  INSTALL JAVA #############
#######################################
RUN apt-get update && apt-get install -y openjdk-8-jdk

#######################################
##########  INSTALL MAVEN #############
#######################################
RUN apt-get install -y maven


##########################################
######  INTALL SOME DEPENDENCIES  ########
##########################################
RUN apt-get update && apt-get -y upgrade &&\
	apt-get -y install git build-essential zlib1g-dev \
			   libncurses5-dev libgdbm-dev libnss3-dev \
			   libssl-dev libreadline-dev libffi-dev wget unzip


##############################
######  INSTALL ANGR  ########
##############################
ARG DEBIAN_FRONTEND=noninteractive
ARG BRANCH=master
RUN apt-get install -y python3-dev virtualenvwrapper python3-pip python3-venv \
	&& pip3 install angr tqdm

############################
######  INSTALL KLEE  ######
############################
COPY klee-install.sh /root
RUN cd /root \
	&& chmod +x klee-install.sh \
	&& ./klee-install.sh

###################################
######  DOWNLOAD EVOSUITE  ########
###################################
RUN cd /root \
	&& wget https://github.com/EvoSuite/evosuite/releases/download/v1.1.0/evosuite-standalone-runtime-1.1.0.jar

###################################
######   DOWNLOAD ASTOR    ########
###################################
RUN cd /root \
	&& git clone https://github.com/SpoonLabs/astor.git \
	&& cd astor && mvn install -DskipTests=true && mvn package -DskipTests=true 

#############################################
######   DOWNLOAD ASSIGNMENT CODE    ########
#############################################
RUN cd /root \
	&& git clone https://github.com/apanichella/JavaInstrumentation.git \
	&& cd JavaInstrumentation \
	&& mvn clean package

###############################################################
######   DOWNLOAD RERS LTL AND REACHABILITY PROBLEMS   ########
###############################################################
RUN cd /root \
	&& mkdir RERS \
	&& cd RERS \
	&& wget http://rers-challenge.org/2020/problems/sequential/SeqReachabilityRers2020.zip \
	&& wget http://rers-challenge.org/2020/problems/sequential/SeqLtlRers2020.zip \
	&& unzip SeqReachabilityRers2020.zip && unzip SeqLtlRers2020.zip \
	&& rm SeqReachabilityRers2020.zip && rm SeqLtlRers2020.zip	

#############################################
######   DOWNLOAD AND INSTALL AFL   #########
#############################################
RUN cd /root \
	&& mkdir AFL \
	&& cd AFL \
	&& wget https://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz \
	&& tar -xvzf afl-latest.tgz\
	&& cd afl-2.52b && make -j `nproc` \
	&& cd .. && rm afl-latest.tgz

### Move the folders to /home/str for easier access as volume
RUN mkdir /home/str \
	&& mv /root/* /home/str \
	&& chmod -R a+rwx /home/str

ENTRYPOINT ["/bin/bash"]
