## Deploy the Golden-RHEL VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://raw.githubusercontent.com/casa-de-vops/azvmimagebuilder/refs/heads/main/templates/10_Virtual_Machine_Deployment_Template/azuredeploy.parameters.json)

> **Tip**  
> This now uses the internal template at `./templates/10_Virtual_Machine_Deployment_Template/azuredeploy.json` and the parameter file at `./templates/10_Virtual_Machine_Deployment_Template/azuredeploy.parameters.json`.  
> The `/versions/latest` segment in the template ensures the VM always uses the most recently published version of **GoldenRHELImage**.
