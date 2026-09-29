package dao;

import model.Aluno;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/** Estrutura para futuros servlets; as páginas ainda não utilizam este DAO. */
public class AlunoDAO {
    public void cadastrar(Aluno aluno) throws SQLException {
        String sql = "INSERT INTO alunos (nome, email, telefone, senha) VALUES (?, ?, ?, ?)";
        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando = conexao.prepareStatement(sql)) {
            comando.setString(1, aluno.getNome());
            comando.setString(2, aluno.getEmail());
            comando.setString(3, aluno.getTelefone());
            // Na integração futura, receba a senha já transformada em hash.
            comando.setString(4, aluno.getSenha());
            comando.executeUpdate();
        }
    }

    public Aluno buscarPorEmail(String email) throws SQLException {
        String sql = "SELECT id, nome, email, telefone, senha FROM alunos WHERE email = ?";
        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando = conexao.prepareStatement(sql)) {
            comando.setString(1, email);
            try (ResultSet resultado = comando.executeQuery()) {
                if (!resultado.next()) {
                    return null;
                }
                Aluno aluno = new Aluno();
                aluno.setId(resultado.getInt("id"));
                aluno.setNome(resultado.getString("nome"));
                aluno.setEmail(resultado.getString("email"));
                aluno.setTelefone(resultado.getString("telefone"));
                aluno.setSenha(resultado.getString("senha"));
                return aluno;
            }
        }
    }
}
