{% from 'webserver/nginx/map.jinja' import os_config with context %}

Make sure webserver is installed and running:
  pkg.installed:
    - name: {{ os_config.package_name }}
  service.running:
    - name: {{ os_config.package_name }}
    - enable: True
    - reload: True

Install main nginx_conf file:
  file.managed:
    - name: {{ os_config.file_dir }}/{{ os_config.file_name }}
    - source: salt://webserver/nginx/config/{{ os_config.file_name }}
    - user: {{ os_config.file_owner }}
    - group: {{ os_config.file_group }}
    - mode: {{ os_config.file_mode }}
    - watch_in:
      - service: {{ os_config.package_name }}

{% for each_site in salt['pillar.get']('nginx:lookup:sites_enabled') %}
Copy Nginx site-available {{ each_site }}:
  file.managed:
    - group: {{ os_config.file_group }}
    - mode: {{ os_config.file_mode }}
    - name: {{ os_config.available_site_configurations_dir }}/{{ each_site }}
    - source: salt://webserver/nginx/config/sites-available/{{ each_site }}
    - template: jinja
    - user: {{ os_config.file_owner }}
    - watch_in:
      - service: {{ os_config.package_name }}
    
Create symlink to activate Nginx site os_configuration {{ each_site }}:
  file.symlink:
    - file_mode: {{ os_config.file_mode }}
    - group: {{ os_config.file_group }}
    - mode: {{ os_config.file_mode }}
    - name: {{ os_config.enabled_site_symlinks_dir }}/{{ each_site }}
    - target: {{ os_config.available_site_configurations_dir }}/{{ each_site }}
    - user: {{ os_config.file_owner }}
    - watch_in:
      - service: {{ os_config.package_name }}

Copy Nginx site content for {{ each_site }}:
  file.recurse:
    - clean: True
    - dir_mode: {{ os_config.dir_mode }}
    - file_mode: {{ os_config.file_mode }}
    - group: {{ os_config.file_group }}
    - include_empty: True
    - name: {{ salt['pillar.get']('nginx:lookup:config:site_content_base_dir') }}/{{ each_site }}
    - source: salt://webserver/nginx/sites/{{ each_site }}
    - user: {{ os_config.file_owner }}
{% endfor %}

{% for disabled_site in salt['pillar.get']('nginx:lookup:sites_disabled') %}
Remove Nginx site-available {{ disabled_site }}:
  file.absent:
    - name: {{ os_config.available_site_configurations_dir }}/{{ disabled_site }}
    - watch_in:
      - service: {{ os_config.package_name }}

Remove Nginx site-enabled {{ disabled_site }}:
  file.absent:
    - name: {{ os_config.enabled_site_symlinks_dir }}/{{ disabled_site }}
    - watch_in:
      - service: {{ os_config.package_name }}

Remove Nginx site content for {{ disabled_site }}:
  file.absent:
    - name: {{ salt['pillar.get']('nginx:lookup:config:site_content_base_dir') }}/{{ disabled_site }}
{% endfor %}


