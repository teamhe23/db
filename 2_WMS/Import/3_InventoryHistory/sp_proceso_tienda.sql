--  procedure sp_proceso_tienda
  --is
  --------------------------------------------------------------------------------------
  --  AUTOR :
  --  FECHA :
  --          Proceso inserta movimientos de inventario en PMM a partir de la interface
  --          inventory_history de WMS. Los registros son procesados segun el Mapeo de PIX.
  --
  --  PROYECTO :  IMPLEMENTACION SISTEMA WMS
  --
  --  PARAMS:
  --
  --  HISTORIA DE MODIFICACION :
  --  --------------------------
  --
  --  Id     Fecha     Autor     Descripción del cambio
  --
  --------------------------------------------------------------------------------------
DECLARE
    cursor c_mov_inv is
      select i.rowid id_reg,
             i.group_nbr,
             i.seq_nbr,
             i.company_code,
             i.activity_code,
             i.reason_code,
             i.ref_value_1,
             i.ref_value_2,
             i.item_part_a prd_lvl_number,
             nvl(nvl(i.adj_qty, i.orig_qty),0) adj_qty,
             i.order_nbr,
             i.create_date  trans_date,
             i.shipment_nbr,
             i.lpn_nbr,
             i.lock_code,
             i.facility_code
       from wms_inv_history i
       where i.download_date_1 is null
         and i.err_code is null
         and i.create_date_int >= trunc(sysdate) - 10
         and exists(
           select * --1
           from wms_tipo_integracion_org a
             inner join orgmstee b on b.org_lvl_child = a.org_lvl_child
           where a.id_tipo = 13-- c_tipo_integracion_tienda
             and to_char(b.org_lvl_number) = i.facility_code
         )
       order by i.group_nbr, i.seq_nbr;

    type t_reg_mov_inv    is table of c_mov_inv%rowtype;
    r_mov_inv   t_reg_mov_inv;

    cursor c_map_inv(p_company_code varchar2,
                     p_activity_code number,
                     p_reason_code varchar2,
                     p_ref_value_1 varchar2,
                     p_ref_value_2 varchar2,
                     p_lock_code varchar2
                     ,p_facility_code varchar2
                    ) is
       select m.ind_efecto,
              m.cod_maestro,
              m.cod_detalle,
              m.suc_inv,
              m.ind_req_rcv,
              m.ind_sgn_wms
        from wms_mapeo_mov_inv m
        where m.company_code = 'HESA'
              and m.activity_code = p_activity_code
              and nvl(m.reason_code,' ') = nvl(p_reason_code,' ')
              and nvl(m.ref_value_1,' ') = nvl(p_ref_value_1,' ')
              and nvl(m.ref_value_2,' ') = nvl(p_ref_value_2,' ')
              and nvl(m.lock_code,' ')   = nvl(p_lock_code,' ')
              and m.estado = 1
              and m.facility_code = p_facility_code --102
        order by m.seq_inv;

    v_tot_reg number := 0;
    v_existe_pe number(2);

    v_prd_lvl_child   prdmstee.prd_lvl_child%type;
    v_org_lvl_child   orgmstee.org_lvl_child%type;
    v_error           wms_error_int.err_code%type;
    v_existe_error    number(5);
    v_tipo_pedido     varchar2(10);
    v_trf_number      trfhdree.trf_number%type;
    v_trf_status_hdr  trfhdree.trf_status%type;
    v_trf_status_dtl  trfhdree.trf_status%type;
    vsesion           invtrnee.trans_session%type;
    vsecuencia        invtrnee.trans_sequence%type;
    vinvtrncode       invtrnee.trans_trn_code%type;
    vinvtypecode      invtrnee.trans_type_code%type;
    vfecha            invtrnee.trans_date%type;
    vcodmaestro       invtrnee.inv_mrpt_code%type;
    vcoddetalle       invtrnee.inv_drpt_code%type;
    vmoneda           invtrnee.trans_curr_code%type;
    vcodsucursal      invtrnee.trans_org_lvl_number%type;
    vsku              invtrnee.trans_prd_lvl_number%type;
    vreferencia       invtrnee.trans_ref%type;
    vreferencia2      invtrnee.trans_ref2%type;
    vcantidad         invtrnee.trans_qty%type;
    vprecio           invtrnee.trans_retl%type;
    vcosto            invtrnee.trans_cost%type;
    vimpuesto         invtrnee.trans_vat%type;
    vunimed           invtrnee.trans_uom%type;
    vinnerpackid      invtrnee.inner_pack_id%type;
    vinnerpacktechkey invtrnee.inner_pk_tech_key%type;
    var_sql_error      sqlerree.sql_error%type;
    var_sql_text      sqlerree.sql_text%type;
    v_flg_procesa      boolean;
    v_flg_procesa_ret  boolean;
    v_asn_recepcionado  number;
    v_ind_inv           varchar2(5);
    v_po_nbr            wms_rcv_asn_dtl.po_nbr%type;
    tip_dist            pmghdree.dmt_code%type;
    v_flg_sku_no_rec   number;
    exp_validation_failed exception;

  begin
    open c_mov_inv;
    loop
      fetch c_mov_inv
      bulk collect into r_mov_inv limit 100;

      for i in 1 .. r_mov_inv.count loop
        begin

          v_error := null;
          vsecuencia := 0;
          v_flg_procesa := true;

          for r_map_inv in c_map_inv( r_mov_inv(i).company_code,
                                      r_mov_inv(i).activity_code,
                                      r_mov_inv(i).reason_code,
                                      r_mov_inv(i).ref_value_1,
                                      r_mov_inv(i).ref_value_2,
                                      r_mov_inv(i).lock_code,
                                      r_mov_inv(i).facility_code
                                      ) loop

            if r_map_inv.ind_req_rcv = 't' then
              select count(1)
               into v_asn_recepcionado
               from edsr.wms_rcv_asn_hdr a
               where a.shipment_nbr = r_mov_inv(i).shipment_nbr
                     and nvl(a.shipment_type,'COM') <> 'TDA'
                     and a.facility_code = r_mov_inv(i).facility_code
                     and a.download_date_1 is not null
                     and err_code = 0;

              begin
                select trim(d.po_nbr)
                into v_po_nbr
                from edsr.wms_rcv_asn_hdr h,
                     edsr.wms_rcv_asn_dtl d
                where h.hdr_group_nbr = d.hdr_group_nbr
                      and h.shipment_nbr  = r_mov_inv(i).shipment_nbr
                      and d.lpn_nbr       = r_mov_inv(i).lpn_nbr
                      and d.item_part_a   = r_mov_inv(i).prd_lvl_number
                      and h.facility_code = r_mov_inv(i).facility_code
                      and h.err_code      = 0;

                if v_po_nbr is not null then

                  select p.dmt_code
                  into tip_dist
                  from edsr.pmghdree p
                  where p.pmg_po_number = to_number(v_po_nbr);

                  if tip_dist <> 2 then
                    v_asn_recepcionado := 0;
                  end if;

                end if;    ---------------

              exception
                when no_data_found then
                    v_asn_recepcionado := 0;
                end;

              if v_asn_recepcionado > 0 then
                v_flg_procesa := true;
              else

                begin

                  select nvl(m.ind_inv,'0')
                  into v_ind_inv
                  from edsr.wms_retornos r, edsr.wms_ret_motivo m
                  where r.num_asn = r_mov_inv(i).shipment_nbr
                        and r.prd_lvl_number = r_mov_inv(i).prd_lvl_number
                        and r.cod_motivo = m.cod_motivo;

                  if v_ind_inv = '1' then
                    v_flg_procesa_ret := true;
                  else
                    v_flg_procesa_ret := false;
                  end if;

                exception

                  when others then
                    v_flg_procesa_ret := false;
                  end;

                if v_flg_procesa_ret = true then
                  v_flg_procesa := true;
                else
                  v_flg_procesa := false;
                  exit;
                end if;
              end if;

            else

              v_flg_procesa := true;

            end if;

            if v_flg_procesa = true then

              pkg_wms_general.sp_valida_prd_number(r_mov_inv(i).prd_lvl_number, v_prd_lvl_child, v_error);
              if v_error <> 0 then raise exp_validation_failed; end if;

              if r_mov_inv(i).adj_qty = 0 then
                v_error := 8;
                raise exp_validation_failed;
              end if;

              pkg_wms_general.sp_valida_org_number(r_map_inv.suc_inv, v_org_lvl_child, v_error);
              if v_error <> 0 then raise exp_validation_failed; end if;

              if vsecuencia = 0 then
                select trans_session.nextval into vsesion from dual;

                insert into edsr.invtrhee
                (
                  trans_session,
                  trans_user,
                  trans_batch_date,
                  trans_source,
                  trans_audited
                )
                values
                (
                  vsesion,
                  'PRCWMSMI',
                  sysdate,
                  'PROCESO MOV.INV. SMS',
                  'T'
                );

                vprecio := pkg_wms_general.fn_get_prc(v_prd_lvl_child,v_org_lvl_child,null);
                vcosto  := pkg_wms_general.fn_get_cst(v_prd_lvl_child,v_org_lvl_child,null);
                vimpuesto := pkg_wms_general.fn_get_igv(vprecio);

                if vcosto <= 0 then
                  v_error := 10;
                  raise exp_validation_failed;
                end if;

              end if;

              vcodmaestro := r_map_inv.cod_maestro;
              vcoddetalle := r_map_inv.cod_detalle;

              begin
                select i.inv_trn_code, i.inv_type_code
                into vinvtrncode, vinvtypecode
                from edsr.invtrdee i
                where i.inv_mrpt_code = vcodmaestro
                      and i.inv_drpt_code = vcoddetalle;
              exception
                when no_data_found then
                  v_error := 18;
                  raise exp_validation_failed;
              end;

              select trunc(caldat) into vfecha from edsr.caldayee;
              vmoneda      := 'USD';
              vcodsucursal := r_map_inv.suc_inv;
              vsku         := r_mov_inv(i).prd_lvl_number;
              vreferencia  := r_mov_inv(i).group_nbr;
              vreferencia2 := r_mov_inv(i).seq_nbr;

              if r_map_inv.ind_sgn_wms = 't' then
                vcantidad  := r_map_inv.ind_efecto*r_mov_inv(i).adj_qty;
              else
                vcantidad  := r_map_inv.ind_efecto*abs(r_mov_inv(i).adj_qty);
              end if;

              vunimed      := pkg_wms_general.fn_obtener_unidad_medida(v_prd_lvl_child);

              vinnerpackid      := pkg_wms_general.fn_get_inner_pack(v_prd_lvl_child,2);
              vinnerpacktechkey := pkg_wms_general.fn_get_inner_pack(v_prd_lvl_child,1);

              if vinnerpackid is null or vinnerpacktechkey is null then
                v_error := 19;
                raise exp_validation_failed;
              end if;

              vsecuencia := vsecuencia + 1;

              insert into edsr.invtrnee
              (
                trans_session,
                trans_sequence,
                trans_org_child,
                trans_prd_child,
                trans_trn_code,
                trans_type_code,
                trans_date,
                inv_mrpt_code,
                inv_drpt_code,
                trans_curr_code,
                trans_org_lvl_number,
                trans_prd_lvl_number,
                proc_source,
                trans_ref,
                trans_ref2,
                trans_qty,
                trans_retl,
                trans_cost,
                trans_vat,
                trans_pos_ext_total,
                trans_ext_retl,
                trans_ext_cost,
                trans_ext_vat,
                trans_home_ext_retl,
                trans_home_ext_cost,
                trans_home_ext_vat,
                inner_pack_id,
                inner_pk_tech_key,
                trans_inners
              )
              values
              (
                vsesion, --trans_session
                vsecuencia, --trans_sequence
                v_org_lvl_child, --trans_org_child
                v_prd_lvl_child, --trans_prd_child
                vinvtrncode, --trans_trn_code
                vinvtypecode, --trans_type_code
                vfecha, --trans_date
                vcodmaestro, --inv_mrpt_code
                vcoddetalle, --inv_drpt_code
                vmoneda, --trans_curr_code
                vcodsucursal, --trans_org_lvl_number
                vsku, --trans_prd_lvl_number
                'WMSMOVINV', --proc_source,
                vreferencia, --trans_ref
                vreferencia2, --trans_ref2
                vcantidad, --trans_qty
                vprecio, --trans_retl
                vcosto, --trans_cost
                vimpuesto, --trans_vat
                vcantidad * vprecio, --trans_pos_ext_total
                vcantidad * vprecio, --trans_ext_retl
                vcantidad * vcosto, --trans_ext_cost
                vcantidad * vimpuesto, --trans_ext_vat
                vcantidad * vprecio, --trans_home_ext_retl
                vcantidad * vcosto, --trans_home_ext_cost
                0, --trans_home_ext_vat
                vinnerpackid, --inner_pack_id
                vinnerpacktechkey, --inner_pk_tech_key
                vcantidad --trans_inners
              );

            end if;

          end loop;

          if vsecuencia > 0 then
            invtrnprc(vsesion, 'F');

            select count(1)
            into v_existe_error
            from edsr.invtrnee i
            where i.trans_session = vsesion;

            if v_existe_error > 0 then
              v_error := 11;
            end if;

            select count(1)
            into v_existe_error
            from edsr.invrejee i
            where i.trans_session = vsesion;

            if v_existe_error > 0 then
              v_error := 12;
            end if;
          end if;

          if v_flg_procesa = true then
            update wms_inv_history w
               set w.err_code = v_error,
                   w.download_date_1 = sysdate
             where w.rowid = r_mov_inv(i).id_reg;
          end if;

          commit;

          select count(1)
          into v_existe_pe
          from wms_pikexp_mov_inv p
          where p.company_code = r_mov_inv(i).company_code
                and p.activity_code = r_mov_inv(i).activity_code;

          if v_existe_pe > 0 then

            v_tipo_pedido := substr(r_mov_inv(i).order_nbr,1,3);

            if v_tipo_pedido in ( 'TRF', 'WMS' , 'TPD' , 'REV' , 'TRN') then

              pkg_wms_general.sp_valida_prd_number(r_mov_inv(i).prd_lvl_number, v_prd_lvl_child, v_error);
              if v_error <> 0 then raise exp_validation_failed; end if;

              if v_tipo_pedido in ('TRF','TPD', 'REV','TRN') then

                begin
                  v_trf_number := to_number(substr(r_mov_inv(i).order_nbr,6));

                  begin
                    select t.trf_status
                    into v_trf_status_hdr
                    from edsr.trfhdree t
                    where t.trf_number = v_trf_number;
                  exception
                    when no_data_found then
                      v_error := 13;
                      raise exp_validation_failed;
                  end;

                  begin
                    select t.trf_status
                    into v_trf_status_dtl
                    from edsr.trfdtlee t
                    where t.trf_number    = v_trf_number
                          and t.prd_lvl_child = v_prd_lvl_child;
                  exception
                    when no_data_found then
                      v_error := 15;
                      raise exp_validation_failed;
                  end;
                exception when others then
                  v_error := 27;
                  raise exp_validation_failed;
                end;
              else

                select count(1)
                into v_flg_sku_no_rec
                from edsr.wms_order_dtl d
                inner join edsr.wms_order_hdr h
                    on d.hdr_group_nbr = h.hdr_group_nbr
                    and h.err_code = 0
                inner join wms_inv_history i
                    on h.order_nbr = i.order_nbr
                    and d.item_alternate_code = i.item_alternate_code
                    and d.req_cntr_nbr = i.lpn_nbr
                    and d.err_code is null
                where i.group_nbr = r_mov_inv(i).group_nbr
                      and i.activity_code = 27
                      and d.item_alternate_code = r_mov_inv(i).prd_lvl_number;

                 if v_flg_sku_no_rec > 0 then

                   v_error := 37;
                   raise exp_validation_failed;
                 end if;

                begin
                  select h.trf_number, h.trf_status, d.trf_status
                  into v_trf_number, v_trf_status_hdr, v_trf_status_dtl
                  from edsr.trfhdree h, edsr.trfdtlee d
                  where h.trf_number = d.trf_number
                        and d.trf_ref_number = r_mov_inv(i).order_nbr
                        and d.prd_lvl_child = v_prd_lvl_child;
                exception
                  when no_data_found then
                    v_error := 15;
                    raise exp_validation_failed;
                  when others then
                    v_error := 27;
                    raise exp_validation_failed;
                end;
              end if;

              if v_trf_status_hdr in (0,5) then
                v_error := 14;
                raise exp_validation_failed;
              end if;

              if v_trf_status_dtl in (0,5) then
                v_error := 16;
                raise exp_validation_failed;
              end if;

              wms_tp_trfpikmas('t',v_trf_number, v_prd_lvl_child, -1*abs(r_mov_inv(i).adj_qty));

              update wms_inv_history w
                 set w.err_code = v_error,
                     w.download_date_1 = sysdate
               where w.rowid = r_mov_inv(i).id_reg;

            end if;
            commit;
          end if;
          --

          v_tot_reg := v_tot_reg + sql%rowcount;

        exception
          when exp_validation_failed then
            rollback;

            if v_error = 15 and nvl(v_tipo_pedido,' ') = 'wms' then
              null;
            else

              update wms_inv_history w
              set    w.err_code = v_error, --error validacion
                     w.download_date_1 = sysdate
              where  w.rowid = r_mov_inv(i).id_reg;

              commit;
            end if;

          when others then
            rollback;

            update wms_inv_history w
            set    w.err_code = 999, --error sql
                   w.download_date_1 = sysdate
            where  w.rowid = r_mov_inv(i).id_reg;

            commit;

            -- insert record into sqlerree
            var_sql_error := sqlcode;
            var_sql_text := substr(r_mov_inv(i).group_nbr||'/'||r_mov_inv(i).seq_nbr||'-'||sqlerrm,1,100);

            insert into sqlerree
            (
              error_number,
              procedure_name,
              error_date,
              sql_error,
              isam_error,
              sql_text,
              error_status
            )
            values
            (
              sqlerrseq.nextval,
              'INV_HIST.SP_PROCESO_TIENDA',
              sysdate,
              var_sql_error,
              var_sql_error,
              var_sql_text,
              '0'
            );
            commit;
            dbms_output.put_line(var_sql_text);
        end;
      end loop;

      exit when c_mov_inv%notfound ;
    end loop;

    commit;
    close c_mov_inv;

    dbms_output.put_line('REG.UPD.: '||v_tot_reg);

  exception
    when others then
      rollback;
      -- insert record into sqlerree
      var_sql_error := sqlcode;
      var_sql_text  := substr(sqlerrm,1,100);

      insert into sqlerree
      (
        error_number,
        procedure_name,
        error_date,
        sql_error,
        isam_error,
        sql_text,
        error_status
      )
      values(
      sqlerrseq.nextval,
      'INV_HIST.SP_PROCESO_TIENDA',
      sysdate,
      var_sql_error,
      var_sql_error,
      var_sql_text,
      '0'
    );
    commit;

    dbms_output.put_line(var_sql_text);
  end;--END sp_proceso_tienda