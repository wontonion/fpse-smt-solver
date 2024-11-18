# SAT/SMT Solver Design Proposal
## 1. Overview
This project first builds a SAT(Boolean Satisfiability Problme) solver and an integer SMT(Satisfiablity Modulo Theories) solver based on SAT solver. For facility using of these solvers, a signle-page web application will be implemented.

Overall, we are planning to build up a website to for three main functions: 
1. Solving SAT problem with proper input and output 
2. Solving SMT problem with proper input and output
3. Solving Sudoku with SAT solver 


## 2. Mock Use
### 2.1 Graphical User Interface(webpage)

#### SAT problem solver:
1. Users can enter their problem expression by clicking buttons or manually 
2. Users can upload a `.txt` file with given format to make batch input
3. Once the input experssion/file is valid, the reading of input will show up on the web page
4. There will be a warning if any kinds of inputs are problematic
5. If the given input is valid, a "solve" button will be activate
6. User can click "solve" button. Once clicked, a request of solving input SAT expression will be sent to backend
7. The backend will calculate via SAT solver algorithm the correct answer
8. Once the solution come out, the solution will be displayed on the web page

#### Integer SMT problem solver:
1. There will be a switch to choose whether the input indicates a SAT problem or SMT problem
2. The input of SMT is limitted to integer

#### Sudoku solver:
1. When user enter Sudoku playground interface, a default 9*9 grid will be generated with numbers
2. User can change the size of grid, once the size is changed, new numbers on the grid will be generate
3. Once all blanks is filled, the website will trigger the SAT solver to check whether the sudoku is correct
4. User can also directly choose to reveal the solution by a button if they don't want to or unable to finish the sudoku

### 2.2 Describe of SAT/SMT solution with Ocaml
If the basis of your project is just some hard algorithm, take this chance to describe the algorithm and how OCaml will work with it. Show example uses and discuss desired performance.

## 3. Libraries and Tools

### ReScript
ReScript is a strongly-typed programming language that compiles to clean, readable JavaScript code. This project will use ReScript to build up graphic interface for interacting with users. 

Follow command below to run demo of ReScript:
```bash
cd web-app/frontend

# use JavaScript package manage to install package, here I use pnpm 
pnpm install

# Then compile ReScript file to JavaScript file
pnpm run res:dev 

# Then open a new tab in terminal at the same folder 
pnpm run dev

# the last command will open run vite at port 5173
```

### Dream
Dream is a fast, feature-rich web framework for OCaml that offers a tidy interface for building web applications. This project uses Dream to communicate with user input and SAT/SMT solver.

Follow command below to run demo of Dream:
```bash
cd web-app/backend
# If dune tool has been properly installed
dune exec backend

# The last command invoke dream at port 8080
```

### landmarks
Landmarks is a simple OCaml profiling library with a PPX extension that allows developers to mark specific code sections for performance measurement and analysis.

Follow command below to run demo of landmarks:
```bash
cd demo
OCAML_LANDMARKS=on _build/default/landmarks/main.exe
```

A code profilling tool


## 4. Implementation Schedule
| Event | Scheduled End Date | Actual End Date |
|--------|------------------|----------------|
| Complete Design Proposal | 11/13/2024 | |
| Phase 1 Development:<br>Frontend - Implement SAT Problem Interface and Backend Integration<br>Backend - Establish Frontend Connection and Data Processing Pipeline<br>Algorithm - Develop Core SAT Solver | 11/20/2024 | |
| Phase 2 Development:<br>Frontend - Implement Sudoku Solver Interface<br>Backend - Develop Sudoku Generator<br>Algorithm - Complete SAT Solver Testing | 11/27/2024 | |
| System Testing:<br>Frontend & Backend Integration Testing and Code Review | 12/4/2024 | |
| Phase 3 Development:<br>Frontend - Implement Integer SMT Interface<br>Backend - Develop SMT Request Handler<br>Algorithm - Develop Integer-to-SAT Conversion Module | 12/11/2024 | |
| Complete System Testing and Integration | 12/17/2024 | |
| Final Demo and Project Presentation | 12/18/2024 | |
