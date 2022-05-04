## SSRS Colour Coded Occupancy Report

### SQL Statement
    Rank() and Row_Number() functions used to expand matrix
    The /20 and %20 specify number of rows and both must be same value
    Case provides True/False for occupancy

### Report
    Insert a matrix
    Add RowID as Column Group and RowNum as Row Group
    Delete leftmost column and uppermost row
    Add [Name] in the remaining block
 
### Colouring
    Right click on [Name] block and select TextBox Properties
    Go to "Fill" and select Fx and type in =IIf(Fields!Occupied.Value = 1,"Yellow","Transparent")

### Useful Links
    https://social.msdn.microsoft.com/Forums/sqlserver/en-US/2d41e2b7-c6a0-42eb-a2b3-5551a7ef8d0d/ssrs-transform-a-single-column-into-multiple-columns?forum=sqlreportingservices
    https://www.sqlservercentral.com/articles/conditional-formatting-with-ssrs
