require "lfs"

local path = {}

----------------------------------------------------------------------------------
--It will return a table that contents all the file paths in the rootpath
path.listdir = function (rootpath, pathes)
    pathes = pathes or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. '/' .. entry
            local attr = lfs.attributes(path)
            assert(type(attr) == 'table')
            if attr.mode ~= 'directory' then
                table.insert(pathes, path)
            end
        end
    end
    return pathes
end



return path
