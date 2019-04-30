package app.dcv.bean.useraccess;

import app.dcv.adfextensions.ADFUtils;
import app.dcv.adfextensions.JSFUtils;
import app.dcv.model.am.UserAccessAMImpl;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.AttributeBinding;
import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.layout.RichPanelSplitter;
import oracle.adf.view.rich.component.rich.layout.RichShowDetailItem;
import oracle.adf.view.rich.component.rich.nav.RichCommandImageLink;
import oracle.adf.view.rich.component.rich.output.RichOutputText;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.event.ReturnPopupEvent;

import oracle.binding.BindingContainer;
import oracle.binding.OperationBinding;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

import org.apache.myfaces.trinidad.event.ReturnEvent;

public class UserAccessBean {

    private RichTable tblAssignedRole;
    private RichTable tblAssignedRegion;
    private RichTable tblAssignedMenuItems;
    private RichTable tblUserList;
    private RichTable tblRoleList;
    private RichInputText itUserPassword;
    private RichPanelSplitter psUserData;
    private RichTable tblAssignedArea;
    private RichTable tblAssignedLoc;
    private RichTable tblAssignedCust;
    private RichTable tblAssignedCustGroup;
    private RichShowDetailItem tabUserArea;
    private RichShowDetailItem tabUserRegion;
    private RichShowDetailItem tabUserLoc;
    private RichShowDetailItem tabUserCustGroup;
    private RichShowDetailItem tabUserCust;
    private UserAccessAMImpl userAccessAM =
        (UserAccessAMImpl)ADFUtils.getApplicationModuleForDataControl("UserAccessAMDataControl");
    private RichTable tblAssignedCustType;
    private RichShowDetailItem tabUserCustType;
    private RichInputText itCustAuthFlag;
    private static String custAuthRegion = "REGION";
    private static String custAuthArea = "AREA";
    private static String custAuthLocation = "LOCATION";
    private static String custAuthCustType = "CUSTTYPE";
    private static String custAuthCustGroup = "CUSTGROUP";
    private static String custAuthCustomer = "CUSTOMER";
    private RichTable tblUserProduk;
    private RichInputListOfValues itlovProdClass;
    private RichInputListOfValues itlovProdBrand;
    private RichInputListOfValues itlovProdExtention;
    private RichInputListOfValues itlovProdPackaging;
    private RichInputListOfValues itlovProdCategory;
    private RichCommandImageLink linkVariant;
    private RichInputText itProductItem;
    private RichCommandImageLink linkProduct;
    private RichInputText itVariant;
    private RichTable tblProdCategory;
    private RichShowDetailItem tabUserProdCategory;
    private RichShowDetailItem tabUserProdClass;
    private RichTable tblProdClass;
    private RichShowDetailItem tabUserProdBrand;
    private RichTable tblProdBrand;
    private RichShowDetailItem tabUserProdExt;
    private RichTable tblProdExt;
    private RichShowDetailItem tabUserProdPack;
    private RichTable tblProdPack;
    private RichShowDetailItem tabUserProdVariant;
    private RichTable tblProdVariant;
    private RichShowDetailItem tabUserProdItem;
    private RichTable tblProdItem;
    private RichOutputText itItemCanAdd;
    private RichPopup popupUserDivChange;
    private RichSelectOneChoice socUserDivision;

    public UserAccessBean() {
    }

    public BindingContainer getBindings() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    public void addRolePopupFetchListener(PopupFetchEvent popupFetchEvent) {
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("CreateInsert");
        operationBinding.execute();
    }

    public void addRoleDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();
        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("Role sudah ditambahkan");

        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void editRoleDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();
        AttributeBinding roleNameAttr =
            (AttributeBinding)bindings.getControlBinding("Name");
        String roleName = (String)roleNameAttr.getInputValue();
        if (roleName != null || !roleName.equalsIgnoreCase("")) {
            if (dialogEvent.getOutcome().name().equals("ok")) {
                OperationBinding operationBindingCommit =
                    bindings.getOperationBinding("Commit");
                operationBindingCommit.execute();

                JSFUtils.addFacesInformationMessage("Role \"" + roleNameAttr +
                                                    "\" sudah diupdate");

            } else {
                OperationBinding operationBinding =
                    bindings.getOperationBinding("Rollback");
                operationBinding.execute();
            }
        } else {
            JSFUtils.addFacesInformationMessage("Pilih terlebih dahulu role yang akan di edit");
        }
    }

    public void removeDialogListener(DialogEvent dialogEvent) {

        BindingContainer bindings = getBindings();
        AttributeBinding roleNameAttr =
            (AttributeBinding)bindings.getControlBinding("Name");
        String roleName = (String)roleNameAttr.getInputValue();

        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Delete");
            operationBinding.execute();
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("Role \"" + roleName +
                                                "\" sudah dihapus");

        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void editMenuDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();
        AttributeBinding roleNameAttr =
            (AttributeBinding)bindings.getControlBinding("Label");
        String roleName = (String)roleNameAttr.getInputValue();

        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("Menu \"" + roleNameAttr +
                                                "\" sudah diupdate");

        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void editMenuItemDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();
        AttributeBinding roleNameAttr =
            (AttributeBinding)bindings.getControlBinding("Label1");
        String roleName = (String)roleNameAttr.getInputValue();

        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("Menu Item \"" + roleNameAttr +
                                                "\" sudah diupdate");
        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void addUserDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();
        FacesContext ctx = FacesContext.getCurrentInstance();
        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            StringBuilder message = new StringBuilder("<html><body>");
            message.append("<p>User login aplikasi sudah ditambahkan.</p>");
            message.append("<p>Mohon dilengkapi kolom-kolom yang masih kosong.</p>");
            message.append("</body></html>");
            FacesMessage msg = new FacesMessage(message.toString());
            msg.setSeverity(FacesMessage.SEVERITY_INFO);
            ctx.addMessage(null, msg);
        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void addUserPopupFetchListener(PopupFetchEvent popupFetchEvent) {
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("CreateInsert");
        operationBinding.execute();
    }

    public void removeUserDialogListener(DialogEvent dialogEvent) {

        BindingContainer bindings = getBindings();
        AttributeBinding fullNameAttr =
            (AttributeBinding)bindings.getControlBinding("FullName");
        String fullName = (String)fullNameAttr.getInputValue();

        AttributeBinding userNameAttr =
            (AttributeBinding)bindings.getControlBinding("UserName");
        String userName = (String)userNameAttr.getInputValue();

        String msgName = fullName + "[" + userName + "]";

        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Delete");
            operationBinding.execute();
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("User \"" + msgName +
                                                "\" sudah dihapus");

        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void windowRoleReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("ExecuteRoles");
        operationBinding.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblAssignedRole);
    }

    public void setTblAssignedRole(RichTable tblAssignedRole) {
        this.tblAssignedRole = tblAssignedRole;
    }

    public RichTable getTblAssignedRole() {
        return tblAssignedRole;
    }

    public void setTblAssignedRegion(RichTable tblAssignedRegion) {
        this.tblAssignedRegion = tblAssignedRegion;
    }

    public RichTable getTblAssignedRegion() {
        return tblAssignedRegion;
    }

    public void windowMenuItemReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("ExecuteMit");
        operationBinding.execute();
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblAssignedMenuItems);
    }

    public void setTblAssignedMenuItems(RichTable tblAssignedMenuItems) {
        this.tblAssignedMenuItems = tblAssignedMenuItems;
    }

    public RichTable getTblAssignedMenuItems() {
        return tblAssignedMenuItems;
    }

    public void addUserPopupCanceledListener(PopupCanceledEvent popupCanceledEvent) {
        BindingContainer bindings = this.getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Rollback");
        operationBinding.execute();
        OperationBinding refreshUserList =
            bindings.getOperationBinding("Execute");
        refreshUserList.execute();
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblUserList);
        AdfFacesContext.getCurrentInstance().addPartialTarget(psUserData);
    }

    public void setTblUserList(RichTable tblUserList) {
        this.tblUserList = tblUserList;
    }

    public RichTable getTblUserList() {
        return tblUserList;
    }

    public void addRolePopupCanceledListener(PopupCanceledEvent popupCanceledEvent) {
        BindingContainer bindings = this.getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Rollback");
        operationBinding.execute();
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblRoleList);
    }

    public void setTblRoleList(RichTable tblRoleList) {
        this.tblRoleList = tblRoleList;
    }

    public RichTable getTblRoleList() {
        return tblRoleList;
    }

    public void resetPasswordPopupFetchListener(PopupFetchEvent popupFetchEvent) {
        itUserPassword.setValue("welcome1");
        AdfFacesContext.getCurrentInstance().addPartialTarget(itUserPassword);
    }

    public void resetPasswordDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = getBindings();

        AttributeBinding userNameAttr =
            (AttributeBinding)bindings.getControlBinding("UserName");
        String userName = (String)userNameAttr.getInputValue();
        
        FacesContext ctx = FacesContext.getCurrentInstance();
        if (dialogEvent.getOutcome().name().equals("ok")) {
            OperationBinding operationBindingCommit =
                bindings.getOperationBinding("Commit");
            operationBindingCommit.execute();

            JSFUtils.addFacesInformationMessage("Password user \"" + userName +
                                                "\" sudah direset");
        } else {
            OperationBinding operationBinding =
                bindings.getOperationBinding("Rollback");
            operationBinding.execute();
        }
    }

    public void setItUserPassword(RichInputText itUserPassword) {
        this.itUserPassword = itUserPassword;
    }

    public RichInputText getItUserPassword() {
        return itUserPassword;
    }

    public void setPsUserData(RichPanelSplitter psUserData) {
        this.psUserData = psUserData;
    }

    public RichPanelSplitter getPsUserData() {
        return psUserData;
    }

    public void setTblAssignedArea(RichTable tblAssignedArea) {
        this.tblAssignedArea = tblAssignedArea;
    }

    public RichTable getTblAssignedArea() {
        return tblAssignedArea;
    }

    public void setTblAssignedLoc(RichTable tblAssignedLoc) {
        this.tblAssignedLoc = tblAssignedLoc;
    }

    public RichTable getTblAssignedLoc() {
        return tblAssignedLoc;
    }

    public void setTblAssignedCust(RichTable tblAssignedCust) {
        this.tblAssignedCust = tblAssignedCust;
    }

    public RichTable getTblAssignedCust() {
        return tblAssignedCust;
    }

    public void setTblAssignedCustGroup(RichTable tblAssignedCustGroup) {
        this.tblAssignedCustGroup = tblAssignedCustGroup;
    }

    public RichTable getTblAssignedCustGroup() {
        return tblAssignedCustGroup;
    }

    public void setTabUserArea(RichShowDetailItem tabUserArea) {
        this.tabUserArea = tabUserArea;
    }

    public RichShowDetailItem getTabUserArea() {
        return tabUserArea;
    }

    public void setTabUserRegion(RichShowDetailItem tabUserRegion) {
        this.tabUserRegion = tabUserRegion;
    }

    public RichShowDetailItem getTabUserRegion() {
        return tabUserRegion;
    }

    public void setTabUserLoc(RichShowDetailItem tabUserLoc) {
        this.tabUserLoc = tabUserLoc;
    }

    public RichShowDetailItem getTabUserLoc() {
        return tabUserLoc;
    }

    public void setTabUserCustGroup(RichShowDetailItem tabUserCustGroup) {
        this.tabUserCustGroup = tabUserCustGroup;
    }

    public RichShowDetailItem getTabUserCustGroup() {
        return tabUserCustGroup;
    }

    public void setTabUserCust(RichShowDetailItem tabUserCust) {
        this.tabUserCust = tabUserCust;
    }

    public RichShowDetailItem getTabUserCust() {
        return tabUserCust;
    }

    public void setTblAssignedCustType(RichTable tblAssignedCustType) {
        this.tblAssignedCustType = tblAssignedCustType;
    }

    public RichTable getTblAssignedCustType() {
        return tblAssignedCustType;
    }

    public void setTabUserCustType(RichShowDetailItem tabUserCustType) {
        this.tabUserCustType = tabUserCustType;
    }

    public RichShowDetailItem getTabUserCustType() {
        return tabUserCustType;
    }

    public void sessionClearDialogListener(DialogEvent dialogEvent) {
        BindingContainer bindings = this.getBindings();

        AttributeBinding userNameAttr =
            (AttributeBinding)bindings.getControlBinding("UserName");
        String usrName = (String)userNameAttr.getInputValue();

        DCIteratorBinding dciterAppUserAccess = ADFUtils.findIterator("AppUserAccessView1Iterator");
        Key userAccessKey = dciterAppUserAccess.getCurrentRow().getKey();

        CallableStatement cst = null;
        try {
            cst =
        userAccessAM.getDBTransaction().createCallableStatement("BEGIN FCS_CLEAR_SESSION('" + usrName + "'); END;", 0);
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

        OperationBinding execUserAccess =
            bindings.getOperationBinding("Execute");
        execUserAccess.execute();
        
        dciterAppUserAccess.setCurrentRowWithKey(userAccessKey.toStringFormat(true));
    }

    public void setItCustAuthFlag(RichInputText itCustAuthFlag) {
        this.itCustAuthFlag = itCustAuthFlag;
    }

    public RichInputText getItCustAuthFlag() {
        return itCustAuthFlag;
    }

    public void addUserProduk(ActionEvent actionEvent) {
        BindingContainer bindings =
            BindingContext.getCurrent().getCurrentBindingsEntry();

        DCIteratorBinding dciter =
            (DCIteratorBinding)bindings.get("AppUserProdukView1Iterator");

        RowSetIterator rsi = dciter.getRowSetIterator();
        Row lastRow = rsi.last();
        int lastRowIndex = rsi.getRangeIndexOf(lastRow);
        Row newRow = rsi.createRow();
        newRow.setNewRowState(Row.STATUS_INITIALIZED);

        //add row to last index + 1 so it becomes last in the range set
        rsi.insertRowAtRangeIndex(lastRowIndex + 1, newRow);
        //make row the current row so it is displayed correctly
        rsi.setCurrentRow(newRow);

        AdfFacesContext.getCurrentInstance().addPartialTarget(tblUserProduk);
    }
    
    
    public void removeUserProduk(ActionEvent actionEvent) {
        String UserProdukIdSel = "";
        DCBindingContainer bindingsSelRow =
            (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding dcItteratorBindings =
            bindingsSelRow.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voTableDatasel = dcItteratorBindings.getViewObject();
        Row rowSelected = voTableDatasel.getCurrentRow();
        if (rowSelected.getAttribute("AppUserProdukId") != null) {
            UserProdukIdSel =
                    rowSelected.getAttribute("AppUserProdukId").toString();
            System.out.println("USER PROD ID : " + UserProdukIdSel);
        }
        
        /*
        DCIteratorBinding iterVar =
            ADFUtils.findIterator("ProdukVariantView1Iterator");
        for (Row r : iterVar.getAllRowsInRange()) {
            String idVar = r.getAttribute("PromoProdukId").toString();
            if (idVar.equalsIgnoreCase(PromoProdukIdSel)) {
                r.remove();
            }
        }
        iterVar.getDataControl().commitTransaction();

        DCIteratorBinding iterItem =
            ADFUtils.findIterator("ProdukItemView1Iterator");
        for (Row rItem : iterItem.getAllRowsInRange()) {
            String idItem = rItem.getAttribute("PromoProdukId").toString();
            if (idItem.equalsIgnoreCase(PromoProdukIdSel)) {
                rItem.remove();
            }
        }
        iterItem.getDataControl().commitTransaction();
        */

        DCIteratorBinding iterUserProduk = ADFUtils.findIterator("AppUserProdukView1Iterator");
        for (Row rUsrProd : iterUserProduk.getAllRowsInRange()) {
            String idUsrProd = rUsrProd.getAttribute("AppUserProdukId").toString();
            System.out.println("ROW ID USER PROD: " + idUsrProd);
            if (idUsrProd.equalsIgnoreCase(UserProdukIdSel)) {
                System.out.println("REMOVE : " + UserProdukIdSel + " | " + idUsrProd);
                rUsrProd.remove();
            }
        }
        iterUserProduk.getDataControl().commitTransaction();

        AdfFacesContext.getCurrentInstance().addPartialTarget(tblUserProduk);
    }

    public void setTblUserProduk(RichTable tblUserProduk) {
        this.tblUserProduk = tblUserProduk;
    }

    public RichTable getTblUserProduk() {
        return tblUserProduk;
    }

    public void productClassChanged(ValueChangeEvent valueChangeEvent) {
        // Add event code here...
    }

    public void productCategoryChanged(ValueChangeEvent valueChangeEvent) {
        // Add event code here...
    }

    public void productBrandChanged(ValueChangeEvent valueChangeEvent) {
        // Add event code here...
    }

    public void productExtentionChanged(ValueChangeEvent valueChangeEvent) {
        // Add event code here...
    }

    public void productPackagingChanged(ValueChangeEvent valueChangeEvent) {
        // Add event code here...
    }

    public void setItlovProdClass(RichInputListOfValues itlovProdClass) {
        this.itlovProdClass = itlovProdClass;
    }

    public RichInputListOfValues getItlovProdClass() {
        return itlovProdClass;
    }

    public void setItlovProdBrand(RichInputListOfValues itlovProdBrand) {
        this.itlovProdBrand = itlovProdBrand;
    }

    public RichInputListOfValues getItlovProdBrand() {
        return itlovProdBrand;
    }

    public void setItlovProdExtention(RichInputListOfValues itlovProdExtention) {
        this.itlovProdExtention = itlovProdExtention;
    }

    public RichInputListOfValues getItlovProdExtention() {
        return itlovProdExtention;
    }

    public void setItlovProdPackaging(RichInputListOfValues itlovProdPackaging) {
        this.itlovProdPackaging = itlovProdPackaging;
    }

    public RichInputListOfValues getItlovProdPackaging() {
        return itlovProdPackaging;
    }

    public void setItlovProdCategory(RichInputListOfValues itlovProdCategory) {
        this.itlovProdCategory = itlovProdCategory;
    }

    public RichInputListOfValues getItlovProdCategory() {
        return itlovProdCategory;
    }

    public void prodCategoryReturnPopupListener(ReturnPopupEvent returnPopupEvent) {
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            binding.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voPromoProduk = iterProduk.getViewObject();
        Row rowSelected = voPromoProduk.getCurrentRow();
        
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        
        iterProduk.executeQuery();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
    }

    public void prodClassReturnPopupListener(ReturnPopupEvent returnPopupEvent) {
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            binding.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voPromoProduk = iterProduk.getViewObject();
        Row rowSelected = voPromoProduk.getCurrentRow();
        
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        
        iterProduk.executeQuery();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
    }

    public void prodBrandReturnPopupListener(ReturnPopupEvent returnPopupEvent) {
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            binding.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voPromoProduk = iterProduk.getViewObject();
        Row rowSelected = voPromoProduk.getCurrentRow();
        
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        
        iterProduk.executeQuery();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
    }

    public void prodExtReturnPopupListener(ReturnPopupEvent returnPopupEvent) {
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            binding.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voPromoProduk = iterProduk.getViewObject();
        Row rowSelected = voPromoProduk.getCurrentRow();
        
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        
        iterProduk.executeQuery();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
    }

    public void prodPackReturnPopupListener(ReturnPopupEvent returnPopupEvent) {
        BindingContext bctx = BindingContext.getCurrent();
        DCBindingContainer binding =
            (DCBindingContainer)bctx.getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            binding.findIteratorBinding("AppUserProdukView1Iterator");
        ViewObject voPromoProduk = iterProduk.getViewObject();
        Row rowSelected = voPromoProduk.getCurrentRow();
        
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("Commit");
        operationBinding.execute();
        
        iterProduk.executeQuery();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
    }

    public void windowVariantReturnListener(ReturnEvent returnEvent) {
        String PromoProdukIdSel = "";
        DCBindingContainer bindingsSelRow =
            (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            bindingsSelRow.findIteratorBinding("PromoProdukView1Iterator");
        ViewObject voTableData = iterProduk.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        if (rowSelected.getAttribute("PromoProdukId") != null) {
            PromoProdukIdSel =
                    rowSelected.getAttribute("PromoProdukId").toString();
        }

        DCIteratorBinding dciterProdVariant = ADFUtils.findIterator("ProdukVariantView1Iterator");
        if (dciterProdVariant.getEstimatedRowCount() == 1) {
            RowSetIterator rsiProdVariant =
                dciterProdVariant.getRowSetIterator();
            Row prodVariantRow = rsiProdVariant.first();
            if (!prodVariantRow.getAttribute("ProdVariant").toString().equalsIgnoreCase("ALL")) {
                DCIteratorBinding dciterProdItem = ADFUtils.findIterator("ProdukItemView1Iterator");
                RowSetIterator rsiProdItem =
                    dciterProdItem.getRowSetIterator();
                for (Row prodItemRow : dciterProdItem.getAllRowsInRange()) {
                    String ppId =
                        prodItemRow.getAttribute("PromoProdukId").toString();
                    if (ppId.equalsIgnoreCase(PromoProdukIdSel)) {
                        prodItemRow.remove();
                        linkProduct.setVisible(false);
                        AdfFacesContext.getCurrentInstance().addPartialTarget(linkProduct);
                    }
                }
                rsiProdItem.closeRowSetIterator();
            } else {
                DCIteratorBinding dciterProdItem = ADFUtils.findIterator("ProdukItemView1Iterator");
                RowSetIterator rsiProdItem =
                    dciterProdItem.getRowSetIterator();
                for (Row prodItemRow : dciterProdItem.getAllRowsInRange()) {
                    String ppId =
                        prodItemRow.getAttribute("PromoProdukId").toString();
                    if (ppId.equalsIgnoreCase(PromoProdukIdSel)) {
                        rsiProdItem.closeRowSetIterator();
                        linkProduct.setVisible(true);
                        AdfFacesContext.getCurrentInstance().addPartialTarget(linkProduct);
                    }
                }
            }
        } else {
            DCIteratorBinding dciterProdItem = ADFUtils.findIterator("ProdukItemView1Iterator");
            RowSetIterator rsiProdItem = dciterProdItem.getRowSetIterator();
            for (Row prodItemRow : dciterProdItem.getAllRowsInRange()) {
                prodItemRow.remove();
            }
            rsiProdItem.closeRowSetIterator();
        }

        BindingContainer bindings = this.getBindings();
        OperationBinding operationBinding =
            bindings.getOperationBinding("ExecutePromoProduct");
        operationBinding.execute();

        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
        AdfFacesContext.getCurrentInstance().addPartialTarget(itVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(itProductItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(linkProduct);
    }

    public void windowItemReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();        
        DCBindingContainer bindingsSelRow =
            (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding iterProduk =
            bindingsSelRow.findIteratorBinding("PromoProdukView1Iterator");
        ViewObject voTableData = iterProduk.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        OperationBinding operationBinding =
            bindings.getOperationBinding("ExecutePromoProduct");
        operationBinding.execute();
        iterProduk.setCurrentRowWithKey(rowSelected.getKey().toStringFormat(true));
        AdfFacesContext.getCurrentInstance().addPartialTarget(itProductItem);
    }

    public void setLinkVariant(RichCommandImageLink linkVariant) {
        this.linkVariant = linkVariant;
    }

    public RichCommandImageLink getLinkVariant() {
        return linkVariant;
    }

    public void setItProductItem(RichInputText itProductItem) {
        this.itProductItem = itProductItem;
    }

    public RichInputText getItProductItem() {
        return itProductItem;
    }

    public void setLinkProduct(RichCommandImageLink linkProduct) {
        this.linkProduct = linkProduct;
    }

    public RichCommandImageLink getLinkProduct() {
        return linkProduct;
    }

    public void setItVariant(RichInputText itVariant) {
        this.itVariant = itVariant;
    }

    public RichInputText getItVariant() {
        return itVariant;
    }

    public void windowProdCategoryReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
         
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdClassReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdBrandReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdExtReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdPackReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdVariantReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(itItemCanAdd);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void windowProdItemReturnListener(ReturnEvent returnEvent) {
        BindingContainer bindings = this.getBindings();
        
        OperationBinding refreshCustTypeCategory =
            bindings.getOperationBinding("ExecuteProdCategory");
        refreshCustTypeCategory.execute();
        
        OperationBinding refreshCustTypeClass =
            bindings.getOperationBinding("ExecuteProdClass");
        refreshCustTypeClass.execute();
        
        OperationBinding refreshCustTypeBrand =
            bindings.getOperationBinding("ExecuteProdBrand");
        refreshCustTypeBrand.execute();
        
        OperationBinding refreshCustTypeExt =
            bindings.getOperationBinding("ExecuteProdExt");
        refreshCustTypeExt.execute();
        
        OperationBinding refreshCustTypePack =
            bindings.getOperationBinding("ExecuteProdPack");
        refreshCustTypePack.execute();
        
        OperationBinding refreshCustTypeVariant =
            bindings.getOperationBinding("ExecuteProdVariant");
        refreshCustTypeVariant.execute();
        
        OperationBinding refreshCustTypeItem =
            bindings.getOperationBinding("ExecuteProdItem");
        refreshCustTypeItem.execute();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdCategory);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdClass);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdBrand);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdExt);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdPack);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdVariant);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tblProdItem);
        AdfFacesContext.getCurrentInstance().addPartialTarget(tabUserProdItem);
    }

    public void setTblProdCategory(RichTable tblProdCategory) {
        this.tblProdCategory = tblProdCategory;
    }

    public RichTable getTblProdCategory() {
        return tblProdCategory;
    }

    public void setTabUserProdCategory(RichShowDetailItem tabUserProdCategory) {
        this.tabUserProdCategory = tabUserProdCategory;
    }

    public RichShowDetailItem getTabUserProdCategory() {
        return tabUserProdCategory;
    }

    public void setTabUserProdClass(RichShowDetailItem tabUserProdClass) {
        this.tabUserProdClass = tabUserProdClass;
    }

    public RichShowDetailItem getTabUserProdClass() {
        return tabUserProdClass;
    }

    public void setTblProdClass(RichTable tblProdClass) {
        this.tblProdClass = tblProdClass;
    }

    public RichTable getTblProdClass() {
        return tblProdClass;
    }

    public void setTabUserProdBrand(RichShowDetailItem tabUserProdBrand) {
        this.tabUserProdBrand = tabUserProdBrand;
    }

    public RichShowDetailItem getTabUserProdBrand() {
        return tabUserProdBrand;
    }

    public void setTblProdBrand(RichTable tblProdBrand) {
        this.tblProdBrand = tblProdBrand;
    }

    public RichTable getTblProdBrand() {
        return tblProdBrand;
    }

    public void setTabUserProdExt(RichShowDetailItem tabUserProdExt) {
        this.tabUserProdExt = tabUserProdExt;
    }

    public RichShowDetailItem getTabUserProdExt() {
        return tabUserProdExt;
    }

    public void setTblProdExt(RichTable tblProdExt) {
        this.tblProdExt = tblProdExt;
    }

    public RichTable getTblProdExt() {
        return tblProdExt;
    }

    public void setTabUserProdPack(RichShowDetailItem tabUserProdPack) {
        this.tabUserProdPack = tabUserProdPack;
    }

    public RichShowDetailItem getTabUserProdPack() {
        return tabUserProdPack;
    }

    public void setTblProdPack(RichTable tblProdPack) {
        this.tblProdPack = tblProdPack;
    }

    public RichTable getTblProdPack() {
        return tblProdPack;
    }

    public void setTabUserProdVariant(RichShowDetailItem tabUserProdVariant) {
        this.tabUserProdVariant = tabUserProdVariant;
    }

    public RichShowDetailItem getTabUserProdVariant() {
        return tabUserProdVariant;
    }

    public void setTblProdVariant(RichTable tblProdVariant) {
        this.tblProdVariant = tblProdVariant;
    }

    public RichTable getTblProdVariant() {
        return tblProdVariant;
    }

    public void setTabUserProdItem(RichShowDetailItem tabUserProdItem) {
        this.tabUserProdItem = tabUserProdItem;
    }

    public RichShowDetailItem getTabUserProdItem() {
        return tabUserProdItem;
    }

    public void setTblProdItem(RichTable tblProdItem) {
        this.tblProdItem = tblProdItem;
    }

    public RichTable getTblProdItem() {
        return tblProdItem;
    }

    public void setItItemCanAdd(RichOutputText itItemCanAdd) {
        this.itItemCanAdd = itItemCanAdd;
    }

    public RichOutputText getItItemCanAdd() {
        return itItemCanAdd;
    }

    public void socUserDivisionValueChangeListener(ValueChangeEvent vce) {
        Integer oldValue = (Integer)vce.getOldValue();
        Integer newValue = (Integer)vce.getNewValue();
        
//        AttributeBinding ads = (AttributeBinding)BindingContext.getCurrent().getCurrentBindingsEntry().getControlBinding("UserDivision");
//        System.out.println(ads.getInputValue().toString());
        
        RichPopup.PopupHints hints = new RichPopup.PopupHints();
        popupUserDivChange.show(hints);
        
        
    }

    public void setPopupUserDivChange(RichPopup popupUserDivChange) {
        this.popupUserDivChange = popupUserDivChange;
    }

    public RichPopup getPopupUserDivChange() {
        return popupUserDivChange;
    }

    public void userDivisionChangedDialogListenerMethod(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == DialogEvent.Outcome.ok) {
            String currusername = ((AttributeBinding)BindingContext.getCurrent().getCurrentBindingsEntry().getControlBinding("UserName")).getInputValue().toString();
            String newuserdivision = ((AttributeBinding)BindingContext.getCurrent().getCurrentBindingsEntry().getControlBinding("UserDivision")).getInputValue().toString();
            //System.out.println(currusername + " " + newuserdivision);
            try {
                UserAccessAMImpl uaAM = (UserAccessAMImpl)ADFUtils.getApplicationModuleForDataControl("UserAccessAMDataControl");
                //delete all ____ from currusername
                //delete all item
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_ITEM WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all variant
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_VARIANT WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all pack
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_PACK WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all ext
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_EXT WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all brand
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_BRAND WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all class
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_CLASS WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                //delete all category
                {
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("DELETE FROM APP_USER_PRODUK_CATEGORY WHERE USER_NAME = '" + currusername + "'", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                if (newuserdivision.equals("1")) {
                    //insert food to app_user_produk_category with currusername
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("INSERT INTO APP_USER_PRODUK_CATEGORY (USER_NAME, PROD_CATEGORY, CATEGORY_DESC) VALUES ('" + currusername + "', 'CT001', 'Food')", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                else if (newuserdivision.equals("2")) {
                    //insert nonfood to app_user_produk_category with currusername
                    PreparedStatement st = uaAM.getDBTransaction().createPreparedStatement("INSERT INTO APP_USER_PRODUK_CATEGORY (USER_NAME, PROD_CATEGORY, CATEGORY_DESC) VALUES ('" + currusername + "', 'CT002', 'Non Food')", 1);
                    try {
                        st.execute();
                    } finally {
                        st.close();
                    }
                }
                else if (newuserdivision.equals("0")) {
                    //insert food to app_user_produk_category with currusername
                    PreparedStatement stFood = uaAM.getDBTransaction().createPreparedStatement("INSERT INTO APP_USER_PRODUK_CATEGORY (USER_NAME, PROD_CATEGORY, CATEGORY_DESC) VALUES ('" + currusername + "', 'CT001', 'Food')", 1);
                    try {
                        stFood.execute();
                    } finally {
                        stFood.close();
                    }
                    
                    //insert nonfood to app_user_produk_category with currusername
                    PreparedStatement stNonFood = uaAM.getDBTransaction().createPreparedStatement("INSERT INTO APP_USER_PRODUK_CATEGORY (USER_NAME, PROD_CATEGORY, CATEGORY_DESC) VALUES ('" + currusername + "', 'CT002', 'Non Food')", 1);
                    try {
                        stNonFood.execute();
                    } finally {
                        stNonFood.close();
                    }
                }
                BindingContext.getCurrent().getCurrentBindingsEntry().getOperationBinding("Commit").execute();
            } catch (Exception e) {
                JSFUtils.addFacesErrorMessage(e.getMessage());
            }
        }
        else {
            BindingContext.getCurrent().getCurrentBindingsEntry().getOperationBinding("Rollback").execute();
        }
        AdfFacesContext.getCurrentInstance().addPartialTarget(socUserDivision);
        windowProdCategoryReturnListener(null);
    }

    public void setSocUserDivision(RichSelectOneChoice socUserDivision) {
        this.socUserDivision = socUserDivision;
    }

    public RichSelectOneChoice getSocUserDivision() {
        return socUserDivision;
    }
}
