#!/bin/bash

#Copyright 2024 Institute of Software, Chinese Academy of Sciences.
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
if [ ! -n "$NET_OPTS" ]; then
    echo "Environment variable NET_OPTS not found. run /opt/oh/initnetwork.sh first."
    exit 1
fi

if [ ! -n "$OHOS_IMG_DIR" ]; then
    echo "Environment variable OHOS_IMG_DIR not found. set OHOS_IMG_DIR to the path of ohos img files."
    exit 1
fi

sudo qemu-system-x86_64 \
-machine pc \
-smp 6 \
-m 4096M \
-cpu host \
-boot c \
-enable-kvm \
-nographic \
-vga none \
-device virtio-vga-gl,xres=360,yres=720 \
-display sdl,gl=on \
-rtc base=utc,clock=host \
-device es1370 \
-initrd ${OHOS_IMG_DIR}/ramdisk.img \
-kernel ${OHOS_IMG_DIR}/bzImage \
-usb \
-device usb-ehci,id=ehci \
${NET_OPTS} \
-drive file=${OHOS_IMG_DIR}/updater.img,if=virtio,media=disk,format=raw,index=0 \
-drive file=${OHOS_IMG_DIR}/system.img,if=virtio,media=disk,format=raw,index=1 \
-drive file=${OHOS_IMG_DIR}/vendor.img,if=virtio,media=disk,format=raw,index=2 \
-drive file=${OHOS_IMG_DIR}/sys_prod.img,if=virtio,media=disk,format=raw,index=3 \
-drive file=${OHOS_IMG_DIR}/chip_prod.img,if=virtio,media=disk,format=raw,index=4 \
-drive file=${OHOS_IMG_DIR}/userdata.img,if=virtio,media=disk,format=raw,index=5 \
-append " \
ip=dhcp \
loglevel=7 \
console=ttyS0,115200 \
init=init root=/dev/ram0 rw \
ohos.boot.hardware=virt \
default_boot_device=10007000.virtio_mmio \
ohos.boot.sn=01234567890 \
ohos.required_mount.system=/dev/block/vdb@/usr@ext4@ro,barrier=1@wait,required \
ohos.required_mount.vendor=/dev/block/vdc@/vendor@ext4@ro,barrier=1@wait,required"
