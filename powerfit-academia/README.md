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

## Mapa

O mapa mostra a região central de São Paulo com imagens do OpenStreetMap, sem marcar a academia fictícia.
