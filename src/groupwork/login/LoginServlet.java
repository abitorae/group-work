package groupwork.login;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        //  TODO: 改进登录验证
        if ("admin".equals(username) && "123456".equals(password)) {
            String target = req.getContextPath() + "/home.html?user="
                    + URLEncoder.encode(username, StandardCharsets.UTF_8);
            resp.sendRedirect(target);
        } else {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=1");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/index.html");
    }
}