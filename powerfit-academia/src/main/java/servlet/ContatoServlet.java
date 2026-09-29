package servlet;

import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Validação demonstrativa, sem banco e sem envio de e-mail. */
@WebServlet("/contato")
public class ContatoServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest requisicao, HttpServletResponse resposta) throws IOException {
        requisicao.setCharacterEncoding("UTF-8");
        String nome = campo(requisicao, "nome");
        String email = campo(requisicao, "email");
        String telefone = campo(requisicao, "telefone");
        String mensagem = campo(requisicao, "mensagem");
        boolean valido = nome.length() >= 2 && nome.length() <= 120
                && email.length() <= 120 && email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
                && telefone.length() <= 25 && telefone.replaceAll("\\D", "").matches("\\d{10,11}")
                && !mensagem.isEmpty() && mensagem.length() <= 2000;
        resposta.setHeader("Cache-Control", "no-store");
        resposta.setStatus(HttpServletResponse.SC_SEE_OTHER);
        resposta.setHeader("Location", requisicao.getContextPath()
                + "/index.jsp?contato=" + (valido ? "validado" : "invalido") + "#contato");
    }
    private String campo(HttpServletRequest requisicao, String nome) {
        String valor = requisicao.getParameter(nome);
        return valor == null ? "" : valor.trim();
    }
}
