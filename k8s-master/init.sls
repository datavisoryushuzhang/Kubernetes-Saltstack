{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{% set post_install_files = [
  "calico.yaml",
  "grafana.yaml", 
  "heapster-rbac.yaml", 
  "heapster.yaml",
  "kubernetes-dashboard.yaml", 
  "setup.sh"] %}
{%- set datavisorDir = pillar['kubernetes']['datavisor']['dir'] -%}

include:
  - .etcd

{{ datavisorDir }}/kubeadm-ha.yaml:
  file.managed:
    - source: salt://{{ slspath }}/kubeadm-ha.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kubelet.service.d/30-kubeadm.conf:
  file.copy:
    - source: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

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
        --config {{ datavisorDir }}/kubeadm-ha.yaml
        --ignore-preflight-errors=all

{% if salt['grains.get']('fqdn_ip4') | first  == pillar['kubernetes']['master']['cluster']['nodes'] | map(attribute='ipaddr') | list | first -%}
{% for file in post_install_files %}
{{ datavisorDir }}/post_install/{{ file }}:
  file.managed:
  - source: salt://post_install/{{ file }}
  - makedirs: true
  - template: jinja
  - user: root
  - group: root
{% if file == "setup.sh" %}
  - mode: 755
{% else %}
  - mode: 644
{% endif %}
{% endfor %}

execute post_install:
  cmd.script:
    - name: {{ datavisorDir }}/post_install/setup.sh
    - cwd: {{ datavisorDir }}/post_install
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
{% endif %}
