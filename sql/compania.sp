/************************************************************************/
/*	Archivo: 		compania.sp			        */
/*	Stored procedure: 	sp_compania 			        */
/*	Base de datos:  	db_erp					*/
/*	Producto: 		ERP        				*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	15/Jun/2011				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_compania')
	drop proc sp_compania
go
create proc sp_compania (
			@i_operacion        char(1),
			@i_ruc              char(13) = NULL,
			@i_nombre           char(65) = NULL,
			@i_direccion        char(65) = NULL,
			@i_representante    char(65) = NULL,
			@i_modo             int = NULL,
			@i_tipo		    varchar(1) = null
)
as
declare
	@w_ruc	char(13)

if @i_operacion = 'I'
begin
	select  @w_ruc = co_ruc
	from    er_compania
	if @@rowcount <> 0
	begin
		raiserror 13042 'Ya existe una compania creada, no se puede ingresar otra'
		return 1
	end
	begin tran
	/* insertar los parametros de entrada */
	insert into er_compania (co_ruc, co_nombre, co_direccion, co_representante)
	values (@i_ruc, @i_nombre, @i_direccion, @i_representante)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13041	'No se pudo crear la compania'
		rollback tran
		return 1
	end
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_ruc = co_ruc
	from    er_compania
	where   co_ruc = @i_ruc
	if @@rowcount = 0
	begin
		raiserror 13043 'No existe la compania'
		return 1
	end
	begin tran
		update er_compania
		set  co_nombre        = @i_nombre,
		     co_direccion     = @i_direccion,
		     co_representante = @i_representante
		where co_ruc  = @i_ruc
		if @@error != 0
		begin
			raiserror 13044 'Error en actualizacion de la compania'
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_ruc = co_ruc
	from   er_compania
	where  co_ruc = @i_ruc
	if @@rowcount = 0
	begin
		raiserror 13043 'No existe la compania'
		return 1
	end
	/* borrado de compania */
	begin tran
		delete er_compania
		where  co_ruc = @i_ruc
		if @@error != 0
		begin
			raiserror 13045 'Error en eliminacion de compania'
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select co_ruc,  co_nombre, co_direccion, co_representante
		from er_compania
		order by co_ruc
	end
	if @i_modo = 1
	begin
		select co_ruc, co_nombre, co_direccion, co_representante
		from   er_compania
		where  co_ruc > @i_ruc
		order by co_ruc
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
			select   'RUC'           = co_ruc,
				 'Nombre'        = co_nombre,
                                 'Direcci¢n'     = co_direccion,
                                 'Representante' = co_representante
			from   er_compania
			order  by co_ruc
		else 
			if @i_modo = 1
				select co_ruc, co_nombre, co_direccion,
                                       co_representante
				from   er_compania
				where  co_ruc > @i_ruc
				order  by co_ruc
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select co_nombre
		from   er_compania
		where co_ruc = @i_ruc
		if @@rowcount = 0
		begin
			raiserror 13043 'No existe compania'
			return 1
		end
	end
end
return 0
go
