include .env
MOCK_VM_NAME = $(PROJECT_NAME)-mock
MOCK_VM_STATE := $(shell multipass list --format json | jq -r '.list[] | select(.name == "$(MOCK_VM_NAME)") | .state')
MOCK_VM_IP := $(shell multipass list --format json | jq -r '.list[] | select(.name == "$(MOCK_VM_NAME)") | .ipv4[0]')
MOCK_VM_IP_COMMAND := `multipass list --format json | jq -r '.list[] | select(.name == "$(MOCK_VM_NAME)") | .ipv4[0]'`
USER_ID := $(shell id -u $(USER))
USER_GROUP := $(shell id -g $(USER))

container-build:
	COMPOSE_PROJECT_NAME=$(PROJECT_NAME) docker-compose build

mock-start:
ifeq ($(MOCK_VM_STATE),Stopped)
	multipass start $(MOCK_VM_NAME)
	@echo IP: $(MOCK_VM_IP_COMMAND)
else ifeq ($(MOCK_VM_STATE),Running)
	@echo "multipass vm ($(MOCK_VM_NAME)) is already up"
	@echo IP: $(MOCK_VM_IP_COMMAND)
else ifeq ($(MOCK_VM_STATE),)
	multipass launch --name $(MOCK_VM_NAME) --cloud-init mock/cloud-init.yaml
	@echo IP: $(MOCK_VM_IP_COMMAND)
else
	@echo "\"multipass VM $(MOCK_VM_STATE)\" already exists, but it is in an unexpected state"
endif

mock-stop:
	multipass stop $(MOCK_VM_NAME)

mock-destroy:
	multipass delete $(MOCK_VM_NAME)
	multipass purge

mock-ping:
	docker-compose run ansible-runner ansible -i $(MOCK_VM_IP), all -m ping -u ubuntu --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

mock-ansible-playbook-%:
	docker-compose run ansible-runner ansible-playbook -i $(MOCK_VM_IP), ${@:mock-ansible-playbook-%=%}.yaml -u ubuntu --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

ansible-lint-all:
	docker-compose run ansible-runner ansible-lint setup.yaml

ansible-lint-%:
	docker-compose run ansible-runner ansible-lint ${@ansible-lint-%=%}.yaml
