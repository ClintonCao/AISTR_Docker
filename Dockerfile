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


ARG DEBIAN_FRONTEND=noninteractive
ARG BRANCH=master
RUN apt-get install -y python3-dev virtualenvwrapper python3-pip python3-venv
RUN python3 -m venv angr
RUN pip3 install angr

### Install KLEE ######
COPY klee-install.sh .
RUN chmod +x klee-install.sh
RUN ./klee-install.sh


###################################
######  DOWNLOAD EVOSUITE  ########
###################################
RUN wget https://github.com/EvoSuite/evosuite/releases/download/v1.1.0/evosuite-standalone-runtime-1.1.0.jar

###################################
######   DOWNLOAD ASTOR    ########
###################################
RUN git clone https://github.com/SpoonLabs/astor.git
RUN cd astor && mvn install -DskipTests=true && mvn package -DskipTests=true 

#############################################
######   DOWNLOAD ASSIGNMENT CODE    ########
#############################################
RUN git clone https://github.com/apanichella/JavaInstrumentation.git
RUN cd JavaInstrumentation && mvn clean package

###############################################################
######   DOWNLOAD RERS LTL AND REACHABILITY PROBLEMS   ########
###############################################################
RUN mkdir RERS
RUN cd RERS && wget http://rers-challenge.org/2020/problems/sequential/SeqReachabilityRers2020.zip \
	        && wget http://rers-challenge.org/2020/problems/sequential/SeqLtlRers2020.zip \
	        && unzip SeqReachabilityRers2020.zip && unzip SeqLtlRers2020.zip \
	        && rm SeqReachabilityRers2020.zip && rm SeqLtlRers2020.zip




