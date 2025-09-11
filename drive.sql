-- =============================================
-- 驾考通应用数据库设计
-- 严格遵循阿里巴巴Java开发手册规范
-- 反三范式设计，冗余存储提高查询性能
-- 不使用主键自增，不使用外键关系
-- =============================================

-- 用户信息表
CREATE TABLE `user_info` (
  `user_id` varchar(32) NOT NULL COMMENT '用户ID，使用UUID',
  `phone` varchar(11) NOT NULL COMMENT '手机号',
  `nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称',
  `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `openid` varchar(64) DEFAULT NULL COMMENT '微信openid',
  `union_id` varchar(64) DEFAULT NULL COMMENT '微信unionid',
  `gender` tinyint(1) DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `total_points` int(11) DEFAULT 0 COMMENT '总积分',
  `available_points` int(11) DEFAULT 0 COMMENT '可用积分',
  `vip_level` tinyint(1) DEFAULT 0 COMMENT 'VIP等级：0-普通用户，1-VIP',
  `vip_expire_time` datetime DEFAULT NULL COMMENT 'VIP过期时间',
  `status` tinyint(1) DEFAULT 1 COMMENT '账号状态：0-禁用，1-正常',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(45) DEFAULT NULL COMMENT '最后登录IP',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_openid` (`openid`),
  KEY `idx_union_id` (`union_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- 驾考题目表
CREATE TABLE `drive_question` (
  `question_id` varchar(32) NOT NULL COMMENT '题目ID，使用UUID',
  `subject` tinyint(1) NOT NULL COMMENT '科目：1-科目一，4-科目四',
  `question_type` varchar(50) NOT NULL COMMENT '题型代码：traffic_signs-交通标志，traffic_rules-交通法规等',
  `question_type_name` varchar(50) NOT NULL COMMENT '题型名称',
  `question` text NOT NULL COMMENT '题目内容',
  `item1` varchar(500) DEFAULT NULL COMMENT '选项A',
  `item2` varchar(500) DEFAULT NULL COMMENT '选项B',
  `item3` varchar(500) DEFAULT NULL COMMENT '选项C',
  `item4` varchar(500) DEFAULT NULL COMMENT '选项D',
  `answer` tinyint(1) NOT NULL COMMENT '正确答案：1-A，2-B，3-C，4-D',
  `explains` text DEFAULT NULL COMMENT '题目解析',
  `image_url` varchar(255) DEFAULT NULL COMMENT '题目配图URL',
  `difficulty` tinyint(1) DEFAULT 1 COMMENT '难度等级：1-简单，2-中等，3-困难',
  `is_vip` tinyint(1) DEFAULT 0 COMMENT '是否VIP题目：0-免费，1-VIP',
  `sequence_order` int(11) DEFAULT 0 COMMENT '顺序刷题排序',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览次数',
  `error_count` int(11) DEFAULT 0 COMMENT '错误次数',
  `correct_count` int(11) DEFAULT 0 COMMENT '正确次数',
  `correct_rate` decimal(5,2) DEFAULT 0.00 COMMENT '正确率',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`question_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_question_type` (`question_type`),
  KEY `idx_difficulty` (`difficulty`),
  KEY `idx_sequence_order` (`sequence_order`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='驾考题目表';

-- 用户答题记录表（反三范式，冗余用户和题目信息）
CREATE TABLE `user_answer_record` (
  `record_id` varchar(32) NOT NULL COMMENT '答题记录ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `question_id` varchar(32) NOT NULL COMMENT '题目ID',
  `subject` tinyint(1) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(50) NOT NULL COMMENT '题型代码（冗余）',
  `question_type_name` varchar(50) NOT NULL COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `correct_answer` tinyint(1) NOT NULL COMMENT '正确答案（冗余）',
  `user_answer` tinyint(1) DEFAULT NULL COMMENT '用户答案：1-A，2-B，3-C，4-D，NULL-未答',
  `is_correct` tinyint(1) DEFAULT NULL COMMENT '是否正确：0-错误，1-正确，NULL-未答',
  `answer_time` int(11) DEFAULT NULL COMMENT '答题用时（秒）',
  `test_type` varchar(20) NOT NULL COMMENT '测试类型：order-顺序刷题，random-随机考试',
  `exam_id` varchar(32) DEFAULT NULL COMMENT '考试ID（如果是考试答题）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_test_type` (`test_type`),
  KEY `idx_exam_id` (`exam_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户答题记录表';

-- 考试记录表（反三范式，冗余用户信息）
CREATE TABLE `exam_record` (
  `exam_id` varchar(32) NOT NULL COMMENT '考试ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `subject` tinyint(1) NOT NULL COMMENT '考试科目：1-科目一，4-科目四',
  `total_questions` int(11) NOT NULL DEFAULT 100 COMMENT '总题数',
  `answered_questions` int(11) DEFAULT 0 COMMENT '已答题数',
  `correct_count` int(11) DEFAULT 0 COMMENT '正确题数',
  `wrong_count` int(11) DEFAULT 0 COMMENT '错误题数',
  `score` decimal(5,2) DEFAULT 0.00 COMMENT '得分',
  `pass_score` decimal(5,2) DEFAULT 90.00 COMMENT '及格分数',
  `is_pass` tinyint(1) DEFAULT 0 COMMENT '是否通过：0-未通过，1-通过',
  `exam_duration` int(11) DEFAULT 2700 COMMENT '考试时长（秒）',
  `used_time` int(11) DEFAULT 0 COMMENT '已用时间（秒）',
  `remaining_time` int(11) DEFAULT 0 COMMENT '剩余时间（秒）',
  `status` tinyint(1) DEFAULT 0 COMMENT '考试状态：0-进行中，1-已完成，2-已放弃',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`exam_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_status` (`status`),
  KEY `idx_is_pass` (`is_pass`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试记录表';

-- 用户收藏表（反三范式，冗余题目信息）
CREATE TABLE `user_favorite` (
  `favorite_id` varchar(32) NOT NULL COMMENT '收藏ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `question_id` varchar(32) NOT NULL COMMENT '题目ID',
  `subject` tinyint(1) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(50) NOT NULL COMMENT '题型代码（冗余）',
  `question_type_name` varchar(50) NOT NULL COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `question_image_url` varchar(255) DEFAULT NULL COMMENT '题目配图URL（冗余）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`favorite_id`),
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏表';

-- 错题本表（反三范式，冗余题目和用户信息）
CREATE TABLE `user_wrong_question` (
  `wrong_id` varchar(32) NOT NULL COMMENT '错题ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `question_id` varchar(32) NOT NULL COMMENT '题目ID',
  `subject` tinyint(1) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(50) NOT NULL COMMENT '题型代码（冗余）',
  `question_type_name` varchar(50) NOT NULL COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `question_image_url` varchar(255) DEFAULT NULL COMMENT '题目配图URL（冗余）',
  `correct_answer` tinyint(1) NOT NULL COMMENT '正确答案（冗余）',
  `wrong_count` int(11) DEFAULT 1 COMMENT '错误次数',
  `last_wrong_answer` tinyint(1) DEFAULT NULL COMMENT '最后一次错误答案',
  `is_mastered` tinyint(1) DEFAULT 0 COMMENT '是否已掌握：0-未掌握，1-已掌握',
  `mastered_time` datetime DEFAULT NULL COMMENT '掌握时间',
  `first_wrong_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次错误时间',
  `last_wrong_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后错误时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`wrong_id`),
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_is_mastered` (`is_mastered`),
  KEY `idx_wrong_count` (`wrong_count`),
  KEY `idx_last_wrong_time` (`last_wrong_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题本表';

-- 学习记录表（反三范式，冗余用户信息）
CREATE TABLE `user_study_record` (
  `record_id` varchar(32) NOT NULL COMMENT '学习记录ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `study_date` date NOT NULL COMMENT '学习日期',
  `subject` tinyint(1) NOT NULL COMMENT '科目',
  `study_type` varchar(20) NOT NULL COMMENT '学习类型：sequential-顺序刷题，exam-模拟考试，wrong-错题练习',
  `total_questions` int(11) DEFAULT 0 COMMENT '总题数',
  `correct_count` int(11) DEFAULT 0 COMMENT '正确题数',
  `wrong_count` int(11) DEFAULT 0 COMMENT '错误题数',
  `accuracy_rate` decimal(5,2) DEFAULT 0.00 COMMENT '正确率',
  `study_time` int(11) DEFAULT 0 COMMENT '学习时长（分钟）',
  `points_earned` int(11) DEFAULT 0 COMMENT '获得积分',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `uk_user_date_subject_type` (`user_id`, `study_date`, `subject`, `study_type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_study_date` (`study_date`),
  KEY `idx_subject` (`subject`),
  KEY `idx_study_type` (`study_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习记录表';

-- 积分商城商品表
CREATE TABLE `points_mall_product` (
  `product_id` varchar(32) NOT NULL COMMENT '商品ID，使用UUID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称',
  `product_desc` text DEFAULT NULL COMMENT '商品描述',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片URL',
  `product_type` varchar(50) NOT NULL COMMENT '商品类型：course-课程，vip-VIP会员，gift-实物礼品',
  `points_price` int(11) NOT NULL COMMENT '积分价格',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `stock_quantity` int(11) DEFAULT -1 COMMENT '库存数量，-1表示无限',
  `exchange_limit` int(11) DEFAULT -1 COMMENT '兑换限制，-1表示无限制',
  `is_hot` tinyint(1) DEFAULT 0 COMMENT '是否热门：0-否，1-是',
  `sort_order` int(11) DEFAULT 0 COMMENT '排序权重',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-下架，1-上架',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`product_id`),
  KEY `idx_product_type` (`product_type`),
  KEY `idx_status` (`status`),
  KEY `idx_is_hot` (`is_hot`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分商城商品表';

-- 积分兑换记录表（反三范式，冗余用户和商品信息）
CREATE TABLE `points_exchange_record` (
  `exchange_id` varchar(32) NOT NULL COMMENT '兑换记录ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `user_phone` varchar(11) DEFAULT NULL COMMENT '用户手机号（冗余）',
  `product_id` varchar(32) NOT NULL COMMENT '商品ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称（冗余）',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片（冗余）',
  `points_cost` int(11) NOT NULL COMMENT '消耗积分',
  `exchange_quantity` int(11) DEFAULT 1 COMMENT '兑换数量',
  `delivery_info` text DEFAULT NULL COMMENT '配送信息JSON',
  `status` tinyint(1) DEFAULT 0 COMMENT '兑换状态：0-待处理，1-已发货，2-已完成，3-已取消',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`exchange_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分兑换记录表';

-- 交规视频表
CREATE TABLE `traffic_video` (
  `video_id` varchar(32) NOT NULL COMMENT '视频ID，使用UUID',
  `video_title` varchar(200) NOT NULL COMMENT '视频标题',
  `video_desc` text DEFAULT NULL COMMENT '视频描述',
  `cover_image` varchar(255) DEFAULT NULL COMMENT '封面图片URL',
  `video_url` varchar(255) NOT NULL COMMENT '视频URL',
  `video_duration` int(11) DEFAULT 0 COMMENT '视频时长（秒）',
  `category` varchar(50) DEFAULT NULL COMMENT '视频分类',
  `tags` varchar(500) DEFAULT NULL COMMENT '标签，逗号分隔',
  `is_vip` tinyint(1) DEFAULT 0 COMMENT '是否VIP视频：0-免费，1-VIP',
  `view_count` int(11) DEFAULT 0 COMMENT '观看次数',
  `like_count` int(11) DEFAULT 0 COMMENT '点赞次数',
  `share_count` int(11) DEFAULT 0 COMMENT '分享次数',
  `sort_order` int(11) DEFAULT 0 COMMENT '排序权重',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-下架，1-上架',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`video_id`),
  KEY `idx_category` (`category`),
  KEY `idx_is_vip` (`is_vip`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_view_count` (`view_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交规视频表';

-- 交通标志表
CREATE TABLE `traffic_sign` (
  `sign_id` varchar(32) NOT NULL COMMENT '标志ID，使用UUID',
  `sign_name` varchar(100) NOT NULL COMMENT '标志名称',
  `sign_desc` text DEFAULT NULL COMMENT '标志说明',
  `sign_image` varchar(255) NOT NULL COMMENT '标志图片URL',
  `sign_category` varchar(50) NOT NULL COMMENT '标志类别：warning-警告标志，prohibition-禁令标志等',
  `sign_type` varchar(50) DEFAULT NULL COMMENT '标志类型',
  `usage_scene` text DEFAULT NULL COMMENT '使用场景',
  `related_regulations` text DEFAULT NULL COMMENT '相关法规',
  `sort_order` int(11) DEFAULT 0 COMMENT '排序权重',
  `view_count` int(11) DEFAULT 0 COMMENT '查看次数',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`sign_id`),
  KEY `idx_sign_category` (`sign_category`),
  KEY `idx_sign_type` (`sign_type`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交通标志表';

-- 题目评论表（反三范式，冗余用户和题目信息）
CREATE TABLE `question_comment` (
  `comment_id` varchar(32) NOT NULL COMMENT '评论ID，使用UUID',
  `question_id` varchar(32) NOT NULL COMMENT '题目ID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称（冗余）',
  `user_avatar` varchar(255) DEFAULT NULL COMMENT '用户头像（冗余）',
  `parent_comment_id` varchar(32) DEFAULT NULL COMMENT '父评论ID（回复功能）',
  `comment_content` text NOT NULL COMMENT '评论内容',
  `like_count` int(11) DEFAULT 0 COMMENT '点赞数',
  `reply_count` int(11) DEFAULT 0 COMMENT '回复数',
  `is_hot` tinyint(1) DEFAULT 0 COMMENT '是否热门评论：0-否，1-是',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-已删除，1-正常',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_comment_id` (`parent_comment_id`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目评论表';

-- 用户点赞记录表
CREATE TABLE `user_like_record` (
  `like_id` varchar(32) NOT NULL COMMENT '点赞ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `target_type` varchar(20) NOT NULL COMMENT '点赞对象类型：comment-评论，video-视频',
  `target_id` varchar(32) NOT NULL COMMENT '点赞对象ID',
  `is_like` tinyint(1) DEFAULT 1 COMMENT '是否点赞：0-取消点赞，1-点赞',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_user_target` (`user_id`, `target_type`, `target_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户点赞记录表';

-- 用户学习统计表（反三范式，聚合统计数据）
CREATE TABLE `user_study_statistics` (
  `stat_id` varchar(32) NOT NULL COMMENT '统计ID，使用UUID',
  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
  `subject` tinyint(1) NOT NULL COMMENT '科目',
  `total_study_days` int(11) DEFAULT 0 COMMENT '总学习天数',
  `total_questions` int(11) DEFAULT 0 COMMENT '总做题数',
  `total_correct` int(11) DEFAULT 0 COMMENT '总正确数',
  `total_wrong` int(11) DEFAULT 0 COMMENT '总错误数',
  `overall_accuracy` decimal(5,2) DEFAULT 0.00 COMMENT '总体正确率',
  `total_study_time` int(11) DEFAULT 0 COMMENT '总学习时长（分钟）',
  `total_exams` int(11) DEFAULT 0 COMMENT '总考试次数',
  `passed_exams` int(11) DEFAULT 0 COMMENT '通过考试次数',
  `best_score` decimal(5,2) DEFAULT 0.00 COMMENT '最好成绩',
  `avg_score` decimal(5,2) DEFAULT 0.00 COMMENT '平均成绩',
  `current_streak` int(11) DEFAULT 0 COMMENT '当前连续学习天数',
  `longest_streak` int(11) DEFAULT 0 COMMENT '最长连续学习天数',
  `weak_question_types` text DEFAULT NULL COMMENT '薄弱题型JSON',
  `strong_question_types` text DEFAULT NULL COMMENT '擅长题型JSON',
  `last_study_date` date DEFAULT NULL COMMENT '最后学习日期',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stat_id`),
  UNIQUE KEY `uk_user_subject` (`user_id`, `subject`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_overall_accuracy` (`overall_accuracy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习统计表';

-- 系统配置表
CREATE TABLE `system_config` (
  `config_id` varchar(32) NOT NULL COMMENT '配置ID，使用UUID',
  `config_key` varchar(100) NOT NULL COMMENT '配置键',
  `config_value` text DEFAULT NULL COMMENT '配置值',
  `config_desc` varchar(255) DEFAULT NULL COMMENT '配置描述',
  `config_type` varchar(20) DEFAULT 'STRING' COMMENT '配置类型：STRING,NUMBER,JSON',
  `is_system` tinyint(1) DEFAULT 0 COMMENT '是否系统配置：0-否，1-是',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`),
  KEY `idx_config_type` (`config_type`),
  KEY `idx_is_system` (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 初始化系统配置数据
INSERT INTO `system_config` VALUES
('sys_001', 'exam_duration_subject1', '2700', '科目一考试时长(秒)', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_002', 'exam_duration_subject4', '1800', '科目四考试时长(秒)', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_003', 'exam_question_count_subject1', '100', '科目一考试题数', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_004', 'exam_question_count_subject4', '50', '科目四考试题数', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_005', 'exam_pass_score', '90', '考试及格分数', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_006', 'daily_points_limit', '50', '每日积分上限', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_007', 'question_point_reward', '1', '每道题积分奖励', 'NUMBER', 1, 1, NOW(), NOW()),
('sys_008', 'exam_pass_point_reward', '10', '考试通过积分奖励', 'NUMBER', 1, 1, NOW(), NOW());

-- =============================================
-- 设计说明：
-- 1. 遵循阿里巴巴Java开发手册，使用utf8mb4字符集
-- 2. 不使用主键自增，使用UUID作为主键
-- 3. 不使用外键关系，通过应用层维护数据一致性
-- 4. 反三范式设计，冗余存储常用字段提高查询性能
-- 5. 所有表均包含create_time和update_time字段
-- 6. 高频查询字段均建立了索引优化
-- 7. 使用tinyint代替boolean，符合MySQL最佳实践
-- =============================================
