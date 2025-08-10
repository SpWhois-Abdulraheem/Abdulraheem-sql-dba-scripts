SELECT 
    User, 
    Host, 
    plugin, 
    account_locked,
    IF(account_locked = 'N' AND plugin NOT IN ('', 'auth_socket'), 'Active', 'Inactive') AS status
FROM 
    mysql.user
WHERE 
    User NOT IN ('mysql.sys', 'mysql.session')   -- Exclude system users
    AND User != ''                               -- Exclude anonymous users
    AND (plugin IS NOT NULL AND plugin != '')    -- Must have a plugin
ORDER BY 
    status DESC, User;
