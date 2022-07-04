#!/bin/bash
NOMBRE_SERVIDOR=pepito
sudo hostnamectl set-hostname $NOMBRE_SERVIDOR

sudo timedatectl set-timezone Europe/Paris

sudo sed -i 's/^%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo mkdir -p /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chown ansible:ansible /home/ansible/.ssh/

sudo touch /home/ansible/.ssh/authorized_keys
sudo chmod 644 /home/ansible/.ssh/authorized_keys
sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcIqesf51uFB2a9tqLpJi70sNW7O9rBDTgBX8WWnMNN Ansible" | sudo tee -a /home/ansible/.ssh/authorized_keys 
sudo chown -R ansible:ansible /home/ansible
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys


USUARIO=ansible
CONTRASENA=123
sudo useradd -m -s /bin/bash -G sudo $USUARIO
echo "$USUARIO:$CONTRASENA" | sudo chpasswd

sudo touch /etc/sudoers.d/$USUARIO
sudo chmod 440 /etc/sudoers.d/$USUARIO
echo "$USUARIO ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USUARIO

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y wget curl git

echo "#!/bin/bash
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo usermod -aG docker ansible
sudo systemctl start docker
sudo systemctl enable docker" | sudo tee -a /home/ansible/instalar-docker.sh
