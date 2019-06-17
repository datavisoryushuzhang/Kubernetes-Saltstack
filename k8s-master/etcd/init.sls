{%- set master = pillar['kubernetes']['master'] -%}
{%- set datavisorDir = pillar['kubernetes']['datavisor']['dir'] -%}
{%- set imageRepository = pillar['kubernetes']['global']['image-repository'] -%}
{%- set nodes =  pillar['kubernetes']['master']['cluster']['nodes'] -%}
{% if master.count == 1 %}
  {%  set etcdConfig = datavisorDir + "/kubeadm-etcd.yaml" %}
{% else %}
  {% set etcdConfig = datavisorDir + "/kubeadm-etcd-ha.yaml" %}
{% endif %}

/etc/etcd:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

{% if imageRepository.ip -%}
private-docker-registry:
  host.present:
    - ip: 
      - {{ imageRepository.ip }}
    - names:
      - {{ imageRepository.dns | regex_replace('\/.*$', '') }}
{%- endif %}

/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf:
  file.managed:
    - source: salt://{{ slspath }}/20-etcd-service-manager.conf.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubelet:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf

{% for key, value in master.certs.iteritems() -%}
{% if 'etcd' in value and not 'etcd-ca' in key -%}
remove old {{ key }}:
  file.absent:
    - name: {{ master['certs-dir']}}/{{ value }}

{% endif %}
{%- endfor -%}
{{ etcdConfig }}:
  file.managed:
    - source: salt://{{ slspath }}/kubeadm-etcd.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

start etcd:
  cmd.run:
    - name: >-
        kubeadm init
        phase etcd
        local
        --config={{ etcdConfig }}



