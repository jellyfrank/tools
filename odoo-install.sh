
echo "开始安装odoo"
read -r -p  "请输入要安装的版本:" version

echo "开始安装odoo服务.."
wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
echo "deb http://nightly.odoo.com/$version/nightly/deb/ ./" >> /etc/apt/sources.list
echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
apt-get update && apt-get -y install libssl1.1 xfonts-75dpi odoo

echo "开始安装wkhtmptopdf.."
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb
dpkg -i wkhtmltox_0.12.5-1.focal_amd64.deb

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
