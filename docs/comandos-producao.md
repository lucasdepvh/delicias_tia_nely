# Operação em VPS, Docker e Render

Esta etapa não publica a aplicação. Substitua os nomes entre `<...>` conforme a instalação real. Não execute comandos de exemplo sem configurar o serviço e seu ambiente. A fundação não tem checkout; um teste de compra completo será obrigatório quando esse módulo existir.

## Ambiente real do serviço

Ruby 3.4.2, Bundler do Gemfile.lock, SQLite e libvips (para imagens futuras). Use um usuário de serviço sem privilégios, diretório persistente gravável para SQLite/uploads e domínio com TLS. Instale gems com `bundle config set --local deployment true`, `bundle config set --local without 'development test'` e `bundle install`.

O processo Rails e as tarefas precisam usar **o mesmo usuário, release, Ruby e variáveis**. Exemplo de shell de manutenção (ajuste o caminho do Ruby e arquivo de ambiente; o arquivo deve usar sintaxe compatível com shell, ter permissão 600 e não ficar no repositório):

```bash
sudo -u <usuario-rails> -H bash
cd /srv/<aplicacao>/current
export PATH=/caminho/ruby-3.4.2/bin:$PATH
set -a
. /etc/<aplicacao>/ambiente
set +a
test "$RAILS_ENV" = production
bundle exec rails runner 'puts({ambiente: Rails.env, ruby: RUBY_VERSION, banco: ActiveRecord::Base.connection_db_config.database}.inspect)'
```

Defina `RAILS_ENV=production`, `APP_HOST` (somente hostname), `SECRET_KEY_BASE`, `STORAGE_PATH` absoluto e, se usar credentials criptografadas, `RAILS_MASTER_KEY`. Preserve a chave entre releases. Veja `.env.example`; Rails não carrega `.env` automaticamente. Nenhuma senha deve ser impressa ou passada em argumentos de shell.

## Instalação nova

No shell do serviço, configure diretórios persistentes antes do primeiro boot, execute:

```bash
bundle exec rails db:migrate
bundle exec rails db:migrate:status
bundle exec rails assets:precompile
bundle exec rails db:seed
```

O seed é explícito, idempotente e exige `SEED_ADMIN_EMAIL`/`SEED_ADMIN_PASSWORD` válidos em produção. Não altera senha de admin existente nem configurações já salvas. Remova as variáveis de seed do ambiente regular depois da criação. Não usa dados da loja de origem. A recuperação de senha só é ativada com SMTP configurado; sem ela, uma redefinição exige uma sessão de console administrativa autorizada.

## Deploy incremental e migrations

1. Coloque o serviço em manutenção, interrompa escritas e produza backup consistente.
2. Instale a release e dependências; carregue o ambiente real conforme acima.
3. Execute `bundle exec rails db:migrate` e `bundle exec rails db:migrate:status`; todas as migrations esperadas devem constar como `up`.
4. Execute `bundle exec rails assets:precompile`.
5. Reinicie **Rails** usando o servidor efetivamente instalado. Não basta reiniciar Nginx.
6. Verifique `/health`, `/up`, home, login e área administrativa. Após implementar checkout, teste o fluxo completo em ambiente de validação, sem enviar mensagens reais.

Não execute seeds automaticamente em cada deploy, nem `db:drop`, `db:reset` ou `db:schema:load` em banco produtivo existente. Migration aplicada não é sinônimo de processo Rails reiniciado.

## Puma / systemd e Nginx

Crie uma unidade com `User`, `WorkingDirectory`, `EnvironmentFile` apontando para a configuração acima, `ExecStart=/caminho/ruby-3.4.2/bin/bundle exec puma -C config/puma.rb`, `Restart=on-failure` e `UMask=0077`. Configure `BIND_HOST=127.0.0.1` e `PORT=3000` para escutar somente no loopback da VPS. Não há worker de fila obrigatório.

No Nginx, configure seu domínio/certificado e proxy para `http://127.0.0.1:3000`, incluindo `Host $host`, `X-Forwarded-For $proxy_add_x_forwarded_for` e `X-Forwarded-Proto $scheme`. Redirecione HTTP para HTTPS. Use limite de corpo compatível com upload de 5 MB e overhead (por exemplo 10 MB); a validação de cada imagem continuará no Rails. Não publique o diretório SQLite como raiz web.

```bash
sudo systemctl restart <servico-puma-real>
sudo systemctl status <servico-puma-real>
sudo journalctl -u <servico-puma-real> -n 100 --no-pager
curl --fail https://<dominio>/health
```

Configure inicialização automática da unidade. Execute `nginx -t` antes de recarregar alterações do proxy. Não há nome de serviço presumido neste projeto.

## Passenger como alternativa

Configure `passenger_ruby` para Ruby 3.4.2, `passenger_app_env production`, raiz em `<release>/public` e as mesmas variáveis persistentes do serviço. Após migration no ambiente correto, use o mecanismo da instalação, como `passenger-config restart-app /srv/<aplicacao>/current` ou `touch tmp/restart.txt` (Passenger padrão). Verifique os logs e healthcheck. Não execute Puma simultaneamente para a mesma instalação.

## Backup e restauração

Pare o processo que escreve no banco; execute como usuário com acesso ao storage. Não copie um arquivo SQLite ativo ignorando WAL. Use o comando `.backup` do sqlite3 para cada banco produtivo e copie uploads junto, mantendo a correspondência entre blobs e metadados. Exemplo com caminhos substituídos e serviço parado:

```bash
sqlite3 /srv/<aplicacao>/storage/production.sqlite3 '.backup /backup/<data>/production.sqlite3'
cp -a /srv/<aplicacao>/storage/uploads /backup/<data>/uploads
sqlite3 /backup/<data>/production.sqlite3 'PRAGMA integrity_check;'
```

Proteja backups e retenção: contêm dados pessoais. Guarde segredos separadamente com acesso restrito. Retome o serviço após o backup. Para restaurar, ensaie primeiro em diretório isolado: mantenha o serviço parado, preserve o estado anterior, restaure banco e uploads da mesma captura, ajuste proprietário/permissões e use a release compatível com o schema. Valide `integrity_check`, status das migrations, anexos e login; reinicie Rails. A restauração produtiva e reversões de schema exigem decisão explícita e não foram executadas nesta entrega.

## Docker

```bash
docker build -t delicias_da_tia_nely .
docker volume create delicias_da_tia_nely_storage
docker run --rm --env-file /caminho/seguro/ambiente \
  -p 127.0.0.1:3000:3000 \
  -v delicias_da_tia_nely_storage:/rails/storage \
  delicias_da_tia_nely
```

O entrypoint executa migrations e confere status antes de iniciar Puma. Não executa seed automaticamente. Garanta UID 1000 com escrita no volume. Use apenas uma instância gravadora com SQLite; atualizações devem preservar volume e segredos. O proxy Nginx termina TLS. Para bootstrap do admin, execute explicitamente `bin/rails db:seed` em contêiner com o mesmo volume e ambiente. Não passe secrets em `docker build`.

## Render

`render.yaml` fornece alternativa Docker com disco em `/rails/storage` e healthcheck `/health`. Selecione plano que suporte disco persistente, configure domínio e secrets no painel e revise custos antes de criar o serviço. O disco SQLite implica instância única; não escale horizontalmente com cópias independentes do banco.

`bin/render-build.sh` instala dependências e compila assets; não acessa o banco. `bin/render-postdeploy.sh` aplica migrations e confere status no ambiente de execução com disco montado. O entrypoint chama esse script antes de Puma, evitando executar migration em build ou job sem o disco da aplicação. Reinício da aplicação após migration acontece no lançamento do novo processo. Seed inicial é comando explícito no ambiente do serviço. Este blueprint não foi publicado nem testado na infraestrutura Render.

## Diagnóstico

Confirme Ruby, `RAILS_ENV`, usuário, diretório, permissão de storage e caminho do banco. Execute `db:migrate:status` no mesmo ambiente do processo. Erro de `SECRET_KEY_BASE` é configuração ausente; não gere chave temporária para contornar manutenção. Compare release e migrations antes de agir. Os healthchecks verificam boot e acesso ao banco, sem divulgar detalhes internos na resposta.
