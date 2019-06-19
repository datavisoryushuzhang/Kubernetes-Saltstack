{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{% set post_install_files = [
  "calico.yaml",
  "grafana.yaml", 
  "heapster-rbac.yaml", 
  "heapster.yaml",
  "kubernetes-dashboard.yaml", 
  "setup.sh"] %}
{%- set datavisor = salt['grains.get']('datavisor') -%}

include:
  - ../k8s-common
  - .etcd

{{ datavisor.dir }}/kubeadm-ha.yaml:
  file.managed:
    - source: salt://{{ slspath }}/kubeadm-ha.yaml.j2
    - user: {{ datavisor.user }}
    - template: jinja
    - group: {{ datavisor.user }}
    - mode: 644

/etc/systemd/system/kubelet.service.d/30-kubeadm.conf:
  file.copy:
    - source: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
    - makedirs: True

Cluster kubelet:
  service.running:
    - name: kubelet
    - enable: True
    - watch:
      - file: /etc/systemd/system/kubelet.service.d/30-kubeadm.conf

init master:
  cmd.run:
    - name: >-
        kubeadm init
        --config {{ datavisor.dir }}/kubeadm-ha.yaml
        --ignore-preflight-errors=all

{% if salt['grains.get']('fqdn_ip4') | first  == pillar['kubernetes']['master']['cluster']['nodes'] | map(attribute='ipaddr') | list | first -%}
{% for file in post_install_files %}
{{ datavisor.dir }}/post_install/{{ file }}:
  file.managed:
  - source: salt://post_install/{{ file }}
  - makedirs: true
  - template: jinja
  - user: {{ datavisor.user }}
  - group: {{ datavisor.user }}
{% if file == "setup.sh" %}
  - mode: 755
{% else %}
  - mode: 644
{% endif %}
{% endfor %}

execute post_install:
  cmd.script:
    - name: {{ datavisor.dir }}/post_install/setup.sh
    - cwd: {{ datavisor.dir }}/post_install
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
{% endif %}
