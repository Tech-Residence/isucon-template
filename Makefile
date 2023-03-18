include .env

container-build:
	docker-compose build

ping:
	docker-compose run ansible-runner ansible all -m ping --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

install-packages%:
	docker-compose run ansible-runner ansible-playbook install_packages.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

prepare-bench%:
	docker-compose run ansible-runner ansible-playbook prepare_bench.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

lint-install-packages:
	docker-compose run ansible-runner ansible-lint install_packages.yaml

lint-prepare-bench:
	docker-compose run ansible-runner ansible-lint prepare_bench.yaml

lint-all: lint-install-packages lint-prepare-bench
