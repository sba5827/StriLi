local sFile = nil;

local bInsideFunction = false;

local function vReset()
    bInsideFunction = false;
end

function sParsFile(sFile)
    assert(sFile ~= nil, "File to pars was not set");
    assert(type(sFile) == "string", "Expected File to be a string.");

    vReset();

    local sTempFileContend = sFile;
    local sTempNewFileContend = "";

    local nStart, nEnd, sMatch = string.find(sTempFileContend, "[%s;]*([^%s^;]+)[%s;]");
    print(nStart, nEnd, sMatch);

    while sMatch do

        sTempFileContend = sTempFileContend:sub(nEnd+1);

        nStart, nEnd, sMatch = string.find(sTempFileContend, "[%s;]*([^%s^;]+)[%s;]");
        print(nStart, nEnd, sMatch);

    end

end