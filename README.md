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

## Testing with cURL
It is *highly* recommended to do command line testing by using the examples on the [API documentation](https://posapi.dev.geniuscentral.com/swagger/index.html) page. This will allow you to easily test API calls in the browser before possibly getting lost on the command line.

### Prerequisites
1. A command line capable of running cURL.
    * Powershell includes a fake alias for curl which does not work
    * If you want to do this testing on Windows it is highly recommended to install [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) which will provide a complete shell environment. If you do not have a preference, install Ubuntu.
1. The following packages: `git`, `curl`, and `jq`
    * If you just installed WSL and Ubuntu install these packages by entering the following commands:
        ```sh
        sudo apt update
        sudo apt install -y git curl jq
        ```
1. The source code repository
    ```sh
    git clone https://github.com/GeniusCentral/VendorApiStarterScripts.git VendorScripts
    cd VendorScripts
    ```
1. Load configuration data
    * If you followed the above steps you should have a client id and a client secret from customer support in the `config.json` file. The following snippet will load those values into environment variables to make accessing them later much easer and more secure.
        ```sh
        $(cat config.json | jq -r 'to_entries|map("export \(.key)=\(.value|tostring)")|.[]' | grep client)
        ```
1. Get your token
    * This following snippet will get a new token and load it into the `$access_token` environment variable:
        ```sh
        $(curl -X POST https://idsrv.dev.geniuscentral.com/connect/token -d "scope=posClient&client_secret=$clientSecret&client_id=$clientId&grant_type=client_credentials" | jq -r 'to_entries|map("export \(.key)=\(.value|tostring)")|.[]' | grep access_token)
        ```
    * To view the token run the following command:
        ```sh
        echo $access_token
        ```
1. From now on the setup is done and we can simply use the authentication token by specifying it from the `$access_token` environment variable
    * The token value can be retrieved by running `echo $access_token` from the shell
    * The same token can be used for the swagger API documentation at https://posapi.dev.geniuscentral.com/swagger/index.html
        * Click "Authorize" and enter "Bearer [value of $access_token]"
        * All the examples should now be usable
        * All examples will also have a curl usage

### Sample usage of the API from the command line
#### Get a single confirmed purchase order:
```sh
curl -X GET "https://posapi.dev.geniuscentral.com/purchase-orders?confirmed=true&count=1" \
     -H "accept: application/json" \
     -H "Authorization: Bearer $access_token" \
     | jq
```
