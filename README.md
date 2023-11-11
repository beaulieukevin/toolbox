![Toolbox Image](/rsc/toolbox.png)

# Welcome to Toolbox

Toolbox is Windows Command Line Interface (CLI) allowing organizations to create, customize, centralize and scale common local environment configurations using their own source control management system through scripting.

It has been created from the need of centralizing tooling management, configuration management and giving the organization's software engineers the possibility to get up to speed the most efficient way.

Toolbox will allow your software engineers to setup their local development environment from a pure vanilla image of Windows (no Git, no CLI, no package manager... pure vanilla).

# Prerequisites

Toolbox has been built to be immediately usable under a Windows environment as it has been written using plain PowerShell without the usage of any third party modules.

The setup of Toolbox is pretty straight forward. It doesn't require anything from your side. Only a Windows machine with the rights to execute PowerShell scripts (no need of administrator rights).

> Toolbox is under analysis to be used under Mac OS and Linux operating systems but is still not yet available. ⭐ the repository to be kept up to date.

# Setup Toolbox within your organization

Fork this repository in your own GitHub organization. If your are not on GitHub simply copy the source code and create your own repository on Azure DevOps, GitLab, Bitbucket or whatever source control management you are using.

> We advise you to NOT change any files you have forked or copied if your purpose is to use Toolbox for consumption only. If you want to contribute to Toolbox, read the [contributing guide](https://github.com/devwith-kev/.github/blob/main/CONTRIBUTING.md).

## Add a configuration file (required)

To make Toolbox works, you'll need to create a configuration file called `config.json` located at the root of your repository. This configuration file will contain all the settings your organization will provide to your software engineers.

> Leave it empty for now. We will come back later below.

## Add a configuration changelog file (optional)

We strongly recommend you to create a configuration changelog file called `CHANGELOG-config.md` located at the root of your repository. This file will be used by your organization to describe all the changes you will perform on the `config.json` file. You can get inspired the approach of the changelog file of Toolbox

## Add a pre-hook file (optional)

You can optionally create a `pre-hook.ps1` file at the root of your repository. This pre-hook script will give you the opportunity to execute a custom PowerShell script before the setup of Toolbox on your software engineers local development environments. You can add things like writing a custom welcome message from your company, updating some environment variables, creating files and more... well whatever you have in mind.

Leave it empty for now. We will come back later below.

## Conclusion

# Configure Toolbox

