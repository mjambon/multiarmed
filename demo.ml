open Printf

let () =
  match Sys.argv with
  | [| _; n; trials; change_p_every |] ->
    let n = int_of_string n in
    let trials = int_of_string trials in
    let change_p_every = int_of_string change_p_every in
    Multiarmed.test ~n ~trials ~change_p_every ()
  | _ ->
    eprintf "Usage: %s <number of random variables> \
                       <number of trials> \
                       <change random variables every>\n%!"
      Sys.argv.(0);
    exit 1
