use GestionCoworkingDB;

-- insertar datos para pruebas

insert into Reservas (usuario_id, espacio_id, fecha, hora_entrada, hora_salida, estado, asistencia_id, servicioAdicional_id) values 
(1, 1, '2026-11-02', '09:00:00', '13:00:00', 'Confirmada', 1, 1),
(2, 4, '2026-11-02', '10:00:00', '14:00:00', 'Confirmada', 4, 2),
(3, 7, '2026-11-02', '08:00:00', '12:00:00', 'Confirmada', 10, 3),
(4, 1, '2026-11-02', '14:00:00', '20:00:00', 'Confirmada', 45, 2),
(5, 2, '2026-11-03', '09:00:00', '17:00:00', 'Confirmada', 1, NULL),
(6, 5, '2026-11-03', '13:00:00', '18:00:00', 'Confirmada', 5, 4),
(7, 8, '2026-11-03', '08:00:00', '11:00:00', 'Confirmada', 15, 1);

insert into Asistencias (reserva_id, usuario_id) values 
(51, 1),
(52, 2),
(53, 3),
(54, 4),
(55, 5),
(56, 6),
(57, 7);


-- _________________________________________________________________________________________________
-- Vista de Estadp de espacios


create view vw_EstadoEspacios as
	select e.idEspacio as Espacio, r.estado as Estado, concat(r.fecha, hora_entrada) as ProximaReserva
    from Espacios e 
    inner join Reservas r on e.idEspacio = r.espacio_id
    where r.fecha >= curdate() and r.hora_entrada <= now(); -- filtrar por fecha y hora iguales y mayores al dia actual.


-- _________________________________________________________________________________________________
-- Procedimiento Almacenado para generar reporteria.

-- Crear tabla para guardar el registro diario del procedimiento almacenado.
create table ReporteDiario (
	idReporte int primary key auto_increment,
    totalReservas int,
    usuariosActivos int,
    ingresosDia decimal(10,2)
);

delimiter $$

create procedure sp_GenerarReporteDiario (in p_fecha date) 
begin
    
    select count(idReserva) 
    from Reservas
    where fecha = p_fecha;
    update ReporteDiario rp
    set rp.totalReservas = count(r.idReserva);
    
    select sum(te.capacidad)
    from TiposEspacios te
    inner join Espacios e on te.idTipoEspacio = e.tipoEspacio_id
    inner join Reservas r on e.idEspacio = r.espacio_id
    where r.fecha = p_fecha;
    update ReporteDiario rp
    set rp.usuariosActivos = sum(te.capacidad);
    
    select sum(te.precio)
    from TiposEspacios te
    inner join Espacios e on te.idTipoEspacio = e.tipoEspacio_id
    inner join Reservas r on e.idEspacio = r.espacio_id
    where r.fecha = p_fecha;
    update ReporteDiario rp
    set rp.ingresosDia = sum(te.precio);

end$$

delimiter ;

call sp_GenerarReporteDiario('2026-11-2');  -- LLamar al procedimiento con la fecha actual.


-- _________________________________________________________________________________________________
-- Consulta Ahora mismo hay X personas en el coworking.

select sum(te.capacidad) as 'Ahora mismo hay X personas en el coworking'
    from TiposEspacios te
    inner join Espacios e on te.idTipoEspacio = e.tipoEspacio_id
    inner join Reservas r on e.idEspacio = r.espacio_id
    where r.fecha = curdate();


