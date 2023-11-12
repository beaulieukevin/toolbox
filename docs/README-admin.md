# Setup Toolbox as an Administrator

Fork this repository in your own GitHub organization. If your are not on GitHub simply copy the source code and create your own repository on Azure DevOps, GitLab, Bitbucket or whatever source control management you are using.

## Add a configuration file (required)

To make Toolbox works, you'll need to create a configuration file called `config.json` located at the root of your repository. This configuration file will contain all the settings your organization will provide to your software engineers.

Leave it empty for now. We will come back later below.

## Add a configuration changelog file (recommended)

We strongly recommend you to create a configuration changelog file called `CHANGELOG-config.md` located at the root of your repository. This file will be used by your organization to describe all the changes you will perform on the `config.json` file. 

The automated release notes email feature of Toolbox will refer to this file each time the version of the configuration file will be incremented.

## Conclusion

You have created two files at the root of your repository:

* config.json
* CHANGELOG-config.md

Only update those two files. We advise you to NOT change any other files you have forked or copied if your purpose is to use Toolbox only for consumption. This could lead to unexpected behaviors of Toolbox.

If you want to contribute to Toolbox, read the [contributing guide](https://github.com/devwith-kev/.github/blob/main/CONTRIBUTING.md).

In the next section, we will explain you what are all the features Toolbox is providing and how to configure them.

# Configure Toolbox

Within the configuration file `config.json`, multiple features can be setup through different root objects using JSON format. We will guide through each of them. You can find a full Gist example of a [config.json](https://gist.github.com/devwith-kev/4fbe1937ba88545b46c6d03f24ebac85) file.

## version (required)

```json
{
    ...
    "version": "1.0.0"
    ...
}
```

It contains the version of your configuration file. It is your responsibility to increment the semantic version based on the changes you will apply to the configuration file. We strongly recommend you to update the `CHANGELOG-config.md` file accordingly each time the `config.json` file has changed.

## organization (required)

```json
{
    ...
    "organization": {
        "name": "devwith.kev",
        "emailDomain": "devwithkev.com",
        "supportEmail": "toolbox@devwithkev.com",
        "smtpServer": "smtp.devwithkev.com",
        "smtpPort": 25,
        "mainBrandHexColor": "#000000"
    }
    ...
}
```

| Field             | Required | Description                                                                                                                                                  |
|-------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name              | true     | The name of your organization.<br>It will be displayed in multiple Toolbox commands and features.                                                            |
| emailDomain       | true     | The email domain of your organization.<br>It will be used while setting the default user email during Git configuration.              |
| supportEmail      | true     | The support email address a user can reach in case of support request.<br>This email is used in multiple Toolbox features including automated release notes. |
| smtpServer        | false    | The SMTP server of your organization.<br>It will be used when Toolbox will send an automated release notes email to the user.                                |
| smtpPort          | false    | The SMTP port of your organization.<br>It will be used when Toolbox will send an automated release notes email to the user.                                  |
| mainBrandHexColor | false    | The main Hex color code of your organization.<br>The color will be used in the automated release notes email.                                                |