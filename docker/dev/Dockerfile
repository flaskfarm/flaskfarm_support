FROM ubuntu:22.04
LABEL maintainer="flaskfarm <flaskfarm@gmail.com>"


ARG DEBIAN_FRONTEND=noninteractive
ENV TZ                  Asia/Seoul
ENV RUNNING_TYPE   docker
COPY ./flaskfarm.sh /root
RUN chmod +x /root/flaskfarm.sh \
    && bash /root/flaskfarm.sh prepare \
    && bash /root/flaskfarm.sh install
    #&& bash /root/sjva3.sh install_mini
RUN bash /root/flaskfarm.sh install_tool
RUN rm /root/flaskfarm.sh
COPY .vscode /root/flaskfarm/.vscode
    
ENV LANG                ko_KR.UTF-8
ENV LANGUAGE            ko_KR.UTF-8
ENV LC_ALL              ko_KR.UTF-8
WORKDIR /root/flaskfarm
EXPOSE 9999
ENTRYPOINT [ "/root/flaskfarm/run.sh" ]