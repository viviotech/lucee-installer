This directory contains a set of FusionReactor Crash Protection sample scripts.
Enterprise versions of FusionReactor allow to define a script for every managed
server that will be executed on the local machine whenever the observed server
becomes unavailable or available again.

Please be aware that

THE SCRIPT IS EXECUTED ON THIS MACHINE

and it is the responsibility of the script to be able to restart a server that
is remote.

If you have successfully configured CP scripts to automatically restart your
server(s) you might find it difficult to stop them. To get around this go to
the Enterprise Dashboard of FusionReactor before and disable monitoring of
servers you want to stop.