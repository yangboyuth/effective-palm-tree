-- ============================================================
-- 淘宝商城数据库建表脚本 (MySQL 5.7+ / 8.0+)
-- 共25张表，分为5个模块
-- 执行方式：source 建表.sql 或在客户端中全选执行
-- ============================================================

-- 先建数据库（如不存在则创建）
CREATE DATABASE IF NOT EXISTS taobao_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE taobao_db;

-- -----------------------------------------------------------
-- 模块一：用户模块（4张表）
-- -----------------------------------------------------------

-- 1. 用户表
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS 用户详情表;
DROP TABLE IF EXISTS 商品收藏表;
DROP TABLE IF EXISTS 收货地址表;
DROP TABLE IF EXISTS 订单明细表;
DROP TABLE IF EXISTS 订单状态日志表;
DROP TABLE IF EXISTS 支付记录表;
DROP TABLE IF EXISTS 退款记录表;
DROP TABLE IF EXISTS 商品评价表;
DROP TABLE IF EXISTS 购物车表;
DROP TABLE IF EXISTS 订单表;
DROP TABLE IF EXISTS 商品规格表;
DROP TABLE IF EXISTS 商品参数表;
DROP TABLE IF EXISTS 商品图片表;
DROP TABLE IF EXISTS 商品描述表;
DROP TABLE IF EXISTS 活动商品表;
DROP TABLE IF EXISTS 促销活动表;
DROP TABLE IF EXISTS 用户优惠券表;
DROP TABLE IF EXISTS 优惠券表;
DROP TABLE IF EXISTS 商品表;
DROP TABLE IF EXISTS 商品分类表;
DROP TABLE IF EXISTS 品牌表;
DROP TABLE IF EXISTS 物流轨迹表;
DROP TABLE IF EXISTS 发货记录表;
DROP TABLE IF EXISTS 快递公司表;
DROP TABLE IF EXISTS 用户表;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE 用户表 (
    用户编号     INT AUTO_INCREMENT,
    用户名       VARCHAR(50)  NOT NULL,
    密码密文     VARCHAR(128) NOT NULL,
    手机号       VARCHAR(20)  NOT NULL,
    邮箱         VARCHAR(100),
    头像URL      VARCHAR(255),
    用户角色     TINYINT      NOT NULL DEFAULT 0 COMMENT '0买家 1卖家',
    账户状态     TINYINT      NOT NULL DEFAULT 1 COMMENT '1正常 0禁用',
    注册时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    最后登录时间 DATETIME,
    PRIMARY KEY (用户编号),
    UNIQUE INDEX idx_用户名 (用户名),
    UNIQUE INDEX idx_手机号 (手机号),
    UNIQUE INDEX idx_邮箱 (邮箱),
    INDEX idx_用户角色 (用户角色)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 用户详情表（与用户表1:1，共享主键）
CREATE TABLE 用户详情表 (
    用户编号     INT NOT NULL,
    真实姓名     VARCHAR(50),
    性别         TINYINT      COMMENT '0男 1女',
    出生日期     DATE,
    昵称         VARCHAR(50),
    个人简介     VARCHAR(500),
    身份证号脱敏 VARCHAR(18),
    更新时间     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (用户编号),
    CONSTRAINT fk_用户详情_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户详情表';

-- 3. 收货地址表
CREATE TABLE 收货地址表 (
    地址编号     INT AUTO_INCREMENT,
    用户编号     INT          NOT NULL,
    收货人姓名   VARCHAR(50)  NOT NULL,
    联系电话     VARCHAR(20)  NOT NULL,
    省份         VARCHAR(50)  NOT NULL,
    城市         VARCHAR(50)  NOT NULL,
    区县         VARCHAR(50)  NOT NULL,
    详细地址     VARCHAR(255) NOT NULL,
    邮政编码     VARCHAR(10),
    是否默认地址 TINYINT      NOT NULL DEFAULT 0 COMMENT '1是 0否',
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (地址编号),
    INDEX idx_地址_用户 (用户编号),
    CONSTRAINT fk_地址_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- 4. 商品收藏表
CREATE TABLE 商品收藏表 (
    收藏编号     INT AUTO_INCREMENT,
    用户编号     INT      NOT NULL,
    商品编号     INT      NOT NULL,
    收藏时间     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (收藏编号),
    INDEX idx_收藏_用户 (用户编号),
    INDEX idx_收藏_商品 (商品编号),
    UNIQUE INDEX idx_收藏_用户商品 (用户编号, 商品编号),
    CONSTRAINT fk_收藏_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE
    -- 商品编号外键在建商品表后补充
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品收藏表';

-- -----------------------------------------------------------
-- 模块二：商品模块（7张表）
-- -----------------------------------------------------------

-- 5. 商品分类表
CREATE TABLE 商品分类表 (
    分类编号     INT AUTO_INCREMENT,
    分类名称     VARCHAR(50)  NOT NULL,
    父级分类编号 INT          DEFAULT NULL COMMENT '顶级分类此字段为NULL',
    分类层级     TINYINT      NOT NULL DEFAULT 1 COMMENT '1一级 2二级 3三级',
    排序序号     INT          NOT NULL DEFAULT 0,
    是否叶子节点 TINYINT      NOT NULL DEFAULT 1 COMMENT '1叶子 0非叶子',
    图标URL      VARCHAR(255),
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (分类编号),
    INDEX idx_分类_父级 (父级分类编号),
    CONSTRAINT fk_分类_父级 FOREIGN KEY (父级分类编号) REFERENCES 商品分类表(分类编号) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 6. 品牌表
CREATE TABLE 品牌表 (
    品牌编号     INT AUTO_INCREMENT,
    品牌名称     VARCHAR(100)  NOT NULL,
    品牌LOGO_URL VARCHAR(255),
    品牌首字母   CHAR(1),
    所属国家     VARCHAR(50),
    品牌故事简介 TEXT,
    状态         TINYINT       NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
    创建时间     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (品牌编号),
    UNIQUE INDEX idx_品牌_名称 (品牌名称),
    INDEX idx_品牌_首字母 (品牌首字母)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌表';

-- 7. 商品表
CREATE TABLE 商品表 (
    商品编号     INT AUTO_INCREMENT,
    卖家编号     INT          NOT NULL COMMENT '关联用户表(卖家)',
    分类编号     INT          NOT NULL,
    品牌编号     INT,
    商品标题     VARCHAR(200) NOT NULL,
    副标题       VARCHAR(200),
    主图URL      VARCHAR(255),
    最低价格     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    最高价格     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    总库存量     INT          NOT NULL DEFAULT 0,
    销量         INT          NOT NULL DEFAULT 0,
    商品状态     TINYINT      NOT NULL DEFAULT 0 COMMENT '0草稿 1上架 2下架',
    是否新品     TINYINT      NOT NULL DEFAULT 0 COMMENT '1是 0否',
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    更新时间     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (商品编号),
    INDEX idx_商品_卖家 (卖家编号),
    INDEX idx_商品_分类 (分类编号),
    INDEX idx_商品_品牌 (品牌编号),
    INDEX idx_商品_状态 (商品状态),
    INDEX idx_商品_标题 (商品标题(50)),
    CONSTRAINT fk_商品_卖家 FOREIGN KEY (卖家编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE,
    CONSTRAINT fk_商品_分类 FOREIGN KEY (分类编号) REFERENCES 商品分类表(分类编号) ON DELETE RESTRICT,
    CONSTRAINT fk_商品_品牌 FOREIGN KEY (品牌编号) REFERENCES 品牌表(品牌编号) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 补建收藏表的外键（商品编号 → 商品表）
ALTER TABLE 商品收藏表
  ADD CONSTRAINT fk_收藏_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE;

-- 8. 商品描述表（与商品表1:1）
CREATE TABLE 商品描述表 (
    描述编号       INT AUTO_INCREMENT,
    商品编号       INT NOT NULL,
    PC端描述HTML   LONGTEXT,
    移动端描述HTML LONGTEXT,
    售后服务说明   TEXT,
    包装清单       VARCHAR(500),
    更新时间       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (描述编号),
    UNIQUE INDEX idx_描述_商品 (商品编号),
    CONSTRAINT fk_描述_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品描述表';

-- 9. 商品图片表
CREATE TABLE 商品图片表 (
    图片编号     INT AUTO_INCREMENT,
    商品编号     INT          NOT NULL,
    图片URL      VARCHAR(255) NOT NULL,
    排序序号     INT          NOT NULL DEFAULT 0,
    是否主图     TINYINT      NOT NULL DEFAULT 0 COMMENT '1是 0否',
    上传时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (图片编号),
    INDEX idx_图片_商品 (商品编号),
    CONSTRAINT fk_图片_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品图片表';

-- 10. 商品规格表（SKU）
CREATE TABLE 商品规格表 (
    规格编号     INT AUTO_INCREMENT,
    商品编号     INT          NOT NULL,
    规格名称     VARCHAR(50)  NOT NULL COMMENT '如：颜色、尺寸',
    规格值       VARCHAR(100) NOT NULL COMMENT '如：红色、XL',
    销售价格     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    库存数量     INT          NOT NULL DEFAULT 0,
    规格编码     VARCHAR(100) COMMENT '商家自定义编码',
    是否启用     TINYINT      NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (规格编号),
    INDEX idx_规格_商品 (商品编号),
    CONSTRAINT fk_规格_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品规格表';

-- 11. 商品参数表
CREATE TABLE 商品参数表 (
    参数编号     INT AUTO_INCREMENT,
    商品编号     INT          NOT NULL,
    属性名称     VARCHAR(100) NOT NULL COMMENT '如：屏幕尺寸、电池容量',
    属性值       VARCHAR(200) NOT NULL,
    排序序号     INT          NOT NULL DEFAULT 0,
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (参数编号),
    INDEX idx_参数_商品 (商品编号),
    CONSTRAINT fk_参数_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品参数表';

-- -----------------------------------------------------------
-- 模块三：订单模块（7张表）
-- -----------------------------------------------------------

-- 12. 购物车表
CREATE TABLE 购物车表 (
    购物车编号   INT AUTO_INCREMENT,
    用户编号     INT      NOT NULL,
    商品编号     INT      NOT NULL,
    规格编号     INT      COMMENT '无规格则为NULL',
    购买数量     INT      NOT NULL DEFAULT 1,
    是否选中     TINYINT  NOT NULL DEFAULT 1 COMMENT '1选中 0未选',
    加入时间     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (购物车编号),
    INDEX idx_购物车_用户 (用户编号),
    INDEX idx_购物车_商品 (商品编号),
    UNIQUE INDEX idx_购物车_用户商品规格 (用户编号, 商品编号, 规格编号),
    CONSTRAINT fk_购物车_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE,
    CONSTRAINT fk_购物车_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE,
    CONSTRAINT fk_购物车_规格 FOREIGN KEY (规格编号) REFERENCES 商品规格表(规格编号) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 13. 订单表
CREATE TABLE 订单表 (
    订单编号     INT AUTO_INCREMENT,
    订单流水号   VARCHAR(32)  NOT NULL,
    用户编号     INT          NOT NULL COMMENT '买家',
    收货地址编号 INT          NOT NULL,
    商品总金额   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    运费金额     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    实付金额     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    订单状态     TINYINT      NOT NULL DEFAULT 0 COMMENT '0待付款 1待发货 2待收货 3已完成 4已取消',
    买家留言     VARCHAR(500),
    支付时间     DATETIME,
    发货时间     DATETIME,
    完成时间     DATETIME,
    取消原因     VARCHAR(255),
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    更新时间     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (订单编号),
    UNIQUE INDEX idx_订单_流水号 (订单流水号),
    INDEX idx_订单_用户 (用户编号),
    INDEX idx_订单_地址 (收货地址编号),
    INDEX idx_订单_状态 (订单状态),
    INDEX idx_订单_创建时间 (创建时间),
    CONSTRAINT fk_订单_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE RESTRICT,
    CONSTRAINT fk_订单_地址 FOREIGN KEY (收货地址编号) REFERENCES 收货地址表(地址编号) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 14. 订单明细表
CREATE TABLE 订单明细表 (
    明细编号       INT AUTO_INCREMENT,
    订单编号       INT          NOT NULL,
    商品编号       INT          NOT NULL,
    规格编号       INT,
    商品标题快照   VARCHAR(200) NOT NULL,
    规格名称快照   VARCHAR(150),
    成交单价快照   DECIMAL(10,2) NOT NULL,
    购买数量       INT          NOT NULL,
    小计金额       DECIMAL(10,2) NOT NULL,
    商品图片快照   VARCHAR(255),
    是否已评价     TINYINT      NOT NULL DEFAULT 0 COMMENT '1已评 0未评',
    PRIMARY KEY (明细编号),
    INDEX idx_明细_订单 (订单编号),
    INDEX idx_明细_商品 (商品编号),
    CONSTRAINT fk_明细_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE CASCADE,
    CONSTRAINT fk_明细_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE RESTRICT,
    CONSTRAINT fk_明细_规格 FOREIGN KEY (规格编号) REFERENCES 商品规格表(规格编号) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 15. 订单状态日志表
CREATE TABLE 订单状态日志表 (
    日志编号       INT AUTO_INCREMENT,
    订单编号       INT          NOT NULL,
    变更前状态     TINYINT,
    变更后状态     TINYINT      NOT NULL,
    操作人类型     TINYINT      NOT NULL COMMENT '0买家 1卖家 2系统',
    操作人编号     INT          COMMENT '操作人用户编号，系统操作为NULL',
    备注说明       VARCHAR(255),
    操作时间       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (日志编号),
    INDEX idx_日志_订单 (订单编号),
    CONSTRAINT fk_日志_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态日志表';

-- 16. 支付记录表
CREATE TABLE 支付记录表 (
    支付编号       INT AUTO_INCREMENT,
    订单编号       INT          NOT NULL,
    支付流水号     VARCHAR(32)  NOT NULL,
    支付金额       DECIMAL(10,2) NOT NULL,
    支付方式       TINYINT      NOT NULL COMMENT '0支付宝 1微信 2银行卡',
    支付状态       TINYINT      NOT NULL DEFAULT 0 COMMENT '0待支付 1已支付 2已退款',
    第三方交易号   VARCHAR(64),
    支付时间       DATETIME,
    创建时间       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (支付编号),
    UNIQUE INDEX idx_支付_流水号 (支付流水号),
    UNIQUE INDEX idx_支付_订单 (订单编号),
    INDEX idx_支付_状态 (支付状态),
    CONSTRAINT fk_支付_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- 17. 退款记录表
CREATE TABLE 退款记录表 (
    退款编号       INT AUTO_INCREMENT,
    订单编号       INT          NOT NULL,
    退款金额       DECIMAL(10,2) NOT NULL,
    退款原因       VARCHAR(255) NOT NULL,
    退款说明       TEXT,
    凭证图片       TEXT         COMMENT '多张图片URL，JSON格式',
    退款状态       TINYINT      NOT NULL DEFAULT 0 COMMENT '0待审核 1已同意 2已拒绝 3已完成',
    商家拒绝原因   VARCHAR(255),
    申请时间       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    处理时间       DATETIME,
    完成时间       DATETIME,
    PRIMARY KEY (退款编号),
    INDEX idx_退款_订单 (订单编号),
    INDEX idx_退款_状态 (退款状态),
    CONSTRAINT fk_退款_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录表';

-- 18. 商品评价表
CREATE TABLE 商品评价表 (
    评价编号       INT AUTO_INCREMENT,
    订单编号       INT          NOT NULL,
    商品编号       INT          NOT NULL,
    用户编号       INT          NOT NULL,
    评分           TINYINT      NOT NULL COMMENT '1~5星',
    评价内容       TEXT,
    晒图图片       TEXT         COMMENT '多张图片URL，JSON格式',
    商家回复内容   VARCHAR(500),
    是否匿名评价   TINYINT      NOT NULL DEFAULT 0 COMMENT '1匿名 0不匿名',
    有用计数       INT          NOT NULL DEFAULT 0,
    回复时间       DATETIME,
    评价时间       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (评价编号),
    INDEX idx_评价_订单 (订单编号),
    INDEX idx_评价_商品 (商品编号),
    INDEX idx_评价_用户 (用户编号),
    INDEX idx_评价_评分 (评分),
    CONSTRAINT fk_评价_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE RESTRICT,
    CONSTRAINT fk_评价_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE RESTRICT,
    CONSTRAINT fk_评价_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品评价表';

-- -----------------------------------------------------------
-- 模块四：营销模块（4张表）
-- -----------------------------------------------------------

-- 19. 优惠券表
CREATE TABLE 优惠券表 (
    优惠券编号     INT AUTO_INCREMENT,
    优惠券名称     VARCHAR(100) NOT NULL,
    优惠券类型     TINYINT      NOT NULL COMMENT '0满减券 1折扣券',
    使用门槛金额   DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '满X元可用',
    减免金额或折扣率 DECIMAL(10,2) NOT NULL COMMENT '满减为减免金额，折扣为折扣率(如0.85)',
    发放总量       INT          NOT NULL DEFAULT 0,
    已领取量       INT          NOT NULL DEFAULT 0,
    已使用量       INT          NOT NULL DEFAULT 0,
    每人限领数量   INT          NOT NULL DEFAULT 1,
    有效期起始时间 DATETIME     NOT NULL,
    有效期结束时间 DATETIME     NOT NULL,
    优惠券状态     TINYINT      NOT NULL DEFAULT 0 COMMENT '0停用 1启用',
    创建时间       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (优惠券编号),
    INDEX idx_优惠券_状态时间 (优惠券状态, 有效期起始时间, 有效期结束时间)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 20. 用户优惠券表
CREATE TABLE 用户优惠券表 (
    记录编号       INT AUTO_INCREMENT,
    用户编号       INT      NOT NULL,
    优惠券编号     INT      NOT NULL,
    优惠券状态     TINYINT  NOT NULL DEFAULT 0 COMMENT '0未使用 1已使用 2已过期',
    使用的订单编号 INT,
    领取时间       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    使用时间       DATETIME,
    PRIMARY KEY (记录编号),
    INDEX idx_用户券_用户 (用户编号),
    INDEX idx_用户券_优惠券 (优惠券编号),
    INDEX idx_用户券_订单 (使用的订单编号),
    CONSTRAINT fk_用户券_用户 FOREIGN KEY (用户编号) REFERENCES 用户表(用户编号) ON DELETE CASCADE,
    CONSTRAINT fk_用户券_优惠券 FOREIGN KEY (优惠券编号) REFERENCES 优惠券表(优惠券编号) ON DELETE CASCADE,
    CONSTRAINT fk_用户券_订单 FOREIGN KEY (使用的订单编号) REFERENCES 订单表(订单编号) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 21. 促销活动表
CREATE TABLE 促销活动表 (
    活动编号     INT AUTO_INCREMENT,
    活动名称     VARCHAR(100) NOT NULL,
    活动类型     TINYINT      NOT NULL COMMENT '0满减 1秒杀 2限时折扣',
    活动描述     VARCHAR(500),
    活动起始时间 DATETIME     NOT NULL,
    活动结束时间 DATETIME     NOT NULL,
    活动规则JSON TEXT,
    活动状态     TINYINT      NOT NULL DEFAULT 0 COMMENT '0未开始 1进行中 2已结束',
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (活动编号),
    INDEX idx_活动_状态时间 (活动状态, 活动起始时间, 活动结束时间)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='促销活动表';

-- 22. 活动商品表
CREATE TABLE 活动商品表 (
    记录编号     INT AUTO_INCREMENT,
    活动编号     INT          NOT NULL,
    商品编号     INT          NOT NULL,
    活动价格     DECIMAL(10,2) NOT NULL,
    每人限购数量 INT          NOT NULL DEFAULT 1,
    活动库存     INT          NOT NULL DEFAULT 0,
    已售数量     INT          NOT NULL DEFAULT 0,
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (记录编号),
    UNIQUE INDEX idx_活动商品_活动商品 (活动编号, 商品编号),
    INDEX idx_活动商品_商品 (商品编号),
    CONSTRAINT fk_活动商品_活动 FOREIGN KEY (活动编号) REFERENCES 促销活动表(活动编号) ON DELETE CASCADE,
    CONSTRAINT fk_活动商品_商品 FOREIGN KEY (商品编号) REFERENCES 商品表(商品编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动商品表';

-- -----------------------------------------------------------
-- 模块五：物流模块（3张表）
-- -----------------------------------------------------------

-- 23. 快递公司表
CREATE TABLE 快递公司表 (
    快递公司编号 INT AUTO_INCREMENT,
    快递公司名称 VARCHAR(50)  NOT NULL,
    快递公司代码 VARCHAR(20)  NOT NULL COMMENT '如：SF、YTO、ZTO',
    客服电话     VARCHAR(20),
    官网URL      VARCHAR(255),
    排序序号     INT          NOT NULL DEFAULT 0,
    是否启用     TINYINT      NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
    PRIMARY KEY (快递公司编号),
    UNIQUE INDEX idx_快递_名称 (快递公司名称),
    UNIQUE INDEX idx_快递_代码 (快递公司代码)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='快递公司表';

-- 24. 发货记录表
CREATE TABLE 发货记录表 (
    发货编号     INT AUTO_INCREMENT,
    订单编号     INT          NOT NULL,
    快递公司编号 INT          NOT NULL,
    快递单号     VARCHAR(50)  NOT NULL,
    发货人姓名   VARCHAR(50),
    发货人电话   VARCHAR(20),
    发货地址     VARCHAR(255),
    收货人姓名   VARCHAR(50)  NOT NULL,
    收货人电话   VARCHAR(20)  NOT NULL,
    收货地址     VARCHAR(255) NOT NULL,
    运费金额     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    发货状态     TINYINT      NOT NULL DEFAULT 0 COMMENT '0待揽收 1运输中 2已签收 3已退回',
    发货时间     DATETIME,
    签收时间     DATETIME,
    创建时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (发货编号),
    UNIQUE INDEX idx_发货_订单 (订单编号),
    INDEX idx_发货_快递公司 (快递公司编号),
    INDEX idx_发货_状态 (发货状态),
    CONSTRAINT fk_发货_订单 FOREIGN KEY (订单编号) REFERENCES 订单表(订单编号) ON DELETE RESTRICT,
    CONSTRAINT fk_发货_快递公司 FOREIGN KEY (快递公司编号) REFERENCES 快递公司表(快递公司编号) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='发货记录表';

-- 25. 物流轨迹表
CREATE TABLE 物流轨迹表 (
    轨迹编号     INT AUTO_INCREMENT,
    发货编号     INT          NOT NULL,
    轨迹描述     VARCHAR(255) NOT NULL,
    轨迹状态     VARCHAR(50)  COMMENT '如：已揽件、运输中、派送中、已签收',
    所在城市     VARCHAR(50),
    操作时间     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (轨迹编号),
    INDEX idx_轨迹_发货 (发货编号),
    INDEX idx_轨迹_时间 (操作时间),
    CONSTRAINT fk_轨迹_发货 FOREIGN KEY (发货编号) REFERENCES 发货记录表(发货编号) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物流轨迹表';

-- ============================================================
-- 建表完成，共25张表
-- ============================================================
