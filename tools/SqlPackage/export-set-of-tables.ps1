SqlPackage                                 `
  /a:export                                `
  /sourceServerName:$srcServer             `
  /sourceDatabaseName:SqlPackageTestDb     `
  /targetFile:set-of-tables.bacpac         `
  /p:extractAllTableData=true              `
  /p:tableData=dbo.numbers                 `
  /p:tableData=dbo.words
