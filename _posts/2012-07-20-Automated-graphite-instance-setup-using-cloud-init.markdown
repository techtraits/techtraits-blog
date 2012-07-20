--- 
layout: post
title: Automated graphite server setup using cloud init
date: 2012-07-20 17:05:41
author: usman
categories: 
- Automation
tags:
- Graphite
- Cloud Init
- AWS
- Monitoring
- Automation

---

In my current project(s) we make extensive use of graphite to monitor, well everything really. As part of setting up monitoring I wanted to automate the process of setting up a graphite node and cluster. To do this I used a handy amazon feature called cloud-init. Cloud init allows you to specify a bash script to be run when the node comes up. This is a simple but very powerful feature as we can keep a few configuration scripts and bring up identical instances at will. This article shows a script that can be used to bring up a single node graphite server. 


### Cloud Init ###

For the purposes of this article I am assuming you are familiar with the EC2 Console and with launching instances using the "Classic Wizard" you will be taken to the menu shown below. Here you can specify the benign sounding User Data value either as text of as a file. The user data field however is not some arbitrary metadata but instead the it can contain a cloud init initialization script. The script specified here is run automatically on instance launch. From the menu above select the As File option and upload the graphite initialization script and you are done a fully configured graphite instance will be up shortly. You maybe thinking "I don't have a graphite initialization script" fear not, read on and we shall create one.

![User Data](/assets/images/user_data.png)

{% highlight bash %}
#!/bin/bash -v
GRAPHITE_INSTALL=/root/graphite-install

function installPackage() {
        echo "Installing $1";
        cd $GRAPHITE_INSTALL/$1
        python setup.py install
}

yum -y --enablerepo=epel install python-zope-interface python-memcached python-ldap gcc python26-devel mod_python mod_wsgi django django-tagging pycairo

mkdir $GRAPHITE_INSTALL
cd $GRAPHITE_INSTALL

wget https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz
wget https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz
wget https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz
wget https://launchpad.net/graphite/0.9/0.9.10/+download/check-dependencies.py
wget http://pypi.python.org/packages/source/T/Twisted/Twisted-12.1.0.tar.bz2

tar xfj Twisted-12.1.0.tar.bz2
tar xfvz carbon-0.9.10.tar.gz
tar xfvz whisper-0.9.10.tar.gz
tar xfvz graphite-web-0.9.10.tar.gz

installPackage whisper-0.9.10
installPackage Twisted-12.1.0
installPackage carbon-0.9.10
installPackage graphite-web-0.9.10

cd /opt/graphite/conf
cp storage-schemas.conf.example storage-schemas.conf

#install apache mod
cp /opt/graphite/examples/example-graphite-vhost.conf /etc/httpd/conf.d/
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
mkdir -p /etc/httpd/wsgi

#configure graphite webapp
cd /opt/graphite/webapp/graphite
ln -s /usr/lib/python2.6/site-packages/django/ django
python2.6 manage.py syncdb --noinput
cp local_settings.py.example local_settings.py


chown -R apache:apache /opt/graphite/storage
python /opt/graphite/bin/carbon-cache.py stop
python /opt/graphite/bin/carbon-cache.py start
service httpd restart

{% endhighlight %}
