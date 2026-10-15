# Implementação

## Carrinho e checkout próprio — 14/10/2026

- Implementados carrinho persistido em sessão e rotas públicas para adicionar, alterar quantidade, remover, esvaziar e visualizar itens. Produto e variação são revalidados no servidor a cada operação; quantidade é limitada a 99 e respeita estoque quando aplicável.
- A vitrine agora permite adicionar produtos disponíveis quando a configuração comercial estiver válida e o recebimento de pedidos estiver ativo. O drawer lateral e a página `/carrinho` exibem o mesmo carrinho; a loja pausada impede adicionar itens e acessar ou concluir checkout.
- Implementado checkout próprio em `/finalizar-pedido`: identificação, retirada/entrega, endereço obrigatório apenas na entrega, pagamento, troco, observações e resumo. O mínimo efetivo de R$ 20,00 é aplicado também na retirada. Frete de entrega usa, por enquanto, somente a taxa padrão configurada; cupons, promoções e áreas de entrega continuam pendentes e não são apresentados como operacionais.
- Ao confirmar, o sistema normaliza/atualiza o cliente por telefone, cria pedido pendente, itens com snapshot de preço e receita automática pendente em uma transação, limpa o carrinho e redireciona para o WhatsApp oficial configurado com a mensagem detalhada codificada. Não há iFood, gateway ou envio automático de mensagem.
- Evidências: `RAILS_ENV=test ... bin/rails db:migrate` aplicado somente no banco de teste; `RAILS_ENV=test ... bin/rails test test/integration/cart_checkout_test.rb` aprovado com **2 testes, 20 asserções, nenhuma falha ou erro**. `zeitwerk:check` aprovado. A suíte completa ainda tem duas falhas preexistentes em `FoundationAccessTest`, cujas expectativas de texto/layout não correspondem às telas atuais; o fluxo novo passou isoladamente.

Escopo desta entrega: fundação e catálogo público inicial. O prompt de continuação está reservado para a próxima etapa. Especificação original preservada, SHA-256 `50fb8dcb81202deb71b5a44d23c8fd089cbe2996034b9d503cf085d08c1ef9c2`.

## Matriz da especificação

| Seções | Fundação / evidência | Pendência |
|---|---|---|
| 1–3 | AGENTS.md, Gemfile, configurações Rails, identidade própria | Evoluir mantendo precedência e monólito |
| 4 | Devise Admin sem registro público, controllers autenticados, testes de acesso | Recuperação por e-mail depende de SMTP; autorização de pedidos no módulo de checkout |
| 5 | Home, institucionais, administração inicial, login/logout e healthchecks | Rotas funcionais de cada módulo |
| 6 | Admin, StoreSetting, Active Storage e migrations | Demais models, relações e índices junto aos módulos |
| 7 | Catálogo público de produtos e categorias, detalhes, disponibilidade e variações disponíveis; infraestrutura de upload | Kits, imagens cadastráveis, busca e paginação completa |
| 8 | Configuração única, valores decimais, padrão pausado | CRUD administrativo e bloqueios nos futuros endpoints de compra |
| 9 | Estrutura de views reservada | Carrinho e suas validações HTML/Turbo |
| 10–11 | Sem promoção ou cupom anunciado como disponível | Cupons, combos, brindes e concorrência |
| 12–13 | Sem checkout ou envio automático | Checkout, ViaCEP, link WhatsApp, privacidade e reenvio |
| 14 | Sem operação de estoque simulada | Pedidos, movimentos, locks, restauração e exclusão auditável |
| 15 | Módulo indicado como pendente | Financeiro comercial, sincronização e vendas manuais |
| 16–17 | Módulos indicados como pendentes | Financeiro pessoal, dashboard real e análise de vendas |
| 18–19 | Layouts responsivos, login, navegação, estados vazios, DESIGN.md | CRUDs, filtros, paginação, componentes e QA dos fluxos |
| 20 | Helpers SEO/moeda/marca, metadados públicos e noindex privado | SEO de categorias/produtos e imagens reais |
| 21 | Segredos externos, seeds idempotentes, docs VPS/Docker/Render | Configuração real da infraestrutura e ensaio de restauração |
| 22 | Verificações da fundação registradas abaixo | Testes dos fluxos comerciais ao implementar cada módulo |
| 23 | Este acompanhamento e AGENTS.md | Atualizar a cada etapa |

## Ordem seguinte

1. Catálogo e configurações: categorias, sabores/produtos, variações, kits, galeria, CRUD, Ransack/Pagy e upload validado.
2. Estoque: movimentos e transações consistentes.
3. Carrinho, checkout, clientes, entrega, pedidos e WhatsApp autorizado.
4. Cupons, combos e brindes.
5. Administração e financeiro comercial.
6. Financeiro pessoal e análise de vendas.
7. SEO completo, testes de concorrência, navegador e operação.

A fundação não habilita vendas, mesmo com dados comerciais preenchidos. A ativação depende do módulo de checkout verificado. Não há integração iFood nem dependência de fila para reproduzi-la.

## Verificações

### Seed de desenvolvimento — 04/10/2026

- `db/seeds.rb` cria de forma idempotente a configuração única da loja, com recebimento de pedidos desativado, mínimo `R$ 0,00`, frete padrão `R$ 10,00` e mensagem de pausa padrão. Configurações comerciais existentes nunca são sobrescritas.
- Para criar o primeiro administrador, informe as duas variáveis no mesmo comando; a seed só cria a conta se aquele e-mail ainda não existir e nunca redefine uma senha já cadastrada:

  ```bash
  SEED_ADMIN_EMAIL="seu-email@exemplo.com" SEED_ADMIN_PASSWORD="escolha-uma-senha-segura" bin/rails db:seed
  ```

- Em produção, a senha precisa ter pelo menos 16 caracteres. Nenhuma credencial ou dado comercial foi colocado no repositório. Produtos, pedidos, estoque e financeiro continuam pendentes porque seus modelos ainda não foram implementados.
- Verificações executadas no banco de teste: `RAILS_ENV=test bin/rails db:seed` concluído duas vezes (idempotência) e `RAILS_ENV=test bin/rails test` aprovado com **7 testes, 28 asserções, nenhuma falha ou erro**.

### Catálogo inicial — 04/10/2026

- Adicionados `Category`, `Product` e `ProductVariant`, com migration, validações de preço/estoque, slugs, índices e relações. Administração autenticada inclui CRUD de categorias e produtos; variações já têm model para a próxima tela específica.
- O catálogo demonstrativo usado apenas na fundação foi removido do seed e do banco de desenvolvimento em 05/10/2026 a pedido da proprietária. A seed de catálogo agora contém somente os produtos dos materiais recebidos.

### Catálogo real inicial — 05/10/2026

- `bin/rails db:seed` cadastra de forma idempotente as categorias “Quitandas da Tia Nely”, “Congelados ou Assados” e “Sanduíches de Pão Santo Antônio”. Os produtos recebidos até o momento são Rosquinhas de Leite Condensado com Coco, Mãe Benta, Pão Santo Antônio Tradicional, Pão de Coco, Bolinho do Céu com Coco, Pão de Queijo, Biscoito de Queijo e Sanduíches de Pão Santo Antônio.
- Quantidades e preços foram cadastrados como variações. Estoque não foi informado, portanto nenhum saldo foi inventado e os produtos permanecem sem controle de estoque até a definição pela loja.
- A seed nunca atualiza nem remove registros existentes. Os demais catálogos serão acrescentados após o recebimento dos respectivos materiais.
- Telefones e o nome apresentados no rodapé do catálogo de congelados/assados não foram cadastrados, pois não fazem parte dos produtos solicitados e ainda não foram configurados como contatos oficiais da loja.
- Os sanduíches foram cadastrados a R$ 7,00 por unidade, com os sabores Geleia de Pimenta, Patê de Atum e Presunto e Queijo. O mínimo de 30 unidades está descrito no produto, mas não é aplicado automaticamente enquanto não houver checkout.
- Verificações executadas: o seed foi rodado duas vezes no banco de desenvolvimento com `bin/rails db:seed`, sem erro ou duplicação; em seguida, `bin/rails test` foi aprovado com **10 testes, 49 asserções, nenhuma falha ou erro**.

### Atualização visual da vitrine — 04/10/2026

- A home pública foi remodelada a partir da referência visual de cardápio móvel enviada pelo proprietário: cabeçalho compacto, campo de busca, chips e cards de superfície clara.
- Como catálogo, carrinho e checkout ainda são pendências da fundação, a implementação mostra somente o estado de preparação. Não foram adicionados produtos, preços, estoque, fotos, contador de carrinho, WhatsApp ou dados comerciais fictícios.
- O layout permanece ERB + CSS compartilhado e mantém a marca local. A home não cria rotas, persistência ou fluxos de venda novos.
- Verificação executada: `RAILS_ENV=test ruby bin/rails test` com Ruby 3.4.2 — **7 testes, 25 asserções, nenhuma falha ou erro**.
- Correção posterior: os layouts passaram a referenciar `style.css` diretamente. O `application.css` atual continha apenas um `@import` não resolvido pelo pipeline Propshaft no ambiente de desenvolvimento, causando o carregamento sem os estilos compartilhados. Não há dependência adicional necessária.
- Dashboard administrativo atualizado conforme referência visual fornecida: cabeçalho de gestão, status da loja, indicadores, etapas e navegação inferior. Os indicadores mostram `—` e as seções futuras permanecem inativas enquanto não houver modelos e fluxos implementados; nenhum pedido, produto, cliente, receita ou alerta fictício foi adicionado.

### Correção de inicialização — 03/10/2026

- Pagy 43.6.3: substituídos `Pagy::DEFAULT[:limit]` (hash congelado) por `Pagy::OPTIONS[:limit]` e `Pagy::Backend` por `Pagy::Method`, preservando o limite de 12 itens. Opções congeladas após configuração, conforme o [guia oficial de atualização](https://ddnexus.github.io/pagy/guides/upgrade-guide/).
- A validação revelou ausência do carregamento de `devise/orm/active_record`; incluído no inicializador existente, mantendo autenticação obrigatória e cadastro público desabilitado.
- A fundação não carrega Action Cable, pois não há funcionalidade que dependa dele. Nenhum worker ou serviço externo foi adicionado.
- WSL acessível pelo caminho absoluto `C:\Windows\System32\wsl.exe`, com Ruby em `/usr/local/rbenv/versions/3.4.2/bin`. Executados `RAILS_ENV=development ruby bin/rails runner 'puts :boot_ok'` e `RAILS_ENV=development ruby bin/rails zeitwerk:check`, ambos aprovados.
- Removida a gem global incompatível `ruby-vips 2.3.0`; ela não constava do Bundle, mas o Rails 8.1.4 a ativava ao detectar a instalação global junto de libvips anterior a 8.13. `bundle exec rails db:prepare` e `bundle exec rails runner "puts 'rails ok'"` foram aprovados após a remoção.
- `rails/all` foi substituído pelos railties usados pela fundação. Action Mailbox e Action Text não são carregados, e `config.active_storage.draw_routes = false` impede uploads diretos e rotas genéricas do Active Storage antes do módulo de catálogo. `bundle exec rails routes` foi conferido: somente rotas da fundação, Devise e Turbo Native permanecem. `bundle exec rails test`: **7 testes, 23 asserções, nenhuma falha ou erro**.
- Aplicadas as duas migrations existentes somente no banco de teste com `RAILS_ENV=test ruby bin/rails db:migrate`; schema gerado pelo Rails. `RAILS_ENV=test ruby bin/rails test`: **7 testes, 23 asserções, nenhuma falha ou erro**.
- Puma iniciado em desenvolvimento na porta local 3107 com Ruby 3.4.2/Rails 8.1.4; confirmou escuta e foi encerrado de forma controlada após cinco segundos. Nenhum processo de servidor foi deixado ativo.
- Sem deploy, alterações em produção ou validação de checkout (ainda pendente). O diretório não contém repositório Git, portanto não houve conferência por `git diff`.

### Histórico anterior

As verificações de Rails precisam ser executadas no ambiente que tem Ruby 3.4.2 e Bundler disponíveis. Nesta sessão, após a geração do lockfile, o executor ativo deixou de disponibilizar `wsl`, `bash`, `ruby`, `bundle`, `rails`, `docker` e `git` (a inspeção de comandos retornou vazio); por isso boot, migrations, rotas e testes não puderam ser executados novamente aqui. Em 03/10/2026, o boot informado no ambiente de desenvolvimento foi bloqueado por libvips anterior a 8.13 carregada por `image_processing`; a dependência foi removida da fundação, que ainda não processa imagens. Nenhum deploy de produção foi solicitado ou executado.

### Consolidação visual das telas existentes — 14/10/2026

- A vitrine pública existente passou a usar o mesmo acabamento de cores, superfícies, botões, rodapé e estados responsivos em home, catálogo, detalhe de produto, Quem somos e Contato. Não foram criados dados comerciais, imagens fictícias, links de WhatsApp ou CTAs de compra.
- A administração disponível (dashboard, categorias e produtos) foi harmonizada: navegação inferior com links apenas para os recursos implementados, listas escaneáveis, estados ativo/inativo, estados vazios, formulários agrupados e ações destrutivas preservando a confirmação já existente.
- Login e recuperação de senha receberam o mesmo acabamento visual, sem mudança no fluxo Devise ou nas políticas de acesso.
- Permanecem pendentes por dependência de módulos ainda não implementados: carrinho, checkout, pedidos, clientes, áreas de entrega, estoque, cupons, promoções/brindes, financeiro, configurações e suas telas administrativas. Eles continuam sem links que os apresentem como operacionais.
- Verificação tentada: `RAILS_ENV=test ruby bin/rails test`. O ambiente WSL atual retornou `ruby: command not found`; portanto, testes e renderização por navegador não foram reexecutados nesta etapa. Nenhuma alteração foi feita em produção.

### Página inicial como cardápio — 14/10/2026

- A rota `/` agora é atendida por `ProductsController#index`, exibindo diretamente a tela pública de produtos. Os caminhos `/produtos` e `/sabores` permanecem disponíveis como atalhos para o mesmo catálogo.
- A navegação pública passou a apresentar esse destino como “Cardápio”. A antiga view de home foi preservada no código, mas não é mais uma rota de entrada.

### Logomarca principal — 14/10/2026

- `app/assets/images/Logo Principal.png` passou a ser a logomarca do cabeçalho público, da administração e dos ícones de navegador. A imagem possui texto alternativo adequado e dimensionamento responsivo.

### Base comercial e CRUDs administrativos — 14/10/2026

- Categorias (tipo de produto) e produtos já possuíam migrations, models, rotas e CRUD administrativo. Administradores já eram persistidos pela migration de fundação e autenticados via Devise; não há cadastro público de usuários.
- Adicionada a migration `20261014000000_create_commerce_records`, com tabelas, índices e chaves estrangeiras para imagens de produto, clientes, áreas de entrega, descontos, promoções, pedidos/itens, movimentos de estoque, lançamentos financeiros/itens e lançamentos financeiros pessoais. O `schema.rb` não foi editado manualmente e só será atualizado ao executar a migration.
- Implementados CRUDs administrativos de clientes (listagem, visualização, edição e exclusão protegida por vínculos) e de lançamentos financeiros comerciais manuais. Lançamentos automáticos, quando criados futuramente por pedidos, ficam bloqueados para edição/exclusão manual.
- Ainda não há checkout, criação de pedidos, baixa de estoque, itens de venda financeira, filtros/paginação, área de entrega, descontos, promoções ou financeiro pessoal operacionais. As migrations fornecem somente a base para os próximos módulos; a funcionalidade completa depende dessas regras e testes.
- A migration e os testes não foram executados nesta etapa. O comando `ruby` não está disponível no `PATH` padrão do WSL; o executável do rbenv foi localizado posteriormente e usado apenas para criar o administrador local.

### Administrador local — 14/10/2026

- Um administrador solicitado pela responsável foi criado exclusivamente no banco de desenvolvimento local por `rails runner`. O e-mail e a senha não foram registrados nesta documentação, no código ou em seeds; nenhuma conta de produção foi criada ou alterada.

### Ajuste de densidade visual administrativa — 14/10/2026

- A área administrativa foi ampliada em telas grandes e os formulários passaram a ocupar uma largura útil maior, reduzindo espaço vazio. Espaçamentos de seções, campos, listas e indicadores foram compactados sem comprometer os alvos de toque em celular.
- Ações primárias dos formulários receberam o tratamento terracota da identidade visual; estados, cartões e navegação mantêm os tons creme, verde e terracota existentes.
- Verificação executada: `RAILS_ENV=development /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails zeitwerk:check` concluída com sucesso.
- O painel inicial foi simplificado: métricas vazias, etapas de implementação e avisos longos foram removidos. Ele agora apresenta somente atalhos para os módulos administrativos acessíveis e um status discreto de pedidos.
- Material Symbols Rounded passou a compor os ícones da navegação e dos atalhos administrativos, com texto visível junto a cada ícone para preservar compreensão e acessibilidade.
- A administração passou a usar menu lateral em desktop, com atalhos para os módulos disponíveis e marcação explícita de áreas futuras sem integração iFood. Em telas menores, o menu lateral é substituído pela navegação inferior.
- A tela administrativa de pedidos foi iniciada com rota autenticada, busca por número/cliente/telefone, filtro de status, tabela responsiva e detalhe do pedido. Ela depende da migration comercial e do checkout para receber pedidos reais; carrinho, finalização e redirecionamento seguro para WhatsApp continuam pendentes.
- Produtos agora aceitam imagem principal por Active Storage no formulário administrativo, limitada a PNG/JPEG/WEBP de 5 MB. A imagem aparece no cardápio e no detalhe público; produtos antigos sem imagem mantêm o placeholder visual.
# Catálogo público (05/10/2026)

- Implementados `GET /produtos`, `/sabores`, `/produtos/:slug` e `/categorias/:slug`, todos públicos por meio de `ProductsController < PublicController`.
- A vitrine usa somente produtos e categorias ativos. Produtos sem saldo, quando controlam estoque, permanecem visíveis com a indicação “Indisponível”; produtos inativos retornam 404 no detalhe e não aparecem em listagens.
- O visual foi adaptado da referência enviada: cartões leves, paleta terracota/creme e foco em nome, categoria, preço e disponibilidade. Dados fictícios da referência — avaliações, descontos, fotos externas, opções de bolo, entrega e compra simulada — não foram incorporados.
- Imagens cadastráveis, carrinho, checkout e paginação completa de catálogo permanecem pendentes. A listagem atual limita a 12 produtos e a home mostra até 24, conforme o padrão de volume da especificação.
- Evidências previstas: testes de integração para rotas públicas, filtragem de produtos ativos, disponibilidade e acesso direto a produto inativo.
