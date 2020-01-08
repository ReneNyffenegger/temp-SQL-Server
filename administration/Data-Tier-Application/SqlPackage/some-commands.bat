@echo off

sqlPackage.exe                          ^
  /action:extract                       ^
  /sourceServerName:SrvFrom\Inst        ^
  /sourceDatabaseName:DBFrom            ^
  /targetFile:extract.dacpac            ^
  /p:extractAllTableData=true

rem  /p:ExtractReferencedServerScopedElements=false ^

if %errorlevel% neq 0 (
   echo "extraction failed"
   exit /b
)

rem sqlPackage.exe                          ^
rem   /action:export                        ^
rem   /sourceServerName:SrvFrom\Inst ^
rem   /sourceDatabaseName:DBFrom    ^
rem   /targetFile:export.bacbac             ^
rem   /p:extractAllTableData=true
rem 
rem if %errorlevel% neq 0 (
rem   echo "extraction failed"
rem   exit /b
rem )

rem sqlPackage.exe                          ^
rem   /action:import                        ^
rem   /sourceFile:export.bacbac             ^
rem   /targetDatabaseName:DbTo    ^
rem   /targetServerName:SrvDest\Inst

sqlPackage.exe                          ^
  /action:script                        ^
  /sourceFile:extract.dacpac            ^
  /DeployScriptPath:createDatabase.sql  ^
  /targetServerName:SrvDest\Inst        ^
  /targetDatabaseName:DbTo              ^
  /p:createNewDatabase=true

rem  /targetFile:extract.dacpac                 ^

rem sqlPackage.exe                              ^
rem   /action:publish                           ^
rem   /sourceFile:extract.dacpac                ^
rem   /targetDatabaseName:DbTo                  ^
rem   /targetServerName:SrvDest\Inst            ^
rem   /p:createNewDatabase=true                 ^
rem   /p:TreatVerificationErrorsAsWarnings=true ^
rem   /p:verifyDeployment=true 


if %errorlevel% neq 0 (
    echo "creation of script failed"
    exit /b
)
  
sqlcmd -S SrvDest\Inst -i createDatabase.sql -V 20
