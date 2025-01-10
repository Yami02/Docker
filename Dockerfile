# Use uma imagem base do Ubuntu 22.04
FROM ubuntu:22.04

# Atualiza o índice de pacotes e instala dependências necessárias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    cron \
    libasound2 \
    libnss3 \
    libgconf-2-4 \
    fonts-liberation \
    libappindicator3-1 \
    libgdk-pixbuf2.0-0 \
    xdg-utils \
    ca-certificates \
    sudo \
    unzip \
    jq \
    python3 \
    apt-utils \
    python3-pip && \
    apt-get clean

# Instala o Firefox diretamente
RUN wget -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt/ && \
    ln -s /opt/firefox/firefox /usr/bin/firefox && \
    rm /tmp/firefox.tar.bz2

# Instala o GeckoDriver
RUN GECKODRIVER_VERSION=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r .tag_name) && \
    wget https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz -O /tmp/geckodriver.tar.gz && \
    tar -xvzf /tmp/geckodriver.tar.gz -C /usr/local/bin/ && \
    rm /tmp/geckodriver.tar.gz

# Instala o Selenium e o WebDriver Manager
RUN pip3 install selenium webdriver-manager beautifulsoup4 yacron

# Define o diretório de trabalho
WORKDIR /home

# Cria um diretório para os scripts Python
RUN mkdir /home/scripts

# Copia o script para dentro do contêiner
COPY ./pwned.py /home/scripts/
COPY ./cron-config /etc/cron.d/pwned-cron

# Expondo a porta (se necessário, mas para o Selenium não é necessário)
EXPOSE 4444

# Definir permissões para o arquivo cron
RUN chmod 0644 /etc/cron.d/pwned-cron

# Criar diretório para logs (opcional)
RUN mkdir -p /var/log/cron

# Iniciar o cron como serviço e manter o contêiner rodando
CMD ["cron", "-f"]
