use db_erp
go
/*usuarios*/
create table er_user
(
us_codigo      smallint        NOT NULL,
us_login       char(15)        NOT NULL,
us_password    char(15)        NOT NULL,
us_estado      char(1)         NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_user_Key ON er_user (
		us_codigo)
go

/*clientes*/
drop table er_ente
go
create table er_ente
(
en_codigo      int             NOT NULL,
en_tipo_i      char(1)         NOT NULL,
en_documento   char(20)        NOT NULL,
en_nombre      char(65)        NOT NULL,
en_apellidop   char(65)        NULL,
en_apellidom   char(65)        NULL,
en_fecha_nac   datetime        NULL,
en_fecha_ing   datetime        NOT NULL,
en_sexo        char(1)         NULL,
en_email       char(65)        NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_ente_Key ON er_ente (
		en_codigo)
go

/*direccion*/
create table er_direccion
(
di_codigo      int             NOT NULL,
di_direccion   char(65)        NOT NULL,
di_telefono    char(9)         NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_direccion_Key ON er_direccion (
		di_codigo)
go

/*articulo*/
drop table er_articulo
go
create table er_articulo
(
ar_codigo        int                 NOT NULL,
ar_descripcion  char(65)        NOT NULL,
ar_familia        char(10)        NOT NULL,
ar_costo         float   	         NULL,
ar_unidad	    char(3)          NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_articulo_Key ON er_articulo (
		ar_codigo)
go

/*autorizaciones*/
create table er_autorizacion_sri
(
au_autorizacion  char(10)    NOT NULL,
au_fecha_val     datetime    NOT NULL,
au_fecha_aut     datetime    NOT NULL,
au_status        char(1)     NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_autorizacion_sri_Key ON er_autorizacion_sri (
		au_autorizacion)
go

/*compania*/
create table er_compania
(
co_ruc           char(13)    NOT NULL,
co_nombre        char(65)    NOT NULL,
co_direccion     char(65)    NOT NULL,
co_representante char(65)    NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_compania_Key ON er_compania (
		co_ruc)
go

/*correccion stock*/
create table er_correccion
(
co_articulo       int             NOT NULL,
co_fecha_tran  datetime     NOT NULL,
co_cactual     float   	      NULL,
co_cnueva    float   	      NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_correccion_Key ON er_correccion (
		co_articulo, co_fecha_tran)
go

/*familia de articulos*/
create table er_familia
(
fa_codigo          varchar(10)    NOT NULL,
fa_descripcion    varchar(65)    NOT NULL,
fa_cta_contable varchar(10)    NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_familia_Key ON er_familia (
		fa_codigo)
go

/*stock de un articulo*/
drop table er_stock_articulo
go
create table er_stock_articulo
(
st_articulo       int       NOT NULL,
st_fecha_tran     date      NOT NULL,
st_hora_tran      time      NOT NULL,
st_cactual        float     NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_stock_articulo_Key ON er_stock_articulo (
		st_articulo)
go

/*historico stock de un articulo*/
drop table er_stock_articulo_his
go
create table er_stock_articulo_his
(
sh_articulo       int             NOT NULL,
sh_fecha_tran     date            NOT NULL,
sh_hora_tran      time            NOT NULL,
sh_canterior      float   	  NULL,
sh_ctransac       float   	  NOT NULL,
sh_cnueva         float   	  NULL,
sh_login          varchar(15)     NOT NULL,
sh_transac        varchar(30)     NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_stock_articulo_his_Key ON er_stock_articulo_his (
		sh_articulo, sh_fecha_tran, sh_hora_tran)
go

/*Unidades*/
create table er_unidades
(
un_codigo            char(3)   	      NULL,
un_descripcion     varchar(60)    NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_unidades_Key ON er_unidades(
		un_codigo)
go

/*historico stock de un articulo*/
drop table er_sucursal
go
create table er_sucursal
(
su_codigo         int             NOT NULL,
su_descripcion    varchar(30)     NOT NULL,
su_direccion      varchar(30)     NOT NULL,
su_ptoemision     varchar(3)      NOT NULL,
su_ptofacturacion varchar(3)      NOT NULL
)
go
CREATE UNIQUE CLUSTERED INDEX er_sucursal_Key ON er_sucursal(
		su_codigo)
go
