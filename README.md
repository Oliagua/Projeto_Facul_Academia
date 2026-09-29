## Código do projeto — PowerFit Academia

O módulo Web está em [powerfit-academia](powerfit-academia/), com fontes Java/JSP, imagens, CSS, JavaScript, Maven e script MySQL. Consulte o [guia de execução](powerfit-academia/README.md) para compilar e publicar no Tomcat 9.

**Estado atual:** site institucional e estrutura JDBC inicial. Ainda não é a entrega final do Trabalho Integrador: faltam módulo Flutter, CRUD administrativo persistido, banco com relacionamentos e integração entre módulos. O login e o contato são demonstrativos. A tabela `alunos` é apenas uma base inicial e não satisfaz sozinha o requisito de modelagem final.

Consulte [o acompanhamento dos requisitos](docs/estado-do-projeto.md). `target/`, WARs, classes compiladas e arquivos de IDE não são versionados. O desenvolvimento desta primeira versão contou com assistência de IA; o grupo deve revisar e compreender o código conforme as regras da disciplina.

---

# Projeto_Facul_Academia
Um projeto semestral da faculdade onde todos os integrantes do grupo irão fazer um desenvolvimento web e mobile com banco de dados em conjunto.

Informações da avaliação do projeto:

TRABALHO INTEGRADOR
Desenvolvimento de Aplicação Web e Mobile para Gestão de um
Negócio
1. Disciplinas envolvidas
O Trabalho Integrador será desenvolvido de forma interdisciplinar, envolvendo os
conhecimentos e competências trabalhados nas seguintes disciplinas:
• Computação Móvel – desenvolvimento de aplicações utilizando Flutter;
• Programação para Banco de Dados – modelagem, criação e manipulação de
bancos de dados utilizando SQL;
• Aplicações Orientadas a Objetos – desenvolvimento de aplicações Web
utilizando Java, JSP e Servlets.

2. Objetivo do trabalho
O objetivo deste Trabalho Integrador é desenvolver uma solução computacional
para apoiar as atividades de um negócio, aplicando de forma integrada os
conhecimentos adquiridos nas três disciplinas.
Cada grupo deverá escolher livremente um ramo de negócio e identificar um
problema ou necessidade que possa ser atendido por meio de uma aplicação.
A solução deverá possuir obrigatoriamente:
• uma aplicação Web, desenvolvida em Java utilizando JSP e Servlets;
• uma aplicação Mobile, desenvolvida utilizando Flutter;
• um banco de dados, projetado e manipulado utilizando SQL;
• operações de CRUD (Create, Read, Update e Delete);
• aplicação dos conceitos de orientação a objetos estudados na disciplina;
• integração coerente entre os módulos que compõem a solução.
O projeto deverá utilizar somente tecnologias, técnicas e recursos trabalhados
nas disciplinas envolvidas, não sendo necessário utilizar frameworks, bibliotecas,
arquiteturas ou tecnologias que não tenham sido abordadas durante o curso.

3. Tema do projeto
O tema e o ramo de negócio serão de livre escolha de cada grupo.
A proposta deverá representar uma situação de negócio plausível, na qual seja
possível identificar:
• usuários do sistema;
• informações que precisam ser cadastradas;
• processos realizados pelo negócio;
• consultas necessárias;
• operações de inclusão, alteração e exclusão de informações.
Alguns exemplos de temas possíveis são:
• clínica veterinária;
• academia;
• salão de beleza ou barbearia;
• oficina mecânica;
• biblioteca;
• escola de idiomas;
• loja de roupas;
• restaurante;
• cafeteria;
• pet shop;
• imobiliária;
• estacionamento;
• assistência técnica;
• empresa de eventos;
• sistema de reservas;
• controle de estoque;
• gerenciamento de serviços;
• locadora de equipamentos;
• sistema para pequenos produtores;
• gerenciamento de campeonatos ou atividades esportivas.
Os exemplos são apenas sugestões. Os grupos são incentivados a propor outros
negócios e soluções.

4. Estrutura mínima da solução
A solução deverá ser composta por três elementos principais.
4.1. Aplicação Web
A aplicação Web deverá ser desenvolvida utilizando os recursos trabalhados na
disciplina Aplicações Orientadas a Objetos.
Tecnologias previstas:
• Java;
• JSP;
• Servlets;
• HTML;
• CSS, quando necessário;
• conceitos de orientação a objetos.
O módulo Web deverá permitir que determinados usuários do negócio realizem
operações administrativas ou de gerenciamento.
Exemplos:
• cadastrar produtos;
• cadastrar clientes;
• consultar pedidos;
• alterar informações;
• excluir registros;
• controlar estoque;
• administrar agendamentos;
• consultar dados cadastrados pelo sistema.
A função específica do módulo Web dependerá do negócio escolhido pelo grupo.

4.2. Aplicação Mobile
A aplicação Mobile deverá ser desenvolvida utilizando Flutter, aplicando os
conhecimentos estudados na disciplina Computação Móvel.
O aplicativo deverá possuir funcionalidades relacionadas ao negócio escolhido.
Exemplos:
• cadastro e consulta de informações;

• consulta de produtos ou serviços;
• realização de agendamentos;
• acompanhamento de pedidos;
• gerenciamento de tarefas;
• consulta de reservas;
• atualização de informações;
• outras operações relacionadas ao negócio.
O aplicativo Mobile não deverá ser apenas uma reprodução das mesmas telas da
aplicação Web.
Os grupos deverão pensar na função de cada plataforma dentro do negócio.
Por exemplo:
Sistema de academia
• Web: administração de alunos, planos e professores;
• Mobile: consulta de treinos e registro de atividades pelo aluno.
Sistema de restaurante
• Web: gerenciamento de produtos, mesas e pedidos;
• Mobile: registro e acompanhamento dos pedidos.
Sistema de clínica veterinária
• Web: gerenciamento de clientes, animais, veterinários e consultas;
• Mobile: acompanhamento e gerenciamento de agendamentos.

5. Banco de Dados
O banco de dados deverá ser projetado utilizando os conhecimentos trabalhados na
disciplina Programação para Banco de Dados.
O projeto deverá apresentar uma estrutura relacional coerente com o negócio
escolhido.
Deverão ser aplicados, quando pertinentes:
• tabelas;
• atributos;
• tipos de dados;
• chaves primárias;

• chaves estrangeiras;
• relacionamentos;
• restrições;
• comandos SQL.
O banco deverá possuir quantidade suficiente de tabelas e relacionamentos para
representar adequadamente o negócio escolhido.
Não serão considerados adequados projetos constituídos apenas por uma única
tabela ou por estruturas excessivamente simplificadas que não permitam
demonstrar os conhecimentos desenvolvidos nas disciplinas.

6. Operações CRUD
O projeto deverá implementar operações de CRUD.
CRUD corresponde às seguintes operações:
Operação Significado Exemplo
Create Inserir cadastrar um cliente
Read Consultar listar clientes cadastrados
Update Alterar atualizar os dados de um cliente
Delete Excluir remover um cliente
As operações deverão utilizar efetivamente o banco de dados desenvolvido pelo
grupo.
O CRUD poderá ser realizado sobre uma ou mais entidades do sistema, de forma
compatível com o funcionamento da aplicação.

7. Integração entre as disciplinas
O projeto não deverá ser desenvolvido como três atividades independentes.
A proposta deverá demonstrar claramente como os conhecimentos das três
disciplinas fazem parte de uma única solução.
De forma geral:
Aplicações Orientadas a Objetos
→ responsável pelo desenvolvimento do módulo Web em Java, JSP e Servlets.

Computação Móvel
→ responsável pelo desenvolvimento do módulo Mobile em Flutter.
Programação para Banco de Dados
→ responsável pela modelagem, criação, consultas e manipulação dos dados
utilizados pela solução.
O grupo deverá explicar durante a apresentação qual é o papel de cada módulo e
como eles fazem parte do processo do negócio escolhido.

8. Requisitos mínimos do projeto
O projeto deverá apresentar, no mínimo:
• aplicação relacionada a um negócio;
• módulo Web funcional;
• módulo Mobile funcional;
• banco de dados relacional;
• operações utilizando SQL;
• utilização de orientação a objetos;
• implementação de operações CRUD;
• navegação entre as principais funcionalidades;
• interface que permita utilizar adequadamente as funcionalidades
implementadas;
• validação básica dos dados informados pelos usuários;
• código organizado e compreensível.
O grupo poderá implementar funcionalidades adicionais, desde que utilize os
conhecimentos e tecnologias trabalhados nas disciplinas.

9. Documentação do projeto
Cada grupo deverá entregar a documentação do projeto contendo três documentos
principais.
Documento 1 – Descrição do Projeto
O documento deverá apresentar uma visão geral da solução desenvolvida.

Deverá conter:
1. Nome do projeto;
2. Integrantes do grupo;
3. Descrição do negócio escolhido;
4. Problema ou necessidade identificada;
5. Objetivo da aplicação;
6. Público-alvo;
7. Descrição da solução proposta;
8. Papel da aplicação Web;
9. Papel da aplicação Mobile;
10. Principais funcionalidades;
11. Tecnologias utilizadas.

Documento 2 – Especificação de Requisitos
Deverá apresentar os requisitos definidos pelo grupo para a aplicação.
O documento deverá conter:
Requisitos Funcionais
Os requisitos funcionais representam aquilo que o sistema deverá realizar.
Exemplos:
RF01 – Cadastrar cliente
O sistema deverá permitir o cadastro de clientes.
RF02 – Consultar clientes
O sistema deverá permitir consultar os clientes cadastrados.
RF03 – Alterar cliente
O sistema deverá permitir alterar os dados de um cliente.
RF04 – Excluir cliente
O sistema deverá permitir excluir um cliente cadastrado.
Os requisitos deverão ser identificados e descritos de forma clara.
Requisitos Não Funcionais
Quando aplicáveis, deverão ser apresentados requisitos relacionados a
características gerais da aplicação, como:
• tecnologia utilizada;

• plataforma;
• banco de dados;
• interface;
• desempenho;
• usabilidade;
• organização da aplicação.

Documento 3 – Modelagem e Estrutura Técnica
Deverá apresentar os principais aspectos técnicos da solução.
O documento deverá incluir, conforme os conteúdos trabalhados nas disciplinas:
Banco de Dados
• modelo do banco de dados;
• tabelas;
• atributos;
• chaves primárias;
• chaves estrangeiras;
• relacionamentos;
• modelo ou diagrama utilizado na disciplina;
• script SQL para criação das principais estruturas.
Aplicação Orientada a Objetos
Apresentação da organização das principais classes utilizadas no projeto, indicando
suas responsabilidades.
Quando trabalhado na disciplina, poderá ser apresentado:
• diagrama de classes;
• classes de entidade;
• classes responsáveis pelo acesso aos dados;
• Servlets;
• JSPs;
• relacionamento entre os componentes.
Aplicação Mobile
Apresentação da organização das principais telas e componentes do aplicativo
Flutter.
Poderão ser apresentados:

• fluxo de navegação;
• principais telas;
• estrutura dos componentes;
• funcionalidades disponíveis no aplicativo.

10. Apresentação do projeto
Cada grupo deverá realizar uma apresentação prática da aplicação desenvolvida.
Todos os integrantes do grupo deverão estar presentes e participar da
apresentação.
Durante a apresentação, o grupo deverá demonstrar:
1. o negócio escolhido;
2. o problema que motivou o desenvolvimento;
3. a solução proposta;
4. a estrutura do banco de dados;
5. a aplicação Web;
6. a aplicação Mobile;
7. as operações CRUD;
8. a integração entre os componentes;
9. a participação das três disciplinas no desenvolvimento da solução.
O grupo deverá realizar uma demonstração prática do sistema funcionando.
Durante a demonstração deverão ser realizadas operações que comprovem o
funcionamento da aplicação, tais como:
Cadastrar → Consultar → Alterar → Consultar novamente → Excluir
Os professores poderão solicitar a execução de funcionalidades específicas durante
a apresentação.

11. Participação dos integrantes
O Trabalho Integrador é uma atividade em grupo, mas todos os integrantes deverão
conhecer a solução desenvolvida.
Durante a apresentação, qualquer integrante poderá ser questionado sobre:
• funcionamento do sistema;

• banco de dados;
• código;
• telas;
• classes;
• consultas SQL;
• regras de negócio;
• funcionalidades implementadas.
A divisão de tarefas entre os integrantes é permitida e recomendada, porém o
projeto deverá representar o trabalho conjunto do grupo.

12. Critérios sugeridos para avaliação
A avaliação poderá considerar os seguintes aspectos:
Critério Aspectos observados
Atendimento à proposta Desenvolvimento Web, Mobile e Banco

de Dados

Banco de Dados Modelagem, relacionamentos, SQL e

consistência

Aplicação Web Funcionamento, Java, JSP, Servlets e

orientação a objetos

Aplicação Mobile Funcionamento e aplicação dos

conceitos de Flutter

CRUD Funcionamento das operações de
inclusão, consulta, alteração e exclusão
Integração Coerência entre Web, Mobile, Banco de

Dados e processo do negócio
Qualidade da solução Organização, regras de negócio,
validações e funcionamento

Documentação Clareza, completude e coerência com a

aplicação desenvolvida

Apresentação Organização, demonstração prática e

domínio do projeto

Participação do grupo Participação e domínio dos integrantes
Funcionalidades adicionais poderão contribuir para a qualidade do trabalho, porém
não compensarão a ausência dos requisitos obrigatórios.

13. Restrições do projeto
Para manter o trabalho compatível com os objetivos das disciplinas:
• deverão ser utilizadas prioritariamente as tecnologias estudadas durante o
semestre;
• não é necessário desenvolver funcionalidades que dependam de tecnologias
ainda não estudadas;
• a complexidade do negócio deverá ser compatível com o período disponível
para desenvolvimento;
• a prioridade deverá ser o correto funcionamento e integração dos
conteúdos estudados, e não a quantidade de funcionalidades.
Um sistema menor, porém completo, funcional e bem estruturado será considerado
mais adequado do que uma aplicação muito extensa e incompleta.

14. Entregas
O Trabalho Integrador terá duas entregas principais.
Entrega 1 – Documentação
O grupo deverá entregar:
1. Documento Descritivo do Projeto;
2. Documento de Requisitos;
3. Documento de Modelagem e Estrutura Técnica, contendo banco de dados e
componentes da solução.
Entrega 2 – Aplicação e Apresentação
O grupo deverá apresentar:
• aplicação Web;
• aplicação Mobile;
• banco de dados;
• CRUD funcionando;
• integração da solução;
• demonstração prática.
Todos os integrantes deverão participar da apresentação.

15. Datas
As datas para:
• entrega da documentação;
• entrega do projeto;
• apresentações dos grupos;
serão definidas e divulgadas pelo professor.

16. Resultado esperado
Ao final do Trabalho Integrador, espera-se que os estudantes sejam capazes de
demonstrar, por meio de uma solução funcional, a aplicação integrada dos
conhecimentos desenvolvidos em:
Flutter + Java Web (JSP/Servlet) + Banco de Dados SQL
O principal objetivo não é apenas desenvolver duas interfaces, mas compreender
como diferentes tecnologias podem ser combinadas para solucionar um problema
real de um negócio, desde a modelagem e persistência dos dados até sua
utilização em aplicações Web e Mobile.
