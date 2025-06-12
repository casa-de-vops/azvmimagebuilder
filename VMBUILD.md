## Deploy the Golden-RHEL VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fdev.azure.com%2Forgname%2Fprojectname%2F_apis%2Fgit%2Frepositories%2Freponame%2Fitems%3FscopePath%3D%2freponame%2fazuredeploy.json%26api-version%3D6.0)

> **Tip**  
> This now uses the internal template at `./templates/10_Virtual_Machine_Deployment_Template/azuredeploy.json` and the parameter file at `./templates/10_Virtual_Machine_Deployment_Template/azuredeploy.parameters.json`.  
> The `/versions/latest` segment in the template ensures the VM always uses the most recently published version of **GoldenRHELImage**.
