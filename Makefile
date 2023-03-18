include .env

container-build:
	docker-compose build

ping:
	docker-compose run ansible-runner ansible all -m ping --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

setup%:
	docker-compose run ansible-runner ansible-playbook setup.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

prepare-bench%:
	docker-compose run ansible-runner ansible-playbook prepare_bench.yaml --private-key="/tmp/.ssh/$(PRIVATE_KEY)"

lint-setup:
	docker-compose run ansible-runner ansible-lint setup.yaml

lint-prepare-bench:
	docker-compose run ansible-runner ansible-lint prepare_bench.yaml

lint-all: lint-setup lint-prepare-bench
