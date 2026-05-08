<#
============================================================================================================================
Script: Start-Windsurf
Author: Smart Ace

Notes:
This ScriptoForm provides a method to launch the Windsurf code editor with a specific user profile.
============================================================================================================================
#>

#region Settings
$SETTINGS_FILE = "$env:LOCALAPPDATA\SmartAceDesigns\Start-Windsurf\Settings.json"
$SUPPORT_CONTACT = "Smart Ace"
$WINDSURF_BASE = "$env:APPDATA\Windsurf"
#endregion

#region Assemblies
Add-Type -AssemblyName System.Windows.Forms
#endregion

#region Appearance
[System.Windows.Forms.Application]::EnableVisualStyles()
#endregion

#region Controls
$FormMain = New-Object -TypeName System.Windows.Forms.Form
$GroupBoxMain = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelProfileName = New-Object -TypeName System.Windows.Forms.Label
$ComboBoxProfileName = New-Object -TypeName System.Windows.Forms.ComboBox
$LabelProjects = New-Object -TypeName System.Windows.Forms.Label
$ComboBoxProjects = New-Object -TypeName System.Windows.Forms.ComboBox
$ButtonRun = New-Object -TypeName System.Windows.Forms.Button
$ButtonClose = New-Object -TypeName System.Windows.Forms.Button
$StatusStripMain = New-Object -TypeName System.Windows.Forms.StatusStrip
$ToolStripStatusLabelMain = New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel
#endregion

#region Forms
$ShowFormMain =
{
    $FormWidth = 330
    $FormHeight = 210

    $FormMain.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $PID).Path)
    $FormMain.Text = "WindSurf Launcher"
    $FormMain.Font = New-Object -TypeName System.Drawing.Font("MS Sans Serif",8)
    $FormMain.ClientSize = New-Object -TypeName System.Drawing.Size($FormWidth,$FormHeight)
    $FormMain.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $FormMain.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $FormMain.MaximizeBox = $false
    $FormMain.AcceptButton = $ButtonRun
    $FormMain.CancelButton = $ButtonClose
    $FormMain.Add_Shown($FormMain_Load)
    $FormMain.Add_Shown($FormMain_Shown)

    $GroupBoxMain.Location = New-Object -TypeName System.Drawing.Point(10,5)
    $GroupBoxMain.Size = New-Object -TypeName System.Drawing.Size(($FormWidth - 20),($FormHeight - 80))
    $FormMain.Controls.Add($GroupBoxMain)

    $LabelProfileName.Location = New-Object -TypeName System.Drawing.Point(15,15)
    $LabelProfileName.AutoSize = $true
    $LabelProfileName.Text = "Profile:"
    $GroupBoxMain.Controls.Add($LabelProfileName)
    
    $ComboBoxProfileName.Location = New-Object -TypeName System.Drawing.Point(15,35)
    $ComboBoxProfileName.Size = New-Object -TypeName System.Drawing.Size(($FormWidth - 50),20)
    $ComboBoxProfileName.TabIndex = 0
    $ComboBoxProfileName.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $GroupBoxMain.Controls.Add($ComboBoxProfileName)

    $LabelProjects.Location = New-Object -TypeName System.Drawing.Point(15,70)
    $LabelProjects.AutoSize = $true
    $LabelProjects.Text = "Project:"
    $GroupBoxMain.Controls.Add($LabelProjects)
    
    $ComboBoxProjects.Location = New-Object -TypeName System.Drawing.Point(15,90)
    $ComboBoxProjects.Size = New-Object -TypeName System.Drawing.Size(($FormWidth - 50),20)
    $ComboBoxProjects.TabIndex = 1
    $ComboBoxProjects.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $GroupBoxMain.Controls.Add($ComboBoxProjects)

    $ButtonRun.Location = New-Object -TypeName System.Drawing.Point(($FormWidth - 175),($FormHeight - 60))
    $ButtonRun.Size = New-Object -TypeName System.Drawing.Size(75,25)
    $ButtonRun.TabIndex = 100
    $ButtonRun.Enabled = $true
    $ButtonRun.Text = "Run"
    $ButtonRun.Add_Click($ButtonRun_Click)
    $FormMain.Controls.Add($ButtonRun)

    $ButtonClose.Location = New-Object -TypeName System.Drawing.Point(($FormWidth - 85),($FormHeight - 60))
    $ButtonClose.Size = New-Object -TypeName System.Drawing.Size(75,25)
    $ButtonClose.TabIndex = 101
    $ButtonClose.Text = "Close"
    $ButtonClose.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $FormMain.Controls.Add($ButtonClose)

    $StatusStripMain.SizingGrip = $false
    $StatusStripMain.Font = New-Object -TypeName System.Drawing.Font("MS Sans Serif",8)
    [void]$StatusStripMain.Items.Add($ToolStripStatusLabelMain)
    $FormMain.Controls.Add($StatusStripMain)

    [void]$FormMain.ShowDialog()
    $FormMain.Dispose()
}
#endregion

#region Functions
function Invoke-FormAction
{
    param
    (
        [Parameter(Mandatory, Position = 0)] [ScriptBlock]$Action,
        [Parameter(Position = 1)] [ScriptBlock]$Reset = $null,
        [Parameter(Position = 2)] [String]$StatusText = "Working...please wait"
    )

    try
    {
        $ToolStripStatusLabelMain.Text = $StatusText
        $FormMain.Controls | Where-Object {$PSItem -isnot [System.Windows.Forms.StatusStrip]} | ForEach-Object {$PSItem.Enabled = $false}
        $FormMain.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        [System.Windows.Forms.Application]::DoEvents()
        Invoke-Command -ScriptBlock $Action
    }
    
    finally
    {
        $FormMain.Controls | ForEach-Object {$PSItem.Enabled = $true}
        $FormMain.ResetCursor()
        if ($Reset) {Invoke-Command -ScriptBlock $Reset}
        $ToolStripStatusLabelMain.Text = "Ready"
        $StatusStripMain.Update()
    }
}

function Get-ExtensionsToDisable
{
    param
    (
        [Parameter(Mandatory, Position = 0)] [string]$ProfileName
    )
    
    @($Settings.ExtensionsToDisable.$ProfileName)
}

function Set-Profile
{
    param
    (
        [Parameter(Mandatory, Position = 0)] [String]$ProfileName
    )
    
    $ActiveProfile = $Settings.ActiveProfile
    if ($ActiveProfile -ne $ProfileName)
    {
        if (Test-Path $WINDSURF_BASE)
        {
            try {Rename-Item $WINDSURF_BASE "$WINDSURF_BASE.$ActiveProfile" -Force -ErrorAction Stop}
            catch {throw}
        }
        if (Test-Path "$WINDSURF_BASE.$ProfileName")
        {
            try {Rename-Item "$WINDSURF_BASE.$ProfileName" $WINDSURF_BASE -Force -ErrorAction stop}
            catch
            {
                # Roll-back rename to prevent missing Windsurf user directory
                if (Test-Path "$WINDSURF_BASE.$ActiveProfile") {Rename-Item "$WINDSURF_BASE.$ActiveProfile" $WINDSURF_BASE -Force}
                throw
            }
        }
        else
        {
            # Roll-back rename to prevent missing Windsurf user directory
            if (Test-Path "$WINDSURF_BASE.$ActiveProfile") {Rename-Item "$WINDSURF_BASE.$ActiveProfile" $WINDSURF_BASE -Force}
            throw "The target profile directory does not exist.`n`nYou might need to create the profile directory first before using this script."
        }
        $Settings.ActiveProfile = $ProfileName
        $Settings | ConvertTo-Json | Set-Content $SETTINGS_FILE
    }
}
#endregion

#region Handlers
$FormMain_Load =
{
    $ComboBoxProfileName.Items.AddRange($Settings.Profiles)
    $ComboBoxProfileName.SelectedIndex = 0
    
    $ComboBoxProjects.Items.Add("None")
    if (Test-Path $Settings.ProjectsFolder)
    {
        $Projects = Get-ChildItem -Path $Settings.ProjectsFolder -Directory | Select-Object -ExpandProperty Name
        $ComboBoxProjects.Items.AddRange($Projects)
    }
    $ComboBoxProjects.SelectedIndex = 0
}

$FormMain_Shown =
{
    $ToolStripStatusLabelMain.Text = "Active profile: $($Settings.ActiveProfile)"
    $StatusStripMain.Update()
    $FormMain.Activate()
}

$ButtonRun_Click =
{
    Invoke-FormAction -Action {
        try
        {
            if ((Test-Path "$WINDSURF_BASE.$($ComboBoxProfileName.Text)") -or ($Settings.ActiveProfile -eq $ComboBoxProfileName.Text))
            {
                Set-Profile -ProfileName $ComboBoxProfileName.Text

                $ExtensionsToDisable = Get-ExtensionsToDisable -ProfileName $ComboBoxProfileName.Text
                $DisableFlags = @()
                foreach ($Extension in $ExtensionsToDisable)
                {
                    $DisableFlags += "--disable-extension"
                    $DisableFlags += $Extension
                }
        
                if ($ComboBoxProjects.SelectedIndex -eq 0) {windsurf @DisableFlags}
                else {windsurf @DisableFlags "$($Settings.ProjectsFolder)\$($ComboBoxProjects.Text)"}

                $FormMain.Close()
            }
            else {throw "The target profile directory does not exist.`n`nYou might need to create the profile directory first before using this script."}
        }
        catch
        {
            [void][System.Windows.Forms.MessageBox]::Show(
                $PSItem.Exception.Message + "`n`nPlease contact $SUPPORT_CONTACT for technical support.",
                "Exception",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            $FormMain.Close()
        }
    }
}
#endregion

#region Main
if (Test-Path -Path $SETTINGS_FILE)
{
    $script:Settings = Get-Content -Path $SETTINGS_FILE | ConvertFrom-Json
    Invoke-Command -ScriptBlock $ShowFormMain
}
else
{
    [void][System.Windows.Forms.MessageBox]::Show(
        "The settings file for this script could not be found. Please verify the following file exists and try the script again:`n`n$SETTINGS_FILE",
        "Missing File",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}
#endregion
