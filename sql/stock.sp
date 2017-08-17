/************************************************************************/
/*	Archivo: 		stock.sp				*/
/*	Stored procedure: 	sp_stock 			        */
/*	Base de datos:  	erp					*/
/*	Producto: 		sistema de Nomina        		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	20/May/2010				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_stock')
	drop proc sp_stock
go
create proc sp_stock (
			@i_operacion       char(1),
			@i_articulo        int            = NULL,
			@i_fecha_tran      varchar(10)    = NULL,
			@i_hora_tran       varchar(8)    = NULL,
			@i_cactual	   float          = NULL,
			@i_login           varchar(15)    = NULL,
			@i_transac         varchar(30)    = NULL,
			@i_modo            int            = NULL,
			@i_tipo		   varchar(1)     = null,
			@i_formato_fecha   tinyint        = 101
)
as
declare
	@w_articulo       int,
	@w_fecha_tran     datetime,
	@w_hora_tran      time,
	@w_canterior	  float 

if @i_operacion = 'I'
begin
	select @w_fecha_tran = convert(datetime, @i_fecha_tran, @i_formato_fecha )
	select @w_hora_tran  = convert(time, @i_hora_tran, 108)
	begin tran
	/* insertar los parametros de entrada */
	insert into er_stock_articulo (st_articulo, st_fecha_tran, st_hora_tran, st_cactual)
	values (@i_articulo, @w_fecha_tran, @w_hora_tran, @i_cactual)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13037 'No se pudo ingresar el stock del articulo'
		rollback tran
		return 1
	end
	/*Insertar historico*/
	insert into er_stock_articulo_his
	      (sh_articulo, sh_fecha_tran, sh_hora_tran, sh_canterior, sh_ctransac, 
 	       sh_cnueva,   sh_login,      sh_transac)
	values(@i_articulo, @w_fecha_tran, @w_hora_tran, 0,            @i_cactual,
	       @i_cactual,  @i_login,      @i_transac)
	if @@error != 0
	begin
		raiserror 13037 'No se pudo ingresar el stock del articulo'
		rollback tran
		return 1
	end
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select @w_fecha_tran = convert(datetime, @i_fecha_tran, @i_formato_fecha)
	select @w_hora_tran  = convert(time, @i_hora_tran, 108)
	select @w_canterior = st_cactual
	from   er_stock_articulo
	where  st_articulo = @i_articulo
	if @@rowcount = 0
	begin
		raiserror 13038 'Stock del articulo no existe, ingrese el stock inicial'
		return 1
	end
	begin tran
		update er_stock_articulo
		set  st_fecha_tran  = @w_fecha_tran,
		     st_hora_tran   = @w_hora_tran,
		     st_cactual     = @i_cactual
		where st_articulo   = @i_articulo
		if @@error != 0
		begin
			raiserror 13039 'Error en actualizacion de stock'
			rollback tran
			return 1
		end
		/*Insertar historico*/
		insert into er_stock_articulo_his
		      (sh_articulo, sh_fecha_tran, sh_hora_tran, sh_canterior, sh_ctransac,
		       sh_cnueva,   sh_login,      sh_transac)
		values(@i_articulo, @w_fecha_tran, @w_hora_tran, @w_canterior, @i_cactual,
		       @i_cactual,  @i_login,      @i_transac)
		if @@error != 0
		begin
			raiserror 13039 'Error en actualizacion de stock'
			rollback tran
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_canterior = st_cactual
	from   er_stock_articulo
	where  st_articulo = @i_articulo
	if @@rowcount = 0
	begin
		raiserror 13038 'Stock del articulo no existe '
		return 1
	end
	/* borrado de stock*/
	begin tran
		delete er_stock_articulo
		where st_articulo = @i_articulo
		if @@error != 0
		begin
			raiserror 13040 'Error en eliminacion de stock'
			return 1
		end
		/*Insertar historico*/
		select @w_fecha_tran = convert(datetime, @i_fecha_tran, @i_formato_fecha)
		select @w_hora_tran  = convert(time, @i_hora_tran, 108)
		insert into er_stock_articulo_his
 		      (sh_articulo, sh_fecha_tran, sh_hora_tran, sh_canterior, sh_ctransac, 
		       sh_cnueva,   sh_login,      sh_transac)
		values(@i_articulo, @w_fecha_tran, @w_hora_tran, @w_canterior, 0, 
		       0,           @i_login,      @i_transac)
		if @@error != 0
		begin
			raiserror 13040 'Error en eliminacion de stock'
			rollback tran
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select st_articulo,  st_fecha_tran, st_hora_tran, st_cactual
		from er_stock_articulo
		order by st_articulo
	end
	if @i_modo = 1
	begin
		select  st_articulo, st_fecha_tran, st_hora_tran, st_cactual
		from   er_stock_articulo
		where st_articulo > @i_articulo
		order by st_articulo
	end
	set rowcount 0
end

/* ** Help ** */
/* Query de datos especificos [A]ll y [V]alue */
if @i_operacion='H'
begin
	if @i_tipo = 'A'
	begin
		set rowcount 20
		if @i_modo = 0
			select   'Articulo' = st_articulo,
				    'Fecha de la Transaccion' = st_fecha_tran,
				    'Hora de la Transaccion' = st_hora_tran,
                                    'Cantidad Actual' =  st_cactual
			from   er_stock_articulo
			order  by st_articulo
		else 
			if @i_modo = 1
				select   st_articulo, st_fecha_tran, st_hora_tran, st_cactual
				from   er_stock_articulo
				where    st_articulo > @i_articulo
				order  by st_articulo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select st_cactual
		from   er_stock_articulo
		where st_articulo = @i_articulo
		if @@rowcount = 0
		begin
			raiserror 13038 'Stock del articulo no existe '
			return 1
		end
	end
end
return 0
go
