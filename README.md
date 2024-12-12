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


## Solver

### Library directory

The SAT Solver is located in `solver` directory.
```bash
dune build
dune test
```

### Run command line SAT solver
```bash
cd solver
dune build
OCAML_LANDMARKS=on _build/default/bin/main.exe < test/files/timetable5.cnf
```
The input can any valid DIMACS format CNF formulas, please pipe it to `stdin`.
The SAT solver will output the assignment on `stdout`.

Here’s a more formal and clearer version of your project progress summary:

### Progress Summary

#### Functional Components

1. **SAT CDCL Solver (`lib/cdcl`)**: The SAT CDCL solver is operational, but its effectiveness is limited to small formulas. It can efficiently identify a valid assignment when multiple solutions exist. However, in instances where the formula has a single solution or is unsatisfiable, the solver experiences significant delays.

2. **DIMACS Parsing Library (`lib/dimacs`)**: The DIMACS parsing library is fully functional and is capable of parsing DIMACS CNF formulas successfully.

3. **Sudoku Solver**: The Sudoku solver effectively resolves the `sudoku.cnf` file and subsequently converts the output back to a Sudoku format. This can be implemented very easily once the performance issues with the SAT solver are addressed.

#### Issues Encountered

1. **Performance of SAT Solver on Larger Formulas**: The SAT solver struggles with larger formulas (e.g., `test/files/sudoku.cnf`). A comparison between the OCaml implementation and its Python counterpart reveals that the OCaml version is at least five times slower. This discrepancy may be due to excessive data copying or a potential bug in the implementation causing an infinite loop. Another approach to mitigate this issue could involve solving smaller Sudoku instances, such as 4x4 or 6x6 grids.

2. **Frontend and Backend Integration**: The frontend functionality for solving has not yet been integrated with the backend handlers. Consequently, the solving button is currently non-functional.

3. **Integer Linear Programming**: Only the definition of functions available as of now.
