IF NOT FILE("CUSTOMERS.DBF")
CREATE TABLE Customers (Id integer AUTOINC, Name c(30), Active L, Location C(30))
ENDIF

_SCREEN.FontSize=16
_SCREEN.FontBold = .T.