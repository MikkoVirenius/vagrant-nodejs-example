# Install

* Clone https://github.com/MikkoVirenius/vagrant-nodejs-example.git

* Run:

```
vagrant up
```

* Access box

```
vagrant ssh
```

* Edit mongod.conf -file:

```
sudo nano /etc/mongod.conf
```

* Comment bind_ip = 127.0.0.1 -> # bind_ip = 127.0.0.1
* Save file
* Run:
```
sudo service mongod restart
```

* Define local domains 
Define your local domains in /etc/hosts -file. Example: 192.168.33.99 somehub.dev

# Create first app

* Install express generator
```
sudo npm install express-generator -g
```
* Go to the apps directory and generate app skeleton
```
express testapp
```


