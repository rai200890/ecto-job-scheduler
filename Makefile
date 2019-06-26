build: down
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test.yml \
		build

.PHONY: down
down:
	docker-compose down -v --remove-orphans

.PHONY: test-shell
test-shell: build
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test.yml \
		run --rm app sh -c "make db  && /bin/sh"

.PHONY: mix-deps 
mix-deps:
	mix deps.get

.PHONY: wait-db
wait-db:
	@echo 'Waiting Postgres Server...'
	@while ! nc -z db 5432; do sleep 1; done

.PHONY: db
db: mix-deps wait-db
	mix do ecto.create, ecto.migrate