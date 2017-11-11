#!/bin/bash

DOMAIN=`basename -- "$0" .sh`

# Pod configuration
POD_USERNAME="demo"
POD_PASSWORD="demo"
POD_MOUNTPATH="$HOME"

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Wait until POD is Running
function wait_until_pod_is_running {
  # Wait until the docker is up and running
  echo -n ">> Waiting for '$1' to start..."
  while [ ! $(kubectl get pods --all-namespaces -l $2 -o jsonpath="{.items[0].status.phase}" &>/dev/null && echo $?) ]
  do
      echo -n "."
      sleep 0.5
  done
  echo "started!"
}

# Install helm dependency with configuration
# $1: channel ( stable/incubator/test)
# $2: app name
function helm_install_with_config {
  # Copy the template
  cp -f config.tpl.yaml config.yaml

  # Replace configurations
  sedeasy "VPS_POD_DOMAIN" "$DOMAIN" config.yaml
  sedeasy "VPS_POD_USERNAME" "$POD_USERNAME" config.yaml
  sedeasy "VPS_POD_PASSWORD" "$POD_PASSWORD" config.yaml
  sedeasy "VPS_POD_MOUNTPATH" "$POD_MOUNTPATH" config.yaml

  helm install --name "${DOMAIN/./-}" \
    -f "config.yaml" \
    "$1" &>/dev/null
}

helm_install_with_config "webdav"

wait_until_pod_is_running "${DOMAIN/./-}" "app=webdav"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${DOMAIN}/"
echo "-----------------------------------------------------"