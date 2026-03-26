NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: all up build down stop restart logs ps clean fclean re

all: up

up:
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	$(COMPOSE) down --volumes

fclean: clean
	docker system prune -af

re: clean up
