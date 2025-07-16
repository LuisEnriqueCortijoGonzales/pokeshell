#!/usr/bin/env bash
function imgshl_stitch_images () {
    local -n _images
    _images=${1:?}
    display_file="${_images[0]}"
}

function imgshl_display_image () {
    local display_file
    local pixel_perfect

    display_file=${1:?}
    pixel_perfect=${2:?}
    timg -p iterm2 "${display_file}"
}


function imgshl_cleanup () {
    local -n _images
    local cache
    local cache_dir
    _images=${1:?}
    cache=${2:?}
    cache_dir=${3:?}
    if [ "$cache" == 0 ]; then
        for _i in "${_images[@]}"; do
            rm -f "${_i}"
        done
    fi
    rm -f "$cache_dir/t.tiff"
}

function imgshl_stitch_ani_images () {
    local -n _images
    _images=${1:?}
    display_file="${_images[0]}"
}



function imgshl_display () {
    local -n __images
    local use_ani
    local scale
    local trim
    local pixel_perfect
    local cache
    local cache_dir
    __images=${1:?}
    use_ani=${2:?}
    scale=${3:?}
    trim=${4:?}
    pixel_perfect=${5:?}
    cache=${6:?}
    cache_dir=${7:?}
    if [ $use_ani == 0 ]; then
        imgshl_stitch_images __images $scale $trim $cache_dir
        imgshl_display_image "$display_file" $pixel_perfect
        imgshl_cleanup __images $cache $cache_dir
    else
        imgshl_stitch_ani_images __images $scale $cache $cache_dir
        imgshl_display_ani_image "$display_file"
    fi
}