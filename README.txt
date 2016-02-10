Problems that would need to be fixed before moving to production:
1) Downloads Nginx directly from public repo with no version check.
  -> Should use a private repo (to save bandwidth)
  -> Should pin to a specific version number
2) No concept of dev/qa/production environments

Things to be aware of:
* Destination for nginx.conf file is templatized per-os, so install will fail
  if OS is not recognized.  (Nginx docs say the config can go into one of
  3 locations; this suggests it can change on different OS's so we use a
  template to figure out correct placement.)

Other comments:


Oldest supported version (and function that requires it):
  salt.modules.file.readdir - version 2014.1.0
