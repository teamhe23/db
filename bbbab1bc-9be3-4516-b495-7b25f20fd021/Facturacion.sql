select * from EDSRCT2.piv_trx_bct_head  where HEADID IN (55) ;
select PPLSERIALNUMBER, FLGPPL,PPL_RET_CODE,PPL_RET_MESSAGE from EDSRCT2.piv_trx_bct_head  where HEADID IN (55) ;

/*
UPDATE EDSRCT2.piv_trx_bct_head
SET FLGPPL = 0, PPL_RET_CODE = 1
WHERE HEADID IN (55)
*/