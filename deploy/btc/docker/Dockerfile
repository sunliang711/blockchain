FROM ubuntu:20.04
RUN apt-get update && apt-get install -y curl
RUN curl -LO https://bitcoin.org/bin/bitcoin-core-0.21.0/bitcoin-0.21.0-x86_64-linux-gnu.tar.gz && tar -C /root -xf bitcoin-0.21.0-x86_64-linux-gnu.tar.gz  && ln -sf /root/bitcoin-0.21.0/bin/bitcoind /usr/local/bin/bitcoind
RUN chmod +x /usr/local/bin/bitcoind
RUN mkdir /root/datadir
COPY entrypoint.sh /root/entrypoint.sh

WORKDIR /root
EXPOSE 8338 8890
ENTRYPOINT ["/root/entrypoint.sh","run"]
