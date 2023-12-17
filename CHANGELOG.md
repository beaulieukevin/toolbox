# 1.4.0 (December 17, 2023)

## Feature
* Update Git to version 2.43.0.1 ([#28](https://github.com/devwith-kev/toolbox/issues/28))

## Bug fix
* Correct function Edit-ExpandableEnvironmentMultipleValueData to manage non expanded value ([#20](https://github.com/devwith-kev/toolbox/issues/20))
* Only ask to sign out when PATH values are updated ([#21](https://github.com/devwith-kev/toolbox/issues/21))
* Correct analytical functions API to lock analytical file while being updated by multiple users ([#27](https://github.com/devwith-kev/toolbox/issues/27))

# 1.3.2 (November 26, 2023)

* Change Toolbox resource name

# 1.3.1 (November 26, 2023)

* Update README.md to simplify the definition of Toolbox
* Update resources for Toolbox re branding

# 1.3.0 (November 22, 2023)

* Set Git init to init using main branch instead of master which was causing the syncing with remote to fail.
* Correct no proxy configuration setup which was failing if no value was passed in the `config.json`

# 1.2.2 (November 21, 2023)

* Update Edit-ExpandableEnvironmentValueData function to allow single or multiple values in registry

# 1.2.1 (November 20, 2023)

* Added logic to check expanded value with the added value in Edit-EnvironmentValueData
* Handle sign out if required

# 1.2.0 (November 20, 2023)

* Update PATH environment variables to be expandable to avoid unexpected behavior from machine OS.

# 1.1.17 (November 20, 2023)

* Add function to make expandable env var generic

# 1.1.16 (November 20, 2023)

* Add function to update correctly PATH environment variable using REG_EXPAND_SZ ([#5](https://github.com/devwith-kev/toolbox/issues/5))

# 1.1.15 (November 20, 2023)

* Add organization configuration version in the analytics ([#14](https://github.com/devwith-kev/toolbox/issues/14))

# 1.1.14 (November 20, 2023)

* Small refactoring of environment variables usage

# 1.1.13 (November 20, 2023)

* Removed ResetToolboxRepository within `toolbox.ps1`file which was leading to bad user experience when it comes to development ([#12](https://github.com/devwith-kev/toolbox/issues/12))
* Moved Git and Proxy versions to `toolbox.json`file as those values are managed by Toolbox and not by the organization ([#8](https://github.com/devwith-kev/toolbox/issues/8))

# 1.1.12 (November 17, 2023)

* Added post-hook mechanism after installation of Toolbox. This is allowing organizations to post-execute commands such as: toolbox install ... or even other post scripting capabilities you would require.
* Documentation updated

# 1.1.11 (November 15, 2023)

* Added organization configuration version within the `toolbox version` command

# 1.1.10 (November 15, 2023)

* Update admin page

# 1.1.9 (November 15, 2023)

* Correct typo

# 1.1.8 (November 15, 2023)

* Update README-user.md and README-admin.md

# 1.1.7 (November 14, 2023)

* Update README-admin.md

# 1.1.6 (November 14, 2023)

* Update README-admin.md and README-user files

# 1.1.5 (November 12, 2023)

* Update README-admin.md and README-user files

# 1.1.4 (November 12, 2023)

* Update README.md file with a refactoring of Toolbox definition
* Creation of a /docs folder to contain all sub README files
* Creation of a README-admin file dedicated to Toolbox administrators
* Creation of a README-user file dedicated to Toolbox users

# 1.1.3 (November 11, 2023)

* Update README.md file to explain how to setup Toolbox within an organization

# 1.1.2 (November 11, 2023)

* Removing community health files to .github repository to spread toward other repositories

# 1.1.1 (November 9, 2023)

* Adding the possibility to add a pre-hook.ps1 script to allow companies to run their own pre-hook before the installation of Toolbox

# 1.1.0 (November 8, 2023)

* Add environment variable called TOOLBOX_HOME to foresee REG_EXPAND_SZ capabilities on the registry and to be modular in the future

# 1.0.1 (November 8, 2023)

* Changed the load of the process environment variables from toolbox.ps1 to the shared common module
* The shared common now load the environment variables so plans CLI can load those variables as well

# 1.0.0 (November 7, 2023)

* First official release of Toolbox