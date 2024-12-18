# OCaml Backend
To run backend locally, you can use the following commands:
```bash
dune build
dune exec backend
```

To run backend in docker, you can use the following commands:
```bash 
docker build -t ocaml-backend .
docker run -v $(pwd):/app/backend -p 8080:8080 ocaml-backend
```


