
echo "开始安装odoo"
echo -p -n  "请输入要安装的版本:" version

echo "开始安装odoo服务.."
wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
echo "deb http://nightly.odoocdn.com/$version/nightly/deb/ ./" >> /etc/apt/sources.list
apt-get update && apt-get -y install odoo

echo "开始安装wkhtmptopdf.."
wget -O - https://raw.githubusercontent.com/jellyhappy/tools/master/wkhtml.sh | bash
echo "开始安装中文字体.."
apt-get -y install ttf-wqy-microhei ttf-wqy-zenhei

read -r -p "是否要安装Nignx[Y/N]:" ng 
case $ng in 
    [yY][eE][sS]|[yY])
        apt-get -y install nginx
        ;;
    [nN][oO]|[nN])
        ;;
    *)
        ;;
esac

echo "重启odoo服务..."
service odoo restart

echo "验证安装.."
systemctl status odoo

echo "安装完成"
