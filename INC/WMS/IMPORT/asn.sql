SELECT * FROM ;

SELECT DOWNLOAD_DATE_1,ERR_CODE, substr(shipment_nbr, 1, 2), shipment_nbr ,HDR.* FROM WMS_RCV_ASN_HDR HDR
--UPDATE WMS_RCV_ASN_HDR SET DOWNLOAD_DATE_1 = null, ERR_CODE = null
WHERE SHIPMENT_NBR = 'NAC000914640';
COMMIT;

SELECT ERR_CODE,PO_NBR, dtl.* FROM WMS_RCV_ASN_DTL dtl WHERE HDR_GROUP_NBR = 10038;
SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (120382,120139,120138);
SELECT * FROM pmgdtlee WHERE PMG_PO_NUMBER = 120382;

--Validacion OC
select d.PO_NBR, d.ERR_CODE, ocd.pmg_status, d.*
from wms_rcv_asn_dtl d
inner join pmgdtlee ocd on to_number(d.po_nbr) = ocd.pmg_po_number
inner join tpprdmst prd
on prd.prd_lvl_number = d.item_alternate_code
and prd.prd_lvl_child = ocd.prd_lvl_child
where d.hdr_group_nbr = 100380
and d.received_qty  > 0
and ocd.pmg_status  in (6, 7);

SELECT m.trf_manifest_id FROM TRFMFHEE m;
SELECT COUNT(1) FROM TRFMFHEE m WHERE trf_manifest_id LIKE 'OS%' ;
SELECT m.trf_manifest_id FROM TRFMFHEE m;
