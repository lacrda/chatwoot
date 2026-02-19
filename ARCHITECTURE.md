# Architecture

## Runtime Components

- `web` (Rails/Puma)
Recebe requests HTTP, inclusive webhook da Meta WhatsApp, valida payload e enfileira jobs no Sidekiq.

- `worker` (Sidekiq)
Consome filas (`critical`, `high`, `default`, `low`) e processa eventos assincronos, incluindo mensagem inbound WhatsApp.

- `postgres` (pgvector)
Persistencia principal do Chatwoot (contas, inbox, contatos, conversas, mensagens, configs).

- `redis`
Broker das filas Sidekiq e cache de partes da aplicacao.

## Startup Model

`railway.json` usa `./docker/start.sh` como entrypoint unico.

- Se `APP_ROLE=web`:
  - cria `tmp/*`
  - executa `rails db:prepare`
  - sobe Puma

- Se `APP_ROLE=worker`:
  - cria `tmp/*`
  - executa `rails db:prepare`
  - sobe Sidekiq com filas prioritarias

## Fluxo WhatsApp (Cloud API)

1. Usuario envia mensagem no WhatsApp.
2. Meta envia webhook para `web` (`/webhooks/whatsapp/:phone_number`).
3. `web` enfileira `Webhooks::WhatsappEventsJob` em `Sidekiq(low)`.
4. `worker` consome o job e grava/processa no Chatwoot.
5. Conversa/mensagem aparece na UI do Chatwoot.

## Dependencias Criticas

- `web` e `worker` DEVEM compartilhar o mesmo `DATABASE_URL`.
- `web` e `worker` DEVEM compartilhar o mesmo `REDIS_URL`.
- `SECRET_KEY_BASE` deve ser identico entre `web` e `worker`.
