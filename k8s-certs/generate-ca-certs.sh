CA_CERTS=("etcd-ca" "ca" "front-proxy-ca" "sa")

for CERT in ${CA_CERTS[@]}
do
  kubeadm init phase certs $CERT --cert-dir $(pwd)
done
