FROM continuumio/miniconda3
LABEL authors="Marc Hoeppner" \
      description="Docker image containing all requirements for IKMB Virus pipeline"

COPY environment.yml /

RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/cov-1.0/bin:/opt/vt:$PATH

RUN apt-get -y update && apt-get -y install procps make gcc  git build-essential autotools-dev automake libsparsehash-dev libboost-all-dev \
cmake zlib1g-dev coreutils ruby ruby-dev sqlite3 libsqlite3-dev openjdk-8-jdk

RUN gem install json -v 2.6.2 
RUN gem install activerecord -v 7.0.3.1 
RUN gem install zlib
RUN gem install rest-client -v 2.1.0 
RUN gem install sqlite3 -v 1.4.4

RUN /opt/conda/envs/cov-pipe-1.0/bin/snpEff download NC_045512.2

RUN cd /opt && git clone https://github.com/atks/vt.git && cd vt \
	&& git checkout 0.577 && make
