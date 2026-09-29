# Estado do projeto e próximos passos

Este registro compara o módulo enviado com o enunciado preservado no README da raiz. Não substitui os três documentos exigidos pelo professor.

| Requisito | Estado desta versão |
| --- | --- |
| Java, JSP e Servlets | Implementados no site institucional e no contato |
| Orientação a objetos | Modelo Aluno, DAO, conexão e Servlet separados |
| Interface e navegação | Implementadas, com validação e layout responsivo |
| Gestão administrativa Web | Pendente |
| CRUD utilizando efetivamente o banco | Pendente; DAO só possui cadastro e busca, ainda sem integração |
| Banco relacional com tabelas relacionadas | Pendente; script atual contém apenas alunos |
| Aplicativo Flutter com função própria | Pendente |
| Integração Web, Mobile e banco | Pendente |
| Documento descritivo, requisitos e modelagem | Pendentes; definir integrantes e escopo com o grupo |
| Demonstração completa de incluir, consultar, alterar e excluir | Pendente |

## Sequência sugerida para o grupo

1. Definir os integrantes, o problema de gestão e o papel de cada módulo. Uma opção é administrar alunos, planos e professores na Web e consultar treinos/registrar atividades no Flutter, conforme o exemplo do enunciado.
2. Produzir os três documentos exigidos, incluindo requisitos numerados, modelo relacional, responsabilidades das classes e fluxo do aplicativo.
3. Modelar tabelas, chaves estrangeiras e relacionamentos coerentes antes de integrar a aplicação. O script inicial não deve ser tratado como modelo final.
4. Implementar e testar CRUD completo no módulo administrativo com JDBC e PreparedStatement.
5. Construir o módulo Flutter e combinar com o professor a forma de integração usando apenas o conteúdo trabalhado em aula. Não presumir autorização para frameworks ou API REST.
6. Testar a persistência real e preparar a demonstração de cadastrar, consultar, alterar, consultar novamente e excluir.

## Validação da versão enviada

- `mvn package` executado com sucesso, compilação para Java 11 e pacote WAR para Tomcat 9.
- JavaScript do mapa verificado com `node --check`.
- Interface verificada no navegador em larguras de 320 e 390 pixels, sem transbordamento horizontal.
- Menu, detalhe de modalidade, seleção do plano, validação do contato no navegador e no Servlet, mapa e login demonstrativo conferidos.
- Simulação de largura não equivale a teste em dispositivo físico.
- Integração com MySQL e Flutter não testada, pois ainda não existe nesta versão.

## Organização do repositório

- `powerfit-academia/`: módulo Web Maven, incluindo o SQL inicial e seu README.
- `docs/`: acompanhamento do projeto e espaço para documentação do grupo.
- `README.md`: acesso ao módulo e enunciado original preservado.
- `.gitignore`: exclusão de arquivos gerados, configurações locais e credenciais.

O envio corresponde ao trabalho realizado até agora, em um commit de importação. Não representa um histórico retroativo de desenvolvimento nem atribui tarefas a integrantes que não foram informados.
