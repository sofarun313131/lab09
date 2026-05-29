# Изменили образ на 20.04, чтобы получить современный CMake
FROM ubuntu:20.04

# Отключаем интерактивные диалоги при установке пакетов (чтобы tzdata не зависала)
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yy gcc g++ cmake

COPY . /print/
WORKDIR /print

# Оставляем флаг компилятора для Hunter
RUN cmake -H. -B_build -DCMAKE_CXX_FLAGS="-Wno-error=maybe-uninitialized" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install
RUN cmake --build _build
RUN cmake --build _build --target install

ENV LOG_PATH /home/logs/log.txt
VOLUME /home/logs

WORKDIR _install/bin
ENTRYPOINT ["./demo"]
