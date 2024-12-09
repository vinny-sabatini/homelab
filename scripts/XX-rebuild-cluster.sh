#! /bin/sh

set -euo

NODE_IP=$1

# Rebuild cluster
talosctl reset -n ${NODE_IP} --reboot -e ${NODE_IP} --wipe-mode all --graceful=false
