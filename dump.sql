CREATE DATABASE  IF NOT EXISTS `techpoint` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `techpoint`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: techpoint
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `cpf` char(11) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `endereco` text,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf` (`cpf`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'joão silva','12345678901','joao.silva@email.com',NULL,'rua x, 100 - são paulo',1),(2,'maria fernanda','23456789012','maria.f@email.com',NULL,'rua y, 200 - rio',1),(3,'paula martins','22334455667','paula.m@email.com',NULL,'av y, 200 - salvador',1),(4,'thiago rocha','33445566778','thiago.r@email.com',NULL,'rua z, 300 - recife',1),(5,'larissa melo','44556677889','larissa.m@email.com',NULL,'av w, 400 - fortaleza',1),(6,'rafael alves','55667788990','rafael.a@email.com',NULL,'rua v, 500 - manaus',1);
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estoque_log`
--

DROP TABLE IF EXISTS `estoque_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estoque_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `produto_id` int NOT NULL,
  `quantidade_anterior` int NOT NULL,
  `quantidade_nova` int NOT NULL,
  `data_atualizacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `estoque_log_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produto` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque_log`
--

LOCK TABLES `estoque_log` WRITE;
/*!40000 ALTER TABLE `estoque_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `estoque_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fornecedor`
--

DROP TABLE IF EXISTS `fornecedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fornecedor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `cpf_cnpj` varchar(14) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `endereco` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf_cnpj` (`cpf_cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fornecedor`
--

LOCK TABLES `fornecedor` WRITE;
/*!40000 ALTER TABLE `fornecedor` DISABLE KEYS */;
INSERT INTO `fornecedor` VALUES (1,'Tech Supplies LTDA','12345678000199','11-98765-4321','av principal, 1000 - são paulo'),(2,'José da Silva','78945612300','21-97654-3210','rua das flores, 500 - rio de janeiro'),(3,'Infor Solutions ME','98765432000188','31-96543-2109','av liberdade, 800 - belo horizonte');
/*!40000 ALTER TABLE `fornecedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_pedido`
--

DROP TABLE IF EXISTS `item_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_pedido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `produto_id` int DEFAULT NULL,
  `servico_id` int DEFAULT NULL,
  `quantidade` int NOT NULL,
  `preco_unitario` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `produto_id` (`produto_id`),
  KEY `servico_id` (`servico_id`),
  CONSTRAINT `item_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedido` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_pedido_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produto` (`id`),
  CONSTRAINT `item_pedido_ibfk_3` FOREIGN KEY (`servico_id`) REFERENCES `servico` (`id`),
  CONSTRAINT `chk_item_produto_servico` CHECK ((((`produto_id` is not null) and (`servico_id` is null)) or ((`produto_id` is null) and (`servico_id` is not null)))),
  CONSTRAINT `item_pedido_chk_1` CHECK ((`quantidade` > 0)),
  CONSTRAINT `item_pedido_chk_2` CHECK ((`preco_unitario` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_pedido`
--

LOCK TABLES `item_pedido` WRITE;
/*!40000 ALTER TABLE `item_pedido` DISABLE KEYS */;
/*!40000 ALTER TABLE `item_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `usuario_id` int DEFAULT NULL,
  `data_pedido` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`),
  CONSTRAINT `pedido_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`),
  CONSTRAINT `pedido_chk_1` CHECK ((`total` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido`
--

LOCK TABLES `pedido` WRITE;
/*!40000 ALTER TABLE `pedido` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produto`
--

DROP TABLE IF EXISTS `produto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` text,
  `preco` int NOT NULL,
  `estoque` int NOT NULL DEFAULT '0',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `fornecedor_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fornecedor_id` (`fornecedor_id`),
  CONSTRAINT `produto_ibfk_1` FOREIGN KEY (`fornecedor_id`) REFERENCES `fornecedor` (`id`),
  CONSTRAINT `produto_chk_1` CHECK ((`preco` >= 0)),
  CONSTRAINT `produto_chk_2` CHECK ((`estoque` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produto`
--

LOCK TABLES `produto` WRITE;
/*!40000 ALTER TABLE `produto` DISABLE KEYS */;
INSERT INTO `produto` VALUES (1,'notebook acer','notebook com 8gb ram e 256gb ssd',350000,10,1,1),(2,'smartphone samsung','galaxy com 128gb',250000,15,1,1),(3,'mouse logitech','mouse sem fio',7500,50,1,2),(4,'monitor lg','monitor 24 polegadas',80000,8,1,3),(5,'teclado mecânico','teclado gamer com led',12000,20,1,3);
/*!40000 ALTER TABLE `produto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servico`
--

DROP TABLE IF EXISTS `servico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` text,
  `preco` int NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  CONSTRAINT `servico_chk_1` CHECK ((`preco` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servico`
--

LOCK TABLES `servico` WRITE;
/*!40000 ALTER TABLE `servico` DISABLE KEYS */;
INSERT INTO `servico` VALUES (1,'instalação de software','instalação e configuração de programas',5000,1),(2,'formatação de pc','formatação completa e backup',8000,1),(3,'limpeza física','limpeza de hardware interna',3000,1),(4,'reparo de hardware','troca de peças danificadas',15000,1),(5,'suporte técnico','atendimento remoto para suporte',6000,1);
/*!40000 ALTER TABLE `servico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `cpf_cnpj` varchar(14) NOT NULL,
  `endereco` text,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cpf_cnpj` (`cpf_cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'luciano pereira','luciano.p@email.com','11223344556','rua x, 100 - campinas',1),(2,'ana paula','ana.p@example.com','22334455667','rua y, 200 - salvador',1),(3,'bruno costa','bruno.c@example.com','33445566778','rua z, 300 - recife',1),(4,'carla almeida','carla.a@example.com','44556677889','av w, 400 - fortaleza',1),(5,'daniel silva','daniel.s@example.com','55667788990','rua v, 500 - manaus',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_log`
--

DROP TABLE IF EXISTS `usuario_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `tipo` enum('deleta_produto','deleta_servico','atualizacao_perfil','atualizacao_produto','atualizacao_servico') NOT NULL,
  `descricao` text,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `usuario_log_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_log`
--

LOCK TABLES `usuario_log` WRITE;
/*!40000 ALTER TABLE `usuario_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuario_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_clientes_total_gasto`
--

DROP TABLE IF EXISTS `vw_clientes_total_gasto`;
/*!50001 DROP VIEW IF EXISTS `vw_clientes_total_gasto`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_clientes_total_gasto` AS SELECT 
 1 AS `cliente_id`,
 1 AS `cliente_nome`,
 1 AS `total_gasto`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_produtos_mais_vendidos`
--

DROP TABLE IF EXISTS `vw_produtos_mais_vendidos`;
/*!50001 DROP VIEW IF EXISTS `vw_produtos_mais_vendidos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_produtos_mais_vendidos` AS SELECT 
 1 AS `produto_id`,
 1 AS `produto_nome`,
 1 AS `fornecedor_nome`,
 1 AS `total_qtd`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_servicos_mais_vendidos`
--

DROP TABLE IF EXISTS `vw_servicos_mais_vendidos`;
/*!50001 DROP VIEW IF EXISTS `vw_servicos_mais_vendidos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_servicos_mais_vendidos` AS SELECT 
 1 AS `servico_id`,
 1 AS `servico_nome`,
 1 AS `total_qtd`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_vendas_por_usuario`
--

DROP TABLE IF EXISTS `vw_vendas_por_usuario`;
/*!50001 DROP VIEW IF EXISTS `vw_vendas_por_usuario`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_vendas_por_usuario` AS SELECT 
 1 AS `usuario_id`,
 1 AS `usuario_nome`,
 1 AS `total_vendas`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_clientes_total_gasto`
--

/*!50001 DROP VIEW IF EXISTS `vw_clientes_total_gasto`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_clientes_total_gasto` AS select `c`.`id` AS `cliente_id`,`c`.`nome` AS `cliente_nome`,sum(`p`.`total`) AS `total_gasto` from (`cliente` `c` join `pedido` `p` on((`p`.`cliente_id` = `c`.`id`))) where (`c`.`ativo` = true) group by `c`.`id`,`c`.`nome` order by `total_gasto` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_produtos_mais_vendidos`
--

/*!50001 DROP VIEW IF EXISTS `vw_produtos_mais_vendidos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_produtos_mais_vendidos` AS select `p`.`id` AS `produto_id`,`p`.`nome` AS `produto_nome`,`f`.`nome` AS `fornecedor_nome`,sum(`ip`.`quantidade`) AS `total_qtd` from ((`produto` `p` join `item_pedido` `ip` on((`ip`.`produto_id` = `p`.`id`))) left join `fornecedor` `f` on((`p`.`fornecedor_id` = `f`.`id`))) group by `p`.`id`,`p`.`nome`,`f`.`nome` order by `total_qtd` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_servicos_mais_vendidos`
--

/*!50001 DROP VIEW IF EXISTS `vw_servicos_mais_vendidos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_servicos_mais_vendidos` AS select `s`.`id` AS `servico_id`,`s`.`nome` AS `servico_nome`,sum(`ip`.`quantidade`) AS `total_qtd` from (`servico` `s` join `item_pedido` `ip` on((`ip`.`servico_id` = `s`.`id`))) group by `s`.`id`,`s`.`nome` order by `total_qtd` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_vendas_por_usuario`
--

/*!50001 DROP VIEW IF EXISTS `vw_vendas_por_usuario`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_vendas_por_usuario` AS select ifnull(`u`.`id`,0) AS `usuario_id`,ifnull(`u`.`nome`,'Sem Operador') AS `usuario_nome`,sum(`p`.`total`) AS `total_vendas` from (`pedido` `p` left join `usuario` `u` on((`p`.`usuario_id` = `u`.`id`))) group by ifnull(`u`.`id`,0),ifnull(`u`.`nome`,'Sem Operador') order by `total_vendas` desc */;
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

-- Dump completed on 2025-06-02  0:39:38
