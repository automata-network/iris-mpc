#!/usr/bin/env bash
set -e

NODE_ID="$1"
if [ -z "$NODE_ID" ]; then
  echo "Usage: run-server.sh <node_id>"
  exit 1
fi

source /bin/.test.env
source /bin/.test.hawk${NODE_ID}.env
echo "AWS_ENDPOINT_URL: ${AWS_ENDPOINT_URL}"
echo "SMPC__PARTY_ID: ${SMPC__PARTY_ID}"

# needs to run twice to create the keys with both AWSCURRENT and AWSPREVIOUS states
/bin/key-manager --region "$AWS_REGION" --endpoint-url "$AWS_ENDPOINT_URL" --node-id "$NODE_ID" --env dev rotate --public-key-bucket-name wf-dev-public-keys
/bin/key-manager --region "$AWS_REGION" --endpoint-url "$AWS_ENDPOINT_URL" --node-id "$NODE_ID" --env dev rotate --public-key-bucket-name wf-dev-public-keys

# Set the stack size to 100MB to receive large messages.
export RUST_MIN_STACK=104857600

mkdir /bin/${NODE_ID}
cp /bin/iris-mpc-hawk /bin/${NODE_ID}/iris-mpc-hawk
cat /bin/.test.env >> /bin/${NODE_ID}/.env
cat /bin/.test.hawk${NODE_ID}.env >> /bin/${NODE_ID}/.env
# echo "ls -al /bin/${NODE_ID}"
# ls -al /bin/${NODE_ID}

# /bin/iris-mpc-hawk
cd /bin/${NODE_ID}
/bin/${NODE_ID}/iris-mpc-hawk