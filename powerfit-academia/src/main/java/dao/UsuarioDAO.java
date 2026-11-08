package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import util.SenhaUtil;

public class UsuarioDAO {
    private static final String SQL_CADASTRAR =
            "INSERT INTO usuario (nome, email, telefone, id_plano, senha) VALUES (?, ?, ?, ?, ?)";

    // Lança SQLIntegrityConstraintViolationException se o e-mail já existe ou o plano não existe.
    public void cadastrar(String nome, String email, String telefone, int idPlano, String senhaPlana)
            throws SQLException {
        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando = conexao.prepareStatement(SQL_CADASTRAR)) {
            comando.setString(1, nome);
            comando.setString(2, email);
            comando.setString(3, telefone);
            comando.setInt(4, idPlano);
            comando.setString(5, SenhaUtil.gerar(senhaPlana));
            comando.executeUpdate();
        }
    }
}
