/************************************************************************/
/*	Archivo: 		familia.sp				*/
/*	Stored procedure: 	sp_familia 			        */
/*	Base de datos:  	erp					*/
/*	Producto: 		sistema de Nomina        		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	15/Abr/2010				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_familia')
	drop proc sp_familia
go
create proc sp_familia (
			@i_operacion       char(1),
			@i_codigo          char(3)     = NULL,
			@i_descripcion     varchar(65) = NULL,
			@i_cta_contable    varchar(10) = NULL,
			@i_modo            int         = NULL,
			@i_tipo		   varchar(1)  = null
)
as
declare
	@w_codigo	char(3)

if @i_operacion = 'I'
begin
	begin tran
	/* insertar los parametros de entrada */
	insert into er_familia (fa_codigo, fa_descripcion, fa_cta_contable)
	values (@i_codigo, @i_descripcion, @i_cta_contable)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13028 'No se pudo crear la familia'
		rollback tran
		return 1
	end
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_codigo = fa_codigo
	from    er_familia
	where fa_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13029 'No existe familia'
		return 1
	end
	begin tran
		update er_familia
		set  fa_descripcion     = @i_descripcion,
		       fa_cta_contable  = @i_cta_contable
		where fa_codigo  = @i_codigo
		if @@error != 0
		begin
			raiserror 13030 'Error en actualizacion de familia'
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_codigo  = fa_codigo
	from   er_familia
	where  fa_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13029 'No existe familia'
		return 1
	end
	select @w_codigo  = ar_codigo
	from   er_articulo
	where  ar_familia = @i_codigo
	if @@rowcount > 0
	begin
		raiserror 13032 'Familia utilizada en articulo no puede ser eliminada'
		return 1
	end
	/* borrado de familia*/
	begin tran
		delete er_familia
		where fa_codigo = @i_codigo
		if @@error != 0
		begin
			raiserror 13031 'Error en eliminacion de familia'
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select fa_codigo,  fa_descripcion, fa_cta_contable
		from er_familia
		order by fa_codigo
	end
	if @i_modo = 1
	begin
		select  fa_codigo, fa_descripcion, fa_cta_contable
		from   er_familia
		where fa_codigo > @i_codigo
		order by fa_codigo
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
			select   'Codigo' = fa_codigo,
				 'Descripcion' = fa_descripcion,
                                 'Cuenta Contable' = fa_cta_contable
			from   er_familia
			order  by fa_codigo
		else 
			if @i_modo = 1
				select   fa_codigo, fa_descripcion, fa_cta_contable
				from   er_familia
				where    fa_codigo > @i_codigo
				order  by fa_codigo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select fa_descripcion
		from   er_familia
		where fa_codigo = @i_codigo
		if @@rowcount = 0
		begin
			raiserror 13029 'No existe familia'
			return 1
		end
	end
end
return 0
go
