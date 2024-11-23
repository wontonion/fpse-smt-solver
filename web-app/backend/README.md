docker build -t ocaml-back .
docker run -v $(pwd)/data:/app/backend -p 8080:8080 ocaml-back