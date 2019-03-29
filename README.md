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
    * If you followed the above steps you should have a client id and a client secret from customer support in the `config.json` file. The following snippet will load those values into environment variables to make accessing them later much easier and more secure.
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
        * All examples will also have a curl usage (after the execute button has been clicked)
    * Ensure all calls to the api include this header option: `-H "accept: application/json"`

### Sample usage of the API from the command line
Most usages of the API fall into one of two categories: GETting data or POSTing data. Below are two examples of how to perform one of each of those operations. The above preceding steps to load the configuration data and get a token should have been followed for the following examples to function correctly.

#### View a confirmed order
```sh
curl -X \
  GET "https://posapi.dev.geniuscentral.com/purchase-orders?confirmed=true&count=1" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  | jq
``` 

#### Get and acknowledge receipt of a single unconfirmed purchase order:
```sh
# step 1: get the order id of a single unconfirmed order
declare -x order_id=$(curl -X \
  GET "https://posapi.dev.geniuscentral.com/purchase-orders?confirmed=false&count=1" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  | jq ".items[].orderId")

# step 2: acknowledge receipt of the order
curl -X PUT \
  https://posapi.dev.geniuscentral.com/purchase-orders/$order_id/receipts \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer $access_token' \
  -H 'Content-Type: application/json' \
  -d ""
```
#### Post a shipping notice for a confirmed order:
```sh
# step 1: get an order id from a purchase order (same code as above, putting a single field into an environment variable)
declare -x order_id=$(curl -X GET "https://posapi.dev.geniuscentral.com/purchase-orders?confirmed=true&count=1" -H "accept: application/json" -H "Authorization: Bearer $access_token" | jq ".items[].orderId")

# step 2: post a new shipping notice to that purchase order (the -d option should contain the JSON formatted data you want to be posted)
curl \
  -X POST "https://posapi.dev.geniuscentral.com/orders/$order_id/shipping-notices" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json-patch+json" \
  -d "{ \"geniusCentral\": { \"version\": 2 }, \"vendor\": { \"shipmentId\": \"12345678934857346\", \"trackingNumber\": \"1235\", \"billOfLadingNumber\": \"12365\", \"carrierReferenceNumber\": \"1234\" }, \"buyer\": { \"storeNumber\": 100331, \"vendorNumber\": \"12365123\" }, \"dateNotified\": \"2019-02-15T14:22:50.227\", \"dateOrdered\": \"2018-07-28T17:08:45.138Z\", \"packages\": [{ \"packagingMaterial\": \"carton\", \"quantity\": 3, \"grossWeight\": 123, \"unitOfMeasure\": \"LB\" } ], \"carrier\": { \"standardCarrierAlphaCode\": \"UPS\", \"name\": \"1K4K3J4F3IF345346J\" }, \"adminContact\": { \"companyName\": \"Dog Food Proveyors, Inc\", \"name\": \"Testy McTesterson\", \"phone\": \"515-551-1155\", \"email\": \"testy.mctesterson@dfp.com\" }, \"transitDetails\": { \"deliveryDate\": \"2018-07-25T17:16:59.519Z\", \"pickupDate\": null, \"shipmentDate\": \"2018-07-25T17:16:59.519Z\" }, \"shipFrom\": { \"dunsNumber\": \"12345678901234\", \"buyerAssignedCode\": \"123563\", \"companyName\": \"Dog Food Proveyors, Inc\", \"name\": \"Shipping Dept\", \"phone\": \"555-555-5555\", \"email\": \"shipping@dfp.com\", \"address\": { \"address1\": \"123 Test Rd\", \"address2\": \"Suite 100\", \"city\": \"Orlando\", \"state\": \"FL\", \"country\": \"USA\", \"postalCode\": \"32819\" } }, \"shipTo\": { \"dunsNumber\": \"12345678901234\", \"buyerAssignedCode\": \"123563\", \"companyName\": null, \"name\": \"Joney McHorseson\", \"phone\": \"727-345-2395\", \"email\": \"joney@mchorseon.com\", \"address\": { \"address1\": \"1234 Horsey Street\", \"address2\": \"Suite 100\", \"city\": \"Ponyville\", \"state\": \"MT\", \"country\": \"USA\", \"postalCode\": \"23837\" } }, \"orders\": [{ \"purchaseOrderNumber\": \"123456767\", \"accountNumber\": \"TEST1234\", \"shippingContainers\": [{ \"shippingContainerCodes\": [\"12345\"], \"lineItems\": [{ \"quantityShipped\": 0, \"additionalDescriptions\": [\"doggie food 16oz\", \"delicious yum-yums\"], \"lotNumber\": \"ABCD1234\", \"expirationDate\": null, \"productionDate\": null, \"bestByDate\": null, \"lineNumber\": \"1\", \"sku\": \"ABC1234\", \"upc\": \"123456789012\", \"gtin\": \"00123456789012\", \"description\": \"Dog Food 16oz - may contain cornmeal\", \"casePackSize\": null, \"unitPrice\": 3.4, \"unitOfMeasure\": null, \"quantityOrdered\": 4, \"additionalUnitOfMeasure\": null, \"size\": null, \"ean\": null } ] } ] } ]}" \
  | jq
```

### In-Network Orders

#### View a pending order
```sh
curl -X \
  GET "https://posapi.dev.geniuscentral.com/in-network/orders?pending=true&count=1" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  | jq
```

#### Get an in-network order, post an invoice:
```sh
# step 1: get the order id of a single pending order
declare -x order_id=$(curl -X \
  GET "https://posapi.dev.geniuscentral.com/in-network/orders?pending=true&count=1" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  | jq ".items[].orderID")

# step 2: post a new invoice to that order (the -d option should contain the JSON formatted data you want to be posted)
curl \
  -X POST "https://posapi.dev.geniuscentral.com/in-network/invoices/" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json-patch+json" \
  -d "{
	\"header\": {
		\"orderID\": $order_id,
		\"invoiceNumber\": \"9999\",
		\"shipDate\": \"2018-12-21T00:00:00\",
		\"invoiceDate\": \"2018-12-20T00:00:00\",
		\"subTotal\": 8,
		\"discount\": 2.99,
		\"tax\": 0,
		\"freight\": 5,
		\"orderTotal\": 12
	},
	\"details\": [
		{
			\"upc\": \"00000002256755\",
			\"supplierSKU\": \"2256\",
			\"itemDescription\": \"Glen's Apple Cider 16 oz\",
			\"shippedQuantity\": 1,
			\"orderQuantity\": 1,
			\"priceEa\": 8,
			\"priceCase\": 0,
			\"srp\": 6.99,
			\"wholesale\": 9.99,
			\"priceExtension\": 8,
			\"brandDescription\": \"Glenville Mangos Market\",
			\"packSize\": \"16 oz\",
			\"discountDesc\": null,
			\"orderUnits\": \"EA\",
			\"casePackSize\": 16
		}
	]
}" \
  | jq
```

#### Get an in-network order, post a shipping notice to it:
```sh
# step 1: get the order id of a single pending order
declare -x order_id=$(curl -X \
  GET "https://posapi.dev.geniuscentral.com/in-network/orders?pending=true&count=1" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  | jq ".items[].orderID")

# step 2: post a new shipping notice to that order (the -d option should contain the JSON formatted data you want to be posted)
curl \
  -X POST "https://posapi.dev.geniuscentral.com/in-network/shipping-notices/" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json-patch+json" \
  -d "{
	\"header\": {
		\"orderID\": $order_id,
		\"shipDate\": \"2018-12-21T00:00:00\",
		\"trackingNumber\": \"AZ12ABCDEFG123456\",
	},
	\"details\": [
		{
			\"shippedQuantity\": 1,
			\"upc\": \"00000002256755\",
			\"sku\": \"2256\",
			\"unitOfMeasure\": \"EA\",
			\"description\": \"Glen's Apple Cider 16 oz\",
		}
	]
}" \
  | jq
```



