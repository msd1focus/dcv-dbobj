package app.dcv.bean.useraccess;

import app.dcv.adfextensions.JSFUtils;


import app.dcv.bean.useraccessmenu.UserData;

import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

import oracle.adf.model.AttributeBinding;
import oracle.adf.model.BindingContext;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.input.RichInputText;

import oracle.binding.BindingContainer;
import oracle.binding.OperationBinding;

import oracle.jbo.JboException;

public class ChangePasswordBackingBean {
    private RichInputText newPassword;
    private RichInputText confirmPassword;
    private RichInputText oldPassword;
    private RichInputText userLoginName;

    public ChangePasswordBackingBean() {
        super();
    }

    public BindingContainer getBindings() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    public void setNewPassword(RichInputText newPassword) {
        this.newPassword = newPassword;
    }

    public RichInputText getNewPassword() {
        return newPassword;
    }

    public void setConfirmPassword(RichInputText confirmPassword) {
        this.confirmPassword = confirmPassword;
    }

    public RichInputText getConfirmPassword() {
        return confirmPassword;
    }

    public void setOldPassword(RichInputText oldPassword) {
        this.oldPassword = oldPassword;
    }

    public RichInputText getOldPassword() {
        return oldPassword;
    }

    public void setUserLoginName(RichInputText userLoginName) {
        this.userLoginName = userLoginName;
    }

    public RichInputText getUserLoginName() {
        return userLoginName;
    }

    public String changePassword() {
        BindingContainer bindings = getBindings();
        FacesContext fctx = FacesContext.getCurrentInstance();
        String action = null;
        String newPass = (String)newPassword.getValue();
        String oldPass = (String)oldPassword.getValue();
        String confPass = (String)confirmPassword.getValue();

        UserData userData =
            (UserData)JSFUtils.resolveExpression("#{UserData}");
        String currentPassword = userData.getUserPassword();

        String encPassword = currentPassword;
        String encOldPassword = oldPass;

        if (encPassword.equals(encOldPassword)) {
            if (newPass.equals(confPass)) {

                AttributeBinding userPass =
                    (AttributeBinding)bindings.getControlBinding("Password");
                userPass.setInputValue(newPass);

                try {
                    OperationBinding operationAddApproval =
                        bindings.getOperationBinding("changePassword");
                    operationAddApproval.execute();
                } catch (JboException e) {
                    JSFUtils.addFacesErrorMessage("Error", e.getBaseMessage());
                }

                ADFContext adfCtx = ADFContext.getCurrent();
                Map pageFlowScope = adfCtx.getPageFlowScope();
                pageFlowScope.put("usrPassChanged", "Y");

                action = "close";
            } else {
                FacesMessage msg =
                    new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                     "Confirmation password tidak sama.",
                                     "Confirmation password tidak sama.");
                fctx.addMessage(null, msg);
                action = null;
            }
        } else {
            FacesMessage msg =
                new FacesMessage(FacesMessage.SEVERITY_ERROR, "Password lama tidak sesuai.",
                                 "Password lama tidak sesuai.");
            fctx.addMessage(null, msg);
            action = null;
        }

        return action;
    }

    public String changePasswordReturnListener() {
        ADFContext adfCtx = ADFContext.getCurrent();
        Map pageFlowScope = adfCtx.getPageFlowScope();
        String passwordChanged = (String)pageFlowScope.get("usrPassChanged");
        if (passwordChanged.equalsIgnoreCase("Y")) {
            FacesContext fctx = FacesContext.getCurrentInstance();
            FacesMessage msg =
                new FacesMessage(FacesMessage.SEVERITY_WARN, "Password selesai diupdate. Lakukan login ulang untuk keamanan.",
                                 "Password selesai diupdate. Lakukan login ulang untuk keamanan.");
            fctx.addMessage(null, msg);
        }
        return null;
    }
}
