{%- set imageRepository = pillar['kubernetes']['global']['image-repository'] -%}

{% if imageRepository.ip -%}
private-docker-registry:
  host.present:
    - ip: 
      - {{ imageRepository.ip }}
    - names:
      - {{ imageRepository.dns | regex_replace('\/.*$', '') }}
{%- endif %}

{{ datavisor.dir }}/kubernetes/config:
  file.directory:
    - user: {{ datavisor.user }}
    - group: {{ datavisor.user }}
    - mode: 750
    - recurse:
      - user
      - group
      - mode
