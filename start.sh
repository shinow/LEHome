#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR

mkdir -p log

echo 'running tag_endpoint.py'
python tag_endpoint.py > /dev/null 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'running ping_endpoint.py'
sudo python ping_endpoint.py > /dev/null 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'running audio server.py...'
sudo python audio_server.py > /dev/null 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'running home.py...'
python home.py > /dev/null 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

# echo 'running remote server proxy.py'
# python remote_server_proxy.py > log/remote_server.log 2>&1 &
# rc=$?
# if [[ $rc != 0 ]] ; then
#     exit $rc
# fi

echo 'running mqtt server proxy.py'
file='log/mqtt_server.log'
if [[ ! -f $file ]]; then
    touch $file
fi
python mqtt_server_proxy.py > log/mqtt_server.log 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'running geo_fencing_server.py'
file='log/geo_fencing.log'
if [[ ! -f $file ]]; then
    touch $file
fi

sleep 3 # wait for home.py to init.

python geo_fencing_server.py > log/geo_fencing.log 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

if [[ $1 != "silent" ]]
then
    echo 'running remote info sender.py'
    file='log/remote_proxy.log'
    if [[ ! -f $file ]]; then
        touch $file
    fi
    python remote_info_sender.py > log/remote_proxy.log 2>&1 &
    rc=$?
    if [[ $rc != 0 ]] ; then
        exit $rc
    fi
fi
# echo 'running sensor_server.py...'
# # python sensor_server.py > log/sensor.log 2>&1 &
# python sensor_server.py > /dev/null 2>&1 &
# rc=$?
# if [[ $rc != 0 ]] ; then
#     exit $rc
# fi

echo 'running qqfm.py...'
cd ../qqfm/
file='log/qqfm.log'
if [[ ! -f $file ]]; then
    touch $file
fi
sudo python qqfm.py > log/qqfm.log 2>&1 &
cd ../LEHome/
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'running quick_button.py'
sudo python quick_button.py > /dev/null 2>&1 &
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo 'LEHome started.'
