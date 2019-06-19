{%- set master = pillar['kubernetes']['master'] -%}
{%- set datavisor = salt['grains.get']('datavisor') -%}
{%- set nodes =  pillar['kubernetes']['master']['cluster']['nodes'] -%}
{% if master.count == 1 %}
  {%  set etcdConfig = "kubeadm-etcd.yaml" %}
{% else %}
  {% set etcdConfig = "kubeadm-etcd-ha.yaml" %}
{% endif %}

# {{ datavisor.dir }}/etcd:
#   file.directory:
#     - user: root
#     - group: root
#     - dir_mode: 750

/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf:
  file.managed:
    - source: salt://{{ slspath }}/20-etcd-service-manager.conf.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

#init kubelet:
#  service.running:
#    - name: kubelet
#    - enable: True

service.systemctl_reload:
  module.run:
    - onchanges:
      - file: /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf

etcd kubelet:
  service.running:
    - name: kubelet
    - enable: True
    - watch:
      - file: /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf

{{ datavisor.dir  }}/{{ etcdConfig }}:
  file.managed:
    - source: salt://{{ slspath }}/{{ etcdConfig  }}.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{% for key, value in master.certs.iteritems() -%}
{% if 'etcd' in value and not 'etcd-ca' in key -%}
remove old {{ key }}:
  file.absent:
    - name: {{ master['certs-dir']}}/{{ value }}

{% endif %}
{%- endfor -%}
{% for cert in ["etcd-server", "etcd-peer", "etcd-healthcheck-client", "apiserver-etcd-client"] %}
generate {{ cert }}:
  cmd.run:
    - name: >-
        kubeadm init phase certs {{ cert }} --config {{ datavisor.dir }}/{{ etcdConfig }}
{% endfor %}

start etcd:
  cmd.run:
    - name: >-
        kubeadm init
        phase etcd
        local
        --config={{ datavisor.dir }}/{{ etcdConfig }}



