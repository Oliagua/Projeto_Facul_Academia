package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Conexão centralizada para futura integração com o MySQL. */
public class Conexao {
    // Altere estes dados conforme o MySQL configurado pelo grupo.
    private static final String URL = "jdbc:mysql://localhost:3306/powerfit?useSSL=false&serverTimezone=America/Sao_Paulo";
    private static final String USUARIO = "root";
    private static final String SENHA = "";

    public static Connection conectar() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL não encontrado.", e);
        }
        return DriverManager.getConnection(URL, USUARIO, SENHA);
    }
}
