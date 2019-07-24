# shshare

shshare is a command-line utility to automatically capture and upload screenshots and screen recordings (screencasts). It is written entirely in Bash.

## uploader.sh

The `uploader.sh` file is what shshare uses to upload data to a host. By default, it resides in `/etc/shshare/` and uploads both screenshots and screencasts to imgur, but can be copied to `$XDG_CONFIG_HOME` and modified to the user's liking.

`uploader.sh` takes the screenshot or screencast as standard input. In the case of screenshots, this is the direct output of `maim`. In the case of screencasts, it is the contents of `/tmp/screencast.mp4`, the temporary file written to by ffmpeg.
