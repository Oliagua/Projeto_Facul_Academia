# PowerFit Mobile

Aplicativo Flutter do **aluno** da PowerFit Academia. O site (módulo Web) é usado pela academia para administrar alunos, planos e professores. O app é onde o aluno entra com a conta dele, consulta os treinos e registra o que treinou.

O app reaproveita o conteúdo e a identidade visual do site: as cores (preto e âmbar `#ffb400`), as fontes (Barlow Condensed e DM Sans), as fotos, as modalidades, os planos e preços, os professores com CREF, os depoimentos, o endereço e os horários.

## Funcionalidades

| Tela | O que faz |
| --- | --- |
| **Login** | E-mail e senha, mostrar/ocultar senha, aviso de credenciais incorretas. O app lembra quem está logado. |
| **Criar conta** | Nome, e-mail, telefone (com máscara), escolha do plano e senha com confirmação. |
| **Início** | Saudação, meta semanal (anel de progresso), minutos na semana, dias seguidos, gráfico dos últimos 7 dias, treino sugerido, modalidades, professores, estrutura, depoimentos e contato. |
| **Treinos** | Fichas A–F montadas pelos professores, com filtro por modalidade. |
| **Detalhe do treino** | Exercícios com séries, repetições, carga e descanso. O aluno marca o que já fez e, no fim, registra o treino. |
| **Atividades** | **CRUD completo**: registrar, listar (agrupado por dia), editar (toque) e excluir (deslizar, com "Desfazer"). |
| **Convidados** | **CRUD completo**: convidar, listar, editar e excluir, respeitando o limite mensal do plano. |
| **Perfil** | Dados do aluno, totais, plano atual, editar nome/telefone, alterar senha, trocar plano, sair e excluir conta. |
| **Planos** | Os quatro planos do site, com o plano atual destacado e a opção de troca. |

Fluxo para a apresentação: **Criar conta → Entrar → Registrar treino → Consultar → Editar → Consultar de novo → Excluir.**

## Banco de dados

O app usa um banco **SQLite no próprio aparelho**, criado em [lib/database/banco_local.dart](lib/database/banco_local.dart), com a estrutura do modelo do grupo. Ainda não é o mesmo banco do site: veja [Próximo passo](#próximo-passo-integração-com-o-site).

### Tabelas do modelo do grupo

Têm exatamente as colunas do diagrama, e um teste automático confere isso.

```
plano (1) ──< usuario (1) ──< treino
                  (1) ──────< convidado
```

| Tabela | Colunas | No app |
| --- | --- | --- |
| `plano` | `id_plano` PK, `nome_plano`, `duracao_meses`, `preco` | Os 4 planos do site. `preco` é o valor **por mês**. |
| `usuario` | `id_usuario` PK, `nome`, `email` único, `senha`, `id_plano` FK | Conta do aluno. `senha` guarda `salt:hash`, nunca a senha em texto. |
| `treino` | `id_treino` PK, `descricao`, `data_treino`, `duracao_minutos`, `id_usuario` FK | Cada treino registrado na aba **Atividades** (classe `Atividade`). |
| `convidado` | `id_convidado` PK, `nome`, `data_visita`, `id_usuario` FK | Tela **Convidados**. |

### Tabelas de apoio do aplicativo (prefixo `app_`)

Guardam o que o app já usava e o diagrama não prevê. Ficam separadas para o modelo do grupo continuar igual ao diagrama.

| Tabela | Conteúdo |
| --- | --- |
| `app_perfil` | Telefone e data de cadastro de cada `usuario` |
| `app_plano` | Descrição, benefícios, destaque e limite de convidados de cada `plano` |
| `app_treino_detalhe` | Ficha usada, intensidade e observação de cada `treino` |
| `app_modalidade` | As 6 modalidades do site |
| `app_professor` | Os 4 professores do site, com CREF e foto |
| `app_ficha` | Fichas de treino A–F, com FK para modalidade e professor |
| `app_exercicio` | Exercícios de cada ficha |

A senha é guardada como `SHA-256(salt + senha)`, com um salt aleatório por usuário. Quem já usava a versão anterior do app tem a conta e os treinos migrados automaticamente na primeira abertura.

**Regra de negócio dos convidados:** vem dos benefícios divulgados no site. Mensal: nenhum. Trimestral e Semestral: 1 por mês. Anual: 2 por mês.

## Como executar

Requisitos: Flutter 3.29 ou superior (testado com 3.47.7).

```
cd powerfit_mobile
flutter pub get
```

**No Chrome** (não precisa de emulador):

```
flutter run -d chrome
```

**No Android**: instale o Android Studio, crie um emulador (Device Manager) e rode:

```
flutter run
```

**No iOS** (só em um Mac): a pasta `ios` não vai para o repositório, para reduzir a quantidade de arquivos. Ela é gerada pelo Flutter, sem perda nenhuma, com:

```
flutter create --org br.com.powerfit --platforms ios .
```

O banco funciona no Android e no iOS com `sqflite`. No navegador, ele roda em WebAssembly (`web/sqlite3.wasm`).

**Testes:**

```
flutter test
```

Os testes cobrem cadastro/login, senha errada, e-mail duplicado, troca de senha, edição de perfil, troca de plano, exclusão de conta, estatísticas da semana e a validação do login. Com um SQLite real, cobrem também as colunas do modelo, o CRUD de treinos, o limite de convidados, a exclusão em cascata e a migração de contas antigas.

> Se o `flutter analyze` travar com `FormatException`, o motivo é o acento em "Área de Trabalho" no caminho da pasta, um bug conhecido do analisador do Dart. Para contornar, mapeie a pasta para uma letra de unidade (`subst P: "C:\...\pasta-do-projeto"`) e rode o comando a partir de `P:`.

## Organização do código

```
lib/
  main.dart                   inicia o app; abre o login ou a área logada
  theme.dart                  cores, fontes e estilo dos componentes
  models/                     Usuario, Plano, Modalidade, Professor, Treino/Exercicio, Atividade, Convidado
  database/
    banco_local.dart          abre o SQLite, cria as tabelas e migra versões antigas
    dados_iniciais.dart       conteúdo do site (planos, modalidades, professores, fichas)
    usuario_dao.dart          CRUD da conta
    catalogo_dao.dart         consultas com JOIN (planos, fichas, modalidade, professor)
    atividade_dao.dart        CRUD dos treinos registrados
    convidado_dao.dart        CRUD dos convidados
    fabrica_banco*.dart       escolhe o SQLite nativo ou o da web
  services/
    auth_service.dart         cadastro, login, hash da senha, perfil, plano, exclusão
    convidado_service.dart    limite de convidados por mês
    sessao_aluno.dart         usuário logado e aviso de mudanças às telas
    estatisticas.dart         meta semanal, sequência de dias e gráfico
  screens/                    login, cadastro, abas (início, treinos, atividades, perfil) e telas internas
  utils/                      validações e formatação (moeda, data, telefone)
  widgets/                    componentes reutilizados (logo, cartões, títulos, botões)
assets/
  imagens/                    fotos do site, reduzidas para o app
  fontes/                     Barlow Condensed e DM Sans (SIL Open Font License)
```

O caminho de uma ação é sempre **tela → service/DAO → SQLite**. As telas não escrevem SQL.

## Próximo passo: integração com o site

O app segue o modelo do grupo, mas cada aparelho ainda tem o seu próprio banco. Um aplicativo não acessa o MySQL diretamente: para todos usarem o mesmo banco, os Servlets do módulo Web precisam criar essas tabelas no MySQL e devolver JSON (`/api/login`, `/api/treinos`, `/api/convidados`...). No app, basta trocar o corpo dos DAOs por chamadas HTTP (pacote `http`), sem mexer nas telas. Antes disso, confirmar com o professor se a comunicação por HTTP é permitida.
