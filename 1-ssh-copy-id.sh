#!/bin/bash
#ssh免密登录shell脚本
#配置免密登录的所有机子都要运行该脚本
 
#修改/etc/ssh/sshd_config配置文件
#sed -i 's/被替换的内容/替换成的内容/'  /配置文件地址
#sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
#cat >> /etc/ssh/sshd_config <<EOF
#RSAAuthentication yes
#EOF
 
ssh-keygen -t rsa   #生成秘钥（按enter键3次即可生成）
for IP in `cat allnode-pubip`;
do

Nodes="$IP"
PASSWORD="6yhn&U*I"   #需要配置的主机登录密码

auto_ssh_copy_id(){
        expect -c "set timeout -1;
        spawn ssh-copy-id $IP;                                
        expect {
                *(yes/no)* {send -- yes\r;exp_continue;}
                *password:* {send -- $2\r;exp_continue;}  
                eof   {exit 0;} 
        }";
}
 
ssh_copy_id_to_all(){
        for Node in $Nodes #遍历要发送到各个主机的ip
        do
                auto_ssh_copy_id $Node $PASSWORD
        done
}
ssh_copy_id_to_all
done
