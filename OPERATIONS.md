# Operations Runbook

## Pre-Deploy Checklist

- [ ] `DATABASE_URL` aponta para Postgres com pgvector
- [ ] `REDIS_URL` aponta para Redis do projeto
- [ ] `APP_ROLE=web` no servico web
- [ ] `APP_ROLE=worker` no servico worker
- [ ] `SECRET_KEY_BASE` setado (mesmo valor nos 2 servicos)

## Deploy Procedure

1. Deploy da branch `develop`.
2. Verificar logs do `web` (Puma pronto).
3. Verificar logs do `worker` (Sidekiq pronto).
4. Rodar `bundle exec rails db:prepare` no shell do web (se necessario).
5. Testar webhook e fluxo de mensagem.

## Health Checks

- `web`: responde HTTP e registra requests do webhook.
- `worker`: processa jobs apos mensagem de teste.
- `redis`: sem erros de conexao no web/worker.
- `postgres`: sem `connection refused` / `PG::ConnectionBad`.

## Incident Playbooks

### Webhook chega no web, mas nao aparece mensagem no Chatwoot

1. Confirmar no web: `Enqueued ... to Sidekiq(low)`.
2. Confirmar no worker processamento da fila `low`.
3. Se worker sem log: revisar `APP_ROLE`, `REDIS_URL`, `DATABASE_URL`.

### Erro de banco em localhost

- Remover `PGHOST`, `PGPORT`, `POSTGRES_*` conflitantes.
- Manter apenas `DATABASE_URL` por reference variable.

### Erro redis unix socket / EINVAL

- Corrigir `REDIS_URL` para reference valida.
- Garantir URL iniciando com `redis://`.

## Scale Plan (operacional)

- 1x-10x: aumentar replicas de worker.
- 10x-100x: separar filas por prioridade e monitorar latencia.
- 100x+: revisar plano de banco/cache, tuning de conexoes e observabilidade.

## Mandatory Alerts

- restart loop de `worker`
- falhas 5xx no `web`
- backlog de fila crescente
- erro de conexao em Redis/Postgres
