#!/bin/bash
#
# uploadc callbacks
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

declare -gA UPLOADC_FUNCS
UPLOADC_FUNCS['dl_parse_form2']='uploadc_dl_parse_form2'
UPLOADC_FUNCS['dl_commit_step2']='uploadc_dl_commit_step2'
UPLOADC_FUNCS['pr_parse_file_size']='uploadc_pr_parse_file_size'
UPLOADC_FUNCS['ul_get_space_data']='uploadc_ul_get_space_data'

uploadc_dl_parse_form2() {
    xfilesharing_dl_parse_form2_generic "$1" 'frmdownload' '' '' '' '' '' '' '' '' \
        'ipcount_val'
}

uploadc_dl_commit_step2() {
    local -r COOKIE_FILE=$1
    #local -r FORM_ACTION=$2
    local -r FORM_DATA=$3
    #local -r FORM_CAPTCHA=$4

    local JS URL PAGE FILE_URL EXTRA FILE_NAME_TMP FILE_NAME

    { read -r FILE_NAME_TMP; } <<<"$FORM_DATA"
    [ -n "$FILE_NAME_TMP" ] && FILE_NAME=$(echo "$FILE_NAME_TMP" | parse . '=\(.*\)$')

    PAGE=$(xfilesharing_dl_commit_step2_generic "$@") || return

    URL=$(echo "$PAGE" | parse_attr "/download-[[:alnum:]]\{12\}.html" 'href') || return

    # Required to download file
    EXTRA="MODULE_XFILESHARING_DOWNLOAD_FINAL_LINK_NEEDS_EXTRA=( -e \"$URL\" )"

    PAGE=$(curl -i -e "$URL" -b "$COOKIE_FILE" -b 'lang=english' "$URL") || return

    detect_javascript || return

    log_debug 'Decrypting final link...'

    JS=$(echo "$PAGE" | parse "^<script type='text/javascript'>eval(function(p,a,c,k,e,d)" ">\(.*\)$") || return

    #FILE_URL=$(echo "var document={location:{href:''}}; $JS; dnlFile(); print(document.location.href);" | javascript) || return
    JS=$(xfilesharing_unpack_js "$JS") || return

    FILE_URL=$(echo "$JS" | parse 'document.location.href' "document.location.href='\(.*\)'") || return

    echo "$FILE_URL"
    echo "$FILE_NAME"
    echo "$EXTRA"
}

uploadc_pr_parse_file_size() {
    local -r PAGE=$1
    local FILE_SIZE

    FILE_SIZE=$(parse_quiet 'File Size :' '^[[:space:]]*\(.*\)' 1 <<< "$PAGE")

    echo "$FILE_SIZE"
}

uploadc_ul_get_space_data() {
    return 0
}