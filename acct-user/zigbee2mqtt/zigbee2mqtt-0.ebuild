# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="A user for zigbee2mqtt"
ACCT_USER_ID=313
ACCT_USER_HOME=/opt/zigbee2mqtt
ACCT_USER_GROUPS=( zigbee2mqtt usb dialout )

acct-user_add_deps
