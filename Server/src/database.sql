DROP TABLE IF EXISTS `baidumusic`;

CREATE TABLE `baidumusic` (
  `musicid` int(32) NOT NULL DEFAULT '0',
  `baidumusicid` int(32) NOT NULL DEFAULT '0',
  `songlink` varchar(1024) DEFAULT NULL,
  `lyriclink` varchar(1024) DEFAULT NULL,
  `smallcoverlink` varchar(1024) DEFAULT NULL,
  `bigcoverlink` varchar(1024) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `device`;

CREATE TABLE `device` (
  `userid` int(11) NOT NULL,
  `devicename` varchar(128) NOT NULL DEFAULT '',
  `state` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `listenlist`;

CREATE TABLE `listenlist` (
  `userid` int(11) NOT NULL,
  `musicid` int(11) NOT NULL,
  `times` int(32) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `localmusic`;

CREATE TABLE `localmusic` (
  `musicid` int(32) NOT NULL,
  `path` varchar(128) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `lovelist`;

CREATE TABLE `lovelist` (
  `userid` int(11) NOT NULL,
  `musicid` int(11) NOT NULL,
  `time` int(11) NOT NULL,
  `degree` int(11) NOT NULL DEFAULT '1'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `music`;

CREATE TABLE `music` (
  `musicid` int(32) unsigned NOT NULL AUTO_INCREMENT,
  `musicname` varchar(512) NOT NULL DEFAULT '',
  `authorname` varchar(512) NOT NULL DEFAULT '',
  `albumname` varchar(512) DEFAULT NULL,
  `time` int(32) DEFAULT '0',
  `type` int(2) DEFAULT '1',
  PRIMARY KEY (`musicid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `userid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL DEFAULT '',
  `password` varchar(32) NOT NULL DEFAULT '',
  `sex` varchar(4) NOT NULL DEFAULT '',
  `age` int(32) NOT NULL,
  `registertime` int(64) NOT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOCK TABLES `user` WRITE;

INSERT INTO `user` (`userid`, `username`, `password`, `sex`, `age`, `registertime`)
VALUES
  (1,'1','1','男',15,1431391280),
  (2,'2','\' or 1=1','男',15,1431391317),
  (3,'hello','1f81176b232f895d238814e81417e1a2','男',15,1431392075),
  (4,'hello1','55e6189a823b5c4b1ead846194d99ce7','男',15,1431392430),
  (5,'hello2','5f6801813ba54424fbc505db3e0d3181','男',15,1431392460),
  (6,'111','06e823620b1c0b7d00ecc58d48d734bb','男',15,1431439378),
  (7,'rt','9ce7cf1231b69adb801311e0a4bb0fbf','男',15,1432173147);

UNLOCK TABLES;
