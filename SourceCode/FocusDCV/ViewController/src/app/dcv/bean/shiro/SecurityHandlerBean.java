package app.dcv.bean.shiro;

import app.dcv.adfextensions.ADFUtils;
import app.dcv.adfextensions.JSFUtils;
import app.dcv.bean.useraccessmenu.UserData;

import app.dcv.model.am.SecurityAMImpl;

import java.io.IOException;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;

import java.sql.CallableStatement;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.UsernamePasswordToken;
import sun.misc.BASE64Encoder;
import javax.servlet.http.HttpServletResponse;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.binding.OperationBinding;

public class SecurityHandlerBean {
    private String userName;
    private String password;
    private String encpassword;
    private RichInputText inputLogin, inputPassword;
    private boolean remember;
    public static final String HOME_URL = "/faces/dashboard.jspx";
    public static final String LOGIN_URL = "slogin.jspx";
    public static final String PASS_THRU_USER_ADMIN = "admin";
    
    public SecurityHandlerBean() {
    }
    
    public String login() {
        try {
            //encpassword=getKeyDigestString(password,null);
            encpassword=password;
            SecurityUtils.getSubject().login(new UsernamePasswordToken(userName, encpassword, remember));
            
            // PPPC Application Data Session
            OperationBinding login = ADFUtils.findOperation("authenticateUser");
            Map m = (Map)login.execute();
            
            String fullName = (String)m.get("FullName");
            HashMap userAccess = (HashMap)m.get("UserAccess");
            String userPassword = (String)m.get("Password");
            String userNameLogin = (String)m.get("UserName");
            String userRole = (String)m.get("UserRole");
            String userLogged = (String)m.get("UserLogged");
            String sessionTime = (String)m.get("SessionTime");
            
            HttpServletRequest request =
            (HttpServletRequest)(FacesContext.getCurrentInstance().getExternalContext().getRequest());
            ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
                
            String ipAddress = request.getHeader("X-FORWARDED-FOR");  
            if (ipAddress == null) {  
                ipAddress = request.getRemoteAddr(); 
            }
            
            /*
            if (savedRequest != null) {
                System.out.println("***SavedRequest URL:" + savedRequest.getRequestUrl());
            }
            */
            //externalContext.redirect(savedRequest != null ? savedRequest.getRequestUrl() : HOME_URL);
        
            boolean sessionValid = true;
            StringBuilder messageSes = new StringBuilder("<html><body>");
            if (userLogged != null && userLogged.equalsIgnoreCase(userNameLogin) && !userLogged.equalsIgnoreCase(PASS_THRU_USER_ADMIN)) {
                messageSes.append("<p>&nbsp;&nbsp;&nbsp;&nbsp;Username <b>" + userNameLogin + "</b> sedang dalam sesi aktif / digunakan oleh user.&nbsp;&nbsp;&nbsp;&nbsp;</p>");
                messageSes.append("<p>&nbsp;&nbsp;&nbsp;&nbsp;Pastikan username tidak sedang digunakan oleh orang lain,</br>");
                messageSes.append("&nbsp;&nbsp;&nbsp;&nbsp;atau apabila username tidak dipergunakan oleh orang lain,</br>");
                messageSes.append("&nbsp;&nbsp;&nbsp;&nbsp;tunggu <b>" + sessionTime + " menit</b> supaya username login dapat dipergunakan kembali.&nbsp;&nbsp;&nbsp;&nbsp;</p>");
                sessionValid = false;
            } else {
                sessionValid = true;
            }
            messageSes.append("</body></html>");
            
            if (sessionValid) {
                
                UserData userData =
                  (UserData)JSFUtils.resolveExpression("#{UserData}");
                userData.setLoggedIn(Boolean.TRUE);
                userData.setFullName(fullName);
                String fullNameSub = null;
                if (fullName.length() > 16) {
                    List<String> nameList = new ArrayList<String>(Arrays.asList(fullName.split(" ")));
                    int nameSize = nameList.size();
                    if (nameSize > 1) {
                        fullNameSub = nameList.get(0) + " " + nameList.get(1);
                    } else {
                        fullNameSub = nameList.get(0);
                    }
                } else {
                    fullNameSub = fullName;
                }
                userData.setUserAccess(userAccess);
                userData.setUserNameLogin(userNameLogin);
                userData.setUserPassword(userPassword);
                userData.setUserRole(userRole);
                
                OperationBinding _dashboardAMSession = ADFUtils.findOperation("setLoginToSession_DashboardAM");
                _dashboardAMSession.execute();

                externalContext.redirect( request.getContextPath()+HOME_URL);

                SecurityAMImpl securityAM =
                    (SecurityAMImpl)ADFUtils.getApplicationModuleForDataControl("SecurityAMDataControl");
                CallableStatement cst = null;
                try {
                    cst =
                securityAM.getDBTransaction().createCallableStatement("BEGIN FCS_LOGIN_BEAT('" + userNameLogin + "', 'INITIAL LOGIN " + userNameLogin + "'); END;", 0);
                    cst.executeUpdate();
                } catch (SQLException e) {
                    JSFUtils.addFacesErrorMessage(e.getMessage());
                } finally {
                    if (cst != null) {
                        try {
                            cst.close();
                        } catch (SQLException e) {
                            //e.printStackTrace();
                        }
                    }
                }
            } else {
                FacesMessage msg = new FacesMessage(messageSes.toString());
                msg.setSeverity(FacesMessage.SEVERITY_ERROR);
                FacesContext.getCurrentInstance().addMessage(null, msg);
            }
        } catch (Exception e) {        
            StringBuilder message = new StringBuilder("<html><body>");
            message.append("<p>Isian salah pada \"Username\" atau \"Password\".</p>");
            message.append("</body></html>");
            FacesMessage msg = new FacesMessage(message.toString());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            FacesContext.getCurrentInstance().addMessage(null, msg);
        }
        return "";
    }

    String getAbsoluteApplicationUrl() throws Exception {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        HttpServletRequest request = (HttpServletRequest)externalContext.getRequest();
        URL url = new URL(request.getRequestURL().toString());
        URL newUrl = new URL(url.getProtocol(), url.getHost(), url.getPort(), request.getContextPath());
        return newUrl.toString();
    }
    
    public String logout_action()throws IOException {
        SecurityUtils.getSubject().logout();
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        HttpServletResponse response = (HttpServletResponse)externalContext.getResponse();
        HttpServletRequest req = (HttpServletRequest)externalContext.getRequest();
        //externalContext.invalidateSession();
        externalContext.redirect(LOGIN_URL);
        try {
            response.sendRedirect((new StringBuilder()).append(req.getContextPath()).append("/faces/dashboard.jspx").toString());
            FacesContext.getCurrentInstance().responseComplete();
        } catch (IOException e) {
            FacesMessage msg = new FacesMessage(e.getLocalizedMessage());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            FacesContext.getCurrentInstance().addMessage(null, msg);
        }       
        return null;               
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getPassword() {
        return password;
    }
    public void setRemember(boolean remember) {
        this.remember = remember;
    }
    public boolean isRemember() {
        return remember;
    }
    public String getKeyDigestString(String message, String key) throws NoSuchProviderException {
        try {
            String pwCompareStr = "";
            byte[] messageByte = message.getBytes();
            // if no key is provided, the message string gets encrypted with itself
            byte[] keyByte = (key != null && key.length() > 0) ? key.getBytes() : message.getBytes();
            // get SHA1 instance      
            MessageDigest sha1 = MessageDigest.getInstance("SHA-1", "SUN");
            sha1.update(messageByte);
           
            //byte[] digestByte = sha1.digest(keyByte);
            byte[] digestByte = sha1.digest();

            // base 64 encoding
            BASE64Encoder b64Encoder = new BASE64Encoder();
            pwCompareStr = (b64Encoder.encode(digestByte));
            pwCompareStr = new StringBuilder("{SHA-1}").append(pwCompareStr).toString();
            return pwCompareStr;
        } catch (NoSuchAlgorithmException e) {
            FacesMessage msg = new FacesMessage(e.getLocalizedMessage());
            msg.setSeverity(FacesMessage.SEVERITY_ERROR);
            FacesContext.getCurrentInstance().addMessage(null, msg);
        }
        return null;
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
}
