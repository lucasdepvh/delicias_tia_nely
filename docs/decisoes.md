# Decisões da fundação

- Escopo: fundação solicitada no primeiro prompt. O texto de continuação descreve uma etapa posterior; os módulos seguem listados em `implementacao.md`.
- O único arquivo inicial era a especificação. Nenhum arquivo da aplicação de origem foi lido ou copiado.
- Ruby 3.4.2 exato e Rails `~> 8.1.3` com versão resolvida em lockfile. Sem Node, SPA ou bundler JavaScript.
- SQLite separado por ambiente em `STORAGE_PATH` (padrão `storage`); anexos locais em `uploads/<ambiente>`. Diretório persistente obrigatório em produção.
- StoreSetting usa chave singleton e restrições no banco. A primeira leitura pode usar defaults não persistidos; o seed cria o registro de forma idempotente. Pedidos permanecem desabilitados nesta etapa.
- Recuperação Devise fica sob `/senha` somente quando SMTP e remetente estiverem configurados. Não há registro público. Seeds não imprimem nem substituem senhas existentes.
- Active Storage instalado, mas suas rotas genéricas ficam desativadas até existir o catálogo com política de upload/acesso. A configuração de tipos e tamanho serve de contrato para o próximo módulo; os endpoints de upload não estão disponíveis publicamente nesta fundação. `image_processing` não é dependência da fundação: versões antigas de libvips bloqueiam o boot seguro do Rails. Ela será adicionada junto do catálogo somente em ambiente com libvips 8.13+ e ruby-vips 2.2.1+ (ou com processador de imagem explicitamente validado).
- Rails 8.1.4 também tenta ativar `ruby-vips` quando ela foi instalada globalmente fora do Bundle. Em ambiente com libvips anterior a 8.13, remover a gem global residual com `gem uninstall ruby-vips -aIx` é necessário para o boot. A proteção de segurança do Active Storage não deve ser desativada.
- Tailwind via CDN conforme requisito; CSS próprio sustenta o layout básico sem rede. Fontes do sistema, marca tipográfica e SVG próprios. Nenhuma identidade comercial reaproveitada.
- Healthchecks usam PublicController, validam banco e boot, retornam erro genérico em caso de falha. Admin e autenticação recebem noindex e cache privado.
- Sem Solid Queue/Cache/Cable. Active Job permanece com adaptador inline; nenhum worker é exigido nesta etapa. Cache em memória não é dado persistente de negócio.
- Render usa migrations no entrypoint com disco montado, não no build nem em job separado sem acesso ao volume SQLite.
