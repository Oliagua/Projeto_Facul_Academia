# Andamento do projeto

## Front-end entregue nesta versão

O site institucional tem todas as seções planejadas e a página de login. Inclui menu responsivo, detalhes das modalidades, seleção de planos, validação dos campos, mapa e efeitos nos cards.

A escolha de um plano preenche a mensagem de contato. O Servlet valida o formulário, mas não envia e-mail nem salva dados. O login exibe um aviso e ainda não autentica o aluno.

## Pendências do trabalho integrador

| Parte | O que falta |
| --- | --- |
| Web administrativo | Interface de alunos pronta com dados em memória; falta ligar cadastro, consulta, edição e exclusão ao servidor |
| Banco | Modelagem com mais tabelas e relacionamentos; o SQL atual é apenas inicial |
| Integração Web | Ligar os formulários administrativos ao DAO e testar a persistência |
| Mobile | Desenvolver o aplicativo Flutter com uma função própria no negócio |
| Integração geral | Definir e implementar a comunicação entre os módulos conforme o conteúdo das aulas |
| Documentação | Descrição do projeto, requisitos e modelagem/estrutura técnica |
| Apresentação | Demonstrar CRUD completo e explicar a participação de cada módulo |

A divisão dessas tarefas deve ser combinada pelo grupo. A responsabilidade informada para esta etapa é o front-end; os responsáveis pelas demais partes ainda não estão registrados aqui.

## Testes realizados

- Compilação com `mvn package` e execução no Tomcat 9.
- Verificação de layout em larguras de 320 e 390 pixels, sem rolagem horizontal.
- Teste do menu, detalhe de modalidade, seleção do plano e formulário de contato.
- Conferência do mapa e das opções da tela de login.
