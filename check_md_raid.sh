#!/bin/bash

# Get count of raid arrays
RAID_DEVICES=$(grep ^md -c /proc/mdstat)

# Get count of degraded arrays
RAID_STATUS=$(grep "\[.*_.*\]" /proc/mdstat -c)

# Is an array currently recovering, get percentage of recovery
RAID_RECOVER=$(grep recovery /proc/mdstat | awk '{print $4}')

# Is an array currently resyncing, get percentage of resync

RAID_RESYNC=$(grep resync /proc/mdstat | awk '{print $4}')

RAID_ARRAY=$(awk '/md[1-9]/{for (i=1;i<=NF;++i) if ($i~/md[1-2]/)print $i}' /proc/mdstat |xargs)
RAID_DISKS=$(awk '/sd[a-z]/{for (i=1;i<=NF;++i) if ($i~/sd[a-z]/)print $i}' /proc/mdstat |xargs)
DISKS_STATUS=$(grep algorithm  /proc/mdstat|awk '{print $12}')

# Check raid status
# RAID recovers --> Warning
if [[ "$RAID_RECOVER" ]]; then
        STATUS="WARNING - Checked $RAID_DEVICES arrays $RAID_ARRAY, recovering : $RAID_RECOVER"
        EXIT=1
# RAID resync --> Warning
elif [[ "$RAID_RESYNC" ]]; then
        STATUS="WARNING - Checked $RAID_DEVICES arrays $RAID_ARRAY., resyncing : $RAID_RESYNC"
        EXIT=1
# RAID ok
elif [[ "$RAID_STATUS"  == "0" ]]; then
        STATUS="OK - Checked $RAID_DEVICES arrays $RAID_ARRAY."
        EXIT=0
# All else critical, better save than sorry
else
        STATUS="CRITICAL - Checked $RAID_DEVICES arrays $RAID_ARRAY, $RAID_STATUS have FAILED"
        EXIT=2
fi

# Status and quit
echo -e "$STATUS \n Physical Disks: $RAID_DISKS Disks Status: $DISKS_STATUS "
exit $EXIT
