APP=web

setup:
	docker compose build --no-cache && \
		docker compose run --rm $(APP) rails db:setup
build:
	docker compose build --no-cache
up:
	docker compose up -d
down:
	docker compose down --remove-orphans
db-create:
	docker compose run --rm $(APP) rails db:create db:migrate
console:
	docker compose run --rm $(APP) rails console
server:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rails server -b 0.0.0.0
spec:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rspec
bash:
	docker compose run --rm $(APP) bash
