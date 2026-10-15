# Delícias da Tia Nely — regras completas para implementação

## 1. Escopo, origem e precedência

Este documento é uma especificação autossuficiente para construir outro projeto com a arquitetura e os módulos da aplicação Sweet Flavor, adaptados à marca **Delícias da Tia Nely**. Foi consolidado em 02/10/2026 a partir de `.ai-framework/RULES.md`, models, controllers, rotas, helpers, JavaScript, migrations, configurações e testes do projeto de referência no commit `21ec1ba`.

Inclui regras documentadas e comportamentos de negócio implementados. Não é uma cópia literal do código nem uma garantia de que a aplicação de origem cumpra todas as regras: divergências e melhorias necessárias estão explicitadas abaixo. Detalhes internos sem efeito funcional não precisam ser reproduzidos linha a linha.

**Exclusão integral:** não implementar integração iFood, polling, autenticação de merchant, mapeamentos, importação/conciliação de pedidos, sincronização de disponibilidade, confirmação externa, leases, jobs, telas, tabelas, rotas, testes ou variáveis dessa integração. Não criar `source`, `external_id`, `external_item_id` ou `ifood_confirmation_status` por herança dessa integração. O checkout próprio deve funcionar sem esses campos.

Precedência para o novo projeto:

1. Instruções explícitas do proprietário do novo projeto.
2. Decisões e regras consolidadas deste documento.
3. Comportamentos da referência descritos como tal, quando não conflitantes.
4. Convenções Rails existentes.

Decisões sobre divergências encontradas:

- **Versões:** regras antigas citam Ruby `~> 3.3` e Rails `~> 8.0`; `.ruby-version`, Gemfile e aplicação efetivos usam Ruby 3.4.2 e Rails 8.1 (`~> 8.1.3`). Adotar a arquitetura/linha efetiva, mantendo versões consistentes em Docker e desenvolvimento.
- **Frete:** documentação antiga exige bloquear região não atendida; código atual cobra R$ 10 quando não encontra área cadastrada. Para equivalência funcional, adotar esse fallback inicial, explicitamente apresentado ao cliente. Centralizar valor em `StoreSetting.default_delivery_fee`, inicializado em R$ 10, corrigindo a divergência entre configuração e constante. Bloqueio geográfico estrito somente quando definido pelo proprietário.
- **Mínimo:** código impõe piso de R$ 20 a todo checkout, inclusive retirada, antes de frete/desconto. Preservar essa regra, mesmo que textos antigos mencionem somente entrega.
- **Financeiro:** pedido pendente já gera receita pendente; entregue gera receita paga; cancelado gera receita cancelada. Preservar o ciclo completo.
- **Exclusão:** existe exclusão administrativa de pedidos com compensações. Disponibilizar com confirmação explícita na interface e transação. Cancelamento é o fluxo normal; exclusão não pode ocorrer por rotinas automáticas.
- **Segurança e consistência:** não reproduzir falhas como credenciais fixas em seeds, dados pessoais públicos por número de pedido, fallback silencioso de variação inválida ou exposição de exceções internas ao cliente. As proteções descritas aqui são requisitos do novo projeto.
- **Timezone:** referência configura `America/Porto_Velho`. Usar esse padrão configurável; não inferir cidade/endereço da nova loja.
- **Hospedagem:** referência documenta Render/Docker; operação relatada usa VPS/Nginx. Documentar ambos, sem presumir infraestrutura já contratada.

## 2. Identidade, linguagem e objetivo

- Nome público: Delícias da Tia Nely. Identificador técnico: `delicias_da_tia_nely`.
- Loja privada com vitrine pública, carrinho, checkout e pedidos encaminhados ao WhatsApp, além de painel administrativo.
- Domínio de referência: dindins tradicionais, gourmet, cremosos, frutados, especiais, alcoólicos quando aplicável, kits, combos, sazonais e encomendas. Catálogo configurável, sem limitar a marca permanentemente a esses exemplos.
- Prioridade: converter visita em pedido com poucos passos, boa leitura e confiança.
- Textos de interface, URLs públicas, validações, mensagens, notices e documentação operacional em PT-BR.
- Tom comercial acolhedor, familiar, leve e apetitoso; evitar exageros.
- Usar BRL: `R$ 1.234,56`. Datas e horários localizados.
- Preservar marca, logo, identidade visual, SEO e simplicidade do fluxo.
- Não reutilizar nome, logo, WhatsApp, Pix, endereço, e-mails ou dados reais da loja de origem.
- Dados comerciais reais ausentes devem ser configurados pelo proprietário; não inventar informações para publicação.

## 3. Stack e arquitetura

- Monólito Ruby on Rails com Ruby 3.4.2 e Rails 8.1, SQLite inicialmente.
- ERB, Turbo Rails, Stimulus e Importmap; Propshaft para assets.
- Devise para administradores, Ransack para filtros, Pagy para paginação.
- Active Storage para imagens e `image_processing` quando necessário.
- Tailwind via CDN nos layouts e CSS próprio em `app/assets/stylesheets/style.css`.
- ViaCEP consultado pelo backend para endereço.
- Puma como servidor; Docker/Thruster podem seguir a infraestrutura Rails de referência.
- Não adicionar Node, npm, yarn, pnpm, bundlers JS, React, Vue ou SPA sem pedido explícito.
- Evitar gems, service objects e abstrações grandes desnecessárias; preferir model, controller, concern e transação Rails.
- Models em `app/models/`; migrations em `db/migrate/`; documentação em `docs/`.
- Controllers administrativos em `app/controllers/admin/`, views correspondentes em `app/views/admin/`.
- Layout público em `app/views/layouts/application.html.erb`; admin em `app/views/layouts/admin.html.erb`.
- Views públicas em `home/`, `products/`, `orders/`, `cart/` e `shared/`.
- Stimulus em `app/javascript/controllers/`; helpers em `app/helpers/`.
- `ApplicationController` exige login por padrão. `PublicController` libera acesso público explicitamente. `Admin::BaseController` usa layout administrativo.
- Configurações comerciais centralizadas em `StoreSetting`; segredos fora do código.
- Não exigir fila/background worker para enviar pedido ao WhatsApp: fluxo gera link, não faz envio automático de mensagem.
- Solid Queue/Cache/Cable só precisam de bancos e processos se habilitados por funcionalidades efetivamente usadas; nunca copiar tarefas recorrentes da integração excluída.

## 4. Autenticação e autorização

- Devise sem cadastro público (`registrations` desabilitado).
- Login `/iniciar-sessao`, logout `/sair`, recuperação de senha sob `/senha` quando configurada.
- Após login, abrir administração; após logout, home pública.
- Alteração de produto, preço, estoque, cliente, pedido, cupom, promoção, financeiro e configuração exige administrador autenticado.
- Páginas administrativas não podem ser acessadas publicamente.
- Cadastro do cliente ocorre no checkout; não exige criar conta de consumidor.
- Não expor listas, histórico, endereço, telefone, financeiro ou detalhes de pedidos de terceiros na vitrine.
- Página pública de pedido deve exigir autorização da sessão que criou o pedido ou token seguro dedicado. Conhecer o número exibido do pedido não deve bastar. Essa proteção corrige uma lacuna da referência.
- Não remover CSRF nem autenticação para fazer Turbo/checkout funcionar.

## 5. Rotas funcionais

Preservar paths em português e helpers Rails claros:

| Método | Path | Função |
|---|---|---|
| GET | `/` | Home |
| GET | `/produtos`, `/sabores` | Catálogo |
| GET | `/produtos/:slug` | Produto |
| GET | `/categorias/:slug` | Categoria |
| GET | `/carrinho` | Carrinho |
| POST | `/carrinho/itens` | Adicionar item |
| PATCH / DELETE | `/carrinho/itens/:key` | Atualizar/remover item |
| POST / DELETE | `/carrinho/cupom` | Aplicar/remover cupom |
| DELETE | `/carrinho` | Esvaziar |
| GET / POST | `/finalizar-pedido` | Formulário/criação |
| GET | `/pedidos/:number` | Resumo autorizado |
| GET | `/quem-somos`, `/contato` | Institucional |
| GET | `/cep/:zip_code` | Consulta de CEP |
| GET | `/health`, `/up` | Saúde da aplicação |

Namespace `admin`, path `/administracao`, incluindo dashboard e recursos: `categorias`, `produtos`, imagens/variações aninhadas em produtos, `clientes`, `pedidos`, alteração de status de pedido, `areas-de-entrega`, `estoque`, `financeiro`, `analise-de-vendas`, `financeiro-pessoal`, `descontos`, `promocoes`, `brindes` e singleton `configuracoes`.

Clientes no admin: listar, ver, editar, atualizar e excluir quando não houver dependências. Pedidos: listar, ver, editar, atualizar, mudar status e excluir com confirmação. Estoque: listar/criar movimentos, sem editar histórico livremente. Brindes: definir sabor de item pendente. Financeiro pessoal: CRUD e alternância de pagamento.

## 6. Modelo de dados

Todos os models persistidos têm identificador e timestamps. Valores monetários usam `decimal`, preferencialmente precisão 10 e escala 2; cálculos Ruby usam `BigDecimal`, não `Float`.

| Model | Campos e relações essenciais |
|---|---|
| `Admin` | E-mail, senha criptografada, campos Devise de recuperação/lembrança |
| `Category` | Nome, slug, descrição, ativo, ordem; muitos produtos |
| `Product` | Categoria, nome, slug, descrição, preço, ativo, destaque, controle de estoque, quantidade, limite de estoque baixo, ordem, imagem principal; imagens adicionais, variações, itens e movimentos |
| `ProductVariant` | Produto, nome, preço opcional, ativo, quantidade, limite de estoque baixo |
| `ProductImage` | Produto, título, posição e anexo de imagem |
| `Customer` | Nome, telefone, e-mail opcional, CEP, rua, número, bairro, cidade, UF, complemento, referência e observações; pedidos |
| `DeliveryArea` | Nome, slug, taxa, prazo estimado, ativo |
| `Order` | Cliente, área opcional, cupom opcional, promoção opcional, número único, status, modalidade, pagamento, troco, subtotal, frete, desconto, total, endereço completo, observações, `stock_deducted` |
| `OrderItem` | Pedido, produto/variação, nome registrado, quantidade, preço unitário, total, `promotion_gift`, `surprise_gift` |
| `StockMovement` | Produto/variação, pedido opcional, quantidade assinada, tipo, motivo e observações |
| `Discount` | Nome, código, tipo, valor, mínimo, ativo, início/fim, limite e contador de usos |
| `Promotion` | Nome, quantidade comprada exata, quantidade de brindes, surpresa, frete grátis, ativo e ordem |
| `FinancialEntry` | Pedido opcional, tipo receita/despesa, status, descrição, valor, vencimento, pagamento, automático, observações |
| `FinancialEntryItem` | Lançamento, produto/variação, nome registrado e quantidade |
| `PersonalFinancialEntry` | Descrição, tipo, responsável, categoria textual, valor, vencimento, pagamento, status e observações |
| `StoreSetting` | Nome da loja, WhatsApp, Pix, endereço, horários, mensagem de pedido, mínimo, frete padrão, política de retirada, redes sociais, recebimento de pedidos e mensagem de pausa |

- Índices em slugs/códigos/números únicos, FKs, campos de status, datas e filtros frequentes.
- Campos obrigatórios com validação de model e restrições coerentes no banco.
- Allowlists explícitas de atributos e associações Ransack; atualizar quando surgirem campos filtráveis. Nunca liberar senha, tokens ou segredos.
- Slugs por `parameterize`, únicos, com sufixo em colisão; preservar slug existente ao mudar nome, salvo edição explícita.
- Categoria com produtos, cliente com pedidos, produto/variação com itens históricos e promoção com pedidos não podem ser apagados quebrando vínculos. Preferir desativação.
- Manter snapshots de nomes/preços nos itens para preservar histórico.

## 7. Catálogo, imagens e disponibilidade

- Categoria exige nome e slug; ordenação por ordem de exibição e nome; navegação usa categorias ativas.
- Produto exige nome, categoria e preço válido. Ativo exige preço maior que zero; preço de inativo não negativo.
- Estoque e limite de estoque baixo são inteiros não negativos.
- Variação exige nome; preço ausente herda preço do produto, preço informado não negativo. Variação disponível exige ela e produto ativos, estoque positivo.
- Produto sem controle de estoque não limita venda pelo saldo do produto; variações continuam com estoque próprio.
- Produto disponível: ativo e sem controle de estoque, ou saldo próprio positivo, ou ao menos uma variação ativa disponível.
- Estoque baixo: controle ativo e saldo maior que zero e menor/igual ao limite. Esgotado: saldo zero sob controle de estoque.
- Produto inativo não aparece na vitrine, busca, carrinho ou checkout; acesso direto não deve vendê-lo.
- Esgotados podem permanecer no catálogo identificados como indisponíveis, com compra desabilitada.
- Produtos relacionados: até quatro disponíveis, primeiro mesma categoria, completar com demais categorias, sem repetir produto atual.
- Home da referência mostra até 24 produtos; listagens e categorias paginam 12 por página. Preservar esses padrões iniciais.
- Tela do produto: foto principal, galeria, nome, descrição, preço, disponibilidade, variações disponíveis, quantidade, adicionar ao carrinho, contato WhatsApp e relacionados.
- Imagens PNG/JPEG/WEBP até 5 MB, validação no servidor tanto da principal quanto das adicionais.
- Posição de imagem adicional: inteiro não negativo; ordem por posição e criação.
- Produto sem imagem usa placeholder coerente com a nova marca, sem asset quebrado.
- Imagem principal é requisito de qualidade para publicação da vitrine; a referência aceita ausência com placeholder. Não adicionar bloqueio de model silenciosamente.

## 8. Configurações e pausa de vendas

- Uma configuração corrente centraliza dados comerciais; evitar múltiplas configurações concorrentes.
- Nome e WhatsApp obrigatórios para operação comercial; telefone oficial com DDI/DDD e apenas dígitos na URL.
- `minimum_order_value` e `default_delivery_fee` não negativos.
- Piso efetivo do checkout = maior entre mínimo configurado e R$ 20.
- `accepting_orders` permite pausar vendas manualmente sem remover vitrine.
- Mensagem padrão: “No momento não estamos recebendo pedidos. Voltamos em breve.”; permitir personalização.
- Loja pausada bloqueia adicionar item, abrir checkout e concluir pedido. Revalidar no POST mesmo se formulário foi aberto antes da pausa.
- Horário exibido é informativo: referência não fecha loja automaticamente por horário; não inventar essa automação.
- Antes de dados reais válidos, inicializar nova loja com recebimento de pedidos desabilitado.
- Endereço, redes sociais, política de retirada, mensagem de WhatsApp e Pix são configuráveis; publicar apenas informações destinadas ao consumidor.

## 9. Carrinho

- Persistir na sessão, distinguindo produto e variação por chave; servidor resolve registros e preços atuais.
- Permitir adicionar, incrementar, reduzir, remover, esvaziar, aplicar/remover cupom, visualizar subtotal, desconto, frete estimado e total.
- Quantidades inteiras positivas; interface opera entre 1 e 99 por item. No novo projeto aplicar teto também à soma de adições repetidas, fechando lacuna da referência.
- Quantidade zero/negativa em atualização remove item. Entrada inválida não pode produzir venda inválida.
- Ao adicionar, considerar quantidade já existente e rejeitar soma que exceda estoque.
- Ao atualizar, limitar ao saldo disponível e ao teto; informar ajuste; remover item que ficou indisponível.
- Verificar que variação pertence ao produto. Nunca converter silenciosamente variação inexistente/inativa em compra do produto sem variação.
- Revalidar itens após alterações de preço, atividade e estoque, inclusive no checkout.
- Não confiar em subtotal, desconto ou frete enviados pelo navegador.
- Contador inclui unidades compradas e brindes; subtotal inclui apenas unidades cobradas.
- Drawer e página completa do carrinho devem refletir mesmo estado.
- Adicionar via Turbo atualiza contadores mobile/desktop e feedback sem abrir drawer automaticamente. Alterar/remover/cupom mantém drawer aberto.
- Manter fallback HTML funcional e mensagens claras; Turbo Stream atualiza parciais pertinentes.
- Esvaziar limpa itens e cupom. Checkout bem-sucedido limpa ambos; falha preserva carrinho e dados preenchidos.

## 10. Cupons

- Model é `Discount`, representando cupom de checkout, não desconto individual de produto.
- Tipos: `percentage`, `fixed_amount`, `free_shipping`.
- Código obrigatório e único sem diferenciar caixa; normalizar para maiúsculas e remover espaços.
- Nome, tipo e valores válidos obrigatórios. Percentual entre mais que zero e 100; valor fixo maior que zero; frete grátis pode ter valor zero.
- Mínimo não negativo; contador de usos inteiro não negativo; limite opcional inteiro positivo.
- Início/fim opcionais; fim não anterior ao início. Intervalo inclui os limites.
- Cupom disponível exige ativo, período válido e limite não atingido.
- Somente um cupom por carrinho; manter código na sessão e permitir remover.
- Aplicação exige carrinho não vazio, código existente e subtotal mínimo; mostrar motivo específico de rejeição.
- Percentual incide sobre subtotal; desconto fixo/percentual nunca supera subtotal.
- Frete grátis zera taxa, não cria desconto monetário duplicado; válido no checkout somente para entrega com frete positivo antes do cupom.
- No carrinho, frete grátis pode ser validado antes de escolher entrega, com aviso de que será aplicado na entrega.
- Revalidar cupom, mínimo, vigência e limite no POST de checkout.
- Incrementar uso dentro da transação de pedido, com lock e rechecagem do limite; falha não consome uso.
- Referência não devolve uso automaticamente ao cancelar/excluir pedido. Preservar até regra explícita diferente.
- Cupom monetário pode combinar com promoção; se promoção já zera frete, referência rejeita cupom adicional de frete grátis por não haver frete a descontar.
- Exibir nome/código/tipo/valor/período/ativo/usos no admin; índices e formulários autenticados.

## 11. Promoções, combos e brindes

- `Promotion` exige nome, quantidade comprada inteira positiva e quantidade de brindes inteira não negativa.
- Promoção aplica apenas quando quantidade comprada é **exatamente** a configurada. Não funciona por múltiplos nem faixas.
- Contar unidades pagas entre sabores/variações, excluindo brindes.
- Selecionar primeira promoção ativa aplicável na ordenação por ordem, quantidade e nome; não empilhar múltiplas promoções.
- Promoção pode oferecer brindes, frete grátis ou ambos.
- Havendo brinde, `surprise_gift` deve estar marcado: sabor escolhido pela loja.
- Brinde surge como item gratuito, com quantidade da promoção; não altera subtotal nem mínimo.
- Exemplos funcionais dos testes: 5 unidades compradas dão 1 brinde; 10 dão 2 e frete grátis. São cadastros exemplificativos, não automação obrigatória de seed de produção.
- Item de brinde pode nascer sem produto somente quando marcado como brinde surpresa pendente.
- Demais itens exigem produto; preço de brinde sempre zero; total do item = quantidade × preço unitário.
- No WhatsApp, identificar brinde como gratuito e sabor a definir pela loja.
- Admin só pode definir sabor enquanto brinde estiver pendente; escolher produto ativo, validar saldo e manter preço zero.
- Se estoque do pedido ainda não foi debitado, definição do sabor aguarda baixa normal. Se já debitado, baixar quantidade do brinde ao defini-lo, com transação e lock.
- Brinde sem produto definido não baixa estoque de um sabor arbitrário.
- Cancelamento restaura apenas estoque efetivamente debitado, incluindo brindes já definidos.
- Preservar vínculo da promoção ao pedido; mudança/desativação posterior não reescreve pedido existente.

## 12. Checkout, cliente e entrega

- GET do checkout exige carrinho não vazio e loja recebendo pedidos; fallback para carrinho/home com aviso.
- Cliente exige nome e telefone; e-mail opcional. Localizar cliente por telefone e atualizar dados fornecidos, preservando histórico de pedidos.
- Referência compara telefone tal como salvo; novo projeto deve normalizar de maneira consistente antes da identificação para evitar duplicidade por máscara.
- Modalidades: `pickup` e `delivery`; padrão retirada.
- Pagamentos aceitos: `pix`, `card`, `cash`, `card_delivery`, `card_pickup`, `transfer`, `other`; padrão Pix; labels traduzidos.
- Permitir troco para pagamento em dinheiro; não implementar gateway/cobrança online sem pedido.
- Para entrega exigir CEP, rua, número, bairro, cidade e UF. Complemento e referência opcionais. Para retirada não exigir endereço e frete zero.
- Máscaras de telefone e CEP no frontend; backend valida conteúdo relevante independentemente das máscaras.
- ViaCEP: limpar não dígitos, exigir 8 dígitos, HTTPS, timeouts de conexão/leitura de 3 segundos como referência.
- Retornar erro JSON compreensível para CEP inválido, não encontrado ou serviço indisponível; permitir preenchimento manual.
- Preencher rua/bairro/cidade/UF sem apagar dados úteis quando resposta vier incompleta; focar número após sucesso.
- Buscar área ativa pelo bairro normalizado: remover acentos, caixa e pontuação, compactar espaços. Referência aceita igualdade ou inclusão em qualquer direção e usa primeira área na ordem por nome. Replicar conscientemente essa regra inicial, não tratar como geocodificação exata.
- Área encontrada fornece taxa e prazo; sem área usar R$ 10 configuráveis e aviso claro. Área selecionada e taxa calculadas pelo backend, não pelo ID ou preço recebido do cliente.
- Promoção de frete grátis e cupom podem zerar frete conforme suas regras.
- Mínimo usa subtotal de itens comprados antes de frete e desconto, em ambas as modalidades.
- Total = subtotal + frete − desconto; nunca negativo.
- POST executa validação, persistência de cliente, criação do pedido/itens, aplicação de promoção/cupom e uso de cupom em transação.
- Bloquear carrinho vazio, produto ausente/inativo, variação inválida, quantidade inválida, estoque insuficiente, dados obrigatórios ausentes, endereço incompleto, pagamento/modalidade inválidos e mínimo não atingido.
- Revalidar pausa de loja e estoque no momento de finalizar.
- Pedido nasce `pending`, `stock_deducted = false`; checkout não baixa estoque. Disponibilidade pode mudar até confirmação administrativa.
- Erro de validação mantém formulário, status HTTP 422 e mensagem PT-BR sem duplicação. Logs podem conter diagnóstico técnico protegido; interface não deve expor stack trace, SQL ou dados internos.
- Pedido e efeitos transacionais não podem ficar parcialmente persistidos por falha de validação.

## 13. WhatsApp e identificação do pedido

- Após persistir pedido, gerar `https://wa.me/NUMERO?text=MENSAGEM_CODIFICADA` com URL encoding correto.
- Número oficial centralizado em configuração/ambiente documentado, nunca espalhado por templates.
- Formulário de checkout desabilita Turbo (`data-turbo="false"`) para redirecionamento externo; permitir host externo apenas no destino oficial gerado pelo servidor.
- Abrir WhatsApp não comprova envio pelo cliente, confirmação da loja ou pagamento. Status permanece pendente até ação administrativa.
- Número de pedido único; referência usa data `YYYYMMDD` e sufixo hexadecimal aleatório. Não usar número como única autorização de dados privados.
- Mensagem inclui abertura configurável, número do pedido, nome/telefone do cliente, itens/sabores, quantidades, preço unitário e total por item, brindes, subtotal, entrega, desconto, total, modalidade, pagamento, troco quando informado, cupom, endereço completo para entrega e observações.
- Manter formatação legível com quebras de linha e moeda brasileira.
- Disponibilizar reenvio pelo resumo autorizado e pelo admin, usando dados persistidos do pedido.
- Links de contato e produto podem montar mensagem introdutória; não devem ser tratados como pedidos já registrados.

## 14. Pedidos, status e estoque

- Status: `pending`, `confirmed`, `preparing`, `ready`, `out_for_delivery`, `delivered`, `cancelled`.
- Labels: aguardando confirmação, confirmado, em preparo, pronto, saiu para entrega, entregue, cancelado.
- Consumidores de estoque: confirmado, em preparo, pronto, saiu para entrega e entregue.
- Mudança para status consumidor baixa estoque somente se `stock_deducted` ainda for falso.
- Antes da baixa conferir produto/variação ativos e quantidade suficiente; produto sem controle dispensa baixa própria.
- Variação escolhida baixa saldo da variação, não soma baixa no produto pai.
- Agregar demanda quando vários itens usam mesmo alvo de estoque; não permitir saldo negativo nem confirmação parcial.
- Lock do pedido e locks dos alvos em ordem determinística, dentro de transação, para impedir concorrência inconsistente.
- Repetir confirmação/mudança entre status consumidores não debita novamente.
- Cancelar restaura saldo apenas se houve baixa; desmarcar indicador após restauração, impedindo duplicação.
- A referência aceita transições entre quaisquer status válidos; não inventar máquina de transições rígida. Voltar para `pending` não restaura estoque automaticamente; `cancelled` é a transição de restauração.
- Reativar pedido cancelado para status consumidor exige nova validação e nova baixa.
- Quantidade de movimento é inteira não zero; motivo e tipo obrigatórios; deve haver produto ou variação.
- Movimentos registram sinal negativo para venda e positivo para restauração; pedido opcional, motivo auditável.
- Ajuste manual: transação e lock; saldo final não negativo; registrar motivo/observação.
- Alterações de quantidade, estoque e valores no admin não podem ignorar consistência dos vínculos ou dupla baixa.
- Exclusão administrativa de pedido: confirmar intenção; em transação restaurar estoque debitado, remover receita automática, tratar movimentos e remover itens/pedido. Referência remove movimentos vinculados; para novo projeto preservar trilha de exclusão ou registrar auditoria antes da remoção.
- Não excluir pedidos/dados de produção por seed, deploy ou limpeza automática.

## 15. Financeiro comercial

- `FinancialEntry`: tipos `income`/`expense`; status `pending`/`paid`/`cancelled`.
- Descrição obrigatória; valor não negativo; data de vencimento, pagamento e observações.
- Cada pedido tem receita automática vinculada, sem duplicar em atualizações. Recomendado índice único no vínculo de receita automática para assegurar essa invariável.
- Receita automática acompanha total do pedido; descrição identifica pedido; vencimento usa data de criação.
- Pending/confirmed/preparing/ready/out_for_delivery → receita pendente; delivered → paga com data de pagamento; cancelled → cancelada sem data de pagamento.
- Lançamento automático exige pedido; não permitir editar/excluir manualmente por endpoints do financeiro.
- Manter sincronização consistente com transação do pedido; callback após commit da referência exige atenção para não deixar pedido salvo com falha financeira silenciosa.
- Receitas/despesas manuais independentes de pedido; `automatic: false` definido no servidor.
- Receita manual pode conter produtos/variações vendidos e quantidades para baixa de estoque.
- Produtos vendidos só podem ser vinculados a receita manual; despesas e receitas automáticas não aceitam esses itens manuais.
- Item financeiro exige produto, nome histórico, quantidade inteira positiva; variação deve pertencer ao produto.
- Ao criar receita manual com itens, baixar estoque; ao editar, aplicar apenas diferença por alvo; ao remover item/lançamento, restaurar saldo correspondente; tudo em transação e com lock.
- Ao converter receita manual em despesa, remover itens e restaurar estoque anterior.
- Na referência, baixa de venda manual depende de ser receita manual, não do status pago/pendente/cancelado. Não supor que mudar status restaura estoque; essa mudança de política exige definição explícita.
- Valor monetário de venda manual é informado pelo administrador, não recalculado automaticamente pela lista de quantidades, que não contém preço unitário. Preservar distinção.
- Mostrar receitas/despesas em seções separadas, com filtros comuns, totais sobre conjunto filtrado e paginação independente (15 por seção na referência).
- Totais dessa tela somam lançamentos filtrados, incluindo status selecionados; rotular claramente para não confundir com caixa recebido/pago.
- Despesas operacionais como ingredientes, embalagens, gelo, combustível e divulgação não se confundem com financeiro pessoal.

## 16. Financeiro pessoal

- Módulo separado do financeiro comercial, exclusivamente administrativo.
- Tipos: `income`, `expense`, `receivable`, `payable`; status `pending`/`paid`.
- Responsáveis técnicos da referência: `me`, `wife`, `shared`. Labels devem ser adaptados ao proprietário, sem presumir relação conjugal da Tia Nely; manter equivalência de responsável individual/segundo responsável/compartilhado.
- Descrição e vencimento obrigatórios; valor estritamente positivo; categoria livre e observações opcionais.
- Marcar pago preenche data atual se ausente; reabrir para pendente limpa data de pagamento.
- Atrasado = pendente com vencimento anterior a hoje.
- Listar com filtros, ordenação por vencimento crescente e criação decrescente, 20 por página inicialmente.
- Resumos filtrados: recebido = income/receivable pagos; pago = expense/payable pagos; a receber = receivable pendente; a pagar = expense/payable pendentes; quantidade atrasada.
- Não gerar `FinancialEntry` comercial, movimento de estoque ou alterar pedido por lançamento pessoal.

## 17. Dashboard e análise de vendas

- Dashboard: pedidos do dia, pendentes, em preparo, prontos, pedidos recentes, produtos ativos, baixo estoque/esgotados e resumo financeiro mensal.
- Volume de pedidos do dia soma totais de pedidos criados hoje não cancelados; não equivale a dinheiro recebido hoje.
- Receita/despesa mensal de caixa usa lançamentos pagos pela data de pagamento; saldo = receita − despesa.
- Referência mostra até oito pedidos recentes e até oito alertas combinados de estoque, priorizando esgotados.
- Análise de vendas usa receitas financeiras e filtro por vencimento, não apenas data de criação do pedido.
- Período padrão: início do mês até hoje. Status padrão pago; aceitar pago, pendente ou todos, excluindo cancelados sempre.
- Combinar quantidades de itens de pedidos com receita automática e itens de vendas financeiras manuais.
- Agrupar por produto, agregando variações; ordenar quantidade decrescente; exibir total de unidades, receita filtrada e quantidade de lançamentos.
- Brindes definidos contam em unidades distribuídas no comportamento de referência; brindes sem produto não entram no ranking. Explicar essa interpretação na interface, evitando apresentá-la como quantidade exclusivamente paga.
- Receita de lançamento manual sem itens participa do total financeiro, mas não inventa quantidades no ranking.
- Filtros e totais devem ser coerentes e acesso sempre autenticado.

## 18. Administração e interface

- CRUD de categorias, produtos, imagens, variações, áreas, descontos e promoções; gestão de clientes, pedidos, estoque e configurações.
- Produtos: ativar/desativar, destaque, preço, estoque, imagem principal/galeria, ordem e categoria.
- Clientes: dados e histórico; não apagar quando houver pedidos vinculados.
- Pedidos: filtros por cliente, telefone, número, status/período; resumo/visualização para impressão; reenvio WhatsApp; status e cancelamento; definição de brinde.
- Configurações: nome, WhatsApp, Pix, endereço, horário, mensagem de pedido, mínimo, frete, retirada, redes, pausa de pedidos.
- Admin objetivo, denso e escaneável em celular/desktop; tabelas responsivas, badges de status, ações claras, mensagens de validação próximas ao formulário.
- Confirmação explícita para ações destrutivas, sem links GET que alterem dados.
- Filtros Ransack e paginação Pagy, sem consultas N+1 evitáveis nas listagens.
- Menu contempla todos os módulos, sem entradas para integração excluída.

## 19. Design, acessibilidade e JavaScript

- Identidade própria da nova marca, visual leve, cores alegres, fotos apetitosas, tipografia de título marcante e corpo legível.
- Não há design system detalhado no arquivo de referência: ele contém apenas placeholder. Criar e documentar um sistema coerente em `.ai-framework/DESIGN.md`, sem alegar que paleta específica era requisito original.
- Usar ERB + Tailwind + classes compartilhadas de `style.css`; não criar estilos desconectados por página.
- Material Symbols quando houver carregamento desses ícones; evitar mistura arbitrária de bibliotecas.
- Layout mobile-first com CTAs legíveis e textos que caibam em telas pequenas; foto, nome, preço, disponibilidade e compra em destaque.
- Home apresenta sabores, diferenciais, como pedir, regiões, promoções e contato; institucionais “Quem somos” e “Contato”.
- Exibir mínimo, prazo, frete, retirada e pausa com clareza, sem esconder condições.
- Acessibilidade: labels associados, foco visível, navegação por teclado, texto alternativo, contraste e feedback compreensível. Drawer deve poder abrir/fechar sem prender navegação.
- Tema escuro não é obrigatório; só manter se houver implementação coerente.
- Stimulus para drawer, abertura do carrinho, quantidade, checkout, carrossel/faixa de entregas, campos de itens financeiros e visibilidade de senha quando necessário.
- Funcionar com navegação Turbo e carregamento inicial, sem duplicar listeners. Preferir ciclo de vida Stimulus; scripts inline pequenos só se coerentes com layout.
- Cálculo frontend é prévia; backend sempre autoritativo para preços, frete, desconto e estoque.
- Checkout alterna retirada/entrega e campos, calcula prévia, busca CEP e formata telefone.
- Prevenir múltiplos envios enquanto requisição está em andamento; não afirmar garantia de idempotência se não implementada.

## 20. SEO e conteúdo público

- Helpers de título, descrição, moeda, imagem e marca centralizados em `ApplicationHelper`.
- Títulos por página com nome da loja; descrições naturais, locais e sem excesso de palavras-chave.
- Home, categoria e produto com canonical, Open Graph, Twitter Card e JSON-LD pertinente.
- Compartilhamento de produto com imagem, preço, descrição e disponibilidade coerentes.
- Não remover `content_for` de SEO sem substituição equivalente.
- Favicon, apple-touch-icon, logo e placeholders da nova marca.
- Não inventar endereço/cidade/avaliações/dados estruturados comerciais ausentes.
- Página privada de pedido/admin não deve expor dados para indexação pública.

## 21. Segurança, persistência e operação

- Strong params em controllers; ignorar campos de controle enviados pelo consumidor, como status, baixa, preços, descontos, total e flag automático.
- Não commitar tokens, senhas reais, dumps, dados pessoais, credenciais descriptografadas ou logs.
- Não imprimir senha de seed no console. Não reproduzir credenciais ou dados pessoais fixos encontrados na referência.
- Admin inicial por `SEED_ADMIN_EMAIL` e `SEED_ADMIN_PASSWORD`; ambiente produtivo exige valores válidos. Não redefinir senha existente em todo deploy sem ação explícita.
- Seed idempotente, não destrutivo; exemplos somente quando solicitados ou em desenvolvimento. Não sobrescrever configurações comerciais existentes ao reaplicar seed.
- `STORE_WHATSAPP`, `APP_HOST`, `DEVISE_MAILER_SENDER`, `SECRET_KEY_BASE` e, quando necessário, `RAILS_MASTER_KEY` documentados. Não trocar chave de sessão para contornar boot de tarefa.
- Estrutura de banco somente via migration; não editar `db/schema.rb` manualmente. Migrations reversíveis quando possível, com cuidado aos dados existentes.
- Bancos separados por ambiente: desenvolvimento, teste e produção. Nunca apontar testes para produção.
- SQLite e uploads persistentes em volume/diretório preservado entre deploys; backup consistente antes de migração de produção e procedimento de restauração documentado.
- Não executar `db:drop`, `db:reset` ou `db:schema:load` contra banco de produção existente como correção de migration.
- Arquivo de migration existir não significa estar aplicado: verificar `db:migrate:status` no ambiente e banco usados pelo serviço.
- Executar tarefas de produção com usuário/permissões e variáveis do serviço Rails; um shell sem `SECRET_KEY_BASE` pode falhar antes de consultar o banco.
- Procedimento: backup, configuração do ambiente, migration/prepare adequado, conferência de status, reinício do processo Rails e teste de compra. Não reiniciar Nginx apenas por mudança de schema; reinício depende do servidor de aplicação realmente usado.
- VPS: documentar Puma/systemd ou Passenger conforme instalação real, sem inventar nome de serviço. Passenger padrão pode usar `tmp/restart.txt`; Puma usa o serviço correspondente.
- Docker: `.ruby-version` e imagem consistentes; entrypoint prepara banco antes de iniciar servidor quando configurado para isso.
- Render: `render.yaml`, build `bin/render-build.sh`, pós-deploy `bin/render-postdeploy.sh`, healthcheck `/health`, segredos por ambiente e armazenamento persistente.
- `docs/comandos-producao.md` deve diferenciar instalação nova, deploy incremental, migrations, reinício, backup e diagnóstico. Não rodar seed com alterações comerciais automaticamente sem política definida.
- Nunca alterar credenciais criptografadas, autenticação, stack ou dados de produção por conveniência sem pedido explícito.

## 22. Critérios de aceite e testes

Usar Minitest e testes de integração Rails; testes de navegador quando necessários. Não basta boot ou diff limpo para declarar checkout validado.

- Boot Rails, migrations em banco novo e atualização de schema, rotas e assets funcionais.
- Login/logout e bloqueio de todos os endpoints administrativos para visitante.
- Catálogo ativo/inativo, esgotado, variações, preços herdados, imagens válidas/inválidas, busca e categorias.
- Carrinho: soma, alteração, remoção, limite 99, saldo insuficiente, variação inválida, contador com brinde, Turbo e HTML.
- Loja pausada ao adicionar, abrir checkout e após formulário já aberto.
- Mínimo R$ 20 e mínimo configurado maior, tanto retirada quanto entrega.
- Endereço obrigatório somente na entrega; CEP válido/inválido/indisponível; cálculo de área e fallback.
- Cupons: caixa/espaços, inválido, inativo, futuro, expirado, limite, mínimo, percentual, fixo, frete grátis, uso concorrente e rollback.
- Promoção por quantidade exata, desaparecimento após mudar quantidade, brinde zero, frete grátis e combinação com cupom.
- Checkout persiste cliente/pedido/itens/financeiro coerentes, limpa sessão no sucesso, preserva no erro e redireciona para URL WhatsApp codificada corretamente.
- Formulário final com Turbo desabilitado, mensagem completa, brinde e reenvio autorizado.
- Estoque: confirmação repetida, duas confirmações disputando último item, variação, produto inativo, restauração única, brinde definido antes/depois da baixa e exclusão compensada.
- Financeiro automático acompanha pedido; edição/exclusão manual bloqueadas; venda manual aplica diferenças e restaura saldo.
- Financeiro pessoal totalmente separado, pagamento/reabertura e vencidos corretos.
- Dashboard e ranking com filtros, receitas manuais/automáticas, brindes e cancelados tratados conforme regra.
- Admin filtros/paginação/formulários e mobile/desktop; mensagens de erro sem duplicação ou detalhes internos.
- Privacidade de pedidos: sessão/token indevido não acessa informações de terceiros.
- Deploy de validação confirma banco migrado e um checkout completo; abertura de WhatsApp deve ser verificada manualmente sem enviar mensagens reais sem autorização.

Comandos de desenvolvimento, conforme ambiente instalado:

```bash
bundle install
bundle exec rails db:prepare
bundle exec rails runner 'puts "rails ok"'
bundle exec rails routes
bundle exec rails test
```

Registrar testes executados, resultados e verificações não realizadas. Se faltar Ruby, Bundler, navegador ou serviço externo, declarar o bloqueio; não afirmar aprovação de produção sem evidência.

## 23. Instruções de execução para o Codex

- Ler este documento e `AGENTS.md` antes de implementar; registrar decisões em documentação do projeto.
- Criar fundação primeiro conforme prompt inicial; implementar módulos restantes na ordem das dependências.
- Manter checklist em `docs/implementacao.md` relacionando cada seção com código/testes correspondentes e pendências.
- Resolver diferenças entre código existente e especificação conscientemente, sem transformar bug acidental da referência em requisito.
- Preservar alterações do usuário e evitar refatoração ampla junto de ajustes pequenos.
- Não eliminar módulos por considerá-los secundários: financeiro pessoal, análise de vendas, cupons, promoções e brindes fazem parte do escopo.
- Não ampliar para gateway, marketplace, cadastro público de administradores, automação de envio WhatsApp ou integrações de terceiros além das previstas.
- Nunca deixar produto inativo comprável, estoque negativo, pedido sem cliente/item válido, receita automática editável livremente ou atualização de schema incompleta.
- Entregar implementação e evidências de teste, não apenas proposta. Deploy e comunicação externa requerem solicitação própria.
