param networkInterfaces_VM_ERP_01VMNic_name string
param networkInterfaces_VM_Lab_Bicep_nic_name string
param networkSecurityGroups_NSG_Lab_VMs_name string
param networkSecurityGroups_VM_ERP_01NSG_name string
param publicIPAddresses_VM_ERP_01PublicIP_name string
param publicIPAddresses_VM_Lab_Bicep_ip_name string
param virtualMachines_VM_ERP_01_name string
param virtualMachines_VM_Lab_Bicep_name string
param virtualNetworks_VNet_Lab_name string

resource networkSecurityGroups_NSG_Lab_VMs_name_resource 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  location: 'eastus'
  name: networkSecurityGroups_NSG_Lab_VMs_name
  properties: {
    securityRules: [
      {
        id: networkSecurityGroups_NSG_Lab_VMs_name_Allow_SSH.id
        name: 'Allow-SSH'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '22'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '200.29.3.50/32'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_VM_ERP_01NSG_name_resource 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  location: 'eastus'
  name: networkSecurityGroups_VM_ERP_01NSG_name
  properties: {
    securityRules: [
      {
        id: networkSecurityGroups_VM_ERP_01NSG_name_default_allow_ssh.id
        name: 'default-allow-ssh'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '22'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
    ]
  }
}

resource publicIPAddresses_VM_ERP_01PublicIP_name_resource 'Microsoft.Network/publicIPAddresses@2025-07-01' = {
  location: 'eastus'
  name: publicIPAddresses_VM_ERP_01PublicIP_name
  properties: {
    idleTimeoutInMinutes: 4
    ipAddress: '13.82.147.231'
    ipTags: []
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource publicIPAddresses_VM_Lab_Bicep_ip_name_resource 'Microsoft.Network/publicIPAddresses@2025-07-01' = {
  location: 'eastus'
  name: publicIPAddresses_VM_Lab_Bicep_ip_name
  properties: {
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
    idleTimeoutInMinutes: 4
    ipAddress: '20.163.209.124'
    ipTags: []
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource virtualMachines_VM_ERP_01_name_resource 'Microsoft.Compute/virtualMachines@2026-03-01' = {
  location: 'eastus'
  name: virtualMachines_VM_ERP_01_name
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v7'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_VM_ERP_01VMNic_name_resource.id
        }
      ]
    }
    osProfile: {
      adminUsername: 'azureuser'
      allowExtensionOperations: true
      computerName: virtualMachines_VM_ERP_01_name
      linuxConfiguration: {
        disablePasswordAuthentication: true
        enableVMAgentPlatformUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'ImageDefault'
        }
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUaeiZalrN1/BdRoz65MllqDnE1k7oFrwBxCEHi+PwZB6s/B+hwzXQ1dYWHSiZJsgo+kuVfyNlgewwgGJDiGESx8EyhNL/wmmggSvx6fmgrbUmswCsblYAk90calU3mNFL8ODogCrfeU9PjI5vH67fR32ry7Ni3yRE8ILrOZq5S/M5fenp/3iyx4SWP2dlR4mGLWZHrh8x5Oxv4XVNT8+IDE+5LpzbQgdgr6KwgtaJMZsndZgeEAvO6/6yp9X01v2ZGNNUv6IOMnSwAY6zNnCvXacxSL+9aJeHAiGL3+lEdGBSFYr7iCsGC5eZOyqyZPhbyKD5C2TXnU22LUqqQa7J'
              path: '/home/azureuser/.ssh/authorized_keys'
            }
          ]
        }
      }
      requireGuestProvisionSignal: true
      secrets: []
    }
    securityProfile: {
      securityType: 'Standard'
    }
    storageProfile: {
      dataDisks: []
      diskControllerType: 'NVMe'
      imageReference: {
        offer: '0001-com-ubuntu-server-jammy'
        publisher: 'Canonical'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Detach'
        diskSizeGB: 30
        managedDisk: {
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_VM_ERP_01_name}_disk1_b483c0bfd00d439186c8d49479089680'
          )
          storageAccountType: 'Premium_LRS'
        }
        name: '${virtualMachines_VM_ERP_01_name}_disk1_b483c0bfd00d439186c8d49479089680'
        osType: 'Linux'
      }
    }
  }
}

resource virtualMachines_VM_Lab_Bicep_name_resource 'Microsoft.Compute/virtualMachines@2026-03-01' = {
  location: 'eastus'
  name: virtualMachines_VM_Lab_Bicep_name
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v7'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_VM_Lab_Bicep_nic_name_resource.id
        }
      ]
    }
    osProfile: {
      adminUsername: 'azureuser'
      allowExtensionOperations: true
      computerName: virtualMachines_VM_Lab_Bicep_name
      linuxConfiguration: {
        disablePasswordAuthentication: true
        enableVMAgentPlatformUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'ImageDefault'
        }
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUaeiZalrN1/BdRoz65MllqDnE1k7oFrwBxCEHi+PwZB6s/B+hwzXQ1dYWHSiZJsgo+kuVfyNlgewwgGJDiGESx8EyhNL/wmmggSvx6fmgrbUmswCsblYAk90calU3mNFL8ODogCrfeU9PjI5vH67fR32ry7Ni3yRE8ILrOZq5S/M5fenp/3iyx4SWP2dlR4mGLWZHrh8x5Oxv4XVNT8+IDE+5LpzbQgdgr6KwgtaJMZsndZgeEAvO6/6yp9X01v2ZGNNUv6IOMnSwAY6zNnCvXacxSL+9aJeHAiGL3+lEdGBSFYr7iCsGC5eZOyqyZPhbyKD5C2TXnU22LUqqQa7J'
              path: '/home/azureuser/.ssh/authorized_keys'
            }
          ]
        }
      }
      requireGuestProvisionSignal: true
      secrets: []
    }
    securityProfile: {
      securityType: 'Standard'
    }
    storageProfile: {
      dataDisks: []
      diskControllerType: 'NVMe'
      imageReference: {
        offer: '0001-com-ubuntu-server-jammy'
        publisher: 'Canonical'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Detach'
        diskSizeGB: 30
        managedDisk: {
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_VM_Lab_Bicep_name}_disk1_cd876e8d01704c59bff276475b139b94'
          )
          storageAccountType: 'Standard_LRS'
        }
        name: '${virtualMachines_VM_Lab_Bicep_name}_disk1_cd876e8d01704c59bff276475b139b94'
        osType: 'Linux'
      }
    }
  }
}

resource networkSecurityGroups_NSG_Lab_VMs_name_Allow_SSH 'Microsoft.Network/networkSecurityGroups/securityRules@2025-07-01' = {
  name: '${networkSecurityGroups_NSG_Lab_VMs_name}/Allow-SSH'
  properties: {
    access: 'Allow'
    destinationAddressPrefix: '*'
    destinationAddressPrefixes: []
    destinationPortRange: '22'
    destinationPortRanges: []
    direction: 'Inbound'
    priority: 100
    protocol: 'Tcp'
    sourceAddressPrefix: '200.29.3.50/32'
    sourceAddressPrefixes: []
    sourcePortRange: '*'
    sourcePortRanges: []
  }
  dependsOn: [
    networkSecurityGroups_NSG_Lab_VMs_name_resource
  ]
}

resource networkSecurityGroups_VM_ERP_01NSG_name_default_allow_ssh 'Microsoft.Network/networkSecurityGroups/securityRules@2025-07-01' = {
  name: '${networkSecurityGroups_VM_ERP_01NSG_name}/default-allow-ssh'
  properties: {
    access: 'Allow'
    destinationAddressPrefix: '*'
    destinationAddressPrefixes: []
    destinationPortRange: '22'
    destinationPortRanges: []
    direction: 'Inbound'
    priority: 1000
    protocol: 'Tcp'
    sourceAddressPrefix: '*'
    sourceAddressPrefixes: []
    sourcePortRange: '*'
    sourcePortRanges: []
  }
  dependsOn: [
    networkSecurityGroups_VM_ERP_01NSG_name_resource
  ]
}

resource virtualNetworks_VNet_Lab_name_resource 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  location: 'eastus'
  name: virtualNetworks_VNet_Lab_name
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    enableDdosProtection: false
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        id: virtualNetworks_VNet_Lab_name_Subnet_VMs.id
        name: 'Subnet-VMs'
        properties: {
          addressPrefix: '10.10.1.0/24'
          defaultOutboundAccess: false
          delegations: []
          networkSecurityGroup: {
            id: networkSecurityGroups_NSG_Lab_VMs_name_resource.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
  }
}

resource networkInterfaces_VM_Lab_Bicep_nic_name_resource 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  kind: 'Regular'
  location: 'eastus'
  name: networkInterfaces_VM_Lab_Bicep_nic_name
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    disableTcpStateTracking: false
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    ipConfigurations: [
      {
        id: '${networkInterfaces_VM_Lab_Bicep_nic_name_resource.id}/ipConfigurations/ipconfig1'
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddress: '10.10.1.5'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_VM_Lab_Bicep_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_VNet_Lab_name_Subnet_VMs.id
          }
        }
      }
    ]
    nicType: 'Standard'
  }
}

resource virtualNetworks_VNet_Lab_name_Subnet_VMs 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: '${virtualNetworks_VNet_Lab_name}/Subnet-VMs'
  properties: {
    addressPrefix: '10.10.1.0/24'
    defaultOutboundAccess: false
    delegations: []
    networkSecurityGroup: {
      id: networkSecurityGroups_NSG_Lab_VMs_name_resource.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_VNet_Lab_name_resource
  ]
}

resource networkInterfaces_VM_ERP_01VMNic_name_resource 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  kind: 'Regular'
  location: 'eastus'
  name: networkInterfaces_VM_ERP_01VMNic_name
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    disableTcpStateTracking: false
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    ipConfigurations: [
      {
        id: '${networkInterfaces_VM_ERP_01VMNic_name_resource.id}/ipConfigurations/ipconfigVM-ERP-01'
        name: 'ipconfigVM-ERP-01'
        properties: {
          primary: true
          privateIPAddress: '10.10.1.4'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_VM_ERP_01PublicIP_name_resource.id
          }
          subnet: {
            id: virtualNetworks_VNet_Lab_name_Subnet_VMs.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_VM_ERP_01NSG_name_resource.id
    }
    nicType: 'Standard'
  }
}
