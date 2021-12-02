# Variable blocks
# Default values are set in the pkrvars.hcl file

variable "vpc_region" {
  type    = string
  default = "$${vpc_region}"
}

variable "instance_type" {
  type    = string
  default = "$${instance_type}"
}

variable "username" {
  type    = string
  default = "$${username}"
}

variable "password" {
  type    = string
  default = "$${password}"
}

# Data blocks
# Get the latest Windows Server 2019 image owned by Amazon

data "amazon-ami" "windows_server_2019_ami" {
  filters = {
    name                = "Windows_Server-2019-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "${var.vpc_region}"
}

# Source blocks
# Create a new gold AMI for SharePoint

source "amazon-ebs" "gold_sharepoint_2019" {
  ami_name                    = "gold-ami-sharepoint-2019-{{ `${replace(timestamp(), ":", "_")}` }}"
  associate_public_ip_address = true
  communicator                = "winrm"
  instance_type               = "${var.instance_type}"
  region                      = "${var.vpc_region}"
  source_ami                  = "${data.amazon-ami.windows_server_2019_ami.id}"
  user_data_file              = "./bootstrap_win.txt"
  winrm_password              = "${var.password}"
  winrm_username              = "${var.username}"
}

# Build blocks

build {

  # Source blocks
  sources = ["source.amazon-ebs.gold_sharepoint_2019"]

  # Provisioner blocks

  provisioner "file" {
    destination = "C:\\Temp\\sharepoint_prereqs_dsc.ps1"
    source      = "files/sharepoint_prereqs_dsc.ps1"
  }

  provisioner "file" {
    destination = "C:\\Temp\\sharepoint_binaries_dsc.ps1"
    source      = "files/sharepoint_binaries_dsc.ps1"
  }

  provisioner "file" {
    destination = "C:\\Temp\\sharepoint_updates_dsc.ps1"
    source      = "files/sharepoint_updates_dsc.ps1"
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force", 
                         "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted", 
                         "Install-Module SharePointDSC", 
                         "Install-Module xDownloadFile"]
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["Set-Location C:\\Temp;./sharepoint_prereqs_dsc.ps1", 
                         "Start-DSCConfiguration -Path C:\\Temp\\SharePoint2019Prereqs -Wait"]
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["Set-Location C:\\Temp;./sharepoint_binaries_dsc.ps1", 
                         "Start-DSCConfiguration -Path C:\\Temp\\SharePointBinaries -Wait"]
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["$volume = Mount-DiskImage C:\\binaries\\officeserver.img -PassThru | Get-Volume", 
                         "$drive = $volume.DriveLetter + \":\\*\"", 
                         "Copy-Item $drive C:\\binaries -recurse"]
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["Set-Location C:\\Temp;./sharepoint_updates_dsc.ps1", 
                         "Start-DSCConfiguration -Path C:\\Temp\\SharePointUpdates -Wait"]
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "${build.Password}"
    inline            = ["C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule"]
  }

}
