{% from "prometheus/map.jinja" import pushgateway with context %}

{%- if pushgateway.enabled %}

{%- if not (pillar.docker is defined and pillar.docker.host is defined) %}

include:
  - prometheus.common

pushgateway_tarball:
  archive.extracted:
    - name: {{ pushgateway.dir.install }}
    - source: {{ pushgateway.source }}
    - source_hash: sha1={{ pushgateway.source_hash }}
    - archive_format: tar
    - if_missing: {{ pushgateway.dir.version_path }}

pushgateway_bin_link:
  file.symlink:
    - name: /usr/bin/pushgateway
    - target: {{ pushgateway.dir.version_path }}/pushgateway
    - require:
      - archive: pushgateway_tarball

pushgateway_defaults:
  file.managed:
    - name: /etc/default/pushgateway
    - source: salt://prometheus/files/default-pushgateway.jinja
    - template: jinja

pushgateway_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/pushgateway.service
    - source: salt://prometheus/files/pushgateway.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/pushgateway.conf
    - source: salt://prometheus/files/pushgateway.upstart.jinja
{%- endif %}
    - watch:
      - file: pushgateway_defaults
    - require_in:
      - file: pushgateway_service

pushgateway_service:
  service.running:
    - name: pushgateway
    - enable: True
    - reload: True
    - watch:
      - file: pushgateway_service_unit
      - file: pushgateway_bin_link

{%- endif %}


{%- endif %}
