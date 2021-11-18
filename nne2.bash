# E02
#  3つのネームスペースns1,router,ns2を作成し、それぞれに仮想イーサネットインタ
#  フェースとIPアドレスを追加する。ネットワークセグメントは2つあり、routerを介
#  してつながっている。
#  pingコマンドでns1からn2へのネットワークの疎通を確認する。
#  ns1とn2にはデフォルトゲートウェイとしてルーターのIPアドレスを設定する。
#  routerはn1,n2のセグメントに直接接続しているのでルーティングテーブルがなくても
#  動作する。

#状態(status): 
# 0:初期状態
# 1:ネットワークネームスペースns1,router,ns2を作成した状態
# 2:仮想ネットワークインタフェースns1-veth0,gw-veth0,ns2-veth0,gw-veth1を作成した状態
# 3:仮想ネットワークインタフェースをns1,router,ns2に配置した状態
# 4:仮想ネットワークインタフェースにIPアドレスを設定した状態
# 5:仮想ネットワークインタフェースを有効にした状態
# 6:仮想ネットワークインタフェースにデフォルトゲートウェイを設定した状態
# 7:Linuxカーネルの設定でルーターの機能を有効にした状態
stat=0	

function fn_fig1() {
cat << END
#
#  ns1              
# +----------------+ 
# |                | 
# |                |
# |                |     
# +----------------+     
#                             router             
#                            +-------------------+     
#                            |                   |     
#                            |                   |     
#                            |                   |     
#                            |                   |     
#                            |                   |     
#                            |                   |
#                            |                   |     
#                            +-------------------+     
#                                                           ns2
#                                                          +-----------------+ 
#                                                          |                 |
#                                                          |                 |
#                                                          |                 |
#                                                          +-----------------+
#                                                      

END
}

function fn_exp1() {
cat << END
# ネットワークネームスペースを3つ作成します。ns1とrouterとns2です。これらは
# ホストOSのLinuxからはネットワーク的に独立しています。ここではns1とrouterと
# ns2を仮想PCとして扱います。
# 
# sudo ip netns add ns1
# sudo ip netns add router
# sudo ip netns add ns2
#
#「sudo 管理者コマンド」は、管理者権限が無いと実行できないコマンドを特別に許可さ
# れたユーザーが実行できるようにするためのコマンドです。ipコマンドの一部の機能を
# 実行するには管理者権限が必要です。
#
#「ip netns」コマンドはネットワークネームスペース関連の設定をするコマンドです。
#「ip netns add ネットワークネームスペース名」は、ネットワークネームスペースを
# 作成します。作成したネットワークネームスペースは「ip netns list」コマンドで
# 確認できます(メニュー 6.ネットワークネームスペースを確認)。

END
}

function fn_fig2() {
cat << END
#
#  ns1              
# +----------------+     
# |                | ns1-veth0 
# |                |    o 
# |                |    |
# +----------------+    |
#                       |     router             
#                       |    +-------------------+ 
#                       |    |                   | 
#                       o    |                   | 
#                   gw-veth0 |                   |
#                            |                   | 
#                            |                   | 
#                            |                   |  gw-veth1
#                            |                   |    o
#                            +-------------------+    |
#                                                     |     ns2
#                                                     |    +-----------------+ 
#                                                     |    |                 |
#                                                     o    |                 |
#                                                ns2-veth0 |                 |
#                                                          |                 |
#                                                          +-----------------+
#                                                      

END
}

function fn_exp2() {
cat << END
# 仮想ネットワークインタフェース(NIC)を作成します。ns1-veth0とgw-veth0と
# ns2-veth0とgw-veth1の4つが仮想ネットワークインタフェースです。イメージと
# しては両端に仮想NICが接続されたネットワークケーブルを2本作成した状態です。
# ここでは仮想ネットワークインタフェースはまだネットワークネームスペースに
# 配置されていません。
#
# sudo ip link add ns1-veth0 type veth peer name gw-veth0
# sudo ip link add ns2-veth0 type veth peer name gw-veth1
#
# 「ip link」コマンドは、ネットワークインタフェース関連の設定をするコマンドです。
#   add NIC名       :仮想ネットワークインタフェース名を追加します。
#   type タイプ     :タイプのvethは仮想イーサネット(virtual ethernet)を指定します。
#   peer name NIC名 :ペアとなる仮想ネットワークインタフェース名を指定します。

END
}

function fn_fig3() {
cat << END
#
#  ns1              
# +----------------+     
# |        DOWN    |     
# |      ns1-veth0 o----+
# |                |    |
# +----------------+    |
#                       |     router            
#                       |    +-------------------+     
#                       |    |   DOWN            |     
#                       +----o gw-veth0          |     
#                            |                   |     
#                            |                   |     
#                            |            DOWN   |     
#                            |          gw-veth1 o----+
#                            |                   |    |
#                            +-------------------+    |
#                                                     |     ns2
#                                                     |    +-----------------+ 
#                                                     |    |   DOWN          |
#                                                     +----o ns2-veth0       |
#                                                          |                 | 
#                                                          +-----------------+
#                                                      

END
}

function fn_exp3() {
cat << END
# 仮想ネットワークインタフェースをネットワークネームスペースに配置します。
#
# sudo ip link set ns1-veth0 netns ns1
# sudo ip link set gw-veth0  netns router
# sudo ip link set gw-veth1  netns router
# sudo ip link set ns2-veth0 netns ns2
#
# これで仮想ネットワーク上においてns1とrouterとn2がケーブルで接続されました。
# しかし、まだ仮想ネットワークインタフェースは無効(DOWN)な状態です。
# よってまだ通信はできません。
#
# 「ip link set 仮想NIC名 netns ネットワークネームスペース名 」コマンドは、
# は仮想ネットワークインタフェースをネットワークネームスペースに配置します。 

END
}

function fn_fig4() {
cat << END
#
#  ns1               [192.0.2.0/24]
# +----------------+    |
# |        DOWN    |    |
# |      ns1-veth0 O----+
# |   192.0.2.1/24 |    |
# +----------------+    |
#                       |     router               [198.51.100.0/24]
#                       |    +-------------------+    |
#                       |    |   DOWN            |    |
#                       +----O gw-veth0          |    |
#                       |    | 192.0.2.254/24    |    |
#                       |    |                   |    |
#                       |    |            DOWN   |    |
#                       |    |          gw-veth1 O----+
#                       |    | 198.51.100.254/24 |    |
#                       |    +-------------------+    |
#                                                     |     ns2
#                                                     |    +-----------------+ 
#                                                     |    |   DOWN          |
#                                                     +----O ns2-veth0       |
#                                                     |    | 198.51.100.1/24 |
#                                                     |    +-----------------+
#                                                      

END
}

function fn_exp4() {
cat << END
# 4つの仮想ネットワークインタフェースにIPアドレスを設定する。
#
# sudo ip netns exec ns1    ip address add 192.0.2.1/24      dev ns1-veth0
# sudo ip netns exec router ip address add 192.0.2.254/24    dev gw-veth0
# sudo ip netns exec router ip address add 198.51.100.254/24 dev gw-veth1
# sudo ip netns exec ns2    ip address add 198.51.100.1/24   dev ns2-veth0
#
# 「ip netns exec」コマンドはネットワークネームスペース内でコマンドを実行する
# ためのコマンドです。ns1とns2はネットワーク的に独立しているために、ns1内に
# あるns1-veth0にIPアドレスを設定するためには、ns1の内部で ip addressコマンド
# を実行する必要があります。
# 「ip address」コマンドはIPアドレスを表示したり、IPアドレスを設定したりします。
# 「ip address add IPアドレス dev ネットワークインタフェース」は、IPアドレスを
# ネットワークインタフェースに設定します。 
# まだ仮想ネットワークインタフェースは無効(DOWN)な状態です。
# 

END
}

function fn_fig5() {
cat << END

#
#  ns1               [192.0.2.0/24]
# +----------------+    |
# |         UP     |    |
# |      ns1-veth0 O----+
# |   192.0.2.1/24 |    |
# +----------------+    |
#                       |     router               [198.51.100.0/24]
#                       |    +-------------------+    |
#                       |    |    UP             |    |
#                       +----O gw-veth0          |    |
#                       |    | 192.0.2.254/24    |    |
#                       |    |                   |    |
#                       |    |             UP    |    |
#                       |    |          gw-veth1 O----+
#                       |    | 198.51.100.254/24 |    |
#                       |    +-------------------+    |
#                                                     |     ns2
#                                                     |    +-----------------+ 
#                                                     |    |    UP           |
#                                                     +----O ns2-veth0       |
#                                                     |    | 198.51.100.1/24 |
#                                                     |    +-----------------+
#                                                      

END
}

function fn_exp5() {
cat << END
# 仮想ネットワークインタフェースを有効化(UP)します。
#
# sudo ip netns exec ns1    ip link set ns1-veth0 up
# sudo ip netns exec router ip link set gw-veth0  up
# sudo ip netns exec router ip link set gw-veth1  up
# sudo ip netns exec ns2    ip link set ns2-veth0 up
#
# 「ip link set <device> up」コマンドはネットワークインタフェースを有効化 
# (UP)します。
#

END
}

function fn_fig6() {
cat << END

#
#  ns1               [192.0.2.0/24]
# +----------------+    |
# |         UP     |    |
# |      ns1-veth0 O----+
# |   192.0.2.1/24 |    |
# |                |    | 
# | GW 192.0.2.254 |    |
# +----------------+    |
#                       |     router               [198.51.100.0/24]
#                       |    +-------------------+    |
#                       |    |    UP             |    |
#                       +----O gw-veth0          |    |
#                       |    | 192.0.2.254/24    |    |
#                       |    |                   |    |
#                       |    |             UP    |    |
#                       |    |          gw-veth1 O----+
#                       |    | 198.51.100.254/24 |    |
#                       |    +-------------------+    |
#                                                     |     ns2
#                                                     |    +------------------+ 
#                                                     |    |    UP            |
#                                                     +----O ns2-veth0        |
#                                                     |    | 198.51.100.1/24  |
#                                                     |    |                  |
#                                                     |    | GW 198.51.100.254|
#                                                     |    +------------------+ 
#                                                      

END
}

function fn_exp6() {
cat << END
# ns1とns2にデフォルトゲートウェイを設定する
#
# sudo ip netns exec ns1 ip route add default via 192.0.2.254
# sudo ip netns exec ns2 ip route add default via 198.51.100.254
#
# 「ip route add default via ipアドレス」コマンドはネットワークインタフェースに
# デフォルトゲートウェイを設定します。
#

END
}

function fn_fig7() {
cat << END

#
#  ns1               [192.0.2.0/24]
# +----------------+    |
# |         UP     |    |
# |      ns1-veth0 O----+
# |   192.0.2.1/24 |    |
# |                |    | 
# | GW 192.0.2.254 |    |
# +----------------+    |
#                       |     router               [198.51.100.0/24]
#                       |   +---------------------+   |
#                       |   |    UP               |   |
#                       +---O gw-veth0            |   |
#                       |   | 192.0.2.254/24      |   |
#                       |   |                     |   |
#                       |   |             UP      |   |
#                       |   |          gw-veth1   O---+
#                       |   | 198.51.100.254/24   |   |
#                       |   |                     |   |
#                       |   |net.ipv4.ip_forward=1|   |   
#                       |   +---------------------+   |     ns2
#                                                     |    +------------------+ 
#                                                     |    |    UP            |
#                                                     +----O ns2-veth0        |
#                                                     |    | 198.51.100.1/24  |
#                                                     |    |                  |
#                                                     |    | GW 198.51.100.254|
#                                                     |    +------------------+ 
#                                                      

END
}

function fn_exp7() {
cat << END
# Linuxカーネルの設定でルーターの機能を有効にする
#
# sudo ip netns exec router sysctl net.ipv4.ip_forward=1

END
}

function fn_fig() {
    echo ''
	case $stat in
		0) echo 'ネットワークネームスペースがありません' ;;
		1) echo '状態(1)'
           fn_fig1 
           ;;
		2) echo '状態(2)'
           fn_fig2
           ;;
		3) echo '状態(3)'
           fn_fig3
           ;;
		4) echo '状態(4)'
           fn_fig4
           ;;
		5) echo '状態(5)'
           fn_fig5
           ;;
		6) echo '状態(6)'
           fn_fig6
           ;;
		7) echo '状態(7)'
           fn_fig7
           ;;
	esac
}

function fn_hitAnyKey(){
	echo "> hit any key!"
	read keyin
}

function fn_menu() {
echo '===メニュー===================================='
PS3='番号を入力>'

menu_list='
ネットワークネームスペースを作成
仮想ネットワークインタフェースを作成
仮想ネットワークインタフェースを配置
仮想ネットワークインタフェースにIPアドレスを設定
仮想ネットワークインタフェースを有効化
ネットワークネームスペースにデフォルトゲートウェイを設定
Linuxカーネルの設定でルーターの機能を有効化
ネットワークネームスペースを確認
仮想インタフェースを確認
ルーティング(デフォルトゲートウェイ)を確認
pingを実行
状態を表示
ネットワークネームスペースをすべて削除
終了'

select item in $menu_list
do
	echo ""
	echo "${REPLY}) ${item}します"
	case $REPLY in
	1) #ネットワークネームスペースを作成する
		echo sudo ip netns add ns1
		echo sudo ip netns add router
		echo sudo ip netns add ns2
        echo ''
		sudo ip netns add ns1
		sudo ip netns add router
		sudo ip netns add ns2
		stat=1
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp1
		;;
	2) #仮想ネットワークインタフェースを作成する
		echo sudo ip link add ns1-veth0 type veth peer name gw-veth0
		echo sudo ip link add ns2-veth0 type veth peer name gw-veth1
        echo ''
		sudo ip link add ns1-veth0 type veth peer name gw-veth0
		sudo ip link add ns2-veth0 type veth peer name gw-veth1
		stat=2
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp2
		;;
	3) #仮想ネットワークインタフェースを配置する
		echo sudo ip link set ns1-veth0 netns ns1
		echo sudo ip link set gw-veth0  netns router
		echo sudo ip link set gw-veth1  netns router
		echo sudo ip link set ns2-veth0 netns ns2
        echo ''
		sudo ip link set ns1-veth0 netns ns1
		sudo ip link set gw-veth0  netns router
		sudo ip link set gw-veth1  netns router
		sudo ip link set ns2-veth0 netns ns2
		stat=3
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp3
		;;
	4) #仮想ネットワークインタフェースにIPアドレスを設定する
		echo sudo ip netns exec ns1    ip address add 192.0.2.1/24      dev ns1-veth0
		echo sudo ip netns exec router ip address add 192.0.2.254/24    dev gw-veth0
		echo sudo ip netns exec router ip address add 198.51.100.254/24 dev gw-veth1
		echo sudo ip netns exec ns2    ip address add 198.51.100.1/24   dev ns2-veth0
        echo ''
		sudo ip netns exec ns1    ip address add 192.0.2.1/24      dev ns1-veth0
		sudo ip netns exec router ip address add 192.0.2.254/24    dev gw-veth0
		sudo ip netns exec router ip address add 198.51.100.254/24 dev gw-veth1
		sudo ip netns exec ns2    ip address add 198.51.100.1/24   dev ns2-veth0
		stat=4
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp4
		;;
	5) #仮想ネットワークインタフェースを有効にする
		echo sudo ip netns exec ns1    ip link set ns1-veth0 up
		echo sudo ip netns exec router ip link set gw-veth0  up
		echo sudo ip netns exec router ip link set gw-veth1  up
		echo sudo ip netns exec ns2    ip link set ns2-veth0 up
        echo ''
		sudo ip netns exec ns1    ip link set ns1-veth0 up
		sudo ip netns exec router ip link set gw-veth0  up
		sudo ip netns exec router ip link set gw-veth1  up
		sudo ip netns exec ns2    ip link set ns2-veth0 up
		stat=5
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp5
		;;
	6) #ns1,ns2にデフォルトゲートウェイを設定する
		echo sudo ip netns exec ns1 ip route add default via 192.0.2.254
		echo sudo ip netns exec ns2 ip route add default via 198.51.100.254
        echo ''
		sudo ip netns exec ns1 ip route add default via 192.0.2.254
		sudo ip netns exec ns2 ip route add default via 198.51.100.254
		stat=6
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp6
		;;
	7) #Linuxカーネルの設定でルーターの機能を有効にする
		echo sudo ip netns exec router sysctl net.ipv4.ip_forward=1
        echo ''
		sudo ip netns exec router sysctl net.ipv4.ip_forward=1
		stat=7
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp7
		;;
	8) #ネットワークネームスペースを確認する
		echo ip netns list
        echo ''
		ip netns list
		;;
	9) #仮想ネットワークインタフェースを確認する
		echo '----------------------------------------------------'
		echo sudo ip netns exec ns1 ip link list
        echo ''
		sudo ip netns exec ns1 ip link list
        echo '----------------------------------------------------'
		echo sudo ip netns exec router ip link list
        echo ''
		sudo ip netns exec router ip link list
        echo '----------------------------------------------------'
		echo sudo ip netns exec ns2 ip link list
        echo ''
		sudo ip netns exec ns2 ip link list
        echo '----------------------------------------------------'
		;;
	10) #ns1,ns2のルーティング(デフォルトルート)を確認する
		echo '----------------------------------------------------'
		echo sudo ip netns exec ns1 route -n
		echo ''
		sudo ip netns exec ns1 route -n
		echo '----------------------------------------------------'
		echo sudo ip netns exec ns2 route -n
		echo ''
		sudo ip netns exec ns2 route -n
		echo '----------------------------------------------------'
		;; 
	11) #pingを実行(n1->n2)する
		echo '----------------------------------------------------'
		echo 'ns1 から ns2 へpingを実行'
		echo sudo ip netns exec ns1 ping -c 5 198.51.100.1 -I ns1-veth0
        echo ''
		sudo ip netns exec ns1 ping -c 5 198.51.100.1 -I ns1-veth0
		sleep 2

	    #pingを実行(n2->n1)する
		echo ''
		echo '----------------------------------------------------'
		echo 'ns2 から ns1 へpingを実行'
		echo sudo ip netns exec ns2 ping -c 5 192.0.2.1 -I ns2-veth0
        echo ''
		sudo ip netns exec ns2 ping -c 5 192.0.2.1 -I ns2-veth0
		echo '----------------------------------------------------'
		;;
	12) #状態を表示する
		if [  -e ./.namespace_tmp ]
		then
			stat=$(cat ./.namespace_tmp)
		fi
		fn_fig
		;;
	13) #ネットワークネームスペースをすべて削除する
		echo sudo ip -all netns delete
        echo ''
		sudo ip -all netns delete
		stat=0
		rm ./.namespace_tmp
		;;
	14) #終了する
		echo "bye bye!"
		exit
		;;
	*)
		echo "番号を入力してください"
	esac

	echo ""
	echo "Enterキーを押してください。"
    read n

	#sleep 2
	fn_menu
done

}

#### START BASH SCRIPT #########################################################

echo '###'
echo '### Network Name Spaceを使った仮想ネットワークの作成'
echo '###'

echo ''
echo 'これから作成するネットワーク'
fn_fig5
sleep 3

echo ""
echo "Enterキーを押してください。"
read n

fn_menu
fn_hitAnyKey


# vim: number tabstop=4 softtabstop=4 shiftwidth=4 textwidth=0 filetype=text:
