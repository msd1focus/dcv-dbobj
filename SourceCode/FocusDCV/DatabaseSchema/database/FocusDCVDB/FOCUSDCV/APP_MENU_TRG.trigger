<?xml version = '1.0' encoding = 'UTF-8'?>
<trigger xmlns="http://xmlns.oracle.com/jdeveloper/1111/offlinedb">
  <ID class="oracle.javatools.db.IdentifierBasedID">
    <identifier class="java.lang.String">6b3ec1ea-258b-434e-9c82-cad1ad8fd43c</identifier>
  </ID>
  <name>APP_MENU_TRG</name>
  <baseType>TABLE</baseType>
  <code>BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_MENU_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
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
  <source>CREATE TRIGGER APP_MENU_TRG 
BEFORE INSERT ON APP_MENU 
FOR EACH ROW 
BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_MENU_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;</source>
  <statementLevel>false</statementLevel>
  <tableID class="oracle.javatools.db.IdentifierBasedID">
    <name>APP_MENU</name>
    <identifier class="java.lang.String">5c8ffafe-8e74-431f-a684-2a1a29e55b78</identifier>
    <schemaName>FOCUSPP</schemaName>
    <type>TABLE</type>
  </tableID>
  <timing>BEFORE</timing>
</trigger>
