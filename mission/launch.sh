#!/bin/bash 
#-------------------------------------------------------
#  Part 1: Check for and handle command-line arguments
#-------------------------------------------------------
TIME_WARP=1
JUST_MAKE="no"
HAZARD_FILE="hazards.txt"
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	printf "%s [SWITCHES] [time_warp]   \n" $0
	printf "  --just_make, -j    \n" 
	printf "  --help, -h         \n" 
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then 
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_build" -o "${ARGI}" = "-j" ] ; then
	JUST_MAKE="yes"
    else 
	printf "Bad Argument: %s \n" $ARGI
	exit 0
    fi
done

#-------------------------------------------------------
#  Part 2: Create the .moos and .bhv files. 
#-------------------------------------------------------
VNAME1="1"       # The first   vehicle community
VNAME2="2"       # The second  vehicle community
VNAME3="3"       # The second  vehicle community
START_POS1="80,1"  
START_POS2="165,2"  
START_POS3="255,1"  

# What is nsplug? Type "nsplug --help" or "nsplug --manual"
nsplug meta_shoreside.moos targ_shoreside.moos -f WARP=$TIME_WARP \
   VNAME="shoreside" HAZARD_FILE=$HAZARD_FILE   VPORT=9000 MODEM_ID=0 \
   ENABLE_DC="//"    N=3

nsplug meta_vehicle.moos targ_$VNAME1.moos -f WARP=$TIME_WARP  VTYPE=UUV \
   VNAME=$VNAME1      START_POS=$START_POS1                              \
   VPORT="9001"       SHARE_LISTEN="9301"   MODEM_ID=1                   \
   HELM_ENABLED="//"    ENABLE_TPC=""       HELM_FILE="1.bhv" 

nsplug meta_vehicle.moos targ_$VNAME2.moos -f WARP=$TIME_WARP  VTYPE=UUV \
   VNAME=$VNAME2      START_POS=$START_POS2                              \
   VPORT="9002"       SHARE_LISTEN="9302"   MODEM_ID=2                   \
   HELM_ENABLED="//"    ENABLE_TPC=""         HELM_FILE="targ_bhv_$VNAME2.bhv"

nsplug meta_vehicle.moos targ_$VNAME3.moos -f WARP=$TIME_WARP  VTYPE=UUV \
   VNAME=$VNAME3      START_POS=$START_POS3                              \
   VPORT="9003"       SHARE_LISTEN="9303"   MODEM_ID=3                   \
   HELM_ENABLED="//"    ENABLE_TPC=""         HELM_FILE="targ_bhv_$VNAME3.bhv"

nsplug meta_behavior.bhv targ_bhv_$VNAME1.bhv -f START_POS=$START_POS1\
    VNAME=$VNAME1

nsplug meta_behavior.bhv targ_bhv_$VNAME2.bhv -f START_POS=$START_POS2\
    VNAME=$VNAME2

nsplug meta_behavior.bhv targ_bhv_$VNAME3.bhv -f START_POS=$START_POS3\
    VNAME=$VNAME3


if [ ${JUST_MAKE} = "yes" ] ; then
    exit 0
fi

#-------------------------------------------------------
#  Part 3: Launch the processes
#-------------------------------------------------------
printf "Launching $VNAME1 MOOS Community (WARP=%s) \n" $TIME_WARP
pAntler targ_$VNAME1.moos >& /dev/null &
sleep .25
printf "Launching $VNAME2 MOOS Community (WARP=%s) \n" $TIME_WARP
pAntler targ_$VNAME2.moos >& /dev/null &
sleep .25
printf "Launching $VNAME3 MOOS Community (WARP=%s) \n" $TIME_WARP
pAntler targ_$VNAME3.moos >& /dev/null &
sleep .25
printf "Launching $SNAME MOOS Community (WARP=%s) \n"  $TIME_WARP
pAntler targ_shoreside.moos >& /dev/null &
printf "Done \n"

uMAC targ_shoreside.moos

printf "Killing all processes ... \n"
kill %1 %2 %3 %4
printf "Done killing processes.   \n"
