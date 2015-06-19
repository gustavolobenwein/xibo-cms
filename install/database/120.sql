/* TODO: we need to go through these updates and make sure structure & data.sql are correct */

ALTER TABLE  `layout` ADD  `width` DECIMAL NOT NULL ,
ADD  `height` DECIMAL NOT NULL ,
ADD  `backgroundColor` VARCHAR( 25 ) NULL ,
ADD  `schemaVersion` TINYINT NOT NULL;

ALTER TABLE  `layout` ADD  `backgroundzIndex` INT NOT NULL DEFAULT  '1' AFTER  `backgroundColor`;

CREATE TABLE IF NOT EXISTS `permission` (
  `permissionId` int(11) NOT NULL AUTO_INCREMENT,
  `entityId` int(11) NOT NULL,
  `groupId` int(11) NOT NULL,
  `objectId` int(11) NOT NULL,
  `view` tinyint(4) NOT NULL,
  `edit` tinyint(4) NOT NULL,
  `delete` tinyint(4) NOT NULL,
  PRIMARY KEY (`permissionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `permissionentity` (
  `entityId` int(11) NOT NULL,
  `entity` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `permissionentity` ADD PRIMARY KEY(`entityId`);

ALTER TABLE  `lkusergroup` ADD UNIQUE (  `GroupID` ,  `UserID` ) ;
ALTER TABLE  `lkdisplaydg` ADD UNIQUE (  `DisplayGroupID` ,  `DisplayId` ) ;


/* Take existing permissions and pull them into the permissions table */
INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `objectIdString`, `view`, `edit`, `delete`)
SELECT groupId, 4, NULL, CONCAT(LayoutId, '_', RegionID, '_', MediaID), view, edit, del
  FROM `lklayoutmediagroup`;

DROP TABLE `lklayoutmediagroup`;

INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `objectIdString`, `view`, `edit`, `delete`)
SELECT groupId, 1, campaignId, NULL, view, edit, del
  FROM `lkcampaigngroup`;

DROP TABLE `lkcampaigngroup`;

INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `objectIdString`, `view`, `edit`, `delete`)
  SELECT groupId, 3, NULL, CONCAT(LayoutId, '_', RegionID), view, edit, del
  FROM `lklayoutregiongroup`;

DROP TABLE `lklayoutregiongroup`;

INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `objectIdString`, `view`, `edit`, `delete`)
  SELECT groupId, 6, mediaId, NULL, view, edit, del
  FROM `lkmediagroup`;

DROP TABLE `lkmediagroup`;

INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `view`, `edit`, `delete`)
  SELECT groupId, 1, pageId, 1, 0, 0
  FROM `lkpagegroup`;

DROP TABLE `lkpagegroup`;

INSERT INTO `permission` (`groupId`, `entityId`, `objectId`, `view`, `edit`, `delete`)
  SELECT groupId, 2, menuItemId, 1, 0, 0
  FROM `lkmenuitemgroup`;

DROP TABLE `lkmenuitemgroup`;


/* End permissions swap */

DROP TABLE `lklayoutmedia`;

ALTER TABLE  `log` CHANGE  `type`  `type` VARCHAR( 254 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;

UPDATE  `pages` SET  `name` =  'library' WHERE  `pages`.`name` = 'content';
UPDATE  `pages` SET  `name` =  'applications' WHERE  `pages`.`name` = 'oauth';

/* Update the home page to be a homePageId */
UPDATE `user` SET homepage = IFNULL((SELECT pageId FROM `pages` WHERE pages.name = `user`.homepage), 1);
ALTER TABLE  `user` CHANGE  `homepage`  `homePageId` INT NOT NULL DEFAULT  '1' COMMENT  'The users homepage';


ALTER TABLE `log`
  DROP `scheduleID`,
  DROP `layoutID`,
  DROP `mediaID`;

ALTER TABLE `log`
  DROP `RequestUri`,
  DROP `RemoteAddr`,
  DROP `UserAgent`;

ALTER TABLE  `log` ADD  `channel` VARCHAR( 5 ) NOT NULL AFTER  `logdate`;
ALTER TABLE  `log` ADD  `runNo` VARCHAR( 10 ) NOT NULL AFTER  `logid`;

CREATE TABLE IF NOT EXISTS `lkscheduledisplaygroup` (
  `eventId` int(11) NOT NULL,
  `displayGroupId` int(11) NOT NULL,
  PRIMARY KEY (`eventId`,`displayGroupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE  `schedule_detail` DROP FOREIGN KEY  `schedule_detail_ibfk_8` ;
ALTER TABLE `schedule_detail` DROP `DisplayGroupID`;
ALTER TABLE `schedule` DROP `DisplayGroupIDs`;


CREATE TABLE IF NOT EXISTS `lkregionplaylist` (
  `regionId` int(11) NOT NULL,
  `playlistId` int(11) NOT NULL,
  `displayOrder` int(11) NOT NULL,
  PRIMARY KEY (`regionId`,`playlistId`,`displayOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `lkwidgetmedia` (
  `widgetId` int(11) NOT NULL,
  `mediaId` int(11) NOT NULL,
  PRIMARY KEY (`widgetId`,`mediaId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `playlist` (
  `playlistId` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(254) DEFAULT NULL,
  `ownerId` int(11) NOT NULL,
  PRIMARY KEY (`playlistId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=18 ;

CREATE TABLE IF NOT EXISTS `region` (
  `regionId` int(11) NOT NULL AUTO_INCREMENT,
  `layoutId` int(11) NOT NULL,
  `ownerId` int(11) NOT NULL,
  `name` varchar(254) DEFAULT NULL,
  `width` decimal(12,4) NOT NULL,
  `height` decimal(12,4) NOT NULL,
  `top` decimal(12,4) NOT NULL,
  `left` decimal(12,4) NOT NULL,
  `zIndex` smallint(6) NOT NULL,
  PRIMARY KEY (`regionId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=14 ;

CREATE TABLE IF NOT EXISTS `regionoption` (
  `regionId` int(11) NOT NULL,
  `option` varchar(50) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`regionId`,`option`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `widget` (
  `widgetId` int(11) NOT NULL AUTO_INCREMENT,
  `playlistId` int(11) NOT NULL,
  `ownerId` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `duration` int(11) NOT NULL,
  `displayOrder` int(11) NOT NULL,
  PRIMARY KEY (`widgetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `widgetoption` (
  `widgetId` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `option` varchar(254) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`widgetId`,`type`,`option`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE  `module` ADD  `viewPath` VARCHAR( 254 ) NOT NULL DEFAULT  '../modules';

UPDATE `version` SET `app_ver` = '1.8.0-alpha', `XmdsVersion` = 4, `XlfVersion` = 2;
UPDATE `setting` SET `value` = 0 WHERE `setting` = 'PHONE_HOME_DATE';
UPDATE `version` SET `DBVersion` = '120';