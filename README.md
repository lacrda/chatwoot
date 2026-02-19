# Chatwoot on Railway (Deploy Guide)

Deploy de Chatwoot self-hosted no Railway com arquitetura minima:
- `web`: Rails + Puma
- `worker`: Sidekiq
- `postgres`: banco (idealmente com pgvector)
- `redis`: fila/cache

## Documentacao do projeto

- `README.md`: setup e deploy
- `ARCHITECTURE.md`: arquitetura e fluxos
- `OPERATIONS.md`: runbook operacional
- `PRODUCT_RULES.md`: regras funcionais do atendimento

## Arquivos de infra no repo

- `Dockerfile`
- `railway.json`
- `docker/start.sh`
- `docker/start-web.sh`
- `docker/start-worker.sh`
- `.env.example`

## Deploy no Railway (resumo)

1. Deploy do fork `develop` no Railway.
2. Adicionar plugins `PostgreSQL` (pgvector) e `Redis`.
3. Configurar variaveis no `web` e `worker`.
4. Definir `APP_ROLE=web` no web e `APP_ROLE=worker` no worker.
5. Redeploy dos dois servicos.

## Variaveis obrigatorias (web e worker)

```env
RAILS_ENV=production
NODE_ENV=production
FRONTEND_URL=https://SEU_DOMINIO_PUBLICO
DATABASE_URL=${{pgvector.DATABASE_URL}}
REDIS_URL=${{redis.REDIS_URL}}
SECRET_KEY_BASE=seu_secret_real
APP_ROLE=web # worker no servico worker
```

## Checklist rapido

- [ ] web sobe e responde HTTP
- [ ] worker sobe com Sidekiq sem erro
- [ ] webhooks do WhatsApp chegam no web
- [ ] jobs de WhatsApp aparecem no worker
- [ ] conversa aparece no Chatwoot

## Comandos uteis

```bash
# preparar schema (shell do web)
bundle exec rails db:prepare

# seed opcional
bundle exec rails db:seed
```

## Troubleshooting rapido

- `extension "vector" is not available`: usar Postgres com pgvector.
- `connection refused 127.0.0.1:5432`: DATABASE_URL incorreta/override por PGHOST.
- `UNIXSocket EINVAL redis`: REDIS_URL invalida ou reference errada.
- webhook chega no web e nao processa: worker/fila `low` indisponivel.
