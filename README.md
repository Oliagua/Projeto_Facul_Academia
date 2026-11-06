# PowerFit Academia

Projeto de academia para o Trabalho Integrador de Java Web, Computação Móvel e Banco de Dados.

## O que já está no repositório

**Site (Java Web)**

- Site com início, sobre, modalidades, planos, professores, estrutura, avaliações e contato.
- Tela de login, ainda sem autenticação.
- Interface administrativa de alunos com busca, filtros, cadastro, edição e exclusão em memória.
- Layout responsivo e mapa interativo.
- Validação do contato no navegador e em um Servlet.
- Classes iniciais para JDBC e script MySQL com a tabela de alunos.

**Aplicativo do aluno (Flutter)**

- Login e cadastro de conta.
- Fichas de treino montadas pelos professores, com os exercícios de cada uma.
- Registro de treinos, com inclusão, consulta, edição e exclusão.
- Convidados, com inclusão, consulta, edição e exclusão, respeitando o limite mensal de cada plano.
- Meta semanal, gráfico dos últimos 7 dias, planos e perfil.
- Banco SQLite no aparelho, com as tabelas do modelo do grupo: `plano`, `usuario`, `treino` e `convidado`.

Versão online do aplicativo: https://powerfitacademy.netlify.app/

## Como executar

### Site

O projeto Web fica em [powerfit-academia](powerfit-academia/). É necessário ter JDK 11 ou superior, Maven e Tomcat 9.

```bash
cd powerfit-academia
mvn clean package
```

Copie `target/powerfit-academia.war` para a pasta `webapps` do Tomcat e inicie o servidor. Depois, acesse `http://localhost:8080/powerfit-academia/`.

As instruções do banco e dos arquivos estão no [README do módulo Web](powerfit-academia/README.md).

### Aplicativo

O aplicativo fica em [powerfit_mobile](powerfit_mobile/). É necessário ter o Flutter 3.29 ou superior.

```bash
cd powerfit_mobile
flutter pub get
flutter run -d chrome
```

Para rodar no Android, instale o Android Studio, crie um emulador e use `flutter run`. Os demais detalhes estão no [README do aplicativo](powerfit_mobile/README.md).

## Organização

| Pasta | Conteúdo |
| --- | --- |
| `powerfit-academia/` | Projeto Web, imagens e SQL inicial |
| `powerfit_mobile/` | Aplicativo Flutter do aluno |
| `docs/` | Enunciado e acompanhamento das próximas etapas |

Arquivos gerados pelo Maven e pelo Flutter, WARs e configurações locais de IDE ficam fora do Git.

## Próximas etapas

- Criar no MySQL as tabelas do modelo do grupo e ligar o site a elas.
- Fazer o aplicativo usar o mesmo banco por meio de Servlets. Hoje cada aparelho tem o próprio banco.
- Concluir a documentação e preparar a apresentação.
