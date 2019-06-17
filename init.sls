---
{% if "k8s-master" in grains.get('role', []) %}
include:
  - .k8s-certs
  - .k8s-master
{%  elif "k8s-worker" in grains.get('role', []) %}
  - .k8s-worker
{% endif %}
