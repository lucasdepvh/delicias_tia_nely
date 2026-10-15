# Orientações para o Codex

Antes de implementar qualquer mudança, leia integralmente `delicias-da-tia-nely-regras.md` na raiz. Esse arquivo é a especificação funcional e técnica obrigatória; aplique sua seção de precedência.

- Preserve conteúdo e alterações existentes. Não copie código, credenciais, dados pessoais ou identidade de outra loja.
- Mantenha Ruby 3.4.2, Rails 8.1, SQLite e o monólito ERB/Propshaft/Importmap/Turbo/Stimulus. Não adicione Node, bundlers JS ou SPA.
- Autenticação por padrão em ApplicationController; acesso público explícito via PublicController; administração via Admin::BaseController.
- Não implemente iFood ou artefatos dessa integração. Não adicione workers sem necessidade funcional.
- Não invente dados comerciais. Pedidos ficam desabilitados até configuração válida e implementação verificada do checkout.
- Mantenha `docs/implementacao.md` atualizado com requisitos, decisões, evidências e pendências. Não apresente módulos pendentes como operacionais.
- Use migrations, Minitest, mensagens PT-BR e valores monetários decimais. Não altere schema manualmente.
- Não publique, modifique produção ou envie mensagens externas sem solicitação específica.
