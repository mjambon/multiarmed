This is an OCaml library that provides an implementation of the
epsilon-greedy solution to the multiarmed-bandit problem.
It adds recency bias, i.e. it will adapt when trends change over time.

Practical use: finding out which variant of a user interface is most often
successful while maximizing the overall success rate as the system
is learning.

See also:

* [20 lines of code that will beat A/B testing every time](http://stevehanov.ca/blog/index.php?id=132)
* [Multi-armed bandit problem at Wikipedia](http://en.wikipedia.org/wiki/Multi-armed_bandit)

Installation:

```
$ make
$ make install
```

Uninstallation:

```
$ make uninstall
```
