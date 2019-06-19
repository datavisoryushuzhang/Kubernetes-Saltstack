{%- set certDir = pillar['kubernetes']['master']['certs-dir'] -%}
{%- set datavisor = salt['grains.get']('datavisor') -%}

{{ certDir }}:
  file.directory:
    - user: {{ datavisor.user }}
    - group: {{ datavisor.user }}
    - dir_mode: 750
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

{% for key, value in pillar['kubernetes']['master']['certs'].iteritems() %}
{% if 'ca' in key or 'etcd-ca' in key or 'sa' in key %}
{{ certDir }}/{{value}}:
  file.managed:
    - source:  salt://{{ slspath }}/{{value}}
    - group: {{ datavisor.user }}
    - user: {{ datavisor.user }}
    - mode: 644
{% endif%}
{% endfor %}
