Install webserver:
  pkg.installed:
     - name: {{ pillar['webserver'] }}

