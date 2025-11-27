# ========= 极致干净的 Foundry + 闪贷套利 Docker 镜像 =========
FROM ghcr.io/foundry-rs/foundry:latest

# 作者
LABEL maintainer="gitnewplay-z"

# 创建工作目录
WORKDIR /app

# 复制当前项目全部内容（干净版）
COPY . .

# 安装依赖 + 预热缓存
RUN forge install --no-commit && \
    forge build --sizes

# 默认启动：本地测试全通过
CMD ["forge", "test", "-vvv"]

# ========= 支持的一键命令 =========
# 本地测试（默认）
# docker run --rm -it yourname/foundry-defi-new

# 部署到 Sepolia
# docker run --rm -e PRIVATE_KEY=0x... -e RPC_URL=https://eth-sepolia... yourname/foundry-defi-new forge script script/DeployPro.s.sol --rpc-url $RPC_URL --broadcast --verify

# 主网部署（直接改 RPC）
# docker run --rm -e PRIVATE_KEY=0x... -e RPC_URL=https://eth-mainnet... yourname/foundry-defi-new forge script script/DeployPro.s.sol --rpc-url $RPC_URL --broadcast

# 执行套利
# docker run --rm -e PRIVATE_KEY=0x... -e BOT_ADDRESS=0x... yourname/foundry-defi-new forge script script/RunPro.s.sol --rpc-url $RPC_URL --broadcast
