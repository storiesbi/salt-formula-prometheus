{% from "prometheus/map.jinja" import server with context %}

{%- if server.enabled %}

{{server.dir.config}}/prometheus.yml:
  file.managed:
  - source: salt://prometheus/files/prometheus.yml
  - template: jinja

{{server.dir.config}}/alerts.yml:
  file.managed:
  - source: salt://prometheus/files/alerts.yml
  - template: jinja

{%- if not (pillar.docker is defined and pillar.docker.host is defined) %}

include:
  - prometheus.common

prometheus_server_tarball:
  archive.extracted:
    - name: {{ server.dir.install }}
    - source: {{ server.source }}
    - source_hash: sha1={{ server.source_hash }}
    - archive_format: tar
    - if_missing: {{ server.dir.version_path }}

prometheus_bin_link:
  file.symlink:
    - name: /usr/bin/prometheus
    - target: {{ server.dir.version_path }}/prometheus
    - require:
      - archive: prometheus_server_tarball

prometheus_defaults:
  file.managed:
    - name: /etc/default/prometheus
    - source: salt://prometheus/files/default-prometheus.jinja
    - template: jinja

prometheus_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/prometheus.service
    - source: salt://prometheus/files/prometheus.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/prometheus.conf
    - source: salt://prometheus/files/prometheus.upstart.jinja
{%- endif %}
    - watch:
      - file: prometheus_defaults
    - require_in:
      - file: prometheus_service

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - reload: True
    - watch:
      - file: prometheus_service_unit
      - file: {{server.dir.config}}/prometheus.yml
      - file: prometheus_bin_link
      - file: {{server.dir.config}}/alerts.yml

{%- endif %}

{%- endif %}
