if db_id('Geocaches') is not null
BEGIN
	ALTER DATABASE Geocaches SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE geocaches;
end

create database Geocaches;
alter database Geocaches modify file 
	(NAME = N'Geocaches', SIZE = 100MB , FILEGROWTH = 2MB);

alter database Geocaches modify file
	(NAME = N'Geocaches_log', SIZE = 100MB , FILEGROWTH = 2MB);

ALTER DATABASE Geocaches SET RECOVERY FULL;
ALTER DATABASE Geocaches SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE Geocaches SET AUTO_UPDATE_STATISTICS_ASYNC ON;