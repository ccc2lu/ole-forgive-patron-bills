#!/bin/bash

OLEUser="OLEUser"
OLEPW="OLEDBPassword"
OLEDB="OLEDB"

mysqldump -u ${OLEUser} -p${OLEPW} ${OLEDB} ole_dlvr_ptrn_bill_t > bills.sql
mysqldump -u ${OLEUser} -p${OLEPW} ${OLEDB} ole_dlvr_ptrn_bill_fee_typ_t > fees.sql
mysqldump -u ${OLEUser} -p${OLEPW} ${OLEDB} ole_dlvr_ptrn_bill_pay_t > payments.sql
mysqldump -u ${OLEUser} -p${OLEPW} ${OLEDB} ole_dlvr_ptrn_bill_fee_typ_s > fees_seq.sql
