/************************************************************************/
/*	Archivo: 		articulo.sp			        */
/*	Stored procedure: 	sp_articulo 			        */
/*	Base de datos:  	db_erp					*/
/*	Producto: 		ERP        				*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	16/Dic/2008				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_articulo')
	drop proc sp_articulo
go
create proc sp_articulo (
			@i_operacion        char(1),
			@i_codigo           int  = NULL,
			@i_descripcion      char(65) = NULL,
			@i_familia    	    char(10) = NULL,
			@i_costo            float = NULL,
			@i_unidad           char(3) = NULL,
			@i_modo             int = NULL,
			@i_tipo		    varchar(1) = null
)
as
declare
	@w_siguiente	int,
	@w_codigo	int,
	@w_codigo_uni	char(3),
	@w_codigo_fam	char(3)

if @i_operacion = 'I'
begin
	/*Verificacion de la familia*/
	select @w_codigo_fam  = fa_codigo
	from   er_familia
	where  fa_codigo = @i_familia
	if @@rowcount = 0
	begin
		raiserror 13029 'No existe familia'
		return 1
	end
	/*Verificacion de la unidad*/
	select @w_codigo_uni  = un_codigo
	from   er_unidades
	where  un_codigo = @i_unidad
	if @@rowcount = 0
	begin
		raiserror 13034 'No existe la unidad'
		return 1
	end
	select @w_siguiente = 1
	select @w_siguiente = max(ar_codigo)
	from   er_articulo
	/*select isnull(@w_siguiente, 1)*/
	if @w_siguiente >= 1
		select @w_siguiente = @w_siguiente + 1
	else
		select @w_siguiente = 1
	begin tran
	/* insertar los parametros de entrada */
	insert into er_articulo (ar_codigo, ar_descripcion, ar_familia, ar_costo,
	                         ar_unidad)
	values (@w_siguiente, @i_descripcion, @i_familia, @i_costo,
	        @i_unidad)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13025 'No se pudo crear el articulo'
		rollback tran
		return 1
	end
	commit tran
	select @w_siguiente
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_codigo = ar_codigo
	from    er_articulo
	where ar_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13026 'No existe articulo'
		/*  'No existe articulo'*/
		return 1
	end
	/*Verificacion de la familia*/
	select @w_codigo_fam  = fa_codigo
	from   er_familia
	where  fa_codigo = @i_familia
	if @@rowcount = 0
	begin
		raiserror 13029 'No existe familia'
		return 1
	end
	/*Verificacion de la unidad*/
	select @w_codigo_uni  = un_codigo
	from   er_unidades
	where  un_codigo = @i_unidad
	if @@rowcount = 0
	begin
		raiserror 13034 'No existe la unidad'
		return 1
	end
	begin tran
		update er_articulo
		set  ar_descripcion = @i_descripcion,
		     ar_familia     = @i_familia,
		     ar_costo       = @i_costo,
		     ar_unidad      = @i_unidad
		where ar_codigo  = @i_codigo
		if @@error != 0
		begin
			raiserror 13027 'Error en actualizacion de articulo'
			/*  'Error en actualizacion de articulo' */
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select  @w_codigo = ar_codigo
	from er_articulo
	where ar_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13026 'No existe articulo'
		/*  'No existe articulo'*/
		return 1
	end
	/* borrado de articulo */
	begin tran
		Delete er_articulo
		where ar_codigo = @i_codigo
		if @@error != 0
		begin
			raiserror 13028 'Error en eliminacion de articulo'
			/*  'Error en eliminacion de articulo ' */
			return 1
		end
	commit tran
end

if @i_operacion = 'S'
begin
	set rowcount 20
	if @i_modo = 0
	begin
		select ar_codigo,  ar_descripcion, ar_familia, ar_costo,
                       ar_unidad
		from er_articulo
		order by ar_codigo
	end
	if @i_modo = 1
	begin
		select ar_codigo, ar_descripcion, ar_familia, ar_costo,
		       ar_unidad
		from   er_articulo
		where  ar_codigo > @i_codigo
		order by ar_codigo
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
			select   'Codigo'      = ar_codigo,
				 'Descripcion' = ar_descripcion,
                                 'Familia'     = ar_familia,
                                 'Costo'       = ar_costo,
			         'Unidad'      = ar_unidad
			from   er_articulo
			order  by ar_codigo
		else 
			if @i_modo = 1
				select ar_codigo, ar_descripcion, ar_familia,
                                       ar_costo, ar_unidad
				from   er_articulo
				where  ar_codigo > @i_codigo
				order  by ar_codigo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select ar_descripcion
		from   er_articulo
		where ar_codigo = @i_codigo
		if @@rowcount = 0
		begin
			raiserror 13026 'No existe articulo'
			/*  'No existe articulo'*/
			return 1
		end
	end
end
return 0
go
