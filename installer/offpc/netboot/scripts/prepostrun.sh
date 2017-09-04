#!/bin/bash
PROG=$(basename ${0})
IMGTYPE=${1}
IPHEX=${2}
IPDEC=${3}
# to be replaced with:                                     # FIXME: when the real thing goes live
PARTIMAG="/home/partimag"
cd "${PARTIMAG}"
umask 0002
mkdir -p "${IPDEC}"                 # OK in both cases because it does no harm
# -------------------------------------------------- #
HWADDRfile="${IPDEC}/currentImgHWADDR.txt"
DATEfile="${IPDEC}/currentImgDATE.txt"
CLONE_CMT_PATH="${IPDEC}/currentCmt.txt"
LOCAL_LOG="${IPDEC}/clone_log"
# -------------------------------------------------- #
exec &> >(tee -a "$LOCAL_LOG")
echo "# -------------------------------------------------- #"
echo "# $(date)"
echo "# ${PROG}:${LINENO}: starting"
echo "# -------------------------------------------------- #"
echo "${PROG}:${LINENO}: PROG           : ${PROG}" 
echo "${PROG}:${LINENO}: IPHEX          : ${IPHEX}" 
echo "${PROG}:${LINENO}: IPDEC          : ${IPDEC}" 
echo "${PROG}:${LINENO}: CLONE_CMT_PATH : ${CLONE_CMT_PATH}" 
echo "${PROG}:${LINENO}: PARTIMAG       : ${PARTIMAG}" 
echo "${PROG}:${LINENO}: HWADDRfile     : ${HWADDRfile}"
echo "${PROG}:${LINENO}: DATEfile       : ${DATEfile}" 
echo "${PROG}:${LINENO}: LOCAL_LOG      : ${LOCAL_LOG}" 
# -------------------------------------------------- #
case "${PROG}" in
# -------------------------------------------------- #
  "prerun" )
    rm "${HWADDRfile}"
    rm "${DATEfile}"
    HWADDR=$(ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | tr -d ":")
    sleep 5
    echo "${HWADDR}" > "${HWADDRfile}"
    echo $(date +%F_%T_%s) > "${DATEfile}"
    echo "${PROG}:${LINENO}:DATEfile   content:$(<${DATEfile})"
    echo "${PROG}:${LINENO}:HWADDRfile content:$(<${HWADDRfile})"
    echo "# -------------------------------------------------- #"
    echo "# $(date)"
    echo "# ${PROG}:${LINENO}: ending"
    echo "# -------------------------------------------------- #"
    sleep 30
    exit
    ;;
# -------------------------------------------------- #
"postrun" ) 
    HWADDR=$(<${HWADDRfile})
    STARTDATE=$(<${DATEfile})
    STARTSEC=$(echo ${STARTDATE##[^_]*_})
    CLONEDIR=$(basename $(ls -td "${HWADDR}"* | head -1))
    #MACHINENAME=$(cat ${CLONE_CMT_PATH} | head -1)
    MACHINENAME=$(grep Produ "${CLONEDIR}/Info-dmi.txt" | head -1 | tr -d " " )
    MACHINENAME=$(echo ${MACHINENAME##[^:]*:})
    NEWDIRNAME="${MACHINENAME}_${STARTSEC}_${IPDEC}"
    echo "${PROG}:${LINENO}: MACHINENAME: ${MACHINENAME}"
    echo "${PROG}:${LINENO}: HWADDR     : ${HWADDR}"
    echo "${PROG}:${LINENO}: STARTSEC   : ${STARTSEC}"
    echo "${PROG}:${LINENO}: CLONEDIR   : ${CLONEDIR}"
    echo "${PROG}:${LINENO}: NEWDIRNAME : ${NEWDIRNAME}"
    mv "${CLONEDIR}" "${NEWDIRNAME}"
    mv "${CLONE_CMT_PATH}" "${NEWDIRNAME}.txt" 
    sudo ssh installer@130.241.35.208 /home/installer/offpc/netboot/makedone.sh ${IPHEX} ${IPDEC}
    echo "# -------------------------------------------------- #"
    echo "# $(date)"
    echo "# ${PROG}:${LINENO}: ending"
    echo "# -------------------------------------------------- #"
    sleep 30
    sudo reboot
    exit
    ;;
esac 
# -------------------------------------------------- #
