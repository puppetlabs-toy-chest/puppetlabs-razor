if $serverversion {
  # You don't want to run this as-is on the master: it would install the razor
  # server on *every single node* in your infrastructure.  Ouch!  This is
  # basically to stop someone blindly dropping this into place rather than
  # putting the `include razor` line into a correct `node whatever` block.
  crit('looks like this was used on the master, which will install razor *everywhere')
}

# this is sufficient to get razor installed if you are using `puppet apply`.
# as noted, everything else in this file is just noise around this. :)
include razor
