.DEFAULT_GOAL := help
.PHONY: docs
SRC_DIRS = ./tutor ./tests ./bin ./docs
BLACK_OPTS = --exclude templates ${SRC_DIRS}

###### Development

docs: ## Build HTML documentation
	$(MAKE) -C docs

compile-requirements: ## Compile requirements files
	pip-compile ${COMPILE_OPTS} requirements/base.in
	pip-compile ${COMPILE_OPTS} requirements/dev.in
	pip-compile ${COMPILE_OPTS} requirements/docs.in

upgrade-requirements: ## Upgrade requirements files
	$(MAKE) compile-requirements COMPILE_OPTS="--upgrade"

build-pythonpackage: ## Build the "tutor" python package for upload to pypi
	python -m build --sdist

push-pythonpackage: ## Push python package to pypi
	twine upload --skip-existing dist/tutor-$(shell make version).tar.gz

test: test-lint test-unit test-types test-format test-pythonpackage ## Run all tests by decreasing order of priority

test-static: test-lint test-types test-format  ## Run only static tests

test-format: ## Run code formatting tests
	black --check --diff $(BLACK_OPTS)

test-lint: ## Run code linting tests
	pylint --disable=all --enable=E --enable=unused-import,unused-argument,f-string-without-interpolation --ignore=templates --ignore=docs/_ext ${SRC_DIRS}

test-unit: ## Run unit tests
	python -m unittest discover tests

test-types: ## Check type definitions
	mypy --exclude=templates --ignore-missing-imports --implicit-reexport --strict ${SRC_DIRS}

test-pythonpackage: build-pythonpackage ## Test that package can be uploaded to pypi
	twine check dist/tutor-$(shell make version).tar.gz

test-k8s: ## Validate the k8s format with kubectl. Not part of the standard test suite.
	tutor k8s apply --dry-run=client --validate=true

format: ## Format code automatically
	black $(BLACK_OPTS)

isort: ##  Sort imports. This target is not mandatory because the output may be incompatible with black formatting. Provided for convenience purposes.
	isort --skip=templates ${SRC_DIRS}

changelog-entry: ## Create a new changelog entry
	scriv create

changelog: ## Collect changelog entries in the CHANGELOG.md file
	scriv collect

###### Code coverage

coverage: ## Run unit-tests before analyzing code coverage and generate report
	$(MAKE) --keep-going coverage-tests coverage-report

coverage-tests: ## Run unit-tests and analyze code coverage
	coverage run -m unittest discover

coverage-report: ## Generate CLI report for the code coverage
	coverage report

coverage-html: coverage-report ## Generate HTML report for the code coverage
	coverage html

coverage-browse-report: coverage-html ## Open the HTML report in the browser
	sensible-browser htmlcov/index.html

###### Continuous integration tasks

bundle: ## Bundle the tutor package in a single "dist/tutor" executable
	pyinstaller tutor.spec

bootstrap-dev: ## Install dev requirements
	pip install .[dev]

bootstrap-dev-plugins: bootstrap-dev  ## Install dev requirements and all plugins
	pip install .[full]

pull-base-images: # Manually pull base images
	docker image pull docker.io/ubuntu:22.04

ci-info: ## Print info about environment
	python --version
	pip --version

ci-test-bundle: ## Run basic tests on bundle
	ls -lh ./dist/tutor
	./dist/tutor --version
	./dist/tutor config printroot
	yes "" | ./dist/tutor config save --interactive
	./dist/tutor config save
	./dist/tutor plugins list
	./dist/tutor plugins enable android discovery forum license mfe minio notes webui xqueue
	./dist/tutor plugins list
	./dist/tutor license --help

ci-bootstrap-images:
	pip install .
	tutor config save

###### Additional commands

version: ## Print the current tutor version
	@python -c 'import io, os; about = {}; exec(io.open(os.path.join("tutor", "__about__.py"), "rt", encoding="utf-8").read(), about); print(about["__package_version__"])'

ESCAPE = 
help: ## Print this help
	@grep -E '^([a-zA-Z_-]+:.*?## .*|######* .+)$$' Makefile \
		| sed 's/######* \(.*\)/@               $(ESCAPE)[1;31m\1$(ESCAPE)[0m/g' | tr '@' '\n' \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-30s\033[0m %s\n", $$1, $$2}'
