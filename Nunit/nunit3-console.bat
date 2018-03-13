@echo off 
SET "var=%*"
CALL SET var=%%var:-xml=--result%%
CALL SET var=%%var:.xml=.xml;format=nunit2%%

%~dp0\nunit3-console.exe %var%