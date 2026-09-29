# PowerFit Academia

Projeto de academia para o Trabalho Integrador de Java Web, Computação Móvel e Banco de Dados.

## O que já está no repositório

- Site com início, sobre, modalidades, planos, professores, estrutura, avaliações e contato.
- Tela de login, ainda sem autenticação.
- Interface administrativa de alunos com busca, filtros, cadastro, edição e exclusão em memória.
- Layout responsivo e mapa interativo.
- Validação do contato no navegador e em um Servlet.
- Classes iniciais para JDBC e script MySQL com a tabela de alunos.

## Como executar

O projeto Web fica em [powerfit-academia](powerfit-academia/). É necessário ter JDK 11 ou superior, Maven e Tomcat 9.

```bash
cd powerfit-academia
mvn clean package
```

Copie `target/powerfit-academia.war` para a pasta `webapps` do Tomcat e inicie o servidor. Depois, acesse `http://localhost:8080/powerfit-academia/`.

As instruções do banco e dos arquivos estão no [README do módulo Web](powerfit-academia/README.md).

## Organização

| Pasta | Conteúdo |
| --- | --- |
| `powerfit-academia/` | Projeto Web, imagens e SQL inicial |
| `docs/` | Enunciado e acompanhamento das próximas etapas |

Arquivos gerados pelo Maven, WARs e configurações locais de IDE ficam fora do Git.

## Próximas etapas

A entrega de front-end não conclui sozinho o trabalho integrador. Ainda falta o banco com relacionamentos, o aplicativo Flutter e a integração.
