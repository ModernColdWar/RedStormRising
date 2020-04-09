function upgrade(db)
    db:exec [[
    CREATE TABLE chat(
      timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ucid TEXT NOT NULL,
      name TEXT NOT NULL,
      to_all BOOLEAN NOT NULL,
      message TEXT NOT NULL,
      PRIMARY KEY(timestamp, ucid)
    )
]]
end

function downgrade(db)
    db:exec [[
    DROP TABLE chat
]]
end
