CA_CERTS=("etcd-ca" "ca" "front-proxy-ca" "sa")

for CERT in ${CA_CERTS[@]}
do
  kubeadm init phase certs $CERT --cert-dir $(pwd)
done

export CA_SHA256 = $(openssl x509 -pubkey -in ./ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | awk '{print $2}')

echo "Generated CA certs"
