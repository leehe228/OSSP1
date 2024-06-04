CREATE TABLE `predictions` (
                               `prediction_id`	bigint	NOT NULL auto_increment primary key ,
                               `object_class`	varchar(255)	NULL,
                               `cavity_probability`	double	NULL,
                               `x1`	int	NULL,
                               `y1`	int	NULL,
                               `x2`	int	NULL,
                               `y2`	int	NULL,
                               `status`	varchar(255)	NOT NULL	DEFAULT 'on_progress',
                               `created_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP,
                               `modified_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               `query_id`	bigint	NOT NULL
);

CREATE TABLE `querys` (
                          `query_id`	bigint	NOT NULL	 auto_increment primary key ,
                          `device_token`	varchar(255)	NOT NULL,
                          `request_id`	bigint	NOT NULL,
                          `result_url`	varchar(1000)	NULL,
                          `image_url`	varchar(1000)	NULL,
                          `status`	varchar(255)	NOT NULL	DEFAULT 'on_progress',
                          `created_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP,
                          `modified_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE `predictions` ADD CONSTRAINT FOREIGN KEY(query_id) REFERENCES querys(query_id);

# CREATE TABLE `predictions` (
#                                `prediction_id`	bigint	NOT NULL auto_increment primary key ,
#                                `device_token`	varchar(255)	NOT NULL,
#                                `request_id`	bigint	NOT NULL,
#                                `image_url`	varchar(1000)	NOT NULL,
#                                `result_url`	varchar(1000)	NULL,
#                                `object_class`	varchar(255)	NULL,
#                                `cavity_probability`	double	NULL,
#                                `status`	varchar(255)	NOT NULL	DEFAULT 'on_progress',
#                                `created_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP,
#                                `modified_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
# );
#
# CREATE TABLE `bbox_points` (
#                                `bbox_point_id`	bigint	NOT NULL auto_increment primary key ,
#                                `x`	int	NOT NULL,
#                                `y`	int	NOT NULL,
#                                `status`	varchar(255)	NULL	DEFAULT 'on_progress',
#                                `created_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP,
#                                `modified_at`	timestamp	NOT NULL	DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#                                `prediction_id`	bigint	NOT NULL
# );
#
# ALTER TABLE `bbox_points` ADD CONSTRAINT FOREIGN KEY(prediction_id) REFERENCES predictions(prediction_id);