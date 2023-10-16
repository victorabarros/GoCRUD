YELLOW=$(shell printf '\033[0;1;33m')
COLOR_OFF=$(shell printf '\033[0;1;0m')
DB_COMPOSE_FILE_PATH=database/docker-compose.yaml
DB_ROOT_USER=postgres_user
DB_DOCKER_SERVICE_NAME=gocrud-db

run:
	@go run cmd/api/main.go

start-db:
	@echo '${YELLOW}Starting Postgres container${COLOR_OFF}'
	docker-compose -f ${DB_COMPOSE_FILE_PATH} build
	docker-compose -f ${DB_COMPOSE_FILE_PATH} up -d

finish-db:
	@echo '${YELLOW}Finishing database container${COLOR}'
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} kill ${DB_DOCKER_SERVICE_NAME}
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} rm ${DB_DOCKER_SERVICE_NAME} -f

query-db:
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} \
		exec ${DB_DOCKER_SERVICE_NAME} psql -d process_db -U ${DB_ROOT_USER}

query-persons-db:
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} \
		exec ${DB_DOCKER_SERVICE_NAME} psql -d process_db -U ${DB_ROOT_USER} \
		--command='SELECT * FROM persons;'

migrate-db:
	@echo '${YELLOW}Running migrations${COLOR}'
	@sleep 1
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} \
		cp ./database/migrations ${DB_DOCKER_SERVICE_NAME}:/
	@docker-compose -f ${DB_COMPOSE_FILE_PATH} \
		exec ${DB_DOCKER_SERVICE_NAME} sh -c \
		'ls migrations/ | xargs -I % sh -c "psql -d process_db \
		-U ${DB_ROOT_USER} -f ./migrations/%"'

restart-db: finish-db start-db migrate-db query-persons-db
