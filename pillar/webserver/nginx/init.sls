nginx:
  lookup:
    sites_enabled:
      - default
    sites_disabled: []
    config:
      listen_port: 8888
# All content will be rooted at the following prefix:
      site_content_base_dir: /usr/share/nginx/sites
