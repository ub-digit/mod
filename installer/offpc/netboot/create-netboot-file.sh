#!/bin/bash
# -------------------------------------------------- #
# Generate PXE-boot file from template               #
# All info supplied from boot-settings.sh            #
#   required:                                        #
#     ACTION       # clone/install                   #
#     IPDEC        # 130.241.35.32 (icke-tom lista)  #
#     IMGTYPE      # elevpc/offpc                    #
#     IMG_NAME     # "string"      (when installing) #
#     CLONE_CMT    # "string"         (when cloning) #
#   optional:                                        #
#     OUTPUT_PATH                    (for debugging) #
# -------------------------------------------------- #
#  - output to file named from IPHEX                 #
#  - in DEFAULT_OUTPUT_DIR                           #
#  - or to OUTPUT_PATH (for debug)                   #
#  - IPDEC som lista enbart relevant vid install     #
# -------------------------------------------------- #
SERVER="130.241.35.208"
SERVER_USER="installer"
SERVER_HOME="/home/${SERVER_USER}"
SERVER_NETBOOT_PATH="${SERVER_HOME}/offpc/netboot"
DEFAULT_OUTPUT_DIR="${SERVER_NETBOOT_PATH}/pxe/pxelinux.cfg"  # where the bootfile will be generated
BOOT_SETTINGS_OLD_DIR='saved-bootsettings-files'
# -------------------------------------------------- #
# Place to find done-distributing messages (to be    #
# erased)                                            #
# DONE_DIST_PATH="${SERVER_NETBOOT_PATH}/done/dist"  # FIXME: uncomment
# -------------------------------------------------- #
BOOT_SETTINGS_FILE="boot-settings.sh"
if [[ ! -s "${BOOT_SETTINGS_FILE}" ]]
then
  echo "exiting: no boot settings file:${BOOT_SETTINGS_FILE}"
  exit
fi
BOOT_SETTINGS=$(<${BOOT_SETTINGS_FILE})
. ${BOOT_SETTINGS_FILE}
# -------------------------------------------------- #

case "${ACTION}" in
  "clone" )
    if [[ -z  "${IPDEC}"  || -z  "${IMGTYPE}" || -z  "${CLONE_CMT}"   ]]
    then
      echo "Usage: ${BOOT_SETTINGS_FILE} must contain ACTION IPDEC IMGTYPE and CLONE_CMT"
      exit
    fi
    ;;
  "install" )
    if [[ -z  "${IPDEC}"  || -z  "${IMGTYPE}" || -z  "${IMG_NAME}"   ]]
    then
      echo "Usage: ${BOOT_SETTINGS_FILE} must contain ACTION IPDEC IMGTYPE and IMG_NAME"
      exit
    fi
    ;;
  "" )
    echo "Usage: ${BOOT_SETTINGS_FILE} must contain ACTION"
    exit
    ;;
  * )
    echo "Usage: wrong ACTION (${ACTION}) value in ${BOOT_SETTINGS_FILE}"
    exit
    ;;
esac 


if [[ -z  "${OUTPUT_PATH}" ]]
then
  OUTPUT_PATH="${DEFAULT_OUTPUT_DIR}"
fi
mkdir -p "${OUTPUT_PATH}"
# -------------------------------------------------- #
CLONE_PATH="/mnt/data/MOD/IMAGES_test/${IMGTYPE}"
# to be replaced with:                                     # FIXME: when the real thing goes live
# -------------------------------------------------- #
SERVER_PXE_TEMPLATE="${SERVER_NETBOOT_PATH}/tmpl/${ACTION}.tmpl"
SCRIPT_PATH="${SERVER_NETBOOT_PATH}/scripts/*run* ." 

# -------------------------------------------------- #
for IPNR in $(echo "${IPDEC}")
do 
  # -------------------------------------------------- #
  IPHEX=$(printf "%02X%02X%02X%02X" $(echo ${IPNR} | cut -d. -f1) $(echo ${IPNR} | cut -d. -f2) $(echo ${IPNR} | cut -d. -f3) $(echo ${IPNR} | cut -d. -f4))
  OUTPUT="${OUTPUT_PATH}/${IPHEX}"
  # -------------------------------------------------- #
  case "${ACTION}" in
    "clone" )
      COPY_PREPOST_SCRIPTS="scp ${SERVER_USER}\@${SERVER}:${SCRIPT_PATH} ."
      PRERUN_CMD="prerun   ${IMGTYPE} ${IPHEX} ${IPNR}" 
      POSTRUN_CMD="postrun ${IMGTYPE} ${IPHEX} ${IPNR}" 
      CLONE_CMT_DIR="${CLONE_PATH}/${IPNR}"
      umask 0002
      mkdir -p "${CLONE_CMT_DIR}"
      CLONE_CMT_PATH="${CLONE_CMT_DIR}/currentCmt.txt"
      echo "${CLONE_CMT}"  >  "${CLONE_CMT_PATH}"
      ;;

    "install" )
      ;;
  esac 
  # -------------------------------------------------- #
  echo " ACTION             : ${ACTION}" 
  echo " IPDEC              : ${IPDEC}"
  echo " IPNR               : ${IPNR}"
  echo " IMGTYPE            : ${IMGTYPE}"
  echo " IMG_NAME           : ${IMG_NAME}"
  echo " BOOT_SETTINGS_FILE : ${BOOT_SETTINGS_FILE}"
  echo " CLONE_CMT          : ${CLONE_CMT}"
  echo " CLONE_CMT_DIR      : ${CLONE_CMT_DIR}"
  echo " CLONE_CMT_PATH     : ${CLONE_CMT_PATH}"
  echo " OUTPUT_PATH        : ${OUTPUT_PATH}"
  echo " SERVER_PXE_TEMPLATE: ${SERVER_PXE_TEMPLATE}"
  echo " OUTPUT             : ${OUTPUT}"
  echo " IPHEX              : ${IPHEX}"
  # -------------------------------------------------- #
  HOST_TEMPLATE_SETUP="sshfs ${SERVER_USER}\@${SERVER}:${CLONE_PATH} /home/partimag"
  DONE_CMD="sudo ssh ${SERVER_USER}\@${SERVER} ${SERVER_NETBOOT_PATH}/makedone.sh ${IPHEX} ${IPNR}"
  # -------------------------------------------------- #
  echo " HOST_TEMPLATE_SETUP: ${HOST_TEMPLATE_SETUP}"
  echo "COPY_PREPOST_SCRIPTS: ${COPY_PREPOST_SCRIPTS}"
  echo "            DONE_CMD: ${DONE_CMD}"
  echo "          PRERUN_CMD: ${PRERUN_CMD}"
  echo "         POSTRUN_CMD: ${POSTRUN_CMD}"
  # -------------------------------------------------- #
  cat "$SERVER_PXE_TEMPLATE" | perl -pe 's,<!--HOST-TEMPLATE-SETUP-->,'"${HOST_TEMPLATE_SETUP}"',' | perl -pe 's,<!--DONE-CMD-->,'"${DONE_CMD}"',' | perl -pe 's,<!--SERVER-->,'"${SERVER}"',' | perl -pe 's,<!--PRERUN-CMD-->,'"${PRERUN_CMD}"',' | perl -pe 's,<!--POSTRUN-CMD-->,'"${POSTRUN_CMD}"',' | perl -pe 's,<!--COPY-PREPOST-SCRIPTS-->,'"${COPY_PREPOST_SCRIPTS}"',' | perl -pe 's,<!--IMG-PATH-->,'"${IMG_NAME}"',' > "${OUTPUT}"
done
mkdir -p "${BOOT_SETTINGS_OLD_DIR}"
mv "${BOOT_SETTINGS_FILE}" "${BOOT_SETTINGS_OLD_DIR}"/"$(date +%F_%T_%s).sh"
# -------------------------------------------------- #
