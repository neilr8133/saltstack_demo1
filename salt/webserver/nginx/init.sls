{% from 'webserver/nginx/map.jinja' import os_config with context %}

# Disable SELinux (Bad, bad, bad!!)
permissive:
  selinux.mode

Make sure Nginx package repo is installed:
  pkgrepo.managed:
    {% if salt['grains.get']('os_family') == 'RedHat' %}
    # Use yum.
    - enabled: 1
    - humanname: nginx repo
    # Define the repo name (has '/etc/yum.repo.d/' prepended and '.repo' appended automatically)
    # Bug: 'name' should be the content that goes inside, but on CentOS it
    # serves as the filename--`file' gets added as a value within the file!
    - name: nginx
    {% else %}
    # Use apt.
    - file: {{ os_config.repo_list_dir }}/nginx.repo
    - names:
      - deb http://nginx.org/packages/debian/ codename nginx
      - deb-src http://nginx.org/packages/debian/ codename nginx 
    {% endif %}
    # Convert the OS to all lowercase on the next line ('CentOS' => 'centos')
    - baseurl: http://nginx.org/packages/{{ salt['grains.get']('os').lower() }}/7/$basearch/
    - gpgcheck: 0
    - key_url: salt://{{ salt['pillar.get']('nginx:source_base_dir') }}/nginx_signing.key
    - require_in:
      - pkg: {{ os_config.package_name }}
  file.directory:
    - dir_mode: {{ os_config.dir_mode }}
    - file_mode: {{ os_config.file_mode }}
    - group: {{ os_config.file_group }}
    - name: {{ os_config.file_dir }}
    - recurse:
      - mode
      - group
      - user
    - user: {{ os_config.file_owner }}

Configure webserver user {{ os_config.file_owner }}:
  group.present:
    - name: {{ os_config.file_group }}
    - system: True
  user.present:
    - createhome: False
    - groups:
      - {{ os_config.file_group }}
    - name: {{ os_config.file_owner }}
    - remove_groups: True
    - require:
      - group: {{ os_config.file_group }}
    - shell: /usr/sbin/nologin

Make sure webserver is installed and running:
  pkg.installed:
    - name: {{ os_config.package_name }}
  service.running:
    - name: {{ os_config.package_name }}
    - enable: True
    - reload: True

Install main nginx_conf file:
  file.managed:
    - group: {{ os_config.file_group }}
    - makedirs: True
    - mode: {{ os_config.file_mode }}
    - name: {{ os_config.file_dir }}/{{ os_config.file_name }}
    - source: salt://{{ salt['pillar.get']('nginx:source_base_dir') }}/config/{{ os_config.file_name }}
    - template: jinja
    - user: {{ os_config.file_owner }}
    - watch_in:
      - service: {{ os_config.package_name }}

{% for each_site in salt['pillar.get']('nginx:sites_enabled') %}
Copy Nginx site-available {{ each_site }}:
  file.managed:
    - group: {{ os_config.file_group }}
    - makedirs: True
    - mode: {{ os_config.file_mode }}
    - name: {{ os_config.available_site_configurations_dir }}/{{ each_site }}
    - source: salt://{{ salt['pillar.get']('nginx:source_base_dir') }}/config/sites-available/{{ each_site }}
    - template: jinja
    - user: {{ os_config.file_owner }}
    - watch_in:
      - service: {{ os_config.package_name }}
    
Create symlink to activate Nginx site os_configuration {{ each_site }}:
  file.symlink:
    - file_mode: {{ os_config.file_mode }}
    - group: {{ os_config.file_group }}
    - makedirs: True
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
    - name: {{ salt['pillar.get']('nginx:server:site_content_base_dir') }}/{{ each_site }}
    - source: salt://{{ salt['pillar.get']('nginx:source_base_dir') }}/sites/{{ each_site }}
    - user: {{ os_config.file_owner }}
{% endfor %}

{% for disabled_site in salt['pillar.get']('nginx:sites_disabled') %}
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
    - name: {{ salt['pillar.get']('nginx:server:site_content_base_dir') }}/{{ disabled_site }}
{% endfor %}

Flush iptables:
  iptables.flush:
    - name: ACCEPT

Configure iptables to accept web requests:
  iptables.append:
    - chain: INPUT
    - comment: "Allow HTTP"
    - connstate: NEW
    - dport: {{ salt['pillar.get']('nginx:server:listen_port') }}
    - jump: ACCEPT
    - match: state
    - proto: tcp
    - save: True
    - table: filter

