# Vagrant / Docker Beginning Point

This repository is a very simple starting point for using a Docker container as a VM for
Vagrant projects.  

This sets up a Fedora image with some changes to the system so that PID 1 will
be a psuedo systemd.  This will let the container run and act like a VM that
can be used with Vagrant.

This example has a Dockerfile that will set up the image with nginx.  To use in 
your project you would most likely fill out the Dockerfile to creat an image with
the web server, php, node, etc. set up ready for recipes to be run.

_NOTE: this is using the Fedora image because Fedora provides an image that will
run on either x86 or M1 mac architectures. Also looking forward to Amazon Linux 2022
which will remove CentOS and RHEL and will be based directly on Fedora._

## How to use

This repo is a complete setup so that it can be used as is to see the parts in motion. 
In order to use, clone to a working directory and run 

```$ vagrant up```

because the Dockerfile and Vagrantfile ore in the same directory, vagrant will take
care of downloading and creating the image. This also means that changes made in the
Dockerfile will be put into use by halting and rerunning up.

Once you have call up you will be able to see the container running with:

```$ docker ps```

and you can log into the VM with:

```$vagrant ssh```

There is also a webserver running at `http://localhost:8080`

**NOTE: That there is something still to fix. The first time you run up you will need 
to: `vagrant halt && vagrant up` For some reason httpd is not starting during the first 
startup.**
