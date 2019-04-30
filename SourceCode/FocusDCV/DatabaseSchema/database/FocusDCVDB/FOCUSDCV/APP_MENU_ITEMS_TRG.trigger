<?xml version = '1.0' encoding = 'UTF-8'?>
<trigger xmlns="http://xmlns.oracle.com/jdeveloper/1111/offlinedb">
  <ID class="oracle.javatools.db.IdentifierBasedID">
    <identifier class="java.lang.String">edf86403-1e69-4530-ad05-871653113050</identifier>
  </ID>
  <name>APP_MENU_ITEMS_TRG</name>
  <baseType>TABLE</baseType>
  <code>BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_MENU_ITEMS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;</code>
  <enabled>true</enabled>
  <events>
    <event>INSERT</event>
  </events>
  <schema>
    <name>FOCUSPP</name>
  </schema>
  <source>CREATE TRIGGER APP_MENU_ITEMS_TRG 
BEFORE INSERT ON APP_MENU_ITEMS 
FOR EACH ROW 
BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_MENU_ITEMS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;</source>
  <statementLevel>false</statementLevel>
  <tableID class="oracle.javatools.db.IdentifierBasedID">
    <name>APP_MENU_ITEMS</name>
    <identifier class="java.lang.String">99d03354-2d77-45c2-b367-a90605b6800f</identifier>
    <schemaName>FOCUSPP</schemaName>
    <type>TABLE</type>
  </tableID>
  <timing>BEFORE</timing>
</trigger>
