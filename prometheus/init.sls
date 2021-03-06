{%- if pillar.prometheus.server is defined or
       pillar.prometheus.alertmanager is defined %}
include:
  {%- if pillar.prometheus.server is defined %}
  - prometheus.server
  {%- endif %}
  {%- if pillar.prometheus.alertmanager is defined %}
  - prometheus.alertmanager
  {%- endif %}
  {%- if pillar.prometheus.pushgateway is defined %}
  - prometheus.pushgateway
  {%- endif %}
  {%- if pillar.prometheus.collectd_exporter is defined %}
  - prometheus.collectd_exporter
  {%- endif %}
{%- endif %}
