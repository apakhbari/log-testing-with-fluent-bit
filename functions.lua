function add_identifier(tag, timestamp, record)
    -- Expecting tag format: docker.container_name
    -- We split the tag to get the container name
    local container_name = "unknown"
    
    -- The tag comes in as "docker.my-app". We want "my-app"
    local p1, p2 = tag:match("([^.]+).([^.]+)")
    if p2 then
        container_name = p2
    end

    -- Create the custom field: "ubuntu_server_01:container_name"
    -- You can change "ubuntu_prod" to whatever your server name is
    record["dividing_name"] = "ubuntu_prod:" .. container_name
    
    -- Ensure the 'log' key exists for GELF (Docker forward usually sends 'log' or 'message')
    if record["log"] == nil and record["message"] ~= nil then
        record["log"] = record["message"]
    end

    return 1, timestamp, record
end