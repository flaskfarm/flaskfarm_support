SET ENV_PATH=C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\.env_win

rmdir /s /q %ENV_PATH%
virtualenv %ENV_PATH%
call %ENV_PATH%\Scripts\activate
pip install --upgrade FlaskFarm
pip install -r %ENV_PATH%\Lib\site-packages\flaskfarm\files\requirements_normal.txt
