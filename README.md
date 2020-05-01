### OVERVIEW:

Included in this repository are two Perl scripts which demonstrate a package dependency handling application.

### SETUP:

These scripts and the libraries they use are written in Perl and there are a few package reuirements including: 

```
  IO::All
  JSON
  Method::Signatures::Simple
  Mouse
```

For convenience sake, I have included a Dockerfile that will allow you to install these requirements and my code and run the scripts by doing:

```
  git git@gitlab.com:simiomalo/packager.git
  cd packager
  docker build -t mpalma-packager .
  docker run -it mpalma-packager /bin/bash
```

The second docker command gives you a bash shell in which you can execute the scripts described below.

### USAGE: 

This is an example of a package dependency handling application with the following options:
```
Command                        Description

DEPEND item1 item2 [item3]     Package item1 depends on package item2 (and item3 or any additional packages).
INSTALL item1                  Installs item1 and any other packages required by item1.
REMOVE item1                   Removes item1 and, if possible, packages required by item1.
LIST                           Lists the names of all currently installed packages
END                            Marks the end of input, when used in a line by itself.
```

These are the two scripts which can be executed:

**package-handler** - allows for execution of a single command from the above list

#### Example:
```
  ./package-handler DEPEND bb aa
  ./package-handler INSTALL aa
  ./package-handler LIST
```

**automated-package-handler** - accepts commands from a newline seperated list of commands
I have copied a set of example commands into a file within the same directory called "input.txt".

#### Example:
```
  ./automated-package-handler input.txt
```

