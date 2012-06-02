open Printf

let default_random_fraction = 0.05
let default_update_contribution = 0.01

type t = {
  array : float array;
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
    array = Array.make n 1.0;
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
  let a = x.array in
  if Random.State.float x.rng 1. < x.random_fraction then
    Random.State.int x.rng (Array.length a)
  else
    fst (array_max a)

let feedback x i success =
  let a = x.array in
  if i < 0 || i >= Array.length a then
    invalid_arg (sprintf "Multiarmed.feedback: invalid index %i" i);
  let contrib =
    if success then
      x.update_contribution
    else
      0.
  in
  a.(i) <- contrib +. (1. -. x.update_contribution) *. a.(i)


let test () =
  let n = 10 in
  let x = init ~random_fraction: 0.05 ~update_contribution: 0.01 n in
  let trials = 100_000 in
  let successes = ref 0 in
  for i = 1 to trials do
    let j = pick x in
    let success = Random.float 10. > float j in
    feedback x j success;
    if success then
      incr successes;
  done;
  let global_success_rate = float !successes /. float trials in
  assert (global_success_rate > 0.97 && global_success_rate < 0.985);
  printf "Individual success rates:\n";
  Array.iteri (fun i r -> printf "%i %.3f\n" i r) x.array;
  printf "Global success rate: %.3f\n" global_success_rate;
  flush stdout
