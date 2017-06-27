#!/bin/bash
## Apply a patch to the specified job(s).
## By Stephen D. Rogers, 2017-07.
## 
## Typical uses:
## 
##     alter-job-config-based-on-patch .sb.wip.patch jobs/astam-cqf-*
##

set -e -o pipefail

PATH="$(dirname "$(dirname "$(realpath "$0")")")/libexec":"$PATH"

source jenkins.admin.core.functions.sh

##

check_cwd_is_jenkins_home

patch_fpn="$(basename "${1:?missing argument: patch}")" ; shift

##

echo NOT DONE YET ; exit 1

for d1 in jobs/astam-cqf-ce* ; do j1="${d1##*/}" ; ! [ "$j1" = "astam-cqf-ce" ] || continue ; cat .sb.wip.patch | perl -pe "s{/astam-cqf-ce/}{/$j1/}" | patch -j1 ; done

##

