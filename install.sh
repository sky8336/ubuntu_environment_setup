#!/bin/bash
#
# install.sh
#
# Copyright (C) 2018-2023 Eric MA  <eric@company.com>. All Rights Reserved.
#
# History:
#    2019/09/23 - [Eric MA] Created file
#
# Maintainer: Eric MA <eric@email.com>
#    Created: 2019-09-23
# LastChange: 2019-09-23
#    Version: v0.0.01
#

source ./utils.sh


deb_packages=(
	baidunetdisk_linux_2.0.2.deb
	dingding/dingding.deb
	wiznote/wiznote_2.3.2.4_amd64.deb
)

cur_prog=0
online=1

#安装需要的软件包
function install_packages()
{
	if [[ $online -ne 1 ]]; then
		return 0
	fi
	pkg_num=${#deb_packages[@]}

	local prog=$cur_prog
	local step=5

	progress_log $prog "====== Install software packages now ! ======"

	while [[ $i -lt $pkg_num ]]; do
		#sudo apt-get install ${deb_packages[i]} --allow-unauthenticated > /dev/null
		sudo dpkg --install software/${deb_packages[i]} > /dev/null
		let i++
		let prog+=5
		progress_log $prog "Install ${deb_packages[i]} ... done"
	done

	cd software/dingding
	tar -zxf dtalk.tar.gz
	sudo cp ./dtalk/ /opt -dpRf
	rm ./dtalk -rf
	cd -

	cur_prog=$prog
}

#
# update related apis
#

# first step
function update_self()
{
	skyvim_path=$(pwd)
	repo_name=$(echo $skyvim_path | awk -F '/'  '{print $NF}')

	echo "====== update $repo_name: git pull ======"

	#chown -R $username:$groupname ../$repo_name
	git pull
	#chown -R $username:$groupname ../$repo_name
	echo "update $repo_name -- done"
}

ubuntu_env_setup()
{
	install_packages
}

main()
{
	if [[ -z $1 ]]; then
		echo
		blue_log ">> step1: prepare and update $repo_name repo."
		set_color
		# prepare
		#check_root_privileges
		get_start_time
		#check_network

		# step1: update $repo_name
		update_self
		echo "$repo_name repo update -- done"

		# now install.sh has been updated
		# execure step2 using new script
		sudo ./`basename $0` 1

		echo_install_time
	elif [[ $1 -eq 1 ]]; then
		echo
		blue_log ">> step2: setup ubuntu environment now!"
		# step2: setup vim config
		ubuntu_env_setup
		prog=100
		progress_log $prog "ubuntu enviroment setup -- done"
		show_logo
	else
		echo "invalid  parameter."
	fi
}

main "$@"
