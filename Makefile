APP=web

.PHONY: stop
stop:
	docker compose down --remove-orphans

setup:
	docker compose build --no-cache ; \
	docker compose run --rm $(APP) rails db:setup ; \
	$(MAKE) stop

build:
	docker compose build --no-cache ; \
	$(MAKE) stop

up:
	docker compose up ; \
	$(MAKE) stop

down:
	$(MAKE) stop

db-create:
	docker compose run --rm $(APP) rails db:create db:migrate ; \
	$(MAKE) stop

console:
	docker compose run --rm $(APP) rails console ; \
	$(MAKE) stop

server:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rails server -b 0.0.0.0 ; \
	$(MAKE) stop

spec:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rspec ; \
	$(MAKE) stop

seed:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rails db:seed ; \
	$(MAKE) stop

bash:
	docker compose run --rm $(APP) bash ; \
	$(MAKE) stop
