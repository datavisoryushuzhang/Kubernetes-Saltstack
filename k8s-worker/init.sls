{%- set master = pillar['kubernetes']['master'] -%}
{%- set global = pillar['kubernetes']['global'] -%}

include:
  - ../k8s-common

kubelet:
  service.running:
    - enable: true

join cluster:
  cmd.run:
    - name: >-
        kubeadm join
        {{ global['kubeadm-lb-fqdn'] }}:{{ global['loadbalancer-apiserver'].port }} 
        --discovery-token-ca-cert-hash sha256:{{ salt['mine.get']('role:k8s-master', 'ca-sha256', 'grain').itervalues().next() }}
        --token {{ master['token'] }}
        --ignore-preflight-errors=all
