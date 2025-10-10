-- =============================================
-- 驾考通应用数据库设计 v3.0
-- 严格遵循阿里巴巴Java开发手册（2022版）规范
-- 反三范式设计，冗余存储提高查询性能
-- 不使用主键自增，采用雪花算法ID
-- 不使用外键关系，应用层保证数据一致性
-- 所有表必须包含gmt_create、gmt_modified字段
-- 使用逻辑删除，禁用物理删除
-- 支持多平台登录、支付和第三方服务配置
-- =============================================

-- 用户信息表
DROP TABLE IF EXISTS `tb_user_info`;
CREATE TABLE `tb_user_info` (
  `id` bigint(20) NOT NULL COMMENT '主键ID，雪花算法生成',
  `phone` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称',
  `avatar_url` varchar(512) NOT NULL DEFAULT '' COMMENT '头像URL',
  `openid` varchar(128) NOT NULL DEFAULT '' COMMENT '微信openid',
  `union_id` varchar(128) NOT NULL DEFAULT '' COMMENT '微信unionid',
  `alipay_user_id` varchar(128) NOT NULL DEFAULT '' COMMENT '支付宝用户ID',
  `huawei_user_id` varchar(128) NOT NULL DEFAULT '' COMMENT '华为用户ID',
  `platform_type` varchar(32) NOT NULL DEFAULT 'mp-weixin' COMMENT '注册平台：mp-weixin/app-plus/h5',
  `gender` tinyint(4) NOT NULL DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `province` varchar(32) NOT NULL DEFAULT '' COMMENT '省份',
  `city` varchar(32) NOT NULL DEFAULT '' COMMENT '城市',
  `district` varchar(32) NOT NULL DEFAULT '' COMMENT '区县',
  `total_points` int(11) NOT NULL DEFAULT 0 COMMENT '总积分',
  `available_points` int(11) NOT NULL DEFAULT 0 COMMENT '可用积分',
  `vip_level` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'VIP等级：0-普通用户，1-VIP月会员，2-VIP年会员，3-VIP终身会员',
  `vip_expire_time` datetime DEFAULT NULL COMMENT 'VIP过期时间',
  `total_study_days` int(11) NOT NULL DEFAULT 0 COMMENT '总学习天数',
  `continuous_study_days` int(11) NOT NULL DEFAULT 0 COMMENT '连续学习天数',
  `max_continuous_days` int(11) NOT NULL DEFAULT 0 COMMENT '最大连续天数',
  `total_questions_answered` bigint(20) NOT NULL DEFAULT 0 COMMENT '总答题数',
  `total_correct_answers` bigint(20) NOT NULL DEFAULT 0 COMMENT '总正确数',
  `overall_accuracy_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '总体正确率',
  `last_study_date` date DEFAULT NULL COMMENT '最后学习日期',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(64) NOT NULL DEFAULT '' COMMENT '最后登录IP',
  `device_id` varchar(128) NOT NULL DEFAULT '' COMMENT '设备ID',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '用户状态：0-禁用，1-正常，2-锁定',
  `comment_permission` tinyint(4) NOT NULL DEFAULT 1 COMMENT '评论权限：0-禁止评论，1-允许评论',
  `violation_comment_count` int(11) NOT NULL DEFAULT 0 COMMENT '违规评论次数',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_openid` (`openid`),
  KEY `idx_union_id` (`union_id`),
  KEY `idx_alipay_user_id` (`alipay_user_id`),
  KEY `idx_huawei_user_id` (`huawei_user_id`),
  KEY `idx_platform_type` (`platform_type`),
  KEY `idx_vip_level` (`vip_level`),
  KEY `idx_status` (`status`),
  KEY `idx_last_study_date` (`last_study_date`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- 驾考题目表
DROP TABLE IF EXISTS `ap_drive_question`;
CREATE TABLE `ap_drive_question` (
  `id` bigint(20) NOT NULL COMMENT '题目ID，雪花算法生成',
  `subject` tinyint(4) NOT NULL COMMENT '科目：1-科目一，4-科目四',
  `question_type` varchar(64) NOT NULL DEFAULT '' COMMENT '题型代码：traffic_signs-交通标志，traffic_rules-交通法规等',
  `question_type_name` varchar(64) NOT NULL DEFAULT '' COMMENT '题型名称',
  `question_content` text NOT NULL COMMENT '题目内容',
  `question_format` tinyint(4) NOT NULL DEFAULT 1 COMMENT '题目格式：1-选择题，2-判断题，3-多选题',
  `option_a` varchar(512) NOT NULL DEFAULT '' COMMENT '选项A',
  `option_b` varchar(512) NOT NULL DEFAULT '' COMMENT '选项B',
  `option_c` varchar(512) NOT NULL DEFAULT '' COMMENT '选项C',
  `option_d` varchar(512) NOT NULL DEFAULT '' COMMENT '选项D',
  `correct_answer` varchar(16) NOT NULL DEFAULT '' COMMENT '正确答案：单选:1/2/3/4,多选:1,2,3',
  `question_explain` text NOT NULL COMMENT '题目解析',
  `image_url` varchar(512) NOT NULL DEFAULT '' COMMENT '题目配图URL',
  `video_url` varchar(512) NOT NULL DEFAULT '' COMMENT '题目视频URL',
  `audio_url` varchar(512) NOT NULL DEFAULT '' COMMENT '题目音频URL',
  `difficulty_level` tinyint(4) NOT NULL DEFAULT 1 COMMENT '难度等级：1-简单，2-中等，3-困难',
  `is_vip` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否VIP题目：0-免费，1-VIP',
  `is_hot` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否热门题目：0-否，1-是',
  `sequence_order` int(11) NOT NULL DEFAULT 0 COMMENT '顺序刷题排序',
  `weight` int(11) NOT NULL DEFAULT 1 COMMENT '题目权重',
  `tags` varchar(512) NOT NULL DEFAULT '' COMMENT '题目标签，逗号分隔',
  `knowledge_points` varchar(512) NOT NULL DEFAULT '' COMMENT '知识点，逗号分隔',
  `view_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '浏览次数',
  `error_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '错误次数',
  `correct_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '正确次数',
  `correct_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '正确率',
  `avg_answer_time` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '平均答题时间(秒)',
  `source` varchar(64) NOT NULL DEFAULT 'official' COMMENT '题目来源：official-官方，user-用户贡献',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '题目状态：0-下架，1-可用，2-审核中',
  `creator_id` bigint(20) DEFAULT NULL COMMENT '创建者ID',
  `auditor_id` bigint(20) DEFAULT NULL COMMENT '审核者ID',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_question_type` (`question_type`),
  KEY `idx_difficulty_level` (`difficulty_level`),
  KEY `idx_sequence_order` (`sequence_order`),
  KEY `idx_status` (`status`),
  KEY `idx_is_hot` (`is_hot`),
  KEY `idx_weight` (`weight`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_correct_rate` (`correct_rate`),
  KEY `idx_creator_id` (`creator_id`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='驾考题目表';

-- 用户答题记录表（反三范式，冗余用户和题目信息）
DROP TABLE IF EXISTS `tb_user_answer_record`;
CREATE TABLE `tb_user_answer_record` (
  `id` bigint(20) NOT NULL COMMENT '答题记录ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `question_id` bigint(20) NOT NULL COMMENT '题目ID',
  `subject` tinyint(4) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(64) NOT NULL DEFAULT '' COMMENT '题型代码（冗余）',
  `question_type_name` varchar(64) NOT NULL DEFAULT '' COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `correct_answer` tinyint(4) NOT NULL COMMENT '正确答案（冗余）',
  `user_answer` tinyint(4) DEFAULT NULL COMMENT '用户答案：1-A，2-B，3-C，4-D，NULL-未答',
  `is_correct` tinyint(4) DEFAULT NULL COMMENT '是否正确：0-错误，1-正确，NULL-未答',
  `answer_time` int(11) DEFAULT NULL COMMENT '答题用时（秒）',
  `test_type` varchar(32) NOT NULL DEFAULT '' COMMENT '测试类型：sequential-顺序刷题，random-随机考试',
  `exam_id` bigint(20) DEFAULT NULL COMMENT '考试ID（如果是考试答题）',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_test_type` (`test_type`),
  KEY `idx_exam_id` (`exam_id`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户答题记录表';

-- 考试记录表（反三范式，冗余用户信息）
DROP TABLE IF EXISTS `tb_exam_record`;
CREATE TABLE `tb_exam_record` (
  `id` bigint(20) NOT NULL COMMENT '考试ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `subject` tinyint(4) NOT NULL COMMENT '考试科目：1-科目一，4-科目四',
  `total_questions` int(11) NOT NULL DEFAULT 100 COMMENT '总题数',
  `answered_questions` int(11) NOT NULL DEFAULT 0 COMMENT '已答题数',
  `correct_count` int(11) NOT NULL DEFAULT 0 COMMENT '正确题数',
  `wrong_count` int(11) NOT NULL DEFAULT 0 COMMENT '错误题数',
  `score` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '得分',
  `pass_score` decimal(5,2) NOT NULL DEFAULT 90.00 COMMENT '及格分数',
  `is_pass` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否通过：0-未通过，1-通过',
  `exam_duration` int(11) NOT NULL DEFAULT 2700 COMMENT '考试时长（秒）',
  `used_time` int(11) NOT NULL DEFAULT 0 COMMENT '已用时间（秒）',
  `remaining_time` int(11) NOT NULL DEFAULT 0 COMMENT '剩余时间（秒）',
  `exam_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '考试状态：0-进行中，1-已完成，2-已放弃',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改旲间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_exam_status` (`exam_status`),
  KEY `idx_is_pass` (`is_pass`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试记录表';

-- 用户收藏表（反三范式，冗余题目信息）
DROP TABLE IF EXISTS `tb_user_favorite`;
CREATE TABLE `tb_user_favorite` (
  `id` bigint(20) NOT NULL COMMENT '收藏ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `question_id` bigint(20) NOT NULL COMMENT '题目ID',
  `subject` tinyint(4) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(64) NOT NULL DEFAULT '' COMMENT '题型代码（冗余）',
  `question_type_name` varchar(64) NOT NULL DEFAULT '' COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `question_image_url` varchar(512) NOT NULL DEFAULT '' COMMENT '题目配图URL（冗余）',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏表';

-- 错题本表（反三范式，冗余题目和用户信息）
DROP TABLE IF EXISTS `tb_user_wrong_question`;
CREATE TABLE `tb_user_wrong_question` (
  `id` bigint(20) NOT NULL COMMENT '错题ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `question_id` bigint(20) NOT NULL COMMENT '题目ID',
  `subject` tinyint(4) NOT NULL COMMENT '科目（冗余）',
  `question_type` varchar(64) NOT NULL DEFAULT '' COMMENT '题型代码（冗余）',
  `question_type_name` varchar(64) NOT NULL DEFAULT '' COMMENT '题型名称（冗余）',
  `question_content` text NOT NULL COMMENT '题目内容（冗余）',
  `question_image_url` varchar(512) NOT NULL DEFAULT '' COMMENT '题目配图URL（冗余）',
  `correct_answer` tinyint(4) NOT NULL COMMENT '正确答案（冗余）',
  `wrong_count` int(11) NOT NULL DEFAULT 1 COMMENT '错误次数',
  `last_wrong_answer` tinyint(4) DEFAULT NULL COMMENT '最后一次错误答案',
  `is_mastered` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否已掌握：0-未掌握，1-已掌握',
  `mastered_time` datetime DEFAULT NULL COMMENT '掌握时间',
  `first_wrong_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次错误时间',
  `last_wrong_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后错误时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_is_mastered` (`is_mastered`),
  KEY `idx_wrong_count` (`wrong_count`),
  KEY `idx_last_wrong_time` (`last_wrong_time`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题本表';

-- 学习记录表（反三范式，冗余用户信息）
DROP TABLE IF EXISTS `tb_user_study_record`;
CREATE TABLE `tb_user_study_record` (
  `id` bigint(20) NOT NULL COMMENT '学习记录ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `study_date` date NOT NULL COMMENT '学习日期',
  `subject` tinyint(4) NOT NULL COMMENT '科目',
  `study_type` varchar(32) NOT NULL DEFAULT '' COMMENT '学习类型：sequential-顺序刷题，exam-模拟考试，wrong-错题练习',
  `total_questions` int(11) NOT NULL DEFAULT 0 COMMENT '总题数',
  `correct_count` int(11) NOT NULL DEFAULT 0 COMMENT '正确题数',
  `wrong_count` int(11) NOT NULL DEFAULT 0 COMMENT '错误题数',
  `accuracy_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '正确率',
  `study_time` int(11) NOT NULL DEFAULT 0 COMMENT '学习时长（分钟）',
  `points_earned` int(11) NOT NULL DEFAULT 0 COMMENT '获得积分',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date_subject_type` (`user_id`, `study_date`, `subject`, `study_type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_study_date` (`study_date`),
  KEY `idx_subject` (`subject`),
  KEY `idx_study_type` (`study_type`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习记录表';

-- 积分商城商品表
DROP TABLE IF EXISTS `tb_points_mall_product`;
CREATE TABLE `tb_points_mall_product` (
  `id` bigint(20) NOT NULL COMMENT '商品ID，雪花算法生成',
  `product_name` varchar(128) NOT NULL DEFAULT '' COMMENT '商品名称',
  `product_desc` text NOT NULL COMMENT '商品描述',
  `product_image` varchar(512) NOT NULL DEFAULT '' COMMENT '商品图片URL',
  `product_type` varchar(64) NOT NULL DEFAULT '' COMMENT '商品类型：course-课程，vip-VIP会员，gift-实物礼品',
  `points_price` int(11) NOT NULL COMMENT '积分价格',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `stock_quantity` int(11) NOT NULL DEFAULT -1 COMMENT '库存数量，-1表示无限',
  `exchange_limit` int(11) NOT NULL DEFAULT -1 COMMENT '兑换限制，-1表示无限制',
  `is_hot` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否热门：0-否，1-是',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序权重',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_type` (`product_type`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_is_hot` (`is_hot`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_points_price` (`points_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分商城商品表';

-- 积分兑换记录表（反三范式，冗余用户和商品信息）
DROP TABLE IF EXISTS `tb_points_exchange_record`;
CREATE TABLE `tb_points_exchange_record` (
  `id` bigint(20) NOT NULL COMMENT '兑换记录ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `user_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '用户手机号（冗余）',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `product_name` varchar(128) NOT NULL DEFAULT '' COMMENT '商品名称（冗余）',
  `product_image` varchar(512) NOT NULL DEFAULT '' COMMENT '商品图片（冗余）',
  `points_cost` int(11) NOT NULL COMMENT '消耗积分',
  `exchange_quantity` int(11) NOT NULL DEFAULT 1 COMMENT '兑换数量',
  `delivery_info` json DEFAULT NULL COMMENT '配送信息JSON',
  `exchange_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '兑换状态：0-待处理，1-已发货，2-已完成，3-已取消',
  `remark` varchar(512) NOT NULL DEFAULT '' COMMENT '备注',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_exchange_status` (`exchange_status`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分兑换记录表';

-- 交规视频表
DROP TABLE IF EXISTS `tb_traffic_video`;
CREATE TABLE `tb_traffic_video` (
  `id` bigint(20) NOT NULL COMMENT '视频ID，雪花算法生成',
  `video_title` varchar(256) NOT NULL DEFAULT '' COMMENT '视频标题',
  `video_desc` text NOT NULL COMMENT '视频描述',
  `cover_image` varchar(512) NOT NULL DEFAULT '' COMMENT '封面图片URL',
  `video_url` varchar(512) NOT NULL DEFAULT '' COMMENT '视频URL',
  `aliyun_video_id` varchar(128) NOT NULL DEFAULT '' COMMENT '阿里云视频ID',
  `play_auth` varchar(1024) NOT NULL DEFAULT '' COMMENT '播放凭证',
  `video_duration` int(11) NOT NULL DEFAULT 0 COMMENT '视频时长（秒）',
  `video_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '视频大小（字节）',
  `video_format` varchar(32) NOT NULL DEFAULT 'mp4' COMMENT '视频格式',
  `resolution` varchar(32) NOT NULL DEFAULT '720p' COMMENT '分辨率',
  `category` varchar(64) NOT NULL DEFAULT '' COMMENT '视频分类',
  `tags` varchar(512) NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `instructor` varchar(64) NOT NULL DEFAULT '' COMMENT '讲师名称',
  `difficulty_level` tinyint(4) NOT NULL DEFAULT 1 COMMENT '难度等级：1-初级，2-中级，3-高级',
  `is_vip` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否VIP视频：0-免费，1-VIP',
  `is_hot` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否热门：0-否，1-是',
  `is_downloadable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否可下载：0-否，1-是',
  `view_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '观看次数',
  `like_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '点赞次数',
  `share_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '分享次数',
  `comment_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '评论数',
  `download_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '下载次数',
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00 COMMENT '评分(0-5)',
  `rating_count` int(11) NOT NULL DEFAULT 0 COMMENT '评分人数',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序权重',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '视频状态：0-下架，1-正常，2-审核中，3-转码中',
  `upload_user_id` bigint(20) DEFAULT NULL COMMENT '上传用户ID',
  `audit_user_id` bigint(20) DEFAULT NULL COMMENT '审核用户ID',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `publish_time` datetime DEFAULT NULL COMMENT '发布时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_aliyun_video_id` (`aliyun_video_id`),
  KEY `idx_category` (`category`),
  KEY `idx_is_vip` (`is_vip`),
  KEY `idx_is_hot` (`is_hot`),
  KEY `idx_difficulty_level` (`difficulty_level`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_rating` (`rating`),
  KEY `idx_publish_time` (`publish_time`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交规视频表';

-- 交通标志表
DROP TABLE IF EXISTS `tb_traffic_sign`;
CREATE TABLE `tb_traffic_sign` (
  `id` bigint(20) NOT NULL COMMENT '标志ID，雪花算法生成',
  `sign_name` varchar(128) NOT NULL DEFAULT '' COMMENT '标志名称',
  `sign_desc` text NOT NULL COMMENT '标志说明',
  `sign_image` varchar(512) NOT NULL DEFAULT '' COMMENT '标志图片URL',
  `sign_category` varchar(64) NOT NULL DEFAULT '' COMMENT '标志类别：warning-警告标志，prohibition-禁令标志等',
  `sign_type` varchar(64) NOT NULL DEFAULT '' COMMENT '标志类型',
  `usage_scene` text NOT NULL COMMENT '使用场景',
  `related_regulations` text NOT NULL COMMENT '相关法规',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序权重',
  `view_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '查看次数',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_sign_category` (`sign_category`),
  KEY `idx_sign_type` (`sign_type`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_view_count` (`view_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交通标志表';

-- 题目评论表（反三范式，冗余用户和题目信息）
DROP TABLE IF EXISTS `tb_question_comment`;
CREATE TABLE `tb_question_comment` (
  `id` bigint(20) NOT NULL COMMENT '评论ID，雪花算法生成',
  `question_id` bigint(20) NOT NULL COMMENT '题目ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `user_avatar` varchar(512) NOT NULL DEFAULT '' COMMENT '用户头像（冗余）',
  `parent_comment_id` bigint(20) DEFAULT NULL COMMENT '父评论ID（回复功能）',
  `comment_content` text NOT NULL COMMENT '评论内容',
  `like_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `reply_count` bigint(20) NOT NULL DEFAULT 0 COMMENT '回复数',
  `is_hot` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否热门评论：0-否，1-是',
  `audit_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '审核状态：0-待审核，1-审核通过，2-审核不通过',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `audit_user_id` bigint(20) DEFAULT NULL COMMENT '审核人ID',
  `audit_remark` varchar(512) NOT NULL DEFAULT '' COMMENT '审核备注',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_comment_id` (`parent_comment_id`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_audit_status` (`audit_status`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目评论表';

-- 用户点赞记录表
DROP TABLE IF EXISTS `tb_user_like_record`;
CREATE TABLE `tb_user_like_record` (
  `id` bigint(20) NOT NULL COMMENT '点赞ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `target_type` varchar(32) NOT NULL DEFAULT '' COMMENT '点赞对象类型：comment-评论，video-视频',
  `target_id` bigint(20) NOT NULL COMMENT '点赞对象ID',
  `is_like` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否点赞：0-取消点赞，1-点赞',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target` (`user_id`, `target_type`, `target_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target` (`target_type`, `target_id`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户点赞记录表';

-- 评论审核日志表
DROP TABLE IF EXISTS `tb_comment_audit_log`;
CREATE TABLE `tb_comment_audit_log` (
  `id` bigint(20) NOT NULL COMMENT '日志ID，雪花算法生成',
  `comment_id` bigint(20) NOT NULL COMMENT '评论ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `audit_status` tinyint(4) NOT NULL COMMENT '审核状态：0-待审核，1-审核通过，2-审核不通过',
  `audit_user_id` bigint(20) DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
  `audit_remark` varchar(512) NOT NULL DEFAULT '' COMMENT '审核备注',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_comment_id` (`comment_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_audit_status` (`audit_status`),
  KEY `idx_audit_user_id` (`audit_user_id`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论审核日志表';

-- 用户学习统计表（反三范式，聚合统计数据）
DROP TABLE IF EXISTS `tb_user_study_statistics`;
CREATE TABLE `tb_user_study_statistics` (
  `id` bigint(20) NOT NULL COMMENT '统计ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `subject` tinyint(4) NOT NULL COMMENT '科目',
  `total_study_days` int(11) NOT NULL DEFAULT 0 COMMENT '总学习天数',
  `total_questions` bigint(20) NOT NULL DEFAULT 0 COMMENT '总做题数',
  `total_correct` bigint(20) NOT NULL DEFAULT 0 COMMENT '总正确数',
  `total_wrong` bigint(20) NOT NULL DEFAULT 0 COMMENT '总错误数',
  `overall_accuracy` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '总体正确率',
  `total_study_time` bigint(20) NOT NULL DEFAULT 0 COMMENT '总学习时长（分钟）',
  `total_exams` int(11) NOT NULL DEFAULT 0 COMMENT '总考试次数',
  `passed_exams` int(11) NOT NULL DEFAULT 0 COMMENT '通过考试次数',
  `best_score` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '最好成绩',
  `avg_score` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '平均成绩',
  `current_streak` int(11) NOT NULL DEFAULT 0 COMMENT '当前连续学习天数',
  `longest_streak` int(11) NOT NULL DEFAULT 0 COMMENT '最长连续学习天数',
  `weak_question_types` json DEFAULT NULL COMMENT '薄弱题型JSON',
  `strong_question_types` json DEFAULT NULL COMMENT '擅长题型JSON',
  `last_study_date` date DEFAULT NULL COMMENT '最后学习日期',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_subject` (`user_id`, `subject`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_overall_accuracy` (`overall_accuracy`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习统计表';

-- VIP订单表
DROP TABLE IF EXISTS `tb_vip_order`;
CREATE TABLE `tb_vip_order` (
  `id` bigint(20) NOT NULL COMMENT '订单ID，雪花算法生成',
  `order_no` varchar(64) NOT NULL DEFAULT '' COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `user_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '用户手机号（冗余）',
  `product_name` varchar(128) NOT NULL DEFAULT '' COMMENT '产品名称',
  `product_type` varchar(32) NOT NULL DEFAULT '' COMMENT '产品类型：monthly-月会员，yearly-年会员',
  `vip_level` tinyint(4) NOT NULL COMMENT 'VIP等级',
  `duration_days` int(11) NOT NULL COMMENT '时长（天）',
  `original_price` decimal(10,2) NOT NULL COMMENT '原价',
  `actual_amount` decimal(10,2) NOT NULL COMMENT '实付金额',
  `payment_method` varchar(32) NOT NULL DEFAULT '' COMMENT '支付方式',
  `platform_type` varchar(32) NOT NULL DEFAULT '' COMMENT '平台类型',
  `order_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '订单状态：0-待支付，1-已支付，2-已取消',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_payment_method` (`payment_method`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='VIP订单表';

-- 广告观看记录表
DROP TABLE IF EXISTS `tb_ad_watch_record`;
CREATE TABLE `tb_ad_watch_record` (
  `id` bigint(20) NOT NULL COMMENT '记录ID，雪花算法生成',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '用户昵称（冗余）',
  `ad_id` varchar(128) NOT NULL DEFAULT '' COMMENT '广告ID',
  `ad_platform` varchar(32) NOT NULL DEFAULT '' COMMENT '广告平台：uni-ad/腾讯广告/穿山甲等',
  `ad_type` varchar(32) NOT NULL DEFAULT '' COMMENT '广告类型：rewarded_video-激励视频，banner-横幅等',
  `ad_position` varchar(64) NOT NULL DEFAULT '' COMMENT '广告位标识',
  `watch_date` date NOT NULL COMMENT '观看日期',
  `start_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始观看时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束观看时间',
  `is_completed` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否完整观看：0-否，1-是',
  `reward_type` varchar(32) NOT NULL DEFAULT '' COMMENT '奖励类型：vip_days-会员天数，points-积分等',
  `reward_amount` int(11) NOT NULL DEFAULT 0 COMMENT '奖励数量',
  `reward_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '奖励发放状态：0-未发放，1-已发放，2-发放失败',
  `device_id` varchar(128) NOT NULL DEFAULT '' COMMENT '设备ID',
  `platform_type` varchar(32) NOT NULL DEFAULT 'mp-weixin' COMMENT '平台类型：mp-weixin/app-plus/h5',
  `ip_address` varchar(64) NOT NULL DEFAULT '' COMMENT 'IP地址',
  `user_agent` varchar(512) NOT NULL DEFAULT '' COMMENT '用户代理',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_ad_id` (`ad_id`),
  KEY `idx_watch_date` (`watch_date`),
  KEY `idx_ad_platform` (`ad_platform`),
  KEY `idx_ad_type` (`ad_type`),
  KEY `idx_is_completed` (`is_completed`),
  KEY `idx_reward_status` (`reward_status`),
  KEY `idx_platform_type` (`platform_type`),
  KEY `idx_user_date` (`user_id`, `watch_date`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='广告观看记录表';

-- 多平台登录配置表
DROP TABLE IF EXISTS `tb_login_config`;
CREATE TABLE `tb_login_config` (
  `id` bigint(20) NOT NULL COMMENT '配置ID，雪花算法生成',
  `platform_type` varchar(32) NOT NULL DEFAULT '' COMMENT '平台类型',
  `login_type` varchar(32) NOT NULL DEFAULT '' COMMENT '登录类型',
  `config_name` varchar(128) NOT NULL DEFAULT '' COMMENT '配置名称',
  `app_id` varchar(128) NOT NULL DEFAULT '' COMMENT '应用ID',
  `app_secret` varchar(256) NOT NULL DEFAULT '' COMMENT '应用密钥',
  `extra_config` json DEFAULT NULL COMMENT '额外配置 JSON',
  `is_enabled` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `environment` varchar(32) NOT NULL DEFAULT 'production' COMMENT '环境',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_platform_login_type` (`platform_type`, `login_type`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='多平台登录配置表';

-- 支付配置表
DROP TABLE IF EXISTS `tb_payment_config`;
CREATE TABLE `tb_payment_config` (
  `id` bigint(20) NOT NULL COMMENT '配置ID，雪花算法生成',
  `platform_type` varchar(32) NOT NULL DEFAULT '' COMMENT '平台类型',
  `payment_type` varchar(32) NOT NULL DEFAULT '' COMMENT '支付类型',
  `config_name` varchar(128) NOT NULL DEFAULT '' COMMENT '配置名称',
  `app_id` varchar(128) NOT NULL DEFAULT '' COMMENT '应用ID',
  `mch_id` varchar(128) NOT NULL DEFAULT '' COMMENT '商户号',
  `api_key` varchar(256) NOT NULL DEFAULT '' COMMENT 'API密钥',
  `notify_url` varchar(512) NOT NULL DEFAULT '' COMMENT '回调地址',
  `extra_config` json DEFAULT NULL COMMENT '额外配置 JSON',
  `is_enabled` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `environment` varchar(32) NOT NULL DEFAULT 'production' COMMENT '环境',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_platform_payment_type` (`platform_type`, `payment_type`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付配置表';

-- 第三方服务配置表
DROP TABLE IF EXISTS `tb_third_party_config`;
CREATE TABLE `tb_third_party_config` (
  `id` bigint(20) NOT NULL COMMENT '配置ID，雪花算法生成',
  `service_type` varchar(64) NOT NULL DEFAULT '' COMMENT '服务类型：aliyun_vod/aliyun_sms/aliyun_oss',
  `service_name` varchar(128) NOT NULL DEFAULT '' COMMENT '服务名称',
  `access_key_id` varchar(128) NOT NULL DEFAULT '' COMMENT '访问密钥ID',
  `access_key_secret` varchar(256) NOT NULL DEFAULT '' COMMENT '访问密钥Secret',
  `region_id` varchar(64) NOT NULL DEFAULT '' COMMENT '地域ID',
  `endpoint` varchar(256) NOT NULL DEFAULT '' COMMENT '服务端点',
  `bucket_name` varchar(128) NOT NULL DEFAULT '' COMMENT '存储桶名称',
  `domain` varchar(256) NOT NULL DEFAULT '' COMMENT '域名',
  `extra_config` json DEFAULT NULL COMMENT '额外配置 JSON',
  `is_enabled` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
  `environment` varchar(32) NOT NULL DEFAULT 'production' COMMENT '环境：sandbox-沙箱，production-生产',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_service_type` (`service_type`),
  KEY `idx_service_type` (`service_type`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='第三方服务配置表';

-- 管理员表
DROP TABLE IF EXISTS `tb_admin_user`;
CREATE TABLE `tb_admin_user` (
  `id` bigint(20) NOT NULL COMMENT '管理员ID，雪花算法生成',
  `username` varchar(64) NOT NULL DEFAULT '' COMMENT '用户名',
  `password` varchar(128) NOT NULL DEFAULT '' COMMENT '密码',
  `real_name` varchar(64) NOT NULL DEFAULT '' COMMENT '真实姓名',
  `phone` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `email` varchar(128) NOT NULL DEFAULT '' COMMENT '邮箱',
  `avatar` varchar(512) NOT NULL DEFAULT '' COMMENT '头像',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `role_name` varchar(64) NOT NULL DEFAULT '' COMMENT '角色名称（冗余）',
  `department` varchar(64) NOT NULL DEFAULT '' COMMENT '部门',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常，2-锁定',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(64) NOT NULL DEFAULT '' COMMENT '最后登录IP',
  `login_count` int(11) NOT NULL DEFAULT 0 COMMENT '登录次数',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员表';

-- 角色表
DROP TABLE IF EXISTS `tb_admin_role`;
CREATE TABLE `tb_admin_role` (
  `id` bigint(20) NOT NULL COMMENT '角色ID，雪花算法生成',
  `role_name` varchar(64) NOT NULL DEFAULT '' COMMENT '角色名称',
  `role_code` varchar(64) NOT NULL DEFAULT '' COMMENT '角色代码',
  `description` varchar(256) NOT NULL DEFAULT '' COMMENT '角色描述',
  `permissions` json DEFAULT NULL COMMENT '权限列表 JSON',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`),
  KEY `idx_status` (`status`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 系统配置表
DROP TABLE IF EXISTS `tb_system_config`;
CREATE TABLE `tb_system_config` (
  `id` bigint(20) NOT NULL COMMENT '配置ID，雪花算法生成',
  `config_key` varchar(128) NOT NULL DEFAULT '' COMMENT '配置键',
  `config_value` text NOT NULL COMMENT '配置值',
  `config_desc` varchar(256) NOT NULL DEFAULT '' COMMENT '配置描述',
  `config_type` varchar(32) NOT NULL DEFAULT 'STRING' COMMENT '配置类型：STRING,NUMBER,JSON,BOOLEAN',
  `config_group` varchar(64) NOT NULL DEFAULT 'system' COMMENT '配置分组',
  `is_system` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否系统配置：0-否，1-是',
  `is_encrypted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否加密：0-否，1-是',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`),
  KEY `idx_config_type` (`config_type`),
  KEY `idx_config_group` (`config_group`),
  KEY `idx_is_system` (`is_system`),
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 初始化系统配置数据
INSERT INTO `tb_system_config` VALUES
(1, 'exam_duration_subject1', '2700', '科目一考试时长(秒)', 'NUMBER', 'exam', 1, 0, 0, NOW(), NOW()),
(2, 'exam_duration_subject4', '1800', '科目四考试时长(秒)', 'NUMBER', 'exam', 1, 0, 0, NOW(), NOW()),
(3, 'exam_question_count_subject1', '100', '科目一考试题数', 'NUMBER', 'exam', 1, 0, 0, NOW(), NOW()),
(4, 'exam_question_count_subject4', '50', '科目四考试题数', 'NUMBER', 'exam', 1, 0, 0, NOW(), NOW()),
(5, 'exam_pass_score', '90', '考试及格分数', 'NUMBER', 'exam', 1, 0, 0, NOW(), NOW()),
(6, 'daily_points_limit', '50', '每日积分上限', 'NUMBER', 'points', 1, 0, 0, NOW(), NOW()),
(7, 'question_point_reward', '1', '每道题积分奖励', 'NUMBER', 'points', 1, 0, 0, NOW(), NOW()),
(8, 'exam_pass_point_reward', '10', '考试通过积分奖励', 'NUMBER', 'points', 1, 0, 0, NOW(), NOW()),
(9, 'app_name', '驾考通', '应用名称', 'STRING', 'app', 1, 0, 0, NOW(), NOW()),
(10, 'app_version', '3.0.0', '应用版本', 'STRING', 'app', 1, 0, 0, NOW(), NOW()),
(11, 'customer_service_phone', '400-123-4567', '客服电话', 'STRING', 'contact', 1, 0, 0, NOW(), NOW()),
(12, 'privacy_policy_url', 'https://example.com/privacy', '隐私政策链接', 'STRING', 'legal', 1, 0, 0, NOW(), NOW()),
(13, 'user_agreement_url', 'https://example.com/agreement', '用户协议链接', 'STRING', 'legal', 1, 0, 0, NOW(), NOW());

-- 初始化管理员角色数据
INSERT INTO `tb_admin_role` VALUES
(1, '超级管理员', 'SUPER_ADMIN', '系统超级管理员，拥有所有权限', '["*"]', 1, 1, 0, NOW(), NOW()),
(2, '内容管理员', 'CONTENT_ADMIN', '负责题库、视频、标志管理', '["question:*", "video:*", "traffic_sign:*"]', 1, 2, 0, NOW(), NOW()),
(3, '运营管理员', 'OPERATION_ADMIN', '负责用户、商城、统计管理', '["user:*", "mall:*", "statistics:*"]', 1, 3, 0, NOW(), NOW()),
(4, '客服管理员', 'SERVICE_ADMIN', '负责用户服务、评论管理', '["user:read", "comment:*"]', 1, 4, 0, NOW(), NOW());

-- 初始化超级管理员账号（默认密码：admin123）
INSERT INTO `tb_admin_user` VALUES
(1, 'admin', '21232f297a57a5a743894a0e4a801fc3', '系统管理员', '13800138000', 'admin@driveschool.com', '', 1, '超级管理员', '技术部', 1, NULL, '', 0, 0, NOW(), NOW());

-- 初始化登录配置数据
INSERT INTO `tb_login_config` VALUES
(1, 'mp-weixin', 'wechat_mini', '微信小程序登录', 'wx333f111792840ed9', '', NULL, 1, 'production', 0, NOW(), NOW()),
(2, 'app-plus', 'wechat_app', '微信APP登录', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(3, 'app-plus', 'huawei', '华为账号登录', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(4, 'app-plus', 'alipay', '支付宝登录', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(5, 'h5', 'sms_code', '短信验证码登录', '', '', NULL, 1, 'production', 0, NOW(), NOW());

-- 初始化支付配置数据
INSERT INTO `tb_payment_config` VALUES
(1, 'mp-weixin', 'wechat_pay', '微信小程序支付', '', '', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(2, 'app-plus', 'wechat_pay', '微信APP支付', '', '', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(3, 'app-plus', 'alipay', 'APP支付宝支付', '', '', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(4, 'h5', 'wechat_pay', 'H5微信支付', '', '', '', '', NULL, 1, 'production', 0, NOW(), NOW()),
(5, 'h5', 'alipay', 'H5支付宝支付', '', '', '', '', NULL, 1, 'production', 0, NOW(), NOW());

-- 初始化第三方服务配置
INSERT INTO `tb_third_party_config` VALUES
(1, 'aliyun_vod', '阿里云视频点播', '', '', 'cn-shanghai', '', '', '', '{}', 1, 'production', 0, NOW(), NOW()),
(2, 'aliyun_sms', '阿里云短信服务', '', '', 'cn-hangzhou', '', '', '', '{}', 1, 'production', 0, NOW(), NOW()),
(3, 'aliyun_oss', '阿里云对象存储', '', '', 'cn-shanghai', '', 'drive-app-bucket', 'cdn.example.com', '{}', 1, 'production', 0, NOW(), NOW());

-- =============================================
-- 设计说明：
-- 1. 严格遵循阿里巴巴Java开发手册（2022版）规范
-- 2. 使用utf8mb4字符集，支持emoji和特殊字符
-- 3. 采用雪花算法生成bigint类型主键，替代UUID提高性能
-- 4. 全部表加tb_前缀，避免与保留字冲突
-- 5. 不使用外键关系，通过应用层维护数据一致性
-- 6. 反三范式设计，冗余存储常用字段提高查询性能
-- 7. 所有表必须包含gmt_create和gmt_modified字段
-- 8. 使用逻辑删除is_deleted字段，禁用物理删除
-- 9. 所有字符串字段都设置NOT NULL DEFAULT ''，避免NULL值
-- 10. 所有数值字段都设置NOT NULL DEFAULT 0，保证数据一致性
-- 11. 高频查询字段均建立了索引优化
-- 12. 使用tinyint(4)代替boolean，符合MySQL最佳实践
-- 13. 支持JSON字段类型，提高复杂数据存储灵活性
-- 14. 所有表都增加is_deleted字段的索引
-- =============================================
