{% from 'webserver/nginx/map.jinja' import config with context %}

Install webserver:
  pkg.installed:
     - name: nginx

Install main nginx.conf file:
  file.managed:
    - name: {{ config.config_file_dir }}/{{ config.config_file_name }}
    - source: salt://webserver/nginx/config/{{ config.config_file_name }}
    - user: {{ config.config_file_owner }}
    - group: {{ config.config_file_group }}
    - mode: {{ config.config_file_mode }}
