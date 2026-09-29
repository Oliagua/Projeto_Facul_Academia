# PowerFit Academia

Site institucional de uma academia fictícia, com Java, JSP, Servlets, HTML, CSS, JavaScript básico, JDBC e MySQL. Empacotamento Maven em WAR para Apache Tomcat 9. Sem frameworks de interface, Spring Boot ou API REST.

## O que está pronto

- Home com banner, menu responsivo e chamadas para contato e planos.
- Sobre, missão, visão e quatro diferenciais.
- Seis modalidades com imagens e detalhes em janela acessível por teclado.
- Quatro planos com preço mensal, duração, total e destaque do anual.
- Quatro professores com especialidades e CREFs fictícios.
- Galeria da estrutura, três depoimentos e mapa interativo do Centro de São Paulo com imagens do OpenStreetMap.
- Contato com validação HTML, JavaScript e Servlet.
- Login demonstrativo, opção de mostrar senha e aviso de recuperação futura.
- Rodapé com links rápidos e links demonstrativos para redes sociais.

Escolher um plano preenche a mensagem de contato. O formulário envia um POST para `ContatoServlet`, que valida os campos e redireciona para a página com o resultado. **Nenhuma mensagem é enviada ou armazenada.** O login não autentica nem consulta o banco. O site funciona sem MySQL instalado.

## Organização

```text
src/main/java/
  dao/Conexao.java           constantes e conexão JDBC
  dao/AlunoDAO.java          cadastro e busca por e-mail com PreparedStatement
  model/Aluno.java           dados do aluno e getters/setters
  servlet/ContatoServlet.java validação demonstrativa do contato
src/main/webapp/
  index.jsp                 site institucional
  login.jsp                 tela de login
  css/style.css             layout e cores
  css/fotos.css             recortes e proporções das imagens
  css/acabamento.css        acabamento visual e acessibilidade
  js/script.js              menu e validação
  js/melhorias.js            modalidades, planos e opções do login
  imagens/                  imagens locais
banco-dados.sql
pom.xml
```

## Executar com Maven e Apache Tomcat

Requisitos: JDK 11 ou superior, Maven 3.8 ou superior e Apache Tomcat **9**, que utiliza `javax.servlet`. Este projeto não está configurado para Tomcat 10 ou superior, que utiliza `jakarta.servlet`.

1. Configure `JAVA_HOME` para o JDK e adicione Java e Maven ao `PATH`.
2. Na pasta que contém `pom.xml`, execute:

   ```bash
   mvn clean package
   ```

3. Copie `target/powerfit-academia.war` para a pasta `webapps` do Tomcat.
4. Inicie o servidor com `bin/startup.bat` no Windows ou `bin/startup.sh` no Linux/macOS.
5. Abra `http://localhost:8080/powerfit-academia/`.
6. O login está em `http://localhost:8080/powerfit-academia/login.jsp`.

Não abra os arquivos JSP diretamente no navegador: eles precisam ser processados pelo Tomcat. Se a porta 8080 estiver ocupada, ajuste o conector no arquivo `conf/server.xml` do Tomcat. Para atualizar o site, gere novamente o WAR e faça o redeploy. Consulte a pasta `logs` do Tomcat em caso de erro.

## Preparar o MySQL para integração futura

1. Instale e inicie o MySQL 8.
2. Abra `banco-dados.sql` no MySQL Workbench e execute o script completo. Ele cria o banco `powerfit` e a tabela `alunos` com `id`, `nome`, `email`, `telefone` e `senha`. O e-mail é único.
3. Em `src/main/java/dao/Conexao.java`, ajuste as constantes `URL`, `USUARIO` e `SENHA` conforme o banco do grupo. A configuração inicial aponta para `localhost:3306/powerfit`.
4. Gere novamente o WAR após alterar as constantes. O Maven inclui o driver JDBC no pacote.

`AlunoDAO.cadastrar` e `AlunoDAO.buscarPorEmail` estão preparados, mas não são chamados pelas páginas nem pelo Servlet de contato. Ambos usam `PreparedStatement` e fecham os recursos com `try-with-resources`. Em uma próxima etapa, o grupo poderá criar um Servlet de matrícula/cadastro que valide os dados, monte um `Aluno` e chame o DAO.

Na integração de cadastro e login, transforme senhas em hash apropriado antes de armazenar e implemente a verificação desse hash. O campo `senha` tem espaço para isso; esta versão não implementa autenticação. Não publique credenciais reais no repositório.

## Conferência manual

- Em computador e celular, confira o menu, as seções e o login.
- Abra “Saiba mais” nas seis modalidades e feche com Escape.
- Escolha cada plano e confira a mensagem preenchida no contato.
- Teste campos vazios, e-mail inválido e telefone sem DDD.
- Com dados válidos, confira o aviso de validação pelo servidor, sem envio ou gravação.
- No login, teste mostrar/ocultar senha e “Esqueci minha senha”.

## Personalizar e apresentar

Edite textos em `index.jsp` e `login.jsp`, cores em `css/style.css` e substitua as imagens em `imagens/`. O mapa utiliza imagens do OpenStreetMap com JavaScript simples em `js/mapa.js`, sem iframe ou bibliotecas. Requer internet e mostra a região central de São Paulo sem marcar a academia fictícia. Possui zoom, arraste, navegação pelas setas do teclado e botão para centralizar. O navegador carrega somente as imagens da área visível e utiliza o cache HTTP normal. A atribuição permanece visível, conforme https://operations.osmfoundation.org/policies/tiles/. O link abaixo abre a região no Google Maps. Ao definir um endereço real, atualize a área do mapa e seu link. Os links sociais apontam para as plataformas; substitua-os por perfis oficiais se o projeto passar a representar uma academia real.

As fotografias são ilustrativas geradas por IA. Academia, pessoas, depoimentos, CREFs, valores e contatos são fictícios. O grupo deve compreender o código e declarar o uso de ferramentas conforme as regras da disciplina.



## Roteiro de apresentação do grupo

1. **Objetivo e interface:** apresentar a academia fictícia e mostrar as seções de `index.jsp`, os planos e o layout no celular. JSP é processado pelo Tomcat e entrega HTML ao navegador.
2. **Estilos e interação:** explicar que CSS organiza cores, responsividade e efeitos dos cards; JavaScript controla menu, detalhes das modalidades e preenchimento do plano escolhido.
3. **Contato:** o navegador valida os campos e envia um POST para `/contato`. `ContatoServlet` lê os parâmetros, valida novamente e redireciona para `index.jsp` com o resultado. Validar no servidor é necessário porque a validação do navegador pode ser contornada.
4. **Modelo e acesso a dados:** `Aluno` representa os dados; `Conexao` abre a conexão JDBC; `AlunoDAO` concentra os comandos SQL. `PreparedStatement` recebe os valores como parâmetros e `try-with-resources` fecha conexão, comando e resultado.
5. **Limites desta versão:** o contato não grava dados nem envia e-mail; o login é demonstrativo. O banco foi preparado, mas não é chamado pelas páginas. Mostrar o script SQL e explicar essa decisão do enunciado.
6. **Execução:** o Maven compila e gera o WAR; o Tomcat executa JSP e Servlets. Mostrar onde fica o WAR e como configurar o MySQL no README.

Antes da apresentação, cada integrante deve conseguir explicar a parte que demonstra e localizar os arquivos correspondentes. Não usar credenciais pessoais durante a demonstração do login.

## Verificação realizada em 29/09/2026

Teste no navegador com larguras de 390 e 320 pixels (simulação de tela, sem aparelho físico):

- Página principal sem transbordamento horizontal nas duas larguras.
- Menu abre, navega para a seção e fecha após escolher o link.
- Janela de detalhes de Musculação abre e fecha sem cortar o conteúdo.
- Cards dos professores e planos ficam em uma coluna; o anual aparece primeiro no celular.
- Escolher o plano anual preenche a mensagem do contato.
- Telefone inválido é rejeitado; dados fictícios válidos chegam ao Servlet e exibem o resultado.
- Mapa carrega na largura de 390 pixels e permite ampliar.
- Login a 320 pixels: mostrar senha, aviso de login demonstrativo e recuperação futura funcionam.

A simulação não substitui uma conferência em Android/iPhone para gestos de toque e teclado virtual. Não foram realizados testes de integração com MySQL, pois as páginas não utilizam o banco nesta versão.

Repositório do grupo: https://github.com/Oliagua/Projeto_Facul_Academia. Este diretório contém o módulo Web inicial. O enunciado completo exige também Flutter, CRUD persistido e banco com relacionamentos; essas partes ainda precisam ser desenvolvidas pelo grupo.
