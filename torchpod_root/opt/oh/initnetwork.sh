#!/usr/bin/env bash

TAP_NAME_PREFIX="ohostap"
INSTANCE_IDX="0"
INSTANCE_TAP_NAME="${TAP_NAME_PREFIX}${INSTANCE_IDX}"
BRIDGE_NAME="ohosbr0"
BRIDGE_IPADDR="192.168.111.1"
BRIDGE_PREFIX=$(echo $BRIDGE_IPADDR | cut -d '.' -f 1-3)

DNSMASQ_CONF="
interface=${BRIDGE_NAME}
# DHCP range (for VMs connected to bridge)
dhcp-range=${BRIDGE_PREFIX}.10,${BRIDGE_PREFIX}.100,24h
# Gateway for the VMs (use the bridge IP address)
dhcp-option=3,$BRIDGE_IPADDR
# DNS server for the VMs (use the bridge IP address)
dhcp-option=6,$BRIDGE_IPADDR
"
echo "NOTICE: must run with sudo."
echo ""
BRIDGE_REC=$(brctl show | grep $BRIDGE_NAME || true)

if [ -n "$BRIDGE_REC" ]; then
    echo "Try to remove previous bridge..."
    ip link set $BRIDGE_NAME down
    brctl delbr $BRIDGE_NAME
    echo "Done."
fi

# Build network bridge
# ip link add name ohosbr0 type bridge
if ! brctl addbr $BRIDGE_NAME; then
    echo "Failed to create network bridge $BRIDGE_NAME" && exit 1
fi

if ! ip addr add $BRIDGE_IPADDR/24 dev $BRIDGE_NAME; then
    echo "Failed to assign IPv4 address ($BRIDGE_IPADDR) to bridge $BRIDGE_NAME" && exit 1
fi

if ! ip link set $BRIDGE_NAME up; then
    echo "Failed to activate bridge $BRIDGE_NAME" && exit 1
fi

killall dnsmasq 2>/dev/null
file="/etc/dnsmasq.conf"
touch $file && chmod a+w $file && echo "$DNSMASQ_CONF" > $file
if ! /usr/sbin/dnsmasq; then
    echo "Failed to start dnsmasq. Reason: $?, may be the dnsmasq is already launched by previous session, try to kill it first." && exit 1
fi


# Reset tap device with a same name
TAP_REC=$(ip tuntap show | grep ${INSTANCE_TAP_NAME} || true)
if [ -n "$TAP_REC" ]; then
    echo "Try to remove tap previous device..."
    ip link set ${INSTANCE_TAP_NAME} down &> /dev/null
    if ! ip tuntap del dev ${INSTANCE_TAP_NAME} mode tap; then
        echo "Failed to del tap device, may be the qemu is already running ?" && exit 1
    fi
    echo "Done."
fi

# Create a tap device for current instance
if ! ip tuntap add dev ${INSTANCE_TAP_NAME} mode tap; then
    echo "Failed to create tap device for instance $INSTANCE_IDX, may be the qemu is already running ?" && exit 1
fi

if ! ip link set ${INSTANCE_TAP_NAME} up; then
    ip tuntap del dev ${INSTANCE_TAP_NAME} mode tap &> /dev/null || true
    echo "Failed to activate tap device ${INSTANCE_TAP_NAME}" && exit 1
fi

if ! ip link set ${INSTANCE_TAP_NAME} master ${BRIDGE_NAME}; then
    ip link set ${INSTANCE_TAP_NAME} down &> /dev/null || true
    ip tuntap del dev ${INSTANCE_TAP_NAME} mode tap &> /dev/null || true
    echo "Failed to associate tap ${INSTANCE_TAP_NAME} with ${BRIDGE_NAME}" && exit 1
fi

export NET_OPTS="-netdev tap,id=net${INSTANCE_IDX},ifname=${INSTANCE_TAP_NAME},script=no,downscript=no -device virtio-net-pci,netdev=net${INSTANCE_IDX},mac=70:30:10:02:18:06"
echo ""
echo "Now, run below 2 commands in your current konsole to set the environment variables: "
echo ""
echo "-----------------------------------------------------"
echo "export NET_OPTS=\"${NET_OPTS}\" "
echo "export OHOS_IMG_DIR=<your_ohos_img_dir>"
echo "-----------------------------------------------------"
