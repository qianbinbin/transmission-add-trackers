[English](#English)

Transmission 辅助脚本，自动添加 Tracker 服务器。

## 使用

```sh
$ curl https://raw.githubusercontent.com/qianbinbin/transmission-add-trackers/master/trans-add-trackers.sh -o /path/to/trans-add-trackers.sh
$ chmod +x /path/to/trans-add-trackers.sh
```

编辑脚本，按需修改以下参数：

```sh
# 主机:端口
# 通常无需修改
HOST="localhost:9091"

# 用户名:密码
AUTH="username:password"
```

然后运行即可。

### Systemd

```sh
$ curl https://raw.githubusercontent.com/qianbinbin/transmission-add-trackers/master/transmission-add-trackers.service -o /etc/systemd/system/transmission-add-trackers.service
```

修改 `/etc/systemd/system/transmission-add-trackers.service` 中以下参数：

```sh
# 用户
User=debian-transmission
# 脚本路径
ExecStart=/path/to/trans-add-trackers.sh
```

执行：

```sh
$ systemctl daemon-reload
$ systemctl enable transmission-add-trackers.service # 开机启动
$ systemctl start transmission-add-trackers.service  # 立即启动
$ systemctl status transmission-add-trackers.service # 查看状态
```

## 感谢

- https://github.com/XIU2/TrackersListCollection

# English

A shell script for Transmission to add trackers automatically.

## Usage

```sh
$ curl https://raw.githubusercontent.com/qianbinbin/transmission-add-trackers/master/trans-add-trackers.sh -o /path/to/trans-add-trackers.sh
$ chmod +x /path/to/trans-add-trackers.sh
```

Change these values in the script:

```sh
# host:port
# Usually no need to change
HOST="localhost:9091"

AUTH="username:password"
```

Then run the script.

### Systemd

```sh
$ curl https://raw.githubusercontent.com/qianbinbin/transmission-add-trackers/master/transmission-add-trackers.service -o /etc/systemd/system/transmission-add-trackers.service
```

Edit `/etc/systemd/system/transmission-add-trackers.service`:

```sh
User=debian-transmission
ExecStart=/path/to/trans-add-trackers.sh
```

Then:

```sh
$ systemctl daemon-reload
$ systemctl enable transmission-add-trackers.service
$ systemctl start transmission-add-trackers.service
$ systemctl status transmission-add-trackers.service
```

## Credits

- https://github.com/XIU2/TrackersListCollection
