# Setup Toolbox within your organization

Fork this repository in your own GitHub organization. If your are not on GitHub simply copy the source code and create your own repository on Azure DevOps, GitLab, Bitbucket or whatever source control management you are using.

> We advise you to NOT change any files you have forked or copied if your purpose is to use Toolbox for consumption only. If you want to contribute to Toolbox, read the [contributing guide](https://github.com/devwith-kev/.github/blob/main/CONTRIBUTING.md).

## Add a configuration file (required)

To make Toolbox works, you'll need to create a configuration file called `config.json` located at the root of your repository. This configuration file will contain all the settings your organization will provide to your software engineers.

> Leave it empty for now. We will come back later below.

## Add a configuration changelog file (recommended)

We strongly recommend you to create a configuration changelog file called `CHANGELOG-config.md` located at the root of your repository. This file will be used by your organization to describe all the changes you will perform on the `config.json` file. 

The automated release notes email of Toolbox will refer to this file each time the version of the configuration file will be incremented.

## Conclusion

# Configure Toolbox



## Add a pre-hook file (optional)

You can optionally create a `pre-hook.ps1` file at the root of your repository. This pre-hook script will give you the possiblity to execute a custom PowerShell script before the setup of Toolbox on your software engineers local development environments. You can add things like writing a custom welcome message from your company, updating some environment variables, creating files and more... well whatever you have in mind.