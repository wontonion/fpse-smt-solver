# fpse-smt-solver

This repo is for FPSE project assignment.

`web-app` is for the whole application of this project

`sovler` will be a indepent home-brew library including SAT solver and Integer SMT solver

## Web App

The web app is built with Docker, and the docker image is based on x86_64. So please make sure the host machine is based on x86_64.

### Prerequisite

- Docker

### Run the web app

```bash
cd web-app
docker compose build --no-cache
docker compose up
```

The web app will be available at `localhost:80`.

### Overview
The web app's backend is built with Dream and its frontend is built with ReScript.

### Progress Summary

#### Frontend Components

#### Sudoku Puzzle
- **Grid Specifications**
  - Supports both 4x4 and 9x9 grid sizes, offering flexibility for different difficulty levels
  - Features real-time validation with visual feedback:
    - Invalid number placements trigger red highlighting in affected row/column/block
    - Valid placements maintain normal cell appearance
  - Custom initialization capability allows players to set their own starting numbers
    - Input validation ensures all initial positions contain valid numbers
  - Performance safeguard: Solutions exceeding 10-second computation time trigger an error notification

#### SAT/SMT Solver Interface
- **User Interface Features**
  - Interactive textarea with guiding placeholders for proper formula formatting
  - Template management system:
    - Download template functionality for reference
    - Batch upload support for multiple problem sets
    - Automatic formula display in textarea upon successful upload

#### Backend Architecture
  - All API endpoints managed through the `Dream` framework
  - Pure OCaml implementation for Sudoku puzzle generation
  - Implements yielding between promises with timeout mechanism, which prevents server lockup during complex calculations.

#### Issues Encountered

1. **Timeouts**: The SAT solver can take a long time to solve some problems, which can cause the web app to reject other requests. We now achieve canceling promise using `Lwt`, but since canceling computation needs aggressive modification current helper functions. We haven't accomplished the genuine termination of computing task. 

## Solver Project

### Overview

The `solver` project is located in the `solver` directory and consists of four libraries and two command-line executables designed for solving SAT and SMT problems.

### Project Components

#### Libraries

- **`cdcl`**: Implements the Conflict-Driven Clause Learning (CDCL) algorithm for solving SAT problems.
  
- **`dimacs`**: A library for parsing standard [DIMACS CNF](https://jix.github.io/varisat/manual/0.2.0/formats/dimacs.html) formulas, used for reading SAT problem instances.

- **`smt`**: A simple SMT library that supports 16-bit BitVectors. It treats all BitVectors as `int16_t`, ignoring higher bits on overflow, and supports a limited set of operations.

- **`vm`**: A virtual machine representation for `int16_t` SMT problems, utilizing a stack-based approach. Detailed descriptions will be provided later.

#### Command-Line Executables

- **`sat_solver`**:
  - **Location**: `_build/default/solver/bin/sat_solver.exe`
  - **Function**: Reads DIMACS CNF formulas and outputs whether they are satisfiable, along with a possible assignment in DIMACS format.

- **`smt_solver`**:
  - **Location**: `_build/default/solver/bin/smt_solver.exe`
  - **Function**: Reads custom VM OpCodes and outputs whether the constraints can be satisfied, along with a possible assignment to the BitVectors.

### Running the Command-Line Executables

To build the project, use the following command:

```bash
dune build
```

#### SAT Solver

To run the SAT solver:

- **Read from standard input**:

  ```bash
  OCAML_LANDMARKS=on _build/default/solver/bin/sat_solver.exe < solver/test/files/timetable5.cnf
  ```

- **Provide a filename**:

  ```bash
  OCAML_LANDMARKS=on _build/default/solver/bin/sat_solver.exe solver/test/files/timetable5.cnf
  ```

#### SMT Solver

To run the SMT solver:

- **Read from standard input**:

  ```bash
  OCAML_LANDMARKS=on _build/default/solver/bin/smt_solver.exe < solver/test/files/example.smt
  ```

- **Provide a filename**:

  ```bash
  OCAML_LANDMARKS=on _build/default/solver/bin/smt_solver.exe solver/test/files/example.smt
  ```

### Progress Summary

#### Functional Components

1. **SAT CDCL Solver (`lib/cdcl`)**: This module previously experienced performance issues, which were resolved by changing the heuristic and adopting the two-watched literals optimization. These changes significantly increased the solver's speed.

2. **DIMACS Parsing Library (`lib/dimacs`)**: The DIMACS parsing library is fully functional and successfully parses DIMACS CNF formulas.

3. **Simple SMT Solver (`lib/smt`)**: The SMT module supports a limited set of operations: `XOR`, `AND`, `OR`, `NOT`, `EQ`, `NEQ0`, `GEQ0`, `LT0`, `ADD`, `SUB`, `SHL`, and `MUL`. It operates on `int16_t`, but the length can be easily adjusted to higher types (e.g., `int32_t`, `int64_t`).

4. **SMT Virtual Machine (`lib/vm`)**: This stack-based virtual machine adds constraints specified by each opcode and can represent and execute all operations supported by our SMT library.

#### Issues Encountered

1. **Help with timeout mechanism**: If the timeout cannot be implemented from the web app, we need to implement it in the solver itself.
2. **Support `MUL` between bitvectors**: Currently, only `MUL` between CONSTANT and Bitvector is allowed.

### Format Specification

#### DIMACS

The [DIMACS](https://jix.github.io/varisat/manual/0.2.0/formats/dimacs.html) format is straightforward.

The first line should be in the format: `p cnf [num of variables] [num of clauses]`, followed by clauses that are `0`-terminated.

For example, the formula `(x ∨ y ∨ ¬z) ∧ (¬y ∨ z)` can be represented as:

```text
p cnf 3 2
1 2 -3 0
-2 3 0
```

#### VM

This section describes our custom VM opcodes, which operate on stacks:

- `END`: Ends a constraint and ensures the stack is empty.
- `VAR n`: Pushes Bitvector `n` onto the stack.
- `CONST n`: Pushes constant `n` onto the stack.
- `XOR`: Pops two bitvectors from the stack and pushes the XORed result back.
- `AND`: Pops two bitvectors from the stack and pushes the ANDed result back.
- `OR`: Pops two bitvectors from the stack and pushes the ORed result back.
- `NOT`: Pops one bitvector from the stack and pushes the NOTed result back.
- `EQ`: Pops two bitvectors from the stack and adds a constraint that they are equal.
- `NEQ0`: Pops one bitvector from the stack and adds a constraint that it is not equal to 0.
- `GEQ0`: Pops one bitvector from the stack and adds a constraint that it is greater than 0.
- `LT0`: Pops one bitvector from the stack and adds a constraint that it is less than 0.
- `ADD`: Pops two bitvectors from the stack and pushes the added result back.
- `SUB`: Pops two bitvectors from the stack and pushes the subtracted result back.
- `SHL n`: Pops one bitvector from the stack and pushes the shifted result back.
- `MUL n`: Pops one bitvector from the stack and pushes the multiplied result back.
