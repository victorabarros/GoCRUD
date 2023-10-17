YELLOW=$(shell printf '\033[0;1;33m')
COLOR_OFF=$(shell printf '\033[0;1;0m')

DB_DOCKER_IMAGE=postgres:alpine
DB_DOCKER_NAME=gocrud-db
DB_SCHEMA=postgres_db
DB_ROOT_USER=postgres_user
CONFIG_FILE_PATH=.env

run:
	@go run cmd/api/main.go

start-db:
	@echo '${YELLOW}Starting Postgres container${COLOR_OFF}'
	@docker run --name ${DB_DOCKER_NAME} -d \
		--env-file ${CONFIG_FILE_PATH} ${DB_DOCKER_IMAGE}
	@sleep 1

finish-db:
	@echo '${YELLOW}Finishing database container${COLOR}'
	@docker rm -f ${DB_DOCKER_NAME}

query-db:
	@docker exec -it ${DB_DOCKER_NAME} psql -d ${DB_SCHEMA} -U ${DB_ROOT_USER}

query-persons-db:
	@docker exec ${DB_DOCKER_NAME} psql -d ${DB_SCHEMA} -U ${DB_ROOT_USER} \
		--command='SELECT * FROM persons;'

migrate-db:
	@echo '${YELLOW}Running migrations${COLOR}'
	@docker cp ./database/migrations ${DB_DOCKER_NAME}:/
	@docker exec ${DB_DOCKER_NAME} sh -c \
		'ls migrations/ | xargs -I % sh -c "psql -d ${DB_SCHEMA} \
		-U ${DB_ROOT_USER} -f ./migrations/%"'

restart-db: finish-db start-db migrate-db query-persons-db
