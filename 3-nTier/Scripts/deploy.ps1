Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId "36da8c44-d1a8-4e47-9515-7ce3097645fc"    #MSDN/Visual Studio Enterprise

#Get-AzureRmResourceProvider -ListAvailable

$filespec="C:\Users\KBergman\Source\Repos\AzureCLI\3-nTier\Templates"
$rg  = "play3"
$loc = "CentralUS"

New-AzureRmResourceGroup -Location $loc -Name $rg

New-AzureRmResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$filespec\azuredeploy.json" -TemplateParameterFile "$filespec\azuredeploy.parameters.json"    
                                                  
