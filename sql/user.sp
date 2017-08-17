/************************************************************************/
/*	Archivo: 		user.sp				        */
/*	Stored procedure: 	sp_user 			        */
/*	Base de datos:  	db_erp					*/
/*	Producto: 		Sistema de nomina        		*/
/*	Disenado por:  		PMS				        */
/*	Fecha de escritura: 	13/Abr/2011				*/
/************************************************************************/

use db_erp
go

if exists (select * from sysobjects where name = 'sp_user')
	drop proc sp_user
go
create proc sp_user (
			@i_operacion	char(1) = NULL,
			@i_codigo	int = NULL,
			@i_login	char(15)= NULL,
			@i_password	char(15) = NULL,
			@i_estado 	char(1) = NULL,
			@i_modo		int = NULL,
			@i_flag		char(1) = NULL,
			@o_siguiente	int = NUll output
)
as
declare
	@w_codigo      	int,
	@w_login         	char(15),
	@w_estado      	char(1),
	@w_cmdtransrv	varchar(64)

if @i_operacion = 'I'
begin
	/* verificar que no este previamente insertada el login */
	if exists (select  us_login from  er_user where  us_login = @i_login)
	begin
		raiserror 13000 'El usuario ya existe'
		return 1
	end
	select @o_siguiente = 0
	select @o_siguiente = max(us_codigo)
	from   er_user
	
	if @o_siguiente >= 1
		select @o_siguiente = @o_siguiente + 1
	else
		select @o_siguiente = 1
	select @w_estado = 'A'
	begin tran
	/* insertar los parametros de entrada */
	insert into er_user (us_codigo, us_login, us_password, us_estado)
	values (@o_siguiente, @i_login, @i_password, @w_estado)
	/* si no se pudo insertar, error */
	if @@error != 0
	begin
		raiserror 13001 'No se pudo crear el usuario'
		rollback tran
		return 1
	end
	select @o_siguiente
	commit tran
end

/* ** Update ** */
if @i_operacion = 'U'
begin
	select  @w_codigo = us_codigo,
	        @w_login   = us_login
	from  er_user
	where us_login = @i_login
	if @@rowcount = 0
	begin
		raiserror 13002 'No existe usuario'
		/*  'No existe usuario'*/
		return 1
	end
	if @i_flag = 'N'
	begin
		begin tran
		update er_user
		set    us_estado = @i_estado
		where  us_login  = @i_login
		if @@error != 0
		begin
			raiserror 13003 'Error en actualizacion de usuario'
			/*  'Error en actualizacion de usuario' */
			rollback tran
			return 1
		end
		commit tran
	end
	if @i_flag = 'S'
	begin
		begin tran
		update er_user
		set    us_password = @i_password
		where  us_login    = @i_login
		if @@error != 0
		begin
			raiserror 13003 'Error en actualizacion de usuario'
			/*  'Error en actualizacion de usuario' */
			rollback tran
			return 1
		end
		commit tran
	end
end

/* ** Delete ** */
if @i_operacion = 'D'
begin
	select  @w_codigo = us_codigo,
		    @w_login   = us_login
	from er_user
	where us_login = @i_login
	if @@rowcount = 0
	begin
		raiserror 13002 'No existe usuario'
		/*  'No existe usuario'*/
		return 1
	end

	/* borrado de usuario */
	begin tran
		Delete er_user
		where us_login = @i_login
		if @@error != 0
		begin
			raiserror 13005 'Error en eliminacion de usuario'
			/*  'Error en eliminacion de usuario ' */
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
		select us_codigo, us_login, us_estado
		from er_user
		order by us_codigo
		set rowcount 20
	end
	if @i_modo = 1
	begin
		select us_codigo, us_login, us_estado
		from   er_user
		where us_codigo > @i_codigo
		order by us_codigo
	end
	set rowcount 0
end
return 0
go
