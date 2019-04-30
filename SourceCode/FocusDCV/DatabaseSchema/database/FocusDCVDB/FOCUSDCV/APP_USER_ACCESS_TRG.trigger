<?xml version = '1.0' encoding = 'UTF-8'?>
<trigger xmlns="http://xmlns.oracle.com/jdeveloper/1111/offlinedb">
  <ID class="oracle.javatools.db.IdentifierBasedID">
    <identifier class="java.lang.String">dd1d0334-0d64-458b-8ea6-e081214c3790</identifier>
  </ID>
  <name>APP_USER_ACCESS_TRG</name>
  <baseType>TABLE</baseType>
  <code>BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_USER_ACCESS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
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
  <source>CREATE TRIGGER APP_USER_ACCESS_TRG 
BEFORE INSERT ON APP_USER_ACCESS 
FOR EACH ROW 
BEGIN
  &lt;&lt;COLUMN_SEQUENCES&gt;&gt;
  BEGIN
    IF :NEW.ID IS NULL THEN
      SELECT APP_USER_ACCESS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END;</source>
  <statementLevel>false</statementLevel>
  <tableID class="oracle.javatools.db.IdentifierBasedID">
    <name>APP_USER_ACCESS</name>
    <identifier class="java.lang.String">265ed33c-4d38-4649-b1f1-aca8671145ac</identifier>
    <schemaName>FOCUSPP</schemaName>
    <type>TABLE</type>
  </tableID>
  <timing>BEFORE</timing>
</trigger>
