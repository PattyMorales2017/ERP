/************************************************************************/
/*	Archivo: 		unidades.sp				*/
/*	Stored procedure: 	sp_unidades 			        */
/*	Base de datos:  	erp					*/
/*	Producto: 		sistema de Nomina        		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	15/Abr/2010				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_unidades')
	drop proc sp_unidades
go
create proc sp_unidades (
			@i_operacion       char(1),
			@i_codigo          char(3)     = NULL,
			@i_descripcion     varchar(65) = NULL,
			@i_modo            int         = NULL,
			@i_tipo		   varchar(1)  = NULL
)
as
declare
	@w_codigo	char(3)

if @i_operacion = 'I'
begin
	begin tran
	/* insertar los parametros de entrada */
	insert into er_unidades (un_codigo, un_descripcion)
	values (@i_codigo, @i_descripcion)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13033 'No se pudo crear la unidad'
		rollback tran
		return 1
	end
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_codigo = un_codigo
	from    er_unidades
	where un_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13034 'No existe la unidad'
		return 1
	end
	begin tran
		update er_unidades
		set  un_descripcion     = @i_descripcion
		where un_codigo  = @i_codigo
		if @@error != 0
		begin
			raiserror 13035 'Error en actualizacion de la unidad'
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_codigo  = un_codigo
	from   er_unidades
	where  un_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13034 'No existe la unidad'
		return 1
	end
	/* borrado de unidades*/
	begin tran
		delete er_unidades
		where un_codigo = @i_codigo
		if @@error != 0
		begin
			raiserror 13036 'Error en eliminacion de la unidad'
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select un_codigo,  un_descripcion
		from er_unidades
		order by un_codigo
	end
	if @i_modo = 1
	begin
		select  un_codigo, un_descripcion
		from   er_unidades
		where un_codigo > @i_codigo
		order by un_codigo
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
			select   'Codigo' = un_codigo,
				 'Descripcion' = un_descripcion
			from   er_unidades
			order  by un_codigo
		else 
			if @i_modo = 1
				select   un_codigo, un_descripcion
				from   er_unidades
				where    un_codigo > @i_codigo
				order  by un_codigo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select un_descripcion
		from   er_unidades
		where un_codigo = @i_codigo
		if @@rowcount = 0
		begin
			raiserror 13034 'No existe la unidad'
			return 1
		end
	end
end
return 0
go
