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