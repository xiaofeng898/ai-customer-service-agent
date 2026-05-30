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

-- ============================================
-- 用户（10 人，覆盖不同消费层级）
-- ============================================
INSERT INTO users (username, phone, email) VALUES
('张三',   '13800001111', 'zhangsan@example.com'),
('李四',   '13800002222', 'lisi@example.com'),
('王五',   '13800003333', 'wangwu@example.com'),
('赵六',   '13800004444', 'zhaoliu@example.com'),
('陈小红', '13800005555', 'chenxh@example.com'),
('刘建国', '13800006666', 'liujg@example.com'),
('孙丽',   '13800007777', 'sunli@example.com'),
('周杰',   '13800008888', 'zhoujie@example.com'),
('吴芳',   '13800009999', 'wufang@example.com'),
('马超',   '13800010000', 'machao@example.com');

-- ============================================
-- 商品（20 件，6 个分类）
-- ============================================
INSERT INTO products (name, category, price, stock, description) VALUES
-- 数码
('无线蓝牙耳机 Pro',     '数码', 299.00,  150, '主动降噪，续航 30 小时，蓝牙 5.3'),
('智能手表 S2',          '数码', 1299.00,  50, '心率血氧监测，GPS，14 天续航，IP68 防水'),
('便携蓝牙音箱',         '数码', 159.00,  120, '360° 环绕音，IPX7 防水，12 小时播放'),
('高清投影仪 Mini',      '数码', 899.00,   15, '1080P 分辨率，自动对焦，内置电池'),
-- 电脑
('轻薄笔记本电脑 14寸',  '电脑', 4999.00,  30, 'i7-1360P / 16G DDR5 / 512G NVMe / 2.8K 屏'),
('游戏台式机 刃系列',   '电脑', 8999.00,  10, 'i9-13900K / RTX4070 / 32G / 1TB'),
('27寸 4K 显示器',       '电脑', 2499.00,  20, 'IPS 面板，Type-C 90W 反向充电，旋转升降'),
-- 外设
('机械键盘 K87',         '外设', 199.00,  200, '青轴，RGB 背光，热插拔，87 键'),
('电竞鼠标 M5',          '外设', 149.00,  180, 'PAW3395，26000DPI，59g 轻量化'),
('USB-C 扩展坞 12合1',  '外设', 249.00,   90, '双 HDMI + DP + 千兆网口 + SD/TF + 3×USB3.0'),
-- 配件
('Type-C 快充数据线 1m', '配件', 19.90,  500, '60W PD 快充，480Mbps 数据传输，编织线'),
('氮化镓充电器 65W',     '配件', 89.00,  300, '双口 GaN，支持笔记本 + 手机同时快充'),
('手机支架 铝合金',       '配件', 39.90,  400, '360° 旋转，折叠便携，兼容 4-8 寸手机'),
-- 家居
('智能台灯 Pro',         '家居', 199.00,  100, '无频闪，色温无极调节，APP 控制，番茄钟'),
('空气净化器 Mini',      '家居', 699.00,   40, 'HEPA 滤网，CADR 200m³/h，静音 28dB'),
('电动牙刷 S1',          '家居', 169.00,  150, '声波震动，5 种模式，IPX7，续航 30 天'),
-- 运动
('跑步鞋 AirBoost',      '运动', 499.00,   60, '超临界发泡中底，碳板支撑，透气飞织鞋面'),
('瑜伽垫 6mm',           '运动', 79.00,   200, 'TPE 环保材质，双面防滑，含收纳绑带'),
('运动水壶 750ml',       '运动', 59.00,   250, '316 不锈钢，真空双层，12 小时保温'),
('筋膜枪 Mini',          '运动', 249.00,   80, '无刷电机，4 档变速，6 个按摩头，超静音');

-- ============================================
-- 订单（35 笔，覆盖不同状态、用户、时间段）
-- ============================================
INSERT INTO orders (order_no, user_id, product_id, quantity, total_price, status) VALUES
-- 张三（高频消费者，数码控）
('ORD20251215001', 1,  1, 1,  299.00,  '已完成'),
('ORD20251220001', 1,  3, 1,  159.00,  '已完成'),
('ORD20260105001', 1,  2, 1, 1299.00,  '已完成'),
('ORD20260118001', 1, 11, 1,   89.00,  '已发货'),
('ORD20260125001', 1,  8, 1,  199.00,  '已发货'),
('ORD20260130001', 1, 12, 2,   79.80,  '待发货'),

-- 李四（高客单价，买电脑和外设）
('ORD20251218001', 2,  5, 1, 4999.00,  '已完成'),
('ORD20260103001', 2,  7, 1, 2499.00,  '已完成'),
('ORD20260115001', 2,  9, 1,  149.00,  '已完成'),
('ORD20260128001', 2, 10, 1,  249.00,  '已发货'),

-- 王五（配件为主，多次购买）
('ORD20260101001', 3, 11, 3,   59.70,  '已完成'),
('ORD20260108001', 3, 12, 1,   89.00,  '已完成'),
('ORD20260112001', 3, 13, 2,   79.80,  '已完成'),
('ORD20260120001', 3,  4, 1,  899.00,  '运输中'),
('ORD20260126001', 3, 16, 1,  169.00,  '已发货'),

-- 赵六（运动达人）
('ORD20260106001', 4, 17, 2,  998.00,  '已完成'),
('ORD20260110001', 4, 18, 1,   79.00,  '已完成'),
('ORD20260122001', 4, 20, 1,  249.00,  '运输中'),

-- 陈小红（家居为主）
('ORD20260104001', 5, 14, 1,  199.00,  '已完成'),
('ORD20260109001', 5, 15, 1,  699.00,  '已完成'),
('ORD20260116001', 5, 16, 1,  169.00,  '已发货'),
('ORD20260124001', 5, 18, 2,  158.00,  '待发货'),

-- 刘建国
('ORD20260102001', 6,  5, 1, 4999.00,  '已完成'),
('ORD20260114001', 6, 10, 1,  249.00,  '已完成'),
('ORD20260127001', 6,  8, 1,  199.00,  '运输中'),

-- 孙丽
('ORD20260107001', 7,  6, 1, 8999.00,  '已完成'),
('ORD20260117001', 7,  9, 1,  149.00,  '已发货'),

-- 周杰
('ORD20260111001', 8,  2, 1, 1299.00,  '已完成'),
('ORD20260119001', 8, 20, 1,  249.00,  '已完成'),
('ORD20260129001', 8, 12, 1,   89.00,  '待发货'),

-- 吴芳
('ORD20260108001', 9, 17, 1,  499.00,  '已完成'),
('ORD20260121001', 9, 19, 2,  118.00,  '运输中'),

-- 马超
('ORD20260113001', 10, 3,  1,  159.00,  '已完成'),
('ORD20260123001', 10, 14, 1,  199.00,  '已发货'),
('ORD20260131001', 10, 11, 5,   99.50,  '待发货');

-- ============================================
-- 物流（所有非"待发货"订单的物流记录）
-- ============================================
INSERT INTO logistics (order_id, tracking_no, carrier, status) VALUES
(1,  'SF1234500001', '顺丰速运', '已签收'),
(2,  'YT1234500002', '圆通快递', '已签收'),
(3,  'SF1234500003', '顺丰速运', '已签收'),
(4,  'JD1234500004', '京东物流', '运输中'),
(5,  'ZT1234500005', '中通快递', '运输中'),
(7,  'SF1234500007', '顺丰速运', '已签收'),
(8,  'SF1234500008', '顺丰速运', '已签收'),
(9,  'YT1234500009', '圆通快递', '已签收'),
(10, 'JD1234500010', '京东物流', '运输中'),
(11, 'ST1234500011', '申通快递', '已签收'),
(12, 'ST1234500012', '申通快递', '已签收'),
(13, 'YT1234500013', '圆通快递', '已签收'),
(14, 'ZT1234500014', '中通快递', '运输中'),
(15, 'SF1234500015', '顺丰速运', '运输中'),
(16, 'JD1234500016', '京东物流', '已签收'),
(17, 'SF1234500017', '顺丰速运', '已签收'),
(18, 'YT1234500018', '圆通快递', '运输中'),
(19, 'SF1234500019', '顺丰速运', '已签收'),
(20, 'JD1234500020', '京东物流', '已签收'),
(21, 'SF1234500021', '顺丰速运', '运输中'),
(23, 'ST1234500023', '申通快递', '已签收'),
(24, 'SF1234500024', '顺丰速运', '已签收'),
(25, 'SF1234500025', '顺丰速运', '已签收'),
(26, 'YT1234500026', '圆通快递', '运输中'),
(27, 'SF1234500027', '顺丰速运', '已签收'),
(28, 'SF1234500028', '顺丰速运', '运输中'),
(29, 'JD1234500029', '京东物流', '已签收'),
(30, 'SF1234500030', '顺丰速运', '已签收'),
(31, 'YT1234500031', '圆通快递', '运输中'),
(32, 'SF1234500032', '顺丰速运', '已签收'),
(33, 'ZT1234500033', '中通快递', '运输中');

-- ============================================
-- 已有工单（演示工单查询功能）
-- ============================================
INSERT INTO human_service_ticket (ticket_id, username, contact, service_type, description, status) VALUES
('TICKET20260118001', '张三',   '13800001111', '换货',    '无线蓝牙耳机 Pro 左耳无声，已试用 3 天，申请换货', '处理中'),
('TICKET20260122001', '陈小红', '13800005555', '退货',    '空气净化器 Mini 噪音偏大，与描述不符，申请退货',   '待处理'),
('TICKET20260125001', '刘建国', '13800006666', '商品破损', '签收后发现机械键盘外壳有裂纹，已拍照留证',        '已完成');

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
