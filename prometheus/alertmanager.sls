{% from "prometheus/map.jinja" import alertmanager with context %}
{%- if alertmanager.enabled %}

{{alertmanager.dir.config}}/alertmanager.yml:
  file.managed:
  - source: salt://prometheus/files/alertmanager.yml
  - template: jinja

{%- if not (pillar.docker is defined and pillar.docker.host is defined) %}

include:
  - prometheus.common

alertmanager_tarball:
  archive.extracted:
    - name: {{ alertmanager.dir.install }}
    - source: {{ alertmanager.source }}
    - source_hash: sha1={{ alertmanager.source_hash }}
    - archive_format: tar
    - if_missing: {{ alertmanager.dir.version_path }}

alertmanager_bin_link:
  file.symlink:
    - name: /usr/bin/alertmanager
    - target: {{ alertmanager.dir.version_path }}/alertmanager
    - require:
      - archive: alertmanager_tarball

alertmanager_defaults:
  file.managed:
    - name: /etc/default/alertmanager
    - source: salt://prometheus/files/default-alertmanager.jinja
    - template: jinja

alertmanager_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/alertmanager.service
    - source: salt://prometheus/files/alertmanager.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/alertmanager.conf
    - source: salt://prometheus/files/alertmanager.upstart.jinja
{%- endif %}
    - watch:
      - file: alertmanager_defaults
    - require_in:
      - file: alertmanager_service

alertmanager_service:
  service.running:
    - name: alertmanager
    - enable: True
    - reload: True
    - watch:
      - file: alertmanager_service_unit
      - file: {{alertmanager.dir.config}}/alertmanager.yml
      - file: alertmanager_bin_link

{%- endif %}


{%- endif %}
