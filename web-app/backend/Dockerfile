# FROM ubuntu:22.04

# USER root

# RUN apt-get update
# RUN apt install opam -y
# RUN apt-get install libev-dev libgmp-dev libssl-dev pkg-config -y

# # RUN useradd -ms /bin/bash opam
# # USER opam
# # WORKDIR /home/opam

# RUN opam init --disable-sandboxing -y

# RUN opam switch create 5.2.0 && eval $(opam env)

# RUN opam install -y \
#     dune \
#     dream \
#     lwt \
#     core \
#     ppx_jane \    
#     landmarks \
#     && opam clean

# WORKDIR /app/backend

# ENV PATH=/home/opam/.opam/5.2.0/bin:$PATH

# COPY --chown=opam:opam . .

# EXPOSE 8080

# # CMD ["dune", "exec", "./bin/main.exe"]·

# # Create a startup script
# RUN echo '#!/bin/sh\ndune exec backend' > /start.sh && \
#     chmod +x /start.sh

# # Use the startup script
# CMD ["/start.sh"]


FROM ubuntu:22.04

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libev-dev \
    libgmp-dev \
    libssl-dev \
    pkg-config \
    opam \
    m4 \
    git \
    curl \
    unzip \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*

# Create and switch to opam user
RUN useradd -ms /bin/bash opam
USER opam
WORKDIR /home/opam

# Initialize opam with proper environment
RUN opam init --disable-sandboxing -y
RUN opam switch create 5.2.0
RUN eval $(opam env)

# Set up PATH and environment variables
ENV OPAM_SWITCH_PREFIX=/home/opam/.opam/5.2.0
ENV CAML_LD_LIBRARY_PATH=/home/opam/.opam/5.2.0/lib/stublibs:/home/opam/.opam/5.2.0/lib/ocaml/stublibs:/home/opam/.opam/5.2.0/lib/ocaml
ENV OCAML_TOPLEVEL_PATH=/home/opam/.opam/5.2.0/lib/toplevel
ENV PATH=/home/opam/.opam/5.2.0/bin:$PATH

# Install OCaml packages
RUN eval $(opam env) && \
    opam install -y \
    dune \
    dream \
    lwt \
    core \
    ppx_jane \
    landmarks \
    yojson \
    ppx_deriving_yojson \
    && opam clean

# Create app directory and set permissions
USER root
RUN mkdir -p /app/backend && chown -R opam:opam /app
USER opam

WORKDIR /app/backend

# Copy application files
COPY --chown=opam:opam . .

# Build the project
RUN eval $(opam env) && \
    dune build

EXPOSE 8080

# Create startup script
USER root
RUN echo '#!/bin/bash\neval $(opam env)\nexec dune exec backend' > /start.sh && \
    chmod +x /start.sh

USER opam
CMD ["/start.sh"]