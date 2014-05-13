CREATE TABLE IF NOT EXISTS login (
	id VARCHAR(36) UNIQUE,
	drupal_id VARCHAR(100) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- VENDOR
CREATE TABLE IF NOT EXISTS vendor (
	id VARCHAR(36) UNIQUE,
	name VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS vendor_info (
	vendor_id VARCHAR(36),
	field VARCHAR(100),
	value TEXT,
	FOREIGN KEY (vendor_id) REFERENCES vendor(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- APPLICATINOS AND REQUESTED PERMISSIONS
CREATE TABLE IF NOT EXISTS app (
	id VARCHAR(36) UNIQUE,
	vendor_id VARCHAR(36),
	name VARCHAR(50),
	title VARCHAR(250),
	description VARCHAR(2000),
	site_url VARCHAR(200),
	about TEXT,
	tags VARCHAR(2000),
	icon_url VARCHAR(200),
	pub VARCHAR(1),
	FOREIGN KEY (vendor_id) REFERENCES vendor(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS app_permissions (
	app_id varchar(36) UNIQUE,
	perm varchar(100),
	FOREIGN KEY (app_id) REFERENCES app(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- SCHOOL ASSIGNMENT
CREATE TABLE IF NOT EXISTS school (
	id VARCHAR(36) UNIQUE,
	name VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS school_app (
	school_id VARCHAR(36),
	app_id VARCHAR(36),
	token VARCHAR(100),		-- A token for direct access
	FOREIGN KEY (school_id) REFERENCES school(id),
	FOREIGN KEY (app_id) REFERENCES app(id) -- ,
	-- UNIQUE INDEX 'school_app' (school_id, app_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- CREATE TABLE IF NOT EXISTS token (
-- 	token VARCHAR(100),
-- 	-- expiry	-- Expire a token
-- 	-- restrictions	-- Other restrictions, like IP, applications etc
-- 	what VARCHAR(100),	-- What access, e.g. school_app ?
-- 	
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- SIF / API Identification

