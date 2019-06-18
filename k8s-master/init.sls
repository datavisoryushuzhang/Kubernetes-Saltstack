{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{% set post_install_files = [
  "calico.yml",
  "grafana.yaml", 
  "heapster-rbac.yaml", 
  "heapster.yaml",
  "kubernetes-dashboard.yaml", 
  "setup.sh"] %}
{%- set datavisorDir = pillar['kubernetes']['datavisor']['dir'] -%}

include:
  - .etcd

{{ datavisorDir }}/kubeadm-ha.yaml
  file.managed:
    - source: salt:// {{ slspath }}/kubeadm-ha.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kubelet.service.d/30-kubeadm.conf:
  file.copy:
    - source: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

kubelet:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/kubelet.service.d/30-kubeadm.conf

init first master:
  cmd.run:
    - name: >-
        kubeadm init
        --config {{ datavisorDir }}/kubeadm-ha.yaml
        --ignore-preflight-errors=all

{% if salt['grains.get']('fqdn_ip4') == pillar['kubernetes']['master']['cluster']['nodes'] | map(attribute='ipaddr') | list | first -%}
{% for file in post_install_files %}
{{ datavisorDir }}/post_install/{{ file }}:
  file.managed:
  - source: salt://{{ slspath.split('/')[0] }}/post_install/{{ file }}
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

{{ datavisorDir }}/post_intall/setup.sh:
  cmd.script:
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
{% endif %}
