Issues and comments:
1) Downloads Nginx directly from public repo with no version check.
  -> Should use a private repo (to save bandwidth)
  -> Should pin to a specific version number
2) No concept of dev/qa/production environments
3) Nginx config file source and destination are hard-coded
  -> Should use variables for OS-specific placement
