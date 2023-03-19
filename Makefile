include .env

.PHONY: container-build
container-build:
	docker-compose build

.PHONY: ping
ping:
	docker-compose run ansible-runner ansible all -m ping --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

.PHONY: install-packages-all
install-packages-all:
	docker-compose run ansible-runner ansible-playbook install_packages.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

.PHONY: install-packages-%
install-packages-%:
	docker-compose run ansible-runner ansible-playbook install_packages.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)" --limit server-${@:install-packages-%=%}

.PHONY: prepare-bench-all
prepare-bench:
	docker-compose run ansible-runner ansible-playbook prepare_bench.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

.PHONY: prepare-bench-%
prepare-bench-%:
	docker-compose run ansible-runner ansible-playbook prepare_bench.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)" --limit server-${@:prepare-bench-%=%}

.PHONY: lint-install-packages
lint-install-packages:
	docker-compose run ansible-runner ansible-lint install_packages.yaml

.PHONY: lint-prepare-bench
lint-prepare-bench:
	docker-compose run ansible-runner ansible-lint prepare_bench.yaml

.PHONY: lint-all
lint-all: lint-install-packages lint-prepare-bench
