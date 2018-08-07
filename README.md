# Vendor Starter Scripts
Starter Scripts for integration with Genius Central Vendor Services

## Prerequisites
These scripts are intended to run in PowerShell on Windows

## Get Started
1. **Clone or Download the Repository**
    * [Clone] If you have git tools installed, run this command to create a folder called VendorScripts and place the code in the folder:
    `git clone https://github.com/GeniusCentral/VendorApiStarterScripts.git VendorScripts`
    * [Download] Alternatively,in this github repository click "Clone or download" in the top  corner and download the zip file into a folder called "VendorScripts"

1. **Set up permission to run these PowerShell scripts**
    * Open a PowerShell window as an Administrator
    * Execute the command Set-ExecutionPolicy RemoteSigned

1. **Send TEST Order Acknowledgments**
    * Make sure you are in the VendorScripts folder
    * Place test files in the location set in `config.json` at `"acknowledgementsJsonPath"`
    * Run `.\SendOrderAcknowledgements -test $true`
    * Open the LogFiles folder and confirm that you have a log file and that the log file indicates that acknowledgements were sent

1. **Send TEST Shipping Notices**
    * Make sure you are in the VendorScripts folder
    * Place test files in the location set in `config.json` at `"acknowledgementsJsonPath"`
    * Run `.\SendShippingNotices -test $true`
    * Open the LogFiles folder and confirm that you have a log file and that the log file indicates that acknowledgements were sent

1. **Change the configuration file to match your unique configuration**
    * Genius Central will provide you with the changes and values to update

1. **Complete Setup with Genius Central**
    * Set debug=false in .config
    * Set `"outputToConsole": false` in `config.json` if that is your preference
    * Test with your specific configuration
    * Test in Production with your specific configuration
