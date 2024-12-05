# fpse-smt-solver
This repo is for FPSE project assignment.

`web-app` is for the whole application of this project

`sovler` will be a indepent home-brew library including SAT solver and Integer SMT solver

## Web App
The web app is built with Docker, and the docker image is based on x86_64. So please make sure your machine is based on x86_64.

### Prerequisite
- Docker

### Run the web app
```bash
cd web-app
docker compose build --no-cache
docker compose up
```
The web app will be available at `localhost:80`.
