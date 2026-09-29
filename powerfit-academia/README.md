# PowerFit — módulo Web

Site institucional feito com Java, JSP, Servlets, HTML, CSS e JavaScript. Usa Maven e Tomcat 9. A estrutura JDBC/MySQL está preparada para uma próxima etapa.

## Executar

Instale JDK 11 ou superior, Maven 3.8 ou superior e Tomcat 9. Configure `JAVA_HOME` e deixe Java e Maven disponíveis no `PATH`.

Na pasta deste arquivo, execute:

```bash
mvn clean package
```

Copie `target/powerfit-academia.war` para `webapps` do Tomcat. Inicie o servidor com `bin/startup.bat` no Windows ou `bin/startup.sh` no Linux/macOS.

- Site: `http://localhost:8080/powerfit-academia/`
- Login: `http://localhost:8080/powerfit-academia/login.jsp`

Os arquivos JSP precisam do Tomcat; não devem ser abertos diretamente como arquivos HTML. O projeto usa `javax.servlet`, por isso a configuração atual é para Tomcat 9, não Tomcat 10 ou superior.

## Arquivos principais

| Arquivo | Função |
| --- | --- |
| `src/main/webapp/index.jsp` | Seções do site e formulário de contato |
| `src/main/webapp/login.jsp` | Tela de login |
| `src/main/webapp/css/` | Layout, imagens e efeitos dos cards |
| `src/main/webapp/js/script.js` | Menu e validação dos campos |
| `src/main/webapp/js/melhorias.js` | Modalidades, planos e opções do login |
| `src/main/webapp/js/mapa.js` | Mapa com zoom e arraste |
| `src/main/webapp/imagens/` | Imagens utilizadas nas páginas |
| `src/main/java/servlet/ContatoServlet.java` | Validação do contato no servidor |
| `src/main/java/model/Aluno.java` | Dados do aluno |
| `src/main/java/dao/Conexao.java` | Conexão JDBC |
| `src/main/java/dao/AlunoDAO.java` | Cadastro e busca de aluno por e-mail |
| `banco-dados.sql` | Banco e tabela inicial de alunos |

## Formulários

O contato faz um POST para `/contato`. O Servlet valida nome, e-mail, telefone e mensagem e redireciona para a página com o resultado. Não há envio de e-mail nem gravação dos dados.

O login permite preencher os campos e mostrar a senha, mas ainda não autentica. A recuperação de senha também depende da integração futura.

## Preparar o MySQL

1. Inicie o MySQL 8 e execute `banco-dados.sql` no Workbench ou no terminal.
2. Ajuste `URL`, `USUARIO` e `SENHA` em `Conexao.java` com os dados do ambiente. A URL inicial é para o banco `powerfit` em `localhost:3306`.
3. Gere novamente o WAR após alterar essas configurações.

O driver JDBC já está no `pom.xml`. O DAO usa `PreparedStatement` e fecha os recursos com `try-with-resources`, mas não é chamado pelas páginas. O site pode ser executado sem MySQL nesta etapa.

A tabela `alunos` é somente o ponto de partida. O modelo final precisa de tabelas relacionadas, conforme o enunciado. Ao implementar autenticação, armazenar hashes de senha e fazer a verificação adequada; não publicar credenciais reais.

## Imagens e mapa

Para substituir uma foto, altere o arquivo em `imagens/` e sua referência na página. As imagens atuais foram geradas por IA; pessoas, CREFs, preços e contatos são fictícios.

O mapa mostra a região central de São Paulo com imagens do OpenStreetMap, sem marcar a academia fictícia. Precisa de internet e mantém os créditos do provedor. O link abaixo abre a região no Google Maps. Os links sociais levam às plataformas e podem ser substituídos pelos perfis da academia.

## Para a apresentação

Mostrar a navegação no computador e em tela pequena, abrir uma modalidade e escolher um plano. No contato, demonstrar um telefone inválido e depois o retorno do Servlet com dados válidos. Explicar a diferença entre a interface pronta e a integração com o banco, que ainda falta.

O [README principal](../README.md) e o [andamento do projeto](../docs/estado-do-projeto.md) separam esta entrega de front-end das próximas etapas do grupo.

## Área administrativa

Abra `http://localhost:8080/powerfit-academia/admin.jsp` ou use o link de prévia na tela de login. A lista tem dados fictícios, busca, filtro por plano e formulários para cadastro, edição e exclusão. As alterações ficam em memória até recarregar a página. Consulte o [guia de integração](../docs/integracao-admin.md) para conectar as telas ao back-end. Os estilos e interações ficam em `css/admin.css` e `js/admin.js`.
