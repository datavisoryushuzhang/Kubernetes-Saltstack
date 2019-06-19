{%- set master = pillar['kubernetes']['master'] -%}
{%- set global = pillar['kubernetes']['global'] -%}
{%- set datavisor = salt['grains.get']('datavisor') -%}

include:
  - ../k8s-common

kubelet:
  service.running:
    - enable: true

{{ datavisor.dir }}/kubeadm-worker.yaml:
  file.managed:
    - source: salt://{{ slspath }}/k8s-worker/kubeadm-worker.yaml.j2
    - template: jinja
    - user: {{ datavisor.user }}
    - group: {{ datavisor.user }}
    - mode: 644

join cluster:
  cmd.run:
    - name: >-
        kubeadm join
        --config {{ datavisor.dir }}/kubeadm-worker.yaml
