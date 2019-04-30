package app.dcv.bean.useraccessmenu;

import app.dcv.adfextensions.ADFUtils;
import app.dcv.adfextensions.JSFUtils;
import app.dcv.model.am.SecurityAMImpl;

import app.dcv.model.views.useraccessmenu.MenuItemsViewImpl;
import app.dcv.model.views.useraccessmenu.MenuItemsViewRowImpl;
import app.dcv.model.views.useraccessmenu.UserAccessRolesViewImpl;

import app.dcv.model.views.useraccessmenu.UserAccessRolesViewRowImpl;

import java.io.IOException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.MethodExpression;

import javax.faces.application.Application;
import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.PhaseEvent;

import javax.servlet.http.HttpServletResponse;

import oracle.adf.view.rich.component.rich.RichMenu;
import oracle.adf.view.rich.component.rich.RichMenuBar;
import oracle.adf.view.rich.component.rich.nav.RichCommandMenuItem;

public class MenuBean {

    private RichMenuBar initMenu;

    public void createMenus(PhaseEvent phaseEvent) {  
             
        FacesContext ctx = FacesContext.getCurrentInstance();
        // check the menu is already added
        boolean addMenu = true;
        for (Iterator iterator = initMenu.getChildren().iterator();
             iterator.hasNext(); ) {
            UIComponent component = (UIComponent)iterator.next();
            if (component.getId().startsWith("menuId")) {
                addMenu = false;
            }
        }
        if (addMenu) {

            //Get user data
            UserData userData =
                (UserData)JSFUtils.resolveExpression("#{UserData}");
            String userNameLogin = userData.getUserNameLogin();

            // List user roles
            List roles = new ArrayList();

            // Get menu application module
            SecurityAMImpl securityModule =
                (SecurityAMImpl)ADFUtils.getApplicationModuleForDataControl("SecurityAMDataControl");

            // Get role by user access
            UserAccessRolesViewImpl roleView;
            roleView = securityModule.getUserAccessRolesView1();
            roleView.setNamedWhereClauseParam("userNameLogin", userNameLogin);
            roleView.executeQuery();
            
            if (roleView.getEstimatedRowCount() > 0) {

                while (roleView.hasNext()) {
                    UserAccessRolesViewRowImpl roleName =
                        (UserAccessRolesViewRowImpl)roleView.next();
                    roles.add(roleName.getRole());
                }

                // Get menu items
                MenuItemsViewImpl menuView;
                menuView =
                        (MenuItemsViewImpl)securityModule.getMenuItemsView1();
                menuView.setNamedWhereClauseParam("usrNameLogin",
                                                  userNameLogin);
                menuView.executeQuery();

                RichMenu menu = new RichMenu();
                while (menuView.hasNext()) {
                    MenuItemsViewRowImpl menuItem =
                        (MenuItemsViewRowImpl)menuView.next();

                    // check if the user has this role
                    boolean roleFound = false;

                    for (int i = 0; i < roles.size(); i++) {
                        if (roles.get(i).equals(menuItem.getRolesName())) {
                            roleFound = true;
                        }
                    }

                    if (roleFound) {
                        Boolean menuFound = false;
                        String menuId =
                            "menuId" + menuItem.getMenId().toString();
                        // check if the main menu is already added
                        for (Iterator iterator =
                             initMenu.getChildren().iterator();
                             iterator.hasNext(); ) {
                            UIComponent component =
                                (UIComponent)iterator.next();
                            if (component.getId().equalsIgnoreCase(menuId)) {
                                menuFound = true;
                                menu = (RichMenu)component;
                            }
                        }
                        if (!menuFound) {
                            // new main menu
                            RichMenu newMenu = new RichMenu();
                            newMenu.setId(menuId);
                            // Menu label
                            newMenu.setText(menuItem.getMenuLabel());
                            newMenu.setIcon(menuItem.getMenuIcon());
                            newMenu.setShortDesc(menuItem.getMenuShortcut());
                            initMenu.getChildren().add(newMenu);
                            menu = newMenu;
                        }

                        Boolean menuItemFound = false;
                        String menuItemId = menuItem.getName();

                        // check if the menu item is already added
                        for (Iterator iterator = menu.getChildren().iterator();
                             iterator.hasNext(); ) {
                            UIComponent component =
                                (UIComponent)iterator.next();
                            if (component.getId().equalsIgnoreCase(menuItemId)) {
                                menuItemFound = true;
                            }
                        }
                        if (!menuItemFound) {
                            RichCommandMenuItem richMenuItem =
                                new RichCommandMenuItem();
                            richMenuItem.setId(menuItemId);
                            // Menu item label
                            richMenuItem.setText(menuItem.getLabel());
                            richMenuItem.setActionExpression(getMethodExpression(menuItem.getAction()));
                            richMenuItem.setIcon(menuItem.getIcon());
                            richMenuItem.setShortDesc(menuItem.getShortcut());
                            menu.getChildren().add(richMenuItem);
                        }
                    }
                }
                menuView.remove();
            } else {
                FacesMessage msg =
                    new FacesMessage(FacesMessage.SEVERITY_WARN, "This account doesnt have any role.",
                                     "No role(s) attached into this account. Please contact your application admin.");
                ctx.addMessage(null, msg);
            }
        }
    }

    public void setInitMenu(RichMenuBar initMenu) {
        this.initMenu = initMenu;
    }

    public RichMenuBar getInitMenu() {
        return initMenu;
    }

    private MethodExpression getMethodExpression(String name) {
        Class[] argtypes = new Class[1];
        argtypes[0] = ActionEvent.class;
        FacesContext facesCtx = FacesContext.getCurrentInstance();
        Application app = facesCtx.getApplication();
        ExpressionFactory elFactory = app.getExpressionFactory();
        ELContext elContext = facesCtx.getELContext();
        return elFactory.createMethodExpression(elContext, name, null,
                                                argtypes);
    }

    public String goHome() throws IOException {
        ExternalContext ectx =
            FacesContext.getCurrentInstance().getExternalContext();
        HttpServletResponse response = (HttpServletResponse)ectx.getResponse();
        String url = ectx.getRequestContextPath() + "/faces/dashboard.jspx";
        try {
            response.sendRedirect(url);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

}
