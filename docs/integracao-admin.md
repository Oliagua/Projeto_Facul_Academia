# Integração da área administrativa

## Telas entregues

`admin.jsp` contém a lista de alunos, busca, filtro por plano, formulário de cadastro/edição e confirmação de exclusão. O acesso está na tela de login como uma prévia, sem autenticação.

`js/admin.js` usa uma lista de exemplos em memória. Os botões alteram essa lista apenas para testar a interface. Recarregar a página restaura os exemplos. Não há conexão com MySQL, armazenamento local nem envio desses dados para o servidor.

## Campos

| Campo | Validação da interface |
| --- | --- |
| id | Identificador do registro; não é digitado pelo usuário |
| nome | Obrigatório, entre 2 e 120 caracteres após remover espaços das extremidades |
| email | Obrigatório, formato de e-mail, até 120 caracteres e sem duplicidade na lista |
| telefone | Obrigatório, DDD e 10 ou 11 dígitos |
| plano | Mensal, Trimestral, Semestral ou Anual |

O modelo `Aluno` e a tabela inicial ainda não possuem o campo de plano. Na modelagem final, combinar com o grupo o relacionamento entre aluno, plano e matrícula. Os nomes de planos desta prévia não substituem uma chave estrangeira.

## Próxima etapa do back-end

1. Proteger a área administrativa com autenticação, sessão e autorização no servidor. O link de prévia não é um controle de acesso.
2. Implementar listagem, atualização e exclusão no DAO, além do cadastro já preparado. Validar novamente os campos no servidor.
3. Carregar os dados por Servlet e renderizar a lista em JSP. Trocar os exemplos e alterações em memória por submissões de formulário ao Servlet.
4. Usar POST nas operações que alteram dados, validar o ID recebido, proteger contra CSRF e escapar os textos exibidos nas JSPs.
5. Tratar e-mail duplicado também no MySQL, falhas de conexão e registros que não existem mais.
6. Confirmar a exclusão e respeitar as relações com matrícula, treinos e demais entidades do modelo final.

A interface não pede senha do aluno. Definir o fluxo de criação de acesso separadamente e nunca mostrar senhas ou hashes na listagem.

Os caminhos de Servlet e a estrutura final do banco devem ser definidos pelo responsável pelo back-end. Esta entrega cobre a interface, não o CRUD persistido exigido na apresentação final.

## Testes da interface administrativa

Conferidos no navegador: busca por nome sem acento, estado vazio, filtro de plano, cadastro, e-mail duplicado, telefone inválido, edição, cancelamento e confirmação de exclusão. Totais e lista acompanharam as alterações. Ao recarregar, os quatro exemplos iniciais foram restaurados. Layout e formulário verificados em larguras de 390 e 320 pixels, sem transbordamento horizontal. Compilação Maven e sintaxe de `admin.js` verificadas.
