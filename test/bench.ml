module Hash = Md5

let () =
  let result =
    Benchmark.throughputN ~repeat:10 1
    [
      "file", Hash.file, Sys.argv.(1);
      "file_fast", Hash.file_fast, Sys.argv.(1);
      "file_unbuffered", Hash.file_unbuffered, Sys.argv.(1);
    ]
  in
  prerr_newline ();
  Benchmark.tabulate result
;;
