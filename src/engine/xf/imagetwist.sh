#!/bin/bash
#
# imagetwist callbacks
# Copyright (c) 2013 Plowshare team
#
# This file is part of Plowshare.
#
# Plowshare is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Plowshare is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Plowshare.  If not, see <http://www.gnu.org/licenses/>.

declare -gA IMAGETWIST_FUNCS
declare -gA IMAGETWIST_OPTIONS
IMAGETWIST_FUNCS['ls_parse_links']='imagetwist_ls_parse_links'
IMAGETWIST_FUNCS['ls_parse_names']='imagetwist_ls_parse_names'
IMAGETWIST_FUNCS['ul_parse_data']='imagetwist_ul_parse_data'
IMAGETWIST_FUNCS['ul_parse_del_code']='imagetwist_ul_parse_del_code'
IMAGETWIST_FUNCS['ul_generate_links']='imagetwist_ul_generate_links'
IMAGETWIST_OPTIONS['UPLOAD_OPTIONS']="${GENERIC_OPTIONS[UPLOAD_OPTIONS]}""
        THUMB_SIZE,,thumb-size,s=THUMB_SZIE,Picture thumb size (100x100, 170x170, 250x250, 300x300, 500x500) (default: 170x170)
        URL_DOMAIN,,url-domain,s=URL_DOMAIN,Picture URL domain (imagetwist.com, imageshimage.com, imagenpic.com) (default: imagetwist.com)"

imagetwist_ls_parse_links() {
    local PAGE=$1
    local LINKS

    LINKS=$(parse_all_attr_quiet '^<TD><a' 'href' <<< "$PAGE")
    LINKS=$(replace '/' 'http://imagetwist.com/' <<< "$LINKS")

    echo "$LINKS"
}

imagetwist_ls_parse_names() {
    return 0
}

imagetwist_ul_parse_data() {
    if [ -z "$THUMB_SIZE" ]; then
        THUMB_SIZE='170x170'
    fi

    if [ "$THUMB_SIZE" != '100x100' -a "$THUMB_SIZE" != '170x170' -a \
        "$THUMB_SIZE" != '250x250' -a "$THUMB_SIZE" != '300x300' -a \
        "$THUMB_SIZE" != '500x500' ]; then
        log_error 'Thumb size can be only 100x100, 170x170, 250x250, 300x300 or 500x500.'
        return $ERR_BAD_COMMAND_LINE
    else
        THUMB_SIZE="thumb_size=$THUMB_SIZE"
    fi

    if [ -z "$URL_DOMAIN" ]; then
        URL_DOMAIN='imagetwist.com'
    fi

    if [ "$URL_DOMAIN" != 'imagetwist.com' -a "$URL_DOMAIN" != 'imageshimage.com' -a \
        "$URL_DOMAIN" != 'imagenpic.com' ]; then
        log_error 'Domain can be only imagetwist.com, imageshimage.com, imagenpic.com.'
        return $ERR_BAD_COMMAND_LINE
    else
        URL_DOMAIN="sdomain=$URL_DOMAIN"
    fi

    xfilesharing_ul_parse_data_generic "$@" "file_safe=0" "$THUMB_SIZE" "$URL_DOMAIN"
}

imagetwist_ul_parse_del_code() {
    local -r PAGE=$1

    parse_attr 'Preview:' 'src' <<< "$PAGE"
}

imagetwist_ul_generate_links() {
    #local BASE_URL=$1
    local FILE_CODE=$2
    local DEL_CODE=$3
    #local FILE_NAME=$4

    echo "http://${URL_DOMAIN}/$FILE_CODE"
    echo "$DEL_CODE"

    return 0
}