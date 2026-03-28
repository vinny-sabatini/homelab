#! /bin/sh

set -euo

echo "Click enter when ready to configure bridge interface (cluster stable)"
read -p ""
talosctl patch mc --patch @talos-patches/bridge-interface.yaml
