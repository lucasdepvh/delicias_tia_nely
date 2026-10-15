# Identidade inicial — Delícias da Tia Nely

Decisão desta implementação, não uma paleta prescrita pela referência: creme (#fffaf2), amora (#722d46), verde profundo (#28594c) e rosa suave (#f5d9df). Texto escuro (#30262a), títulos em Georgia e corpo com fontes do sistema, sem serviço externo de fontes.

Marca tipográfica própria com monograma N; nenhuma imagem da loja de origem. Fundos simples, bordas arredondadas e espaços generosos. Fotos reais de produtos serão cadastradas no módulo de catálogo; não simular fotos de produtos disponíveis.

Layout mobile-first com largura máxima de 1120px, navegação que quebra linhas e controles com foco visível. CSS compartilhado em `app/assets/stylesheets/style.css`; Tailwind via CDN conforme a especificação. O CSS próprio mantém a base legível sem o CDN. O CDN demanda internet no navegador e deverá ser reavaliado antes de uma política CSP estrita, preservando a stack autorizada.

Conteúdo desta etapa comunica preparação da vitrine e pedidos indisponíveis. Admin exibe módulos futuros como texto com estado pendente, sem links que sugiram operações prontas. Não há números fictícios de vendas, endereços ou avaliações.

## Atualização da home — 04/10/2026

A página inicial passou a adotar a linguagem visual do layout de cardápio móvel fornecido pelo proprietário: superfícies em creme, terracota como cor de ação, verde como cor de disponibilidade, busca ampla, chips horizontais e cards arredondados. A adaptação permanece própria da Delícias da Tia Nely e usa o `brand-mark.svg` local.

O catálogo ainda não existe no domínio. Portanto, busca, categorias, carrinho, preços, imagens de produtos, contagem de itens e contato comercial não foram simulados. A composição usa um estado vazio claro e a mensagem de pausa configurada, sem indicar que pedidos sejam possíveis.
