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

### 2.2 Description of Conflict-Driven Clause Learning (CDCL) Algorithm

If the basis of your project is just some hard algorithm, take this chance to describe the algorithm and how OCaml will work with it. Show example uses and discuss desired performance.

The Boolean Satisfiability Problem (SAT) is a fundamental question in computer science: given a boolean formula, can we find an assignment of its variables that makes the formula evaluate to true? This problem is known to be NP-Complete, meaning that, in the worst case, it can take an exponential amount of time to solve. However, many real-world problems often exhibit structures that can be leveraged to improve search efficiency.

In this project, we will explore the Conflict-Driven Clause Learning (CDCL) algorithm, a modern SAT solver that significantly enhances the search process compared to earlier methods, such as the Davis-Putnam-Logemann-Loveland (DPLL) algorithm developed in the 1960s.

#### Overview of CDCL

CDCL builds on the foundation laid by DPLL but introduces several key innovations:

- Clause Learning: When CDCL encounters a conflict (i.e., a situation where no variable assignment can satisfy the formula), it analyzes the decisions and implications that led to this conflict. By constructing an implication graph, it identifies a new clause that represents this learned information. This clause is added to the formula, allowing the solver to avoid similar conflicts in the future.
- Non-Chronological Backtracking: Unlike DPLL, which can only backtrack one level when a conflict is reached, CDCL can backtrack multiple levels. This ability to skip over large sections of the search space is critical for improving performance, especially in complex formulas.
- Boolean Constraint Propagation (BCP): CDCL employs BCP extensively, automatically inferring variable assignments based on the current state of the formula. This process helps in simplifying the formula and quickly identifying unit clauses that must be satisfied.

#### How CDCL Works

The algorithm operates as follows:

- Initialization: Start with an empty assignment of variables.
- BCP Execution: Continuously apply BCP to deduce variable assignments until no more unit clauses can be found.
- Decision Making: If the formula is still undecided, select an unassigned variable and attempt to assign it true or false, recursively applying the CDCL process.
- Conflict Resolution: Upon encountering a conflict, construct the implication graph, learn a new clause, and perform non-chronological backtracking to a decision point that allows for exploration of new possibilities.
- Repeat: Repeat the process, until all variables are assigned.

#### How OCaml will work with it

OCaml is particularly well-suited for implementing the Conflict-Driven Clause Learning (CDCL) algorithm:

- Higher-Order Functions: These allow for the creation of flexible and reusable components, such as abstractions for heuristics, decision-making and conflict resolution. This enhances code modularity and readability, making it easier to implement complex logic.
- Pattern Matching: OCaml’s powerful pattern matching capabilities simplify the handling of different states within the algorithm. This feature allows us to easily distinguish between satisfied clauses, conflicts, and undecided variables, reducing the likelihood of errors.
- Code Clarity and Robustness: The combination of higher-order functions and pattern matching promotes clearer code and more maintainable implementations. This results in a more efficient SAT solver that effectively tackles complex Boolean formulas.

#### Performance Considerations

While OCaml's immutable data structures promote safety and ease of reasoning, adopting mutable data structures can significantly enhance performance, particularly in scenarios involving frequent updates and dynamic modifications. Mutable arrays, for instance, allow for efficient in-place updates of variable assignments and clause representations, reducing the overhead associated with creating new copies of data on each modification.

However, we will likely avoid using mutable data structures to deepen our understanding of OCaml. Instead, we will utilize OCaml's profiling tools, such as landmark, to identify bottlenecks in the CDCL implementation. By analyzing runtime performance, we can concentrate on optimizing critical sections of the code, such as Boolean Constraint Propagation (BCP) and conflict resolution, ultimately enhancing overall execution speed.

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
