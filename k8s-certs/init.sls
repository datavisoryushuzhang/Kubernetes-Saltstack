{% set certDir = pillar['kubernetes']['master']['certs-dir'] %}

{{ certDir }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

{% for key, value in pillar['kubernetes']['master']['certs'].iteritems() %}
{{ certDir }}/{{value}}:
  file.managed:
    - source:  salt://{{ slspath }}/{{value}}
    - group: root
    - mode: 644
{% endfor %}
