SET ENV_PATH=C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\.env_win

rmdir /s /q %ENV_PATH%
virtualenv %ENV_PATH%
call %ENV_PATH%\Scripts\activate
python -m pip install --upgrade pip
pip install --upgrade flaskfarm
pip install -r %ENV_PATH%\Lib\site-packages\flaskfarm\files\requirements_normal.txt
