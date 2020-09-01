FROM lihebi/mylab-julia

USER root
# playgroud to add additional packages
# FIXME why I have to run update here??
# probably because apt and apt-get are different things
#
# But apt-get still didn't find the packages
# FIXME maybe apt-get update && xxx did not work?
#
RUN apt-get update
RUN apt-get install -y iputils-ping iproute2 htop locate libzmq5

# Install racket
RUN apt-get install -y software-properties-common &&\
        add-apt-repository ppa:plt/racket &&\
        apt-get update && \
        apt-get install -y racket

# iracket is under development, so I'm installing it at user's place for easy
# modifying
USER $NB_UID
RUN git clone https://github.com/lihebi/iracket $HOME/iracket
WORKDIR $HOME/iracket
RUN cd $HOME/iracket && git checkout dev

# FIXME these are not working
# RUN raco pkg install --batch --deps search-auto --auto --link
# RUN raco iracket install

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME
