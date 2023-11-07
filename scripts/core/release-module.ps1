function Get-ToolboxReleaseContent($ToolboxNewVersion) {
  $content = @"
  <tr>
	<td style="padding:36px 30px 0px 30px;">
	  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
		<tr>
		  <td style="padding:0;color:#333333;">
			<h1 style="font-size:24px;margin:0 0 18px 0;font-family:Arial,sans-serif;">New Toolbox version</h1>
			<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">Toolbox has been updated to the version <strong>{{TOOLBOX_NEW_VERSION}}</strong>.</p>
			<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
			  For more details, <a href="{{TOOLBOX_CHANGELOG_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
			</p>
		  </td>
		</tr>
	  </table>
	</td>
</tr>
"@

  $content = $content.Replace("{{TOOLBOX_NEW_VERSION}}", $ToolboxNewVersion)
  $toolboxGitRepository = Get-ToolboxGitRepository
  $toolboxChangelogUrl = Get-MarkdownFileUrlFromRepository -GitRepository $toolboxGitRepository -MarkdownType "CHANGELOG"
  $content = $content.Replace("{{TOOLBOX_CHANGELOG_URL}}", $toolboxChangelogUrl)

  return $content
}

function Get-ConfigReleasecontent {
  param(
    $ConfigNewVersion,
    [switch]$DocsUrlChanged,
    [switch]$AutoUpdateChanged,
    [switch]$SupportEmailChanged
  )
  
  $content = @"
  <tr>
	<td style="padding:36px 30px 0px 30px;">
	  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
		<tr>
		  <td style="padding:0;color:#333333;">
			<h1 style="font-size:24px;margin:0 0 18px 0;font-family:Arial,sans-serif;">Toolbox configuration has been updated</h1>
			<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">Toolbox configuration has been updated to the version <strong>{{CONFIG_NEW_VERSION}}</strong>.</p>
			{{EXTRA_CONTENT}}
			<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
			  For more details, <a href="{{CONFIG_CHANGELOG_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
			</p>
		  </td>
		</tr>
	  </table>
	</td>
</tr>
"@

  $content = $content.Replace("{{CONFIG_NEW_VERSION}}", $ConfigNewVersion)
  $toolboxGitRepository = Get-ToolboxGitRepository
  $configChangelogUrl = Get-MarkdownFileUrlFromRepository -GitRepository $toolboxGitRepository -MarkdownType "CHANGELOG-config"
  $content = $content.Replace("{{CONFIG_CHANGELOG_URL}}", $configChangelogUrl)

  $extraContent = @"
"@

  if ($DocsUrlChanged.IsPresent) {
    $docsUrl = Get-CompanyDocsUrl
    if ($docsUrl) {
      $extraContent += @"
<br/>
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">The documentation URL of Toolbox has been updated. You can find the new documentation <a href="{{DOCS_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">here</a> or by opening a command prompt and executing:</p>
<p>
  <ul style="margin:0;font-size:15px;font-family:Arial,sans-serif;">
    <li><strong>toolbox docs</strong></li>
  </ul>
</p>
"@
      $extraContent = $extraContent.Replace("{{DOCS_URL}}", $docsUrl)
    }
    else {
      $extraContent += @"
<br/>
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">The documentation URL of Toolbox has been removed. Therefore the usage of 'toolbox docs' in a command prompt won't open any page in your browser.</p>
"@
    }
  }

  if ($AutoUpdateChanged.IsPresent) {
    $extraContent += @"
<br/>
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">The auto update feature of Toolbox has been <strong>{{ACTIVATION_MODE}}</strong>. {{UPDATE_EXPLANATION}}
"@

    $toolboxAutoUpdate = Get-ToolboxAutoUpdateConfig

    if (($null -ne $toolboxAutoUpdate) -and $toolboxAutoUpdate) {
      $activationMode = "activated"
      $updateExplanation = @"
Therefore, instead of executing a 'toolbox update' in a command prompt to update Toolbox and its associated plans, it will self update <strong>every day at noon local time</strong>.</p>
"@
    }
    else {
      $activationMode = "deactivated"
      $updateExplanation = @"
Therefore, to update Toolbox and its associated plans, you will need to open a command prompt and execute:</p>
<p>
  <ul style="margin:0;font-size:15px;font-family:Arial,sans-serif;">
    <li><strong>toolbox update</strong></li>
  </ul>
</p>
"@
    }

    $extraContent = $extraContent.Replace("{{ACTIVATION_MODE}}", $activationMode)
    $extraContent = $extraContent.Replace("{{UPDATE_EXPLANATION}}", $updateExplanation)
  }

  if ($SupportEmailChanged.IsPresent) {
    $supportEmail = Get-CompanySupportEmail
    if ($supportEmail) {
      $extraContent += @"
<br/>
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">The support email has been updated. You can now use the following email: {{SUPPORT_EMAIL}}.</p>
"@
      $extraContent = $extraContent.Replace("{{SUPPORT_EMAIL}}", $supportEmail)
    }
  }

  $content = $content.Replace("{{EXTRA_CONTENT}}", $extraContent)

  return $content
}

function Get-PlansReleaseContent($AddedPlans, $UpdatedPlans, $DeprecatedPlans) {
  $content = @"
<tr>
  <td style="padding:36px 30px 0px 30px;">
    <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
      <tr>
        <td style="padding:0;color:#333333;">
          <h1 style="font-size:24px;margin:0;font-family:Arial,sans-serif;">Plans overview</h1>
          {{EXTRA_CONTENT}}
        </td>
      </tr>
    </table>
  </td>
</tr>
"@

  $extraContent = @"
"@

  if ($AddedPlans) {
    $extraContent += @"
<table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
  <tr>
    <td style="padding:18px 0 12px 0;">
      <table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
        <tr>
          <td style="background-color:#4bc99c;padding:5px 15px 5px 15px;">
            <h2 style="margin:0;color:#ffffff;font-size:19px;font-family:Arial,sans-serif;">Added plans</h2>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
"@

    $newPlanTemplate = @"
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;"><strong>{{PLAN_NAME}}</strong> plan is now available for installation. {{PLAN_DESCRIPTION}} Install it by opening a command prompt and executing:</p>
<p>
  <ul style="margin:0;font-size:15px;font-family:Arial,sans-serif;">
    <li><strong>toolbox install {{PLAN_NAME}}</strong></li>
  </ul>
</p>
<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
  For more information, <a href="{{PLAN_DOCUMENTATION_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read documentation</a>
</p>
"@

    foreach ($planName in $AddedPlans) {
      $planDescription = Get-PlanGitRepositoryDescription -PlanName $planName
      $planGitRepository = Get-PlanGitRepository -PlanName $planName
      $planDocumentationUrl = Get-MarkdownFileUrlFromRepository -GitRepository $planGitRepository -MarkdownType "README"
      $extraContent += $newPlanTemplate
      $extraContent = $extraContent.Replace("{{PLAN_NAME}}", $planName)
      $extraContent = $extraContent.Replace("{{PLAN_DESCRIPTION}}", $planDescription)
      $extraContent = $extraContent.Replace("{{PLAN_DOCUMENTATION_URL}}", $planDocumentationUrl)
    }
  }

  if ($UpdatedPlans) {
    $extraContent += @"
<table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
  <tr>
    <td style="padding:18px 0 12px 0;">
      <table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
        <tr>
          <td style="background-color:#38c1ca;padding:5px 15px 5px 15px;">
            <h2 style="margin:0;color:#ffffff;font-size:19px;font-family:Arial,sans-serif;">Updated plans</h2>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
"@

    $updatedPlanTemplate = @"
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;"><strong>{{PLAN_NAME}}</strong> plan has been updated to the version <strong>{{PLAN_NEW_VERSION}}</strong>.</p> 
<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
  For more details, <a href="{{PLAN_CHANGELOG_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
</p>
"@

    foreach ($planName in $UpdatedPlans) {
      $planGitRepository = Get-PlanGitRepository -PlanName $planName
      $planChangeLogUrl = Get-MarkdownFileUrlFromRepository -GitRepository $planGitRepository -MarkdownType "CHANGELOG"
      $planConfig = Get-Content -Path "$Env:TOOLBOX_PLANS\$planName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
      $planVersion = $planConfig.version
      $extraContent += $updatedPlanTemplate
      $extraContent = $extraContent.Replace("{{PLAN_NAME}}", $planName)
      $extraContent = $extraContent.Replace("{{PLAN_NEW_VERSION}}", $planVersion)
      $extraContent = $extraContent.Replace("{{PLAN_CHANGELOG_URL}}", $planChangeLogUrl)
    }
  }

  if ($DeprecatedPlans) {
    $extraContent += @"
<table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
  <tr>
    <td style="padding:18px 0 12px 0;">
      <table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
        <tr>
          <td style="background-color:#f47878;padding:5px 15px 5px 15px;">
            <h2 style="margin:0;color:#ffffff;font-size:19px;font-family:Arial,sans-serif;">Deprecated plans</h2>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
"@

    $deprecatedPlanTemplate = @"
<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;"><strong>{{PLAN_NAME}}</strong> plan has been deprecated and is no longer available in Toolbox. Support or update of this plan will not be provided anymore. We recommend to uninstall it by opening a command prompt and executing:</p>
<p>
  <ul style="margin:0;font-size:15px;font-family:Arial,sans-serif;">
    <li><strong>toolbox uninstall {{PLAN_NAME}}</strong></li>
  </ul>
<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
  For more context, <a href="{{PLAN_TOOLBOX_CHANGELOG_URL}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
</p>
"@

    foreach ($planName in $DeprecatedPlans) {
      $toolboxGitRepository = Get-ToolboxGitRepository
      $toolboxChangeLogUrl = Get-MarkdownFileUrlFromRepository -GitRepository $toolboxGitRepository -MarkdownType "CHANGELOG"
      $extraContent += $deprecatedPlanTemplate
      $extraContent = $extraContent.Replace("{{PLAN_NAME}}", $planName)
      $extraContent = $extraContent.Replace("{{PLAN_TOOLBOX_CHANGELOG_URL}}", $toolboxChangeLogUrl)
    }
  }

  $content = $content.Replace("{{EXTRA_CONTENT}}", $extraContent)

  return $content
}

function Get-GitReleaseContent($GitNewVersion) {
  $content = @"
    <tr>
	<td style="padding:36px 30px 0px 30px;">
	  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
		<tr>
		  <td style="padding:0;color:#333333;">
			<h1 style="font-size:24px;margin:0 0 18px 0;font-family:Arial,sans-serif;">New Git version</h1>
			<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">Git has been updated to the version <strong>{{GIT_NEW_VERSION}}</strong>.</p>
			<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
			  For more details, <a href="https://github.com/git-for-windows/git/releases/tag/v{{GIT_WINDOWS_NEW_VERSION}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
			</p>
		  </td>
		</tr>
	  </table>
	</td>
</tr>
"@

  $content = $content.Replace("{{GIT_NEW_VERSION}}", $GitNewVersion)
  $versionParts = $GitNewVersion.Split(".")
  $major = $versionParts[0]
  $minor = $versionParts[1]
  $patch = $versionParts[2]
  $build = $versionParts[3]
  $content = $content.Replace("{{GIT_WINDOWS_NEW_VERSION}}", "$major.$minor.$patch.windows.$build")

  return $content
}

function Get-ProxyReleaseContent($ProxyNewVersion) {
  $content = @"
  <tr>
	<td style="padding:36px 30px 0px 30px;">
	  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
		<tr>
		  <td style="padding:0;color:#333333;">
			<h1 style="font-size:24px;margin:0 0 18px 0;font-family:Arial,sans-serif;">New Px proxy version</h1>
			<p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">Px proxy has been updated to the version <strong>{{PROXY_NEW_VERSION}}</strong>.</p>
			<p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
			  For more details, <a href="https://github.com/genotrance/px/releases/tag/v{{PROXY_NEW_VERSION}}" style="color:{{ORGANIZATION_BRAND_COLOR}};">read changelog</a>
			</p>
		  </td>
		</tr>
	  </table>
	</td>
</tr>
"@

  $content = $content.Replace("{{PROXY_NEW_VERSION}}", $ProxyNewVersion)

  return $content
}

function Send-ReleaseNotesMailMessage($ReleaseContent) {
  if (!$ReleaseContent) {
    return
  }

  $companyConfig = Get-CompanyConfig

  $organizationBrandColor = $companyConfig.organization.mainBrandHexColor
  if (!$organizationBrandColor) {
    $organizationBrandColor = "#000000"
  }
  $organizationName = Get-CompanyName
  $supportEmail = Get-CompanySupportEmail
  $currentYear = Get-Date -Format "yyyy"

  $emailBody = @"
    <!DOCTYPE html>
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta name="x-apple-disable-message-reformatting">
      <title></title>
      <!--[if mso]>
      <noscript>
        <xml>
          <o:OfficeDocumentSettings>
            <o:PixelsPerInch>96</o:PixelsPerInch>
          </o:OfficeDocumentSettings>
        </xml>
      </noscript>
      <![endif]-->
      <style>
        table, td, div, h1, p {font-family: Arial, sans-serif;}
      </style>
    </head>
    <body style="margin:0;padding:0;">
      <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;background:#ffffff;">
        <tr>
          <td align="center" style="padding:0;">
            <table role="presentation" style="width:600px;border-collapse:collapse;border:1px solid #cccccc;border-spacing:0;">
              <tr>
                <td align="center" style="padding:36px 30px 36px 30px;background:{{ORGANIZATION_BRAND_COLOR}};">
                  <img src="cid:toolbox.png" alt="Toolbox icon" width="300" style="height:auto;display:block;" />
                </td>
              </tr>
              {{RELEASE_CONTENT}}
              <tr>
                <td style="padding:36px 30px 36px 30px;">
                  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
                    <tr>
                      <td style="padding:0;color:#333333;">
                        <h1 style="font-size:24px;margin:0 0 18px 0;font-family:Arial,sans-serif;">Support</h1>
                        <p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;text-align:justify;text-justify:auto;">Do you encounter issues? Do you have suggestions to improve Toolbox? Or do you like it and want to share it with us?</p>
                        <p style="margin:12px 0 0 0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;">
                          Send us an email at <a href="mailto:{{SUPPORT_EMAIL}}?subject=Toolbox" style="color:{{ORGANIZATION_BRAND_COLOR}};">{{SUPPORT_EMAIL}}</a>
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding:36px 30px 36px 30px;background:{{ORGANIZATION_BRAND_COLOR}};">
                  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
                    <tr>
                      <td style="padding:0;width:80%;" align="left">
                        <p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;color:#ffffff;">
                          {{ORGANIZATION_NAME}}, {{CURRENT_YEAR}}
                        </p>
                        <p style="margin:0;font-size:15px;line-height:24px;font-family:Arial,sans-serif;color:#ffffff;">
                          From Toolbox open source project on GitHub
                        </p>
                      </td>
                      <td style="padding:0;width:20%;" align="right">
                        <table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
                          <tr>
                            <td style="padding:0 0 0 12px;width:36px;">
                              <a href="https://github.com/devwith-kev/toolbox" style="color:#ffffff;"><img src="cid:github.png" alt="GitHub icon" width="36" style="height:auto;display:block;border:0;" /></a>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
"@

  $emailBody = $emailBody.Replace("{{RELEASE_CONTENT}}", $ReleaseContent)
  $emailBody = $emailBody.Replace("{{ORGANIZATION_BRAND_COLOR}}", $organizationBrandColor)
  $emailBody = $emailBody.Replace("{{ORGANIZATION_NAME}}", $organizationName)
  $emailBody = $emailBody.Replace("{{CURRENT_YEAR}}", $currentYear)
  $emailBody = $emailBody.Replace("{{SUPPORT_EMAIL}}", $supportEmail)

  $emailDomain = Get-CompanyEmailDomain
  $emailFrom = "$Env:USERNAME@$emailDomain"
  $emailTo = "$Env:USERNAME@$emailDomain"
  $emailSubject = "Toolbox Release Notes"
  $smtpServer = $companyConfig.organization.smtpServer
  $smtpPort = $companyConfig.organization.smtpPort

  Send-MailMessage -From $emailFrom -To $emailTo -Subject $emailSubject -Body $emailBody -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort -Attachments "$Env:TOOLBOX_HOME\rsc\toolbox.png", "$Env:TOOLBOX_HOME\rsc\github.png" -ErrorAction SilentlyContinue
}
