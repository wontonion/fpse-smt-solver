#### Project Design Proposal

For this submission and all subsequent submissions, you are required to submit to Gradescope via a GitHub repo. If you have large datasets in files, please put them on Google Drive or similar and provide a link - Gradescope and/or Github may be unhappy otherwise.

You will have created a project on GitHub, and the content of this submission is found top-level in `Design.md` with module type declarations in `src/`.

The design submission must include
  1. An overview of the purpose of the project.
  2. A complete mock use of the application.
    - If you have a graphical user interface, show a mock up of every page and how the user can interact.
    - ... similarly if you have a command line interface.
    - If the basis of your project is just some hard algorithm, take this chance to describe the algorithm and how OCaml will work with it. Show example uses and discuss desired performance.
  3. A list of libraries you are using or plan to use in your implementation. For all non-standard libraries used in the rest of the course (e.g. if you are using `Dream`), you need to have successfully installed the library on all team member computers and have a small demo working to verify the library really works. We require this because OCaml libraries can be flaky. This will be submitted in `demo/` with a subdirectory for each library.
  4. Commented module type declarations (`.mli` files) which will provide you with an initial specification to code to.
    - You can change this later and don't need every single detail filled out, but it should include as many details as you can think of, and you should try to cover the entire project.
    - Include an initial pass at key types and functions needed and a brief comment if the meaning of a function is not clear.
  5. An implementation plan: a list of the order in which you will implement features and by what date you hope to have them completed.
  6. You may also include any other information that will make it easier to understand your project.

*Grading rubric*

* 30% mock use: depicts each usage case clearly and accurately.
* 15% libraries: has a working demo folder for each library to be used in the final submission.
* 15% project scope: the project is not too big or too small, has enough algorithmic complexity, and has room to make a general library.
* 10% plan of implementation: there is a detailed implementation plan that covers all aspects of the project.
* 30% module declarations: there are reasonable module interfaces for core components that are well thought-through and well designed.


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


Once the solution come out, the solution will be displayed on the web page
7. Some default examples will be displayed on the web page for validating the algorithm of SAT/SMT.
8. 

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
#### SAT_solver
As an essentitial part of our programm...

#### SMT_solver

<!-- #### Docker

For creating a unified development environoment, our group decide to use `Docker` for better configuring the devlopment environoment. Thus, there will be two docker containers for this project. One for fronted and the other for backend, which includes the main SAT/SMT solver algorithm. -->

#### Rescripts
This is a library enables programmer using Ocaml syntax to write frontend...

#### Dream and lwt 


#### landmark ppx

A code profilling tool


A list of libraries you are using or plan to use in your implementation. For all non-standard libraries used in the rest of the course (e.g. if you are using Dream), you need to have successfully installed the library on all team member computers and have a small demo working to verify the library really works. We require this because OCaml libraries can be flaky. This will be submitted in demo/ with a subdirectory for each library.
Commented module type declarations (.mli files) which will provide you with an initial specification to code to. - You can change this later and don't need every single detail filled out, but it should include as many details as you can think of, and you should try to cover the entire project. - Include an initial pass at key types and functions needed and a brief comment if the meaning of a function is not clear.

## 4. Implementation Schedule

Event|Scheduled End Date|Actual End Date|
|-|-|-|
||||


An implementation plan: a list of the order in which you will implement features and by what date you hope to have them completed.
You may also include any other information that will make it easier to understand your project.