#!/bin/bash
for cpu in 8 7 6 5 4 3 2 1 0
do
    for i in  35 30 25 20
    do
        runtime=`av1an -p 1 --split_method aom_keyframes -s ${1} -i ${1} -enc svt_av1 -v " --qp $i --preset $cpu " -o svt${i}_${c} | grep Finished | cut -d' ' -f2 | tr -d '[[:alpha:]]'`
        vmaf=`ffmpeg -r 60 -i svt${i}_${c}.mkv -r 60 -i ${1} -filter_complex libvmaf=psnr=1:ssim=1:ms_ssim=1:log_path=${i}_${c}.json:log_fmt=json -f null - 2>&1 | grep "VMAF score" | tr ' ' '\n' | tail -n1`

        vmaf=`jq '.["VMAF score"]'  ${i}_${c}.json`
        psnr=`jq '.["PSNR score"]'  ${i}_${c}.json`
        ssim=`jq '.["SSIM score"]'  ${i}_${c}.json`
        ms_ssim=`jq '.["MS-SSIM score"]'  ${i}_${c}.json`

        bitrate=`ffprobe -i svt${i}_${c}.mkv 2>&1 | grep bitrate | rev | cut -d' ' -f2 | rev`
        output="('svt', $runtime, $cpu, $i, $bitrate, $vmaf, $psnr, $ssim, $ms_ssim),"
        echo $output
        echo -n $output >> svt_${1}data.txt
done
done
