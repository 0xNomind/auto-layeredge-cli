#!/bin/bash

set -e

# Install NVM
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install Node.js
echo "Installing Node.js..."
nvm install 22

# Verify installation
echo "Verifying Node.js and npm versions..."
node -v
npm -v

# Install PM2
echo "Installing PM2..."
npm i -g pm2
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> $HOME/.bashrc
echo 'export PATH="$(npm root -g)/pm2/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo 'source "$HOME/.cargo/env"' >> $HOME/.bashrc
source $HOME/.bashrc

# Install Go
echo "Installing Go..."
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bashrc
source $HOME/.bashrc
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
