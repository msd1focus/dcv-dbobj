package app.dcv.bean;

import app.dcv.adfextensions.ADFUtils;

import app.dcv.adfextensions.JSFUtils;

import app.dcv.bean.useraccessmenu.UserData;
import java.io.IOException;

import java.util.HashMap;
import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;

import javax.security.auth.Subject;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.login.FailedLoginException;
import javax.security.auth.login.LoginException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;

import oracle.adf.view.rich.component.rich.input.RichInputText;

import oracle.binding.OperationBinding;

import weblogic.security.SimpleCallbackHandler;

import weblogic.servlet.security.ServletAuthentication;

public class LoginBean {
    private RichInputText inputLogin, inputPassword;

    public LoginBean() {
        super();
    }

    public void setInputLogin(RichInputText inputLogin) {
        this.inputLogin = inputLogin;
    }

    public RichInputText getInputLogin() {
        return inputLogin;
    }

    public void setInputPassword(RichInputText inputPassword) {
        this.inputPassword = inputPassword;
    }

    public RichInputText getInputPassword() {
        return inputPassword;
    }

    public String loginAction() throws LoginException {
        String action = "";
        String un = "";
        byte[] pw = ("").getBytes();
        FacesContext ctx = FacesContext.getCurrentInstance();
        HttpServletRequest request =
            (HttpServletRequest)ctx.getExternalContext().getRequest();
        try {
            OperationBinding login = ADFUtils.findOperation("authenticateUser");
            Map m = (Map)login.execute();

            String fullName = (String)m.get("FullName");
            HashMap userAccess = (HashMap)m.get("UserAccess");
            String userPassword = (String)m.get("Password");
            String userNameLogin = (String)m.get("UserName");
            String userRole = (String)m.get("UserRole");
                
            un = userNameLogin;
            pw = (userPassword).getBytes();
            
            //CallbackHandler handler = new URLCallbackHandler(un, pw);
            CallbackHandler handler = new SimpleCallbackHandler(un, pw);
            Subject mySubject =
                weblogic.security.services.Authentication.login(handler);
            weblogic.servlet.security.ServletAuthentication.runAs(mySubject,
                                                                  request);
            
            ServletAuthentication.generateNewSessionID(request);
                UserData userData =
                    (UserData)JSFUtils.resolveExpression("#{UserData}");
                userData.setLoggedIn(Boolean.TRUE);
                userData.setFullName(fullName);
                userData.setUserAccess(userAccess);
                userData.setUserNameLogin(userNameLogin);
                userData.setUserPassword(userPassword);
                userData.setUserRole(userRole);

                OperationBinding _dashboardAMSession = ADFUtils.findOperation("setLoginToSession_DashboardAM");
                _dashboardAMSession.execute();

                String loginUrl =
                    "/adfAuthentication?success_url=/faces/dashboard.jspx";
                HttpServletResponse response =
                    (HttpServletResponse)ctx.getExternalContext().getResponse();
                sendForward(request, response, loginUrl);
                action = "success";
        } catch (FailedLoginException fle) {
            StringBuilder message = new StringBuilder("<html><body>");
            message.append("<p>Isian salah pada \"Username\" atau \"Password\".</p>");
            message.append("</body></html>");
            FacesMessage msg = new FacesMessage(message.toString());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            ctx.addMessage(null, msg);
        } catch (LoginException le) {
            FacesMessage msg = new FacesMessage(le.getMessage());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            ctx.addMessage(null, msg);
        } catch (Exception e) {
            FacesMessage msg = new FacesMessage(e.getLocalizedMessage());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            ctx.addMessage(null, msg);
        }
        return action;
    }

    private void sendForward(HttpServletRequest request,
                             HttpServletResponse response, String forwardUrl) {
        FacesContext ctx = FacesContext.getCurrentInstance();
        RequestDispatcher dispatcher =
            request.getRequestDispatcher(forwardUrl);
        try {
            dispatcher.forward(request, response);
        } catch (ServletException se) {
            reportUnexpectedLoginError("ServletException", se);
        } catch (IOException ie) {
            reportUnexpectedLoginError("IOException", ie);
        }
        ctx.responseComplete();
    }

    private void reportUnexpectedLoginError(String errType, Exception e) {
        FacesMessage msg =
            new FacesMessage(FacesMessage.SEVERITY_ERROR, "Unexpected error during login",
                             "Unexpected error during login (" + errType +
                             "), please consult logs for detail");
        FacesContext.getCurrentInstance().addMessage("d2:it35", msg);
        e.printStackTrace();
    }

    public String doLogout() {                                
        FacesContext fctx = FacesContext.getCurrentInstance();
        ExternalContext ectx = fctx.getExternalContext();
        HttpServletRequest req = (HttpServletRequest)ectx.getRequest();
        
        String url =
            ectx.getRequestContextPath() + "/adfAuthentication?logout=true&end_url=/faces/dashboard.jspx";
        try {
            ectx.redirect(url);
        } catch (IOException e) {
            e.printStackTrace();
        }
        fctx.responseComplete();
        return null;
    }
}
