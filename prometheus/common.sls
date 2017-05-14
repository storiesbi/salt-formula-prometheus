{% from "prometheus/map.jinja" import server with context %}

prometheus_user:
  user.present:
  - name: prometheus
  - shell: /bin/bash
  - system: true
  - home: /srv/prometheus

prometheus_dirs:
  file.directory:
  - names:
    - /var/log/prometheus
    - {{ server.dir.storage }}
    - {{ server.dir.config }}
  - makedirs: true
  - group: prometheus
  - user: prometheus
  - require:
    - user: prometheus