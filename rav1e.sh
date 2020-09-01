#!/bin/bash
for cpu in 10 9 8 7 6 5 4 3 2 1 0
do
    for i in 150 130 110 90
    do
        runtime=`av1an.py -p 1 --split_method aom_keyframes -s ${1}.csv -i ${1} -enc rav1e -v " --quantizer $i -s $cpu " -o rav1e${i}_${c} | grep Finished | cut -d' ' -f2 | tr -d '[[:alpha:]]'`
        vmaf=`ffmpeg -r 60 -i rav1e${i}_${c}.mkv -r 60 -i ${1} -filter_complex libvmaf=psnr=1:ssim=1:ms_ssim=1:log_path=${i}_${c}.json:log_fmt=json -f null - 2>&1 | grep "VMAF score" | tr ' ' '\n' | tail -n1`

        vmaf=`jq '.["VMAF score"]'  ${i}_${c}.json`
        psnr=`jq '.["PSNR score"]'  ${i}_${c}.json`
        ssim=`jq '.["SSIM score"]'  ${i}_${c}.json`
        ms_ssim=`jq '.["MS-SSIM score"]'  ${i}_${c}.json`

        bitrate=`ffprobe -i rav1e${i}_${c}.mkv 2>&1 | grep bitrate | rev | cut -d' ' -f2 | rev`
        output="('rav1e', $runtime, $cpu, $i, $bitrate, $vmaf, $psnr, $ssim, $ms_ssim),"
        echo $output
        echo -n $output >> rav1e_${1}data.txt
done
done
