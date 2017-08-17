/************************************************************************/
/*	Archivo: 		ente.sp				*/
/*	Stored procedure: 	sp_ente 			        */
/*	Base de datos:  	erp					*/
/*	Producto: 		sistema de Nomina        		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	30/Jun/2010				*/
/************************************************************************/

use db_erp
go
if exists (select * from sysobjects where name = 'sp_ente')
	drop proc sp_ente
go
create proc sp_ente (
			@i_operacion   char(1),
			@i_codigo      int         = NULL,
			@i_tipo_i      char(1)     = NULL,
			@i_documento   char(20)    = NULL,
			@i_nombre      char(65)    = NULL,
			@i_apellidop   char(65)    = NULL,
			@i_apellidom   char(65)    = NULL,
			@i_fecha_nac   datetime    = NULL,
			@i_fecha_ing   datetime    = NULL,
			@i_sexo        char(1)     = NULL,
			@i_email       char(65)    = NULL,
			@i_modo        int         = NULL,
			@i_tipo	       varchar(1)  = NULL
)
as
declare
	@w_codigo	int,
	@w_siguiente	int

if @i_operacion = 'I'
begin
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
	insert into er_ente (en_codigo, en_tipo, en_documento,
		             en_nombre, en_apellidop, en_apellidom,
		             en_fecha_nac, en_fecha_ing, en_sexo,
		             en_email)
	values (@w_siguiente, @i_tipo_i,    @i_documento,
		@i_nombre,    @i_apellidop, @i_apellidom,
		@i_fecha_nac, @i_fecha_ing, @i_sexo,
		@i_email)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13050 'No se pudo crear el cliente'
		rollback tran
		return 1
	end
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select @w_codigo = en_codigo
	from   er_ente
	where  en_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13051 'No existe el cliente'
		return 1
	end
	begin tran
		update er_ente
		set  en_tipo = @i_tipo_i, 
		en_documento = @i_documento,
		en_nombre    = @i_nombre,
		en_apellidop = @i_apellidop,
		en_apellidom = @i_apellidom,
		en_fecha_nac = @i_fecha_nac,
		en_fecha_ing = @i_fecha_ing,
		en_sexo      = @i_sexo,
		en_email     = @i_email
		where en_codigo  = @i_codigo
		if @@error != 0
		begin
			raiserror 13052 'Error en actualizacion del cliente'
			return 1
		end
	commit tran
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select @w_codigo  = en_codigo
	from   er_ente
	where  en_codigo = @i_codigo
	if @@rowcount = 0
	begin
		raiserror 13034 'No existe la unidad'
		return 1
	end
	/* borrado de ente*/
	begin tran
		delete er_ente
		where en_codigo = @i_codigo
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
		select en_codigo,  un_descripcion
		from er_ente
		order by en_codigo
	end
	if @i_modo = 1
	begin
		select  en_codigo, un_descripcion
		from   er_ente
		where en_codigo > @i_codigo
		order by en_codigo
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
			select   'Codigo' = en_codigo,
				 'Descripcion' = un_descripcion
			from   er_ente
			order  by en_codigo
		else 
			if @i_modo = 1
				select   en_codigo, un_descripcion
				from   er_ente
				where    en_codigo > @i_codigo
				order  by en_codigo
		set rowcount 0
	end
	if @i_tipo = 'V'
	begin
		select un_descripcion
		from   er_ente
		where en_codigo = @i_codigo
		if @@rowcount = 0
		begin
			raiserror 13034 'No existe la unidad'
			return 1
		end
	end
end
return 0
go
