{% from "prometheus/map.jinja" import collectd_exporter with context %}
{%- if collectd_exporter.enabled %}

{%- if not (pillar.docker is defined and pillar.docker.host is defined) %}

include:
  - prometheus.common

collectd_exporter_tarball:
  archive.extracted:
    - name: {{ collectd_exporter.dir.install }}
    - source: {{ collectd_exporter.source }}
    - source_hash: sha1={{ collectd_exporter.source_hash }}
    - archive_format: tar
    - if_missing: {{ collectd_exporter.dir.version_path }}

collectd_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/collectd_exporter
    - target: {{ collectd_exporter.dir.version_path }}/collectd_exporter
    - require:
      - archive: collectd_exporter_tarball

collectd_exporter_defaults:
  file.managed:
    - name: /etc/default/collectd_exporter
    - source: salt://prometheus/files/default-collectd_exporter.jinja
    - template: jinja

collectd_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/collectd_exporter.service
    - source: salt://prometheus/files/collectd_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/collectd_exporter.conf
    - source: salt://prometheus/files/collectd_exporter.upstart.jinja
{%- endif %}
    - watch:
      - file: collectd_exporter_defaults
    - require_in:
      - file: collectd_exporter_service

collectd_exporter_service:
  service.running:
    - name: collectd_exporter
    - enable: True
    - reload: True
    - watch:
      - file: collectd_exporter_service_unit
      - file: collectd_exporter_bin_link

{%- endif %}


{%- endif %}
