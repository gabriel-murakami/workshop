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
db-recreate:
	docker compose run --rm $(APP) rails db:drop db:create db:migrate db:seed ; \
	$(MAKE) stop
console:
	docker compose run --rm $(APP) rails console ; \
	$(MAKE) stop
server:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rails server -b 0.0.0.0 ; \
	$(MAKE) stop
bundle:
	docker compose run --rm -p 3000:3000 $(APP) bundle install ; \
	$(MAKE) stop
test:
	docker compose run --rm -p 3000:3000 -e RAILS_ENV=test $(APP) bundle exec rspec; \
	$(MAKE) stop
raw-test:
	docker compose run --rm -p 3000:3000 -e SIMPLECOV=false $(APP) bundle exec rspec; \
	$(MAKE) stop
seed:
	docker compose run --rm -p 3000:3000 $(APP) bundle exec rails db:seed ; \
	$(MAKE) stop
bash:
	docker compose run --rm $(APP) bash ; \
	$(MAKE) stop
swagger:
	docker compose run --rm -p 3000:3000 -e SIMPLECOV=false $(APP) bundle exec rake rswag:specs:swaggerize RAILS_ENV=test ; \
	$(MAKE) stop
export_vars:
	export TF_VAR_database_username=$(grep DATABASE_USERNAME .env | cut -d '=' -f2)
	export TF_VAR_database_password=$(grep DATABASE_PASSWORD .env | cut -d '=' -f2)
	export TF_VAR_jwt_secret=$(grep JWT_SECRET .env | cut -d '=' -f2)
	export TF_VAR_smtp_username=$(grep SMTP_USERNAME .env | cut -d '=' -f2)
	export TF_VAR_smtp_password=$(grep SMTP_PASSWORD .env | cut -d '=' -f2)
