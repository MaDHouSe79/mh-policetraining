CREATE TABLE IF NOT EXISTS `police_training` (
    `id` int(10) NOT NULL AUTO_INCREMENT,
    `license` varchar(255) NOT NULL,
    `username` varchar(255) NOT NULL,
    `arrested` int(11) DEFAULT 0,
    `escaped` int(11) DEFAULT 0,
    `failed` int(11) DEFAULT 0,
    `deads` int(11) DEFAULT 0,
    `earned` int(11) DEFAULT 0,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;