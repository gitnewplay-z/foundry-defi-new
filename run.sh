#!/bin/bash
echo "=== Foundry 闪贷套利 Docker 一键启动 ==="
echo "1. 本地测试（默认）"
echo "2. 部署到 Sepolia"
echo "3. 部署到主网"
echo "4. 执行套利"
read -p "选择 [1-4]: " choice

case $choice in
  1) docker run --rm -v $(pwd):/app -it gitnewplay/foundry-defi-new ;;
  2) read -p "输入 PRIVATE_KEY: " pk
     read -p "输入 SEPOLIA_RPC: " rpc
     docker run --rm -e PRIVATE_KEY=$pk -e RPC_URL=$rpc -v $(pwd):/app gitnewplay/foundry-defi-new \
       forge script script/DeployPro.s.sol --rpc-url $RPC_URL --broadcast --verify ;;
  3) read -p "输入 PRIVATE_KEY: " pk
     read -p "输入 MAINNET_RPC: " rpc
     docker run --rm -e PRIVATE_KEY=$pk -e RPC_URL=$rpc -v $(pwd):/app gitnewplay/foundry-defi-new \
       forge script script/DeployPro.s.sol --rpc-url $RPC_URL --broadcast ;;
  4) read -p "输入 PRIVATE_KEY: " pk
     read -p "输入 RPC_URL: " rpc
     read -p "输入 BOT_ADDRESS: " bot
     docker run --rm -e PRIVATE_KEY=$pk -e RPC_URL=$rpc -e BOT_ADDRESS=$bot -v $(pwd):/app gitnewplay/foundry-defi-new \
       forge script script/RunPro.s.sol --rpc-url $RPC_URL --broadcast ;;
  *) echo "无效选择" ;;
esac
