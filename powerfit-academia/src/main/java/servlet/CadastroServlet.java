package servlet;

import dao.UsuarioDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Cadastro de aluno: valida os campos e grava o usuário com a senha em hash. */
@WebServlet("/cadastro")
public class CadastroServlet extends HttpServlet {
    private final UsuarioDAO dao = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest requisicao, HttpServletResponse resposta) throws IOException {
        requisicao.setCharacterEncoding("UTF-8");
        String nome = campo(requisicao, "nome");
        String email = campo(requisicao, "email").toLowerCase();
        String telefone = campo(requisicao, "telefone").replaceAll("\\D", "");
        String plano = campo(requisicao, "plano");
        String senha = requisicao.getParameter("senha") == null ? "" : requisicao.getParameter("senha");
        String confirmar = requisicao.getParameter("confirmar") == null ? "" : requisicao.getParameter("confirmar");

        boolean valido = nome.length() >= 2 && nome.length() <= 120
                && email.length() <= 120 && email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
                && telefone.matches("\\d{10,11}")
                && senha.length() >= 8 && senha.length() <= 72
                && plano.matches("\\d{1,9}");
        if (!valido) {
            voltar(requisicao, resposta, "dados");
            return;
        }
        if (!senha.equals(confirmar)) {
            voltar(requisicao, resposta, "senha");
            return;
        }

        try {
            dao.cadastrar(nome, email, telefone, Integer.parseInt(plano), senha);
        } catch (SQLIntegrityConstraintViolationException e) {
            voltar(requisicao, resposta, "email");
            return;
        } catch (SQLException e) {
            log("Falha ao cadastrar usuário", e);
            voltar(requisicao, resposta, "servidor");
            return;
        }
        redirecionar(resposta, requisicao.getContextPath() + "/login.jsp?cadastro=ok");
    }

    private void voltar(HttpServletRequest requisicao, HttpServletResponse resposta, String erro) {
        redirecionar(resposta, requisicao.getContextPath() + "/cadastro.jsp?erro=" + erro);
    }

    private void redirecionar(HttpServletResponse resposta, String destino) {
        resposta.setHeader("Cache-Control", "no-store");
        resposta.setStatus(HttpServletResponse.SC_SEE_OTHER);
        resposta.setHeader("Location", destino);
    }

    private String campo(HttpServletRequest requisicao, String nome) {
        String valor = requisicao.getParameter(nome);
        return valor == null ? "" : valor.trim();
    }
}
