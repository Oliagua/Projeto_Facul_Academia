# PowerFit — módulo Web

Site institucional feito com Java, JSP, Servlets, HTML, CSS e JavaScript. Usa Maven, Tomcat 9 e MySQL 8. O cadastro e o login de aluno já usam o banco de dados.

## Executar

Instale JDK 11 ou superior, Maven 3.8 ou superior, Tomcat 9 e MySQL 8. Configure `JAVA_HOME` e deixe Java e Maven disponíveis no `PATH`.

1. Prepare o banco, como explicado em "Preparar o MySQL" mais abaixo.
2. Na pasta deste arquivo, execute:

```bash
mvn clean package
```

3. Copie `target/powerfit-academia.war` para `webapps` do Tomcat. Inicie o servidor com `bin/startup.bat` no Windows ou `bin/startup.sh` no Linux/macOS.

- Site: `http://localhost:8080/powerfit-academia/`
- Cadastro: `http://localhost:8080/powerfit-academia/cadastro.jsp`
- Login: `http://localhost:8080/powerfit-academia/login.jsp`

Os arquivos JSP precisam do Tomcat; não devem ser abertos diretamente como arquivos HTML. O projeto usa `javax.servlet`, por isso a configuração padrão é o Tomcat 9. No Tomcat 10 ou superior o WAR precisa ser convertido; veja "Usar Tomcat 10 ou 11" abaixo.

## Preparar o MySQL

1. Inicie o MySQL 8 e execute `banco-cadastro.sql`. O script cria o banco `powerfit` e as tabelas `plano` (com os quatro planos) e `usuario`, e pode ser executado mais de uma vez sem apagar dados. No Workbench, use File > Open SQL Script e clique no raio; o comando `source` só funciona no cliente de linha de comando.
2. Confira `URL`, `USUARIO` e `SENHA` em `Conexao.java`. A URL inicial é para o banco `powerfit` em `localhost:3306`, com usuário `root` e senha vazia. Ajuste conforme o MySQL do seu ambiente. Se o root tiver senha e o log mostrar "Public Key Retrieval is not allowed", acrescente `&allowPublicKeyRetrieval=true` no fim da `URL`.
3. Gere novamente o WAR após alterar essas configurações.

O arquivo `banco-dados.sql` é a estrutura inicial, com a tabela `alunos`. O cadastro e o login não usam essa tabela.

## Usar Tomcat 10 ou 11

O Tomcat 10 e os seguintes usam `jakarta.servlet`, e este projeto usa `javax.servlet`. Para rodar nele sem mudar o código, use a pasta de conversão do próprio Tomcat:

1. Pare o Tomcat e apague `powerfit-academia.war` e a pasta `powerfit-academia` de `webapps`, se existirem.
2. Crie a pasta `webapps-javaee` dentro da pasta do Tomcat, ao lado de `webapps`, e copie o WAR para ela.
3. Inicie o Tomcat. Ele converte o aplicativo e cria `powerfit-academia.war` e a pasta `powerfit-academia` em `webapps`.

Testado no Tomcat 11.0.27, com cadastro e login. O Tomcat 11 exige Java 17 ou superior.

## Cadastro e login

- Crie os usuários pela página `cadastro.jsp`. Não insira usuários direto no banco: a coluna `senha` precisa estar no formato `salt:hash`, e só o cadastro pelo site grava assim. Um usuário inserido na mão não consegue entrar.
- O hash é SHA-256 de `salt + senha`, com um salt aleatório por usuário. É o mesmo formato do aplicativo Flutter, para facilitar a integração entre os módulos. Hoje o aplicativo ainda usa o banco do próprio aparelho, então as contas não são compartilhadas.
- O login confere e-mail e senha no banco, guarda o usuário na sessão e leva para `index.jsp`. E-mail inexistente e senha errada mostram a mesma mensagem.
- Ainda não há botão de sair nem recuperação de senha. A área administrativa (`admin.jsp`) continua como prévia, com dados em memória e sem proteção de acesso.

## Arquivos principais

| Arquivo | Função |
| --- | --- |
| `src/main/webapp/index.jsp` | Seções do site e formulário de contato |
| `src/main/webapp/cadastro.jsp` | Tela de cadastro do aluno |
| `src/main/webapp/login.jsp` | Tela de login |
| `src/main/webapp/css/` | Layout, imagens, efeitos dos cards e tela de cadastro |
| `src/main/webapp/js/script.js` | Menu e validação dos campos |
| `src/main/webapp/js/cadastro.js` | Validação e mensagens do cadastro |
| `src/main/webapp/js/melhorias.js` | Modalidades, planos e opções do login |
| `src/main/webapp/js/mapa.js` | Mapa com zoom e arraste |
| `src/main/webapp/imagens/` | Imagens utilizadas nas páginas |
| `src/main/java/servlet/ContatoServlet.java` | Validação do contato no servidor |
| `src/main/java/servlet/CadastroServlet.java` | Validação e gravação do cadastro |
| `src/main/java/servlet/LoginServlet.java` | Confere e-mail e senha e abre a sessão |
| `src/main/java/model/Usuario.java` | Dados do usuário que fez login |
| `src/main/java/model/Aluno.java` | Dados do aluno (estrutura inicial, sem uso nas páginas) |
| `src/main/java/dao/Conexao.java` | Conexão JDBC |
| `src/main/java/dao/UsuarioDAO.java` | Cadastro e autenticação de usuário |
| `src/main/java/dao/AlunoDAO.java` | Estrutura inicial para a tabela alunos (sem uso nas páginas) |
| `src/main/java/util/SenhaUtil.java` | Gera e confere a senha no formato `salt:hash` |
| `banco-cadastro.sql` | Banco `powerfit` com as tabelas `plano` e `usuario` |
| `banco-dados.sql` | Estrutura inicial com a tabela `alunos` |

## Formulários

O contato faz um POST para `/contato`. O Servlet valida nome, e-mail, telefone e mensagem e redireciona para a página com o resultado. Não há envio de e-mail nem gravação dos dados.

O cadastro faz um POST para `/cadastro` e o login faz um POST para `/login`. Os dois validam os campos no navegador e de novo no servidor.

## Mapa

O mapa mostra a região central de São Paulo com imagens do OpenStreetMap, sem marcar a academia fictícia.
