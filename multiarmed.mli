(**
   Epsilon-greedy solution to the multiarmed-bandit problem,
   with recency bias allowing to follow trends over time.

   Practical use: finding out which variant of a user interface is most often
   successful while maximizing the overall success rate as the system
   is learning.

   http://en.wikipedia.org/wiki/Multi-armed_bandit
*)

type t = {
  estimates : float array;
    (** The average success rate of each choice. *)

  picked : int array;
    (** Number of times each random variable was picked. *)

  successes : int array;
    (** Number of successes obtained with each random variable. *)

  random_fraction : float;
    (** How often we make random picks for exploratory purposes. *)

  update_contribution : float;
    (** Parameter used to compute the exponential moving average.

        This represents how much a given success or failure
        contributes to the computation of the average success
        frequency for a given choice.
        This gives more weight to recent results, their weight
        decreasing exponentially over time. *)

  rng : Random.State.t;
}

val default_random_fraction : float
val default_update_contribution : float

val init : ?random_fraction:float -> ?update_contribution:float -> int -> t
  (** Create a fresh mutable data structure that takes care of everything. *)

val pick : t -> int
  (** Pick an element, as an index starting from 0.
      Must be followed by a call to [feedback] for any learning to happen. *)

val feedback : t -> int -> bool -> unit
  (** Report success (true) or failure (false) for a given choice (index). *)

val test : ?n:int -> ?trials:int -> ?change_p_every:int -> unit -> unit
