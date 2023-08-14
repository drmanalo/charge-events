## Install Tooling and Dependencies

If you are running a mac machine with brew, run these commands:
```
$ make dev-brew  or  make dev-brew-arm64
$ make dev-docker
$ make dev-gotooling
```

If you are running a linux machine with brew, run these commands:
```
$ make dev-brew-common
$ make dev-docker
$ make dev-gotooling
```
Then follow instructions above for Telepresence.

If you are a windows user with brew, run these commands:
```
$ make dev-brew-common
$ make dev-docker
$ make dev-gotooling
```
Then follow instructions above for Telepresence.

## Installing Telepresence

### Windows Users ONLY - Install Telepresence

Unfortunately you can't use brew to install telepresence because you will receive a bad binary. Please follow these instruction.

	$ sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence
	$ sudo chmod a+x /usr/local/bin/telepresence

 	Restart your wsl environment.

### Linux Users ONLY - Install Telepresence

   Visit https://www.telepresence.io/docs/latest/quick-start/?os=gnu-linux


### M1 Mac Users ONLY - Uninstall Telepresence If Installed Intel Version

   $ sudo rm -rf /Library/Developer/CommandLineTools
   $ sudo xcode-select --install
   Then install it with brew (arm64)