## Deploy the Golden-RHEL VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.json)

> **Tip**  
> This now uses the remote template at `templates/10_Virtual_Machine_Deployment_Template/azuredeploy.json` and the parameter file at `templates/10_Virtual_Machine_Deployment_Template/azuredeploy.parameters.json`.  
> The `/versions/latest` segment in the template ensures the VM always uses the most recently published version of **GoldenRHELImage**.
