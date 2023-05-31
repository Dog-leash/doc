#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'
BrowserUA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36"

# 定义要检查的网站名称和URL
website_names=("bilibili" "Netflix" "chatgpt")
website_urls=("www.bilibili.com" "www.netflix.com" "https://chat.openai.com")

# 获取网站数量
website_count=${#website_names[@]}

# 遍历每个网站
for (( i=0; i<$website_count; i++ ))
do
    # 输出正在检查的网站
    echo -n "正在检查 ${website_names[$i]}..."

    # 对于ChatGPT，我们需要检查是否被屏蔽
    if [[ "${website_names[$i]}" == "chatgpt" ]]
    then
        if [[ $(curl --max-time 10 -sS ${website_urls[$i]} -I | grep "text/plain") != "" ]]
        then
            echo -e "${website_names[$i]}: ${RED}IP is BLOCKED${PLAIN}"
        else
            countryCode="$(curl --max-time 10 -sS ${website_urls[$i]}/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')";
            if [ -n "$countryCode" ]; then
                echo -e "${website_names[$i]}: ${GREEN}Yes (Region: ${countryCode})${PLAIN}"
            else
                echo -e "${website_names[$i]}: ${RED}Failed${PLAIN}"
            fi
        fi
    else
        # 对于其他网站，我们只检查HTTP状态码
        response=$(curl --user-agent "${BrowserUA}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 ${website_urls[$i]} 2>&1)
        if [[ "$response" == "403" ]]
        then
            echo -e "${website_names[$i]}: ${RED}无法访问，IP被阻止${PLAIN}"
        elif [[ "$response" == "404" ]]
        then
            echo -e "${website_names[$i]}: ${RED}无法访问，404错误${PLAIN}"
        elif [[ "$response" == "200" ]]
        then
            echo -e "${website_names[$i]}: ${GREEN}可以访问${PLAIN}"
        else
            echo -e "${website_names[$i]}: ${YELLOW}网络连接失败${PLAIN}"
        fi
    fi
done
