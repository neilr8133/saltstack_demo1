{% from 'webserver/nginx/map.jinja' import config with context %}

Make sure webserver is installed and running:
  pkg.installed:
    - name: {{ config.package_name }}
  service.running:
    - name: {{ config.package_name }}
    - enable: True
    - reload: True

Install main nginx_conf file:
  file.managed:
    - name: {{ config.config_file_dir }}/{{ config.config_file_name }}
    - source: salt://webserver/nginx/config/{{ config.config_file_name }}
    - user: {{ config.config_file_owner }}
    - group: {{ config.config_file_group }}
    - mode: {{ config.config_file_mode }}
    - watch_in:
      - service: {{ config.package_name }}

Install site configuration files:
  file.recurse:
    - file_mode: {{ config.config_file_mode }}
    - group: {{ config.config_file_group }}
    - name: {{ config.available_site_configurations_dir }}
    - source: salt://webserver/nginx/config/sites-available/
    - user: {{ config.config_file_owner }}
    - watch_in:
      - service: {{ config.package_name }}

