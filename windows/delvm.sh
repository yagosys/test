#!/bin/bash -x
az vm delete \
 --resource-group wanyvm \
 --name myVM -y
