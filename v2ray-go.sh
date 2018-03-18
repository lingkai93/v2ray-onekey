##################################
# Designed by CN_SZTL            #
# Telegram: @CN_SZTL             #
# Blog: ctcgfw-blog.blogspot.com #
# Tools URL: v2ray-install.ml    #
##################################

#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function rootness(){
	clear
	echo "正在检测当前是否为ROOT用户..."
	if [[ $EUID -ne 0 ]]; then
		sudo su
		rootness
		clear
		echo "错误：当前并非ROOT用户，请先切换到ROOT用户后再使用本脚本。"
		exit
	fi
	clear
	echo "当前为Root用户。"
}

function checkos(){
	clear
	echo "正在检测此OS是否被支持..."
	if [ ! -z "$(cat /etc/issue | grep Debian)" ];then
		OS='debian'
		clear
		echo "该脚本支持您的系统。"
	elif [ ! -z "$(cat /etc/issue | grep Ubuntu)" ];then
		OS='ubuntu'
		clear
		echo "该脚本支持您的系统。"
	else
		clear
		echo "目前暂不支持您使用的操作系统，请切换至Debian/Ubuntu。"
		exit
	fi
}

function checkenv(){
	echo "正在安装/更新系统组件中..."
	clear
	apt-get -y update
	apt-get -y upgrade
	apt-get -y install wget curl ntpdate unzip socat netcat lsof
	if [[ $? -ne 0 ]];then
		echo "系统组件更新失败！"
		exit
	else
		clear
		echo "系统组件更新完毕。"
	fi
}

function netdate(){
	clear
	echo "正在对时中..."
	rm -rf /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	ntpdate time.nist.gov
	if [[ $? -eq 0 ]];then
		clear
		echo "时间同步成功！"
		echo "当前系统时间 $(date -R) （请注意时区间时间换算，换算后时间误差应为三分钟以内）"
	else
		clear
		echo "时间同步失败，请检查ntpdate服务是否正常工作。"
		echo "当前系统时间 $(date -R) ，如果和你的本地时间有误差，请手动调整。"
	fi 
}

function echo_install_type(){
	clear
	if_install_status
	check_v2ray_run_status
	check_caddy_run_status
	clear
	echo "安装V2ray:"
	echo "1.Socks5(不支持设置用户名和密码)"
	echo "2.Shadowsocks"
	echo "3.Shadowsocks+mkcp"
	echo "4.TCP"
	echo "5.TCP+动态端口"
	echo "6.TCP+HTTP伪装(监听80端口)"
	echo "7.TCP+TLS(监听443端口)"
	echo "8.TCP+TLS(自带域名，监听443端口)"
	echo "9.Mkcp"
	echo "10.Mkcp+BT流量伪装"
	echo "11.Mkcp+视频流量伪装"
	echo "12.Mkcp+微信视频流量伪装"
	echo "13.Mkcp+动态端口"
	echo "14.Mkcp+微信视频流量伪装+动态端口"
	echo "15.Websocket+TLS(使用Host分流，监听443端口)"
	echo "16.Websocket+TLS(使用Path分流，可使用CDN，监听443端口)"
	echo "17.Websocket+TLS+(自带域名，使用Path分流，可使用CDN，监听443端口)"
	echo "18.Websocket+TLS+网站伪装(使用Caddy转发流量，使用Path分流，可使用CDN，监听443端口)"
	echo "19.Websocket+TLS+网站伪装(自带域名，使用Caddy转发流量，使用Path分流，可使用CDN，监听443端口)"
	echo "--------------------------------------------------------------------------------------------------"
	echo "20.卸载V2Ray"
	echo "--------------------------------------------------------------------------------------------------"
	echo "21.重装V2Ray"
	echo "--------------------------------------------------------------------------------------------------"
	echo "脚本当前安装状态：${install_status}"
	echo "V2Ray当前运行状态：${v2ray_run_status}"
	echo "Caddy当前运行状态：${caddy_run_status}"
	echo "22.启动"
	echo "23.关闭"
	echo "24.重启"
	echo "--------------------------------------------------------------------------------------------------"
	stty erase '^H' && read -p "请输入序号：" install_type
	if [[ ${install_type} = "" ]]; then
		clear
		echo "请输入序号！"
		echo_install_type
	elif [[ ${install_type} -lt 1 ]]; then
		clear
		echo "请输入正确的序号！"
		echo_install_type
	elif [[ ${install_type} -gt 24 ]]; then
		clear
		echo "请输入正确的序号！"
		echo_install_type
	fi
}

function check_v2ray_run_status(){
	v2ray_info=$(cat /etc/v2ray/config.json)
	if [[ ${v2ray_info} = "" ]]; then
		v2ray_run_status="未安装"
	else
		v2ray_pid=$(ps -ef |grep "v2ray" |grep -v "grep" | grep -v ".sh"| grep -v "init.d" |grep -v "service" |awk '{print $2}')
		if [[ ${v2ray_pid} = "" ]]; then
			v2ray_run_status="未运行"
		else
			v2ray_run_status="正在运行"
		fi
	fi
}

function check_caddy_run_status(){
	caddy_info=$(cat /usr/local/caddy/Caddyfile)
	if [[ ${caddy_info} = "" ]]; then
		caddy_run_status="未安装"
	else
		caddy_pid=$(ps -ef |grep "caddy" |grep -v "grep" | grep -v ".sh"| grep -v "init.d" |grep -v "service" |awk '{print $2}')
		if [[ ${caddy_pid} = "" ]]; then
			caddy_run_status="未运行"
		else
			caddy_run_status="正在运行"
		fi
	fi
}

function install_v2ray(){
	clear
	echo "安装V2Ray主程序中..."
	bash <(curl https://install.direct/go.sh)
	if [[ $? -eq 0 ]];then
		clear
		echo -e "V2ray 安装成功。"
	else
		clear
		echo -e "V2ray 安装失败，请检查相关依赖是否正确安装。"
		exit
	fi
}

function if_install_status(){
	install_if=$(cat /etc/v2ray/install_type.txt)
	if [[ ${install_if} = "" ]]; then
		install_status="未安装"
	else
		install_status="已安装"
	fi
}

function check_if_install(){
	clear
	echo "正在检查安装状态中..."
	if [[ ${install_status} = "已安装" ]]; then
		clear
		echo "V2Ray已经被安装，请勿再次执行安装程序。"
		exit
	else
		return 0
	fi
}

function generate_base_info(){
	clear
	echo "正在生成基础信息中..."
	hostname=$(hostname)
	Address=$(curl https://ipinfo.io/ip)
	UUID=$(cat /proc/sys/kernel/random/uuid)
	UUID2=$(cat /proc/sys/kernel/random/uuid)
	let v2_listen_port=$RANDOM+10000
	if [[ ${hostname} = "" ]]; then
		clear
		echo "读取Hostname失败！"
		exit
	elif [[ ${Address} = "" ]]; then
		clear
		echo "读取vps_ip失败！"
		exit
	elif [[ ${UUID} = "" ]]; then
		clear
		echo "生成UUID失败！"
		exit
	elif [[ ${UUID2} = "" ]]; then
		clear
		echo "生成UUID2失败！"
		exit
	elif [[ ${v2_listen_port} = "" ]]; then
		clear
		echo "生成V2Ray监听端口失败！"
		exit
	else
		clear
		echo "您的主机名为：${hostname}"
		echo "您的vps_ip为：${Address}"
		echo "生成的UUID为：${UUID}"
		echo "生成的UUID2为：${UUID2}"
		echo "生成V2Ray监听端口为：${v2_listen_port}"
	fi
}

function set_v2ray_config(){
	if [[ ${install_type} = "20" ]]; then
		if_install_status
		if [[ ${install_status} = "已安装" ]]; then
			install_type=${install_if}
			remove_install
		else
			clear
			echo "您未安装V2Ray，无法卸载。"
		fi
		return 0
	elif [[ ${install_type} = "21" ]]; then
		if_install_status
		if [[ ${install_status} = "已安装" ]]; then
			install_type=${install_if}
			remove_install
			set_v2ray_config
		else
			clear
			echo "您未安装V2Ray，无法重装。"
		fi
		return 0
	elif [[ ${install_type} = "22" ]]; then
		if_install_status
		if [[ ${install_status} = "已安装" ]]; then
			if [ "${install_if}" -le "14" ]; then
				service v2ray start
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray启动成功！"
				else
					clear
					echo "V2Ray启动失败！"
				fi
				return 0
			elif [ "${install_if}" -gt "14" ];then
				service v2ray start
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray启动成功！"
				else
					clear
					echo "V2Ray启动失败！"
				fi
				service caddy start
				if [[ $? -eq 0 ]];then
					clear
					echo "Caddy启动成功！"
				else
					clear
					echo "Caddy启动失败！"
				fi
				return 0
			fi
		else
			clear
			echo "V2Ray未被安装。"
			exit
		fi
		return 0
	elif [[ ${install_type} = "23" ]]; then
		if_install_status
		if [[ ${install_status} = "已安装" ]]; then
			if [ "${install_if}" -le "14" ]; then
				service v2ray stop
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray停止成功！"
				else
					clear
					echo "V2Ray停止失败！"
				fi
				return 0
			elif [ "${install_if}" -gt "14" ];then
				service v2ray stop
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray停止成功！"
				else
					clear
					echo "V2Ray停止失败！"
				fi
				service caddy stop
				if [[ $? -eq 0 ]];then
					clear
					echo "Caddy停止成功！"
				else
					clear
					echo "Caddy停止失败！"
				fi
				return 0
			fi
		else
			clear
			echo "V2Ray未被安装。"
			exit
		fi
		return 0
	elif [[ ${install_type} = "24" ]]; then
		if_install_status
		if [[ ${install_status} = "已安装" ]]; then
			if [ "${install_if}" -le "14" ]; then
				service v2ray restart
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray重启成功！"
				else
					clear
					echo "V2Ray重启失败！"
				fi
				return 0
			elif [ "${install_if}" -gt "14" ];then
				service v2ray restart
				if [[ $? -eq 0 ]];then
					clear
					echo "V2Ray重启成功！"
				else
					clear
					echo "V2Ray重启失败！"
				fi
				service caddy restart
				if [[ $? -eq 0 ]];then
					clear
					echo "Caddy重启成功！"
				else
					clear
					echo "Caddy重启失败！"
				fi
				return 0
			fi
		else
			clear
			echo "V2Ray未被安装。"
			exit
		fi
		return 0
	fi
	check_if_install
	checkenv
	netdate
	install_v2ray
	generate_base_info
	clear
	echo "配置V2Ray中..."
	rm -rf /etc/v2ray/config.json
	if [[ ${install_type} = "1" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/socks5.json"
		input_port
		service_restart
		echo_v2ray_info
		echo "1" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "2" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/shadowsocks.json"
		input_port
		stty erase '^H' && read -p "请输入SS的加密方式(默认加密方式：ase-256-gcm)：" install_ss_encryption_type
		if [[ ${install_ss_encryption_type} = "" ]]; then
			install_ss_encryption_type="ase-256-gcm"
		else
			sed -i "s/ase-256-gcm/${install_ss_encryption_type}/g" "/etc/v2ray/config.json"
		fi
		stty erase '^H' && read -p "请输入SS的连接密码(默认密码：sspwd)：" install_ss_password
		if [[ ${install_ss_password} = "" ]]; then
			install_ss_password="sspwd"
		else
			sed -i "s/sspwd/${install_ss_password}/g" "/etc/v2ray/config.json"
		fi
		service_restart
		echo_v2ray_info
		echo "2" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "3" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/shadowsocks-mkcp.json"
		clear
		input_port
		stty erase '^H' && read -p "请输入SS的加密方式(默认加密方式：ase-256-gcm)：" install_ss_encryption_type
		if [[ ${install_ss_encryption_type} = "" ]]; then
			install_ss_encryption_type="ase-256-gcm"
		else
			sed -i "s/ase-256-gcm/${install_ss_encryption_type}/g" "/etc/v2ray/config.json"
		fi
		clear
		stty erase '^H' && read -p "请输入SS的连接密码(默认密码：sspwd)：" install_ss_password
		if [[ ${install_ss_password} = "" ]]; then
			install_ss_password="sspwd"
		else
			sed -i "s/sspwd/${install_ss_password}/g" "/etc/v2ray/config.json"
		fi
		service_restart
		echo_v2ray_info
		echo "3" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "4" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/tcp.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "4" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "5" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/tcp-dynport.json"
		clear
		stty erase '^H' && read -p "请输入监听端口(默认监听8080端口)：" install_port
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "5" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "6" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/tcp-http.json"
		clear
		install_port="80"
		port_check
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		clear
		stty erase '^H' && read -p "请输入伪装域名，多个域名请使用英文逗号\",\"隔开(默认：cache.m.iqiyi.com)：" false_domain
		if [[ ${false_domain} = "" ]]; then
			false_domain="cache.m.iqiyi.com"
		else
			sed -i "s/cache.m.iqiyi.com/${false_domain}/g" "/etc/v2ray/config.json"
		fi
		service_restart
		echo_v2ray_info
		echo "6" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "7" ]]; then
		install_acme
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/tcp-tls.json"
		clear
		install_port="443"
		port_check
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		clear
		stty erase '^H' && read -p "请输入您的域名：" install_domain
		if [[ ${install_domain} = "" ]]; then
			clear
			echo "请输入您的域名！"
			set_v2ray_config
		else
			issue_ssl
			sed -i "s/V2rayAddress/${install_domain}/g" "/etc/v2ray/config.json"
			echo "${install_domain}" > /etc/v2ray/full_domain.txt
		fi
		service_restart
		echo_v2ray_info
		echo "7" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "8" ]]; then
		install_acme
		install_port="443"
		port_check
		generate_domain
		issue_cfssl
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/tcp-tls.json"
		sed -i "s/V2rayAddress/${domain_fullname}/g" "/etc/v2ray/config.json"
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		clear
		service_restart
		echo_v2ray_info
		echo "8" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "9" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "9" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "10" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-utp.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "10" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "11" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-srtp.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "11" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "12" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-wechatvideo.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "12" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "13" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-dynport.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "13" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "14" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-dynport.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "14" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "14" ]]; then
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/mkcp-wechatvideo-dynport.json"
		clear
		input_port
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "14" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "15" ]]; then
		install_acme
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-host.json"
		clear
		install_port="443"
		port_check
		clear
		stty erase '^H' && read -p "请输入您的域名：" install_domain
		if [[ ${install_domain} = "" ]]; then
			clear
			echo "请输入您的域名！"
			set_v2ray_config
		else
			issue_ssl
			sed -i "s/V2rayAddress/${install_domain}/g" "/etc/v2ray/config.json"
			echo "${install_domain}" > /etc/v2ray/full_domain.txt
		fi
		sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "15" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "16" ]]; then
		install_acme
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-path.json"
		clear
		install_port="443"
		port_check
		clear
		stty erase '^H' && read -p "请输入您的域名：" install_domain
		if [[ ${install_domain} = "" ]]; then
			clear
			echo "请输入您的域名！"
			set_v2ray_config
		else
			issue_ssl
			sed -i "s/V2rayAddress/${install_domain}/g" "/etc/v2ray/config.json"
			echo "${install_domain}" > /etc/v2ray/full_domain.txt
		fi
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "16" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "17" ]]; then
		install_acme
		install_port="443"
		port_check
		generate_domain
		issue_cfssl
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-path.json"
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
		service_restart
		echo_v2ray_info
		echo "17" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "18" ]]; then
		install_caddy
		install_port="443"
		port_check
		clear
		stty erase '^H' && read -p "请输入您的域名：" install_domain
		if [[ ${install_domain} = "" ]]; then
			clear
			echo "请输入您的域名！"
			set_v2ray_config
		fi
		echo ""${install_domain#*"://"}"" > /tmp/caddyaddress.txt
		sed -i "s#/##g" "/tmp/caddyaddress.txt"
		install_domain=$(cat "/tmp/caddyaddress.txt")
		rm -rf /tmp/caddyaddress.txt
		echo "${install_domain}" > /etc/v2ray/full_domain.txt
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-website-path.json"
		wget -qO /usr/local/caddy/Caddyfile "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-website-path.Caddyfile"
		sed -i "s/PathUUID/${UUID2}/g" "/usr/local/caddy/Caddyfile"
		sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
		sed -i "s/V2RayListenPort/${v2_listen_port}/g" "/etc/v2ray/config.json"
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		sed -i "s/V2RayListenPort/${v2_listen_port}/g" "/usr/local/caddy/Caddyfile"
		sed -i "s/V2rayAddress/${install_domain}/g" "/usr/local/caddy/Caddyfile"
		mkdir /etc/v2ray/pages
		cd /etc/v2ray/pages
		wget https://websocket-tls-website-path.v2ray-install.ml/v2ray-webpage.zip
		unzip v2ray-webpage.zip
		rm -rf v2ray-webpage.zip
		cd /root/
		service_restart
		echo_v2ray_info
		echo "18" > /etc/v2ray/install_type.txt
	elif [[ ${install_type} = "19" ]]; then
		install_acme
		install_caddy
		install_port="443"
		port_check
		generate_domain
		issue_cfssl
		wget -O "/etc/v2ray/config.json" "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-website-path-domain.json"
		wget -qO /usr/local/caddy/Caddyfile "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/websocket-tls-website-path-domain.Caddyfile"
		sed -i "s/PathUUID/${UUID2}/g" "/usr/local/caddy/Caddyfile"
		sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
		sed -i "s/V2RayListenPort/${v2_listen_port}/g" "/etc/v2ray/config.json"
		sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
		sed -i "s/V2RayListenPort/${v2_listen_port}/g" "/usr/local/caddy/Caddyfile"
		sed -i "s/V2rayAddress/${domain_fullname}/g" "/usr/local/caddy/Caddyfile"
		mkdir /etc/v2ray/pages
		wget -qO /etc/v2ray/pages/index.html "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/v2ray-index.html"
		wget -qO /etc/v2ray/pages/404.html "https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/v2ray-404.html"
		service_restart
		echo_v2ray_info
		echo "19" > /etc/v2ray/install_type.txt
	fi
}

function input_port(){
	clear
	stty erase '^H' && read -p "请输入监听端口(默认监听8080端口)：" install_port
	if [[ ${install_port} = "" ]]; then
		install_port="8080"
	fi
	port_check
	sed -i "s/8080/${install_port}/g" "/etc/v2ray/config.json"
}

function port_check(){
	clear
	echo "正在检查端口占用情况："
	if [[ 0 -eq `lsof -i:"${install_port}" | wc -l` ]];then
		clear
		echo "端口未被占用。"
		return 0
	else
		clear
		echo "端口被占用，请切换使用其他端口。"
		set_v2ray_config
	fi
}

function install_acme(){
	clear
	echo "正在安装acme.sh中..."
	curl https://get.acme.sh | sh
	if [[ $? -eq 0 ]];then
		clear
		echo -e "acme.sh 安装成功。"
	else
		clear
		echo -e "acme.sh 安装失败，请检查相关依赖是否正确安装。"
		exit
	fi
}

function install_caddy(){
	clear
	echo "正在安装Caddy中..."
	bash <(curl https://softs.fun/Bash/caddy_install.sh)
	if [[ $? -eq 0 ]];then
		clear
		echo -e "Caddy 安装成功。"
	else
		clear
		echo -e "Caddy 安装失败，请检查相关依赖是否正确安装。"
		exit
	fi
}

function generate_domain(){
	clear
	let domain_number=$RANDOM+$RANDOM+100000
	v2_domain=$(curl https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/domain.txt)
	zone_id=$(curl https://raw.githubusercontent.com/1715173329/v2ray-onekey/master/zone_id.txt)
	domain_fullname='cdn'${domain_number}'.'${v2_domain}
	server_ip=$(curl https://ipinfo.io/ip)
	clear
    echo -e "您的VPS_IP是否已被GFW封锁？ / 您是否想使用CloudFlare进行中转？[Y/N ,default:N]"
    stty erase '^H' && read cdn_relay
	if [[ ${cdn_relay} == [Yy] ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":true}')
	elif [[ ${cdn_relay} = "Yes" ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":true}')
	elif [[ ${cdn_relay} = "yes" ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":true}')
	elif [[ ${cdn_relay} == [Nn] ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":false}')
	elif [[ ${cdn_relay} = "No" ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":false}')
	elif [[ ${cdn_relay} = "no" ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":false}')
	elif [[ ${cdn_relay} = "" ]];then
		cfcdn_result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/"${zone_id}"/dns_records" \
			-H "X-Auth-Email: cloudflare@sztl.uu.me" \
			-H "X-Auth-Key: b6d7963dfdc213fee228ecf89d52b588ad0ac" \
			-H "Content-Type: application/json" \
			--data '{"type":"A","name":"'${domain_fullname}'","content":"'${server_ip}'","ttl":1,"proxied":false}')
	fi
	echo "${cfcdn_result}" > /tmp/cfcdn_result_source.txt
	sed -i 's/{/{\n	/g' /tmp/cfcdn_result_source.txt
	sed -i 's/,/,\n	/g' /tmp/cfcdn_result_source.txt
	sed -i 's/}/\n}/g' /tmp/cfcdn_result_source.txt
	grep "id" /tmp/cfcdn_result_source.txt > /tmp/cfcdn_result_id.txt
	sed -i "4d" /tmp/cfcdn_result_id.txt
	sed -i "3d" /tmp/cfcdn_result_id.txt
	sed -i "2d" /tmp/cfcdn_result_id.txt
	sed -i 's/	//g' /tmp/cfcdn_result_id.txt
	sed -i 's/\"id\":"//g' /tmp/cfcdn_result_id.txt
	sed -i 's/",//g' /tmp/cfcdn_result_id.txt
	rm -rf /tmp/cfcdn_result_source.txt
	mv /tmp/cfcdn_result_id.txt /etc/v2ray/cfcdn_result_id.txt
	cfcdn_result=""
	echo "${domain_fullname}" > /etc/v2ray/full_domain.txt
}

function issue_ssl(){
	clear
	echo "正在签发证书中..."
	bash ~/.acme.sh/acme.sh --issue -d ${install_domain} --standalone -k ec-256 --force
	if [[ $? -eq 0 ]];then
		clear
		echo "证书生成成功。"
		bash ~/.acme.sh/acme.sh --installcert -d ${install_domain} --fullchainpath /etc/v2ray/pem.pem --keypath /etc/v2ray/key.key --ecc
		if [[ $? -eq 0 ]];then
			clear
			echo "证书配置成功。"
		fi
	else
		clear
		echo "证书生成失败。"
		exit
	fi
}

function issue_cfssl(){
	clear
	echo "正在签发证书中..."
	export CF_Key="b6d7963dfdc213fee228ecf89d52b588ad0ac"
	export CF_Email="cloudflare@sztl.uu.me"
	bash ~/.acme.sh/acme.sh --issue -d ${domain_fullname} --dns dns_cf  -k ec-256 --force
	if [[ $? -eq 0 ]];then
		clear
		echo "证书生成成功。"
		bash ~/.acme.sh/acme.sh --installcert -d ${domain_fullname} --fullchainpath /etc/v2ray/pem.pem --keypath /etc/v2ray/key.key --ecc
		if [[ $? -eq 0 ]];then
			clear
			echo "证书配置成功。"
		fi
	else
		clear
		echo "证书生成失败。"
		exit
	fi
}

function service_restart(){
	clear
	echo "正在启动服务中..."
	if [ "${install_type}" -le "14" ]; then
		service v2ray restart
		if [[ $? -eq 0 ]];then
			clear
			echo "V2Ray启动成功！"
		else
			clear
			echo "V2Ray启动失败！"
		fi
	elif [ "${install_type}" -le "19" ]; then
		service v2ray restart
		if [[ $? -eq 0 ]];then
			clear
			echo "V2Ray启动成功！"
		else
			clear
			echo "V2Ray启动失败！"
		fi
		service caddy restart
		if [[ $? -eq 0 ]];then
			clear
			echo "Caddy启动成功！"
		else
			clear
			echo "Caddy启动失败！"
		fi
	fi
}

function echo_v2ray_info(){
	clear
	if [[ ${install_type} = "1" ]]; then
		clear
		echo "您的连接信息如下："
		echo "地址(Hostname)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "代理协议(Proxy Type)：socks5"
	elif [[ ${install_type} = "2" ]]; then
		clear
		echo "您的连接信息如下："
		echo "地址(Hostname)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "加密方式：${install_ss_encryption_type}"
		echo "连接密码：${install_ss_password}"
	elif [[ ${install_type} = "3" ]]; then
		clear
		echo "您的连接信息如下："
		echo "地址(Hostname)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "加密方式：${install_ss_encryption_type}"
		echo "连接密码：${install_ss_password}"
		echo "传输协议(Network)：Mkcp"
	elif [[ ${install_type} = "4" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"tcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：tcp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "5" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"tcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：tcp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "6" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"tcp\",
		  \"type\": \"http\",
		  \"host\": \"${false_domain}\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：{Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：tcp"
		echo "伪装类型：http"
		echo "伪装域名/其他项：${false_domain}"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "7" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${install_domain}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"tcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${install_domain}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：tcp"
		echo "底层传输安全(TLS）：tls"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "8" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${domain_fullname}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"tcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${domain_fullname}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：tcp"
		echo "底层传输安全(TLS）：tls"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "9" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "10" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"utp\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "伪装类型：utp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "11" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"srtp\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "伪装类型：srtp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "12" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"wechat-video\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "伪装类型：wechat-video"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "13" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"none\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "14" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${Address}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"kcp\",
		  \"type\": \"wechat-video\",
		  \"host\": \"\",
		  \"tls\": \"\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${Address}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：aes-128-gcm"
		echo "传输协议(Network）：kcp"
		echo "伪装类型：wechat-video"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "15" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${install_domain}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"ws\",
		  \"type\": \"none\",
		  \"host\": \"${UUID2}.youtube.com\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${install_domain}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：ws"
		echo "伪装类型：none"
		echo "伪装域名/其他项：/;${UUID2}.youtube.com"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "16" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${install_domain}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"ws\",
		  \"type\": \"none\",
		  \"host\": \"/fuckgfw_gfwmotherfuckingboom/${UUID2}\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${install_domain}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：ws"
		echo "伪装类型：none"
		echo "伪装域名/其他项：/fuckgfw_gfwmotherfuckingboom/${UUID2}"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "17" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${domain_fullname}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"ws\",
		  \"type\": \"none\",
		  \"host\": \"/fuckgfw_gfwmotherfuckingboom/${UUID2}\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${domain_fullname}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：ws"
		echo "伪装类型：none"
		echo "伪装域名/其他项：/fuckgfw_gfwmotherfuckingboom/${UUID2}"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "18" ]]; then
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${install_domain}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"ws\",
		  \"type\": \"none\",
		  \"host\": \"/fuckgfw_gfwmotherfuckingboom/${UUID2}\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${install_domain}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：ws"
		echo "伪装类型：none"
		echo "伪装域名/其他项：/fuckgfw_gfwmotherfuckingboom/${UUID2}"
		echo "Vmess链接：${vmesslink}"
	elif [[ ${install_type} = "19" ]]; then
		clear
		vmesslink="vmess://"$(echo "{
		  \"ps\": \"${hostname}\",
		  \"add\": \"${domain_fullname}\",
		  \"port\": \"${install_port}\",
		  \"id\": \"${UUID}\",
		  \"aid\": \"100\",
		  \"net\": \"ws\",
		  \"type\": \"none\",
		  \"host\": \"/fuckgfw_gfwmotherfuckingboom/${UUID2}\",
		  \"tls\": \"tls\"
		  }" | base64)
		echo "您的连接信息如下："
		echo "别名(Remarks)：${hostname}"
		echo "地址(Address)：${domain_fullname}"
		echo "端口(Port)：${install_port}"
		echo "用户ID(ID)：${UUID}"
		echo "额外ID(AlterID)：100"
		echo "加密方式(Security)：none"
		echo "传输协议(Network）：ws"
		echo "伪装类型：none"
		echo "伪装域名/其他项：/fuckgfw_gfwmotherfuckingboom/${UUID2}"
		echo "Vmess链接：${vmesslink}"
	fi
}

function remove_install(){
	clear
	echo "正在卸载中..."
	if [ "${install_type}" -le "17" ]; then
		full_domain=$(cat /etc/v2ray/full_domain.txt)
		bash ~/.acme.sh/acme.sh --revoke -d ${full_domain} --ecc
		bash ~/.acme.sh/acme.sh --remove -d ${full_domain} --ecc
		rm -rf ~/.acme.sh
		service v2ray stop
		update-rc.d -f v2ray remove
		systemctl disable v2ray.service
		rm -rf /etc/init.d/v2ray
		rm -rf /lib/systemd/system/v2ray.service
		rm -rf /etc/systemd/system/v2ray.service
		rm -rf /etc/v2ray
		rm -rf /usr/bin/v2ray
		rm -rf /var/log/v2ray
		if [[ $? -eq 0 ]];then
			clear
			echo "V2Ray卸载成功！"
		else
			clear
			echo "V2Ray卸载失败！"
		fi
		return 0
	elif [ "${install_if}" -le "19" ];then
		full_domain=$(cat /etc/v2ray/full_domain.txt)
		bash ~/.acme.sh/acme.sh --revoke -d ${full_domain} --ecc
		bash ~/.acme.sh/acme.sh --remove -d ${full_domain} --ecc
		rm -rf ~/.acme.sh
		service v2ray stop
		update-rc.d -f v2ray remove
		systemctl disable v2ray.service
		rm -rf /etc/init.d/v2ray
		rm -rf /lib/systemd/system/v2ray.service
		rm -rf /etc/systemd/system/v2ray.service
		rm -rf /etc/v2ray
		rm -rf /usr/bin/v2ray
		rm -rf /var/log/v2ray
		if [[ $? -eq 0 ]];then
			clear
			echo "V2Ray卸载成功！"
		else
			clear
			echo "V2Ray卸载失败！"
		fi
		service caddy stop
		update-rc.d -f caddy remove
		rm -rf /etc/init.d/caddy
		rm -rf /root/.caddy
		rm -rf /usr/local/caddy
		if [[ $? -eq 0 ]];then
			clear
			echo "Caddy卸载成功！"
		else
			clear
			echo "Caddy卸载失败！"
		fi
		return 0
	fi
}

function main(){
	rootness
	checkos
	cd /root/
	echo_install_type
	set_v2ray_config
	cd /root/
}

main