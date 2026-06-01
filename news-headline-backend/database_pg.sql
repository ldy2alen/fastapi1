-- 新闻资讯应用数据库设计 (PostgreSQL 版本)

-- 用户表
CREATE TABLE IF NOT EXISTS "user" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(50) NOT NULL UNIQUE,
  "password" VARCHAR(255) NOT NULL,
  "nickname" VARCHAR(50) DEFAULT NULL,
  "avatar" VARCHAR(255) DEFAULT NULL,
  "gender" VARCHAR(10) DEFAULT 'unknown' CHECK ("gender" IN ('male', 'female', 'unknown')),
  "bio" VARCHAR(500) DEFAULT NULL,
  "phone" VARCHAR(20) DEFAULT NULL UNIQUE,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "user" IS '用户信息表';
COMMENT ON COLUMN "user"."id" IS '用户ID';
COMMENT ON COLUMN "user"."username" IS '用户名';
COMMENT ON COLUMN "user"."password" IS '密码（加密存储）';
COMMENT ON COLUMN "user"."nickname" IS '昵称';
COMMENT ON COLUMN "user"."avatar" IS '头像URL';
COMMENT ON COLUMN "user"."gender" IS '性别';
COMMENT ON COLUMN "user"."bio" IS '个人简介';
COMMENT ON COLUMN "user"."phone" IS '手机号';
COMMENT ON COLUMN "user"."created_at" IS '创建时间';
COMMENT ON COLUMN "user"."updated_at" IS '更新时间';

-- 用户令牌表
CREATE TABLE IF NOT EXISTS "user_token" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER NOT NULL REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "token" VARCHAR(255) NOT NULL UNIQUE,
  "expires_at" TIMESTAMP NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "user_token" IS '用户令牌表';

-- 新闻分类表
CREATE TABLE IF NOT EXISTS "news_category" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(50) NOT NULL UNIQUE,
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "news_category" IS '新闻分类表';

-- 新闻表
CREATE TABLE IF NOT EXISTS "news" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(255) NOT NULL,
  "description" VARCHAR(500) DEFAULT NULL,
  "content" TEXT NOT NULL,
  "image" VARCHAR(255) DEFAULT NULL,
  "author" VARCHAR(50) DEFAULT NULL,
  "category_id" INTEGER NOT NULL REFERENCES "news_category"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  "views" INTEGER NOT NULL DEFAULT 0,
  "publish_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "news" IS '新闻表';
CREATE INDEX IF NOT EXISTS "idx_news_category" ON "news"("category_id");
CREATE INDEX IF NOT EXISTS "idx_news_publish_time" ON "news"("publish_time" DESC);

-- 相关新闻关联表
CREATE TABLE IF NOT EXISTS "related_news" (
  "id" SERIAL PRIMARY KEY,
  "news_id" INTEGER NOT NULL REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "related_news_id" INTEGER NOT NULL REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE ("news_id", "related_news_id")
);
COMMENT ON TABLE "related_news" IS '相关新闻关联表';

-- 收藏表
CREATE TABLE IF NOT EXISTS "favorite" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER NOT NULL REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "news_id" INTEGER NOT NULL REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE ("user_id", "news_id")
);
COMMENT ON TABLE "favorite" IS '收藏表';

-- 浏览历史表
CREATE TABLE IF NOT EXISTS "history" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER NOT NULL REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "news_id" INTEGER NOT NULL REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "view_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "history" IS '浏览历史表';
CREATE INDEX IF NOT EXISTS "idx_history_view_time" ON "history"("view_time" DESC);

-- AI聊天记录表
CREATE TABLE IF NOT EXISTS "ai_chat" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER NOT NULL REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "message" TEXT NOT NULL,
  "response" TEXT NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE "ai_chat" IS 'AI聊天记录表';
CREATE INDEX IF NOT EXISTS "idx_ai_chat_created_at" ON "ai_chat"("created_at" DESC);

-- 初始化数据
-- 插入默认新闻分类
INSERT INTO "news_category" ("name", "sort_order") VALUES
('头条', 1),
('社会', 2),
('国内', 3),
('国际', 4),
('娱乐', 5),
('体育', 6),
('科技', 7),
('财经', 8);

-- 插入默认新闻 (category_id=1 头条)
INSERT INTO "news" ("title", "description", "content", "image", "author", "category_id", "views", "publish_time") VALUES
('国家主席发表2024年新年贺词', '主席总结过去一年成就，展望未来发展蓝图，强调高质量发展。', '2023年12月31日晚，国家主席通过中央广播电视总台和互联网发表新年贺词。他回顾了2023年在经济建设、科技创新、疫情防控等方面取得的成就，并指出2024年要坚持稳中求进，全面深化改革开放，推动高质量发展，增进民生福祉。贺词在全国各地干部群众中引发热烈反响，大家表示要齐心协力共创美好未来。', 'https://picsum.photos/id/100/200/200', '新华社', 1, 12500, '2024-01-01 08:00:00'),
('全国两会将于3月初在京召开', '十四届全国人大二次会议和全国政协十四届二次会议议程公布。', '据悉，第十四届全国人民代表大会第二次会议和全国政协第十四届二次会议将分别于2024年3月5日和3月4日在北京开幕。本次两会将审议政府工作报告、计划报告、预算报告以及国务院机构改革方案等多项重要文件，各界高度关注经济发展目标与民生政策新动向。', 'https://picsum.photos/id/101/200/200', '人民日报', 1, 8900, '2024-01-05 09:30:00'),
('我国成功发射通信技术试验卫星十一号', '卫星顺利进入预定轨道，将用于开展多频段、高速率通信试验。', '2024年1月10日15时03分，我国在西昌卫星发射中心使用长征二号丁运载火箭，成功将通信技术试验卫星十一号发射升空。该卫星主要用于开展Ka频段宽带通信、新型天线展开等关键技术验证，可为下一代通信技术积累数据。此次任务是长征系列火箭的第456次飞行。', 'https://picsum.photos/id/102/200/200', '央视新闻', 1, 11200, '2024-01-10 18:20:00'),
('2023年我国GDP同比增长5.2%', '经济总量超126万亿元，国民经济回升向好，高质量发展扎实推进。', '国家统计局公布数据显示，2023年我国国内生产总值（GDP）达到1260582亿元，按不变价格计算同比增长5.2%。分季度看，一季度增长4.5%，二季度增长6.3%，三季度增长4.9%，四季度增长5.2%。全年社会消费品零售总额实现增长，高技术产业投资较快增长，就业形势总体稳定。', 'https://picsum.photos/id/103/200/200', '经济日报', 1, 15300, '2024-01-17 10:00:00'),
('央行宣布降准0.5个百分点', '释放长期资金约1万亿元，保持流动性合理充裕，支持实体经济。', '中国人民银行决定于2024年1月25日下调金融机构存款准备金率0.5个百分点（不含已执行5%存款准备金率的金融机构）。本次下调后，金融机构加权平均存款准备金率约为7.0%。此次降准旨在巩固经济回升向好基础，优化金融机构资金结构，更好支持科技创新、小微企业等重点领域。', 'https://picsum.photos/id/104/200/200', '财经网', 1, 14200, '2024-01-20 16:45:00'),
('C919国产大飞机开启东南亚演示飞行', '首次飞抵新加坡航展，展示我国民用航空工业新成就。', '我国自主研发的C919大型客机于2024年2月18日飞抵新加坡，将参加2024年新加坡航展并进行静态展示和演示飞行。这是C919飞机首次在海外航展进行飞行表演，标志着国产大飞机迈出"走出去"的重要一步。航展期间，C919还将面向潜在客户进行推介活动。', 'https://picsum.photos/id/105/200/200', '新华每日电讯', 1, 9800, '2024-02-18 12:15:00'),
('春节假期国内旅游出游4.74亿人次', '按可比口径较2019年同期增长19.0%，旅游收入6326.87亿元。', '经文化和旅游部数据中心测算，2024年春节假期8天，全国国内旅游出游4.74亿人次，同比增长34.3%，按可比口径较2019年同期增长19.0%；实现国内旅游收入6326.87亿元，同比增长47.3%，较2019年同期增长7.7%。南北互跨旅游热潮涌动，文旅市场活力十足。', 'https://picsum.photos/id/106/200/200', '中国旅游报', 1, 13400, '2024-02-25 14:30:00'),
('我国科学家在量子计算领域取得新突破', '成功研制"九章三号"光量子计算原型机，处理特定问题速度大幅提升。', '中国科学技术大学潘建伟、陆朝阳等组成的研究团队与中国科学院上海微系统所、国家并行计算机工程技术研究中心合作，成功构建了255个光子的量子计算原型机"九章三号"。在求解高斯玻色取样数学问题时，其处理速度比目前全球最快的超级计算机快一亿亿倍，复杂度提升百万倍。', 'https://picsum.photos/id/107/200/200', '科技日报', 1, 10800, '2024-03-01 11:20:00'),
('2024年春运圆满结束', '全社会跨区域人员流动量预计累计超84亿人次，创历史新高。', '2024年春运于3月5日结束，为期40天。据交通运输部数据，全社会跨区域人员流动量预计累计达到84.2亿人次，同比增长9.8%，较2019年同期增长7.1%。铁路、公路、水路、民航运输安全平稳有序，其中铁路发送旅客4.8亿人次，民航发送旅客0.83亿人次，均创历史新高。', 'https://picsum.photos/id/108/200/200', '人民铁道报', 1, 7600, '2024-03-05 17:00:00'),
('"十四五"规划实施中期评估报告发布', '主要指标进展符合预期，重大工程项目扎实推进，发展质量提升。', '国家发改委发布《"十四五"规划实施中期评估报告》。报告显示，20项主要指标中16项基本符合或快于预期，粮食能源安全、科技创新、民生保障等领域成效显著。下一步将针对薄弱环节精准发力，推动规划任务全面落实，为全面建设社会主义现代化国家开好局起好步。', 'https://picsum.photos/id/109/200/200', '光明日报', 1, 6900, '2024-03-10 15:50:00');

-- 创建测试用户
INSERT INTO "user" ("username", "password", "nickname", "gender", "bio") VALUES
('admin', '$2b$12$TKevPbXcGL6Q1WdaFKbLhuueBuLfLyhkdk/0ESBvBv7X74.rNwiNm', '测试用户', 'unknown', '这是一个测试账号');
