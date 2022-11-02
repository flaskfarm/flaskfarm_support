REM docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t flaskfarm/flaskfarm:4.0 --push .
docker buildx build --no-cache --progress plain --platform linux/amd64,linux/arm64 -t flaskfarm/flaskfarm:4.0 --push .