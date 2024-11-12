FROM ubuntu:22.04

USER root

RUN apt-get update
RUN apt install opam -y
RUN apt-get install libev-dev libgmp-dev libssl-dev pkg-config -y

# RUN useradd -ms /bin/bash opam
# USER opam
# WORKDIR /home/opam

RUN opam init --disable-sandboxing -y

RUN opam switch create 5.2.0
RUN eval $(opam env)

RUN opam install -y \
    dune \
    dream \
    lwt \
    core \
    ppx_jane \    
    && opam clean

# RUN opam install -y landmarks

WORKDIR /app/backend

# ENV PATH=/home/opam/.opam/5.2.0/bin:$PATH

# COPY --chown=opam:opam . .

# EXPOSE 8080

# CMD ["dune", "exec", "./bin/main.exe"]·

