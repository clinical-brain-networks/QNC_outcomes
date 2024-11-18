# /bin/bash
# uses dcm2bids to convert raw dicom into bids
# may need to edit the config file with new data
# requires dcm2bids, dcm2niix and pydeface
# inputs:

# set path for bids directory
bids_dir=/home/lukeh/hpcworking/lukeH/projects/QNC_outcomes/data/bids

# dcm2bids config file
BIDS_CONFIG=dcm2bids_configv3.json

## PRE scan
# Note the rawIDs from PRE and POST may not be identical
# rawIDs=(
#     "QNCTMS_D092MB4" "QNCTMS_D093MB4" "QNCTMS_D094MB4" "QNCTMS_D097MB4" "QNCTMS_D098MB4" 
#     "QNCTMS_D099MB4" "QNCTMS_D103MB4" "QNCTMS_D105MB4" "QNCTMS_D106MB4" "QNCTMS_D108MB4"
#     "QNCTMS_D110MB4" "QNCTMS_D111MB4" "QNCTMS_D112MB4" "QNCTMS_D115MB4" "QNCTMS_D118MB4"
#     "QNCTMS_D122MB4" "QNCTMS_D123MB4" "QNCTMS_D127MB4" "QNCTMS_D130MB4" "QNCTMS_D131MB4"
#     "sub-D132MB4" "sub-D141MB4" "sub-D143MB4" "sub-D144MB4" "sub-D153MB4"
#     )
# rawIDs=(
#     "sub-D137MB4" "sub-D148MB4" "sub-D155MB4"
#     )
rawIDs=(
    "sub-D159MB4"
    )
# newIDs=(
#     "sub-092" "sub-093" "sub-094" "sub-097" "sub-098" 
#     "sub-099" "sub-103" "sub-105" "sub-106" "sub-108"
#     "sub-110" "sub-111" "sub-112" "sub-115" "sub-118"
#     "sub-122" "sub-123" "sub-127" "sub-130" "sub-131"
#     "sub-132" "sub-141" "sub-143" "sub-144" "sub-153"
#     )
# newIDs=(
#     "sub-137" "sub-148" "sub-155"
#     )
newIDs=(
    "sub-159"
    )

for index in ${!rawIDs[*]}; do
    echo "pre : ${rawIDs[$index]} : ${newIDs[$index]}"
    srce_dir=/home/lukeh/LabData/Lab_LucaC/A_QNC_Databank/MRI_Baseline/${rawIDs[$index]}
    dcm2bids -d ${srce_dir} -p ${newIDs[$index]} -c ${BIDS_CONFIG} -o ${bids_dir} -s pre

done

# POST scan
# rawIDs=(
#     "QNC_D_092" "QNC_D_093" "QNC_D_094" "QNC_D_097" "QNC_D_098"
#     "QNC_D_099" "QNC_D_103" "QNC_D_105" "QNC_D_106" "QNC_D_108"
#     "QNC_D_110" "QNC_D_111" "QNC_D_112" "QNC_D_115_V2" "QNC_D_118"
#     "QNC_D_122_V2" "QNC_D_123_V2" "QNC_D_127_V2" "QNC_D_130_V2" "QNC_D_131_V2"
#     "QNC_D_132_V2" "QNC_D_141_POST" "QNC_D_143_V2" "QNC_D_144_POST" "QNC_D_153_V2"
#     )
# rawIDs=(
#     "QNC_D_137_V2" "QNC_D_148_V2" "QNC_D_155_V2"
#     )
rawIDs=("QNC_D_159_V2")

for index in ${!rawIDs[*]}; do 
    echo "post : ${rawIDs[$index]} : ${newIDs[$index]}"
    srce_dir=/home/lukeh/LabData/Lab_LucaC/A_QNC_Databank/MRI_Post/${rawIDs[$index]}
    dcm2bids -d ${srce_dir} -p ${newIDs[$index]} -c ${BIDS_CONFIG} -o ${bids_dir} -s post

done
