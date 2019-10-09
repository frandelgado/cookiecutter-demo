WEB=`docker-compose ps | grep gunicorn | cut -d\  -f 1 | head -n 1`
NODE=`docker-compose ps | grep npm | cut -d\  -f 1 | head -n 1`
WEBS=`docker-compose ps | grep gunicorn | cut -d\  -f 1 `
FILE=docker-compose.yml
BACKUPS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../backups/)
ENV_STAGE = ``

#########
#ACTIONS#
#########

build:
	docker-compose -f $(FILE) build

scaleweb:
	docker-compose -f $(FILE) scale web=5

loadinitialdb:
	docker exec $(WEB) /bin/sh -c "python manage.py loaddata fixtures/initial/*.json"

loadtestdb: loadinitialdb
	docker exec $(WEB) /bin/sh -c "python manage.py loaddata fixtures/testing/*.json"

up:
	docker-compose -f $(FILE) up -d web nginx postgres node celeryworker celerybeat redis




deploy: FILE=production.yml
deploy: build scaleweb up set-django loadinitialdb ps

start:
	docker-compose -f $(FILE) start

stop:
	docker-compose -f $(FILE) stop

ps:
	docker-compose -f $(FILE) ps
	@echo "---------------------------"
	@echo "Web:     `ps aux | grep /usr/local/bin/gunicorn | grep -v grep | wc -l` threads running"

clean: stop
	docker-compose rm -f

restart: clean build up ps
	@echo "Restarted all containers"

reboot-db:
	docker exec cookiecutter-postgres /bin/sh -c "dropdb -U postgres postgres"
	docker exec cookiecutter-postgres /bin/sh -c "createdb -U postgres postgres"

########
#SHELLS#
########

shell-nginx:
	docker exec -ti cookiecutter-nginx bash

shell-web:
	docker exec -ti $(WEB) bash

shell-db:
	docker exec -ti cookiecutter-postgres bash

shell-node:
	docker exec -ti $(NODE) bash

shell-celeryw:
	docker exec -ti cookiecutter-celeryworker bash

shell-celeryb:
	docker exec -ti cookiecutter-celerybeat bash

######
#LOGS#
######

log-nginx:
	docker-compose logs nginx

log-web:
	docker-compose logs web

log-web-live:
	docker logs --tail 50 --follow --timestamps $(WEB)

log-node:
	docker-compose logs node

log-node-live:
	docker logs --tail 50 --follow --timestamps $(NODE)

log-db:
	docker-compose logs db

log-celeryw:
	docker-compose logs celeryworker

log-celeryb:
	docker-compose logs celerybeat

#######
#Tests#
#######

pdb:
	@echo "PDB (Exit: CONTROL + P + CONTROL + Q)"
	docker attach $(WEB)

pylint:
	@echo "Running Pylint"
	docker exec $(WEB) /bin/sh -c "pylint *"

py-tests:
	@echo "Running python tests"
	docker exec $(WEB) /bin/sh -c "coverage run --source='.' manage.py test"

test-all:
	@echo "Running all tests"
	@echo "Running all tests in backend"
	docker exec $(WEB) /bin/sh -c "coverage run --source='.' manage.py test"
	docker exec $(WEB) /bin/sh -c "pylint *"
	docker exec $(WEB) /bin/sh -c "coverage report -m"
	@echo "Running all tests in frontend"
	docker exec $(NODE) /bin/sh -c "./node_modules/.bin/eslint ."

eslint:
	@echo "Running eslint"
	docker exec $(NODE) /bin/sh -c "./node_modules/.bin/eslint ."

coverage:
	docker exec $(WEB) /bin/sh -c "coverage report -m"



############
#DJANGO OPS#
############

collectstatic:
	@echo $(shell for container in $(WEBS); do\
		docker exec $$container /bin/sh -c "python manage.py collectstatic --noinput" ;\
	done)

migrate:
	docker exec $(WEB) /bin/sh -c "python manage.py migrate"

makemigrations:
	docker exec $(WEB) /bin/sh -c "python manage.py makemigrations"

compilemessages:
	@echo $(shell for container in $(WEBS); do\
		docker exec $$container /bin/sh -c "python manage.py compilemessages" ;\
	done)

set-django: collectstatic migrate compilemessages
	@echo "Django environment setup complete."

#########
#BACKUPS#
#########

backup-db:
	if [ ! -d $(BACKUPS_DIR) ] ; then mkdir $(BACKUPS_DIR) ; fi
	$(eval DUMP_NAME = $(BACKUPS_DIR)/`date +%Y%m%d`$(ENV_STAGE)_sac_dump_.gz)
	docker exec -t cookiecutter-postgres pg_dumpall -c -U postgres | gzip > $(DUMP_NAME)


#############
#DEVELOPMENT#
#############
dev-restart:
	docker-compose -f development.yml stop
	docker-compose development.yml rm -f
	docker-compose -f development.yml build
	docker-compose -f development.yml up -d web nginx postgres node

deploy-dev:
	make clean build up set-django FILE=docker-compose.yml
