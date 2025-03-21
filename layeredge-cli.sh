#!/bin/bash

set -e

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".

# Verify npm version:
npm -v # Should print "10.9.2".

# Install PM2
npm i -g pm2

# Install Go
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source .bash_profile
go version

# Verify Go installation
if ! command -v go &> /dev/null; then
    echo "Go installation failed. Try running 'source ~/.bashrc' and 'go version' manually."
    exit 1
fi
go version

# Clone Repository
echo "Cloning Light Node repository..."
git clone https://github.com/Layer-Edge/light-node.git
cd light-node

# Prompt for PRIVATE_KEY input
while true; do
    read -p "Enter your PRIVATE_KEY (without 0x prefix): " PRIVATE_KEY
    if [[ "$PRIVATE_KEY" =~ ^0x ]]; then
        echo "Error: PRIVATE_KEY should not start with 0x. Please enter it correctly."
    else
        break
    fi
done

# Configure .env file
echo "Configuring environment variables..."
cat <<EOT > .env
GRPC_URL=grpc.testnet.layeredge.io:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=https://layeredge.mintair.xyz
API_REQUEST_TIMEOUT=100
POINTS_API=https://light-node.layeredge.io
PRIVATE_KEY='$PRIVATE_KEY'
EOT

# Build and run the node
echo "Building and starting Light Node..."
cd $HOME/light-node
go build
pm2 start light-node --name layeredge
pm2 logs layeredge

echo "Installation completed successfully!"
