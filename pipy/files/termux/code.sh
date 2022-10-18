curl -fsSL https://code-server.dev/install.sh | sh
echo "code-server --bind-addr 0.0.0.0:9995 --user-data-dir /storage/Download/flaskfarm/code-server --config /storage/Download/flaskfarm/code-server/config.yaml" >> run.sh
chmod 777 run.sh
