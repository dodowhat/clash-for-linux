# clash-for-linux

 Clash command line management tools on Linux.

Principle: [Clash Service Management on Linux](https://dodowhat.github.io/blog/posts/clash-service-management-on-linux/)

## Manual

Scripts description:

    delay.sh          test proxies delay

    reset.sh          init / reset runtime configs

    start.sh          start / restart clash service

    stop.sh           stop clash service

    subscribe.sh      pull / update config subscription

    switch_config.sh  switch config file

    switch_proxy.sh   switch proxy

    update_clash.sh   update clash core

    update_geoip.sh   update Country.mmdb
    
Usage:

Most of them don't need arguments, just run it.

To update config subscription, you need to maintain url list in `runtime/subscription.json`

    {
        "NAME1": "URL1",
        "NAME2": "URL2"
    }
    
and then run

    ./subscribe.sh NAME1
    
To switch config file, run

    ./switch_config.sh [CONFIG_FILE_PATH]
    
for example

    ./switch_config.sh runtime/config.yml