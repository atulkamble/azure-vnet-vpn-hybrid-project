## 📦 Project: **Azure VPN Gateway Setup**

---

## 🔷 Prerequisites

✅ Azure Resource Group
✅ Azure Virtual Network
✅ Azure Gateway Subnet
✅ Azure Public IP
✅ Azure VPN Gateway

---

## 📌 Create Common Resources (for both S2S and P2S)

### 📜 `azure-common-vpn-setup.sh`

```bash
# Variables
LOCATION="eastus"
RG_NAME="MyVPNResourceGroup"
VNET_NAME="MyVNet"
SUBNET_NAME="MySubnet"
GATEWAY_SUBNET_NAME="GatewaySubnet"
VNET_ADDRESS_PREFIX="10.0.0.0/16"
SUBNET_PREFIX="10.0.1.0/24"
GATEWAY_SUBNET_PREFIX="10.0.255.0/27"
PUBLIC_IP_NAME="MyVPNGatewayPublicIP"
VPN_GATEWAY_NAME="MyVPNGateway"
VPN_TYPE="RouteBased"
VPN_SKU="VpnGw1"

# Create Resource Group
az group create --name $RG_NAME --location $LOCATION

# Create Virtual Network
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --address-prefix $VNET_ADDRESS_PREFIX \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix $SUBNET_PREFIX

# Create Gateway Subnet
az network vnet subnet create \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name $GATEWAY_SUBNET_NAME \
  --address-prefix $GATEWAY_SUBNET_PREFIX

# Create Public IP for VPN Gateway
az network public-ip create \
  --resource-group $RG_NAME \
  --name $PUBLIC_IP_NAME \
  --sku Standard

# Create VPN Gateway
az network vnet-gateway create \
  --resource-group $RG_NAME \
  --name $VPN_GATEWAY_NAME \
  --public-ip-address $PUBLIC_IP_NAME \
  --vnet $VNET_NAME \
  --gateway-type Vpn \
  --vpn-type $VPN_TYPE \
  --sku $VPN_SKU \
  --no-wait
```

---

## 🔷 📡 Site-to-Site VPN Setup (connect on-prem VPN device to Azure)

**You’ll need your on-prem VPN public IP and IP address space**

### 📜 `azure-s2s-connection.sh`

```bash
# Variables
ON_PREM_GATEWAY_IP="203.0.113.10"  # replace with real public IP
ON_PREM_ADDRESS_PREFIX="192.168.1.0/24"
LOCAL_NETWORK_GATEWAY_NAME="MyOnPremiseGateway"
CONNECTION_NAME="MyS2SConnection"
SHARED_KEY="myS2Ssharedkey"

# Create Local Network Gateway (on-prem VPN details)
az network local-gateway create \
  --resource-group $RG_NAME \
  --name $LOCAL_NETWORK_GATEWAY_NAME \
  --gateway-ip-address $ON_PREM_GATEWAY_IP \
  --local-address-prefixes $ON_PREM_ADDRESS_PREFIX

# Create Site-to-Site VPN connection
az network vpn-connection create \
  --resource-group $RG_NAME \
  --name $CONNECTION_NAME \
  --vnet-gateway1 $VPN_GATEWAY_NAME \
  --local-gateway2 $LOCAL_NETWORK_GATEWAY_NAME \
  --shared-key $SHARED_KEY \
  --enable-bgp false
```

---

## 🔷 💻 Point-to-Site VPN Setup (client devices connect securely)

### 📜 `azure-p2s-config.sh`

```bash
# Variables
P2S_ADDRESS_POOL="172.16.0.0/24"
CERT_NAME="P2SRootCert"
CERT_PUBLIC_KEY="rootcert.pem"  # must be pre-generated Base64-encoded cert

# Update VPN Gateway config for P2S
az network vnet-gateway update \
  --resource-group $RG_NAME \
  --name $VPN_GATEWAY_NAME \
  --set vpnClientConfiguration.vpnClientAddressPool.addressPrefixes=$P2S_ADDRESS_POOL

# Upload root certificate for client authentication
az network vnet-gateway root-cert create \
  --resource-group $RG_NAME \
  --gateway-name $VPN_GATEWAY_NAME \
  --name $CERT_NAME \
  --public-cert-data "$(cat $CERT_PUBLIC_KEY)"
```

👉 For client certificates:
You’ll need to generate a **self-signed root cert** and client cert (on Windows/macOS/Linux) — can help you with those commands too if you’d like.

---

## 📦 📌 How to Run:

```bash
bash azure-common-vpn-setup.sh
bash azure-s2s-connection.sh   # for Site-to-Site
bash azure-p2s-config.sh       # for Point-to-Site
```

---

## ✅ Summary:

* **azure-common-vpn-setup.sh** → creates RG, VNet, GatewaySubnet, Public IP, VPN Gateway
* **azure-s2s-connection.sh** → defines local network gateway (on-prem) and S2S connection
* **azure-p2s-config.sh** → configures VPN Gateway for P2S connections with address pool and cert

