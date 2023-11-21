# Тестовое задание PHP

Есть клиенты clients, которые посещают занятия sessions. Их отметка о посещении хранится в таблице session_members.

Занятия идут на постоянной основе, поэтому таблица sessions автоматически пополняется новыми занятиями каждый день на основе таблицы session_configurations, которая отвечает за то, как должны создаваться записи в таблице sessions.

Так получилось, что в коде была допущена ошибка, из-за которой создались дубликаты записей в таблице занятий sessions, что привело уже к другой ошибке – клиенты были отмечены, как на занятиях оригиналах, так и на занятиях-дублях (см. данные в  session_members).

Необходимо систему вернуть к её устойчивому состоянию, которое предполагает, что:
1. Может проходить только одно занятие в определённое время, созданное по определённой конфигурации. Не может быть такого, что в таблице  sessions есть несколько записей, у который start_time и session_configuration_id повторяются.
2. Клиент может быть отмечен только 1 раз на занятии. Не может быть такого, что в таблице session_members есть несколько записей, у которых session_id и client_id повторяются.

Для этого потребуется написать запрос SQL и/или PHP-код – на ваш выбор, т.е. вы можете написать всё на “чистом” SQL, а можете прибегнуть к использованию PHP, чтобы получать данные из БД и производить с ними манипуляция. После выполнения запросов в таблице sessions должны остаться только оригинальные занятия, т.е. все дубликаты должны удалиться. При этом, если на занятия-дубликаты уже были отмечены клиенты, то их отметки должны перенестись на занятия-оригиналы (могут быть ситуации, когда клиент был отмечен на занятие-дубликате, и не был отмечен на занятие-оригинале – в таких случаях его отметку нужно перенести на занятие-оригинал).

### Окружение
- PHP 8
- MySQL 8
### Schema

~~~sql 
create table `clients`
(
id            bigint unsigned auto_increment primary key,
first_name    varchar(255)            not null,
last_name     varchar(255)            null
)  collate = utf8mb4_unicode_ci;

create table `session_configurations`
(
id               bigint unsigned auto_increment primary key,
day_number       int          not null,
start_time       time         not null,
duration_minutes varchar(255) not null,
start_date       datetime     null
) collate = utf8mb4_unicode_ci;

create table `sessions`
(
id                       bigint unsigned auto_increment primary key,
start_time               datetime        not null,
session_configuration_id bigint unsigned not null
) collate = utf8mb4_unicode_ci;

create table `session_members`
(
id              bigint unsigned auto_increment primary key,
session_id      bigint unsigned not null,
client_id       bigint unsigned not null,
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
