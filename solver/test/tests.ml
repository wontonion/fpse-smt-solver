open OUnit2

let series =
  "Project tests"
  >::: [
         Cdcl_tests.series;
         Dimacs_tests.series;
         Bin_tests.series;
         Smt_tests.series;
         Vm_tests.series;
       ]

let () = run_test_tt_main series
