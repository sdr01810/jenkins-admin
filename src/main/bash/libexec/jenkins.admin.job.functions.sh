##/bin/bash source'd
## Helper functions for Jenkins admin scripts pertaining to jobs.
## By Stephen D. Rogers <inbox.c7r@steve-rogers.com>, 2017-06.
## 

[ -z "$jenkins_admin_job_functions_p" ] || return 0 ; jenkins_admin_job_functions_p=t

source jenkins.admin.core.functions.sh

##

looks_like_job_pathname() { # j1 ...
	local j1

	[ $# -gt 0 ] || return 1

	for j1 in "$@" ; do

		case x/"${j1%/}"/x in
		*/jobs/x) false ;; */jobs/*) true ;; *) false ;;
		esac || return 1
	done
	return 0
}

check_looks_like_job_pathname() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do

		if ! looks_like_job_pathname "$@" ; then
			echo 1>&2 "cannot infer a job corresponding to pathname: $j1"
			rc=2
		fi
	done
	return ${rc:?}
}

job_from_pathname() { # j1 ...
	local j1

	for j1 in "$@" ; do
		check_looks_like_job_pathname "$j1"
		j1="$(realpath "$j1")"

		local result="${j1##*/jobs/}" ; result="${result%%/*}"
		echo "$result"
	done
}

##

looks_like_job_name() { # j1 ...
	local j1

	[ $# -gt 0 ] || return 1

	for j1 in "$@" ; do

                ! [ -z "$j1" ] || return 1
                ! looks_like_job_pathname "$j1" || return 1

		case x"${j1}"x in
		*" "*) false ;; *) true ;;
		esac || return 1
	done
	return 0
}

check_looks_like_job_name() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do

		if ! looks_like_job_name "$@" ; then
			echo 1>&2 "cannot infer a job corresponding to name: $j1"
			rc=1
		fi
	done
        return ${rc:?}
}

job_from_name() { # j1 ...
	local j1

	for j1 in "$@" ; do
		check_looks_like_job_name "$j1"

		echo "$j1"
	done
}

##

looks_like_job_spec() { # j1 ...
	local j1
	local rc=0

	[ $# -gt 0 ] || return 1

	for j1 in "$@" ; do

		! looks_like_job_pathname "$j1" || continue
		! looks_like_job_name "$j1" || continue

		rc=1
	done
	return ${rc:?}
}

check_looks_like_job_spec() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do

		if ! looks_like_job_spec "$@" ; then
			echo 1>&2 "cannot infer a job corresponding to spec: $j1"
			rc=1
		fi
	done
        return ${rc:?}
}

job_from_spec() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do

		check_looks_like_job_spec "$j1" || { rc=1 ; continue ; }

		if looks_like_job_pathname "$j1" ; then
			echo "$(job_from_pathname "$j1")"
			continue
		fi
		if looks_like_job_name "$j1" ; then
			echo "$(job_from_name "$j1")"
			continue
		fi
		echo 1>&2 "unexpected type of job spec: $j1"
		rc=1
	done
	return ${rc:?}
}

##

pathname_of_job() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do

		check_looks_like_job_spec "$j1" || { rc=1 ; continue ; }

		echo "jobs/$(job_from_spec "$j1")"
	done
        return ${rc:?}
}

job_exists() { # j1 ...
	local j1

	for j1 in "$@" ; do

		j1_pn="$(pathname_of_job "$j1")"
                [ -d "$j1_pn" ] || return 1
	done
        return 0
}

check_job_exists() { # j1 ...
	local j1
	local rc=0

	for j1 in "$@" ; do 

		if ! job_exists "$j1" ; then
			echo 1>&2 "does not exist; job: $j1"
			rc=1
		fi
	done
	return ${rc:?}
}

##

reset_history_of_job_directory() {( # j1_dpn ...
	local j1_dpn

	for j1_dpn in "$@" ; do

		xx :
		xx cd "$(jenkins_admin_share_root)"/jobs/job-with-no-history.to-replace.d

		xx cp -r . "${j1_dpn:?}"

		##

		xx :
		xx cd "${j1_dpn:?}"

		cat "$(jenkins_admin_share_root)"/jobs/job-with-no-history.to-delete |
		while read -r f1 ; do
			! [ -d "$f1" ] || continue

			! [ -e "$f1" ] || xx rm -f "$f1"
		done

		woe ls -d builds/[0-9]* |
		while read -r d1 ; do
			[ -d "$d1" ] || continue

			xx rm -fr "$d1"
		done
	done
)}

reset_history_of_job() { # j1 ...
	local j1
        local j1_dpn

	for j1 in "$@" ; do
                
		check_job_exists "$j1" || continue

		for j1_dpn in "$(realpath "$(pathname_of_job "$j1")")" ; do

			woe find "$j1_dpn"/* -type d \( -name builds -o -name nextBuildNumber \) |
			while read -r j1_build_history_marker_pn ; do

				reset_history_of_job_directory "$(dirname "${j1_build_history_marker_pn:?}")"
			done
		done
	done
}

##

