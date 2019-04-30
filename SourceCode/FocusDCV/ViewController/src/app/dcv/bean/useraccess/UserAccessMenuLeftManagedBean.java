package app.dcv.bean.useraccess;

import oracle.adf.controller.TaskFlowId;

public class UserAccessMenuLeftManagedBean {
    private String manageUserTaskFlowId = "/WEB-INF/ua-manage-user.xml#ua-manage-user";
    private String manageMenuTaskFlowId = "/WEB-INF/ua-manage-menu.xml#ua-manage-menu";
    private String manageRoleTaskFlowId = "/WEB-INF/ua-manage-role.xml#ua-manage-role";
    private String currentTF = "main";

    public UserAccessMenuLeftManagedBean() {
    }

    public TaskFlowId getDynamicTaskFlowId() {
        if (this.getCurrentTF().equalsIgnoreCase("main"))
            return TaskFlowId.parse(manageUserTaskFlowId);
        else if (this.getCurrentTF().equalsIgnoreCase("menu"))
            return TaskFlowId.parse(manageMenuTaskFlowId);
        else if (this.getCurrentTF().equalsIgnoreCase("role"))
            return TaskFlowId.parse(manageRoleTaskFlowId);
        else
            return TaskFlowId.parse(manageUserTaskFlowId);
    } 

    public void setCurrentTF(String currentTF) {
        this.currentTF = currentTF;
    }

    public String getCurrentTF() {
        return currentTF;
    }
}
