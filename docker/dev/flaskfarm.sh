#!/bin/bash
LINE="==========================================="
APP_HOME="$HOME/flaskfarm"
APP_NAME="flaskfarm"
DIR_DATA="/data"
DIR_BIN="/usr/bin"
GIT="https://github.com/flaskfarm/flaskfarm.git"

SCRIPT_TYPE="ubuntu"
SCRIPT_VERSION="1.2.0"
SCRIPT_NAME="flaskfarm.sh"
SCRIPT_URL="https://raw.githubusercontent.com/flaskfarm/flaskfarm_support/main/files/docker_dev/flaskfarm.sh"

PYTHON="python"
PIP="pip"
PACKAGE_CMD="apt-get -y --no-install-recommends"
PS_COMMAND="ps -eo pid,args"

PROGRAM_PATH="$DIR_DATA/programs"

###########################################
# 공통
###########################################
download_shell_script() {
    curl -Lo $APP_HOME/$SCRIPT_NAME "$SCRIPT_URL"
    chmod +x $APP_HOME/$SCRIPT_NAME
}

make_run_script() {
    cat <<EOF >$APP_HOME/run.sh
#!/bin/bash
curl -Lo $APP_HOME/$SCRIPT_NAME "$SCRIPT_URL"
chmod +x $APP_HOME/$SCRIPT_NAME
bash $APP_HOME/$SCRIPT_NAME start
EOF
    chmod +x $APP_HOME/run.sh
}

stop() {
    $PS_COMMAND | grep main.py | grep -v grep | awk '{print $1}' | xargs -r kill -9
}

install_ffmpeg() {
    $PACKAGE_CMD install ffmpeg
}

install_filebrowser() {
    FILEBROWSER_PATH="$DIR_BIN/filebrowser"
    TMP_PATH=$APP_HOME/tmp
    mkdir -p $TMP_PATH
    $PS_COMMAND | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
    if [ -e $FILEBROWSER_PATH ]; then
      rm $FILEBROWSER_PATH
    fi
    case "$(uname -m)" in
        aarch64) ARCH="arm64";;
        x86_64) ARCH="amd64";;
        amd64) ARCH="amd64";;
        *) ARCH="armv7";;
    esac
    curl -Lo $TMP_PATH/file.tar.gz "https://github.com/filebrowser/filebrowser/releases/download/v2.22.4/linux-$ARCH-filebrowser.tar.gz"
    tar -zxvf $TMP_PATH/file.tar.gz -C $TMP_PATH
    mv "$TMP_PATH/filebrowser" "$FILEBROWSER_PATH"
    chmod +x $FILEBROWSER_PATH
    echo 'nohup bash -c "cd / && filebrowser -a 0.0.0.0 -p 9996 -d /data/db/filebrowser.db" > /dev/null 2>&1 &' >> $APP_HOME/pre_start.sh
    rm -rf $TMP_PATH
}

install_rclone() {
    if [ "$SCRIPT_TYPE" = "ubuntu" ]; then
        $PACKAGE_CMD install unzip
    elif [ "$SCRIPT_TYPE" = "entware" ]; then 
        $PACKAGE_CMD install unzip coreutils-mktemp
    fi
    RCLONE_PATH="$DIR_BIN/rclone"
    $PS_COMMAND | grep rclone | grep -v grep | awk '{print $1}' | xargs -r kill -9
    if [ -e $RCLONE_PATH ]; then
      rm $RCLONE_PATH
    fi
    VERSION="1.59.2-41"
    case "$(uname -m)" in
      aarch64) ARCH="arm64";;
      x86_64) ARCH="amd64";;
      amd64) ARCH="amd64";;
      *) ARCH="arm-v7";;
    esac
    TMP_PATH=$APP_HOME/tmp
    mkdir -p $TMP_PATH
    curl -Lo $TMP_PATH/rclone.zip "https://github.com/wiserain/rclone/releases/download/v$VERSION/rclone-v$VERSION-linux-$ARCH.zip"
    unzip $TMP_PATH/rclone.zip -d $TMP_PATH
    chmod +x "$TMP_PATH/rclone-v$VERSION-linux-$ARCH/rclone"
    mv "$TMP_PATH/rclone-v$VERSION-linux-$ARCH/rclone" "$RCLONE_PATH"
    rm -rf $TMP_PATH
}
###########################################

# Dockerfile에서 호출
prepare() {
    export DEBIAN_FRONTEND=noninteractive
    export TZ=Asia/Seoul
    $PACKAGE_CMD update 
    $PACKAGE_CMD install locales
    locale-gen ko_KR.UTF-8
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
}
 
install() {
    echo -e "\n\n설치 시작"
    $PACKAGE_CMD update
    $PACKAGE_CMD install tzdata
    $PACKAGE_CMD install \
        git \
        python3 \
        python3-dev \
        python3-pip \
        curl \
        redis \
        fuse \
        vnstat \
        'libboost-python[0-9.]+$'
    ln -s /usr/bin/python3 /usr/bin/python
    $PIP config set global.cache-dir false
    $PYTHON -m pip install --upgrade pip
    if [ ! -d $APP_HOME ]; then 
        git clone --depth 1 $GIT $APP_HOME
        download_shell_script
        make_run_script
    else
        cd $APP_HOME && git reset --hard HEAD && git pull
    fi
    $PIP --no-cache-dir install --upgrade setuptools wheel
    $PIP install -r $APP_HOME/files/requirements_mini.txt
    $PIP install -r $APP_HOME/files/requirements_normal.txt
    $PIP install -r $APP_HOME/files/requirements_useful.txt

    mkdir -p $DIR_DATA
    if [ ! -d /app ]; then 
        ln -s $APP_HOME /app
    fi

    #if [ ! -e $APP_HOME/export.sh ]; then
    cat <<EOF >$APP_HOME/export.sh
#!/bin/bash
export REDIS_PORT="46379"
export CELERY_WORKER_COUNT="2"
export C_FORCE_ROOT="true"
export UPDATE_STOP="false"
export DOCKER_NONSTOP="false"
export TERM="xterm"
export PLUGIN_UPDATE_FROM_PYTHON="false"
EOF
    chmod +x $APP_HOME/export.sh
    #fi

    . $APP_HOME/export.sh

    if [ ! -e /etc/default/flaskfarm_celery ]; then
        cat <<EOF >/etc/default/flaskfarm_celery
#!/bin/sh -e
. $APP_HOME/export.sh
CELERY_APP="main.celery"
CELERYD_CHDIR="${APP_HOME}"
CELERY_BIN="celery"
CELERYD_USER="root"
CELERYD_GROUP="root"
CELERY_BIN="/usr/local/bin/celery"
CELERYD_OPTS='-c $CELERY_WORKER_COUNT --config_filepath=/data/config.yaml --running_type=docker'
EOF
        chmod +x /etc/default/flaskfarm_celery
    fi

    # pre_start.sh 파일 생성
    if [ ! -e $APP_HOME/pre_start.sh ]; then
        cat <<EOF >$APP_HOME/pre_start.sh
#!/bin/bash
EOF
        chmod +x $APP_HOME/pre_start.sh
    fi

    # redis 설정
    sed -i "s/port 6379/port $REDIS_PORT/g" /etc/redis/redis.conf
    update-rc.d redis-server defaults

    # celery daemon 설정
    curl -o /etc/init.d/flaskfarm_celery https://raw.githubusercontent.com/celery/celery/master/extra/generic-init.d/celeryd
    chmod +x /etc/init.d/flaskfarm_celery
    update-rc.d flaskfarm_celery defaults

    # cache 삭제
    rm -rf /var/lib/apt/lists/*
}



install_nginx() {
    $PACKAGE_CMD install \
    nginx sqlite3 \
    php8.1-fpm php8.1-soap php8.1-gmp php8.1-dom php8.1-zip php8.1-mysqli php8.1-sqlite3 php8.1-apcu php8.1-bcmath php8.1-gd php8.1-xmlrpc php8.1-bz2 php8.1-curl  php8.1-mbstring  
    sed -i "s/user www-data;/user root;/" /etc/nginx/nginx.conf
    sed -i "s/--daemonize/--daemonize -R/" /etc/init.d/php8.1-fpm
    sed -i "s/user = www-data/user = root/" /etc/php/8.1/fpm/pool.d/www.conf
    sed -i "s/group = www-data/group = root/" /etc/php/8.1/fpm/pool.d/www.conf
    curl -Lo /etc/nginx/sites-available/default https://raw.githubusercontent.com/flaskfarm/flaskfarm_support/main/files/docker_dev/nginx_default
    echo 'service php8.1-fpm restart' >> $APP_HOME/pre_start.sh
    echo 'service nginx restart' >> $APP_HOME/pre_start.sh
    if [ ! -d $DIR_DATA/html ]; then 
        mkdir -p $DIR_DATA/html
        mv /var/www/html/index.nginx-debian.html $DIR_DATA/html
        echo '<?php phpinfo(); ?>' >> $DIR_DATA/html/phpinfo.php
    fi
    mkdir -p /run/php
    touch /run/php/php8.1-fpm.sock
    rm -rf /var/www/html
    ln -s $DIR_DATA/html /var/www/html 
}


install_code_server() {
    curl -fsSL https://code-server.dev/install.sh | sh
    echo -e "\n\n"
    #read -r -p "사용할 암호를 입력하세요 > " new
    new="admin"
    config="$DIR_DATA/code-server/config.yaml"
    mkdir -p $DIR_DATA/code-server
    #old=`sed -n '3p' $config | awk '{print $2}'`
    #sed -i "s/$old/$new/" $config
    cat <<EOF >$config
bind-addr: 127.0.0.1:9995
auth: password
password: $new
cert: false
EOF
    mkdir -p $DIR_DATA/code-server
    echo "nohup code-server --bind-addr 0.0.0.0:9995 --user-data-dir $DIR_DATA/code-server --config $config > /dev/null 2>&1 &" >> $APP_HOME/pre_start.sh
    rm -rf $HOME/.cache/code-server
}


install_tool() {
    $PACKAGE_CMD update
    install_nginx
    install_code_server
    install_filebrowser
    install_rclone
    install_ffmpeg
    install_vim
    rm -rf /var/lib/apt/lists/*
}


install_vim() {
    $PACKAGE_CMD install vim
    cat <<EOF >~/.vimrc
set encoding=utf-8
set fileencodings=utf-8,euc-kr
EOF
}


install_transmission() {
    $PACKAGE_CMD update
    $PACKAGE_CMD install wget transmission-daemon
    APP_PATH=$DIR_DATA/programs/transmission
    mkdir -p $APP_PATH
    rm $APP_PATH/settings.json
    ln -s /var/lib/transmission-daemon/.config/transmission-daemon $APP_PATH/settings.json 

    cd $APP_PATH
    curl -Lo install.sh https://raw.githubusercontent.com/ronggang/transmission-web-control/master/release/install-tr-control.sh
    chmod +x install.sh
    . install.sh
    rm $APP_PATH/install.sh
    echo "service transmission-daemon restart" >> $APP_HOME/pre_start.sh

    echo "$APP_PATH/settings.json 편집"
}


install_mycomix() {
    cd $DIR_DATA/html
    if [ ! -d $DIR_DATA/html/myComix ]; then 
        git clone https://github.com/imueRoid/myComix --depth 1
    fi
    chmod 777 -R $DIR_DATA/html/myComix
}

install_webtoon_viewer() {
    cd $DIR_DATA/html
    if [ ! -d $DIR_DATA/html/webtoon ]; then 
        git clone https://github.com/enaskr/webtoon --depth 1
    fi
    chmod 777 -R $DIR_DATA/html/webtoon
}


install_kodexplorer() {
    cd $DIR_DATA/html
    if [ ! -d $DIR_DATA/html/KodExplorer ]; then 
        git clone https://github.com/kalcaddle/KodExplorer --depth 1
        cat <<EOF >$DIR_DATA/html/KodExplorer/config/define.php
<?php define ('DATA_PATH', '/data/html/KodExplorer/data/');
EOF
    fi
    chmod 777 -R $DIR_DATA/html/KodExplorer
}

install_squid() {
    $PACKAGE_CMD update
    $PACKAGE_CMD install squid apache2-utils
    #cp /etc/squid/squid.conf /etc/squid/squid.conf.default
    #curl -Lo /etc/squid/squid.conf "https://flaskfarm.github.io/files/docker/squid.conf"
    sed -i "s/http_port 3128/http_port 9994/" /etc/squid/squid.conf
    chmod 777 /etc/squid/squid.conf
    echo -e '\n\n'
    read -p "인증 user 입력 > " user
    read -p "인증 pass 입력 > " pass
    htpasswd -c -b /etc/squid/squid_passwd "$user" "$pass"
    echo 'service squid restart' >> $APP_HOME/pre_start.sh
    service squid restart
    echo -e '\n설치 완료'
    echo -e "\ncurl -x $user:$pass@localhost:9994 https://google.come  명령으로 동작 확인"
}

install_ssh() {
    $PACKAGE_CMD install ssh
}

plugin_update() {
    echo "plugin update"
    SECRET_KEY='foobar'
    export SECRET_KEY
    python3 -c "import os; print( os.environ.get('SECRET_KEY', 'Nonesuch'))"
    if [ -d $DIR_DATA/plugins ]; then
        REPOS="$(ls $DIR_DATA/plugins)"
        for repo in $REPOS
        do
            if [ -d "$DIR_DATA/plugins/${repo}" ]; then
                if [ -d "$DIR_DATA/plugins/$repo/.git" ] && [ ! -e "$DIR_DATA/plugins/$repo/.update_stop" ]; then
                    echo $LINE
                    echo "플러그인 : $repo"
                    find $DIR_DATA/plugins/$repo/.git -name "index.lock" -exec rm -f {} \;
                    git -C $DIR_DATA/plugins/$repo reset --hard HEAD
                    git -C $DIR_DATA/plugins/$repo pull
                    echo $LINE
                    echo -e '\n'
                fi
            fi
        done
    fi
}
 

start() {
    cd $APP_HOME
    . $APP_HOME/export.sh
    if [ -e $APP_HOME/pre_start.sh ]; then
        . $APP_HOME/pre_start.sh
    fi
    if [ -e /etc/init.d/redis-server ]; then
        service redis-server start
    fi

    COUNT=0
    while true; 
    do
        . $APP_HOME/export.sh
        if [ "$UPDATE_STOP" == "true" ]; then
            echo "pass git reset !!"
        else
            find $APP_HOME/.git -name "index.lock" -exec rm -f {} \;
            git reset --hard HEAD
            git remote set-url origin $GIT
            git pull
            if [ "$PLUGIN_UPDATE_FROM_PYTHON" == "false" ]; then
                echo "PLUGIN_UPDATE_FROM_SCRIPT"
                plugin_update
            else
                ehco "PLUGIN_UPDATE_FROM_PYTHON"
            fi
        fi

        if [ -e /etc/init.d/flaskfarm_celery ]; then
            cat <<EOF >/etc/default/flaskfarm_celery
#!/bin/sh -e
. $APP_HOME/export.sh
CELERY_APP="main.celery"
CELERYD_CHDIR="${APP_HOME}"
CELERY_BIN="celery"
CELERYD_USER="root"
CELERYD_GROUP="root"
CELERY_BIN="/usr/local/bin/celery"
CELERYD_OPTS='-c $CELERY_WORKER_COUNT --config_filepath=/data/config.yaml --running_type=docker'
EOF
            chmod +x /etc/default/flaskfarm_celery
            $PS_COMMAND | grep main.celery | grep -v grep | awk '{print $1}' | xargs -r kill -9
            service flaskfarm_celery restart
        fi 
        $PYTHON -u main.py --repeat ${COUNT} --config "/data/config.yaml"
        RESULT=$?
        echo "PYTHON EXIT CODE : ${RESULT}.............."
        if [ "$RESULT" = "1" ]; then
            echo 'REPEAT....'
        else
            echo 'FINISH....'
            break
        fi 
        COUNT=`expr $COUNT + 1`
    done
    if [ -e /etc/init.d/redis-server ]; then
        service redis-server stop
    fi
    if [ -e /etc/init.d/flaskfarm_celery ]; then
        service flaskfarm_celery stop
    fi
    if [ "$DOCKER_NONSTOP" == "true" ]; then
        while true;
        do
            sleep 1d
        done
    fi
}


foreground_start() {
    cd $APP_HOME
    . $APP_HOME/export.sh
    if [ -e /etc/init.d/redis-server ]; then
        service redis-server restart
    fi
    #export UPDATE_STOP="true"
    COUNT=0
    while true;
    do
        if [ "$UPDATE_STOP" == "true" ]; then
            echo "pass git reset !!"
        else
            find $APP_HOME/.git -name "index.lock" -exec rm -f {} \;
            git reset --hard HEAD
            git remote set-url origin $GIT
            git pull
            if [ "$PLUGIN_UPDATE_FROM_PYTHON" == "false" ]; then
                echo "PLUGIN_UPDATE_FROM_SCRIPT"
                plugin_update
            else
                echo "PLUGIN_UPDATE_FROM_PYTHON"
            fi
        fi
 
        $PYTHON -u main.py --repeat ${COUNT} --config "/data/config.yaml"
        RESULT=$?
        echo "PYTHON EXIT CODE : ${RESULT}.............."
        if [ "$RESULT" = "1" ]; then
            echo 'REPEAT....'
        else
            echo 'FINISH....'
            break
        fi
        COUNT=`expr $COUNT + 1`
    done
}


menu() {
    clear
    if [ -e $APP_HOME/export.sh ]; then
        . $APP_HOME/export.sh
    fi
    echo $LINE
    echo -e "스크립트 v$SCRIPT_VERSION - $SCRIPT_TYPE"
    echo $LINE
    echo -e "<설치>"
    echo "0. 설치 : 일반"
    echo "1. 설치 : 최소"
    echo $LINE
    echo -e "<실행>"
    echo "2. 시작 - Foreground (UI)"
    echo "3. 시작 - Foreground (celery)"
    echo "4. 중지"
    echo $LINE   
    echo -e "<권장 툴>" 
    echo "5. nginx 설치"
    echo "6. code-server 설치"
    echo "7. Filebrowser 설치"
    echo "8. rclone 설치 (이치로님 버전)"
    echo "9. ffmpeg 설치" 
    echo "a. 권장 툴 전체 설치"
    echo $LINE   
    echo -e "<기타>"
    echo "b. apt update"
    echo "c. vi 설치"
    echo "d. ssh 설치"
    echo "e. App 설치"
    echo "w. cat pre_start.sh"
    echo "x. cat export.sh"
    echo "y. ps -ef"
    echo "z. 스크립트 업데이트"
    echo $LINE
}

app_menu() {
    clear
    echo $LINE
    echo -e "스크립트 v$SCRIPT_VERSION - $SCRIPT_TYPE"
    echo $LINE
    echo -e "<App 설치>"
    echo "1. imueRoid님의 mycomix 설치"
    echo "2. 재키님의 웹툰뷰어 설치"
    echo "3. Kod Explorer 설치"
    echo "4. transmission 설치"
    echo "5. squid 설치 - proxy (기본포트:9994)"    
    echo $LINE
    read -n 1 -s -p "메뉴 선택 > " cmd
    case $cmd in
        1) install_mycomix;;
        2) install_webtoon_viewer;;
        3) install_kodexplorer;;
        4) install_transmission;;
        5) install_squid;;
    esac
    echo -e "\n"
}


while true; do
    if [ $# -eq 0 ]; then
        menu
        read -n 1 -s -p "메뉴 선택 > " cmd
    else
        cmd=$1
    fi

    case $cmd in
        0)  install;;
        2)  stop && foreground_start;;
        3)  $PS_COMMAND | grep main.celery | grep -v grep | awk '{print $1}' | xargs -r kill -9
            /usr/bin/python -m celery --app=main.celery --workdir=/root/flaskfarm worker --loglevel=INFO -c $CELERY_WORKER_COUNT --executable=/usr/bin/python --config_filepath=/data/config.yaml --running_type=native;;
        4)  stop;;
        5)  install_nginx;;
        6)  install_code_server;; 
        7)  install_filebrowser;;
        8)  install_rclone;;
        9)  install_ffmpeg;;
        a)  install_tool;;
        b)  $PACKAGE_CMD update;;
        c)  install_vim;;
        d)  install_ssh;;
        e)  app_menu;;
        w)  echo -e "\n\n$LINE" && cat "$APP_HOME/pre_start.sh" && echo -e "\n$LINE";;
        x)  echo -e "\n\n$LINE" && cat "$APP_HOME/export.sh" && echo -e "\n$LINE";;
        y)  echo "`ps -ef`";;
        z)  echo -e "\n\n업데이트를 시작합니다." && download_shell_script && echo -e "\n\n재실행하세요." && exit;;
        prepare) prepare;;
        install) install;;
        install_tool) install_tool;;
        start) start;;
        stop) stop;;
        restart) stop && start;;
        [\s\n]) ;;
        *)
            exit
    esac
    echo -e "\n"
    if [ $# -eq 0 ]; then
        read -n 1 -s -r -p "아무키나 누르세요.."
    else
        exit 0
    fi
done
exit
