{% from 'webserver/nginx/map.jinja' import config with context %}
{% from 'webserver/nginx/map.jinja' import sites_enabled %}

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

{% for each_site in sites_enabled %}
Copy Nginx site configuration {{ each_site }}:
  file.managed:
    - group: {{ config.config_file_group }}
    - mode: {{ config.config_file_mode }}
    - name: {{ config.available_site_configurations_dir }}/{{ each_site }}
    - source: salt://webserver/nginx/config/sites-available/{{ each_site }}
    - user: {{ config.config_file_owner }}
    - watch_in:
      - service: {{ config.package_name }}
    
Create symlink to activate Nginx site configuration {{ each_site }}:
  file.symlink:
    - file_mode: {{ config.config_file_mode }}
    - group: {{ config.config_file_group }}
    - mode: {{ config.config_file_mode }}
    - name: {{ config.enabled_site_symlinks_dir }}/{{ each_site }}
    - target: {{ config.available_site_configurations_dir }}/{{ each_site }}
    - user: {{ config.config_file_owner }}
    - watch_in:
      - service: {{ config.package_name }}
{% endfor %}
