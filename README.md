# Chatwoot on Railway (Docker)

Infra de deploy para rodar Chatwoot self-hosted no Railway com:
- 1 servico `web` (Rails + Puma)
- 1 servico `worker` (Sidekiq)
- 1 Postgres (plugin Railway)
- 1 Redis (plugin Railway)

## Arquivos criados

- `Dockerfile`
- `railway.json`
- `docker/start-web.sh`
- `docker/start-worker.sh`
- `.env.example`

## 1) Fork + clone do Chatwoot

Opcao A (GitHub UI):
1. Abra `https://github.com/chatwoot/chatwoot`
2. Clique em `Fork`
3. Clone seu fork:

```bash
git clone https://github.com/SEU_USUARIO/chatwoot.git
cd chatwoot
```

Opcao B (GitHub CLI):

```bash
gh repo fork chatwoot/chatwoot --clone=true --remote=true
cd chatwoot
```

Depois, copie estes arquivos para a raiz do seu fork (ou replique o conteudo).

## 2) Build e start no Railway

- O Railway usa `Dockerfile` para build.
- O comando padrao do servico web vem de `railway.json`:
  - `./docker/start-web.sh`
- `start-web.sh` executa:
1. `bundle exec rails db:prepare`
2. `bundle exec puma -C config/puma.rb -p $PORT`

## 3) Criar projeto no Railway

1. `New Project` -> `Deploy from GitHub repo`
2. Selecione seu fork do Chatwoot
3. Aguarde o primeiro build Docker

## 4) Adicionar plugins de banco e cache

1. Dentro do projeto Railway: `New` -> `Database` -> `PostgreSQL`
2. Depois: `New` -> `Database` -> `Redis`

## 5) Variaveis de ambiente no servico web

Defina no servico web, no minimo:

- `RAILS_ENV=production`
- `NODE_ENV=production`
- `SECRET_KEY_BASE=<valor forte>`
- `FRONTEND_URL=https://SEU_DOMINIO_PUBLICO`
- `REDIS_URL=<connection url do plugin Redis>`
- `DATABASE_URL=<connection url do Postgres>`

Tambem pode expor as variaveis separadas:
- `POSTGRES_HOST`
- `POSTGRES_USERNAME`
- `POSTGRES_PASSWORD`
- `POSTGRES_DATABASE`

## 6) Usar variaveis injetadas automaticamente pelo Railway

No Railway, prefira `Reference Variables`:

- `DATABASE_URL` -> referencie a URL do servico Postgres
- `REDIS_URL` -> referencie a URL do servico Redis

Assim, quando credenciais mudarem, os servicos continuam sincronizados.

## 7) Criar servico worker (Sidekiq)

1. No projeto Railway, duplique o servico web (ou crie novo servico apontando para o mesmo repo)
2. No novo servico, mantenha a mesma imagem/build
3. Troque Start Command para:

```bash
./docker/start-worker.sh
```

Esse script executa:
1. `bundle exec rails db:prepare`
2. `bundle exec sidekiq -C config/sidekiq.yml`

## 8) Rodar `rails db:prepare` manualmente (se necessario)

No shell do servico web no Railway:

```bash
bundle exec rails db:prepare
```

## 9) Primeiro acesso e usuario admin

1. Abra `FRONTEND_URL`
2. Siga onboarding do Chatwoot para criar a conta inicial/admin
3. Se a tela nao carregar, valide logs do web e worker

## Checklist objetivo

- [ ] Fork do Chatwoot criado
- [ ] Repo conectado ao Railway
- [ ] Postgres plugin adicionado
- [ ] Redis plugin adicionado
- [ ] `DATABASE_URL` e `REDIS_URL` configuradas via Reference Variables
- [ ] Servico web iniciando com `./docker/start-web.sh`
- [ ] Servico worker iniciando com `./docker/start-worker.sh`
- [ ] `bundle exec rails db:prepare` executado sem erro
- [ ] Primeiro usuario admin criado

## Comandos para subir alteracoes do seu fork

Depois de adicionar os arquivos:

```bash
git add Dockerfile railway.json docker/start-web.sh docker/start-worker.sh .env.example README.md
git commit -m "chore: add railway docker deployment setup"
git push origin main
```
