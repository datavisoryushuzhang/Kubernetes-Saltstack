{%- set certDir = pillar['kubernetes']['master']['certs-dir'] -%}
{%- set datavisor = salt['grains.get']('datavisor') -%}

{{ certDir }}:
  file.directory:
    - user: {{ datavisor.user }}
    - group: {{ datavisor.user }}
    - dir_mode: 750

{% for key, value in pillar['kubernetes']['master']['certs'].iteritems() %}
{% if 'ca' in key or 'etcd-ca' in key or 'sa' in key %}
{{ certDir }}/{{value}}:
  file.managed:
    - source:  salt://{{ slspath }}/{{value}}
    - group: root
    - mode: 644
    - makedirs: True
{% endif%}
{% endfor %}
