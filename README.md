# K3sVM
Terraform module to create VM in VMware for K3s cluster


#### Cloud-Init
https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment/#:~:text=Cloud%2Dinit%20is%20an%20interesting,OS%20configuration%2C%20without%20manual%20intervention.


this post helped more than most: https://williamlam.com/2022/06/using-the-new-vsphere-guest-os-customization-with-cloud-init-in-vsphere-7-0-update-3.html

and the metadata file: https://kb.vmware.com/s/article/82250#:~:text=Cloud%2Dinit%20metadata%20is%20a,version%201%20or%20version%202.

good example to get it working: https://grantorchard.com/terraform-vsphere-cloud-init/

cloud init variables: https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment-a-step-forward/

#### terraform modules
https://www.terraform.io/language/modules/develop/composition


k3s installed in AWS
https://github.com/sagittaros/terraform-k3s-private-cloud/blob/main/user_data/master/k3s-server-install.sh


##### K3s module?
https://registry.terraform.io/modules/sagittaros/private-cloud/k3s/latest


#### manual k3s cluster build
https://itnext.io/setup-your-own-kubernetes-cluster-with-k3s-b527bf48e36a
