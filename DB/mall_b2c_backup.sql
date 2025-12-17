-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: mall_b2c
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cms_comment`
--

DROP TABLE IF EXISTS `cms_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint DEFAULT NULL,
  `member_nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_com_pro` (`product_id`),
  CONSTRAINT `fk_com_pro` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_comment`
--

LOCK TABLES `cms_comment` WRITE;
/*!40000 ALTER TABLE `cms_comment` DISABLE KEYS */;
INSERT INTO `cms_comment` VALUES (1,2,'测试用户','不好用','2025-12-05 01:17:33'),(2,2,'111','好用','2025-12-05 01:24:12'),(3,4,'222','一般','2025-12-05 12:02:33'),(4,7,'111','很好！','2025-12-15 16:52:25'),(5,9,'111','111','2025-12-16 21:28:33');
/*!40000 ALTER TABLE `cms_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oms_cart_item`
--

DROP TABLE IF EXISTS `oms_cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oms_cart_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `product_sku_id` bigint DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `product_attr` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL COMMENT '添加时价格',
  `product_pic` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品图片',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品名称',
  `product_sku_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'SKU条码',
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `fk_cart_mem` (`member_id`),
  KEY `fk_cart_pro` (`product_id`),
  CONSTRAINT `fk_cart_mem` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_pro` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oms_cart_item`
--

LOCK TABLES `oms_cart_item` WRITE;
/*!40000 ALTER TABLE `oms_cart_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `oms_cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oms_order`
--

DROP TABLE IF EXISTS `oms_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oms_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '总金额',
  `status` int DEFAULT NULL COMMENT '0->待付款;1->待发货;2->已发货;3->已完成',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `receiver_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `receiver_detail_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_sn` (`order_sn`),
  KEY `fk_order_member` (`member_id`),
  KEY `idx_order_sn` (`order_sn`),
  CONSTRAINT `fk_order_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oms_order`
--

LOCK TABLES `oms_order` WRITE;
/*!40000 ALTER TABLE `oms_order` DISABLE KEYS */;
INSERT INTO `oms_order` VALUES (1,1,'2c1ad97c-d135-11f0-a907-b0dcef5e70c6','2025-12-05 01:17:55',4999.00,3,'张三','13800000000','北京市海淀区'),(2,2,'2ca2a18a-d136-11f0-87a2-b0dcef5e70c6','2025-12-05 01:25:05',9999.00,2,'111','111','默认地址：学校/公司/家'),(3,2,'77e5bb98-d137-11f0-80e7-b0dcef5e70c6','2025-12-05 01:34:21',9999.00,3,'111','111','默认地址：学校/公司/家'),(4,2,'a7fe5c22-d137-11f0-9b18-b0dcef5e70c6','2025-12-05 01:35:42',9899.00,1,'111','111','默认地址：学校/公司/家'),(5,2,'93a224c1-d138-11f0-97e8-b0dcef5e70c6','2025-12-05 01:42:17',9949.00,1,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(6,2,'9d2fe7a2-d139-11f0-92d2-b0dcef5e70c6','2025-12-05 01:49:42',222.00,2,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(7,3,'522bd6b3-d18c-11f0-8199-b0dcef5e70c6','2025-12-05 11:41:45',4899.00,3,'Yang222','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(8,3,'38f3c3f6-d1a3-11f0-8286-b0dcef5e70c6','2025-12-05 14:25:41',2222.00,2,'Yang222','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(9,2,'5b1b19cc-d8ce-11f0-b08a-b0dcef5e70c6','2025-12-14 17:22:05',220.00,4,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(10,2,'9ec25f47-d8d4-11f0-bfeb-b0dcef5e70c6','2025-12-14 18:06:55',275.00,4,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(11,1,'1656ab3e-d96e-11f0-9f90-b0dcef5e70c6','2025-12-15 12:25:29',59.40,3,'张三','13800000000','北京市海淀区'),(12,2,'202512161505242','2025-12-16 15:05:24',600.00,1,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(13,2,'202512161845242','2025-12-16 18:45:24',100.00,3,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province'),(14,2,'202512162128502','2025-12-16 21:28:50',432.00,4,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province');
/*!40000 ALTER TABLE `oms_order` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = gbk */ ;
/*!50003 SET character_set_results = gbk */ ;
/*!50003 SET collation_connection  = gbk_chinese_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `t_order_complete_log` AFTER UPDATE ON `oms_order` FOR EACH ROW BEGIN
    
    IF OLD.status <> 3 AND NEW.status = 3 THEN
        INSERT INTO sys_log (content) 
        VALUES (CONCAT('���� ', NEW.order_sn, ' ����ɽ��ף���', NEW.total_amount));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `oms_order_item`
--

DROP TABLE IF EXISTS `oms_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oms_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL,
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `product_sku_id` bigint DEFAULT NULL,
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `product_price` decimal(10,2) DEFAULT NULL,
  `product_quantity` int DEFAULT NULL,
  `product_attr` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '购买时属性:颜色尺码',
  PRIMARY KEY (`id`),
  KEY `fk_item_order` (`order_id`),
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `oms_order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oms_order_item`
--

LOCK TABLES `oms_order_item` WRITE;
/*!40000 ALTER TABLE `oms_order_item` DISABLE KEYS */;
INSERT INTO `oms_order_item` VALUES (1,1,'2c1ad97c-d135-11f0-a907-b0dcef5e70c6',2,4,'Xiaomi 14 Pro',4999.00,1,'岩石青 12G+256G'),(2,2,'2ca2a18a-d136-11f0-87a2-b0dcef5e70c6',1,3,'iPhone 15 Pro Max',9999.00,1,'黑色钛金属 256G'),(3,3,'77e5bb98-d137-11f0-80e7-b0dcef5e70c6',1,3,'iPhone 15 Pro Max',9999.00,1,'黑色钛金属 256G'),(4,4,'a7fe5c22-d137-11f0-9b18-b0dcef5e70c6',1,3,'iPhone 15 Pro Max',9999.00,1,'黑色钛金属 256G'),(5,5,'93a224c1-d138-11f0-97e8-b0dcef5e70c6',1,3,'iPhone 15 Pro Max',9999.00,1,'黑色钛金属 256G'),(6,6,'9d2fe7a2-d139-11f0-92d2-b0dcef5e70c6',3,5,'《深度学习》书籍',111.00,2,'默认规格'),(7,7,'522bd6b3-d18c-11f0-8199-b0dcef5e70c6',2,4,'Xiaomi 14 Pro',4999.00,1,'岩石青 12G+256G'),(8,8,'38f3c3f6-d1a3-11f0-8286-b0dcef5e70c6',5,7,'头盔',1111.00,2,'规格1'),(9,9,'5b1b19cc-d8ce-11f0-b08a-b0dcef5e70c6',6,8,'Ptoduct1',22.00,10,'1'),(10,10,'9ec25f47-d8d4-11f0-bfeb-b0dcef5e70c6',6,8,'Ptoduct1',22.00,13,'1'),(11,11,'1656ab3e-d96e-11f0-9f90-b0dcef5e70c6',6,9,'Ptoduct1',33.00,2,'2'),(12,12,'202512161505242',7,12,'Product-01',300.00,2,'规格3'),(13,13,'202512161845242',7,10,'Product-01',100.00,1,'规格1'),(14,14,'202512162128502',9,16,'1218',222.00,2,'规格2');
/*!40000 ALTER TABLE `oms_order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oms_order_return_apply`
--

DROP TABLE IF EXISTS `oms_order_return_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oms_order_return_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL,
  `status` int DEFAULT '0' COMMENT '0->待处理',
  `reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_return_order` (`order_id`),
  CONSTRAINT `fk_return_order` FOREIGN KEY (`order_id`) REFERENCES `oms_order` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oms_order_return_apply`
--

LOCK TABLES `oms_order_return_apply` WRITE;
/*!40000 ALTER TABLE `oms_order_return_apply` DISABLE KEYS */;
INSERT INTO `oms_order_return_apply` VALUES (1,10,1,'不要了','2025-12-15 21:02:16'),(2,10,1,'111','2025-12-15 21:02:26'),(3,10,1,'111','2025-12-15 21:02:29'),(4,9,1,'1','2025-12-15 21:31:20'),(5,3,2,'2','2025-12-15 21:31:33'),(6,14,1,'111','2025-12-16 21:29:22');
/*!40000 ALTER TABLE `oms_order_return_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pms_brand`
--

DROP TABLE IF EXISTS `pms_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pms_brand` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '名称',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Logo',
  `product_count` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pms_brand`
--

LOCK TABLES `pms_brand` WRITE;
/*!40000 ALTER TABLE `pms_brand` DISABLE KEYS */;
INSERT INTO `pms_brand` VALUES (1,'Apple','https://img14.360buyimg.com/n1/jfs/t1/202062/12/35560/94467/650cf5eeF67e58428/8a159f518e388273.jpg',100),(2,'小米','https://img14.360buyimg.com/n1/jfs/t1/157002/26/36465/86266/653b6e80Ff7b44535/5341400626359d9f.jpg',50),(3,'北斗',NULL,0),(4,'111',NULL,0),(5,'测定品牌',NULL,0);
/*!40000 ALTER TABLE `pms_brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pms_category`
--

DROP TABLE IF EXISTS `pms_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pms_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint DEFAULT '0' COMMENT '上级ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '名称',
  `level` int DEFAULT NULL COMMENT '层级:0->1级',
  `sort` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pms_category`
--

LOCK TABLES `pms_category` WRITE;
/*!40000 ALTER TABLE `pms_category` DISABLE KEYS */;
INSERT INTO `pms_category` VALUES (1,0,'手机数码',0,1),(2,0,'家用电器',0,2),(3,0,'日常用品',0,0),(4,0,'111',0,0),(5,0,'测试分类',0,0);
/*!40000 ALTER TABLE `pms_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pms_product`
--

DROP TABLE IF EXISTS `pms_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pms_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `brand_id` bigint DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `pic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '主图',
  `product_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '货号',
  `publish_status` tinyint DEFAULT '0' COMMENT '上架状态',
  `delete_status` tinyint DEFAULT '0' COMMENT '删除状态:0->未删;1->已删',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `sale` int DEFAULT '0' COMMENT '销量',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '详情',
  PRIMARY KEY (`id`),
  KEY `fk_pro_cat` (`category_id`),
  KEY `fk_pro_brand` (`brand_id`),
  KEY `idx_product_name` (`name`),
  CONSTRAINT `fk_pro_brand` FOREIGN KEY (`brand_id`) REFERENCES `pms_brand` (`id`),
  CONSTRAINT `fk_pro_cat` FOREIGN KEY (`category_id`) REFERENCES `pms_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pms_product`
--

LOCK TABLES `pms_product` WRITE;
/*!40000 ALTER TABLE `pms_product` DISABLE KEYS */;
INSERT INTO `pms_product` VALUES (1,1,1,'iPhone 15 Pro Max','https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/iphone-15-pro-max.png','NO.1001',0,1,9999.00,500,NULL),(2,2,1,'Xiaomi 14 Pro','https://cdn.cnbj0.fds.api.mi-img.com/b2c-shopapi-pms/pms_1758612893.86335067.png','NO.1002',1,0,4999.00,1000,NULL),(3,2,2,'《深度学习》书籍','https://dummyimage.com/600x600/000/fff.jpg&text=New+Product','N0.001',0,1,111.00,0,NULL),(4,3,3,'头盔','https://picx.zhimg.com/v2-2f80a693af58fdb9affb4a84204b5ba1_1440w.jpg','NO.12',0,1,122.00,0,NULL),(5,3,3,'头盔','https://pic3.zhimg.com/v2-3a97ad5fc8cf0edc32b2e1f77b6f0b18_1440w.jpg','N0.002',0,1,1111.00,0,NULL),(6,4,4,'Ptoduct1','https://dummyimage.com/600x600/000/fff.jpg&text=Product','111',1,0,22.00,0,NULL),(7,5,5,'Product-01','https://picx.zhimg.com/v2-2f80a693af58fdb9affb4a84204b5ba1_1440w.jpg','123',1,0,100.00,0,NULL),(8,1,1,'1','https://dummyimage.com/600x600/000/fff.jpg&text=Product','1',1,0,111.00,0,NULL),(9,2,1,'1218','https://dummyimage.com/600x600/000/fff.jpg&text=Product','1218',1,0,111.00,0,NULL);
/*!40000 ALTER TABLE `pms_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pms_sku_stock`
--

DROP TABLE IF EXISTS `pms_sku_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pms_sku_stock` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint DEFAULT NULL COMMENT '商品ID',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'sku编码',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `stock` int DEFAULT '0' COMMENT '库存',
  `sp_data` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '销售属性JSON',
  PRIMARY KEY (`id`),
  KEY `fk_sku_pro` (`product_id`),
  CONSTRAINT `fk_sku_pro` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pms_sku_stock`
--

LOCK TABLES `pms_sku_stock` WRITE;
/*!40000 ALTER TABLE `pms_sku_stock` DISABLE KEYS */;
INSERT INTO `pms_sku_stock` VALUES (3,1,'2023001',9999.00,96,'黑色钛金属 256G'),(4,2,'2023002',4999.00,698,'岩石青 12G+256G'),(5,3,'N0.001_SKU',111.00,98,'默认规格'),(6,4,'NO.12_SKU',122.00,200,'默认规格'),(7,5,'N0.002_SKU',1111.00,98,'规格1'),(8,6,'111_1',22.00,77,'1'),(9,6,'111_2',33.00,98,'2'),(10,7,'123_1',100.00,149,'规格1'),(11,7,'123_2',200.00,100,'规格2'),(12,7,'123_3',300.00,98,'规格3'),(13,8,'1_0',111.00,100,'11'),(14,8,'1_1',222.00,100,'22'),(15,9,'1218_0',111.00,150,'规格1'),(16,9,'1218_1',222.00,198,'规格2');
/*!40000 ALTER TABLE `pms_sku_stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_coupon`
--

DROP TABLE IF EXISTS `sms_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '名称',
  `amount` decimal(10,2) DEFAULT NULL COMMENT '金额',
  `min_point` decimal(10,2) DEFAULT NULL COMMENT '门槛',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `publish_count` int DEFAULT '100' COMMENT '发行数量',
  `receive_count` int DEFAULT '0' COMMENT '已领取数量',
  `start_time` datetime DEFAULT NULL COMMENT '生效时间',
  `enable_status` int DEFAULT '1' COMMENT '状态：0->下架；1->上架',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_coupon`
--

LOCK TABLES `sms_coupon` WRITE;
/*!40000 ALTER TABLE `sms_coupon` DISABLE KEYS */;
INSERT INTO `sms_coupon` VALUES (1,'开业大酬宾',100.00,500.00,'2025-12-31 23:59:59',100,2,NULL,1),(2,'手慢无（测试券）',50.00,100.00,'2025-12-31 23:59:59',2,1,NULL,1),(4,'12/14 test',11.00,111.00,'2025-12-14 21:05:00',100,1,'2025-12-14 18:05:00',1),(8,'1216',12.00,100.00,'2025-12-17 22:27:00',100,1,'2025-12-16 21:27:00',1);
/*!40000 ALTER TABLE `sms_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_coupon_history`
--

DROP TABLE IF EXISTS `sms_coupon_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_coupon_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint DEFAULT NULL,
  `member_id` bigint DEFAULT NULL,
  `use_status` int DEFAULT '0' COMMENT '0->未使用',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  PRIMARY KEY (`id`),
  KEY `fk_ch_coupon` (`coupon_id`),
  KEY `fk_ch_member` (`member_id`),
  CONSTRAINT `fk_ch_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `sms_coupon` (`id`),
  CONSTRAINT `fk_ch_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_coupon_history`
--

LOCK TABLES `sms_coupon_history` WRITE;
/*!40000 ALTER TABLE `sms_coupon_history` DISABLE KEYS */;
INSERT INTO `sms_coupon_history` VALUES (1,1,2,1,'2025-12-05 01:35:42'),(2,2,2,1,'2025-12-05 01:42:17'),(3,1,3,1,'2025-12-05 11:41:45'),(4,4,2,1,'2025-12-14 18:06:55'),(5,8,2,1,'2025-12-16 21:28:50');
/*!40000 ALTER TABLE `sms_coupon_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_admin`
--

DROP TABLE IF EXISTS `sys_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_admin` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `nick_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int DEFAULT '1' COMMENT '帐号状态: 0->禁用; 1->启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `fk_admin_role` (`role_id`),
  CONSTRAINT `fk_admin_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_admin`
--

LOCK TABLES `sys_admin` WRITE;
/*!40000 ALTER TABLE `sys_admin` DISABLE KEYS */;
INSERT INTO `sys_admin` VALUES (1,1,'admin','123456','SuperAdmin',1);
/*!40000 ALTER TABLE `sys_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_log`
--

DROP TABLE IF EXISTS `sys_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_log`
--

LOCK TABLES `sys_log` WRITE;
/*!40000 ALTER TABLE `sys_log` DISABLE KEYS */;
INSERT INTO `sys_log` VALUES (1,'订单 5b1b19cc-d8ce-11f0-b08a-b0dcef5e70c6 已完成交易，金额：220.00','2025-12-14 17:24:05'),(2,'订单 9ec25f47-d8d4-11f0-bfeb-b0dcef5e70c6 已完成交易，金额：275.00','2025-12-14 18:09:07'),(3,'订单 1656ab3e-d96e-11f0-9f90-b0dcef5e70c6 已完成交易，金额：59.40','2025-12-15 12:26:06'),(4,'订单 2c1ad97c-d135-11f0-a907-b0dcef5e70c6 已完成交易，金额：4999.00','2025-12-15 12:26:09'),(5,'订单 202512161845242 已完成交易，金额：100.00','2025-12-16 21:26:00'),(6,'订单 202512162128502 已完成交易，金额：432.00','2025-12-16 21:29:17');
/*!40000 ALTER TABLE `sys_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '角色名:超级管理员/客服',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员'),(2,'普通客服');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ums_member`
--

DROP TABLE IF EXISTS `ums_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ums_member` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_level_id` bigint DEFAULT NULL COMMENT '会员等级ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户名',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '密码',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '昵称',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '手机号',
  `status` tinyint DEFAULT '1' COMMENT '帐号状态:0->禁用；1->启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `phone` (`phone`),
  KEY `fk_member_level` (`member_level_id`),
  CONSTRAINT `fk_member_level` FOREIGN KEY (`member_level_id`) REFERENCES `ums_member_level` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ums_member`
--

LOCK TABLES `ums_member` WRITE;
/*!40000 ALTER TABLE `ums_member` DISABLE KEYS */;
INSERT INTO `ums_member` VALUES (1,2,'test_user','123456','测试用户','13800000000',2,'2025-12-05 00:07:12'),(2,1,'111','111','111','111',1,'2025-12-05 01:06:59'),(3,1,'222','222','222','222',1,'2025-12-05 11:38:16');
/*!40000 ALTER TABLE `ums_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ums_member_level`
--

DROP TABLE IF EXISTS `ums_member_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ums_member_level` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '等级名称',
  `growth_point` int DEFAULT NULL COMMENT '所需成长值',
  `priviledge_free_freight` tinyint DEFAULT NULL COMMENT '是否有免邮特权',
  `discount` decimal(10,2) DEFAULT '1.00' COMMENT '折扣率: 1.00=原价, 0.90=九折',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ums_member_level`
--

LOCK TABLES `ums_member_level` WRITE;
/*!40000 ALTER TABLE `ums_member_level` DISABLE KEYS */;
INSERT INTO `ums_member_level` VALUES (1,'普通会员',0,NULL,1.00),(2,'黄金会员',1000,NULL,0.90);
/*!40000 ALTER TABLE `ums_member_level` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ums_member_receive_address`
--

DROP TABLE IF EXISTS `ums_member_receive_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ums_member_receive_address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint DEFAULT NULL COMMENT '会员ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '收货人',
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '电话',
  `detail_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '详细地址',
  `default_status` tinyint DEFAULT '0' COMMENT '是否默认',
  PRIMARY KEY (`id`),
  KEY `fk_addr_member` (`member_id`),
  CONSTRAINT `fk_addr_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ums_member_receive_address`
--

LOCK TABLES `ums_member_receive_address` WRITE;
/*!40000 ALTER TABLE `ums_member_receive_address` DISABLE KEYS */;
INSERT INTO `ums_member_receive_address` VALUES (1,1,'张三','13800000000','北京市海淀区',1),(2,2,'111','111','默认地址：学校/公司/家',0),(3,2,'Yang','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province',1),(4,3,'222','222','默认地址：学校/公司/家',0),(5,3,'Yang222','15897652956','Wuhan University of Technology, No. 258 Xiongchu Avenue, Hongshan District, Wuhan City, Hubei Province',1);
/*!40000 ALTER TABLE `ums_member_receive_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_order_detail`
--

DROP TABLE IF EXISTS `v_order_detail`;
/*!50001 DROP VIEW IF EXISTS `v_order_detail`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_order_detail` AS SELECT 
 1 AS `id`,
 1 AS `order_sn`,
 1 AS `member_id`,
 1 AS `product_name`,
 1 AS `product_price`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `wms_ware_info`
--

DROP TABLE IF EXISTS `wms_ware_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_ware_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_ware_info`
--

LOCK TABLES `wms_ware_info` WRITE;
/*!40000 ALTER TABLE `wms_ware_info` DISABLE KEYS */;
INSERT INTO `wms_ware_info` VALUES (1,'北京总仓');
/*!40000 ALTER TABLE `wms_ware_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_ware_sku`
--

DROP TABLE IF EXISTS `wms_ware_sku`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_ware_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint DEFAULT NULL,
  `ware_id` bigint DEFAULT NULL,
  `stock` int DEFAULT NULL,
  `stock_locked` int DEFAULT '0' COMMENT '锁定库存(待发货)',
  PRIMARY KEY (`id`),
  KEY `fk_wms_sku` (`sku_id`),
  KEY `fk_wms_ware` (`ware_id`),
  CONSTRAINT `fk_wms_sku` FOREIGN KEY (`sku_id`) REFERENCES `pms_sku_stock` (`id`),
  CONSTRAINT `fk_wms_ware` FOREIGN KEY (`ware_id`) REFERENCES `wms_ware_info` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_ware_sku`
--

LOCK TABLES `wms_ware_sku` WRITE;
/*!40000 ALTER TABLE `wms_ware_sku` DISABLE KEYS */;
INSERT INTO `wms_ware_sku` VALUES (2,4,1,500,0),(3,6,1,100,0),(4,10,1,50,0),(5,15,1,50,0);
/*!40000 ALTER TABLE `wms_ware_sku` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_order_detail`
--

/*!50001 DROP VIEW IF EXISTS `v_order_detail`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = gbk */;
/*!50001 SET character_set_results     = gbk */;
/*!50001 SET collation_connection      = gbk_chinese_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_order_detail` AS select `o`.`id` AS `id`,`o`.`order_sn` AS `order_sn`,`o`.`member_id` AS `member_id`,`oi`.`product_name` AS `product_name`,`oi`.`product_price` AS `product_price` from (`oms_order` `o` join `oms_order_item` `oi` on((`o`.`id` = `oi`.`order_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-16 22:25:25
