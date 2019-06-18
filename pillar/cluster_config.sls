kubernetes:
  version: v1.13.6
  domain: cluster.local
  master:
#    count: 1
#    hostname: master.domain.tld
#    ipaddr: 10.240.0.10
    count: 3
    cluster:
      name: k8s-aws-cn-dev-test
      nodes:
        - ipaddr: 10.201.14.186
          etcd-member-name: etcd0
        - ipaddr: 10.201.31.9
          etcd-member-name: etcd1
        - ipaddr: 10.201.38.35
          etcd-member-name: etcd2
    encryption-key: 'w3RNESCMG+o3GCHTUcrQUUdq6CFV72q/Zik9LAO8uEc='
    certs-dir: /etc/kubernetes/pki
    etcd:
      version: v3.3.9
    certs:
      etcd-ca-cert: etcd/ca.crt
      etcd-ca-key: etcd/ca.key
      server-cert: etcd/server.crt
      server-key: etcd/server.key
      healthcheck-cert: etcd/healthcheck.crt
      healthcheck-key: etcd/healthcheck.key
      client-cert: etcd/client.crt
      client-key: etcd/client.key
      apiserver-etcd-client-cert: apiserver-etcd-client.crt
      apiserver-etcd-client-key: apiserver-etcd-client.key
      apiserver-cert: apiserver.crt
      apiserver-key: apiserver.key
      apiserver-kubelet-client-cert: apiserver-kubelet-client.crt
      apiserver-kubelet-client-key: apiserver-kubelet-client.key
      ca-cert: ca.crt
      ca-key: ca.key
      front-proxy-ca-cert: front-proxy-ca.crt
      front-proxy-ca-key: front-proxy-ca.key
      front-proxy-client-cert: front-proxy-client.crt
      front-proxy-client-key: front-proxy-client.key
      sa-key: sa.key
      sa-public-key: sa.pub
  worker:
    runtime:
      provider: docker
      docker:
        version: 18.03.0-ce
        data-dir: /dockerFS
    networking:
      cni-version: v0.7.1
      provider: calico
      calico:
        version: v3.2.1
        cni-version: v3.2.1
        calicoctl-version: v3.2.1
        controller-version: 3.2-release
        as-number: 64512
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
        ipv4:
          range: 192.168.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          interface: eth0
          range: fd80:24e2:f998:72d6::/64
  global:
    clusterIP-range: 10.32.0.0/16
    helm-version: v2.10.0
    dashboard-version: v1.10.0
    admin-token: Haim8kay1rarCHANGEMEHaim8kay11ra
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipa1e1w
    image-repository: 
      dns: docker-registry.datavisor.cn/library
      ip: 52.83.236.125
  datavisor:
    dir: /opt/datavisor
