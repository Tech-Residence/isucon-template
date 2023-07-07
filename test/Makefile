VM_NAME = isucon-template-test

tmp:
	mkdir -p tmp

tmp/id_ed25519: tmp
	ssh-keygen -t ed25519 -f tmp/id_ed25519 -N ""

tmp/id_ed25519.pub: tmp
	ssh-keygen -t ed25519 -f tmp/id_ed25519 -N ""

tmp/cloud-init.yaml: tmp/id_ed25519.pub tmp/id_ed25519
	sed "s|#{ssh_pub_key}|$(shell cat tmp/id_ed25519.pub)|" cloud-init-template.yaml > tmp/cloud-init.yaml

.PHONY: launch-test-server
launch-test-server: tmp/cloud-init.yaml
	multipass launch --name $(VM_NAME) --cloud-init tmp/cloud-init.yaml

.PHONY: echo-test-server-ip
echo-test-server-ip: launch-test-server
	echo $(shell multipass info isucon-template-test --format json | jq -r '.info."$(VM_NAME)".ipv4[0]')

tmp/inventory: launch-test-server
	@echo "[all]" > tmp/inventory.ini
	@echo "server-1 ansible_host=$(shell multipass info isucon-template-test --format json | jq -r '.info."$(VM_NAME)".ipv4[0]')" >> tmp/inventory.ini
	@echo "[all:vars]" >> tmp/inventory.ini
	@echo "ansible_user=ubuntu" >> tmp/inventory.ini

start-test-server: tmp/inventory
	echo "SERVER_IP: $(shell multipass info isucon-template-test --format json | jq -r '.info."$(VM_NAME)".ipv4[0]')"

.PHONY: destroy-test-server
destroy-test-server:
	multipass delete $(VM_NAME)
	multipass purge

.PHONY: ping-test-server
ping-test-server:
	docker-compose run ansible-runner ansible -m ping all -i /home/ubuntu/tmp/inventory.ini --private-key="/home/ubuntu/tmp/id_ed25519"

.PHONY: install-packages
install-packages:
	docker-compose run ansible-runner ansible-playbook install_packages.yaml -i /home/ubuntu/tmp/inventory.ini --private-key="/home/ubuntu/tmp/id_ed25519"

