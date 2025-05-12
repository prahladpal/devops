#!/bin/bash

# Label used in your Deployment
LABEL_SELECTOR="app=ace-server"

# Get the pod name dynamically
POD=$(kubectl get pod -l "$LABEL_SELECTOR" -o jsonpath="{.items[0].metadata.name}")

# Validate POD
if [ -z "$POD" ]; then
  echo "? Pod not found! Exiting."
  exit 1
fi

echo "?? Found ACE pod: $POD"

# Copy all BAR files
echo "?? Copying BAR files to pod..."
kubectl cp ./bar-files/. "$POD:/deployments"

# Deploy each BAR file
for bar in ./bar-files/*.bar; do
  barfile=$(basename "$bar")
  echo "?? Deploying $barfile..."
  #kubectl exec "$POD" -- su - aceadmin "mqsideploy -n INode01 -e default -a \"/deployments/$barfile\""
  kubectl exec "$POD" -- su - aceadmin -c "mqsideploy INode01 -e default -a \"/deployments/$barfile\""
done

echo "? All BAR files deployed!"