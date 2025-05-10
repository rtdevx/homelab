## Building Talos Kubernetes cluster using patches

*_Talos Image Optimized for Proxmox_* (image: factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.1). *For other platforms use appropriate image*.
### Install talosctl, kubectl and k9s

On the Jump Host install talosctl, kubectl and k9s

```bash
# talosctl
curl -sL https://talos.dev/install | sh

# kubectl
sudo snap install kubectl --classic

# k9s
sudo snap install k9s

# k9s command not found after snap install issue in Ubuntu 24.04
# https://github.com/derailed/k9s/issues/2128
sudo ln -s /snap/k9s/current/bin/k9s /snap/bin/
```

### Cluster Build

1. Generate Secrets

```bash
cd ~

talosctl gen secrets
```

2. Export Variables

```Bash
export CLUSTER_IP=192.168.20.44
export CLUSTER_NAME=talos-cluster-s

export CONTROL_PLANE_IP1=192.168.20.45
export CONTROL_PLANE_IP2=192.168.20.46
export CONTROL_PLANE_IP3=192.168.20.47

export WORKER_IP1=192.168.20.55
export WORKER_IP2=192.168.20.56
export WORKER_IP3=192.168.20.57
```

3. Generate config files for the cluster using patches

```bash
git clone https://github.com/rtdevx/homelab.git

cd ~/homelab/kubernetes/talos

talosctl gen config $CLUSTER_NAME https://$CLUSTER_IP:6443 \
  --with-secrets ~/secrets.yaml \
  --config-patch @patches/all.yaml \
  --config-patch-control-plane @patches/cp.yaml \
  --config-patch-worker @patches/worker.yaml \
  --output ~/rendered/
```

4. Set Up the cluster

```bash
cd ~

talosctl apply -f rendered/controlplane.yaml -n $CONTROL_PLANE_IP1 --insecure
talosctl apply -f rendered/controlplane.yaml -n $CONTROL_PLANE_IP2 --insecure
talosctl apply -f rendered/controlplane.yaml -n $CONTROL_PLANE_IP3 --insecure
```

5. Add Worker Nodes

```bash
talosctl apply -f rendered/worker.yaml -n $WORKER_IP1 --insecure
talosctl apply -f rendered/worker.yaml -n $WORKER_IP2 --insecure
talosctl apply -f rendered/worker.yaml -n $WORKER_IP3 --insecure
```

- Note _--insecure_ is only used for the initial install. After cluster is installed with it's newly generated keys, this option should not be used.

6. Configure talosctl

```bash
mkdir -p ~/.talos 
cp rendered/talosconfig ~/.talos/config

# Test
talosctl config contexts

# Set endpoints for talosctl
talosctl config endpoint $CONTROL_PLANE_IP1 $CONTROL_PLANE_IP2 $CONTROL_PLANE_IP3

# Set config node
talosctl config node $CONTROL_PLANE_IP1
```

7. Install (Bootstrap) Kubernetes

```Bash
talosctl bootstrap

# Fetch kubeconfig
talosctl kubeconfig
```

8. Add kubectl alias (Optional)

```Bash
vi ~/.bashrc

#Custom Aliases
alias k='kubectl'
```

### References / Sources

- _source:_ https://www.talos.dev/v1.10/talos-guides/configuration/patching/
- _source:_ https://mirceanton.com/posts/2023-11-28-the-best-os-for-kubernetes/

Youtube: 

- https://www.youtube.com/watch?v=T2-sEgl-_ak
- https://www.youtube.com/watch?v=4_U0KK-blXQ