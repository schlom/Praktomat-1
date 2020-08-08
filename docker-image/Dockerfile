FROM debian:buster

MAINTAINER Armin Lehmann

# set up new user
RUN echo "praktomat:x:1001:1001:,,,:/home/praktomat:/bin/bash" >> /etc/passwd
RUN echo "praktomat:x:1001:tester" >> /etc/group

# We use a fresh tmpfs with /home in each container
RUN chmod 1777 /home

RUN apt-get --yes update
RUN apt-get -y install dialog
RUN apt-get -y install libipc-run-perl libdata-guid-perl libterm-readline-gnu-perl
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install --yes ca-certificates-java
RUN apt-get install --yes openjdk-11-jdk junit junit4 dejagnu && apt-get clean

# Python-Stuff
RUN apt-get update -y
RUN apt-get install --yes python3            python               && apt-get clean
RUN apt-get install --yes                    ipython              && apt-get clean
RUN apt-get install --yes python3-requests                        && apt-get clean
RUN apt-get install --yes python3-pip                             && apt-get clean
RUN apt-get install --yes python3-six        python-six           && apt-get clean
RUN apt-get install --yes python3-responses                       && apt-get clean
RUN apt-get install --yes python3-xlrd                            && apt-get clean
RUN apt-get install --yes python3-simplejson python-simplejson    && apt-get clean

################ISABELLE#################
# Install Isabelle2019
#RUN apt-get install --yes curl libc6-i386 lib32stdc++6  && apt-get clean
#RUN curl http://isabelle.in.tum.de/dist/Isabelle2019_linux.tar.gz | tar -C /opt -xz
#RUN ln -s /opt/Isabelle2019/bin/isabelle /usr/local/bin
#RUN isabelle build -bv HOL
#########################################

###################SCALA###################
# needs to be enabled if the Scala Checker is used
#RUN apt-get install --yes wget && apt-get clean
#ENV SCALA_VERSION 2.11.7
#ENV SBT_VERSION 0.13.12
#ENV SBT_OPTS -Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M -Duser.timezone=GMT

# install sbt
#RUN wget https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb
#RUN dpkg -i sbt-$SBT_VERSION.deb

# install scala
#RUN wget https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.deb
#RUN dpkg -i scala-$SCALA_VERSION.deb
#RUN sbt
#########################################

###################GHC###################
#RUN apt-get install --yes ghc libghc-test-framework-dev libghc-test-framework-hunit-dev libghc-test-framework-quickcheck2-dev
#########################################

#########################################
# checkstyle and jPlag
COPY /contrib/checkstyle-8.29-all.jar /srv/praktomat/contrib/checkstyle-8.29-all.jar
COPY /contrib/jplag-2.12.1-SNAPSHOT-jar-with-dependencies.jar /srv/praktomat/contrib/jplag-2.12.1-SNAPSHOT-jar-with-dependencies.jar
#########################################

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64