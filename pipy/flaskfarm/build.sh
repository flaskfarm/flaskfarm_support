#!/bin/bash
HOME=/data/flaskfarm_support/pipy/flaskfarm
rm -rf $HOME/flaskfarm
rm -rf $HOME/build
rm -rf $HOME/dist
rm -rf $HOME/FlaskFarm.egg-info
cp -R /root/flaskfarm $HOME

python setup.py sdist bdist_wheel
python -m twine upload dist/*

rm -rf $HOME/flaskfarm
rm -rf $HOME/build
rm -rf $HOME/dist
rm -rf $HOME/FlaskFarm.egg-info
