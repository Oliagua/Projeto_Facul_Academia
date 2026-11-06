import 'package:sqflite/sqflite.dart';

/// Conteúdo inicial, o mesmo exibido no site (index.jsp e melhorias.js).
class DadosIniciais {
  static const _img = 'assets/imagens';

  static void inserir(Batch lote) {
    for (final p in planos) {
      lote.insert('plano', {
        'id_plano': p['id_plano'],
        'nome_plano': p['nome_plano'],
        'duracao_meses': p['duracao_meses'],
        'preco': p['preco'],
      });
      lote.insert('app_plano', {
        'id_plano': p['id_plano'],
        'descricao': p['descricao'],
        'beneficios': p['beneficios'],
        'recomendado': p['recomendado'],
        'limite_convidados': p['limite_convidados'],
      });
    }
    for (final m in modalidades) {
      lote.insert('app_modalidade', m);
    }
    for (final p in professores) {
      lote.insert('app_professor', p);
    }
    for (final t in treinos) {
      final exercicios = t['exercicios'] as List<List<Object>>;
      lote.insert('app_ficha', Map.of(t)..remove('exercicios'));
      for (var i = 0; i < exercicios.length; i++) {
        final e = exercicios[i];
        lote.insert('app_exercicio', {
          'id_ficha': t['id'],
          'ordem': i + 1,
          'nome': e[0],
          'series': e[1],
          'repeticoes': e[2],
          'carga': e[3],
          'descanso_seg': e[4],
        });
      }
    }
  }

  // "preco" é o valor por mês, como o site mostra (R$ 89/mês no plano anual).
  static const planos = [
    {
      'id_plano': 1,
      'nome_plano': 'Plano Mensal',
      'duracao_meses': 1,
      'preco': 119.0,
      'descricao': 'Liberdade para começar.',
      'beneficios': 'Acesso à musculação;Aulas coletivas;Avaliação física',
      'recomendado': 0,
      'limite_convidados': 0,
    },
    {
      'id_plano': 2,
      'nome_plano': 'Plano Trimestral',
      'duracao_meses': 3,
      'preco': 109.0,
      'descricao': 'Ritmo para avançar.',
      'beneficios':
          'Todos os benefícios do plano mensal;Treino personalizado;1 convidado por mês',
      'recomendado': 0,
      'limite_convidados': 1,
    },
    {
      'id_plano': 3,
      'nome_plano': 'Plano Semestral',
      'duracao_meses': 6,
      'preco': 99.0,
      'descricao': 'Consistência que transforma.',
      'beneficios':
          'Todos os benefícios do plano mensal;Treino personalizado;1 convidado por mês',
      'recomendado': 0,
      'limite_convidados': 1,
    },
    {
      'id_plano': 4,
      'nome_plano': 'Plano Anual',
      'duracao_meses': 12,
      'preco': 89.0,
      'descricao': 'O melhor valor para você.',
      'beneficios': 'Todos os benefícios;Revisão mensal do treino;2 convidados por mês',
      'recomendado': 1,
      'limite_convidados': 2,
    },
  ];

  static const modalidades = [
    {
      'id': 1,
      'nome': 'Musculação',
      'resumo': 'Força, condicionamento e evolução.',
      'descricao':
          'Treino com pesos livres e aparelhos. Cargas e exercícios são adaptados ao seu nível com orientação dos professores.',
      'imagem': '$_img/modalidade-1.jpg',
    },
    {
      'id': 2,
      'nome': 'Funcional',
      'resumo': 'Movimentos para a vida real.',
      'descricao':
          'Movimentos que combinam força, equilíbrio e coordenação, com opções para iniciantes.',
      'imagem': '$_img/modalidade-2.jpg',
    },
    {
      'id': 3,
      'nome': 'Cross Training',
      'resumo': 'Intensidade e comunidade.',
      'descricao':
          'Circuitos com cordas, pesos e exercícios com o próprio corpo. A intensidade é ajustada ao seu condicionamento.',
      'imagem': '$_img/cross.jpg',
    },
    {
      'id': 4,
      'nome': 'Spinning',
      'resumo': 'Ritmo, energia e resistência.',
      'descricao':
          'Ciclismo indoor com música e variações de ritmo. Cada aluno regula a resistência da bicicleta.',
      'imagem': '$_img/modalidade-3.jpg',
    },
    {
      'id': 5,
      'nome': 'Alongamento',
      'resumo': 'Mobilidade para seu melhor movimento.',
      'descricao': 'Movimentos controlados para trabalhar flexibilidade e mobilidade.',
      'imagem': '$_img/modalidade-4.jpg',
    },
    {
      'id': 6,
      'nome': 'Personal Trainer',
      'resumo': 'Atenção exclusiva à sua meta.',
      'descricao':
          'Acompanhamento individual com planejamento específico. Serviço contratado separadamente: consulte disponibilidade e valores.',
      'imagem': '$_img/personal.jpg',
    },
  ];

  static const professores = [
    {
      'id': 1,
      'nome': 'Gustavo Tavares',
      'especialidade': 'Musculação e Hipertrofia',
      'cref': 'CREF 012345-G/SP',
      'foto': '$_img/professor-1.jpg',
    },
    {
      'id': 2,
      'nome': 'Angelina Alves',
      'especialidade': 'Funcional e Mobilidade',
      'cref': 'CREF 023456-G/SP',
      'foto': '$_img/professor-2.jpg',
    },
    {
      'id': 3,
      'nome': 'Rafael Costa',
      'especialidade': 'Cross Training',
      'cref': 'CREF 034567-G/SP',
      'foto': '$_img/professor-3.jpg',
    },
    {
      'id': 4,
      'nome': 'Camila Santos',
      'especialidade': 'Spinning e Condicionamento',
      'cref': 'CREF 045678-G/SP',
      'foto': '$_img/professor-4.jpg',
    },
  ];

  // Exercícios: [nome, séries, repetições, carga, descanso em segundos]
  static const treinos = [
    {
      'id': 1,
      'letra': 'A',
      'imagem': '$_img/modalidade-1.jpg',
      'nome': 'Peito, ombro e tríceps',
      'foco': 'Empurrar',
      'nivel': 'Intermediário',
      'duracao_min': 55,
      'modalidade_id': 1,
      'professor_id': 1,
      'exercicios': [
        ['Supino reto com barra', 4, '8 a 10', '30 kg', 90],
        ['Supino inclinado com halteres', 3, '10 a 12', '12 kg cada', 75],
        ['Crucifixo na máquina', 3, '12', '25 kg', 60],
        ['Desenvolvimento com halteres', 3, '10', '10 kg cada', 75],
        ['Elevação lateral', 3, '12 a 15', '6 kg cada', 60],
        ['Tríceps na polia', 3, '12', '20 kg', 60],
      ],
    },
    {
      'id': 2,
      'letra': 'B',
      'imagem': '$_img/personal.jpg',
      'nome': 'Costas e bíceps',
      'foco': 'Puxar',
      'nivel': 'Intermediário',
      'duracao_min': 50,
      'modalidade_id': 1,
      'professor_id': 1,
      'exercicios': [
        ['Puxada frontal', 4, '10', '40 kg', 90],
        ['Remada curvada com barra', 4, '8 a 10', '30 kg', 90],
        ['Remada baixa', 3, '12', '35 kg', 75],
        ['Pulldown com braços estendidos', 3, '12', '20 kg', 60],
        ['Rosca direta', 3, '10 a 12', '20 kg', 60],
        ['Rosca martelo', 3, '12', '10 kg cada', 60],
      ],
    },
    {
      'id': 3,
      'letra': 'C',
      'imagem': '$_img/hero.jpg',
      'nome': 'Pernas e glúteos',
      'foco': 'Membros inferiores',
      'nivel': 'Intermediário',
      'duracao_min': 60,
      'modalidade_id': 1,
      'professor_id': 1,
      'exercicios': [
        ['Agachamento livre', 4, '8 a 10', '40 kg', 120],
        ['Leg press 45°', 4, '12', '120 kg', 90],
        ['Cadeira extensora', 3, '12 a 15', '35 kg', 60],
        ['Mesa flexora', 3, '12', '30 kg', 60],
        ['Elevação pélvica', 3, '12', '50 kg', 75],
        ['Panturrilha em pé', 4, '15', '40 kg', 45],
      ],
    },
    {
      'id': 4,
      'letra': 'D',
      'imagem': '$_img/modalidade-2.jpg',
      'nome': 'Funcional e mobilidade',
      'foco': 'Corpo inteiro',
      'nivel': 'Iniciante',
      'duracao_min': 40,
      'modalidade_id': 2,
      'professor_id': 2,
      'exercicios': [
        ['Mobilidade de quadril', 2, '10 por lado', 'Peso corporal', 30],
        ['Agachamento com kettlebell', 3, '15', '12 kg', 45],
        ['Prancha', 3, '40 s', 'Peso corporal', 30],
        ['Avanço alternado', 3, '12 por perna', 'Peso corporal', 45],
        ['Remada com elástico', 3, '15', 'Elástico médio', 45],
        ['Equilíbrio em uma perna', 3, '30 s por perna', 'Peso corporal', 30],
      ],
    },
    {
      'id': 5,
      'letra': 'E',
      'imagem': '$_img/cross.jpg',
      'nome': 'Circuito Cross',
      'foco': 'Condicionamento',
      'nivel': 'Avançado',
      'duracao_min': 45,
      'modalidade_id': 3,
      'professor_id': 3,
      'exercicios': [
        ['Corda naval', 3, '30 s', 'Corda 12 m', 30],
        ['Burpee', 4, '12', 'Peso corporal', 45],
        ['Kettlebell swing', 4, '15', '16 kg', 45],
        ['Salto na caixa', 4, '10', 'Caixa 50 cm', 60],
        ['Thruster', 4, '10', '20 kg', 60],
        ['Remo ergômetro', 3, '250 m', 'Ritmo forte', 60],
      ],
    },
    {
      'id': 6,
      'letra': 'F',
      'imagem': '$_img/modalidade-3.jpg',
      'nome': 'Spinning intervalado',
      'foco': 'Resistência',
      'nivel': 'Todos os níveis',
      'duracao_min': 45,
      'modalidade_id': 4,
      'professor_id': 4,
      'exercicios': [
        ['Aquecimento', 1, '5 min', 'Carga leve', 0],
        ['Subida sentado', 4, '3 min', 'Carga alta', 60],
        ['Sprint em pé', 6, '30 s', 'Carga média', 30],
        ['Ritmo constante', 1, '10 min', 'Carga média', 0],
        ['Desaquecimento', 1, '5 min', 'Carga leve', 0],
      ],
    },
  ];
}
