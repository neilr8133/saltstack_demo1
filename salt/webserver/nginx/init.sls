Install webserver:
  pkg.installed:
     - name: {{ pillar['webserver'] }}

Install main nginx.conf file:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://webserver/nginx/config/nginx.conf

