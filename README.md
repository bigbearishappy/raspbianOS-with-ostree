# raspbianOS-with-ostree

In this repo. We can turn a [raspbian OS](https://www.raspberrypi.com/software/) into a rootfs that is managed by [ostree](https://github.com/ostreedev/ostree)

---

# Build target image
## step 1: build the docker image
```
git clone https://github.com/bigbearishappy/raspbianOS-with-ostree.git
cd raspbianOS-with-ostree
docker build . --tag bbear/build-raspbian-ostree-img
docker push bbear/build-raspbian-ostree-img
```
## step 2: build the raspbian OS with ostree
```
#download the firmware we need to convert
curl -L -O https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-09-07/2022-09-06-raspios-bullseye-arm64.img.xz
unxz 2022-09-06-raspios-bullseye-arm64.img.xz

curl -L -O https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64.img.xz
unxz 2022-09-22-raspios-bullseye-arm64.img.xz

#pull the docker image
docker pull bbear/build-raspbian-ostree-img

#convert official raspbian OS with ostree and output the target img
docker run -ti --rm --privileged --env OSTREE_VERSION=0.0.0 --env OSTREE_BRANCH="raspbian/testing/2022-09-06/bullseye" --env OSTREE_SUBJECT="2022-09-06-Raspbian-OS" -v $PWD:/host bbear/build-raspbian-ostree-img 2022-09-06-raspios-bullseye-arm64.img

docker run -ti --rm --privileged --env OSTREE_VERSION=0.0.0 --env OSTREE_BRANCH="raspbian/testing/2022-09-06/bullseye" --env OSTREE_SUBJECT="2022-09-22-Raspbian-OS" -v $PWD:/host bbear/build-raspbian-ostree-img 2022-09-22-raspios-bullseye-arm64.img
```

---

# Baseic usage of raspbian OS with ostree

we use nginx to deploy the static web server for ostree upgrade.
```
# 1 install nginx
apt install nginx
# 2 change the value of root to the directory we need to public to client(~/raspbianOS-with-ostree/repo)
vim  /etc/nginx/sites-available/default
# 3 start the service
service nginx restart
```
client operation:
```
export REMOTE=seeed
export REMOTE_URL=http://192.168.113.27:80
ostree remote add --no-gpg-verify --no-sign-verify $REMOTE $REMOTE_URL
ostree pull $REMOTE raspbian/testing/2022-09-06/bullseye
ostree admin deploy raspbian/testing/2021-09-06/bullseye
reboot

```

---

# Advanced usage of raspbian OS with ostree
## upgrade the raspbian OS with static delta
### 1 generate the static delta
```
# get commit ID
ostree log raspbian/testing/2022-09-06/bullseye
ostree static-delta generate --from=commit1 --to=commit2 --min-fallback-size=0 --inline --filename=commit1-to-commit2.delta
```
### 2 upgrade with static delta
```
ostree static-delta apply-offline commit1-to-commit2.delta
ostree admin deploy commit2
reboot
```
## verification for the commit or static delta
```
//TODO
```

---

Thank a lot for [jallwine](https://github.com/jallwine) and [starnight](https://github.com/starnight)

This repo is based on [bbb-ostree-helper-scripts](https://github.com/PocketNC/bbb-ostree-helper-scripts) which is maintained by jallwine.
He helps me a lot when I am in trouble with usage of bbb-ostree-helper-scripts. :)

The basic idea of adapting raspbian os with ostree is from starnight's [discussion](https://github.com/ostreedev/ostree/issues/2223#issuecomment-718417071) in the issue of ostree.
