#!/bin/bash
HOME=/data/flaskfarm_support/pipy/flaskfarm
rm -rf $HOME/flaskfarm
rm -rf $HOME/build
rm -rf $HOME/dist
rm -rf $HOME/FlaskFarm.egg-info
cp -R /data/flaskfarm $HOME

find $HOME/flaskfarm -type f -name "*.sh" -exec rm {} \;
find $HOME/flaskfarm -type f -name "*.log" -exec rm {} \;
find $HOME/flaskfarm -type d -name "__pycache__" -exec rm -rf {} \;

python setup.py sdist bdist_wheel
python -m twine upload dist/*



rm -rf $HOME/flaskfarm
rm -rf $HOME/build
rm -rf $HOME/dist
rm -rf $HOME/FlaskFarm.egg-info

# pypi-AgEIcHlwaS5vcmcCJDZjODA0ZjQ5LWM3YzMtNGMwOC1hOWZkLWEzOTZmODNiMzk2NgACKlszLCJiMGY0ZmIzYS00NjQ1LTRkMmMtOWNhOC0xYWE1MGZiM2E2YzUiXQAABiB08bO-r0Q1Qni1gPuq3xWollKVBKR1spwrHdtuckDZSg


# pypi
# 42ffddc0beb6b49d
# 25e5c11d0da176d7
# 9d24edbd705f3693
# 12029572131e8499
# 6952452d9ca8ca25
# 85e1979dad37b324
# 25f758deb2191d3b
# 3526c9cb7140d214