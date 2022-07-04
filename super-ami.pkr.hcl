variable "tipo_instancia" {default = "t2.micro"}
variable "usuario_ssh" {default = "ubuntu"}
variable "nombre_de_ami" {default = "super-ami"}
variable "proyecto" {default = "cicd"}

data "amazon-ami" "os_ubuntu_22_04" {
    filters   = {
        virtualization-type           = "hvm"
        name                          = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
        root-device-type              = "ebs"
    }
    owners         = ["099720109477"]
    most_recent    = true
}

source "amazon-ebs" "mi_ami_cicd" {
    source_ami     =   data.amazon-ami.os_ubuntu_22_04.id
    instance_type  =   var.tipo_instancia
    ssh_username   =   var.usuario_ssh
    ami_name       =   var.nombre_de_ami

    tags = {
        Name = "ami-personalizada-${var.proyecto}"
        OS_version          = "ubuntu"
        Release             = "Latest"
        Base_AMI_ID         = "{{ .SourceAMI }}"
        Base_AMI_Name       = "{{ .SourceAMIName }}"
    }

    launch_block_device_mappings {
        device_name           = "/dev/sda1"
        volume_size           = 40
        volume_type           = "gp3"
        delete_on_termination = true
    }

}

build {
    sources = ["source.amazon-ebs.mi_ami_cicd"]

    provisioner "shell" {
      script ="bootstrap.sh"    
    }
}