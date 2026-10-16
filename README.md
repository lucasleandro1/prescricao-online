# Prescrição Online

## Deploy em produção

- Hospedagem: [Render](https://render.com) (configuração em `render.yaml`)
- Banco de dados: [Neon](https://neon.tech) (Postgres gerenciado, sem expiração por tempo)

### Variáveis de ambiente (configuradas no dashboard do Render)

| Variável | Valor |
|---|---|
| `RAILS_MASTER_KEY` | conteúdo de `config/master.key` |
| `DATABASE_URL` | connection string do projeto no Neon |

### Deploy inicial / de um banco novo

```bash
RAILS_ENV=production bundle exec rails db:schema:load
```

## Backup automático

Workflow `.github/workflows/backup.yml` roda todo dia às 03:00 (horário de
Brasília), faz `pg_dump` do banco de produção, criptografa o dump com
AES-256 e publica no branch `db-backups` do repositório (mantém os últimos
30 backups). Também pode ser disparado manualmente em Actions → "Backup do
banco de produção" → Run workflow.

### Secrets necessários (GitHub → Settings → Secrets and variables → Actions)

| Secret | Descrição |
|---|---|
| `DATABASE_URL` | mesma connection string do Neon usada no Render |
| `BACKUP_ENCRYPTION_KEY` | senha usada para criptografar/descriptografar os backups — **guarde em um gerenciador de senhas**. Sem ela os backups não podem ser restaurados, nem pela equipe. |

### Restaurar um backup

1. Baixe o arquivo `.dump.enc` desejado do branch `db-backups` (pasta `backups/`)
2. Descriptografe:

   ```bash
   openssl enc -d -aes-256-cbc -pbkdf2 \
     -in db-XXXXXXXX.dump.enc -out db.dump \
     -k "SUA_BACKUP_ENCRYPTION_KEY"
   ```

3. Restaure no banco de destino:

   ```bash
   pg_restore --clean --if-exists --no-owner --dbname="$DATABASE_URL" db.dump
   ```

## Desenvolvimento local

* Ruby: ver `.ruby-version`
* Banco local: SQLite (`storage/development.sqlite3`)
* Setup:

  ```bash
  bin/setup
  ```

* Rodar o servidor:

  ```bash
  bin/dev
  ```

* Rodar os testes:

  ```bash
  bundle exec rspec
  ```
