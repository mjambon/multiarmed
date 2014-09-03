open Printf

let default_random_fraction = 0.05
let default_update_contribution = 0.01

type t = {
  estimates : float array;
  picked : int array;
  successes : int array;
  random_fraction : float;
  update_contribution : float;
  rng : Random.State.t;
}

let init
    ?(random_fraction = default_random_fraction)
    ?(update_contribution = default_update_contribution)
    n =
  if n < 1 then
    invalid_arg (sprintf "Multiarmed.init: %i" n);
  if random_fraction > 1. || random_fraction < 0. then
    invalid_arg (sprintf "Multiarmed.init: random_fraction %g"
                   random_fraction);
  if update_contribution < 0.  || update_contribution > 1. then
    invalid_arg (sprintf "Multiarmed.init: update_contribution %g"
                   update_contribution);
  {
    estimates = Array.make n 1.0;
    picked = Array.make n 0;
    successes = Array.make n 0;
    random_fraction;
    update_contribution;
    rng = Random.State.make_self_init ();
  }

let array_max a =
  assert (Array.length a > 0);
  let index = ref 0 in
  let value = ref a.(0) in
  for i = 1 to Array.length a - 1 do
    if a.(i) > !value then (
      index := i;
      value := a.(i)
    )
  done;
  (!index, !value)

let pick x =
  let a = x.estimates in
  if Random.State.float x.rng 1. < x.random_fraction then
    Random.State.int x.rng (Array.length a)
  else
    fst (array_max a)

let feedback x i success =
  let a = x.estimates in
  if i < 0 || i >= Array.length a then
    invalid_arg (sprintf "Multiarmed.feedback: invalid index %i" i);
  let contrib =
    if success then
      x.update_contribution
    else
      0.
  in
  a.(i) <- contrib +. (1. -. x.update_contribution) *. a.(i)

(*
   Produce an array of random variables following Bernoulli distributions.

   Optionally, the parameter p can change.
*)
let make_random_variables ?(change_p_every = 0) rng n =
  printf "Expected values:\n";
  let count = ref 0 in
  let a = Array.init n (fun i -> fun () -> assert false) in

  let rec make_var i =
    let p = Random.State.float rng 1.0 in
    printf "[%i] %.3f\n" i p;
    fun () ->
      let result = Random.State.float rng 1.0 <= p in
      incr count;
      if change_p_every > 0
      && !count mod change_p_every = 0
      && !count > 0 then
        init_array ();
      result

  and init_array () =
    Array.iteri (fun i _ -> a.(i) <- make_var i) a;
    printf "--\n"
  in

  init_array ();
  a


let test ?(n = 10) ?(trials = 100) ?(change_p_every = 1000) () =
  printf "Number of random variables to choose from: %i\n" n;
  printf "Number of trials: %i\n%!" trials;
  if change_p_every < trials then
    printf "Change all distributions every %i trials\n%!" change_p_every;
  let x = init ~random_fraction: 0.05 ~update_contribution: 0.1 n in
  let random_variables = make_random_variables ~change_p_every x.rng n in
  let successes = ref 0 in
  for i = 1 to trials do
    let j = pick x in
    let success = random_variables.(j) () in
    feedback x j success;
    if success then (
      incr successes;
      x.successes.(j) <- x.successes.(j) + 1
    );
    x.picked.(j) <- x.picked.(j) + 1;
  done;
  let global_success_rate = float !successes /. float trials in
  printf "Individual success rates:\n";
  Array.iteri (fun i r ->
    let successes = x.successes.(i) in
    let total = x.picked.(i) in
    printf "[%i] %.3f %i/%i\n"
      i (float successes /. float total) successes total
  ) x.estimates;
  printf "Global success rate: %.3f\n" global_success_rate;
  flush stdout
