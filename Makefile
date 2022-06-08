AUTHOR = "Matt <mattjensen@fastmail.com>"
APP = app
ML = ml
POETRY = ~/.poetry/bin/poetry
PYTHON = python3.9
PYTHON_VERSION = 3.9.13
# PYTHON_VERSION = 3.6.1
#PYTHON = python3.8
#PYTHON_VERSION = 3.8.9
#PYTHON_VERSION = 3.8.9
CORES = 4

all:

python: $(PYTHON)

ml: project
	$(POETRY) run django-admin startapp $(ML)

project: django
	$(POETRY) run django-admin startproject $(APP) ./

django: pyproject.toml
	poetry add Django

pyproject.toml: $(POETRY)
	$(POETRY) init --name $(APP) --python ">=3.8,<4.0" --author "$(AUTHOR)" -n

$(POETRY):
	if [! -f ~/.poetry/bin/poetry ]; \
	then curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -; \
	fi
	poetry env use $(PYTHON)

$(PYTHON):
	curl -O https://www.python.org/ftp/python/$(PYTHON_VERSION)/Python-$(PYTHON_VERSION).tar.xz
	tar -xf Python-$(PYTHON_VERSION).tar.xz
	cd Python-$(PYTHON_VERSION)/ && \
	./configure && \
	make -j $(CORES) && \
	sudo make altinstall
	#./configure --enable-optimizations && \

test-install: 

test: $(POETRY) test-install
	$(POETRY) run pytest

watch: $(POETRY)
	while true; do inotifywait -e close_write **/*.py; make test; done

clean:
	rm -rf Python-$(PYTHON_VERSION).tar.xz Python-$(PYTHON_VERSION)/

serve: project
	$(POETRY) run python manage.py runserver
gitignore:
	curl https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore >> .gitignore
