#!/bin/bash
# By Caio Villela
# Example ./setup.sh [app_name] [environment]

if [ -d /opt/${1}/run-env/${2} ]; then
   echo "Directory /opt/${1}/run-env/${2} exists."
else
   echo "Directory /opt/${1}/run-env/${2} does not exist."
   echo "Creating directory."
   sudo mkdir -p /opt/${1}/run-env/${2}
fi

### Start & Stop Scripts 
if [ -f start.sh ]; then
    rm start.sh
fi
cat >> start.sh << EOF1
#!/bin/bash
cd /opt/$1/run-env/${2}
export TAG=\`cat tag.lock\`
export BRANCH=\`cat branch.lock\`
export AWS_REGISTRY_URL=\`cat aws-ecr.lock\`
export GITLAB_REGISTRY_URL=\`cat gitlab-registry.lock\`
docker-compose stop
docker-compose rm -f
echo y |docker system prune
docker-compose up
EOF1

if [ -f stop.sh ]; then
    rm stop.sh
fi
cat >> stop.sh << EOF2
#!/bin/bash
cd /opt/$1/run-env/${2}
export TAG=\`cat tag.lock\`
export BRANCH=\`cat branch.lock\`
export AWS_REGISTRY_URL=\`cat aws-ecr.lock\`
export GITLAB_REGISTRY_URL=\`cat gitlab-registry.lock\`
docker-compose stop
docker-compose rm -f
echo y |docker system prune
EOF2

sudo mv start.sh stop.sh /opt/${1}/run-env/${2}
sudo chmod +x /opt/${1}/run-env/${2}/start.sh /opt/${1}/run-env/${2}/stop.sh

if [ -f ${1}{$2}.service ]; then
    rm ${1}${2}.service
fi
### Systemd Service
cat >> ${1}-${2}.service << EOF3
[Unit]
Description=${1} ${2} stack
Requires=docker.service
After=network.target docker.service

[Service]
Type=simple
Restart=always
StartLimitBurst=5
RestartSec=30
WorkingDirectory=/opt/${1}/run-env/${2}
ExecStart=/opt/${1}/run-env/${2}/start.sh
ExecStop=/opt/${1}/run-env/${2}/stop.sh
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF3

sudo mv ${1}-${2}.service /etc/systemd/system/
systemctl disable "${1}-${2}.service"
systemctl enable "${1}-${2}.service"
chmod +x /etc/systemd/system/${1}-${2}.service

sudo cp docker-compose.production.yml /opt/${1}/run-env/${2}/docker-compose.yml

sudo chown -R gitlab-runner:gitlab-runner /opt/$1
