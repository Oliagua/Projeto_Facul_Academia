package servlet;

import dao.UsuarioDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Usuario;

/** Login do aluno: confere e-mail e senha no banco e abre a sessão. */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UsuarioDAO dao = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest requisicao, HttpServletResponse resposta) throws IOException {
        requisicao.setCharacterEncoding("UTF-8");
        String raiz = requisicao.getContextPath();
        String email = campo(requisicao, "email").toLowerCase();
        String senha = requisicao.getParameter("senha") == null ? "" : requisicao.getParameter("senha");
        if (email.isEmpty() || senha.isEmpty() || email.length() > 120 || senha.length() > 72) {
            redirecionar(resposta, raiz + "/login.jsp?erro=dados");
            return;
        }

        Usuario usuario;
        try {
            usuario = dao.autenticar(email, senha);
        } catch (SQLException e) {
            log("Falha ao consultar usuário", e);
            redirecionar(resposta, raiz + "/login.jsp?erro=servidor");
            return;
        }
        if (usuario == null) {
            redirecionar(resposta, raiz + "/login.jsp?erro=credenciais");
            return;
        }

        HttpSession antiga = requisicao.getSession(false);
        if (antiga != null) antiga.invalidate();
        requisicao.getSession(true).setAttribute("usuario", usuario);
        redirecionar(resposta, raiz + "/index.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest requisicao, HttpServletResponse resposta) throws IOException {
        redirecionar(resposta, requisicao.getContextPath() + "/login.jsp");
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
