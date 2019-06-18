{%- set imageRepository = pillar['kubernetes']['global']['image-repository'] -%}

{% if imageRepository.ip -%}
private-docker-registry:
  host.present:
    - ip: 
      - {{ imageRepository.ip }}
    - names:
      - {{ imageRepository.dns | regex_replace('\/.*$', '') }}
{%- endif %}