# Delícias da Tia Nely

Fundação da aplicação Rails da Delícias da Tia Nely. A vitrine pública está em preparação e os pedidos ficam desabilitados até que catálogo, checkout e configuração comercial sejam implementados e verificados. Nenhum dado comercial foi inventado.

## Requisitos

- Ruby 3.4.2
- SQLite 3 e ferramentas de compilação para gems nativas. libvips 8.13+ será necessário quando o módulo de catálogo habilitar processamento de imagens.
- Sem Node, npm, Yarn, pnpm ou bundler JavaScript

## Desenvolvimento

Antes do primeiro boot, remova uma instalação global residual de `ruby-vips`, caso exista. A fundação não usa essa gem; Rails 8.1 a detecta fora do Gemfile e bloqueia o boot com libvips anterior a 8.13:

```bash
gem uninstall ruby-vips -aIx
```

Esse comando remove somente a gem global incompatível. Não instale nem atualize libvips apenas para esta fundação, pois ela ainda não processa imagens.

```bash
cd delicias-da-tia-nely
bundle install
bundle exec rails db:prepare
bundle exec rails runner 'puts "rails ok"'
bundle exec rails routes
bundle exec rails test
bundle exec puma -C config/puma.rb
```

Abra `http://localhost:3000`. Para usar host ou porta diferentes, defina `APP_HOST`, `APP_PORT`, `BIND_HOST` e `PORT`. O fuso padrão é `America/Porto_Velho`; altere `APP_TIME_ZONE` apenas quando houver decisão da loja.

O SQLite fica em `storage/development.sqlite3`, `storage/test.sqlite3` e `storage/production.sqlite3`, ou no diretório absoluto de `STORAGE_PATH`; teste pode usar `TEST_STORAGE_PATH`. Não use a mesma localização de banco entre ambientes. Uploads locais ficam no subdiretório `uploads/<ambiente>` desse storage.

## Primeiro administrador e configurações

O seed não cria credenciais fixas nem imprime senhas. Para criar uma única vez o primeiro administrador em desenvolvimento:

```bash
SEED_ADMIN_EMAIL=admin@exemplo.test SEED_ADMIN_PASSWORD='uma-senha-segura' bundle exec rails db:seed
```

Em produção a senha precisa ter pelo menos 16 caracteres. O comando não troca senha de administrador existente nem sobrescreve configurações comerciais existentes. A recuperação de senha é acessível em `/senha` e só envia mensagens se SMTP e `DEVISE_MAILER_SENDER` estiverem configurados. Veja `.env.example`; não a versione com valores reais.

`StoreSetting` centraliza dados comerciais. O seed cria a configuração inicial com recebimento desabilitado, mínimo configurável e frete padrão de R$ 10,00. Mesmo que um WhatsApp seja configurado depois, pedidos continuam desabilitados até o módulo de checkout.

## Rotas desta fundação

- `/`, `/quem-somos` e `/contato`: páginas públicas em preparação
- `/iniciar-sessao`, `DELETE /sair`, `/senha`: Devise de administradores, sem cadastro público
- `/administracao`: painel autenticado inicial
- `/health` e `/up`: healthchecks JSON de boot e banco

Catálogo, carrinho, checkout, ViaCEP, WhatsApp, estoque, cupons, promoções, financeiro e relatórios ainda não possuem rotas ou telas funcionais. A ordem de implementação e a matriz de requisitos estão em `docs/implementacao.md`.

## Produção

Use secrets pelo ambiente do serviço: `SECRET_KEY_BASE`, `APP_HOST`, `STORAGE_PATH`, `DEVISE_MAILER_SENDER` e, se aplicável, `RAILS_MASTER_KEY`. Para seed administrativo, use temporariamente `SEED_ADMIN_EMAIL` e `SEED_ADMIN_PASSWORD`. `STORE_WHATSAPP` está documentado para a etapa comercial, mas não ativa vendas nesta fundação.

Os procedimentos de VPS (Nginx/Puma ou Passenger), backup, Docker e Render estão em `docs/comandos-producao.md`. Em qualquer alteração de schema, faça backup, carregue as variáveis do processo Rails, execute `db:migrate`, confira `db:migrate:status`, reinicie o processo Rails e teste a aplicação. Não publique ou altere produção com esta fundação.
