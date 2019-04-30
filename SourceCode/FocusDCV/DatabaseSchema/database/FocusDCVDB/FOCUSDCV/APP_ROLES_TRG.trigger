<?xml version = '1.0' encoding = 'UTF-8'?>
<trigger xmlns="http://xmlns.oracle.com/jdeveloper/1111/offlinedb">
  <ID class="oracle.javatools.db.IdentifierBasedID">
    <identifier class="java.lang.String">43168406-9446-4d89-a4a5-29926aa549a9</identifier>
  </ID>
  <name>APP_ROLES_TRG</name>
  <baseType>TABLE</baseType>
  <code>BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_ROLES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
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
  <source>CREATE TRIGGER APP_ROLES_TRG 
BEFORE INSERT ON APP_ROLES 
FOR EACH ROW 
BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_ROLES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;</source>
  <statementLevel>false</statementLevel>
  <tableID class="oracle.javatools.db.IdentifierBasedID">
    <name>APP_ROLES</name>
    <identifier class="java.lang.String">539899af-873e-4a11-ad7d-78d9fa4482c5</identifier>
    <schemaName>FOCUSPP</schemaName>
    <type>TABLE</type>
  </tableID>
  <timing>BEFORE</timing>
</trigger>
