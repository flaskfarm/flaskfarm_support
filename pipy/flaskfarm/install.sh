#!/bin/bash
ENV_PATH=/data/flaskfarm_support/pipy/flaskfarm/.env_ubuntu
rm -rf $ENV_PATH
virtualenv $ENV_PATH
source $ENV_PATH/bin/activate
pip install --upgrade FlaskFarm
pip install -r $ENV_PATH/lib/python3.10/site-packages/flaskfarm/files/requirements_normal.txt
