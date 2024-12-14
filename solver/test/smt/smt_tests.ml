open OUnit2

let series =
  "SMT tests"
  >::: [ Context_tests.series; Bitvec_tests.series; Bitop_tests.series ]
