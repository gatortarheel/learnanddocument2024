# Bicep

## Getting Started

https://learn.microsoft.com/en-us/training/paths/fundamentals-bicep/

## Conventions


### Parameters
```CSharp 
param appServiceAppName string
```
Parameters with default value
```CSharp
param appServiceAppName string = 'yourappservicenamehere'
```

### Expressions
```CSharp
param location string = resourceGroup().location
```

#### OK
```CSharp
param storageAccountName string = uniqueString(resourceGroup().id)
```

#### Better
```CSharp
param storageAccountName string = 'starwarsapp${uniqueString(resourceGroup().id)}'
```

Sometimes the uniqueString() function will create strings that **start with a number**. Some Azure resources, like storage accounts, don't allow their names to start with numbers. This means it's a good idea to use string interpolation to create resource names, like in the preceding example.



### Prod vs. Non-Prod
```CSharp
@allowed([
  'nonprod'
  'prod'
])
param environmentType string
```

`Notice that this code uses some new syntax to specify a list of allowed values for the environmentType parameter. Bicep won't let anyone deploy the template unless they provide one of these values.`

### This is cool
```CSharp
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2V3' : 'F1'
```

# none of these worked for the sandbox subscription 
az account set --subscription '7f3f0dbf-2c85-447e-b404-36cb8070e983'

az deployment group create --template-file main.bicep --parameters environmentType=nonprod

az config set core.allow_broker=true
az account clear
az login

### Commands

```CSharp
 az bicep build -f main.bicep
```
`Compiles a Bicep file into an ARM template. It checks the Bicep file for syntax and semantic errors and generates a corresponding ARM template file.`

```CSharp
az bicep decompile --file main.json
```
`Converts an existing ARM template into an equivalent Bicep file. This command helps you migrate existing ARM templates to Bicep.`

```CSharp
az bicep validate -f main.bicep
```
`Validates a Bicep file for syntax and semantic errors without building or decompiling it. This command is useful for checking the integrity of Bicep code.`


## Works 
```CSharp
Connect-AzAccount
```

## then
```Csharp
New-AzSubscriptionDeployment -Location eastus  -TemplateFile resourceGroup.bicep
```
`Note that it is a Subscription deployment not a resource group deployment.  This is because MOST templates are deployed at the resource group level.`
        

