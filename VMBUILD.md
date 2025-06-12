## Deploy the Golden-LINUX VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.json?parameters-uri=https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.linux.parameters.json)

## Deploy the Golden-RHEL VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.json?parameters-uri=https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.linux.rhel.parameters.json)

> **Tip**  
> This now uses the remote template at `templates/10_Virtual_Machine_Deployment_Template/azuredeploy.json` and you can also provide a parameter file by appending `?parameters-uri=<URL-ENCODED-PARAM-FILE>` to the link.  
> The `/versions/latest` segment in the template ensures the VM always uses the most recently published version of the image.