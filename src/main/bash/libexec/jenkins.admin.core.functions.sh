##/bin/bash
## Core helper functions for Jenkins admin scripts.
## By Stephen D. Rogers <inbox.c7r@steve-rogers.com>, 2017-06.
## 

[ -z "$jenkins_admin_core_functions_p" ] || return 0 ; jenkins_admin_core_functions_p=t

##

qq() { # ...

	printf "%q" "$*"
}

xx() { # ...

	echo 1>&2 "+" "$@"
	"$@"
}

woe() { # ...

	"$@" 2>&- || :
}

##

jenkins_admin_root() {

	dirname "$(dirname "$(realpath "${BASH_SOURCE}")")"
}

jenkins_admin_bin_root() {

	echo "$(jenkins_admin_root)"/bin
}

jenkins_admin_lib_root() {

	echo "$(jenkins_admin_root)"/lib
}

jenkins_admin_libexec_root() {

	echo "$(jenkins_admin_root)"/libexec
}

jenkins_admin_share_root() {

	echo "$(jenkins_admin_root)"/share
}

##

cwd_is_jenkins_home() {

	[ -f config.xml -a -d jobs ]
}

check_cwd_is_jenkins_home() {

	if ! cwd_is_jenkins_home ; then
		echo 1>&2 "current working directory is not the Jenkins home directory"
		return 1
	fi
	return 0
}

##

jenkins_home_root() {(

	if [ -n "${JENKINS_HOME}" ] ; then
		cd "${JENKINS_HOME}"
	fi
        
	check_cwd_is_jenkins_home || return 1

	realpath .
)}

jenkins_home_jobs_root() {

	echo "$(jenkins_home_root)"/jobs
}

##

