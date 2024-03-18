# Introduction

As a Toolbox administrator, you are responsible of handling the configuration and the updates of the core Toolbox for your organization. In the following sections, we will explain you how to setup and configure Toolbox within your organization.

# Setup Toolbox as an Administrator

Fork this repository in your own GitHub organization. If you are not on GitHub simply copy the source code and create your own repository on Azure DevOps, GitLab, Bitbucket or whatever source control management you are using. To make the synchronization easier between GitHub and your other source control management, use different Git remotes within your Git repository.

## Add a Configuration File

To make Toolbox works, you'll need to create a configuration file called `config.json` located at the root of your repository. This configuration file will contain all the settings your organization will provide to your software engineers.

Leave it empty for now. We will come back later below.

## Add a Configuration Changelog File

We strongly recommend you to create a configuration changelog file called `CHANGELOG-config.md` located at the root of your repository. This file will be used by your organization to describe all the changes you will perform on the `config.json` file. 

The automated release notes email feature of Toolbox will refer to this file each time the version of the configuration file will be incremented.

## To Wrap Up

You have created two files at the root of your repository:

* `config.json`
* `CHANGELOG-config.md`

Only update those two files. We advise you to NOT change any other files you have forked or copied if your purpose is to use Toolbox only for consumption. This could lead to unexpected behaviors of Toolbox.

If you want to contribute to Toolbox, read the [contributing guide](https://github.com/devwith-kev/.github/blob/main/CONTRIBUTING.md).

In the next section, we will explain you what are all the features Toolbox is providing and how to configure them.

# Configure Toolbox

Within the configuration file `config.json`, multiple features can be setup through different root objects using JSON format. Some of them are required, some others are optional. We will guide through each of them. You can find a full Gist example of a [config.json](https://gist.github.com/devwith-kev/4fbe1937ba88545b46c6d03f24ebac85) file.

## Required Fields

### 1 - Version

```json
{
  "version": "1.0.0"
}
```

It contains the version of your configuration file. It is your responsibility to increment the semantic version based on the changes you will apply to the configuration file. We strongly recommend you to update the `CHANGELOG-config.md` file accordingly each time the `config.json` file has changed.

### 2 - Organization

```json
{
  "organization": {
    "name": "devwith.kev",
    "emailDomain": "devwithkev.com",
    "ldapPath": "LDAP://DC=devwithkev,DC=com",
    "supportEmail": "support@devwithkev.com",
    "smtpServer": "smtp.devwithkev.com",
    "smtpPort": 25,
    "mainBrandHexColor": "#013220"
  }
}
```

| Field             | Required | Description                                                                                                                                                  |
|-------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name              | true     | The name of your organization.<br>It will be displayed in multiple Toolbox commands and features.                                                            |
| emailDomain       | true     | The email domain of your organization.<br>It will be used while setting the default user email during Git configuration and for sending automated release notes.             |
| ldapPath       | false     | The LDAP path used to retrieve the logged in user email. This is used for Git installation and Toolbox releases through email.   |
| supportEmail      | true     | The support email address a user can reach in case of support request.<br>This email is used in multiple Toolbox features including automated release notes. |
| smtpServer        | false    | The SMTP server of your organization.<br>It will be used when Toolbox will send an automated release notes email to the user.                                |
| smtpPort          | false<br>(true if 'smtpServer' is added)    | The SMTP port of your organization.<br>It will be used when Toolbox will send an automated release notes email to the user.                                  |
| mainBrandHexColor | false    | The main Hex color code of your organization.<br>The color will be used in the automated release notes email.                                                |

### 3 - Toolbox

```json
{
  "toolbox": {
    "gitRepository": "https://github.com/devwith-kev/toolbox.git",
    "defaultBranch": "main",
    "autoUpdate": true,
    "docsUrl": "https://github.com/devwith-kev/toolbox/blob/main/README.md"
  }
}
```

| Field         | Required | Description                                                                                                                                                      |
|---------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| gitRepository | true     | The Git repository where you have forked or copied Toolbox.<br>It will be used for syncing the core of Toolbox through a `toolbox update` or the autoupdate feature.                           |
| defaultBranch | true     | The default branch of your forked or copied Toolbox Git repository.<br>It will be used for syncing the core Toolbox through a `toolbox update` or the autoupdate feature.                      |
| autoUpdate    | false    | To activate or deactivate the autoupdate feature of Toolbox.<br>By activating the autoupdate, all the users will have Toolbox updated during logon and every day at noon. |
| docsUrl       | false    | The documentation URL used while using `toolbox docs`.                                                                                                           |

### 4 - Plans

```json
{
  "plans": {
    "vscode": {
      "gitRepository": "https://github.com/devwith-kev/toolbox-plan-vscode.git",
      "description": "Visual Studio Code, also commonly referred to as VS Code, is a source-code editor made by Microsoft with the Electron Framework, for Windows, Linux and macOS. Features include support for debugging, syntax highlighting, intelligent code completion, snippets and code refactoring."
    }
  }
}
```

Plans are the main heart of Toolbox, this is where you define all the plans Toolbox will refer to. The list of plans are being referred by the `toolbox list` command. For more information on how to create or update an existing plan, read the [plan management guide](/docs/README-plan-management.md).

In this example `vscode` is a plan. Users will be able to execute a plan installation by using `toolbox install vscode`. It is up to you to define the plan name.

If you don't have plans yet, either don't add the `plans` object or leave it empty.

| Field         | Required | Description                                                                      |
|---------------|----------|----------------------------------------------------------------------------------|
| gitRepository | true     | The Git repository where your plan is located and from where it will be fetched. |
| description   | true     | The description of your plan.<br> It will be used in the automated release notes to mention if a new plan has been added in the list.                                                    |

## Optional Fields

### 1 - ShortcutsLocation

```json
{
  "shortcutsLocation": "\\YOUR_PATH\\Desktop"
}
```

If you add a `shortcutsLocation` field, Toolbox will use this value to override the default `%USERPROFILE%\Desktop` path where application shortcuts are created. Don't use it if you are targeting the default path mentioned previously.

**Example**: if you have set `shortcutsLocation` to `\\INTERMEDIATE_DIRECTORY\\TARGET`, Toolbox will create applications shortcuts in `%USERPROFILE%\INTERMEDIATE_DIRECTORY\TARGET` instead of `%USERPROFILE%\Desktop`. 

> Notice that you need to use double slashes to escape a `\` in JSON.

### 2 - EnvironmentVariables

```json
{
  "environmentVariables": {
    "CUSTOM_VAR": "HELLOWORLD"
  }
}
```

You can customize Toolbox by provisioning environment variables at process level. It is really useful if you want to share environment variables related to your organization across multiple installation scripts. By doing so, you would be able to access the value `HELLOWORLD` by using in PowerShell `$Env:TOOLBOX_CUSTOM_VAR`. Notice that a variable defined in the list will always have the prefix `TOOLBOX_` prepended. 

> The variables named `HOME`, `APPS`, `PLANS` and `BIN` are forbidden values as they are defined inside Toolbox. They can all be accessed by prefixing them with `TOOLBOX_`.

### 3 - Git

```json
{
  "git": {
    "systemConfig": {
      "--remove-section": "include",
      "core.pager": "\"\"",
      "core.autocrlf": "false",
      "init.defaultBranch": "main",
      "http.sslBackend": "openssl",
      "pull.rebase": "true",
      "credential.https://dev.azure.com.usehttppath": "true"
    },
    "globalConfig": {
      "--unset": "init.defaultBranch",
      "push.autoSetupRemote": "true"
    }
  }
}
```

[MinGit](https://github.com/git-for-windows/git/releases), a lightweight Git, is coming out of the box with Toolbox. You can add optional configurations at system or global scope that will be applied to all users while setting up or updating Toolbox.

| Field        | Required | Description                                                                                                                                                                                   |
|--------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| systemConfig | false    | If you want to set common Git configuration at **system scope** for all your users then you can add a list of key value pairs.<br>Behind the scene, Toolbox will execute implicitly `git config --system KEY VALUE`.  |
| globalConfig | false    | If you want to set common Git configuration at **global scope** for all your users then you can add a list of key value pairs.<br>Behind the scene, Toolbox will execute implicitly `git config --global KEY VALUE`. |

### 4 - Analytics

```json
{
  "analytics": {
    "storagePath": "\\\\belwired.net\\dfs\\DATA\\ISS\\ITDev\\Data\\DEFR\\DEVX\\packages\\analytics",
    "usageFileName": "analytics",
    "errorFileName": "errors",
    "maxFileSizeInMb": 1.5
  }
}
```

You can activate Toolbox analytics by adding the object above. It will allow your organization to centralize the usage of Toolbox of all users either in an anonymous way or with their `%USERNAME%` depending on the privacy mode the user has selected.

| Field           | Required | Description                                                                                                                                                       |
|-----------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| storagePath     | true     | The URI of the directory where the analytics will be stored.<br>We recommend you to specify a directory where all users have `write` access like a NAS directory. |
| usageFileName   | true     | The JSON file name that will be created to store the users Toolbox usage.                                                                                         |
| errorFileName   | true     | The JSON file name that will be created in case errors are happening within Toolbox.                                                                              |
| maxFileSizeInMb | true     | The maximum file size limit of the analytics in Mb.                                                                                                               |

### 5 - Proxy

```json
{
  "proxy": {
    "localHost": "127.0.0.1",
    "localPort": "3128",
    "noProxy": "127.0.0.*,10.*.*.*,192.168.*.*"
  }
}
```

If your organization is running behind a corporate proxy, it might be required to setup a local proxy to make the bridge between your local environment and your organization proxy. Toolbox is using [Px proxy](https://github.com/genotrance/px), a HTTP(s) proxy server that allows applications to authenticate through an NTLM or Kerberos proxy server.

| Field            | Required | Description                                                                                                                              |
|------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------|
| localHost | true     | The local host your local proxy will run on. We recommend to use the localhost IP address: `127.0.0.1`.                                  |
| localPort | true     | The local port your local proxy will listen on. We recommend to use `3128` port.                                                         |
| noProxy          | false    | The list of IP addresses for which the proxy shouldn't be used. Each IP addresses must be separated by a comma `,`.                      |

# Extra Features

Toolbox provides your organization an extra feature which is called `hooks`. You can create a `pre-hook.ps1` file at the root directory of your repository. This script will be executed before the execution of the `setup.bat` file from the end user.

This is useful if you would like to perform some tasks related to your organization before the installation of Toolbox from the end user.

The same way, the creation of a `post-hook.ps1` file at the root directory of your repository will allow you to execute tasks after the installation of Toolbox.

This is useful if you want to already execute commands such as the installation of tools using `toolbox install` or any other post scripts you would like to perform.

# Congratulations

You now have all the pieces needed to setup, manage and update Toolbox within your organization.

To go further, read the [plan management guide](/docs/README-plan-management.md) to learn how to create a plan or update existing plans.