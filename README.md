# Start-Windsurf
>[!warning]
>This ScriptoForm is for demonstration purposes only and not intended for use in a production environment.

This repository contains all files required to build the **Start-Windsurf** ScriptoForm project. A _ScriptoForm_ is a PowerShell script that generates and displays a [Microsoft Windows Forms](https://learn.microsoft.com/en-us/dotnet/desktop/winforms/overview/?view=netdesktop-10.0#introduction) application that can be used for a specific management or system administration task in a network environment. A _ScriptoForm project_ is the set of files and folders, including the PowerShell script, that can be compiled into an executable file using the Microsoft .NET CLI utility (dotnet.exe) which is available with any [Microsoft .NET SDK](https://dotnet.microsoft.com/en-us/download/dotnet). Included in the repository is the Build.cs C# file which the compiler will use as the source for the executable, and the Build.csproj C# project file which provides the set of instructions used to compile the executable.

## Purpose

The **Start-Windsurf** script launches a Windows form that provides a method to start the Windsurf code editor with a specific profile and project. By default, Windsurf does not provide multple-profile functionality similar to that of VSCode. This script swaps an existing custom profile directory, as specified by the user from the form, with the default Windsurf directory prior to launching the Windsurf editor. Optionally, a specific project folder can be opened with the editor. All settings are stored in the `$env:LOCALAPPDATA\SmartAceDesigns\Start-Windsurf\Settings.json` file and can be customized as needed.

### Initial Setup

1. Copy the `Settings.json` file to `$env:LOCALAPPDATA\SmartAceDesigns\Start-Windsurf` and update it as needed per your specific requirements:
   1. Leave the `ActiveProfile` property’s value set to `"default"` — this will update automatically when the script is run and a profile is selected.
   2. Add as many profile names as needed to the `Profiles` array. Each name should be unique and follow standard Windows directory naming requirements. Avoid using spaces.
   3. Do not remove `"default"` from the `Profiles` array — it represents the initial profile used by Windsurf and must remain the first entry.
   4. For each profile, add the extension identifier (if any) that should be disabled when that profile is active to the `Extensions` object, using the profile name as the key. For example, you may want to disable the Prettier extension in an `oxc`-specific profile, and disable the `oxc` extension when using the `default` profile configured for Prettier formatting. Check the extension details in Windsurf to determine the correct identifier.
   5. Update the `ProjectsFolder` property to match the root directory that contains your project folders.
2. Create a copy of the `$env:APPDATA\Windsurf` directory (known as the `default` profile) for each unique profile listed in your `Settings.json` file using the profile name as a suffix for the new directory. For example: `$env:APPDATA\Windsurf-oxc`. The contents of each new profile directory will initially be identical to the default profile.
3. Start the `Start-Windsurf` script using PowerShell or a compiled ScriptoForm. Select a custom profile and launch Windsurf from the script. Customize the profile as needed within Windsurf, then close Windsurf to save the changes.
4. Repeat step 3 for each custom profile. Once all profiles have been initialized, you can use the `Start-Windsurf` script to load any custom profile or the default profile.
5. To open a specific project folder when launching Windsurf through the `Start-Windsurf` script, select it from the `Project` combobox. This list is generated dynamically from the `ProjectsFolder` property in your `Settings.json` file.

### Example

`Settings.json`:

```json
{
  "ActiveProfile": "default",
  "Profiles": ["default", "oxc"],
  "ExtensionsToDisable": {
    "default": ["oxc.oxc-vscode"],
    "oxc": ["esbenp.prettier-vscode", "unifiedjs.vscode-mdx"]
  },
  "ProjectsFolder": "D:\\Projects"
}
```

## Requirements

- This project supports the following command shells:
  - [Windows PowerShell 5.1](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-5.1)
  - [PowerShell 7.4.x](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.4)
  - [PowerShell 7.5.x](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.5)
  - [PowerShell 7.6.x](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.6)
- This project supports the following Microsoft .NET frameworks:
  - [Microsoft .NET 4.x](https://dotnet.microsoft.com/en-us/download/dotnet-framework)
  - [Microsoft .NET 8.x](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
  - [Microsoft .NET 9.x](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
  - [Microsoft .NET 10.x](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)

## Compile Instructions

Perform the following prerequisite steps:

- Install the [Microsoft .NET 10.x SDK](https://dotnet.microsoft.com/en-us/download/dotnet/10.0) on your development machine.
- Clone the repository to your development machine.

Use any of the below workflows to create an executable file of the PowerShell script that is compatible with the framework version specified:

Microsoft .NET 4.x Framework

- Open a supported command shell and navigate to the _Build_ subdirectory in your local repository directory.
- Run the following command from within your _Build_ subdirectory:<br>
  `dotnet publish -f net48 -v q -o ..\Release\Legacy; dotnet clean -f net48 -v q`
- The compiled executable will be created in the _Release\Legacy_ subdirectory of your local repository directory. This location can be changed by modifying the `-o` argument in the above command.
- The latest [Microsoft .NET 4.x Framework Runtime](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48) will be required on any computer used to run the executable.

Microsoft .NET 8.x Framework

- Open a supported command shell and navigate to the _Build_ subdirectory in your local repository directory.
- Run the following command from within your _Build_ subdirectory:<br>
  `dotnet publish -f net8.0-windows -v q -o ..\Release\LTSLegacy; dotnet clean -f net8.0-windows -v q`
- The compiled executable will be created in the _Release\LTSLegacy_ subdirectory of your local repository directory. This location can be changed by modifying the `-o` argument in the above command.
- The latest [Microsoft .NET 8.x Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) will be required on any computer used to run the executable.

Microsoft .NET 9.x Framework

- Open a supported command shell and navigate to the _Build_ subdirectory in your local repository directory.
- Run the following command from within your _Build_ subdirectory:<br>
  `dotnet publish -f net9.0-windows -v q -o ..\Release\STS; dotnet clean -f net9.0-windows -v q`
- The compiled executable will be created in the _Release\STS_ subdirectory of your local repository directory. This location can be changed by modifying the `-o` argument in the above command.
- The latest [Microsoft .NET 9.x Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) will be required on any computer used to run the executable.

Microsoft .NET 10.x Framework

- Open a supported command shell and navigate to the _Build_ subdirectory in your local repository directory.
- Run the following command from within your _Build_ subdirectory:<br>
  `dotnet publish -f net10.0-windows -v q -o ..\Release\LTS; dotnet clean -f net10.0-windows -v q`
- The compiled executable will be created in the _Release\LTS_ subdirectory of your local repository directory. This location can be changed by modifying the `-o` argument in the above command.
- The latest [Microsoft .NET 10.x Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/10.0) will be required on any computer used to run the executable.

## Executable Notes

- When the executable file is run it will extract all resource files that were included in the compilation process to a unique temporary extraction directory in the user's profile directory.
- The executable will attempt to use the latest version of PowerShell discovered on the local machine to execute the extracted script file unless excluded by one of the command-line arguments noted below. If a version of PowerShell is excluded by a command-line argument then the executable will attempt to use the next latest version of PowerShell discovered on the system. The executable will always default to using Windows PowerShell if no other versions are available for use.
- After the PowerShell script execution has completed, all extracted files and the extraction directory are deleted and the executable terminates.
- The following optional command-line arguments can be used to control operation of the executable:
  | Argument | Purpose | Notes |
  | ------------ | --------------------------------- | ---------------------------------------------- |
  | -exclude:all | Exclude PowerShell x.x.x versions | Do not use with other _exclude_ arguments |
  | -exclude:ps7 | Exclude PowerShell 7.x.x versions | Do not use with other _exclude_ arguments |
  | -debug | Show console window | Use individually or with an _exclude_ argument |
