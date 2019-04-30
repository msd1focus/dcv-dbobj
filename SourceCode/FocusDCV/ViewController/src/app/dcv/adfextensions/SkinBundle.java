package app.dcv.adfextensions;

import java.util.ListResourceBundle;

public class SkinBundle extends ListResourceBundle {
    @Override
    public Object[][] getContents() {
      return _CONTENTS;
    }
  
    static private final Object[][] _CONTENTS = {
        {"af_panelCollection.DETACH_DIALOG_TITLE", "Full Screen"},
        {"af_panelCollection.LABEL_DETACH_TABLE_DLG", "Full Screen"},
        {"af_panelCollection.LABEL_MENUITEM_DETACH", "Full Screen"},
        {"af_panelCollection.TIP_BUTTON_DETACH", "Full Screen"},
        {"af_panelCollection.LABEL_MENUITEM_REDUCE", "Full Screen" }
    };
}
