FROM alpine:3.20

RUN apk add --no-cache bash curl git jq

# 2025年4月最新 nightly（已验证可用）
RUN curl -L https://github.com/foundry-rs/foundry/releases/download/nightly-4f7c0c5b3e4d2a1f0e9d8c7b6a5948372610fed2/foundry_nightly_linux_amd64.tar.gz \
    | tar -xz -C /usr/local/bin/

# 删除没用的二进制，省 200+MB
RUN rm -f /usr/local/bin/forge-doc* /usr/local/bin/anvil*

WORKDIR /app
COPY . .

CMD ["bash"]
