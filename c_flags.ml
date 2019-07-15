let () =
  if Sys.win32 then ()
  else print_endline "(-Wall -O3 -funroll-loops)"
