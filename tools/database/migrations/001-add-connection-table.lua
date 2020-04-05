function upgrade(db)
    db:exec [[
    CREATE TABLE connection(
      timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ucid TEXT NOT NULL,
      name TEXT NOT NULL,
      ipaddr TEXT NOT NULL,
      PRIMARY KEY(timestamp, ucid)
    )
]]
end

function downgrade(db)
    db:exec [[
    DROP TABLE connection
]]
end
