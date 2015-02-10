#!/bin/bash

OLEUser="OLEUser"
OLEPW="OLEDBPassword"
OLEDB="OLEDB"

mysql -u ${OLEUser} -p${OLEPW} ${OLEDB} < bills.sql
mysql -u ${OLEUser} -p${OLEPW} ${OLEDB} < fees.sql
mysql -u ${OLEUser} -p${OLEPW} ${OLEDB} < payments.sql
mysql -u ${OLEUser} -p${OLEPW} ${OLEDB} < fees_seq.sql
