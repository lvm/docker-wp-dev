# Docker container for WordPress development (not production)

The idea of this container is to have a quick/disposable WordPress sandbox to work with.  

This setup is a *follow up/fork* of the works of @eugeneware and @jbfink. The main differences are:  

* Uses Debian Jessie instead of Ubuntu
* Uses `runit` for the init-scripts
* The `nginx` conf is slightly different
* Has **hardcoded** passwords

Again, I **do not** recommend this setup for production (as it is), although can be used as the base for a more appropiate setup.  

## How to ...?

Install:

```bash
$ git clone https://github.com/lvm/docker-wp-dev
$ cd docker-wp-dev
$ docker build -t wpdev .
```

Run:

```bash
$ docker run -p 80:80 -v $HOME/dev/wpdev/themes:/usr/share/nginx/wordpress/wp-content/themes/ wpdev
```

Then you can simply point your browser to `http://127.0.0.1:80` and you're ready to go.

## License

```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2016 Mauro <mauro@sdf.org>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```
