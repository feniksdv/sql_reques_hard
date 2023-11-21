create table `clients`
(
    id bigint unsigned auto_increment primary key,
    first_name varchar(255) not null,
    last_name varchar(255) null
) collate = utf8mb4_unicode_ci;

create table `session_configurations`
(
    id bigint unsigned auto_increment primary key,
    day_number int not null,
    start_time time not null,
    duration_minutes varchar(255) not null,
    start_date datetime null
) collate = utf8mb4_unicode_ci;

create table `sessions`
(
    id bigint unsigned auto_increment primary key,
    start_time datetime not null,
    session_configuration_id bigint unsigned not null
) collate = utf8mb4_unicode_ci;

create table `session_members`
(
    id bigint unsigned auto_increment primary key,
    session_id bigint unsigned not null,
    client_id bigint unsigned not null,
    constraint session_members_session_id_foreign
    foreign key (session_id) references sessions (id)
    on delete cascade,
    constraint session_members_client_id_foreign
    foreign key (client_id) references clients (id)
    on delete cascade
) collate = utf8mb4_unicode_ci;

insert into `clients` values
    (1,'Иван', 'Иванов'),
    (2,'Василиса', 'Краснова');

insert into `session_configurations` values
    (1,1,'17:00:00','60','2023-08-21'),
    (2,2,'17:00:00','60','2023-08-22');

insert into `sessions` values
    (1,'2023-08-21 17:00:00',1),
    (2,'2023-08-28 17:00:00',1),
    (3,'2023-08-22 17:00:00',2),
    (4,'2023-08-29 17:00:00',2),
    (5,'2023-08-21 17:00:00',1),
    (6,'2023-08-22 17:00:00',2),
    (7,'2023-08-22 17:00:00',2);

insert into `session_members` values
    (1,1,1),
    (2,1,2),
    (3,2,1),
    (4,2,2),
    (5,3,1),
    (6,3,2),
    (7,5,1),
    (8,7,1),
    (9,7,2);

ALTER TABLE sessions
    ADD COLUMN status VARCHAR(255) DEFAULT NULL AFTER session_configuration_id,
    ADD COLUMN status_id INT DEFAULT NULL AFTER status;

--- Подготовка таблицы
UPDATE sessions AS s1
JOIN (
    SELECT MIN(id) AS MIN_ID, start_time, session_configuration_id
    FROM sessions
    GROUP BY start_time, session_configuration_id
) AS s2 ON s1.start_time = s2.start_time AND s1.session_configuration_id = s2.session_configuration_id
SET s1.status = CASE
WHEN s1.id = s2.MIN_ID THEN 'origin'
ELSE 'double'
END,
s1.status_id = CASE
WHEN s1.status = 'double' THEN s2.MIN_ID
ELSE s1.status_id
END;

--- перенос отметок
UPDATE session_members AS sm
JOIN sessions AS s ON sm.session_id = s.id
SET sm.session_id = CASE
WHEN s.status = 'double' THEN s.status_id
ELSE sm.session_id
END
WHERE s.status = 'double';

--- Удалить дубли в sessions
DELETE s1
FROM sessions s1
JOIN sessions s2 ON s1.start_time = s2.start_time
AND s1.session_configuration_id = s2.session_configuration_id
AND s1.id > s2.id;
ALTER TABLE sessions
DROP COLUMN status_id,
DROP COLUMN status;

--- Удалить дубли в session_members
DELETE sm1
FROM session_members sm1
JOIN session_members sm2 ON sm1.session_id = sm2.session_id
AND sm1.client_id = sm2.client_id
AND sm1.id > sm2.id;