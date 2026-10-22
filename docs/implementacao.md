# Implementação

## Confirmação ao adicionar produto ao carrinho — 21/10/2026

- Ao adicionar um produto pelo cardápio, a resposta Turbo agora mostra a confirmação “Produto adicionado ao carrinho.”, sem abrir o carrinho automaticamente.
- O contador e o conteúdo do carrinho continuam sendo atualizados na mesma resposta.


## CTA único nos cards do cardápio — 21/10/2026

- Cada card de produto agora mostra somente a ação “Comprar”; o botão ocupa toda a largura disponível. A ação continua desabilitada e identificada quando os pedidos estão pausados ou o produto está indisponível.


## Alinhamento dos cards do cardápio no mobile — 21/10/2026

- Os cards do catálogo agora usam coluna flexível: o conteúdo preenche a altura da linha e o bloco de preço/disponibilidade fica no final. Assim, nomes maiores não deslocam preços e botões em relação ao card vizinho.
- Alteração somente de CSS em `app/assets/stylesheets/style.css`; não modifica produtos, estoque, carrinho ou checkout.
- Verificação pendente: inspeção visual em navegador mobile e execução da suíte Rails neste ambiente.

## Seed de administrador em produção — 21/10/2026

- Por decisão explícita da proprietária, a seed não impõe comprimento mínimo para a senha em produção.
- Permanecem obrigatórias as duas variáveis juntas; a conta é criada somente se o e-mail ainda não existir, sem redefinir senha já cadastrada.
- Evidência: teste de seed aprovado com 1 teste, 18 asserções, zero falhas ou erros.

## Escolha e cadastro de opções de produto — 21/10/2026

- O formulário administrativo de produto agora contém a seção “Opções e preços”. Ela permite adicionar/remover tamanhos ou sabores, informar preço, estoque, alerta de estoque baixo e ativação de cada opção, sem depender de uma tela separada.
- Na vitrine, opções são apresentadas como cartões selecionáveis com nome, preço e disponibilidade. Produtos que tenham opções exigem a escolha de uma opção: saldo do produto pai não libera uma compra direta que ignoraria o tamanho/sabor escolhido.
- Quando todas as opções estão sem saldo, seus nomes e preços permanecem visíveis no detalhe, identificados como indisponíveis. Assim a vitrine não inventa estoque e a pessoa entende o que será liberado após reposição.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/admin_product_variants_test.rb test/integration/product_catalog_test.rb test/integration/checkout_rules_test.rb` aprovado com **27 testes, 193 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.
- Correção visual posterior: regras antigas mais específicas estavam forçando as opções em uma linha flexível. A grade agora prevalece com duas colunas amplas e muda para uma coluna em até 700 px, impedindo compressão, sobreposição e rolagem horizontal.
- Evidências complementares: `test/integration/product_catalog_test.rb test/integration/checkout_rules_test.rb` aprovado com **26 testes, 184 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Catálogo de quitandas inicial — 21/10/2026

- A seed idempotente já registra a categoria “Quitandas da Tia Nely” e os cinco produtos da página recebida: Rosquinhas de Leite Condensado com Coco, Mãe Benta, Pão Santo Antônio Tradicional, Pão de Coco e Bolinho do Céu com Coco. Todas as porções e preços da referência foram conferidos na seed.
- Cada item é um produto e cada tamanho/sabor é uma variação com preço próprio. Esse formato permite que o cliente selecione a opção correta no detalhe antes de adicionar ao carrinho, preservando o preço no pedido.
- Nenhuma imagem ou quantidade de estoque é criada pela seed. A imagem principal pode ser anexada manualmente pelo formulário administrativo; enquanto as variações estiverem com estoque zero, o detalhe mantém as opções e preços visíveis como indisponíveis, sem simular venda.
- Evidências: seed aplicada uma vez no banco local de desenvolvimento, sem erro. Migrations aplicadas em banco de teste novo; `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/models/catalog_seed_test.rb test/integration/product_catalog_test.rb` aprovado com **7 testes, 63 asserções, zero falhas ou erros**. `zeitwerk:check` e `git diff --check` também aprovados.

## Feedback ao adicionar ao carrinho — 20/10/2026

- Removido o aviso verde exibido ao adicionar um produto ao carrinho por Turbo. A operação continua atualizando contador, drawer e página do carrinho, sem abrir o drawer automaticamente.
- Mensagens por Turbo são mantidas apenas para erros; o contêiner deixou de herdar o estilo de aviso verde quando está vazio.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/checkout_rules_test.rb` aprovado com **18 testes, 128 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Ativação de pedidos no painel — 20/10/2026

- Corrigido o estado inconsistente do botão de pedidos: antes, ele gravava a ativação mesmo sem WhatsApp comercial válido, mas a vitrine continuava bloqueada pela regra de segurança.
- Agora a loja só é ativada quando há WhatsApp válido; caso contrário, o painel mantém pedidos pausados e informa a configuração necessária. Ao pausar, a flag também é persistida corretamente.
- A regra foi centralizada em `StoreSetting#toggle_order_acceptance!`; o painel apenas apresenta a mensagem correspondente. Nenhum contato foi inventado nem alterado.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb test/models/store_setting_test.rb` aprovado com **10 testes, 58 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Acesso administrativo — 20/10/2026

- A tela `/iniciar-sessao` foi reorganizada em duas regiões: contexto da área restrita e formulário de acesso. Os campos agora informam a obrigatoriedade, têm textos de apoio associados para leitores de tela, foco visível, opção de manter sessão com linguagem clara e ação principal de largura completa.
- Corrigida a tradução de falha do Devise para administrador inexistente. A interface passa a exibir “E-mail ou senha inválidos.”, sem revelar se o e-mail está cadastrado.
- A alteração preserva rota, autenticação Devise, recuperação de senha, cabeçalho público e privacidade da página (`noindex, nofollow` e `no-store`). Nenhuma credencial, dado comercial ou comportamento de sessão foi adicionado.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb` aprovado com **7 testes, 42 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Tela de finalização do pedido — 19/10/2026

- A tela pública `/finalizar-pedido` foi redesenhada a partir da estrutura visual recebida: etapas do pedido, cartões de identificação, recebimento, endereço, pagamento, observações e resumo detalhado.
- Os controles são ligados aos campos e cálculos existentes. Entrega e retirada permanecem condicionadas à escolha do cliente; o CEP continua preenchendo endereço e o frete é consultado pelo bairro. Produtos sem imagem mostram apenas um ícone neutro, sem reutilizar imagens externas ou dados fictícios da referência.
- O resumo usa itens, quantidades, preços e total do carrinho no servidor. A confirmação ainda registra o pedido e conduz à página autorizada que oferece o envio pelo WhatsApp; não há cobrança, desconto, prazo, endereço, brinde ou confirmação comercial inventados.
- Evidências: `bundle exec rails test test/integration/cart_checkout_test.rb test/integration/checkout_rules_test.rb` aprovado com **20 testes, 155 asserções, zero falhas ou erros**. A suíte integral e a verificação de carregamento foram executadas ao final desta etapa.
- Correção posterior: os ícones desta tela deixaram de depender da fonte remota Material Symbols, que podia falhar e exibir nomes técnicos na interface. Foram substituídos por SVGs locais, e o topo ganhou espaçamento suficiente para não ficar sob o cabeçalho fixado. A verificação cobre a presença dos SVGs e a ausência dos nomes técnicos.
- Ajuste visual posterior: o checkout deixou de usar rosa como superfície dominante. A área de trabalho passou a usar marfim e areia suaves; cartões, controles e totais usam branco quente e bordas neutras. Terracota e verde continuam restritos aos elementos de ação e estado.
- Navegação pública: removido o atalho “Contato” do cabeçalho. Carrinho e Administração agora usam ícones SVG locais de carrinho e acesso administrativo, com texto e rótulos acessíveis preservados; o contador de itens continua atualizado pelo Turbo.
- Drawer do carrinho: ganhou cabeçalho próprio, miniatura ou ícone do produto, quantidade e remoção agrupadas por item, orientação sobre frete e rodapé fixado com total, revisão e finalização. As mesmas ações continuam usando os endpoints existentes.
- Interação do drawer: alterar a quantidade pelo campo ou pelas setas envia a atualização automaticamente por Turbo. O texto de atualização foi removido da interface; remoção passou a usar um botão de lixeira com rótulo acessível.
- Cabeçalho e rodapé: o carrinho passou a ser um botão flutuante com contador, mantendo a abertura do drawer. O rodapé foi reorganizado em formato centralizado, com links públicos e administrativos e crédito para Lucas Martins, direcionado ao portfólio informado pelo proprietário.
- Finalização: após validar e gravar o pedido, o checkout agora responde diretamente com redirecionamento 303 para o WhatsApp oficial, levando a mensagem do pedido já preenchida. O resumo autorizado permanece acessível pelo último pedido no carrinho para consulta ou reenvio posterior.

## Navegação administrativa — 21/10/2026

- Removido o atalho redundante “Ver vitrine” da barra superior. O acesso permanece uma única vez, no rodapé do menu lateral.
- Em desktop, a barra lateral passou de 238 px para 280 px; a logomarca foi ampliada para 64 px e os itens do menu ganharam área de toque e tipografia maiores. Em celular, a marca permanece compacta e a navegação inferior não foi alterada.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb` aprovado com **8 testes, 57 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Pedidos vinculados ao cliente — 21/10/2026

- A listagem administrativa de clientes passou a informar quantos pedidos cada cliente possui, calculando a contagem na própria consulta para evitar uma consulta adicional por linha.
- O detalhe do cliente ganhou um cartão de resumo com ícone e a quantidade de pedidos vinculados, incluindo a mensagem singular/plural apropriada.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/admin_customer_show_test.rb` aprovado com **2 testes, 20 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Visualização de clientes — 21/10/2026

- A página administrativa de cliente passou a concentrar contato, endereço e observações em cartões legíveis, com disposição em duas colunas amplas e uma coluna no celular.
- Foi incluído o botão destacado “Voltar aos clientes”. A ação de edição não aparece mais nessa visualização, evitando misturar consulta com alteração.
- A listagem usa ícones de visualizar, editar e excluir com rótulos acessíveis. Telefones são apresentados com a máscara brasileira, inclusive nas referências de cliente em pedidos e lançamentos.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/admin_customer_show_test.rb` aprovado com **2 testes, 14 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Detalhe de lançamento financeiro — 21/10/2026

- A listagem financeira passou a oferecer a ação "Ver" para cada lançamento. A tela de detalhe apresenta valor, tipo, origem, situação, vencimento, pagamento e observações.
- Quando houver pedido vinculado, a tela exibe cliente, telefone, recebimento, pagamento e a tabela dos itens do pedido, além de fornecer acesso ao detalhe administrativo do pedido. Lançamentos automáticos permanecem protegidos contra edição e exclusão direta; os manuais conservam essas ações com confirmação para excluir.
- Adicionado teste de integração da tela de detalhe. A execução continua pendente porque Ruby e Bundler não estão disponíveis neste WSL.
- Datas de vencimento e pagamento são apresentadas explicitamente como `dd/mm/aaaa`, sem depender do formato `date.default` que não existe nas traduções atuais.

## Detalhe administrativo de pedido — 21/10/2026

- O botão de WhatsApp foi removido apenas do detalhe administrativo do pedido. O resumo público autorizado mantém o botão de envio, que faz parte do fluxo do cliente.
- O detalhe foi reorganizado em cards próprios de itens/totais, atualização de status, movimentos e resumo do cliente. No celular, o layout se empilha em uma coluna e a tabela de itens preserva leitura por rolagem horizontal interna.
- O conjunto do detalhe é centralizado no espaço de trabalho em telas amplas, mantendo largura máxima legível; em telas móveis ele ocupa toda a largura disponível.
- A ação "Ver" de lançamento automático passou a abrir diretamente o pedido vinculado, inclusive quando a URL financeira é acessada manualmente. O pedido exibe o lançamento sincronizado e concentra a alteração de status que controla a baixa/restauração de estoque. Lançamentos manuais continuam no detalhe financeiro próprio.
- Links de retorno receberam tratamento visual padronizado: borda, contraste, seta, área mínima de toque e foco visível, preservando a adaptação para celular.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/admin_order_status_test.rb test/integration/admin_financial_entry_show_test.rb` aprovado com **2 testes, 28 asserções, zero falhas ou erros**; `zeitwerk:check` e `git diff --check` também aprovados.

## Máscaras de campos — 21/10/2026

- Adicionado controlador Stimulus reutilizável para máscara de telefone, CEP e moeda brasileira. O checkout mascara WhatsApp, CEP e troco; a administração mascara telefone/CEP de clientes e valores de produto e lançamento financeiro.
- Campos monetários aceitam a digitação `R$ 1.234,56` e os controllers normalizam esse formato para decimal antes da validação e persistência. Quantidade, data e campos textuais não recebem máscara por não terem formato visual fixo.
- Evidência: teste de integração cobre o troco enviado com máscara monetária. A execução foi bloqueada neste ambiente porque Ruby e Bundler não estão instalados no WSL; `git diff --check` foi aprovado. A suíte completa permanece pendente de execução em ambiente Rails.

## Revisão do caminho carrinho → pedido → WhatsApp — 19/10/2026

- Após confirmar o checkout, a aplicação responde com 303 para o resumo `/pedidos/:number` autorizado pela sessão. A página apresenta o pedido persistido e um botão “Enviar pedido pelo WhatsApp”; a mensagem codificada usa os itens e valores gravados, permitindo conferir e reabrir o link enquanto a sessão tiver acesso. O texto explica que registrar e abrir o link não envia a mensagem automaticamente.
- Produtos com variações ativas e sem estoque disponível deixam de parecer compráveis quando não há saldo próprio para venda direta. O servidor rejeita a tentativa de adicionar o produto sem uma variação válida. Foi preservada a compra direta já documentada quando o produto controla estoque e tem saldo próprio positivo.
- A suíte Minitest foi atualizada para percorrer o redirecionamento ao resumo, localizar o botão e decodificar a mensagem WhatsApp. Há teste adicional para variação esgotada. Evidências: `bundle exec rails test` com **41 testes, 282 asserções, zero falhas ou erros**; `bundle exec rails zeitwerk:check` e `git diff --check` aprovados.
- O recebimento continua condicionado a WhatsApp oficial válido e `accepting_orders` ativo. Cupons, promoções/brindes e configurações administrativas seguem pendentes; não foram apresentados como operacionais. Não houve envio real de mensagem nem validação manual da abertura do aplicativo ou deploy.

## Confirmação de carrinho e acesso à finalização — 15/10/2026

- Ao adicionar um produto via Turbo, a vitrine agora mostra uma confirmação visual persistente, com mensagem clara e atalho para revisar o carrinho. O drawer permanece fechado nesse momento, conforme a seção 9 da especificação, evitando interromper a escolha de outros produtos.
- O drawer passou a oferecer as duas próximas ações: “Ver carrinho” para revisão completa e “Finalizar pedido”, que abre a tela própria `/finalizar-pedido`. A mesma ação de finalização já permanece disponível no resumo da página do carrinho.
- Adicionado teste de integração para assegurar que a resposta Turbo atualiza contador, conteúdo do drawer, confirmação com link e não tenta abrir/substituir o drawer.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/checkout_rules_test.rb` aprovado com **17 testes, 117 asserções, nenhuma falha ou erro**; `zeitwerk:check` e `git diff --check` também aprovados.


## Opções de produto indisponíveis — 15/10/2026

- Quando o produto controla seu próprio estoque e tem saldo positivo, ele pode ser comprado diretamente, mesmo que existam variações antigas sem saldo. Assim, a quantidade cadastrada no produto continua sendo respeitada.
- A tela lista apenas opções compráveis; se nenhuma estiver disponível, ela não mostra o seletor vazio. Nessa situação, com saldo próprio positivo, exibe a compra direta; sem saldo, informa que o produto está indisponível.
- Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/product_catalog_test.rb test/integration/checkout_rules_test.rb` aprovado com **23 testes, 158 asserções, nenhuma falha ou erro**; `zeitwerk:check` e `git diff --check` também aprovados.

## Carrinho e finalização para WhatsApp — 15/10/2026

- Seções 8–9, 12–13 e 22: concluído o fluxo básico de compra sobre a implementação inicial. O carrinho rejeita quantidades inválidas e soma acima de 99; atualizar ajusta ao estoque/teto, remove itens indisponíveis e informa o ajuste. Respostas Turbo atualizam contador, conteúdo do drawer, página e feedback sem substituir o drawer aberto; HTML permanece funcional.
- O POST revalida produto/variação, quantidade e estoque, mínimo antes de frete (inclusive retirada), telefone, modalidade, pagamento, endereço, CEP e troco. Valores e status enviados pelo navegador não controlam os cálculos. Não há baixa de estoque no checkout.
- Cliente normalizado, pedido pendente, itens com snapshots de nome/preço e receita pendente são persistidos na mesma transação. Falhas preservam formulário e carrinho; sucesso limpa o carrinho e responde com redirecionamento 303 para o WhatsApp configurado.
- Entrega procura área ativa pelo bairro normalizado, com fallback para a taxa padrão informada no formulário. Retirada tem frete zero. Consulta de CEP pelo backend utiliza HTTPS/ViaCEP e timeouts de 3 segundos, permite preenchimento manual; a estimativa de frete usa endpoint próprio e é recalculada ao finalizar.
- Mensagem inclui itens, totais, modalidade, pagamento traduzido, troco, endereço e observações. Resumo em `/pedidos/:number` exige a sessão que criou o pedido, com cabeçalhos de privacidade. O carrinho oferece acesso ao último pedido; detalhe administrativo também permite reabrir a mensagem.
- O formulário desativa Turbo e bloqueia repetição do envio enquanto navega. Isso não oferece idempotência entre múltiplas abas/requisições; continua pendente uma garantia persistente de idempotência.
- Evidências: testes direcionados `checkout_rules_test.rb`, `cart_checkout_test.rb` e `store_setting_test.rb`: **21 testes, 137 asserções, zero falhas/erros**. Cobrem redirecionamento/codificação, estoque alterado, produto inativo, variação, mínimo, pausa após GET, dados inválidos, fraude de totais, fallback/área, rollback financeiro, privacidade e Turbo. Suíte completa: **30 testes, 177 asserções, duas falhas visuais preexistentes em FoundationAccessTest, zero erros**.
- Configuração local atualizada com o WhatsApp informado pelo proprietário, normalizado com DDI brasileiro. Dados comerciais mínimos válidos e recebimento ativado localmente para validar o fluxo de carrinho/checkout. O número foi armazenado somente no banco de desenvolvimento, sem inclusão no código ou nesta documentação.
- Pendências fora deste fluxo básico: cupons e promoções/brindes (seções 10–11, incluindo integração ao carrinho e checkout), CRUD de áreas/configurações, ciclo administrativo de estoque/status e financeiro, snapshot próprio de identificação do cliente para reenvios históricos, validação de navegador e abertura manual do aplicativo WhatsApp. A consulta real ao ViaCEP não foi exercitada nesta etapa. Nenhuma mensagem foi enviada e nenhuma configuração de produção foi modificada.
- O cardápio exibe somente a ação “Comprar” em cada produto disponível. Sem variações, ela adiciona uma unidade; com opções ativas, leva à escolha obrigatória antes de adicionar. Quando o recebimento está pausado ou o item está indisponível, o aviso correspondente permanece visível e desabilitado.
- Evidência complementar: `product_catalog_test.rb` e `checkout_rules_test.rb` passaram com **21 testes, 141 asserções, zero falhas/erros**.

## Status de pedidos e estoque — 15/10/2026

- Seções 14–15: o painel administrativo agora permite atualizar o status de pedidos autenticados. Ao entrar pela primeira vez em confirmado, em preparo, pronto, saiu para entrega ou entregue, o pedido baixa os saldos necessários em uma transação e cria movimentos auditáveis. O checkout continua sem baixar estoque.
- Para produtos controlados, a baixa verifica atividade e saldo antes de alterar qualquer registro; itens repetidos são agregados. Variações baixam apenas o próprio saldo. Uma tentativa sem saldo suficiente ou com produto inativo não altera status, estoque, movimentos nem receita.
- Cancelar um pedido com baixa restaura os saldos uma vez e registra o movimento; confirmar novamente depois de cancelado baixa novamente. Voltar para pendente não restaura saldo, conforme a regra definida. A receita automática permanece pendente nos status em aberto, é marcada paga na entrega e cancelada quando o pedido é cancelado.
- Evidências: `order_stock_test.rb` e `admin_order_status_test.rb` cobrem produto, variação, agregação, saldo insuficiente, inativação, cancelamento, reativação, entrega, receita e autorização administrativa. A execução conjunta com os testes de carrinho/checkout teve **28 testes, 192 asserções, zero falhas/erros**. As duas expectativas visuais antigas de `FoundationAccessTest` foram alinhadas à home de cardápio e ao painel administrativo atuais. Suíte completa: **37 testes, 240 asserções, zero falhas/erros**. `zeitwerk:check` também foi aprovado.

## Carrinho e checkout próprio — 14/10/2026

- Implementados carrinho persistido em sessão e rotas públicas para adicionar, alterar quantidade, remover, esvaziar e visualizar itens. Produto e variação são revalidados no servidor a cada operação; quantidade é limitada a 99 e respeita estoque quando aplicável.
- A vitrine agora permite adicionar produtos disponíveis quando a configuração comercial estiver válida e o recebimento de pedidos estiver ativo. O drawer lateral e a página `/carrinho` exibem o mesmo carrinho; a loja pausada impede adicionar itens e acessar ou concluir checkout.
- Implementado checkout próprio em `/finalizar-pedido`: identificação, retirada/entrega, endereço obrigatório apenas na entrega, pagamento, troco, observações e resumo. O mínimo efetivo de R$ 20,00 é aplicado também na retirada. Frete de entrega usa, por enquanto, somente a taxa padrão configurada; cupons, promoções e áreas de entrega continuam pendentes e não são apresentados como operacionais.
- Ao confirmar, o sistema normaliza/atualiza o cliente por telefone, cria pedido pendente, itens com snapshot de preço e receita automática pendente em uma transação, limpa o carrinho e redireciona para o WhatsApp oficial configurado com a mensagem detalhada codificada. Não há iFood, gateway ou envio automático de mensagem.
- Evidências: `RAILS_ENV=test ... bin/rails db:migrate` aplicado somente no banco de teste; `RAILS_ENV=test ... bin/rails test test/integration/cart_checkout_test.rb` aprovado com **2 testes, 20 asserções, nenhuma falha ou erro**. `zeitwerk:check` aprovado. A suíte completa ainda tem duas falhas preexistentes em `FoundationAccessTest`, cujas expectativas de texto/layout não correspondem às telas atuais; o fluxo novo passou isoladamente.

## Correção do layout de autenticação — 15/10/2026

- `current_cart` passou a ser fornecido por `ApplicationController`. As telas Devise de iniciar sessão e recuperação de senha usam o layout público, mas não herdam de `PublicController`; centralizar o helper preserva o carrinho na sessão e impede erro de renderização no cabeçalho/drawer.
- Adicionado teste de integração para `GET /iniciar-sessao`, verificando a renderização do contador de carrinho vazio. Evidências: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb:22` aprovado com **1 teste, 3 asserções, nenhuma falha ou erro**; `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails zeitwerk:check` aprovado. A execução integral de `foundation_access_test.rb` ainda tem duas falhas preexistentes de expectativas visuais desatualizadas (título da home e seletor do dashboard), sem relação com esta correção.

## Acesso temporário de demonstração — 15/10/2026

- O ambiente de desenvolvimento aceita hosts adicionais somente quando informados em `RAILS_ALLOWED_HOSTS`, separados por vírgula. A proteção contra hosts não autorizados permanece ativa por padrão; a variável serve para túneis temporários de demonstração, sem alteração de produção ou DNS permanente.
- Ao iniciar uma demonstração com `SHARE_DEMO=1`, as páginas de erro detalhadas de desenvolvimento ficam desativadas. Esse modo não substitui uma implantação de produção, mas evita revelar traces ao visitante do túnel temporário.
- Evidência: o Quick Tunnel ativo foi verificado externamente com resposta HTTP `200` para a rota `/`. O endereço expira quando o processo do túnel ou o computador for interrompido; nenhum domínio, DNS permanente ou serviço de produção foi configurado.

Estado atual: fundação, catálogo e fluxo básico de carrinho/checkout implementados; as limitações mais recentes estão registradas na entrada de 19/10/2026. Os registros abaixo preservam o histórico de cada etapa. Especificação original preservada, SHA-256 `50fb8dcb81202deb71b5a44d23c8fd089cbe2996034b9d503cf085d08c1ef9c2`.

## Matriz da especificação

| Seções | Fundação / evidência | Pendência |
|---|---|---|
| 1–3 | AGENTS.md, Gemfile, configurações Rails, identidade própria | Evoluir mantendo precedência e monólito |
| 4 | Devise Admin sem registro público, controllers autenticados, testes de acesso | Recuperação por e-mail depende de SMTP; autorização de pedidos no módulo de checkout |
| 5 | Home, institucionais, administração inicial, login/logout e healthchecks | Rotas funcionais de cada módulo |
| 6 | Admin, StoreSetting, Active Storage e migrations | Demais models, relações e índices junto aos módulos |
| 7 | Catálogo público de produtos e categorias, detalhes, disponibilidade e variações disponíveis; infraestrutura de upload | Kits, imagens cadastráveis, busca e paginação completa |
| 8 | Configuração única, valores decimais, padrão pausado | CRUD administrativo e bloqueios nos futuros endpoints de compra |
| 9 | Cart, CartController, parciais HTML/Turbo e CheckoutRulesTest | Integração com cupons e brindes |
| 10–11 | Sem promoção ou cupom anunciado como disponível | Cupons, combos, brindes e concorrência |
| 12–13 | CheckoutController, OrdersController, PostalCodesController, OrdersHelper e testes de integração | Cupons/promoções, idempotência persistente, verificação de navegador/ViaCEP real/WhatsApp |
| 14 | Alteração administrativa de status, movimentos de venda/restauração e baixa transacional | Ajustes manuais, concorrência em produção, exclusão auditável e brindes pendentes |
| 15 | Receita automática pendente/paga/cancelada sincronizada com status do pedido | Financeiro comercial completo e vendas manuais |
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

O recebimento de pedidos está ativado na configuração local com dados comerciais válidos. O fluxo básico de checkout está verificado pelos testes acima. Não há integração iFood nem dependência de fila para reproduzi-la.

## Verificações

### Seed de desenvolvimento — 04/10/2026

- `db/seeds.rb` cria de forma idempotente a configuração única da loja, com recebimento de pedidos desativado, mínimo `R$ 0,00`, frete padrão `R$ 10,00` e mensagem de pausa padrão. Configurações comerciais existentes nunca são sobrescritas.
- Para criar o primeiro administrador, informe as duas variáveis no mesmo comando; a seed só cria a conta se aquele e-mail ainda não existir e nunca redefine uma senha já cadastrada:

  ```bash
  SEED_ADMIN_EMAIL="seu-email@exemplo.com" SEED_ADMIN_PASSWORD="escolha-uma-senha-segura" bin/rails db:seed
  ```

- A seed exige que e-mail e senha sejam informados juntos, mas não impõe comprimento mínimo para a senha em produção. Nenhuma credencial ou dado comercial foi colocado no repositório. Produtos, pedidos, estoque e financeiro continuam pendentes porque seus modelos ainda não foram implementados.
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


## Página Quem Somos — 21/10/2026

- A página pública “Quem Somos” passou a apresentar a história fornecida pela proprietária: origem familiar da Delícias da Tia Nely, atuação da Tia Nely e da Aleandra, produção artesanal sob encomenda e convite ao cardápio.
- O conteúdo foi organizado em cabeçalho, narrativa, chamada ao cardápio e assinatura final, sem acrescentar contatos ou informações comerciais não fornecidas.
- Evidência: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb` aprovado com **8 testes, 63 asserções, zero falhas ou erros**.


## Navegação pública em mobile — 21/10/2026

- A navegação pública agora agrupa Cardápio, Quem Somos e Administração em um menu hambúrguer em telas de até 620 px. O menu abre pelo botão próprio, fecha ao escolher um destino e pode ser fechado com Esc.
- Em telas maiores, os destinos permanecem visíveis e Administração passou a usar somente o ícone, com rótulo acessível para leitores de tela.
- A página Quem Somos preserva a assinatura “Delícias da Tia Nely — Sabor de casa, memórias que ficam.”.
- Evidência: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb` aprovado com **8 testes, 68 asserções, zero falhas ou erros**.


- Ajuste posterior: dentro do menu hambúrguer, Administração é exibida como item completo com ícone e texto; fora dele, permanece como botão somente com ícone. Evidência: teste de integração público aprovado com **8 testes, 68 asserções, zero falhas ou erros**.


## Produtos relacionados em pares — 21/10/2026

- A seção “Você também pode gostar” do detalhe do produto agora mantém os cards em duas colunas, inclusive em telas de até 480 px, em vez de empilhá-los em uma única coluna.
- Evidência: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/product_catalog_test.rb` aprovado com **7 testes, 54 asserções, zero falhas ou erros**.


## Dashboard administrativo e avisos temporários — 21/10/2026

- O dashboard administrativo foi reorganizado com cabeçalho orientado à operação, status da loja destacado, métricas com ícones, ações rápidas descritivas, estados vazios e lista de vendas recentes mais legível, preservando os dados e rotas existentes.
- Avisos administrativos agora aparecem como toast centralizado, podem ser fechados manualmente e desaparecem após cinco segundos. Avisos de erro preservam cor e ícone distintos.
- Evidência: `RAILS_ENV=test /usr/local/rbenv/versions/3.4.2/bin/ruby bin/rails test test/integration/foundation_access_test.rb` aprovado com **8 testes, 68 asserções, zero falhas ou erros**.
