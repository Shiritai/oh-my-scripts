# Developing custom scripts

Please put you setup scripts like:

* `setup.sh` will be called when building docker image.
* `start.sh` will be called when the container starts to run.
* You can also put other `dotfile` and `assets` in the plugin directory.

All of the files/directories listed above are optional!

```txt
dev
|--- some-plugin1
|  |--- assets
|  |--- dotfile
|  |--- setup.sh
|  |--- start.sh
|  
|--- some-plugin2
|  |--- assets
|  |--- dotfile
|  |--- setup.sh
|  |--- start.sh
...
```
