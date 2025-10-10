-- 用户登录日志功能相关数据库表
-- 创建时间: 2025-09-25
-- 说明: 包含用户登录日志表和IP地址缓存表

-- =====================================================
-- 用户登录日志表
-- =====================================================
CREATE TABLE `user_login_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `login_time` datetime NOT NULL COMMENT '登录时间',
  `login_ip` varchar(50) NOT NULL COMMENT '登录IP地址',
  `ip_location` varchar(200) DEFAULT NULL COMMENT 'IP地址归属地（省市区）',
  `longitude` decimal(10,7) DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10,7) DEFAULT NULL COMMENT '纬度',
  `device_type` varchar(50) DEFAULT NULL COMMENT '设备类型（mobile/desktop/tablet/miniprogram）',
  `device_brand` varchar(50) DEFAULT NULL COMMENT '设备品牌（iPhone/Huawei/Xiaomi等）',
  `device_model` varchar(100) DEFAULT NULL COMMENT '设备型号（iPhone 13/P50 Pro等）',
  `os_name` varchar(50) DEFAULT NULL COMMENT '操作系统名称（iOS/Android/Windows）',
  `os_version` varchar(50) DEFAULT NULL COMMENT '操作系统版本（15.0/12.0等）',
  `browser_name` varchar(50) DEFAULT NULL COMMENT '浏览器名称（Safari/Chrome等）',
  `browser_version` varchar(50) DEFAULT NULL COMMENT '浏览器版本',
  `platform` varchar(20) DEFAULT NULL COMMENT '平台（mp-weixin/app-android/app-ios/h5）',
  `login_type` varchar(20) DEFAULT NULL COMMENT '登录方式（wechat/phone/sms/password）',
  `user_agent` text COMMENT '用户代理字符串（完整的User-Agent）',
  `session_id` varchar(100) DEFAULT NULL COMMENT '会话ID',
  `login_status` tinyint(1) DEFAULT 1 COMMENT '登录状态（1:成功 0:失败）',
  `fail_reason` varchar(200) DEFAULT NULL COMMENT '登录失败原因',
  `is_risk_login` tinyint(1) DEFAULT 0 COMMENT '是否风险登录（1:是 0:否）',
  `risk_level` tinyint(1) DEFAULT 0 COMMENT '风险等级（0:正常 1:低风险 2:中风险 3:高风险）',
  `risk_desc` varchar(500) DEFAULT NULL COMMENT '风险描述（具体的风险原因说明）',
  `device_fingerprint` varchar(100) DEFAULT NULL COMMENT '设备指纹（用于设备识别）',
  `network_type` varchar(20) DEFAULT NULL COMMENT '网络类型（wifi/4g/5g等）',
  `logout_time` datetime DEFAULT NULL COMMENT '退出登录时间',
  `online_duration` int(11) DEFAULT NULL COMMENT '在线时长（秒）',
  `client_version` varchar(20) DEFAULT NULL COMMENT '客户端版本号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`) COMMENT '用户ID索引',
  KEY `idx_login_time` (`login_time`) COMMENT '登录时间索引',
  KEY `idx_login_ip` (`login_ip`) COMMENT '登录IP索引',
  KEY `idx_is_risk` (`is_risk_login`) COMMENT '风险登录索引',
  KEY `idx_platform` (`platform`) COMMENT '平台索引',
  KEY `idx_login_status` (`login_status`) COMMENT '登录状态索引',
  KEY `idx_user_time` (`user_id`, `login_time`) COMMENT '用户和时间复合索引',
  KEY `idx_device_fingerprint` (`device_fingerprint`) COMMENT '设备指纹索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户登录日志表';

-- =====================================================
-- IP地址位置缓存表
-- =====================================================
CREATE TABLE `ip_location_cache` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `ip_address` varchar(50) NOT NULL COMMENT 'IP地址',
  `country` varchar(50) DEFAULT NULL COMMENT '国家',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `district` varchar(50) DEFAULT NULL COMMENT '区县',
  `isp` varchar(50) DEFAULT NULL COMMENT '运营商（电信/联通/移动等）',
  `longitude` decimal(10,7) DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10,7) DEFAULT NULL COMMENT '纬度',
  `location_desc` varchar(200) DEFAULT NULL COMMENT '位置描述（完整的地址描述）',
  `data_source` varchar(20) DEFAULT NULL COMMENT '数据来源（baidu/amap/ip138/ipapi等）',
  `accuracy` varchar(20) DEFAULT NULL COMMENT '精度等级（city/district/street）',
  `query_count` int(11) DEFAULT 1 COMMENT '查询次数统计',
  `last_query_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后查询时间',
  `expire_time` datetime DEFAULT NULL COMMENT '缓存过期时间',
  `is_valid` tinyint(1) DEFAULT 1 COMMENT '是否有效（1:有效 0:无效）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ip` (`ip_address`) COMMENT 'IP地址唯一索引',
  KEY `idx_expire_time` (`expire_time`) COMMENT '过期时间索引',
  KEY `idx_location` (`province`, `city`) COMMENT '位置索引',
  KEY `idx_data_source` (`data_source`) COMMENT '数据来源索引',
  KEY `idx_last_query` (`last_query_time`) COMMENT '最后查询时间索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='IP地址位置缓存表';

-- =====================================================
-- 登录安全规则配置表（可选）
-- =====================================================
CREATE TABLE `login_security_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_name` varchar(50) NOT NULL COMMENT '规则名称',
  `rule_type` varchar(20) NOT NULL COMMENT '规则类型（location/frequency/time/device）',
  `rule_config` json COMMENT '规则配置（JSON格式）',
  `risk_score` int(11) DEFAULT 10 COMMENT '风险分数',
  `is_enabled` tinyint(1) DEFAULT 1 COMMENT '是否启用（1:启用 0:禁用）',
  `description` varchar(200) DEFAULT NULL COMMENT '规则描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_rule_type` (`rule_type`) COMMENT '规则类型索引',
  KEY `idx_enabled` (`is_enabled`) COMMENT '启用状态索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录安全规则配置表';

-- =====================================================
-- 用户设备指纹表（可选）
-- =====================================================
CREATE TABLE `user_device_fingerprint` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `device_fingerprint` varchar(100) NOT NULL COMMENT '设备指纹',
  `device_name` varchar(100) DEFAULT NULL COMMENT '设备名称（用户自定义）',
  `device_type` varchar(50) DEFAULT NULL COMMENT '设备类型',
  `platform` varchar(20) DEFAULT NULL COMMENT '平台',
  `first_login_time` datetime DEFAULT NULL COMMENT '首次登录时间',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `login_count` int(11) DEFAULT 1 COMMENT '登录次数',
  `is_trusted` tinyint(1) DEFAULT 0 COMMENT '是否可信设备（1:是 0:否）',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态（1:正常 0:禁用）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_device` (`user_id`, `device_fingerprint`) COMMENT '用户设备唯一索引',
  KEY `idx_user_id` (`user_id`) COMMENT '用户ID索引',
  KEY `idx_fingerprint` (`device_fingerprint`) COMMENT '设备指纹索引',
  KEY `idx_trusted` (`is_trusted`) COMMENT '可信设备索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户设备指纹表';

-- =====================================================
-- 插入默认安全规则配置
-- =====================================================
INSERT INTO `login_security_rules` (`rule_name`, `rule_type`, `rule_config`, `risk_score`, `description`) VALUES
('异地登录检测', 'location', '{"max_distance": 100, "time_window": 30}', 30, '检测用户在短时间内从不同地理位置登录'),
('频繁登录检测', 'frequency', '{"max_attempts": 5, "time_window": 5}', 20, '检测用户在短时间内多次登录尝试'),
('异常时间检测', 'time', '{"start_hour": 2, "end_hour": 6}', 15, '检测用户在异常时间段登录'),
('新设备检测', 'device', '{"alert_new_device": true}', 10, '检测用户使用新设备登录');

-- =====================================================
-- 创建视图：用户登录统计视图
-- =====================================================
CREATE VIEW `user_login_statistics` AS
SELECT
    user_id,
    COUNT(*) as total_login_count,
    COUNT(CASE WHEN login_status = 1 THEN 1 END) as success_login_count,
    COUNT(CASE WHEN login_status = 0 THEN 1 END) as failed_login_count,
    COUNT(CASE WHEN is_risk_login = 1 THEN 1 END) as risk_login_count,
    COUNT(CASE WHEN DATE(login_time) = CURDATE() THEN 1 END) as today_login_count,
    COUNT(DISTINCT device_fingerprint) as device_count,
    COUNT(DISTINCT CONCAT(province, city)) as location_count,
    MAX(login_time) as last_login_time,
    MIN(login_time) as first_login_time
FROM user_login_log
WHERE login_time >= DATE_SUB(NOW(), INTERVAL 6 MONTH)  -- 最近6个月的数据
GROUP BY user_id;

-- =====================================================
-- 添加表注释和使用说明
-- =====================================================

-- 表结构说明：
-- 1. user_login_log: 核心的登录日志表，记录每次登录的详细信息
-- 2. ip_location_cache: IP地址位置缓存表，避免重复调用第三方API
-- 3. login_security_rules: 安全规则配置表，支持动态配置风险检测规则
-- 4. user_device_fingerprint: 用户设备指纹表，用于设备识别和管理
-- 5. user_login_statistics: 统计视图，便于快速查询用户登录统计信息

-- 索引说明：
-- 1. 主要查询场景都已添加相应索引
-- 2. 复合索引优化了常见的查询组合
-- 3. 唯一索引保证了数据的一致性

-- 使用建议：
-- 1. 定期清理过期的登录日志数据（建议保留6个月）
-- 2. IP位置缓存设置合理的过期时间（建议30天）
-- 3. 根据实际业务需求调整风险检测规则
-- 4. 定期分析登录统计数据，优化安全策略
