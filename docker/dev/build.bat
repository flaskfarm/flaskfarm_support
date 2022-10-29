REM docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t flaskfarm/flaskfarm:1.1-dev --push .
REM docker buildx build --no-cache --platform linux/amd64 -t flaskfarm/flaskfarm:1.2-dev --push .
REM docker buildx build --no-cache --platform linux/amd64 -t flaskfarm/flaskfarm:1.2-dev --push .
REM docker buildx build --no-cache --progress plain --platform linux/amd64 -t flaskfarm/flaskfarm:1.7 --push .
REM docker buildx build --no-cache --progress plain --platform linux/amd64,linux/arm64,linux/arm/v7 -t flaskfarm/flaskfarm:2.0-dev --push .
REM NORMAL에서는 requirements   useful 제외
REM docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t flaskfarm/flaskfarm:1.1-dev --push .
REM docker buildx build --platform linux/amd64 -t flaskfarm/flaskfarm:0.1-alpine
REM docker buildx build --no-cache --platform linux/amd64,linux/arm64,linux/arm/v7 -t flaskfarm/flaskfarm:1.0 --push .

cd C:\work\FlaskFarm\flaskfarm_support\docker\dev
copy /e /h /k C:\work\FlaskFarm\flaskfarm_support\files\docker_dev\flaskfarm.sh C:\work\FlaskFarm\flaskfarm_support\docker\dev
docker buildx build --no-cache --progress plain --platform linux/amd64,linux/arm64 -t flaskfarm/flaskfarm:4.0-dev --push .