open OUnit2

let series =
  "CDCL tests"
  >::: [
         Literal_tests.series;
         Clause_tests.series;
         Formula_tests.series;
         Assignment_tests.series;
         Solver_tests.series;
       ]
