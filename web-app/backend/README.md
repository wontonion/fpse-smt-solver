docker build -t ocaml-back .
docker run -v $(pwd):/app/backend -p 8080:8080 ocaml-back