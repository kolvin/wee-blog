apt -y install apt-transport-https lsb-release ca-certificates
curl -sL https://deb.nodesource.com/setup_12.x | bash -

apt -y install nodejs
apt -y  install gcc g++ make

# Version output
node --version
npm --version