package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Usuario;
import util.SenhaUtil;

public class UsuarioDAO {
    private static final String SQL_CADASTRAR =
            "INSERT INTO usuario (nome, email, telefone, id_plano, senha) VALUES (?, ?, ?, ?, ?)";
    private static final String SQL_BUSCAR_POR_EMAIL =
            "SELECT id_usuario, nome, email, id_plano, senha FROM usuario WHERE email = ?";

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

    // Retorna o usuário se o e-mail existe e a senha confere, ou null.
    public Usuario autenticar(String email, String senhaDigitada) throws SQLException {
        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando = conexao.prepareStatement(SQL_BUSCAR_POR_EMAIL)) {
            comando.setString(1, email);
            try (ResultSet resultado = comando.executeQuery()) {
                if (!resultado.next()) return null;
                if (!SenhaUtil.confere(senhaDigitada, resultado.getString("senha"))) return null;
                return new Usuario(resultado.getInt("id_usuario"), resultado.getString("nome"),
                        resultado.getString("email"), resultado.getInt("id_plano"));
            }
        }
    }
}
