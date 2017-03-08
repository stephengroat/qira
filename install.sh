#!/bin/bash -e

# default is just pip, but on things like arch where python 3 is default, it's pip2
if [ $(which pip2) ]; then
    PIP="pip2"
else
    PIP="pip"
fi

unamestr=$(uname)
arch=$(uname -p)

if [[ "$unamestr" == 'Linux' ]]; then
  # we need pip to install python stuff
  # build for building qiradb and stuff for flask like gevent
  if [ $(which apt-get) ]; then
    git clone https://github.com/aquynh/capstone.git -b 3.0.4
    cd capstone && ./make.sh && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:`pwd` && cd ..

  elif [ $(which pacman) ]; then
    echo "installing pip"
    sudo pacman -S --needed --noconfirm base-devel python2-pip python2-virtualenv
    PIP="pip2"
  elif [ $(which dnf) ]; then
    sudo dnf install -y python-pip python-devel gcc gcc-c++ python-virtualenv glib2-devel
    PIP="pip2"
  elif [ $(which yum) ]; then
    sudo yum install -y python-pip python-devel gcc gcc-c++ python-virtualenv glib2-devel
  fi

  if [ $(tracers/qemu/qira-i386 > /dev/null; echo $?) == 1 ]; then
    echo "QIRA QEMU appears to run okay"
  else
    echo "building QEMU"
    cd tracers
    ./qemu_build.sh
    cd ../
  fi
elif [[ "$unamestr" == 'Darwin' ]]; then
  if [ $(which brew) ]; then
    echo "Installing OS X dependencies"
    cd tracers
    ./pin_build.sh
    cd ../
  else
    echo "build script only supports Homebrew"
  fi
fi

echo "installing pip packages"

if [ $(which virtualenv2) ]; then
    VIRTUALENV="virtualenv2"
else
    VIRTUALENV="virtualenv"
fi

$VIRTUALENV venv
source venv/bin/activate
$PIP install --upgrade -r requirements.txt

echo "making symlink"
sudo ln -sf $(pwd)/qira /usr/local/bin/qira

echo "***************************************"
echo "  Thanks for installing QIRA"
echo "  Check out README for more info"
echo "  Or just dive in with 'qira /bin/ls'"
echo "  And point Chrome to localhost:3002"
echo "    ~geohot"
