-- ============================================
-- AI 客服智能体 - 数据库初始化脚本
-- 数据库：chatbi / MySQL 5.7+
-- ============================================

CREATE DATABASE IF NOT EXISTS chatbi
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE chatbi;

-- ============================================
-- 1. 用户表
-- ============================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  username   VARCHAR(50)  NOT NULL COMMENT '用户名',
  phone      VARCHAR(20)  DEFAULT NULL COMMENT '手机号',
  email      VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 2. 商品表
-- ============================================
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(200)   NOT NULL COMMENT '商品名称',
  category    VARCHAR(50)    DEFAULT NULL COMMENT '分类',
  price       DECIMAL(10,2)  NOT NULL COMMENT '单价',
  stock       INT            DEFAULT 0 COMMENT '库存',
  description TEXT           DEFAULT NULL COMMENT '商品描述',
  created_at  DATETIME       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- ============================================
-- 3. 订单表
-- ============================================
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  order_no       VARCHAR(32)    NOT NULL COMMENT '订单编号',
  user_id        INT            NOT NULL COMMENT '用户ID',
  product_id     INT            NOT NULL COMMENT '商品ID',
  quantity       INT            DEFAULT 1 COMMENT '数量',
  total_price    DECIMAL(10,2)  NOT NULL COMMENT '总价',
  status         VARCHAR(20)    DEFAULT '待发货' COMMENT '订单状态',
  created_at     DATETIME       DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_order_no (order_no),
  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ============================================
-- 4. 物流表
-- ============================================
DROP TABLE IF EXISTS logistics;
CREATE TABLE logistics (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  order_id        INT           NOT NULL COMMENT '订单ID',
  tracking_no     VARCHAR(50)   DEFAULT NULL COMMENT '快递单号',
  carrier         VARCHAR(50)   DEFAULT NULL COMMENT '快递公司',
  status          VARCHAR(20)   DEFAULT '运输中' COMMENT '物流状态',
  updated_at      DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物流表';

-- ============================================
-- 5. 售后规则表
-- ============================================
DROP TABLE IF EXISTS after_sales_policy;
CREATE TABLE after_sales_policy (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  policy_type VARCHAR(30)  NOT NULL COMMENT '规则类型: return/exchange/refund/damage/manual',
  title       VARCHAR(100) NOT NULL COMMENT '规则标题',
  content     TEXT         NOT NULL COMMENT '规则内容',
  updated_at  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_policy_type (policy_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售后规则表';

-- ============================================
-- 6. 人工客服工单表
-- ============================================
DROP TABLE IF EXISTS human_service_ticket;
CREATE TABLE human_service_ticket (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id     VARCHAR(32)  NOT NULL COMMENT '工单编号',
  username      VARCHAR(50)  NOT NULL COMMENT '用户姓名',
  contact       VARCHAR(100) NOT NULL COMMENT '联系方式',
  service_type  VARCHAR(50)  NOT NULL COMMENT '服务类型',
  description   TEXT         NOT NULL COMMENT '问题描述',
  status        VARCHAR(20)  DEFAULT '待处理' COMMENT '状态',
  created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_ticket_id (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人工客服工单表';

-- ============================================
-- 种子数据
-- ============================================

-- 用户
INSERT INTO users (username, phone, email) VALUES
('张三', '13800001111', 'zhangsan@example.com'),
('李四', '13800002222', 'lisi@example.com'),
('王五', '13800003333', 'wangwu@example.com');

-- 商品
INSERT INTO products (name, category, price, stock, description) VALUES
('无线蓝牙耳机 Pro', '数码', 299.00, 150, '主动降噪，续航 30 小时'),
('轻薄笔记本电脑 14寸', '电脑', 4999.00, 30, 'i7-1360P / 16G / 512G'),
('智能手表 S1', '数码', 899.00, 80, '心率监测，血氧检测，7 天续航'),
('机械键盘 K87', '外设', 199.00, 200, '青轴，RGB 背光，87 键'),
('Type-C 数据线 1m', '配件', 19.90, 500, '60W 快充，数据传输');

-- 订单
INSERT INTO orders (order_no, user_id, product_id, quantity, total_price, status) VALUES
('ORD20260101001', 1, 1, 1, 299.00,  '已完成'),
('ORD20260102001', 1, 3, 1, 899.00,  '已发货'),
('ORD20260103001', 2, 2, 1, 4999.00, '待发货'),
('ORD20260104001', 3, 4, 2, 398.00,  '已完成'),
('ORD20260105001', 2, 5, 3, 59.70,   '运输中');

-- 物流
INSERT INTO logistics (order_id, tracking_no, carrier, status) VALUES
(1, 'SF1234567890', '顺丰速运', '已签收'),
(2, 'YT9876543210', '圆通快递', '运输中'),
(5, 'ZT1112223330', '中通快递', '运输中');

-- 售后规则
INSERT INTO after_sales_policy (policy_type, title, content) VALUES
('return', '退货政策',
 '1. 自签收之日起 7 天内可申请无理由退货。\n2. 商品需保持完好，配件齐全，不影响二次销售。\n3. 退货包邮（平台承担运费）。\n4. 退款将在收到退货后 3-5 个工作日内原路返回。'),
('exchange', '换货政策',
 '1. 自签收之日起 15 天内可申请换货。\n2. 若因质量问题换货，运费由平台承担。\n3. 非质量问题换货，运费由买家承担。\n4. 换货商品将在收到退货后 2 个工作日内发出。'),
('refund', '退款政策',
 '1. 未发货订单可随时申请退款，即时到账。\n2. 已发货订单需先拒收或退回，确认后 3-5 个工作日退款。\n3. 虚拟商品一经发货不支持退款。'),
('damage', '商品破损处理',
 '1. 签收时发现破损请当场拒收并拍照留证。\n2. 签收后 24 小时内发现破损，联系客服并提供照片，可申请补发或退款。\n3. 逾期未反馈视为签收完好，不支持破损理赔。'),
('manual', '人工客服',
 '如需人工协助，请提供订单号 + 问题描述 + 联系方式，我们将尽快为您处理。');
