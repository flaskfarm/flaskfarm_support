call C:\work\FlaskFarm\.env\Scripts\activate 
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\build
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\dist
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\FlaskFarm.egg-info

mkdir C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm
XCOPY C:\work\FlaskFarm\flaskfarm C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm  /e /h /k

del /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm\cli\*.log
del /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm\lib\support\site\wavve.py
del /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm\lib\support\site\tving.py
python setup.py sdist bdist_wheel
python -m twine upload dist/*

rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\flaskfarm
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\build
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\dist
rmdir /s /q C:\work\FlaskFarm\flaskfarm_support\pipy\flaskfarm\FlaskFarm.egg-info

