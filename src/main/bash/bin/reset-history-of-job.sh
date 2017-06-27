#!/bin/bash
## Reset all state for the specified job that pertains to its (build) history.
## By Stephen D. Rogers <inbox.c7r@steve-rogers.com>, 2017-06.
##
## Usage:
## 
##     reset-history-of-job [job_name_or_pathname] ...
## 
## Typical uses:
## 
##     reset-history-of-job my-job
##     
##     reset-history-of-job jobs/*
## 

set -e -o pipefail

PATH="$(dirname "$(dirname "$(realpath "$0")")")/libexec":"$PATH"

source jenkins.admin.core.functions.sh
source jenkins.admin.job.functions.sh

##

main() { # ...

	check_cwd_is_jenkins_home

	reset_history_of_job "$@"
}

##

main "$@"

