#!/bin/bash
#
# Script to generate LVM test files

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1;

	which ${BINARY} > /dev/null 2>&1;
	if test $? -ne ${EXIT_SUCCESS};
	then
		echo "Missing binary: ${BINARY}";
		echo "";

		exit ${EXIT_FAILURE};
	fi
}

assert_availability_binary dd;
assert_availability_binary losetup;
assert_availability_binary lvcreate;
assert_availability_binary pvcreate;
assert_availability_binary vgchange;
assert_availability_binary vgcreate;

set -e;

SPECIMENS_PATH="specimens";

mkdir -p ${SPECIMENS_PATH};

IMAGE_SIZE=$(( 8 * 1024 * 1024 ));
SECTOR_SIZE=512;

# Create a physical volume.
IMAGE_NAME="${SPECIMENS_PATH}/lvm2_physical_only.raw"

dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

sudo losetup /dev/loop0 ${IMAGE_NAME};

sudo pvcreate -q /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo losetup -d /dev/loop0;

# Create a physical volume with a volume group.
IMAGE_NAME="${SPECIMENS_PATH}/lvm2_group_only.raw"

dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

sudo losetup /dev/loop0 ${IMAGE_NAME};

sudo pvcreate -q /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgcreate -q test_volume_group /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgchange -q --activate n test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo losetup -d /dev/loop0;

# Create a physical volume with a volume group and a single linear logical volume.
IMAGE_NAME="${SPECIMENS_PATH}/lvm2_single_linear.raw"

dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

sudo losetup /dev/loop0 ${IMAGE_NAME};

sudo pvcreate -q /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgcreate -q test_volume_group /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo lvcreate -q --name test_logical_volume --size 4m --type linear test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgchange -q --activate n test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo losetup -d /dev/loop0;

# Create a physical volume with a volume group and a single striped logical volume.
IMAGE_NAME="${SPECIMENS_PATH}/lvm2_single_striped.raw"

dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

sudo losetup /dev/loop0 ${IMAGE_NAME};

sudo pvcreate -q /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgcreate -q test_volume_group /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo lvcreate -q --name test_logical_volume --size 4m --type striped test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo vgchange -q --activate n test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

sudo losetup -d /dev/loop0;

# Create a physical volume with a volume group and a single raid1 (mirror) logical volume.
# IMAGE_NAME="${SPECIMENS_PATH}/lvm2_single_raid1.raw"

# dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

# sudo losetup /dev/loop0 ${IMAGE_NAME};

# sudo pvcreate -q /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

# sudo vgcreate -q test_volume_group /dev/loop0 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

# sudo lvcreate -q --name test_logical_volume --size 4m --type raid1 test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

# sudo vgchange -q --activate n test_volume_group 2>&1 | sed '/is using an old PV header, modify the VG to update/ d;/open failed: No medium found/ d';

# sudo losetup -d /dev/loop0;

exit ${EXIT_SUCCESS};

