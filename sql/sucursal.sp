/************************************************************************/
/*	Archivo: 		sucursal.sp				*/
/*	Stored procedure: 	sp_sucursal 			        */
/*	Base de datos:  	db_erp					*/
/*	Producto: 		sistema ERP             		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	15/Jun/2011				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_sucursal')
	drop proc sp_sucursal
go
create proc sp_sucursal (
			@i_operacion       char(1),
			@i_codigo          char(3)     = NULL,
			@i_descripcion     varchar(65) = NULL,
			@i_direccion       varchar(30) = NULL,
			@i_ptoemision      varchar(3)  = NULL,
			@i_ptofacturacion  varchar(3)  = NULL,
			@i_modo            int         = NULL,
			@i_tipo		   varchar(1)  = NULL,
			@o_siguiente	   int         = NULL output
)
as
declare
	@w_codigo	int

if @i_operacion = 'I'
begin
	select @o_siguiente = 0
	select @o_siguiente = max(su_codigo)
	from   er_sucursal
	
	if @o_siguiente >= 1
		select @o_siguiente = @o_siguiente + 1
	else
		select @o_siguiente = 1
	begin tran
	/* insertar los parametros de entrada */
	insert into er_sucursal (su_codigo,     su_descripcion, su_direccion,
			         su_ptoemision, su_ptofacturacion)
	                 values (@o_siguiente,  @i_descripcion, @i_direccion,
			         @i_ptoemision, @i_ptofacturacion)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13046 'No se pudo crear la sucursal'
		rollback tran
		return 1
	end
	commit tran
	select @o_siguiente
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_codigo = su_codigo
	from    er_sucursal
	where   su_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13047 'No existe la sucursal'
		return 1
	end
	begin tran
		update er_sucursal
		set  su_descripcion     = @i_descripcion,
		     su_direccion       = @i_direccion,
		     su_ptoemision      = @i_ptoemision,
		     su_ptofacturacion  = @i_ptofacturacion
		where su_codigo  = @i_codigo
		if @@error != 0
		begin
			raiserror 13048 'Error en actualizacion de la sucursal'
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_codigo  = su_codigo
	from   er_sucursal
	where  su_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13047 'No existe la sucursal'
		return 1
	end
	/* borrado de sucursales*/
	begin tran
		delete er_sucursal
		where su_codigo = @i_codigo
		if @@error != 0
		begin
			raiserror 13049 'Error en eliminacion de la sucursal'
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select su_codigo,     su_descripcion, su_direccion,
		       su_ptoemision, su_ptofacturacion
		from er_sucursal
		order by su_codigo
	end
	if @i_modo = 1
	begin
		select su_codigo,     su_descripcion, su_direccion,
		       su_ptoemision, su_ptofacturacion
		from   er_sucursal
		where su_codigo > @i_codigo
		order by su_codigo
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
			select   'Codigo' = su_codigo,
				 'Descripcion' = su_descripcion
			from   er_sucursal
			order  by su_codigo
		else 
			if @i_modo = 1
				select   su_codigo, su_descripcion
				from   er_sucursal
				where    su_codigo > @i_codigo
				order  by su_codigo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select su_descripcion
		from   er_sucursal
		where su_codigo = @i_codigo
		if @@rowcount = 0
		begin
			raiserror 13047 'No existe la sucursal'
			return 1
		end
	end
end
return 0
go
