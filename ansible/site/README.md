Script can install and configure 1-node OR 3-node HA K3s cluster with 2 LB's in front.
If for any reason descaling or removing nodes is required:

### 1. Removing Server nodes

```bash
kubectl drain NODENAME --delete-emptydir-data --ignore-daemonsets

kubectl delete node NODENAME

sudo /usr/local/bin/k3s-uninstall.sh && sudo rm -rf /etc/rancher
```

### 2. Removing Agent nodes

```bash
kubectl drain NODENAME --delete-emptydir-data --ignore-daemonsets

kubectl delete node NODENAME

sudo /usr/local/bin/k3s-agent-uninstall.sh && sudo rm -rf /etc/rancher
```

## Ansible script modifications for 1-node OR 3-node scenario

I still keep 2 LB's in front for flexibility and so Control Plane Servers can be added in the future. This is to ensure K3s cluster scaling out can be done quickly.

Configuration items in the script needed changing depending on the scenario:

 1. Comment or comment out Server Nodes from inventory (group k3ssvr).
 2. Update _main.yml_ in _k3s_configure_haproxy_ role. Select (uncomment) the relevant role depending on the scenario (HA or Single node).
 3. `rm -rf /etc/haproxy/haproxy.cfg` to ensure fresh file gets copied and updated accordingly.
 4. Run the playbook.