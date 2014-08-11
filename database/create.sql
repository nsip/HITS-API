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

-- SIS - Student Information System
CREATE TABLE IF NOT EXISTS sis (
	id VARCHAR(100) UNIQUE,
	ѕis_type VARCHAR(25),		-- e.g. hits_db
	sis_ref VARCHAR(200)		-- e.g. X, sis_X
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- APPLICATINOS AND REQUESTED PERMISSIONS
--	One application per connection
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
	perm_template VARCHAR(50),	-- Permissions template...
	sis_id VARCHAR(100),		-- Which SIS does this app use
	FOREIGN KEY (vendor_id) REFERENCES vendor(id),
	FOREIGN KEY (sis_id) REFERENCES sis(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS app_permissions (
	app_id varchar(36) UNIQUE,
	perm varchar(100),
	FOREIGN KEY (app_id) REFERENCES app(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- DEPRECATED - Now part of the SIS
-- CREATE TABLE IF NOT EXISTS school (
-- 	id VARCHAR(36) UNIQUE,
-- 	name VARCHAR(50)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS app_login (
	id VARCHAR(36),			-- ? Local ID for convenience
	app_id VARCHAR(36),		-- Which app, therefore vendor and SIS

	-- token VARCHAR(100),		-- A token for direct access

	-- DATABASE = hits_sif3_infra
	app_template_id int(11),	-- Link to hits_sif3_infra.SIF3_APP_TEMPLATE.APP_TEMPLATE_ID
	-- SIF required data
	--		SoultionID			-- Use app_template_id above
	--		ApplicationKey		-- Use app_template_id above
	--		UserToken			-- Use app_template_id above
	--		Password			-- Use app_template_id above
	--		ZoneId				-- User Token from template above
	--		School Zones		-- Internal

	FOREIGN KEY (app_id) REFERENCES app(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

