# System Bootstrap

A collection of shell files to automatically install Operating System with preconfigured settings.

Note: currently there's only support for ArchLinux and Gentoo.

## ArchLinux

1. Edit `ArchLinux/config.yml`
2. Update to latest ArchLinux version with `rake update`
3. Compile with `rake compile`
4. Create ArchLinux installation flash or CD, add generated `ArchLinux/bootstrap.sh` or upload it somewhere
5. On target system, boot ArchLinux installation medium, create paritions, mount them and execute `bootstrap.sh install`
6. Wait till system is installed.
7. Enjoy!

(you can also install it from existing system using `bootstrap_existing.sh`)

## Gentoo

1. Edit `Gentoo/config.yml`
2. Update to latest Gentoo version with `rake update`
3. Compile with `rake compile`
4. Create Gentoo installation flash or CD, add generated `Gentoo/bootstrap.sh` or upload it somewhere
5. On target system, boot Gentoo installation medium, create paritions, mount them and execute `bootstrap.sh install`
6. Wait till system is installed.
7. Enjoy!

## Unlicense

![Copyright-Free](http://unlicense.org/pd-icon.png)

All text, documentation, code and files in this repository are in public domain (including this text, README).
It means you can copy, modify, distribute and include in your own work/code, even for commercial purposes, all without asking permission.

[About Unlicense](http://unlicense.org/)

## Contributing

Feel free to improve anything.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


**Warning**: By sending pull request to this repository you dedicate any and all copyright interest in pull request (code files and all other) to the public domain. (files will be in public domain even if pull request doesn't get merged)

Also before sending pull request you acknowledge that you own all copyrights or have authorization to dedicate them to public domain.

If you don't want to dedicate code to public domain or if you're not allowed to (eg. you don't own required copyrights) then DON'T send pull request.

