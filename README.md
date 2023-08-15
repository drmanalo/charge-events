## Brew Installation

Having brew installed will simplify the process of installing all the tooling.

Run this command to install `brew` on your machine. This works for Linux, Max and Windows Subsystem.
The script explains what it will do and then pauses before it does it.
```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

###	Windows Machines
These are extra things you will most likely need to do after installing brew

Run these three commands in your terminal to add Homebrew to your PATH:
Replace <name> with your username.
```
$ echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/<name>/.profile
$ echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/<name>/.profile
$ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### 	Linux Machines
```
$ sudo apt-get install build-essential
$ brew install gcc
```

## Install Tooling and Dependencies

If you are running a Mac machine with `brew`, run these commands:
```
$ make dev-brew  or  make dev-brew-arm64
$ make dev-docker
$ make dev-gotooling
```

If you are running a Linux machine with `brew`, run these commands:
```
$ make dev-brew-common
$ make dev-docker
$ make dev-gotooling
```
Then follow below instructions for Telepresence.

If you are a Windows user with `brew`, run these commands:
```
$ make dev-brew-common
$ make dev-docker
$ make dev-gotooling
```
Then follow below instructions for Telepresence.

## Installing Telepresence

### Windows Users ONLY - Install Telepresence

Unfortunately you can't use `brew` to install telepresence because you will receive a bad binary. Please follow these instruction.
```
$ sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence
$ sudo chmod a+x /usr/local/bin/telepresence
```
Restart your wsl environment.

### Linux Users ONLY - Install Telepresence

Visit https://www.telepresence.io/docs/latest/quick-start/?os=gnu-linux


### M1 Mac Users ONLY - Uninstall Telepresence If Installed Intel Version
```
$ sudo rm -rf /Library/Developer/CommandLineTools
$ sudo xcode-select --install
```   
Then install it with `brew` (arm64)