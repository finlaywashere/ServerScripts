#!/bin/bash
# A script that automatically downloads, and sets up deploy scripts for my applications on Github

DESTINATION_BASE="/usr/lib"

if [ "$EUID" -ne 0 ];then
        echo "Please run as root"
        exit
fi

if [[ "$#" -ne 2 ]]; then
        echo "Usage: ./newdeploy <name> <user>"
        exit
fi

curr=$(pwd)

name=$1
user=$2

service=$(echo $name | tr '[:upper:]' '[:lower:]')

url="https://github.com/finlaywashere/${name}"

cd $DESTINATION_BASE
mkdir $name
cd $name
git clone "https://github.com/finlaywashere/${name}"

echo "#!/bin/bash
sudo -u $user ./deploy.sh
rm log.txt
systemctl restart $service
" > deploy_root.sh

chmod +x deploy_root.sh

echo "#!/bin/bash
cd $name
git pull
JAVA_HOME=/usr/lib/jvm/default/ ./gradlew build
cp build/libs/${name}-all.jar ../
chmod +x ../${name}-all.jar
" > deploy.sh

chmod +x deploy.sh

echo "#!/bin/bash
java -jar ${name}-all.jar >> log.txt 2>&1
" > start.sh

chown -R ${user}:${user} .

cd $curr
./mkservice.sh $service "${DESTINATION_BASE}/${name}/start.sh" $user
