<img src="https://i.imgur.com/SJAtDZk.png" width="460" height="125" >

Kubernetes-Saltstack provide an easy way to deploy H/A **Kubernetes Cluster** using Salt.

## Features

- Cloud-provider **aws, aliyun, azure**
- Support **high-available** clusters
- Use the power of **`Saltstack`**
- Made for **`systemd`** based Linux systems
- **Routed** networking by default (**`Calico`**)
- **CoreDNS** as internal DNS provider
- Integrated **add-ons**
- **RBAC** & **TLS** by default

## Getting started 

Let's clone the git repo on Salt-master and create CA & certificates on the `k8s-certs/` directory using **`generate-ca-certs.sh`** scripts:

```bash
git clone https://github.com/valentin2105/Kubernetes-Saltstack.git /srv/salt
ln -s /srv/salt/pillar /srv/pillar

cd /srv/salt/k8s-certs
generate-ca-certs.sh
```
After that, edit the `pillar/cluster_config.sls` to configure your future Kubernetes cluster.

## Deployment

To deploy your Kubernetes cluster using this formula, you first need to setup your Saltstack master/Minion.  
You can use [Salt-Bootstrap](https://docs.saltstack.com/en/stage/topics/tutorials/salt_bootstrap.html) or [Salt-Cloud](https://docs.saltstack.com/en/latest/topics/cloud/) to enhance the process. 

The configuration is done to use the Salt-master as the Kubernetes master. You can have them as different nodes if needed but the `post_install/setup.sh` require `kubectl` and access to the `pillar` files.

#### The recommended configuration is :

- one or three Kubernetes-master (Salt-master & minion)

- one or more Kubernetes-workers (Salt-minion)

The Minion's roles are matched with `Salt Grains` (kind of inventory), so you need to define theses grains on your servers :

```bash
# Kubernetes masters
cat << EOF > /etc/salt/grains
role: k8s-master
EOF

# Kubernetes workers
cat << EOF > /etc/salt/grains
role: k8s-worker
EOF

systemctl restart salt-minion 
```

After that, you can apply your configuration (`highstate`) :

```bash
# Apply Kubernetes master configurations
salt -G 'role:k8s-master' state.highstate

~# kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
etcd-2               Healthy   {"health": "true"}

# Apply Kubernetes worker configurations
salt -G 'role:k8s-worker' state.highstate

~# kubectl get nodes
NAME                STATUS    ROLES     AGE       VERSION   EXTERNAL-IP   OS-IMAGE 
k8s-salt-worker01   Ready     <none>     5m       v1.11.2    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-worker02   Ready     <none>     5m       v1.11.2    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-worker03   Ready     <none>     5m       v1.11.2    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-worker04   Ready     <none>     5m       v1.11.2    <none>        Ubuntu 18.04.1 LTS 
```

Add-ons will be created on the Kubernetes cluster, you can check the `post_install/setup.sh` script :

```bash
/srv/salt/post_install/setup.sh

~# kubectl get pod --all-namespaces
NAMESPACE     NAME                                    READY     STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-fcc5cb8ff-tfm7v 1/1       Running   0          1m
kube-system   calico-node-bntsh                       1/1       Running   0          1m
kube-system   calico-node-fbicr                       1/1       Running   0          1m
kube-system   calico-node-badop                       1/1       Running   0          1m
kube-system   calico-node-rcrze                       1/1       Running   0          1m
kube-system   coredns-d44664bbd-596tr                 1/1       Running   0          1m
kube-system   coredns-d44664bbd-h8h6m                 1/1       Running   0          1m
kube-system   kubernetes-dashboard-7c5d596d8c-4zmt4   1/1       Running   0          1m
kube-system   tiller-deploy-546cf9696c-hjdbm          1/1       Running   0          1m
kube-system   heapster-55c5d9c56b-7drzs               1/1       Running   0          1m
kube-system   monitoring-grafana-5bccc9f786-f4lf2     1/1       Running   0          1m
kube-system   monitoring-influxdb-85cb4985d4-rd776    1/1       Running   0          1m
```

## Good to know

If you want add a node on your Kubernetes cluster, just add the new **Hostname** on `kubernetes-csr.json` and run theses commands :

```bash
cd /srv/salt/k8s-certs

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

salt -G 'role:k8s-master' state.highstate
salt -G 'role:k8s-worker' state.highstate
```

Last `highstate` reload your Kubernetes master and configure automatically new workers.

- Tested on Debian, Ubuntu and Fedora.
- You can easily upgrade software version on your cluster by changing values in `pillar/cluster_config.sls` and apply a `state.highstate`.
- This configuration use ECDSA certificates (you can switch to `rsa` if needed in `certs/*.json`).
- You can tweak Pod's IPv4 pool, enable IPv6, change IPv6 pool, enable IPv6 NAT (for no-public networks), change BGP AS number, Enable IPinIP (to allow routes sharing of different cloud providers).
- If you use `salt-ssh` or `salt-cloud` you can quickly scale new workers.


## Support me on Patreon
Help me out for a couple of :beers:!

https://www.patreon.com/ValentinOuvrard
