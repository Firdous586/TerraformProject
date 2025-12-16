locals{
    resource_location ="East US"
    resource_group_name ="tf-rg"
    resource_network_name ="tf-vnet"
    address_space= ["10.0.0.0/16"]
    subnet_address_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
    subnets=[
        {
            name = "tf-subnet"
            address_prefixes =  ["10.0.1.0/24"]
        },
        {
            name ="tf-subnet2"
            address_prefixes = ["10.0.2.0/24"]
        }
]
}