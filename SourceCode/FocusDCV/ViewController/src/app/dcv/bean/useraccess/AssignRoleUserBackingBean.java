package app.dcv.bean.useraccess;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.List;

import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import oracle.adf.model.BindingContext;

import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;

import oracle.adf.share.ADFContext;

import oracle.binding.AttributeBinding;
import oracle.binding.BindingContainer;
import oracle.binding.OperationBinding;

import oracle.jbo.Row;

public class AssignRoleUserBackingBean implements Serializable {

    // Shuttle operations
    @SuppressWarnings("compatibility:4429120787595570625")
    private static final long serialVersionUID = 1L;
    List selectedRoles;
    List allRoles;
    Boolean refreshSelectedList = false;
    private final String SELECTED_ROLE_ITERATOR =
        "AppUserAccessRolesView1Iterator";
    private final String ALL_ROLE_ITERATOR = "AllRolesShuttleView1Iterator";
    
    public AssignRoleUserBackingBean() {
        super();
    }

    public BindingContainer getBindings() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    public void setSelectedRoles(List selectedRoles) {
        this.selectedRoles = selectedRoles;
    }

    public List getSelectedRoles() {

        if (selectedRoles == null || refreshSelectedList) {
            selectedRoles =
                    attributeListForIterator(SELECTED_ROLE_ITERATOR, "Role");
        }
        return selectedRoles;
    }

    public void setAllRoles(List allRoles) {
        this.allRoles = allRoles;
    }

    public List getAllRoles() {
        if (allRoles == null) {
            allRoles = selectItemsForIterator(ALL_ROLE_ITERATOR, "Name", "Label");
        }
        return allRoles;
    }

    public void refreshSelectedList(ValueChangeEvent e) {
        refreshSelectedList = true;
    }

    // Shuttle operations
    public static List attributeListForIterator(String iteratorName,
                                                String valueAttrName) {
        BindingContext bc = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bc.getCurrentBindingsEntry();
        DCIteratorBinding iter = binding.findIteratorBinding(iteratorName);
        List attributeList = new ArrayList();
        for (Row r : iter.getAllRowsInRange()) {
            attributeList.add(r.getAttribute(valueAttrName));
        }
        return attributeList;
    }

    public static List<SelectItem> selectItemsForIterator(String iteratorName,
                                                          String valueAttrName,
                                                          String displayAttrName) {
        BindingContext bc = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bc.getCurrentBindingsEntry();
        DCIteratorBinding iter = binding.findIteratorBinding(iteratorName);
        List<SelectItem> selectItems = new ArrayList<SelectItem>();
        for (Row r : iter.getAllRowsInRange()) {
            selectItems.add(new SelectItem(r.getAttribute(valueAttrName),
                                           (String)r.getAttribute(displayAttrName)));
        }
        return selectItems;
    }

    public String processShuttle() {
        FacesContext fctx = FacesContext.getCurrentInstance();
        String closeAfter = "close";
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iter =
            (DCIteratorBinding)binding.get(SELECTED_ROLE_ITERATOR);

        //Removing all rows
        for (Row r : iter.getAllRowsInRange()) {
            r.remove();
        }

        if (this.getSelectedRoles().size() > 0) {
            for (int i = 0; i < getSelectedRoles().size(); i++) {

                Row row = iter.getRowSetIterator().createRow();

                row.setNewRowState(Row.STATUS_INITIALIZED);
                row.setAttribute("UserName", this.getCurrentUserName());
                row.setAttribute("Role", getSelectedRoles().get(i));

                iter.getRowSetIterator().insertRow(row);
                iter.setCurrentRowWithKey(row.getKey().toStringFormat(true));

            }
        }
        
        String ok = doCommit();
        return closeAfter;
    }

    public String processCancel() {
        FacesContext fctx = FacesContext.getCurrentInstance();
        String closeAfter = "close";
        //String cancel = doRollback();
        return closeAfter;
    }

    public String doCommit() {
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        if (!operationBinding.getErrors().isEmpty()) {
            return null;
        }
        return null;
    }

    public String doRollback() {
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Rollback");
        operationBinding.execute();
        if (!operationBinding.getErrors().isEmpty()) {
            return null;
        }
        return null;
    }

    public String getCurrentUserName() {
        ADFContext adfCtx = ADFContext.getCurrent();
        Map pageFlowScope = adfCtx.getPageFlowScope();
        String userName = (String)pageFlowScope.get("userName");
        return userName;
    }
}
