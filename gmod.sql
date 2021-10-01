SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `nAdmin_users` (
  `accountid` int(11) NOT NULL,
  `usergroup` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `nAdmin_bans` (
  `ind` int(11) NOT NULL,
  `plyban` text NOT NULL,
  `reason` text NOT NULL,
  `time` float NOT NULL,
  `banned_by` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `nAdmin_time` (
  `infoid` int(11) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_bin;

CREATE TABLE `nAdmin_users` (
  `accountid` int(11) NOT NULL,
  `usergroup` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `achievements`
  ADD PRIMARY KEY (`accountid`),
  ADD UNIQUE KEY `accountid` (`accountid`),
  ADD UNIQUE KEY `accountid_2` (`accountid`);

ALTER TABLE `nAdmin_bans`
  ADD UNIQUE KEY `ind` (`ind`);

ALTER TABLE `nAdmin_time`
  ADD PRIMARY KEY (`infoid`);

ALTER TABLE `nAdmin_users`
  ADD PRIMARY KEY (`accountid`),
  ADD UNIQUE KEY `accountid` (`accountid`);
COMMIT;
