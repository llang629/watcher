# watcher

Connects via PPTP to private network.
Ping tests selected nodes.
Email update when status changes.

On new instance, remember to add route to subnet, for example
sudo route add -net 192.168.10.0 netmask 255.255.255.0 dev ppp0
