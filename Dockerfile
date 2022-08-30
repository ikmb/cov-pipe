FROM continuumio/miniconda3
LABEL authors="Marc Hoeppner" \
      description="Docker image containing all requirements for IKMB Virus pipeline"

COPY environment.yml /

RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/cov-1.0/bin:/opt/vt:$PATH

RUN apt-get -y update && apt-get -y install procps make gcc  git build-essential autotools-dev automake libsparsehash-dev libboost-all-dev \
cmake zlib1g-dev coreutils ruby sqlite-3 libsqlite3-dev

RUN gem install json=2.6.2 activerecord=7.0.3.1 zlib rest-client=2.1.0 sqlite3=1.4.4

RUN /opt/conda/envs/virus-pipe-1.3/bin/snpEff download NC_045512.2

RUN cd /opt && git clone https://github.com/atks/vt.git && cd vt \
	&& git checkout 0.577 && make
