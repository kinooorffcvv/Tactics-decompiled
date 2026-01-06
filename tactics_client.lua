(function(...)
    if localPlayer == nil then
        local tacticsElement = createElement("Tactics", "Tactics");
        setElementData(tacticsElement, "version", "1.2 r20");
        do
            local dataElementTactics = tacticsElement;
            getAllTacticsData = function()
                return getElementData(dataElementTactics, "AllData") or {};
            end;
            getTacticsData = function(...)
                local div = true;
                local tableData = {...};
                if type(tableData[#tableData]) == "boolean" then
                    div = table.remove(tableData);
                end;
                if #tableData == 1 then
                    local dataTctTable = getElementData(dataElementTactics, tableData[1]);
                    if div and type(dataTctTable) == "string" and string.find(dataTctTable, "|") then
                        return gettok(dataTctTable, 1, string.byte("|")), split(gettok(dataTctTable, 2, string.byte("|")), ",");
                    else
                        return dataTctTable;
                    end;
                elseif #tableData > 1 then
                    local isDataTct = nil;
                    for i, j in ipairs(tableData) do
                        if i == 1 then
                            isDataTct = getElementData(dataElementTactics, j);
                        else
                            isDataTct = isDataTct[j];
                        end;
                        if not isDataTct then
                            return nil;
                        end;
                    end;
                    if div and type(isDataTct) == "string" and string.find(isDataTct, "|") then
                        return gettok(isDataTct, 1, string.byte("|")), split(gettok(isDataTct, 2, string.byte("|")), ",");
                    else
                        return isDataTct;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(param)
                if type(param) == "string" then
                    if string.find(param, "|") then
                        return "parameter";
                    elseif string.find(param, ":") then
                        return "time";
                    elseif param == "true" or param == "false" then
                        return "toggle";
                    end;
                end;
                return type(param);
            end;
            setTacticsData = function(tblTCT, ...)
                local bool = false;
                local tableTactics = {...};
                if type(tableTactics[#tableTactics]) == "boolean" then
                    bool = table.remove(tableTactics);
                end;
                local rcv1 = nil;
                local rcv2 = {};
                if #tableTactics > 1 then
                    rcv2[1] = getElementData(dataElementTactics, tableTactics[1]);
                    if type(rcv2[1]) ~= "table" then
                        rcv2[1] = {};
                    end;
                    for rcv3 = 2, #tableTactics - 1 do
                        rcv2[rcv3] = type(rcv2[rcv3 - 1][tableTactics[rcv3]]) == "table" and rcv2[rcv3 - 1][tableTactics[rcv3]] or {};
                    end;
                    if type(tblTCT) == "table" or rcv2[#tableTactics - 1][tableTactics[#tableTactics]] ~= tblTCT then
                        rcv1 = rcv2[#tableTactics - 1][tableTactics[#tableTactics]];
                        if bool and getDataType(rcv1) == "parameter" then
                            rcv2[#tableTactics - 1][tableTactics[#tableTactics]] = tostring(tblTCT) .. string.sub(rcv1, string.find(rcv1, "|"), -1);
                        elseif type(tblTCT) == "string" then
                            rcv2[#tableTactics - 1][tableTactics[#tableTactics]] = tostring(tblTCT);
                        else
                            rcv2[#tableTactics - 1][tableTactics[#tableTactics]] = tblTCT;
                        end;
                        for serverTableIndex = #tableTactics - 1, 2, -1 do
                            rcv2[serverTableIndex - 1][tableTactics[serverTableIndex]] = rcv2[serverTableIndex];
                        end;
                    else
                        return false;
                    end;
                elseif #tableTactics == 1 then
                    if type(tblTCT) == "table" or getElementData(dataElementTactics, tableTactics[1]) ~= tblTCT then
                        rcv1 = getElementData(dataElementTactics, tableTactics[1]);
                        if bool and getDataType(rcv1) == "parameter" then
                            rcv2[1] = tostring(tblTCT) .. string.sub(rcv1, string.find(rcv1, "|"), -1);
                        elseif type(tblTCT) == "string" then
                            rcv2[1] = tostring(tblTCT);
                        else
                            rcv2[1] = tblTCT;
                        end;
                    else
                        return false;
                    end;
                else
                    return false;
                end;
                setElementData(dataElementTactics, tableTactics[1], rcv2[1]);
                triggerEvent("onTacticsChange", root, tableTactics, rcv1);
                return true;
            end;
            addEvent("onTacticsChange");
            addEvent("onSetTacticsData", true);
            addEventHandler("onSetTacticsData", root, function(serverValueToSet, ...)
                setTacticsData(serverValueToSet, ...);
            end);
        end;
    else
        local serverClientTacticsElement = getElementByID("Tactics");
        do
            local serverClientRef = serverClientTacticsElement;
            initTacticsData = function()
                local serverCurrentPath = {};
                local function serverCompareTables(serverNewTable, serverOldTable, serverDepth)
                    for serverNewKey, serverNewVal in pairs(serverNewTable) do
                        serverCurrentPath[serverDepth] = serverNewKey;
                        if type(serverNewVal) == "table" and #serverNewVal == 0 and type(next(serverNewVal)) == "string" then
                            serverCompareTables(serverNewVal, serverOldTable[serverNewKey] or {}, serverDepth + 1);
                            serverCurrentPath[serverDepth + 1] = nil;
                        elseif type(serverOldTable[serverNewKey]) == "table" or serverNewVal ~= serverOldTable[serverNewKey] then
                            triggerEvent("onClientTacticsChange", serverClientRef, serverCurrentPath, serverOldTable[serverNewKey]);
                        end;
                        serverOldTable[serverNewKey] = nil;
                    end;
                    for serverOldKey, serverOldVal in pairs(serverOldTable) do
                        serverCurrentPath[serverDepth] = serverOldKey;
                        if type(serverNewTable[serverOldKey]) == "table" and #serverNewTable[serverOldKey] == 0 and type(next(serverNewTable[serverOldKey])) == "string" then
                            serverCompareTables(serverNewTable[serverOldKey], serverOldVal or {}, serverDepth + 1);
                            serverCurrentPath[serverDepth + 1] = nil;
                        elseif type(serverOldVal) == "table" or serverNewTable[serverOldKey] ~= serverOldVal then
                            triggerEvent("onClientTacticsChange", serverClientRef, serverCurrentPath, serverOldVal);
                        end;
                    end;
                end;
                for __, serverElementName in ipairs(getAllTacticsData()) do
                    local serverElementData = getElementData(serverClientRef, serverElementName);
                    serverCurrentPath[1] = serverElementName;
                    if type(serverElementData) == "table" and #serverElementData == 0 and type(next(serverElementData)) == "string" then
                        serverCompareTables(serverElementData, {}, 2);
                        serverCurrentPath[2] = nil;
                    else
                        triggerEvent("onClientTacticsChange", serverClientRef, serverCurrentPath, nil);
                    end;
                end;
            end;
            addEvent("onDownloadComplete");
            addEventHandler("onDownloadComplete", root, initTacticsData);
            local function serverOnElementDataChange(serverChangedKey, serverOldData) 
                local serverPathBuilder = {};
                local function serverCompareTablesRecursive(serverNewTableRecursive, serverOldTableRecursive, serverRecursiveDepth) 
                    for serverNewKeyRecursive, serverNewValRecursive in pairs(serverNewTableRecursive) do
                        serverPathBuilder[serverRecursiveDepth] = serverNewKeyRecursive;
                        if type(serverNewValRecursive) == "table" and #serverNewValRecursive == 0 and type(next(serverNewValRecursive)) == "string" then
                            serverCompareTablesRecursive(serverNewValRecursive, serverOldTableRecursive[serverNewKeyRecursive] or {}, serverRecursiveDepth + 1);
                            serverPathBuilder[serverRecursiveDepth + 1] = nil;
                        elseif type(serverOldTableRecursive[serverNewKeyRecursive]) == "table" or serverNewValRecursive ~= serverOldTableRecursive[serverNewKeyRecursive] then
                            triggerEvent("onClientTacticsChange", source, serverPathBuilder, serverOldTableRecursive[serverNewKeyRecursive]);
                        end;
                        serverOldTableRecursive[serverNewKeyRecursive] = nil;
                    end;
                    for serverOldKeyRecursive, serverOldValRecursive in pairs(serverOldTableRecursive) do
                        serverPathBuilder[serverRecursiveDepth] = serverOldKeyRecursive;
                        if type(serverNewTableRecursive[serverOldKeyRecursive]) == "table" and #serverNewTableRecursive[serverOldKeyRecursive] == 0 and type(next(serverNewTableRecursive[serverOldKeyRecursive])) == "string" then
                            serverCompareTablesRecursive(serverNewTableRecursive[serverOldKeyRecursive], serverOldValRecursive or {}, serverRecursiveDepth + 1);
                            serverPathBuilder[serverRecursiveDepth + 1] = nil;
                        elseif type(serverOldValRecursive) == "table" or serverNewTableRecursive[serverOldKeyRecursive] ~= serverOldValRecursive then
                            triggerEvent("onClientTacticsChange", source, serverPathBuilder, serverOldValRecursive);
                        end;
                    end;
                end;
                local serverChangedData = getElementData(source, serverChangedKey);
                serverPathBuilder[1] = serverChangedKey;
                if type(serverChangedData) == "table" and #serverChangedData == 0 and type(next(serverChangedData)) == "string" then
                    serverCompareTablesRecursive(serverChangedData, serverOldData or {}, 2);
                    serverPathBuilder[2] = nil;
                else
                    triggerEvent("onClientTacticsChange", source, serverPathBuilder, serverOldData);
                end;
            end;
            addEvent("onClientTacticsChange");
            addEventHandler("onClientElementDataChange", serverClientRef, serverOnElementDataChange);
            getAllTacticsData = function() 
                return getElementData(serverClientRef, "AllData") or {};
            end;
            getTacticsData = function(...) 
                local serverShouldParse = true;
                local serverArgsArray = {...};
                if type(serverArgsArray[#serverArgsArray]) == "boolean" then
                    serverShouldParse = table.remove(serverArgsArray);
                end;
                if #serverArgsArray == 1 then
                    local serverElementValue = getElementData(serverClientRef, serverArgsArray[1]);
                    if serverShouldParse and type(serverElementValue) == "string" and string.find(serverElementValue, "|") then
                        return gettok(serverElementValue, 1, string.byte("|")), split(gettok(serverElementValue, 2, string.byte("|")), ",");
                    else
                        return serverElementValue;
                    end;
                elseif #serverArgsArray > 1 then
                    local serverNestedValue = nil;
                    for serverIndex, serverArgName in ipairs(serverArgsArray) do
                        if serverIndex == 1 then
                            serverNestedValue = getElementData(serverClientRef, serverArgName);
                        else
                            serverNestedValue = serverNestedValue[serverArgName];
                        end;
                        if not serverNestedValue then
                            return nil;
                        end;
                    end;
                    if serverShouldParse and type(serverNestedValue) == "string" and string.find(serverNestedValue, "|") then
                        return gettok(serverNestedValue, 1, string.byte("|")), split(gettok(serverNestedValue, 2, string.byte("|")), ",");
                    else
                        return serverNestedValue;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(serverParamString) 
                if type(serverParamString) == "string" then
                    if string.find(serverParamString, "|") then
                        return "parameter";
                    elseif string.find(serverParamString, ":") then
                        return "time";
                    elseif serverParamString == "true" or serverParamString == "false" then
                        return "toggle";
                    end;
                end;
                return type(serverParamString);
            end;
            setTacticsData = function(serverValue, ...) 
                triggerServerEvent("onSetTacticsData", resourceRoot, serverValue, ...);
            end;
        end;
    end;
    if triggerServerEvent ~= nil then
        local serverScreenWidth, serverScreenHeight = guiGetScreenSize();
        yscreen = serverScreenHeight;
        xscreen = serverScreenWidth;
        white = tocolor(255, 255, 255);
        whiteC0 = tocolor(255, 255, 255, 192);
        silver = tocolor(225, 225, 225);
        black = tocolor(0, 0, 0);
        blackC0 = tocolor(0, 0, 0, 192);
        black80 = tocolor(0, 0, 0, 128);
        black60 = tocolor(0, 0, 0, 96);
        blueC0 = tocolor(0, 192, 255, 192);
        darkblueC0 = tocolor(0, 96, 128, 192);
        greyE1 = tocolor(192, 192, 192, 225);
        setCameraPrepair = function(serverCameraHeight, serverCameraX, serverCameraY, serverCameraZ) 
            if not serverCameraX or not serverCameraY or not serverCameraZ then
                local serverCentralMarker = getElementsByType("Central_Marker")[1];
                if isElement(serverCentralMarker) then
                    local serverMarkerX, serverMarkerY, serverMarkerZ = getElementPosition(serverCentralMarker);
                    serverCameraZ = serverMarkerZ;
                    serverCameraY = serverMarkerY;
                    serverCameraX = serverMarkerX;
                else
                    local serverPlayerX, serverPlayerY, serverPlayerZ = getElementPosition(localPlayer);
                    serverCameraZ = serverPlayerZ;
                    serverCameraY = serverPlayerY;
                    serverCameraX = serverPlayerX;
                end;
            end;
            if not serverCameraHeight then
                serverCameraHeight = 70;
            end;
            setCameraMatrix(serverCameraX, serverCameraY, serverCameraZ, serverCameraX, serverCameraY, serverCameraZ + serverCameraHeight);
            setElementData(localPlayer, "Prepair", {serverCameraX, serverCameraY, serverCameraZ, serverCameraHeight}, false);
            return true;
        end;
        stopCameraPrepair = function() 
            if setElementData(localPlayer, "Prepair", nil, false) then
                setCameraTarget(localPlayer);
            end;
        end;
        getFont = function(serverFontSize) 
            return tonumber(0.015 * serverFontSize * yscreen / 9);
        end;
        getPlayerLanguage = function() 
            if not isElement(config_gameplay_language) then
                return "language/english.lng";
            else
                local serverLanguageText = guiGetText(config_gameplay_language);
                return serverLanguageText and config_gameplay_languagelist[serverLanguageText] or "language/english.lng";
            end;
        end;
        setPlayerLanguage = function(serverLanguageFile) 
            if config_gameplay_languagelist[guiGetText(config_gameplay_language)] == serverLanguageFile then
                return false;
            else
                local serverXmlFile = xmlLoadFile(serverLanguageFile);
                if serverXmlFile then
                    loadedLanguage = {};
                    local serverLanguageName = xmlNodeGetAttribute(serverXmlFile, "name") or "";
                    local serverLanguageAuthor = xmlNodeGetAttribute(serverXmlFile, "author") or "";
                    outputChatBox(serverLanguageName .. " (" .. serverLanguageAuthor .. ")", 255, 100, 100, true);
                    for __, serverXmlChild in ipairs(xmlNodeGetChildren(serverXmlFile)) do
                        loadedLanguage[xmlNodeGetName(serverXmlChild)] = xmlNodeGetAttribute(serverXmlChild, "string");
                    end;
                    xmlUnloadFile(serverXmlFile);
                    local serverGameplayNode = xmlFindChild(_client, "gameplay", 0) or xmlCreateChild(_client, "gameplay");
                    xmlNodeSetAttribute(serverGameplayNode, "language", serverLanguageFile);
                    xmlSaveFile(_client);
                    if not config_gameplay_languagelist[serverLanguageFile] then
                        config_gameplay_languagelist[serverLanguageFile] = serverLanguageName;
                    end;
                    if not config_gameplay_languagelist[serverLanguageName] then
                        config_gameplay_languagelist[serverLanguageName] = serverLanguageFile;
                    end;
                    guiSetText(config_gameplay_language, serverLanguageName);
                    triggerEvent("onClientLanguageChange", localPlayer, serverLanguageFile);
                    return true;
                else
                    return false;
                end;
            end;
        end;
        getLanguageString = function(serverStringKey) 
            if type(loadedLanguage) ~= "table" then
                loadedLanguage = {};
                local serverCurrentLanguage = getPlayerLanguage();
                local serverLanguageXml = xmlLoadFile(serverCurrentLanguage);
                if serverLanguageXml then
                    for __, serverXmlChildNode in ipairs(xmlNodeGetChildren(serverLanguageXml)) do
                        loadedLanguage[xmlNodeGetName(serverXmlChildNode)] = xmlNodeGetAttribute(serverXmlChildNode, "string");
                    end;
                    xmlUnloadFile(serverLanguageXml);
                end;
            end;
            return loadedLanguage[tostring(serverStringKey)] or "";
        end;
        outputLangString = function(serverOutputKey, ...) 
            local serverFormatArgs = {...};
            if #serverFormatArgs > 0 then
                outputChatBox(string.format(getLanguageString(tostring(serverOutputKey)), unpack(serverFormatArgs)), 255, 100, 100, true);
            else
                outputChatBox(getLanguageString(tostring(serverOutputKey)), 255, 100, 100, true);
            end;
        end;
        isAllGuiHidden = function() 
            if getElementData(localPlayer, "Status") == "Joining" then
                return false;
            else
                for __, serverGuiWindow in ipairs(getElementsByType("gui-window", resourceRoot)) do
                    if guiGetVisible(serverGuiWindow) and serverGuiWindow ~= voting_window then
                        return false;
                    end;
                end;
                return true;
            end;
        end;
        isRoundPaused = function() 
            if getTacticsData("Pause") then
                local serverUnpauseTime = getTacticsData("Unpause");
                if serverUnpauseTime then
                    return true, serverUnpauseTime - (getTickCount() + addTickCount);
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        voiceThread = {};
        playVoice = function(serverSoundFile, serverLoopSound, serverSoundVolume, serverSoundSpeed) 
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(voiceThread[serverSoundFile]) then
                return voiceThread[serverSoundFile];
            else
                voiceThread[serverSoundFile] = playSound(serverSoundFile, serverLoopSound or false);
                if not serverSoundVolume then
                    serverSoundVolume = 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol);
                else
                    serverSoundVolume = math.min(serverSoundVolume, 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol));
                end;
                setSoundVolume(voiceThread[serverSoundFile], serverSoundVolume);
                setSoundSpeed(voiceThread[serverSoundFile], serverSoundSpeed or 1);
                return voiceThread[serverSoundFile];
            end;
        end;
        musicThread = {};
        playMusic = function(serverMusicFile, serverMusicLoop, serverMusicVolume) 
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(musicThread[serverMusicFile]) then
                return musicThread[serverMusicFile];
            else
                musicThread[serverMusicFile] = playSound(serverMusicFile, serverMusicLoop or false);
                if not serverMusicVolume then
                    serverMusicVolume = 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol);
                else
                    serverMusicVolume = math.min(serverMusicVolume, 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol));
                end;
                setSoundVolume(musicThread[serverMusicFile], not serverMusicVolume and 1 or serverMusicVolume);
                setSoundSpeed(musicThread[serverMusicFile], speed or 1);
                return musicThread[serverMusicFile];
            end;
        end;
        getAngleBetweenPoints2D = function(serverX1, serverY1, serverX2, serverY2) 
            local serverAngle = 0 - math.deg(math.atan2(serverX2 - serverX1, serverY2 - serverY1));
            if serverAngle < 0 then
                serverAngle = serverAngle + 360;
            end;
            return serverAngle;
        end;
        getAngleBetweenAngles2D = function(serverAngle1, serverAngle2) 
            local serverAngleDifference;
            if serverAngle1 < serverAngle2 then
                if serverAngle1 < serverAngle2 - 180 then
                    serverAngleDifference = serverAngle1 - (serverAngle2 - 360);
                else
                    serverAngleDifference = serverAngle1 - serverAngle2;
                end;
            elseif serverAngle2 + 180 < serverAngle1 then
                serverAngleDifference = serverAngle1 - (serverAngle2 + 360);
            else
                serverAngleDifference = serverAngle1 - serverAngle2;
            end;
            return serverAngleDifference;
        end;
        replaceCustom = {};
        loadCustomObject = function(serverModelId, serverTxdFile, serverDffFile) 
            local serverCustomObject = {model = serverModelId};
            local serverImportResult = false;
            if serverTxdFile then
                serverCustomObject.txd = engineLoadTXD(serverTxdFile);
                serverImportResult = engineImportTXD(serverCustomObject.txd, serverModelId);
            end;
            if serverDffFile then
                serverCustomObject.dff = engineLoadDFF(serverDffFile, serverModelId);
                serverImportResult = engineReplaceModel(serverCustomObject.dff, serverModelId);
            end;
            if serverImportResult then
                table.insert(replaceCustom, serverCustomObject);
            end;
            return serverImportResult;
        end;
        addEventHandler("onClientMapStopping", root, function() 
            for __, serverReplaceData in ipairs(replaceCustom) do
                if serverReplaceData.txd and isElement(serverReplaceData.txd) then
                    destroyElement(serverReplaceData.txd);
                end;
                if serverReplaceData.dff and isElement(serverReplaceData.dff) then
                    destroyElement(serverReplaceData.dff);
                    engineRestoreModel(serverReplaceData.model);
                end;
            end;
            replaceCustom = {};
        end);
        getElementVector = function(serverElement, serverOffsetX, serverOffsetY, serverOffsetZ, serverRelative) 
            if not isElement(serverElement) then
                return false;
            else
                local serverElementMatrix = getElementMatrix(serverElement);
                local serverWorldPosition = {};
                if not serverRelative then
                    serverWorldPosition[1] = serverOffsetX * serverElementMatrix[1][1] + serverOffsetY * serverElementMatrix[2][1] + serverOffsetZ * serverElementMatrix[3][1] + serverElementMatrix[4][1];
                    serverWorldPosition[2] = serverOffsetX * serverElementMatrix[1][2] + serverOffsetY * serverElementMatrix[2][2] + serverOffsetZ * serverElementMatrix[3][2] + serverElementMatrix[4][2];
                    serverWorldPosition[3] = serverOffsetX * serverElementMatrix[1][3] + serverOffsetY * serverElementMatrix[2][3] + serverOffsetZ * serverElementMatrix[3][3] + serverElementMatrix[4][3];
                else
                    serverWorldPosition[1] = serverOffsetX * serverElementMatrix[1][1] + serverOffsetY * serverElementMatrix[2][1] + serverOffsetZ * serverElementMatrix[3][1];
                    serverWorldPosition[2] = serverOffsetX * serverElementMatrix[1][2] + serverOffsetY * serverElementMatrix[2][2] + serverOffsetZ * serverElementMatrix[3][2];
                    serverWorldPosition[3] = serverOffsetX * serverElementMatrix[1][3] + serverOffsetY * serverElementMatrix[2][3] + serverOffsetZ * serverElementMatrix[3][3];
                end;
                return serverWorldPosition;
            end;
        end;
        callServerFunction = function(serverFunctionName, ...) 
            local serverArgs = {...};
            if serverArgs[1] then
                for serverArgIndex, serverArgValue in next, serverArgs do
                    if type(serverArgValue) == "number" then
                        serverArgs[serverArgIndex] = tostring(serverArgValue);
                    end;
                end;
            end;
            triggerServerEvent("onClientCallsServerFunction", resourceRoot, serverFunctionName, unpack(serverArgs));
        end;
        callClientFunction = function(serverClientFunction, ...) 
            local serverClientArgs = {...};
            if serverClientArgs[1] then
                for serverClientArgIndex, serverClientArgValue in next, serverClientArgs do
                    serverClientArgs[serverClientArgIndex] = tonumber(serverClientArgValue) or serverClientArgValue;
                end;
            end;
            loadstring("return " .. serverClientFunction)()(unpack(serverClientArgs));
        end;
        addEvent("onServerCallsClientFunction", true);
        addEventHandler("onServerCallsClientFunction", root, callClientFunction);
        addEvent("onClientLanguageChange");
        addEvent("onOutputLangString", true);
        addEventHandler("onOutputLangString", root, outputLangString);
    else
        outputLangString = function(serverTargetPlayer, serverLangStringKey, ...) 
            triggerClientEvent(serverTargetPlayer, "onOutputLangString", root, serverLangStringKey, ...);
        end;
        getString = function(serverServerStringKey) 
            if not serverLanguage then
                serverLanguage = {};
                local serverServerXml = xmlLoadFile("language/english.lng");
                if serverServerXml then
                    for __, serverServerXmlChild in ipairs(xmlNodeGetChildren(serverServerXml)) do
                        serverLanguage[xmlNodeGetName(serverServerXmlChild)] = xmlNodeGetAttribute(serverServerXmlChild, "string");
                    end;
                end;
            end;
            return serverLanguage[tostring(serverServerStringKey)] or "";
        end;
        setCameraPrepair = function(serverPlayerElement, serverCameraHeightServer, serverCamX, serverCamY, serverCamZ) 
            if not serverCamX or not serverCamY or not serverCamZ then
                local serverServerCentralMarker = getElementsByType("Central_Marker")[1];
                if isElement(serverServerCentralMarker) then
                    local serverServerMarkerX, serverServerMarkerY, serverServerMarkerZ = getElementPosition(serverServerCentralMarker);
                    serverCamZ = serverServerMarkerZ;
                    serverCamY = serverServerMarkerY;
                    serverCamX = serverServerMarkerX;
                else
                    local serverServerPlayerX, serverServerPlayerY, serverServerPlayerZ = getElementPosition(serverPlayerElement);
                    serverCamZ = serverServerPlayerZ;
                    serverCamY = serverServerPlayerY;
                    serverCamX = serverServerPlayerX;
                end;
            end;
            if not serverCameraHeightServer then
                serverCameraHeightServer = 70;
            end;
            setCameraMatrix(serverPlayerElement, serverCamX, serverCamY, serverCamZ, serverCamX, serverCamY, serverCamZ + serverCameraHeightServer);
            setElementData(serverPlayerElement, "Prepair", {serverCamX, serverCamY, serverCamZ, serverCameraHeightServer});
        end;
        stopCameraPrepair = function(serverSpectatingPlayer) 
            if setElementData(serverSpectatingPlayer, "Prepair", nil) then
                setCameraTarget(serverSpectatingPlayer, serverSpectatingPlayer);
            end;
        end;
        setCameraSpectating = function(serverTargetSpectator, ...) 
            if serverTargetSpectator and isElement(serverTargetSpectator) then
                callClientFunction(serverTargetSpectator, "setCameraSpectating", ...);
                return true;
            else
                return false;
            end;
        end;
        isRoundPaused = function() 
            if getTacticsData("Pause") then
                local serverServerUnpauseTime = getTacticsData("Unpause");
                if serverServerUnpauseTime then
                    return true, serverServerUnpauseTime - getTickCount();
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        createMapVehicle = function(serverVehicleModel, serverVehX, serverVehY, serverVehZ, serverVehRotX, serverVehRotY, serverVehRotZ) 
            local serverCreatedVehicle = createVehicle(serverVehicleModel, serverVehX, serverVehY, serverVehZ, serverVehRotX, serverVehRotY, serverVehRotZ);
            setElementParent(serverCreatedVehicle, getRoundMapDynamicRoot());
            return serverCreatedVehicle;
        end;
        callClientFunction = function(serverTargetClient, serverServerFunctionName, ...) 
            local serverServerArgs = {...};
            if serverServerArgs[1] then
                for serverServerArgIndex, serverServerArgValue in next, serverServerArgs do
                    if type(serverServerArgValue) == "number" then
                        serverServerArgs[serverServerArgIndex] = tostring(serverServerArgValue);
                    end;
                end;
            end;
            triggerClientEvent(serverTargetClient, "onServerCallsClientFunction", root, serverServerFunctionName, unpack(serverServerArgs or {}));
        end;
        callServerFunction = function(serverServerFunction, ...) 
            local serverServerFunctionArgs = {...};
            if serverServerFunctionArgs[1] then
                for serverServerArgIdx, serverServerArgVal in next, serverServerFunctionArgs do
                    serverServerFunctionArgs[serverServerArgIdx] = tonumber(serverServerArgVal) or serverServerArgVal;
                end;
            end;
            loadstring("return " .. serverServerFunction)()(unpack(serverServerFunctionArgs));
        end;
        addEvent("onClientCallsServerFunction", true);
        addEventHandler("onClientCallsServerFunction", root, callServerFunction);
    end;
    getRoundMapRoot = function(serverMapResource) 
        if serverMapResource then
            return getResourceRootElement(serverMapResource);
        else
            local serverResourceHandle = getResourceFromName(getTacticsData("MapResName"));
            if serverResourceHandle then
                return getResourceRootElement(serverResourceHandle);
            else
                return root;
            end;
        end;
    end;
    getRoundMapDynamicRoot = function(serverDynamicMapResource) 
        if serverDynamicMapResource then
            return getResourceDynamicElementRoot(serverDynamicMapResource);
        else
            local serverDynamicResourceHandle = getResourceFromName(getTacticsData("MapResName"));
            if serverDynamicResourceHandle then
                return getResourceDynamicElementRoot(serverDynamicResourceHandle);
            else
                return root;
            end;
        end;
    end;
    removeColorCoding = function(serverText) 
        return type(serverText) == "string" and string.gsub(serverText, "#%x%x%x%x%x%x", "") or serverText;
    end;
    TimeToSec = function(serverTimeString) 
        if not string.find(tostring(serverTimeString), ":") then
            return false;
        else
            local serverTimeParts = split(tostring(serverTimeString), string.byte(":"));
            local serverHours = tonumber(serverTimeParts[#serverTimeParts - 2]) or 0;
            local serverMinutes = tonumber(serverTimeParts[#serverTimeParts - 1]) or 0;
            local serverSeconds = tonumber(serverTimeParts[#serverTimeParts]);
            return 3600 * serverHours + 60 * serverMinutes + serverSeconds;
        end;
    end;
    MSecToTime = function(serverMilliseconds, serverDecimalPlaces) 
        if type(serverMilliseconds) ~= "number" then
            return false;
        else
            if type(serverDecimalPlaces) ~= "number" then
                serverDecimalPlaces = 1;
            end;
            local serverMsHours = math.floor(serverMilliseconds / 3600000) or 0;
            local serverMsMinutes = math.floor(serverMilliseconds / 60000) - serverMsHours * 60 or 0;
            local serverMsSeconds = math.floor(serverMilliseconds / 1000) - serverMsMinutes * 60 - serverMsHours * 3600 or 0;
            local serverMsRemaining = serverMilliseconds - serverMsSeconds * 1000 - serverMsMinutes * 60000 - serverMsHours * 3600000 or 0;
            local serverFormattedTime = string.format("%02i", serverMsSeconds);
            if serverMsHours > 0 then
                serverFormattedTime = string.format("%i:%02i:", serverMsHours, serverMsMinutes) .. serverFormattedTime;
            else
                serverFormattedTime = string.format("%i:", serverMsMinutes) .. serverFormattedTime;
            end;
            if serverDecimalPlaces > 0 then
                local serverMsFraction = string.sub(string.format("%." .. serverDecimalPlaces .. "f", 0.001 * serverMsRemaining), 2);
                if #serverMsFraction - 1 < serverDecimalPlaces then
                    serverMsFraction = serverMsFraction .. string.rep("0", serverDecimalPlaces - (#serverMsFraction - 1));
                end;
                serverFormattedTime = serverFormattedTime .. serverMsFraction;
            end;
            return serverFormattedTime;
        end;
    end;
    string.count = function(serverSourceString, serverSearchPattern) 
        local serverCountResult = 0;
        local serverFoundIndex = string.find(serverSourceString, serverSearchPattern);
        while serverFoundIndex do
            serverCountResult = serverCountResult + 1;
            serverFoundIndex = string.find(serverSourceString, serverSearchPattern, serverFoundIndex + 1);
        end;
        return serverCountResult;
    end;
    getRoundMapInfo = function() 
        return {
            modename = getTacticsData("Map"), 
            name = getTacticsData("MapName") or "unnamed", 
            author = getTacticsData("MapAuthor"), 
            resname = getTacticsData("MapResName"), 
            mapnext = getTacticsData("ResourceNext")
        };
    end;
    getRoundModeSettings = function(...) 
        local serverModeArgs = {...};
        local serverModeName = getTacticsData("Map");
        local serverModeSettings = {getTacticsData("modes", serverModeName, unpack(serverModeArgs))};
        if serverModeSettings[1] then
            return unpack(serverModeSettings);
        else
            return getTacticsData(unpack(serverModeArgs));
        end;
    end;
    getUnreadyPlayers = function() 
        local serverUnreadyList = {};
        for __, serverPlayer in ipairs(getElementsByType("player")) do
            if getElementData(serverPlayer, "Loading") and getElementData(serverPlayer, "Status") == "Play" then
                table.insert(serverUnreadyList, serverPlayer);
            end;
        end;
        if #serverUnreadyList > 1 then
            return serverUnreadyList;
        else
            return serverUnreadyList[1] or false;
        end;
    end;
    getPlayerGameStatus = function(serverTargetPlayerStatus) 
        if not isElement(serverTargetPlayerStatus) then
            return false;
        elseif getElementData(serverTargetPlayerStatus, "Loading") then
            return "Loading";
        else
            return getElementData(serverTargetPlayerStatus, "Status");
        end;
    end;
    getRoundState = function() 
        return (getTacticsData("roundState"));
    end;
end)();
(function(...) 
    addTickCount = 0;
    helpme = {};
    helpmeArrow = {};
    local serverIsVehicleNametagEnabled = false;
    weaponSave = {};
    weaponMemory = false;
    fixTickCount = function(serverTickCount) 
        addTickCount = serverTickCount - getTickCount();
    end;
    showCountdown = function(serverCountdownNumber) 
        if serverCountdownNumber == 0 then
            dxDrawAnimatedImage("images/count_go.png", 2);
            if not playVoice("audio/count_go.mp3") then
                playSoundFrontEnd(45);
            end;
        elseif serverCountdownNumber <= 3 then
            dxDrawAnimatedImage("images/count_" .. serverCountdownNumber .. ".png", 1);
            if not playVoice("audio/count_" .. serverCountdownNumber .. ".mp3") then
                playSoundFrontEnd(44);
            end;
        end;
    end;
    onClientResourceStart = function(__) 
        fontTactics = guiCreateFont("verdana.ttf", 20) or fontTactics;
        serverIsVehicleNametagEnabled = false;
        label_version = guiCreateLabel(0, yscreen - 30, xscreen - 5, 30, "", false);
        guiSetEnabled(label_version, false);
        guiLabelSetHorizontalAlign(label_version, "right", false);
        guiSetAlpha(label_version, 0.5);
        mapstring = guiCreateLabel(5, yscreen - 15, xscreen, 15, tostring(getTacticsData("MapName", false)), false);
        guiSetEnabled(mapstring, false);
        guiSetAlpha(mapstring, 0.5);
        for __, serverOtherPlayer in ipairs(getElementsByType("player")) do
            if serverOtherPlayer ~= localPlayer then
                local serverPlayerBlip = createBlipAttachedTo(serverOtherPlayer, 0, 2, 0, 0, 0, 0);
                setElementData(serverOtherPlayer, "Blip", serverPlayerBlip, false);
                setElementParent(serverPlayerBlip, serverOtherPlayer);
            end;
        end;
        for __, serverVehicle in ipairs(getElementsByType("vehicle")) do
            local serverVehicleBlip = createBlipAttachedTo(serverVehicle, 0, 0, 0, 0, 0, 0, -1);
            setElementData(serverVehicle, "Blip", serverVehicleBlip, false);
            setElementParent(serverVehicleBlip, serverVehicle);
        end;
        credits_window = guiCreateWindow(xscreen * 0.5 - 280, yscreen * 0.5 - 150, 560, 300, "", false);
        guiWindowSetSizable(credits_window, false);
        guiSetVisible(credits_window, false);
        credits_content = {};
        credits_height = 300;
        local function serverCreateCreditLine(serverLabelText, serverTextStyle) 
            local serverCreditLabel = guiCreateLabel(0, credits_height, 560, 1000, serverLabelText, false, credits_window);
            if not serverTextStyle then
                serverTextStyle = 0;
            end;
            if serverTextStyle == 1 then
                guiSetFont(serverCreditLabel, "default-bold-small");
            end;
            if serverTextStyle == 2 then
                guiSetFont(serverCreditLabel, fontTactics);
            end;
            guiSetEnabled(serverCreditLabel, false);
            guiLabelSetHorizontalAlign(serverCreditLabel, "center", false);
            table.insert(credits_content, {serverCreditLabel, credits_height});
            local serverHeightAdjustments = {
                [0] = 50, 
                [1] = 20, 
                [2] = 80
            };
            credits_height = credits_height + string.count(serverLabelText, "\n") * guiLabelGetFontHeight(serverCreditLabel) + serverHeightAdjustments[serverTextStyle];
            return serverCreditLabel;
        end;
        credits_version = serverCreateCreditLine("", 2);
        serverCreateCreditLine("Author, Scripting & Idea", 1);
        serverCreateCreditLine("Alexander \"Lex128\"");
        serverCreateCreditLine("Interface Design", 1);
        serverCreateCreditLine("Alexander \"Lex128\"\nDenis \"spitfire\"\nDenis \"Den\"\nand unknown creator of countdown images");
        serverCreateCreditLine("Speech Synthesis", 1);
        serverCreateCreditLine("SitePal.com");
        serverCreateCreditLine("Mapping", 1);
        serverCreateCreditLine("Maxim \"Saint\"\nAlexander \"Lex128\"\nStar \"Easterdie\"");
        serverCreateCreditLine("Language Support", 1);
        serverCreateCreditLine("Osamah \"iComm2a\"\nEddy \"Dorega\"\nLaith \"C4neeL\"\nViktor \"Rubik\"\nAlexander \"Zaibatsu\"\nJoseph \"Randy\"\nAdrian \"vnm\"\nLukas \"Lukis\"\nNikolas \"Dante\"\nAriel \"arielszz\"");
        serverCreateCreditLine("Develop open-source", 1);
        serverCreateCreditLine("Ariel \"arielszz\"");
        serverCreateCreditLine("Special Thanks", 1);
        serverCreateCreditLine("Nikita \"Vincent\"\nSemen \"DJ_Semen\"\nSergey \"3ap\"");
        credits_ending = {
            guiCreateLabel(0, credits_height, 560, 20, "Lex128, 2009-" .. tostring(1900 + getRealTime().year), false, credits_window), 
            credits_height
        };
        guiLabelSetHorizontalAlign(credits_ending[1], "center", false);
        guiSetEnabled(credits_ending[1], false);
        credits_close = guiCreateButton(431, 270, 112, 21, "OK", false, credits_window);
        guiSetFont(credits_close, "default-bold-small");
        team_window = guiCreateWindow(xscreen * 0.5 - 130, yscreen * 0.5 - 120, 260, 240, "Teams", false);
        guiWindowSetSizable(team_window, false);
        guiSetVisible(team_window, false);
        team_button = {};
        team_specskinbtn = guiCreateButton(135, 27, 120, 20, "    Spectate Skin", false, team_window);
        guiSetFont(team_specskinbtn, "default-bold-small");
        team_specskin = guiCreateCheckBox(5, 2, 16, 16, "", false, false, team_specskinbtn);
        team_joining = guiCreateButton(135, 49, 120, 20, "Go to Joining", false, team_window);
        guiSetFont(team_joining, "default-bold-small");
        team_close = guiCreateButton(135, 71, 120, 20, "Close", false, team_window);
        guiSetFont(team_close, "default-bold-small");
        guiSetInputEnabled(false);
        setInteriorSoundsEnabled(false);
        setAmbientSoundEnabled("gunfire", false);
        setTrafficLightsLocked(true);
        setTrafficLightState("yellow", "yellow");
        addEventHandler("onClientGUIMouseDown", root, function() 
            if (getElementType(source) == "gui-edit" or getElementType(source) == "gui-memo") and guiGetProperty(source, "ReadOnly") ~= "True" then
                guiSetInputEnabled(true);
            elseif guiGetInputEnabled() then
                guiSetInputEnabled(false);
            end;
        end);
        setTimer(triggerServerEvent, 150, 1, "onPlayerDownloadComplete", localPlayer);
        setTimer(triggerEvent, 150, 1, "onDownloadComplete", root);
    end;
    onClientResourceStop = function() 
        for __, serverPedElement in ipairs(currentPed) do
            if isElement(serverPedElement) then
                destroyElement(serverPedElement);
            end;
        end;
        currentPed = {};
        setElementData(localPlayer, "Status", nil);
        setTrafficLightState("auto");
        resetAmbientSounds();
        resetHeatHaze();
        resetSkyGradient();
        resetWindVelocity();
        resetRainLevel();
        resetSunSize();
        resetSunColor();
        resetFarClipDistance();
        resetFogDistance();
        resetWaterColor();
        resetWaterLevel();
    end;
    createVehicleManager = function() 
        vehicle_window = guiCreateWindow(xscreen * 0.5 - 130, yscreen * 0.5 - 225, 260, 450, "Vehicle Manager", false);
        guiWindowSetSizable(vehicle_window, false);
        vehicle_search = guiCreateEdit(0.04, 0.05, 0.63, 0.05, "", true, vehicle_window);
        guiSetEnabled(guiCreateStaticImage(0.88, 0.1, 0.11, 0.8, "images/search.png", true, vehicle_search), false);
        vehicle_list = guiCreateGridList(0.04, 0.11, 0.63, 0.81, true, vehicle_window);
        guiGridListSetSortingEnabled(vehicle_list, false);
        guiGridListAddColumn(vehicle_list, "Name", 0.8);
        vehicle_car = guiCreateCheckBox(0.7, 0.11, 0.28, 0.05, "Cars", true, true, vehicle_window);
        vehicle_bike = guiCreateCheckBox(0.7, 0.16999999999999998, 0.28, 0.05, "Bikes", true, true, vehicle_window);
        vehicle_plane = guiCreateCheckBox(0.7, 0.22999999999999998, 0.28, 0.05, "Planes", true, true, vehicle_window);
        vehicle_heli = guiCreateCheckBox(0.7, 0.29, 0.28, 0.05, "Helis", true, true, vehicle_window);
        vehicle_boat = guiCreateCheckBox(0.7, 0.35, 0.28, 0.05, "Boats", true, true, vehicle_window);
        vehicle_getvehicle = guiCreateButton(0.04, 0.93, 0.44, 0.05, "Get vehicle", true, vehicle_window);
        guiSetFont(vehicle_getvehicle, "default-bold-small");
        guiSetProperty(vehicle_getvehicle, "NormalTextColour", "C000FF00");
        vehicle_close = guiCreateButton(0.52, 0.93, 0.44, 0.05, "Cancel", true, vehicle_window);
        guiSetFont(vehicle_close, "default-bold-small");
        updateVehicleList();
        return vehicle_window;
    end;
    createWeaponManager = function() 
        weapon_window = guiCreateWindow(xscreen * 0.5 - 310, yscreen * 0.5 - 160, 620, 320, "Weapon Manager", false);
        guiWindowSetSizable(weapon_window, false);
        weapon_properties = guiCreateLabel(435, 28, 185, 230, "", false, weapon_window);
        local serverWeaponSlotsLimit = getTacticsData("weapon_slots") or 0;
        weapon_slots = guiCreateLabel(435, 244, 185, 22, "You can choice " .. (serverWeaponSlotsLimit > 0 and serverWeaponSlotsLimit or "any") .. " weapons", false, weapon_window);
        guiLabelSetHorizontalAlign(weapon_slots, "center", false);
        guiSetFont(weapon_slots, "default-bold-small");
        weapon_scrollerbg = guiCreateGridList(5, 25, 420, 290, false, weapon_window);
        weapon_scroller = guiCreateScrollPane(3, 3, 416, 285, false, weapon_scrollerbg);
        weapon_items = {};
        weapon_memory = guiCreateCheckBox(433, 266, 100, 22, "Save Selected", false, false, weapon_window);
        weapon_accept = guiCreateButton(433, 288, 86, 22, "Get weapons", false, weapon_window);
        guiSetFont(weapon_accept, "default-bold-small");
        guiSetProperty(weapon_accept, "NormalTextColour", "C000FF00");
        weapon_close = guiCreateButton(524, 288, 86, 22, "Close", false, weapon_window);
        guiSetFont(weapon_close, "default-bold-small");
        remakeWeaponsPack();
        return weapon_window;
    end;
    onClientOtherResourceStart = function(serverStartedResource) 
        if getThisResource() ~= serverStartedResource and getResourceName(serverStartedResource) == getTacticsData("MapResName") and getElementData(localPlayer, "Status") then
            local serverMapInfo = {
                modename = getTacticsData("Map"), 
                name = getTacticsData("MapName", false) or "unnamed", 
                author = getTacticsData("MapAuthor", false), 
                resname = getResourceName(serverStartedResource), 
                resource = serverStartedResource
            };
            if serverMapInfo.modename then
                triggerServerEvent("onPlayerMapLoad", localPlayer);
                triggerEvent("onClientMapStarting", root, serverMapInfo);
            end;
        end;
    end;
    updateTeamManager = function() 
        local serverTeamList = getElementsByType("team");
        table.insert(serverTeamList, serverTeamList[1]);
        table.remove(serverTeamList, 1);
        for serverTeamIndex, serverCurrentTeam in ipairs(serverTeamList) do
            if serverCurrentTeam == getPlayerTeam(localPlayer) then
                table.remove(serverTeamList, serverTeamIndex);
                break;
            end;
        end;
        local __ = 1;
        for serverTeamButtonIndex = 1, math.max(#serverTeamList, #team_button) do
            if serverTeamButtonIndex <= #serverTeamList then
                if #team_button < serverTeamButtonIndex then
                    team_button[serverTeamButtonIndex] = guiCreateButton(5, 5 + 22 * serverTeamButtonIndex, 120, 20, "", false, team_window);
                    guiSetFont(team_button[serverTeamButtonIndex], "default-bold-small");
                end;
                guiSetText(team_button[serverTeamButtonIndex], getTeamName(serverTeamList[serverTeamButtonIndex]));
                guiSetProperty(team_button[serverTeamButtonIndex], "NormalTextColour", string.format("FF%02X%02X%02X", getTeamColor(serverTeamList[serverTeamButtonIndex])));
                guiBringToFront(team_button[serverTeamButtonIndex]);
            else
                destroyElement(team_button[serverTeamButtonIndex]);
                table.remove(team_button);
            end;
        end;
        guiCheckBoxSetSelected(team_specskin, getElementData(localPlayer, "spectateskin") and true or false);
        guiSetSize(team_window, 260, 5 + 22 * math.max(3, #serverTeamList) + 22 + 8, false);
        guiSetPosition(team_joining, 135, 5 + 22 * math.max(2, #serverTeamList - 1), false);
        guiSetPosition(team_close, 135, 5 + 22 * math.max(3, #serverTeamList), false);
    end;
    createRadarPolyline = function(serverPointList, serverRedColor, serverGreenColor, serverBlueColor, serverAlphaColor, serverIsClosedShape, serverMarkerSize, serverParentElement) 
        if type(serverPointList) ~= "table" and type(serverPointList) ~= "userdata" then
            return false;
        else
            if not serverRedColor then
                serverRedColor = 128;
            end;
            if not serverGreenColor then
                serverGreenColor = 0;
            end;
            if not serverBlueColor then
                serverBlueColor = 0;
            end;
            if not serverAlphaColor then
                serverAlphaColor = 255;
            end;
            if not serverMarkerSize then
                serverMarkerSize = 12;
            end;
            if not serverParentElement then
                serverParentElement = getRoundMapDynamicRoot();
            end;
            local function isValidNumber(num)
                return type(num) == "number" and num == num
            end
            if not isValidNumber(serverMarkerSize) or serverMarkerSize <= 0 then
                serverMarkerSize = 12;
            end;
            if not isValidNumber(serverRedColor) then serverRedColor = 128 end
            if not isValidNumber(serverGreenColor) then serverGreenColor = 0 end
            if not isValidNumber(serverBlueColor) then serverBlueColor = 0 end
            if not isValidNumber(serverAlphaColor) then serverAlphaColor = 255 end
            for serverPointIndex, serverCurrentPoint in ipairs(serverPointList) do
                local serverCurrentX = 0;
                local serverCurrentY = 0;
                local serverNextX = 0;
                local serverNextY = 0;
                if isElement(serverCurrentPoint) then
                    local serverElementX = tonumber(getElementData(serverCurrentPoint, "posX"));
                    serverCurrentY = tonumber(getElementData(serverCurrentPoint, "posY"));
                    serverCurrentX = serverElementX;
                else
                    local serverPointX, serverPointY = unpack(serverCurrentPoint);
                    serverCurrentY = serverPointY;
                    serverCurrentX = serverPointX;
                end;
                if not isValidNumber(serverCurrentX) or not isValidNumber(serverCurrentY) then
                    return false;
                end;
            
                local serverNextPoint = serverPointIndex < #serverPointList and serverPointList[serverPointIndex + 1] or serverIsClosedShape and serverPointList[1];
                if serverNextPoint then
                    if isElement(serverNextPoint) then
                        local serverNextElementX = tonumber(getElementData(serverNextPoint, "posX"));
                        serverNextY = tonumber(getElementData(serverNextPoint, "posY"));
                        serverNextX = serverNextElementX;
                    else
                        local serverNextPointX, serverNextPointY = unpack(serverNextPoint);
                        serverNextY = serverNextPointY;
                        serverNextX = serverNextPointX;
                    end;
                    if not isValidNumber(serverNextX) or not isValidNumber(serverNextY) then
                        return false;
                    end;
                    local distance = getDistanceBetweenPoints2D(serverCurrentX, serverCurrentY, serverNextX, serverNextY);
                    if not isValidNumber(distance) then
                        return false;
                    end
                
                    if distance <= 0 then
                        local xPos = serverCurrentX - serverMarkerSize * 0.5
                        local yPos = serverCurrentY - serverMarkerSize * 0.5
                    
                        if isValidNumber(xPos) and isValidNumber(yPos) then
                            local serverRadarArea = createRadarArea(xPos, yPos, serverMarkerSize, serverMarkerSize, serverRedColor, serverGreenColor, serverBlueColor, serverAlphaColor);
                            if serverRadarArea and isElement(serverRadarArea) and serverParentElement and isElement(serverParentElement) then
                                setElementParent(serverRadarArea, serverParentElement);
                            end;
                        end
                    else
                        local serverSegmentCount = math.floor(distance / (0.4 * serverMarkerSize));
                        if serverSegmentCount < 1 then
                            serverSegmentCount = 1;
                        end;
                        local serverXIncrement = (serverNextX - serverCurrentX) / serverSegmentCount;
                        local serverYIncrement = (serverNextY - serverCurrentY) / serverSegmentCount;
                        if not isValidNumber(serverXIncrement) or not isValidNumber(serverYIncrement) then
                            return false;
                        end;
                        for serverSegmentIndex = 0, serverSegmentCount do
                            local xPos = serverCurrentX - serverMarkerSize * 0.5 + serverXIncrement * serverSegmentIndex;
                            local yPos = serverCurrentY - serverMarkerSize * 0.5 + serverYIncrement * serverSegmentIndex;
                            if isValidNumber(xPos) and isValidNumber(yPos) then
                                local serverRadarArea
                                if isValidNumber(xPos) and isValidNumber(yPos) and isValidNumber(serverMarkerSize) then
                                    serverRadarArea = createRadarArea(xPos, yPos, serverMarkerSize, serverMarkerSize, serverRedColor, serverGreenColor, serverBlueColor, serverAlphaColor);
                                end
                                if serverRadarArea and isElement(serverRadarArea) then
                                    if serverParentElement and isElement(serverParentElement) then
                                        setElementParent(serverRadarArea, serverParentElement);
                                    end
                                end
                            end
                        end;
                    end;
                end;
            end;
            return true;
        end;
    end;
    onClientMapStarting = function(__) 
        local serverAntiRushPoints = {};
        for __, serverRushPoint in ipairs(getElementsByType("Anti_Rush_Point")) do
            local serverRushX = tonumber(getElementData(serverRushPoint, "posX"));
            local serverRushY = tonumber(getElementData(serverRushPoint, "posY"));
            table.insert(serverAntiRushPoints, {serverRushX, serverRushY});
        end;
        if #serverAntiRushPoints > 0 then
            if #serverAntiRushPoints == 2 then
                serverAntiRushPoints = {
                    {math.min(serverAntiRushPoints[1][1], serverAntiRushPoints[2][1]), math.min(serverAntiRushPoints[1][2], serverAntiRushPoints[2][2])}, 
                    {math.max(serverAntiRushPoints[1][1], serverAntiRushPoints[2][1]), math.min(serverAntiRushPoints[1][2], serverAntiRushPoints[2][2])}, 
                    {math.max(serverAntiRushPoints[1][1], serverAntiRushPoints[2][1]), math.max(serverAntiRushPoints[1][2], serverAntiRushPoints[2][2])}, 
                    {math.min(serverAntiRushPoints[1][1], serverAntiRushPoints[2][1]), math.max(serverAntiRushPoints[1][2], serverAntiRushPoints[2][2])}
                };
            end;
            if #serverAntiRushPoints > 1 then
                local serverDynamicRoot = getRoundMapDynamicRoot();
                local serverPolygonPoints = {};
                local serverCentralMarker = getElementsByType("Central_Marker")[1];
                table.insert(serverPolygonPoints, tonumber(getElementData(serverCentralMarker, "posX")));
                table.insert(serverPolygonPoints, tonumber(getElementData(serverCentralMarker, "posY")));
                for __, serverRushPointData in ipairs(serverAntiRushPoints) do
                    table.insert(serverPolygonPoints, serverRushPointData[1]);
                    table.insert(serverPolygonPoints, serverRushPointData[2]);
                end;
                createRadarPolyline(serverAntiRushPoints, 128, 0, 0, 255, true, 12, serverDynamicRoot);
                local serverColPolygon = createColPolygon(unpack(serverPolygonPoints));
                setElementParent(serverColPolygon, serverDynamicRoot);
                setElementData(serverColPolygon, "Boundings", true, false);
            end;
        end;
        if getElementData(localPlayer, "Loading") and type(notreadyCounter) ~= "number" then
            local serverSpawnMarker = getElementsByType("Central_Marker")[1] or getElementsByType("spawnpoint")[1];
            if serverSpawnMarker then
                local serverMarkerPosX = tonumber(getElementData(serverSpawnMarker, "posX"));
                local serverMarkerPosY = tonumber(getElementData(serverSpawnMarker, "posY"));
                local serverMarkerPosZ = tonumber(getElementData(serverSpawnMarker, "posZ"));
                if not serverMarkerPosX or not serverMarkerPosY or not serverMarkerPosZ then
                    local serverElementPosX, serverElementPosY, serverElementPosZ = getElementPosition(serverSpawnMarker);
                    serverMarkerPosZ = serverElementPosZ;
                    serverMarkerPosY = serverElementPosY;
                    serverMarkerPosX = serverElementPosX;
                end;
                if serverMarkerPosX and serverMarkerPosY and serverMarkerPosZ then
                    setCameraMatrix(serverMarkerPosX, serverMarkerPosY, serverMarkerPosZ + 1, serverMarkerPosX, serverMarkerPosY, serverMarkerPosZ);
                end;
            end;
        end;
    end;
    onClientPlayerJoin = function() 
        local serverJoinBlip = createBlipAttachedTo(source, 0, 2, 0, 0, 0, 0);
        setElementData(source, "Blip", serverJoinBlip, false);
        setElementParent(serverJoinBlip, source);
    end;
    onClientPlayerQuit = function(__) 
        local serverPlayerBlipToDestroy = getElementData(source, "Blip");
        if serverPlayerBlipToDestroy then
            destroyElement(serverPlayerBlipToDestroy);
        end;
    end;
    onClientPlayerDamage = function(serverDamageSource, __, __, __) 
        if isElement(serverDamageSource) and localPlayer ~= serverDamageSource then
            if getElementType(serverDamageSource) == "vehicle" then
                serverDamageSource = getVehicleController(serverDamageSource);
            end;
            if getElementType(serverDamageSource) ~= "player" then
                return;
            else
                local serverAttackerTeam = getPlayerTeam(serverDamageSource);
                local serverVictimTeam = getPlayerTeam(localPlayer);
                if serverVictimTeam and serverAttackerTeam and serverAttackerTeam ~= serverVictimTeam and getElementData(serverVictimTeam, "Side") == getElementData(serverAttackerTeam, "Side") then
                    cancelEvent();
                end;
            end;
        end;
    end;
    onClientPlayerSpawn = function(__) 
        if source ~= localPlayer then
            setElementCollisionsEnabled(source, true);
        else
            setElementRotation(localPlayer, 0, 0, getPedRotation(localPlayer));
        end;
    end;
    onClientPlayerWasted = function(__, serverDeathReason, __) 
        if source == localPlayer then
            if serverDeathReason == 16 or serverDeathReason == 19 or serverDeathReason == 35 or serverDeathReason == 36 or serverDeathReason == 37 or serverDeathReason == 39 or serverDeathReason == 51 or serverDeathReason == 59 then
                playVoice("audio/toasted.mp3");
            else
                playVoice("audio/wasted.mp3");
            end;
            setCameraMatrix(getCameraMatrix());
        else
            setElementCollisionsEnabled(source, false);
        end;
    end;
    onClientRespawnCountdown = function(serverRespawnTime) 
        if respawn_countdown then
            return;
        else
            addEventHandler("onClientPreRender", root, onClientRespawnRender);
            respawn_countdown = serverRespawnTime;
            return;
        end;
    end;
    onClientRespawnRender = function(serverTimeDelta) 
        respawn_countdown = respawn_countdown - serverTimeDelta * getGameSpeed();
        local serverMaxLives = tonumber(getRoundModeSettings("respawn_lives") or getTacticsData("settings", "respawn_lives") or tonumber(0));
        local serverCurrentLives = getElementData(localPlayer, "RespawnLives");
        if serverCurrentLives and serverMaxLives > 0 then
            dxDrawText(tostring(serverCurrentLives), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, 4278190080, getFont(2), "default-bold", "center", "bottom");
            dxDrawText(tostring(serverCurrentLives), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 128), getFont(2), "default-bold", "center", "bottom");
        end;
        dxDrawText(string.format(getLanguageString("respawn_in"), math.max(respawn_countdown, 0) / 1000), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(1), "default", "center", "top");
        dxDrawText(string.format(getLanguageString("respawn_in"), math.max(respawn_countdown, 0) / 1000), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 255), getFont(1), "default", "center", "top");
        if respawn_countdown <= 0 then
            removeEventHandler("onClientPreRender", root, onClientRespawnRender);
            respawn_countdown = nil;
            fadeCamera(false, 0);
            triggerServerEvent("onPlayerRoundRespawn", localPlayer);
        end;
    end;
    local serverCameraAngle = nil;
    local serverCameraTransition = nil;
    onClientRoundCountdownStarted = function(serverTransitionDuration) 
        local serverPlayerX, serverPlayerY, serverPlayerZ = getElementPosition(localPlayer);
        local serverPlayerRotationRad = math.rad(getPedRotation(localPlayer));
        local serverCameraAngleRad = math.rad(2.86431884766);
        local serverLookAtX = 0;
        local serverLookAtY = 0;
        local serverCameraHeightOffset = 0.6;
        if isPedDucked(localPlayer) then serverCameraHeightOffset = -0.1; end;
        local serverCameraOffsetX = 3.5 * math.sin(serverPlayerRotationRad) * math.cos(serverCameraAngleRad);
        local serverCameraOffsetY = -3.5 * math.cos(serverPlayerRotationRad) * math.cos(serverCameraAngleRad);
        local serverCameraOffsetZ = 3.5 * math.sin(serverCameraAngleRad) + serverCameraHeightOffset;
        serverCameraTransition = {
            getTickCount(), serverTransitionDuration, serverCameraOffsetX + serverPlayerX, serverCameraOffsetY + serverPlayerY, serverCameraOffsetZ + serverPlayerZ, serverLookAtX + serverPlayerX, serverLookAtY + serverPlayerY, serverCameraHeightOffset + serverPlayerZ};
    end;
    onClientPrepairRender = function() 
        local serverPrepairData = getElementData(localPlayer, "Prepair");
        if serverPrepairData and not getCameraTarget() then
            local serverTargetX, serverTargetY, serverTargetZ, serverCameraDistance = unpack(serverPrepairData);
            local serverCameraPosX, serverCameraPosY, serverCameraPosZ = getCameraMatrix();
            serverCameraAngle = (serverCameraAngle or getAngleBetweenPoints2D(serverTargetX, serverTargetY, serverCameraPosX, serverCameraPosY)) + 1;
            local serverCurrentAngleRad = math.rad(serverCameraAngle);
            local serverNewCameraX = serverTargetX - serverCameraDistance * math.sin(serverCurrentAngleRad);
            local serverNewCameraY = serverTargetY + serverCameraDistance * math.cos(serverCurrentAngleRad);
            serverCameraPosZ = serverTargetZ + 0.5 * serverCameraDistance;
            serverCameraPosY = serverNewCameraY;
            serverCameraPosX = serverNewCameraX;
            if serverCameraTransition == nil or getElementData(localPlayer, "Status") ~= "Play" then
                setCameraMatrix(serverCameraPosX, serverCameraPosY, serverCameraPosZ, serverTargetX, serverTargetY, serverTargetZ);
            elseif type(serverCameraTransition) == "table" then
                local serverTransitionStartTime, serverTransitionTotalTime, serverEndOffsetX, serverEndOffsetY, serverEndOffsetZ, serverEndLookAtX;
                serverNewCameraX, serverNewCameraY, serverTransitionStartTime, serverTransitionTotalTime, serverEndOffsetX, serverEndOffsetY, serverEndOffsetZ, serverEndLookAtX = unpack(serverCameraTransition);
                local serverEndLookAtY = getEasingValue(math.max(0, math.min(1, (getTickCount() - serverNewCameraX) / serverNewCameraY)), "InOutQuad");
                serverCameraAngle = serverCameraAngle - serverEndLookAtY;
                local serverEndLookAtZ = serverCameraPosX + serverEndLookAtY * (serverTransitionStartTime - serverCameraPosX);
                local serverEasingValue = serverCameraPosY + serverEndLookAtY * (serverTransitionTotalTime - serverCameraPosY);
                local serverInterpolatedAngle = serverCameraPosZ + serverEndLookAtY * (serverEndOffsetX - serverCameraPosZ);
                local serverInterpolatedCameraX = serverTargetX + serverEndLookAtY * (serverEndOffsetY - serverTargetX);
                local serverInterpolatedCameraY = serverTargetY + serverEndLookAtY * (serverEndOffsetZ - serverTargetY);
                local serverInterpolatedCameraZ = serverTargetZ + serverEndLookAtY * (serverEndLookAtX - serverTargetZ);
                setCameraMatrix(serverEndLookAtZ, serverEasingValue, serverInterpolatedAngle, serverInterpolatedCameraX, serverInterpolatedCameraY, serverInterpolatedCameraZ);
                if serverEndLookAtY == 1 then
                    stopCameraPrepair();
                end;
            end;
        elseif serverPrepairData then
            stopCameraPrepair();
        end;
    end;
    onDownloadCompleteingRender = function() 
        if type(notreadyCounter) ~= "number" or notreadyCounter < 3000 then
            local serverInterpolatedTargetX = 30 * math.floor(getTickCount() % 1000 * 0.012);
            dxDrawImage(xscreen * 0.5 - 32, yscreen * 0.5 - 32, 64, 64, "images/loading.png", serverInterpolatedTargetX);
        end;
        if type(notreadyCounter) == "number" then
            if notreadyCounter < 3000 and notreadyCounter + getGameSpeed() * 20 >= 3000 then
                fadeCamera(true, 2);
            end;
            notreadyCounter = notreadyCounter + getGameSpeed() * 20;
            if notreadyCounter >= 5000 then
                notreadyCounter = nil;
                setElementData(localPlayer, "Loading", nil);
                triggerServerEvent("onPlayerMapReady", localPlayer);
            end;
        else
            local serverInterpolatedTargetY, serverInterpolatedTargetZ = getCameraMatrix();
            if not isLineOfSightClear(serverInterpolatedTargetY, serverInterpolatedTargetZ, 1500, serverInterpolatedTargetY, serverInterpolatedTargetZ, -100) or testLineAgainstWater(serverInterpolatedTargetY, serverInterpolatedTargetZ, 1500, serverInterpolatedTargetY, serverInterpolatedTargetZ, -100) then
                notreadyCounter = 0;
            end;
        end;
    end;
    onDownloadComplete = function() 
        local serverMapData = getRoundMapInfo();
        if serverMapData.modename then
            triggerServerEvent("onPlayerMapLoad", localPlayer);
            triggerEvent("onClientMapStarting", root, serverMapData);
        end;
        local serverWeaponPackData = getTacticsData("weaponspack") or {};
        local serverWeaponPackNode = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
        local serverSavedWeapons = fromJSON(xmlNodeGetAttribute(serverWeaponPackNode, "selected") or "[ [ ] ]");
        weaponSave = {};
        local serverSlotLimit = getTacticsData("weapon_slots") or 0;
        local serverSelectedCount = 0;
        for __, serverWeaponName in ipairs(serverSavedWeapons) do
            if serverWeaponPackData[serverWeaponName] and (serverSlotLimit == 0 or serverSelectedCount < serverSlotLimit) then
                weaponSave[serverWeaponName] = true;
                serverSelectedCount = serverSelectedCount + 1;
            end;
        end;
        remakeWeaponsPack();
    end;
    local serverPausedProjectiles = {};
    onClientPauseRender = function() 
        dxDrawRectangle(0, 0, xscreen, yscreen, tocolor(0, 0, 0, 96));
        dxDrawText(getLanguageString("pause"), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(2), "default-bold", "center", "bottom");
        dxDrawText(getLanguageString("pause"), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(0, 128, 255), getFont(2), "default-bold", "center", "bottom");
        local serverUnpauseTimeClient = getTacticsData("Unpause");
        if serverUnpauseTimeClient then
            local serverUnpauseRemaining = serverUnpauseTimeClient - (getTickCount() + addTickCount);
            dxDrawText(string.format(getLanguageString("unpausing_in"), serverUnpauseRemaining / 1000), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(1), "default", "center", "top");
            dxDrawText(string.format(getLanguageString("unpausing_in"), serverUnpauseRemaining / 1000), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 255), getFont(1), "default", "center", "top");
        end;
        local serverPrimaryTask1 = getPedTask(localPlayer, "primary", 1);
        local serverPrimaryTask3 = getPedTask(localPlayer, "primary", 3);
        local serverPrimaryTask4 = getPedTask(localPlayer, "primary", 4);
        for __, serverProjectile in ipairs(getElementsByType("projectile", root, true)) do
            if serverPausedProjectiles[serverProjectile] then
                local serverProjPosX, serverProjPosY, serverProjPosZ, serverProjVelX, serverProjVelY, serverProjVelZ = unpack(serverPausedProjectiles[serverProjectile]);
                setElementPosition(serverProjectile, serverProjPosX, serverProjPosY, serverProjPosZ, false);
                setElementVelocity(serverProjectile, serverProjVelX, serverProjVelY, serverProjVelZ);
            else
                local serverCurrentProjX, serverCurrentProjY, serverCurrentProjZ = getElementPosition(serverProjectile);
                local serverCurrentVelX, serverCurrentVelY, serverCurrentVelZ = getElementVelocity(serverProjectile);
                serverPausedProjectiles[serverProjectile] = {serverCurrentProjX, serverCurrentProjY, serverCurrentProjZ, serverCurrentVelX, serverCurrentVelY, serverCurrentVelZ};
            end;
        end;
        if getElementData(localPlayer, "Status") == "Play" and serverPrimaryTask4 == "TASK_SIMPLE_PLAYER_ON_FOOT" and serverPrimaryTask1 ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and serverPrimaryTask3 ~= "TASK_COMPLEX_JUMP" then
            if not xpause then
                local serverPausedX, serverPausedY, serverPausedZ = getElementPosition(localPlayer);
                zpause = serverPausedZ;
                ypause = serverPausedY;
                xpause = serverPausedX;
                rpause = getPedRotation(localPlayer);
            end;
            setElementPosition(localPlayer, xpause, ypause, zpause, false);
            setPedRotation(localPlayer, rpause);
        elseif xpause then
            xpause = nil;
        end;
    end;
    local serverMessageTitle = "";
    local serverMessageSubtitle = "";
    local serverTitleColor = 4294967295;
    local serverShadowColor = 4278190080;
    local serverTitlePosX = xscreen * 0.5;
    local serverTitlePosY = yscreen * 0.35;
    local serverShadowPosX = xscreen * 0.502;
    local serverShadowPosY = yscreen * 0.352;
    local serverTitleFontSize = getFont(2);
    local serverSubtitleFontSize = getFont(1);
    onClientMessageRender = function() 
        dxDrawText(serverMessageTitle, serverShadowPosX, serverShadowPosY, serverShadowPosX, serverShadowPosY, serverShadowColor, serverTitleFontSize, "default-bold", "center", "bottom");
        dxDrawText(serverMessageTitle, serverTitlePosX, serverTitlePosY, serverTitlePosX, serverTitlePosY, serverTitleColor, serverTitleFontSize, "default-bold", "center", "bottom");
        dxDrawText(serverMessageSubtitle, serverShadowPosX, serverShadowPosY, serverShadowPosX, serverShadowPosY, serverShadowColor, serverSubtitleFontSize, "default", "center", "top");
        dxDrawText(serverMessageSubtitle, serverTitlePosX, serverTitlePosY, serverTitlePosX, serverTitlePosY, 4294967295, serverSubtitleFontSize, "default", "center", "top");
    end;
    onClientPlayerTarget = function(serverTargetVehicle) 
        if serverTargetVehicle and not serverIsVehicleNametagEnabled then
            serverIsVehicleNametagEnabled = true;
            addEventHandler("onClientRender", root, onClientVehicleNametagRender);
        end;
    end;
    local serverHealthBarHeight = yscreen * 0.011;
    local serverHealthBarWidth = xscreen * 0.06;
    local serverHealthBarYOffset = yscreen * 0.025;
    local serverHealthBarBorder = xscreen * 0.003;
    onClientVehicleNametagRender = function() 
        local serverTargetElement = getPedTarget(localPlayer);
        if serverTargetElement and getElementType(serverTargetElement) == "vehicle" then
            local serverTargetPosX, serverTargetPosY, serverTargetPosZ = getElementPosition(serverTargetElement);
            local serverScreenX, serverScreenY = getScreenFromWorldPosition(serverTargetPosX, serverTargetPosY, serverTargetPosZ);
            if serverScreenX then
                local serverHealthRatio = (getElementHealth(serverTargetElement) - 250) / 750;
                if serverHealthRatio < 0 then
                    serverHealthRatio = 0;
                end;
                local serverRedValue = math.floor(512 * (1 - serverHealthRatio));
                local serverGreenValue = math.floor(512 * serverHealthRatio);
                serverRedValue = math.min(math.max(serverRedValue, 0), 255);
                serverGreenValue = math.min(math.max(serverGreenValue, 0), 255);
                dxDrawRectangle(serverScreenX - 0.5 * serverHealthBarWidth - serverHealthBarBorder, serverScreenY - 0.5 * serverHealthBarHeight - serverHealthBarBorder + serverHealthBarYOffset, serverHealthBarWidth + 2 * serverHealthBarBorder, serverHealthBarHeight + 2 * serverHealthBarBorder, tocolor(0, 0, 0, 180));
                dxDrawRectangle(serverScreenX - 0.5 * serverHealthBarWidth + serverHealthBarWidth * serverHealthRatio, serverScreenY - 0.5 * serverHealthBarHeight + serverHealthBarYOffset, (1 - serverHealthRatio) * serverHealthBarWidth, serverHealthBarHeight, tocolor(math.floor(0.33 * serverRedValue), math.floor(0.33 * serverGreenValue), 0, 180));
                dxDrawRectangle(serverScreenX - 0.5 * serverHealthBarWidth, serverScreenY - 0.5 * serverHealthBarHeight + serverHealthBarYOffset, serverHealthBarWidth * serverHealthRatio, serverHealthBarHeight, tocolor(serverRedValue, serverGreenValue, 0, 180));
            end;
        else
            serverIsVehicleNametagEnabled = false;
            removeEventHandler("onClientRender", root, onClientVehicleNametagRender);
        end;
    end;
    forcedChangeTeam = function() 
        if guiGetInputEnabled() then
            return;
        elseif getElementData(localPlayer, "Status") == "Joining" then
            return;
        else
            if getTacticsData("Map") == "lobby" then
                if guiGetVisible(team_window) then
                    guiSetVisible(team_window, false);
                    if isAllGuiHidden() then
                        showCursor(false);
                    end;
                else
                    updateTeamManager();
                    guiBringToFront(team_window);
                    guiSetVisible(team_window, true);
                    showCursor(true);
                end;
            elseif not getElementData(localPlayer, "ChangeTeam") then
                setElementData(localPlayer, "ChangeTeam", true);
                outputChatBox(getLanguageString("team_change_set"), 255, 100, 100);
            else
                setElementData(localPlayer, "ChangeTeam", nil);
                outputChatBox(getLanguageString("team_change_cancel"), 255, 100, 100);
            end;
            return;
        end;
    end;
    onClientWeaponDisable = function() 
        setElementData(localPlayer, "Weapons", nil);
    end;
    onClientElementDataChange = function(serverDataName, serverDataValue) 
        if serverDataName == "Status" and getElementType(source) == "player" then
            triggerEvent("onClientPlayerGameStatusChange", source, serverDataValue);
            triggerEvent("onClientPlayerBlipUpdate", source);
        end;
        if source == localPlayer then
            if serverDataName == "Prepair" then
                if getElementData(localPlayer, "Prepair") and not serverDataValue then
                    serverCameraAngle = nil;
                    serverCameraTransition = nil;
                    addEventHandler("onClientPreRender", root, onClientPrepairRender);
                elseif not getElementData(localPlayer, "Prepair") and serverDataValue then
                    removeEventHandler("onClientPreRender", root, onClientPrepairRender);
                    serverCameraAngle = nil;
                    serverCameraTransition = nil;
                end;
            end;
            if serverDataName == "Weapons" then
                if getElementData(localPlayer, "Weapons") == true then
                    addEventHandler("onClientPlayerWeaponFire", localPlayer, onClientWeaponDisable);
                else
                    removeEventHandler("onClientPlayerWeaponFire", localPlayer, onClientWeaponDisable);
                end;
            end;
            if serverDataName == "Loading" then
                if getElementData(localPlayer, "Loading") and not serverDataValue then
                    notreadyCounter = nil;
                    fadeCamera(false, 0);
                    addEventHandler("onClientRender", root, onDownloadCompleteingRender);
                elseif not getElementData(localPlayer, "Loading") and serverDataValue then
                    removeEventHandler("onClientRender", root, onDownloadCompleteingRender);
                    fadeCamera(true, 0);
                end;
            end;
        end;
        if serverDataName == "Helpme" and source ~= localPlayer then
            local serverHelpmeState = getElementData(source, serverDataName);
            local serverLocalPlayerTeam = getPlayerTeam(localPlayer);
            local serverOtherPlayerTeam = getPlayerTeam(source);
            if serverHelpmeState and serverLocalPlayerTeam and (serverLocalPlayerTeam == getElementsByType("team")[1] or serverLocalPlayerTeam == serverOtherPlayerTeam) then
                if isTimer(helpme[source]) then
                    killTimer(helpme[source]);
                end;
                helpme[source] = setTimer(function(serverHelpmePlayer) 
                    if not isElement(serverHelpmePlayer) or not getElementData(serverHelpmePlayer, "Helpme") then
                        killTimer(helpme[serverHelpmePlayer]);
                    end;
                    if isElement(helpmeArrow[serverHelpmePlayer]) then
                        destroyElement(helpmeArrow[serverHelpmePlayer]);
                    else
                        helpmeArrow[serverHelpmePlayer] = createMarker(0, 0, 0, "arrow", 0.5, 255, 255, 0, 128);
                        attachElements(helpmeArrow[serverHelpmePlayer], serverHelpmePlayer, 0, 0, 2);
                        setElementInterior(helpmeArrow[serverHelpmePlayer], getElementInterior(serverHelpmePlayer));
                        setElementParent(helpmeArrow[serverHelpmePlayer], serverHelpmePlayer);
                        local serverArrowMarker = createBlipAttachedTo(helpmeArrow[serverHelpmePlayer], 0, 2, 255, 255, 0, 255, 1);
                        setElementParent(serverArrowMarker, helpmeArrow[serverHelpmePlayer]);
                    end;
                end, 250, 0, source);
                outputChatBox(string.format(getLanguageString("help_me"), getPlayerName(source)), 255, 100, 100, true);
            else
                if isTimer(helpme[source]) then
                    killTimer(helpme[source]);
                end;
                if isElement(helpmeArrow[source]) then
                    destroyElement(helpmeArrow[source]);
                end;
            end;
        end;
    end;
    onClientTacticsChange = function(serverChangedPath, serverOldValue) 
        if serverChangedPath[1] == "version" then
            local serverVersionText = getTacticsData("version");
            guiSetText(label_version, "Tactics " .. tostring(serverVersionText));
            guiSetText(credits_window, "Tactics " .. tostring(serverVersionText));
            guiSetText(credits_version, "Tactics " .. tostring(serverVersionText));
        end;
        if serverChangedPath[1] == "message" then
            local serverMessageData = getTacticsData("message");
            if serverMessageData then
                serverMessageTitle = "";
                serverMessageSubtitle = "";
                serverTitleColor = 4294967295;
                if type(serverMessageData[1]) == "table" then
                    if type(serverMessageData[1][1]) == "string" then
                        local serverMessageKey = serverMessageData[1][1];
                        local serverMessageArgs = serverMessageData[1];
                        table.remove(serverMessageArgs, 1);
                        if #serverMessageArgs > 0 then
                            serverMessageTitle = string.format(getLanguageString(serverMessageKey), unpack(serverMessageArgs));
                        elseif serverMessageKey then
                            serverMessageTitle = getLanguageString(serverMessageKey);
                        end;
                        if #serverMessageTitle == 0 then
                            serverMessageTitle = tostring(serverMessageKey);
                        end;
                    elseif type(serverMessageData[1][4]) == "string" then
                        local serverColorRed = tonumber(serverMessageData[1][1]);
                        local serverColorGreen = tonumber(serverMessageData[1][2]);
                        local serverColorBlue = tonumber(serverMessageData[1][3]);
                        local serverColorMessageKey = serverMessageData[1][4];
                        local serverColorMessageArgs = serverMessageData[1];
                        serverTitleColor = tocolor(serverColorRed, serverColorGreen, serverColorBlue);
                        if #serverColorMessageArgs > 4 then
                            table.remove(serverColorMessageArgs, 4);
                            table.remove(serverColorMessageArgs, 3);
                            table.remove(serverColorMessageArgs, 2);
                            table.remove(serverColorMessageArgs, 1);
                            serverMessageTitle = string.format(getLanguageString(serverColorMessageKey), unpack(serverColorMessageArgs));
                        elseif serverColorMessageKey then
                            serverMessageTitle = getLanguageString(serverColorMessageKey);
                        end;
                        if #serverMessageTitle == 0 then
                            serverMessageTitle = tostring(serverColorMessageKey);
                        end;
                    end;
                elseif type(serverMessageData[1]) == "string" then
                    serverMessageTitle = getLanguageString(serverMessageData[1]);
                    if #serverMessageTitle == 0 then
                        serverMessageTitle = tostring(serverMessageData[1]);
                    end;
                else
                    serverMessageTitle = tostring(serverMessageData[1]);
                end;
                if type(serverMessageData[2]) == "table" then
                    local serverSubtitleKey = serverMessageData[2][1];
                    local serverSubtitleArgs = serverMessageData[2];
                    table.remove(serverSubtitleArgs, 1);
                    serverMessageSubtitle = string.format(getLanguageString(tostring(serverSubtitleKey)), unpack(serverSubtitleArgs));
                elseif type(serverMessageData[2]) == "string" then
                    serverMessageSubtitle = getLanguageString(serverMessageData[2]);
                    if #serverMessageSubtitle == 0 then
                        serverMessageSubtitle = tostring(serverMessageData[2]);
                    end;
                else
                    serverMessageSubtitle = tostring(serverMessageData[2]);
                end;
                serverMessageTitle = removeColorCoding(serverMessageTitle);
                serverMessageSubtitle = removeColorCoding(serverMessageSubtitle);
            end;
            if serverMessageData and not serverOldValue then
                addEventHandler("onClientRender", root, onClientMessageRender);
            elseif not serverMessageData and serverOldValue then
                removeEventHandler("onClientRender", root, onClientMessageRender);
            end;
        end;
        if serverChangedPath[1] == "Pause" then
            local serverPauseState = getTacticsData("Pause");
            if serverPauseState and not serverOldValue then
                addEventHandler("onClientRender", root, onClientPauseRender);
            elseif not serverPauseState and serverOldValue then
                removeEventHandler("onClientRender", root, onClientPauseRender);
                xpause = nil;
            end;
        end;
        if serverChangedPath[1] == "weaponspack" or serverChangedPath[1] == "weapon_balance" or serverChangedPath[1] == "weapon_cost" then
            remakeWeaponsPack();
        end;
        if serverChangedPath[1] == "weapon_slots" then
            local serverWeaponSlotLimit = getTacticsData("weapon_slots") or 0;
            if serverWeaponSlotLimit > 0 then
                local serverSelectedWeaponCount = 0;
                if isElement(weapon_window) then
                    guiSetText(weapon_slots, "You can choice " .. serverWeaponSlotLimit .. " weapons");
                    for __, serverWeaponItemData in ipairs(weapon_items) do
                        if guiGetProperty(serverWeaponItemData.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            serverSelectedWeaponCount = serverSelectedWeaponCount + 1;
                            if serverWeaponSlotLimit < serverSelectedWeaponCount then
                                guiSetProperty(serverWeaponItemData.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                                weaponSave[guiGetText(serverWeaponItemData.name)] = nil;
                            end;
                        end;
                    end;
                else
                    for serverSavedWeaponKey in pairs(weaponSave) do
                        serverSelectedWeaponCount = serverSelectedWeaponCount + 1;
                        if serverWeaponSlotLimit < serverSelectedWeaponCount then
                            weaponSave[serverSavedWeaponKey] = nil;
                        end;
                    end;
                end;
                if serverWeaponSlotLimit < serverSelectedWeaponCount then
                    updateSaveWeapons();
                end;
            elseif isElement(weapon_window) then
                guiSetText(weapon_slots, "You can choice any weapons");
            end;
        end;
        if serverChangedPath[1] == "settings" then
            if serverChangedPath[2] == "ghostmode" then
                local serverGhostMode = getTacticsData("settings", "ghostmode");
                if serverGhostMode == "all" or serverGhostMode == "team" then
                    setCameraClip(true, false);
                else
                    setCameraClip(true, true);
                end;
                for __, serverPlayerA in ipairs(getElementsByType("player", root, true)) do
                    for __, serverOtherPlayerA in ipairs(getElementsByType("player", root, true)) do
                        if serverGhostMode == "all" then
                            setElementCollidableWith(serverPlayerA, serverOtherPlayerA, false);
                        elseif serverGhostMode == "team" and getPlayerTeam(serverPlayerA) == getPlayerTeam(serverOtherPlayerA) then
                            setElementCollidableWith(serverPlayerA, serverOtherPlayerA, false);
                        else
                            setElementCollidableWith(serverPlayerA, serverOtherPlayerA, true);
                        end;
                    end;
                end;
                for __, serverVehicle1 in ipairs(getElementsByType("vehicle", root, true)) do
                    for __, serverVehicle2 in ipairs(getElementsByType("vehicle", root, true)) do
                        if serverGhostMode == "all" then
                            setElementCollidableWith(serverVehicle1, serverVehicle2, false);
                        elseif serverGhostMode == "team" and getVehicleController(serverVehicle1) and getVehicleController(serverVehicle2) and getPlayerTeam(getVehicleController(serverVehicle1)) == getPlayerTeam(getVehicleController(serverVehicle2)) then
                            setElementCollidableWith(serverVehicle1, serverVehicle2, false);
                        else
                            setElementCollidableWith(serverVehicle1, serverVehicle2, true);
                        end;
                    end;
                end;
            end;
            if serverChangedPath[2] == "time" then
                updateWeather();
            end;
            if serverChangedPath[2] == "time_minuteduration" then
                updateWeather();
            end;
            if serverChangedPath[2] == "gravity" then
                setGravity(tonumber(getTacticsData("settings", "gravity")));
            end;
            if serverChangedPath[2] == "player_radarblip" or serverChangedPath[2] == "player_nametag" then
                triggerEvent("onClientPlayerBlipUpdate", localPlayer);
            end;
            if serverChangedPath[2] == "blurlevel" then
                setBlurLevel(tonumber(getTacticsData("settings", "blurlevel")) or 36);
            end;
            if serverChangedPath[2] == "heli_killing" then
                if getTacticsData("settings", "heli_killing") == "false" then
                    addEventHandler("onClientPlayerHeliKilled", root, cancelEvent);
                    addEventHandler("onClientPedHeliKilled", root, cancelEvent);
                else
                    removeEventHandler("onClientPlayerHeliKilled", root, cancelEvent);
                    removeEventHandler("onClientPedHeliKilled", root, cancelEvent);
                end;
            end;
            if serverChangedPath[2] == "stealth_killing" then
                if getTacticsData("settings", "stealth_killing") == "false" then
                    addEventHandler("onClientPlayerStealthKill", localPlayer, cancelEvent);
                else
                    removeEventHandler("onClientPlayerStealthKill", localPlayer, cancelEvent);
                end;
            end;
            if serverChangedPath[2] == "vehicle_radarblip" then
                local serverVehicleBlipMode = getTacticsData("settings", "vehicle_radarblip");
                for __, serverVehicleForBlip in ipairs(getElementsByType("vehicle")) do
                    local serverVehicleBlipElement = getElementData(serverVehicleForBlip, "Blip");
                    if serverVehicleBlipElement then
                        local serverBlipRed = 0;
                        local serverBlipGreen = 0;
                        local serverBlipBlue = 0;
                        local serverBlipAlpha = 0;
                        if serverVehicleBlipMode == "always" then
                            local serverDefaultRed = 128;
                            local serverDefaultGreen = 128;
                            local serverDefaultBlue = 128;
                            serverBlipAlpha = 128;
                            serverBlipBlue = serverDefaultBlue;
                            serverBlipGreen = serverDefaultGreen;
                            serverBlipRed = serverDefaultRed;
                        elseif serverVehicleBlipMode == "unoccupied" then
                            local serverHasOccupants = false;
                            local serverVehicleOccupants = getVehicleOccupants(serverVehicleForBlip);
                            for serverSeatIndex = 0, getVehicleMaxPassengers(serverVehicleForBlip) do
                                if serverVehicleOccupants[serverSeatIndex] then
                                    serverHasOccupants = true;
                                    break;
                                end;
                            end;
                            if not serverHasOccupants and not getVehicleController(serverVehicleForBlip) then
                                local serverUnoccupiedRed = 128;
                                local serverUnoccupiedGreen = 128;
                                local serverUnoccupiedBlue = 128;
                                serverBlipAlpha = 128;
                                serverBlipBlue = serverUnoccupiedBlue;
                                serverBlipGreen = serverUnoccupiedGreen;
                                serverBlipRed = serverUnoccupiedRed;
                            end;
                        end;
                        setBlipColor(serverVehicleBlipElement, serverBlipRed, serverBlipGreen, serverBlipBlue, serverBlipAlpha);
                    end;
                end;
            end;
            if serverChangedPath[2] == "vehicle_nametag" then
                if getTacticsData("settings", "vehicle_nametag") == "true" then
                    addEventHandler("onClientPlayerTarget", localPlayer, onClientPlayerTarget);
                else
                    if serverIsVehicleNametagEnabled then
                        serverIsVehicleNametagEnabled = false;
                        removeEventHandler("onClientRender", root, onClientVehicleNametagRender);
                    end;
                    removeEventHandler("onClientPlayerTarget", localPlayer, onClientPlayerTarget);
                end;
            end;
        end;
        if serverChangedPath[1] == "MapName" then
            guiSetText(mapstring, tostring(getTacticsData("MapName", false)));
        end;
        if serverChangedPath[1] == "Weather" then
            updateWeatherBlend();
            updateWeather(true);
        end;
    end;
    onClientElementStreamIn = function() 
        if getElementType(source) == "player" then
            local serverStreamedGhostMode = getTacticsData("settings", "ghostmode");
            for __, serverOtherStreamedPlayer in ipairs(getElementsByType("player", root, true)) do
                if serverStreamedGhostMode == "all" then
                    setElementCollidableWith(serverOtherStreamedPlayer, source, false);
                    setElementCollidableWith(source, serverOtherStreamedPlayer, false);
                elseif serverStreamedGhostMode == "team" and getPlayerTeam(serverOtherStreamedPlayer) == getPlayerTeam(source) then
                    setElementCollidableWith(serverOtherStreamedPlayer, source, false);
                    setElementCollidableWith(source, serverOtherStreamedPlayer, false);
                else
                    setElementCollidableWith(serverOtherStreamedPlayer, source, true);
                    setElementCollidableWith(source, serverOtherStreamedPlayer, true);
                end;
            end;
        end;
        if getElementType(source) == "vehicle" then
            local serverVehicleGhostMode = getTacticsData("settings", "ghostmode");
            for __, serverOtherStreamedVehicle in ipairs(getElementsByType("vehicle", root, true)) do
                if serverVehicleGhostMode == "all" then
                    setElementCollidableWith(serverOtherStreamedVehicle, source, false);
                    setElementCollidableWith(source, serverOtherStreamedVehicle, false);
                elseif serverVehicleGhostMode == "all" and getVehicleController(serverOtherStreamedVehicle) and getVehicleController(source) and getElementType(getVehicleController(serverOtherStreamedVehicle)) == "player" and getElementType(getVehicleController(source)) == "player" and getPlayerTeam(getVehicleController(serverOtherStreamedVehicle)) == getPlayerTeam(getVehicleController(source)) then
                    setElementCollidableWith(serverOtherStreamedVehicle, source, false);
                    setElementCollidableWith(source, serverOtherStreamedVehicle, false);
                else
                    setElementCollidableWith(serverOtherStreamedVehicle, source, true);
                    setElementCollidableWith(source, serverOtherStreamedVehicle, true);
                end;
            end;
            if not getElementData(source, "Blip") then
                local serverVehicleBlipSetting = getTacticsData("settings", "vehicle_radarblip");
                local serverVehicleBlipR = 0;
                local serverVehicleBlipG = 0;
                local serverVehicleBlipB = 0;
                local serverVehicleBlipA = 0;
                if serverVehicleBlipSetting == "always" then
                    local serverAlwaysRed = 128;
                    local serverAlwaysGreen = 128;
                    local serverAlwaysBlue = 128;
                    serverVehicleBlipA = 128;
                    serverVehicleBlipB = serverAlwaysBlue;
                    serverVehicleBlipG = serverAlwaysGreen;
                    serverVehicleBlipR = serverAlwaysRed;
                elseif serverVehicleBlipSetting == "unoccupied" then
                    local serverIsOccupied = false;
                    local serverStreamedOccupants = getVehicleOccupants(source);
                    for serverOccupantSeat = 0, getVehicleMaxPassengers(source) do
                        if serverStreamedOccupants[serverOccupantSeat] then
                            serverIsOccupied = true;
                            break;
                        end;
                    end;
                    if not serverIsOccupied and not getVehicleController(source) then
                        local serverUnoccupiedR = 128;
                        local serverUnoccupiedG = 128;
                        local serverUnoccupiedB = 128;
                        serverVehicleBlipA = 128;
                        serverVehicleBlipB = serverUnoccupiedB;
                        serverVehicleBlipG = serverUnoccupiedG;
                        serverVehicleBlipR = serverUnoccupiedR;
                    end;
                end;
                local serverStreamedBlip = createBlipAttachedTo(source, 0, 0, serverVehicleBlipR, serverVehicleBlipG, serverVehicleBlipB, serverVehicleBlipA, -1);
                setElementData(source, "Blip", serverStreamedBlip, false);
                setElementParent(serverStreamedBlip, source);
            end;
            local serverTankExplodable = getTacticsData("settings", "vehicle_tank_explodable") == "true";
            setVehicleFuelTankExplodable(source, serverTankExplodable);
        end;
    end;
    onClientGUIClick = function(serverMouseButton, __, __, __) 
        if serverMouseButton ~= "left" then
            return;
        else
            if source == weapon_accept then
                guiSetVisible(weapon_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                if not getElementData(localPlayer, "Weapons") then
                    if guiCheckBoxGetSelected(config_performance_weapmanager) then
                        destroyElement(weapon_window);
                    end;
                    return outputChatBox(getLanguageString("weapon_choice_disabled"), 255, 100, 100);
                else
                    local serverSelectedWeapons = {};
                    local serverWeaponPack = getTacticsData("weaponspack") or {};
                    for serverWeaponKey in pairs(weaponSave) do
                        local serverWeaponId = convertWeaponNamesToID[serverWeaponKey];
                        local serverWeaponAmmo = tonumber(serverWeaponPack[serverWeaponKey]) or 0;
                        table.insert(serverSelectedWeapons, {id = serverWeaponId, ammo = math.max(serverWeaponAmmo, 1), name = serverWeaponKey});
                    end;
                    callServerFunction("onPlayerWeaponpackChose", localPlayer, serverSelectedWeapons);
                    if guiCheckBoxGetSelected(config_performance_weapmanager) then
                        destroyElement(weapon_window);
                    end;
                end;
            end;
            if source == weapon_close then
                guiSetVisible(weapon_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                if guiCheckBoxGetSelected(config_performance_weapmanager) then
                    destroyElement(weapon_window);
                end;
            end;
            if source == team_close then
                guiSetVisible(team_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if guiGetVisible(team_window) then
                for __, serverClickedTeamButton in ipairs(team_button) do
                    if source == serverClickedTeamButton then
                        local serverSelectedTeam = getTeamFromName(tostring(guiGetText(source)));
                        local serverTeamSkin = (getElementData(serverSelectedTeam, "Skins") or {
                            71
                        })[1];
                        triggerServerEvent("onPlayerTeamSelect", localPlayer, serverSelectedTeam, serverTeamSkin);
                        guiSetVisible(team_window, false);
                        if isAllGuiHidden() then
                            showCursor(false);
                            break;
                        else
                            break;
                        end;
                    end;
                end;
            end;
            if source == team_specskinbtn then
                guiCheckBoxSetSelected(team_specskin, not guiCheckBoxGetSelected(team_specskin));
                setElementData(localPlayer, "spectateskin", guiCheckBoxGetSelected(team_specskin));
            end;
            if source == team_specskin then
                setElementData(localPlayer, "spectateskin", guiCheckBoxGetSelected(team_specskin));
            end;
            if source == team_joining then
                callServerFunction("warpPlayerToJoining", localPlayer);
                guiSetVisible(team_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if source == vehicle_car or source == vehicle_bike or source == vehicle_plane or source == vehicle_heli or source == vehicle_boat then
                updateVehicleList();
            end;
            if source == vehicle_getvehicle then
                local serverSelectedVehicleIndex = guiGridListGetSelectedItem(vehicle_list);
                if serverSelectedVehicleIndex ~= -1 then
                    local serverVehicleModelId = getVehicleModelFromName(guiGridListGetItemText(vehicle_list, serverSelectedVehicleIndex, 1));
                    if serverVehicleModelId then
                        local serverVehicleHeightOffset = nil;
                        local serverCurrentVehicle = getPedOccupiedVehicle(localPlayer);
                        if serverCurrentVehicle then
                            serverVehicleHeightOffset = getElementDistanceFromCentreOfMassToBaseOfModel(serverCurrentVehicle);
                        end;
                        callServerFunction("onPlayerVehicleSelect", localPlayer, serverVehicleModelId, serverVehicleHeightOffset);
                        guiSetVisible(vehicle_window, false);
                        if isAllGuiHidden() then
                            showCursor(false);
                        end;
                        if guiCheckBoxGetSelected(config_performance_vehmanager) then
                            destroyElement(vehicle_window);
                        end;
                    end;
                end;
            end;
            if source == vehicle_close then
                guiSetVisible(vehicle_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                if guiCheckBoxGetSelected(config_performance_vehmanager) then
                    destroyElement(vehicle_window);
                end;
            end;
            if source == credits_close then
                guiSetVisible(credits_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if source == weapon_memory then
                if guiCheckBoxGetSelected(weapon_memory) then
                    weaponMemory = true;
                    local serverSortedWeapons = {};
                    for __, serverSelectedWeaponItem in ipairs(weapon_items) do
                        if guiGetProperty(serverSelectedWeaponItem.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            table.insert(serverSortedWeapons, guiGetText(serverSelectedWeaponItem.name));
                        end;
                    end;
                    if #serverSortedWeapons > 1 then
                        table.sort(serverSortedWeapons, function(serverWeaponA, serverWeaponB) 
                            return serverWeaponA < serverWeaponB;
                        end);
                    end;
                    local serverWeaponXmlNode = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
                    xmlNodeSetAttribute(serverWeaponXmlNode, "selected", toJSON(serverSortedWeapons));
                else
                    weaponMemory = false;
                    local serverOldWeaponNode = xmlFindChild(_client, "weaponpack", 0);
                    if serverOldWeaponNode then
                        xmlDestroyNode(serverOldWeaponNode);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if isElement(weapon_window) and guiGetVisible(weapon_window) then
                local serverWeaponClicked = false;
                for __, serverClickedWeaponItem in ipairs(weapon_items) do
                    if source == serverClickedWeaponItem.gui then
                        local serverWeaponSlotInfo = getTacticsData("weapon_slot") or {};
                        serverWeaponClicked = true;
                        local serverClickedWeaponName = guiGetText(serverClickedWeaponItem.name);
                        if guiGetProperty(serverClickedWeaponItem.gui, "ImageColours") ~= "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            local serverClickedWeaponId = convertWeaponNamesToID[serverClickedWeaponName];
                            local serverWeaponSlotNumber = tonumber(serverWeaponSlotInfo[serverClickedWeaponName]) or serverClickedWeaponId and getSlotFromWeapon(serverClickedWeaponId) or 13;
                            for __, serverConflictWeaponItem in ipairs(weapon_items) do
                                if guiGetProperty(serverConflictWeaponItem.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                                    local serverOtherWeaponName = guiGetText(serverConflictWeaponItem.name);
                                    local serverOtherWeaponId = convertWeaponNamesToID[serverOtherWeaponName];
                                    if serverWeaponSlotNumber == (tonumber(serverWeaponSlotInfo[serverOtherWeaponName]) or serverOtherWeaponId and getSlotFromWeapon(serverOtherWeaponId) or 13) then
                                        guiSetProperty(serverConflictWeaponItem.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                                        weaponSave[serverOtherWeaponName] = nil;
                                    end;
                                end;
                            end;
                            local serverCurrentSlotLimit = getTacticsData("weapon_slots") or 0;
                            local serverCurrentSelectedCount = 0;
                            for __ in pairs(weaponSave) do
                                serverCurrentSelectedCount = serverCurrentSelectedCount + 1;
                            end;
                            if serverCurrentSlotLimit == 0 or serverCurrentSelectedCount < serverCurrentSlotLimit then
                                guiSetProperty(serverClickedWeaponItem.gui, "ImageColours", "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF");
                                weaponSave[serverClickedWeaponName] = true;
                                break;
                            else
                                break;
                            end;
                        elseif guiGetProperty(serverClickedWeaponItem.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            guiSetProperty(serverClickedWeaponItem.gui, "ImageColours", "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF");
                            weaponSave[serverClickedWeaponName] = nil;
                            break;
                        else
                            break;
                        end;
                    end;
                end;
                if serverWeaponClicked then
                    updateSaveWeapons();
                end;
            end;
            return;
        end;
    end;
    updateSaveWeapons = function() 
        local serverSavedWeaponsNode = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
        local serverOldSavedWeapons = fromJSON(xmlNodeGetAttribute(serverSavedWeaponsNode, "selected") or "[ [ ] ]");
        local serverNewSavedWeapons = {};
        for serverSavedWeaponKey2, __ in pairs(weaponSave) do
            table.insert(serverNewSavedWeapons, serverSavedWeaponKey2);
        end;
        if #serverNewSavedWeapons > 1 then
            table.sort(serverNewSavedWeapons, function(serverWeaponNameA, serverWeaponNameB) 
                return serverWeaponNameA < serverWeaponNameB;
            end);
        end;
        local serverIsSameSelection = true;
        for serverOldIndex, serverOldWeaponName in ipairs(serverOldSavedWeapons) do
            if serverOldWeaponName ~= serverNewSavedWeapons[serverOldIndex] then
                serverIsSameSelection = false;
                break;
            end;
        end;
        if #serverOldSavedWeapons ~= #serverNewSavedWeapons or #serverOldSavedWeapons == 0 then
            serverIsSameSelection = false;
        end;
        weaponMemory = serverIsSameSelection;
        if isElement(weapon_window) then
            guiCheckBoxSetSelected(weapon_memory, serverIsSameSelection);
        end;
    end;
    onClientGUIDoubleClick = function(serverDoubleClickButton, __, __, __) 
        if serverDoubleClickButton ~= "left" then
            return;
        else
            if source == vehicle_list then
                local serverSelectedGridItem = guiGridListGetSelectedItem(vehicle_list);
                if serverSelectedGridItem ~= -1 then
                    local serverDoubleClickModelId = getVehicleModelFromName(guiGridListGetItemText(vehicle_list, serverSelectedGridItem, 1));
                    if serverDoubleClickModelId then
                        local serverVehicleHeight = nil;
                        local serverCurrentPlayerVehicle = getPedOccupiedVehicle(localPlayer);
                        if serverCurrentPlayerVehicle then
                            serverVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(serverCurrentPlayerVehicle);
                        end;
                        callServerFunction("onPlayerVehicleSelect", localPlayer, serverDoubleClickModelId, serverVehicleHeight);
                        guiSetVisible(vehicle_window, false);
                        if isAllGuiHidden() then
                            showCursor(false);
                        end;
                        if guiCheckBoxGetSelected(config_performance_vehmanager) then
                            destroyElement(vehicle_window);
                        end;
                    end;
                end;
            end;
            return;
        end;
    end;
    onClientGUIChanged = function(__) 
        if source == vehicle_search then
            updateVehicleList();
        end;
    end;
    onClientMouseEnter = function(__, __) 
        if isElement(weapon_window) and guiGetVisible(weapon_window) then
            for __, serverHoveredWeaponItem in ipairs(weapon_items) do
                if source == serverHoveredWeaponItem.gui then
                    if guiGetProperty(serverHoveredWeaponItem.gui, "ImageColours") == "tl:00000000 tr:00000000 bl:00000000 br:00000000" then
                        guiSetProperty(serverHoveredWeaponItem.gui, "ImageColours", "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF");
                    end;
                    local serverHoveredWeaponName = guiGetText(serverHoveredWeaponItem.name);
                    local serverHoveredWeaponId = convertWeaponNamesToID[serverHoveredWeaponName] or 0;
                    local serverWeaponDescription = "Name: " .. serverHoveredWeaponName;
                    local __ = "-";
                    if serverHoveredWeaponName == "grenade" or serverHoveredWeaponName == "satchel" or serverHoveredWeaponName == "rocket" or serverHoveredWeaponName == "headseek" then
                        serverWeaponDescription = serverWeaponDescription .. "\nDamage: explosion";
                    elseif serverHoveredWeaponName == "teargas" or serverHoveredWeaponName == "spray" or serverHoveredWeaponName == "fireextinguisher" then
                        serverWeaponDescription = serverWeaponDescription .. "\nDamage: gas";
                    elseif serverHoveredWeaponName == "flame" or serverHoveredWeaponName == "molotov" then
                        serverWeaponDescription = serverWeaponDescription .. "\nDamage: fire";
                    elseif serverHoveredWeaponId >= 22 and serverHoveredWeaponId <= 39 and getWeaponProperty(serverHoveredWeaponId, "pro", "damage") then
                        if serverHoveredWeaponName == "shotgun" or serverHoveredWeaponName == "sawnoff" then
                            serverWeaponDescription = serverWeaponDescription .. "\nDamage: " .. string.format("shot %.1f ~ %.1f hp", getWeaponProperty(serverHoveredWeaponId, "pro", "damage") / 3, getWeaponProperty(serverHoveredWeaponId, "pro", "damage") * 5);
                        elseif serverHoveredWeaponName == "spas12" then
                            serverWeaponDescription = serverWeaponDescription .. "\nDamage: " .. string.format("shot %.1f ~ %.1f hp", getWeaponProperty(serverHoveredWeaponId, "pro", "damage") / 3, getWeaponProperty(serverHoveredWeaponId, "pro", "damage") * 2.66);
                        else
                            serverWeaponDescription = serverWeaponDescription .. "\nDamage: " .. string.format("bullet %.1f hp", getWeaponProperty(serverHoveredWeaponId, "pro", "damage") / 3);
                        end;
                    else
                        serverWeaponDescription = serverWeaponDescription .. "\nDamage: -";
                    end;
                    if serverHoveredWeaponId >= 22 and serverHoveredWeaponId <= 39 then
                        local serverAnimStart = getWeaponProperty(serverHoveredWeaponId, "pro", "anim_loop_start");
                        local serverAnimStop = getWeaponProperty(serverHoveredWeaponId, "pro", "anim_loop_stop");
                        if serverAnimStart and serverAnimStop then
                            serverWeaponDescription = serverWeaponDescription .. "\nFire Rate: " .. math.floor(60 / (serverAnimStop - serverAnimStart)) .. " r/min";
                        end;
                        if getWeaponProperty(serverHoveredWeaponId, "pro", "weapon_range") then
                            serverWeaponDescription = serverWeaponDescription .. "\nRange: " .. math.floor(getWeaponProperty(serverHoveredWeaponId, "pro", "weapon_range")) .. " m";
                        end;
                    end;
                    guiSetText(weapon_properties, serverWeaponDescription);
                end;
            end;
        end;
    end;
    onClientMouseLeave = function(__, __) 
        if isElement(weapon_window) and guiGetVisible(weapon_window) then
            for __, serverLeftWeaponItem in ipairs(weapon_items) do
                if source == serverLeftWeaponItem.gui then
                    if guiGetProperty(serverLeftWeaponItem.gui, "ImageColours") == "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF" then
                        guiSetProperty(serverLeftWeaponItem.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    end;
                    guiSetText(weapon_properties, "");
                end;
            end;
        end;
    end;
    toggleVehicleManager = function(__, serverVehicleModelArg) 
        if serverVehicleModelArg then
            if getVehicleModelFromName(serverVehicleModelArg) then
                serverVehicleModelArg = getVehicleModelFromName(serverVehicleModelArg);
            else
                serverVehicleModelArg = math.floor(tonumber(serverVehicleModelArg));
            end;
            if not (getTacticsData("disabled_vehicles") or {})[serverVehicleModelArg] and serverVehicleModelArg >= 400 and serverVehicleModelArg <= 611 then
                local serverCurrentVehicleHeight = nil;
                local serverOccupiedVehicle = getPedOccupiedVehicle(localPlayer);
                if serverOccupiedVehicle then
                    serverCurrentVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(serverOccupiedVehicle);
                end;
                callServerFunction("onPlayerVehicleSelect", localPlayer, serverVehicleModelArg, serverCurrentVehicleHeight);
                if isElement(vehicle_window) and guiGetVisible(vehicle_window) then
                    guiSetVisible(vehicle_window, false);
                    if isAllGuiHidden() then
                        showCursor(false);
                    end;
                    if guiCheckBoxGetSelected(config_performance_vehmanager) then
                        destroyElement(vehicle_window);
                    end;
                end;
            elseif not isElement(vehicle_window) or not guiGetVisible(vehicle_window) then
                if not isElement(vehicle_window) then
                    createVehicleManager();
                end;
                guiBringToFront(vehicle_window);
                guiSetVisible(vehicle_window, true);
                showCursor(true);
            elseif isElement(vehicle_window) and guiGetVisible(vehicle_window) then
                guiSetVisible(vehicle_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                if guiCheckBoxGetSelected(config_performance_vehmanager) then
                    destroyElement(vehicle_window);
                end;
            end;
        elseif not isElement(vehicle_window) or not guiGetVisible(vehicle_window) then
            if not isElement(vehicle_window) then
                createVehicleManager();
            end;
            guiBringToFront(vehicle_window);
            guiSetVisible(vehicle_window, true);
            showCursor(true);
        elseif isElement(vehicle_window) and guiGetVisible(vehicle_window) then
            guiSetVisible(vehicle_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            if guiCheckBoxGetSelected(config_performance_vehmanager) then
                destroyElement(vehicle_window);
            end;
        end;
    end;
    updateVehicleList = function() 
        local serverShowCars = guiCheckBoxGetSelected(vehicle_car);
        local serverShowBikes = guiCheckBoxGetSelected(vehicle_bike);
        local serverShowPlanes = guiCheckBoxGetSelected(vehicle_plane);
        local serverShowHelicopters = guiCheckBoxGetSelected(vehicle_heli);
        local serverShowBoats = guiCheckBoxGetSelected(vehicle_boat);
        local serverSearchText = guiGetText(vehicle_search);
        local serverDisabledVehicles = getTacticsData("disabled_vehicles") or {};
        local serverFilteredVehicles = {};
        for serverVehicleId = 400, 611 do
            local serverVehicleName = getVehicleNameFromModel(serverVehicleId);
            if not serverDisabledVehicles[serverVehicleId] and #serverVehicleName > 0 then
                local serverIsVisibleType = false;
                local serverVehicleType = getVehicleType(serverVehicleId);
                if serverShowCars and (serverVehicleType == "Automobile" or serverVehicleType == "Monster Truck") then
                    serverIsVisibleType = true;
                end;
                if serverShowBikes and (serverVehicleType == "Bike" or serverVehicleType == "BMX" or serverVehicleType == "Quad") then
                    serverIsVisibleType = true;
                end;
                if serverShowPlanes and serverVehicleType == "Plane" then
                    serverIsVisibleType = true;
                end;
                if serverShowHelicopters and serverVehicleType == "Helicopter" then
                    serverIsVisibleType = true;
                end;
                if serverShowBoats and serverVehicleType == "Boat" then
                    serverIsVisibleType = true;
                end;
                if #serverSearchText > 0 then
                    for serverSearchTerm in string.gmatch(serverSearchText, "[^ ]+") do
                        if string.sub(serverSearchTerm, 1, 1) == "-" then
                            serverSearchTerm = string.sub(serverSearchTerm, 2, -1);
                            if string.find(tostring(serverVehicleId), serverSearchTerm) or string.find(string.lower(serverVehicleName), string.lower(serverSearchTerm)) then
                                serverIsVisibleType = false;
                            end;
                        elseif not string.find(tostring(serverVehicleId), serverSearchTerm) and not string.find(string.lower(serverVehicleName), string.lower(serverSearchTerm)) then
                            serverIsVisibleType = false;
                        end;
                    end;
                end;
                if serverIsVisibleType then
                    table.insert(serverFilteredVehicles, {serverVehicleId, serverVehicleName});
                end;
            end;
        end;
        table.sort(serverFilteredVehicles, function(serverVehicleAInfo, serverVehicleBInfo) 
            return serverVehicleAInfo[2] < serverVehicleBInfo[2];
        end);
        guiGridListClear(vehicle_list);
        for __, serverVehicleInfo in ipairs(serverFilteredVehicles) do
            local serverRowIndex = guiGridListAddRow(vehicle_list);
            guiGridListSetItemText(vehicle_list, serverRowIndex, 1, serverVehicleInfo[2], false, false);
        end;
    end;
    toggleWeaponManager = function(serverToggleParam) 
        if (not isElement(weapon_window) or not guiGetVisible(weapon_window)) and serverToggleParam ~= false or serverToggleParam == true then
            if isElement(weapon_window) and serverToggleParam == true and guiCheckBoxGetSelected(weapon_memory) and not guiGetVisible(weapon_window) then
                triggerEvent("onClientGUIClick", weapon_accept, "left", "up", 0, 0);
                return;
            elseif not isElement(weapon_window) and serverToggleParam == true and weaponMemory then
                if not getElementData(localPlayer, "Weapons") then
                    return outputChatBox(getLanguageString("weapon_choice_disabled"), 255, 100, 100);
                else
                    local serverQuickWeapons = {};
                    local serverQuickWeaponPack = getTacticsData("weaponspack") or {};
                    for serverQuickWeaponKey in pairs(weaponSave) do
                        local serverQuickWeaponId = convertWeaponNamesToID[serverQuickWeaponKey];
                        local serverQuickWeaponAmmo = tonumber(serverQuickWeaponPack[serverQuickWeaponKey]) or 0;
                        table.insert(serverQuickWeapons, {id = serverQuickWeaponId, ammo = math.max(serverQuickWeaponAmmo, 1), name = serverQuickWeaponKey});
                    end;
                    callServerFunction("onPlayerWeaponpackChose", localPlayer, serverQuickWeapons);
                    return;
                end;
            else
                if isElement(weapon_window) then
                    for __, serverWeaponGuiItem in ipairs(weapon_items) do
                        if guiGetProperty(serverWeaponGuiItem.gui, "ImageColours") == "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF" then
                            guiSetProperty(serverWeaponGuiItem.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                        end;
                    end;
                    guiSetText(weapon_properties, "");
                else
                    createWeaponManager();
                end;
                guiBringToFront(weapon_window);
                guiSetVisible(weapon_window, true);
                showCursor(true);
            end;
        else
            guiSetVisible(weapon_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            if guiCheckBoxGetSelected(config_performance_weapmanager) then
                destroyElement(weapon_window);
            end;
        end;
    end;
    onClientPauseToggle = function(serverIsPaused) 
        for __, serverSound in ipairs(getElementsByType("sound")) do
            setSoundPaused(serverSound, serverIsPaused);
        end;
        if serverIsPaused then
            serverPausedProjectiles = {};
            for __, serverPausedProjectile in ipairs(getElementsByType("projectile")) do
                local serverPausedProjX, serverPausedProjY, serverPausedProjZ = getElementPosition(serverPausedProjectile);
                local serverPausedVelX, serverPausedVelY, serverPausedVelZ = getElementVelocity(serverPausedProjectile);
                serverPausedProjectiles[serverPausedProjectile] = {serverPausedProjX, serverPausedProjY, serverPausedProjZ, serverPausedVelX, serverPausedVelY, serverPausedVelZ};
            end;
        end;
        if getElementData(localPlayer, "Status") == "Play" then
            local serverControlList = {
                "fire", 
                "next_weapon", 
                "previous_weapon", 
                "forwards", 
                "backwards", 
                "left", 
                "right", 
                "zoom_in", 
                "zoom_out", 
                "change_camera", 
                "jump", 
                "sprint", 
                "look_behind", 
                "crouch", 
                "action", 
                "walk", 
                "aim_weapon", 
                "enter_exit", 
                "vehicle_fire", 
                "vehicle_secondary_fire", 
                "vehicle_left", 
                "vehicle_right", 
                "steer_forward", 
                "steer_back", 
                "accelerate", 
                "brake_reverse", 
                "radio_next", 
                "radio_previous", 
                "radio_user_track_skip", 
                "horn", 
                "sub_mission", 
                "handbrake", 
                "vehicle_look_left", 
                "vehicle_look_right", 
                "vehicle_look_behind", 
                "vehicle_mouse_look", 
                "special_control_left", 
                "special_control_right", 
                "special_control_down", 
                "special_control_up", "enter_passenger"
            };
            if serverIsPaused then
                local serverActiveControls = {};
                for __, serverControl in ipairs(serverControlList) do
                    if getPedControlState(serverControl) and serverControl ~= "fire" and serverControl ~= "vehicle_fire" and serverControl ~= "vehicle_secondary_fire" and serverControl ~= "enter_exit" then
                        table.insert(serverActiveControls, serverControl);
                    end;
                end;
                toggleAllControls(false, true, false);
                toggleControl("enter_passenger", false);
                for __, serverActiveControl in ipairs(serverActiveControls) do
                    setPedControlState(serverActiveControl, true);
                end;
            else
                toggleAllControls(true);
                for __, serverControlToCheck in ipairs(serverControlList) do
                    local serverBoundKeys = getBoundKeys(serverControlToCheck) or {};
                    local serverIsKeyPressed = false;
                    for serverKeyName, __ in pairs(serverBoundKeys) do
                        if getKeyState(serverKeyName) then
                            serverIsKeyPressed = true;
                            break;
                        end;
                    end;
                    setPedControlState(serverControlToCheck, serverIsKeyPressed);
                end;
            end;
        end;
    end;
    remakeWeaponsPack = function() 
        if not isElement(weapon_window) then
            return;
        else
            local serverWeaponAmmoData = getTacticsData("weaponspack") or {};
            local serverWeaponBalanceData = getTacticsData("weapon_balance") or {};
            if not getTacticsData("weapon_cost") then
                local __ = {};
            end;
            local serverSortedWeaponList = {};
            for serverWeaponEntry in pairs(serverWeaponAmmoData) do
                if serverWeaponEntry ~= nil then
                    table.insert(serverSortedWeaponList, serverWeaponEntry);
                end;
            end;
            local serverSlotPriority = {
                [2] = 1, 
                [3] = 2, 
                [4] = 2, 
                [5] = 3, 
                [6] = 3
            };
            table.sort(serverSortedWeaponList, function(serverSortWeaponA, serverSortWeaponB) 
                local serverWeaponIdA = convertWeaponNamesToID[serverSortWeaponA] or 46;
                local serverWeaponIdB = convertWeaponNamesToID[serverSortWeaponB] or 46;
                local serverSlotA = getSlotFromWeapon(serverWeaponIdA);
                local serverSlotB = getSlotFromWeapon(serverWeaponIdB);
                local serverPriorityA = serverSlotPriority[serverSlotA] or 4;
                local serverPriorityB = serverSlotPriority[serverSlotB] or 4;
                return serverPriorityA == serverPriorityB and not (serverWeaponIdA >= serverWeaponIdB) or serverPriorityA < serverPriorityB;
            end);
            local serverItemX = 0;
            local serverItemY = 0;
            for serverItemIndex = 1, math.max(#weapon_items, #serverSortedWeaponList) do
                if serverItemIndex <= #serverSortedWeaponList then
                    local serverCurrentWeapon = serverSortedWeaponList[serverItemIndex];
                    local serverClipSize = 0;
                    local serverCurrentWeaponId = convertWeaponNamesToID[serverCurrentWeapon] or 16;
                    if serverCurrentWeaponId >= 16 and serverCurrentWeaponId <= 18 or serverCurrentWeaponId >= 22 and serverCurrentWeaponId <= 39 or serverCurrentWeaponId >= 41 and serverCurrentWeaponId <= 43 then
                        serverClipSize = tonumber(getWeaponProperty(serverCurrentWeaponId, "pro", "maximum_clip_ammo")) or 1;
                    end;
                    local serverAmmoText = math.max(0, math.floor(tonumber(serverWeaponAmmoData[serverCurrentWeapon]) - serverClipSize)) .. "-" .. math.min(tonumber(serverWeaponAmmoData[serverCurrentWeapon]), serverClipSize);
                    if #weapon_items < serverItemIndex then
                        local serverWeaponGui = guiCreateStaticImage(serverItemX, serverItemY, 64, 84, "images/color_pixel.png", false, weapon_scroller);
                        local serverWeaponIcon = guiCreateStaticImage(2, 5, 60, 64, "images/hud/fist.png", false, serverWeaponGui);
                        guiSetEnabled(serverWeaponIcon, false);
                        local serverAmmoLabel = guiCreateLabel(1, 60, 62, 20, serverClipSize > 1 and serverAmmoText or serverClipSize == 1 and serverWeaponAmmoData[serverCurrentWeapon] or "", false, serverWeaponGui);
                        guiLabelSetHorizontalAlign(serverAmmoLabel, "center", false);
                        guiLabelSetVerticalAlign(serverAmmoLabel, "center");
                        guiSetEnabled(serverAmmoLabel, false);
                        local serverNameLabel = guiCreateLabel(1, 5, 62, 20, serverCurrentWeapon, false, serverWeaponGui);
                        guiSetFont(serverNameLabel, "default-small");
                        guiSetEnabled(serverNameLabel, false);
                        local serverLimitLabel = guiCreateLabel(1, 5, 62, 20, serverWeaponBalanceData[serverCurrentWeapon] and "x" .. serverWeaponBalanceData[serverCurrentWeapon] or "", false, serverWeaponGui);
                        guiLabelSetHorizontalAlign(serverLimitLabel, "right", false);
                        guiLabelSetColor(serverLimitLabel, 255, 0, 0);
                        guiSetEnabled(serverLimitLabel, false);
                        table.insert(weapon_items, {gui = serverWeaponGui, icon = serverWeaponIcon, name = serverNameLabel, ammo = serverAmmoLabel, limit = serverLimitLabel});
                    else
                        guiSetPosition(weapon_items[serverItemIndex].gui, serverItemX, serverItemY, false);
                        guiSetText(weapon_items[serverItemIndex].ammo, serverClipSize > 1 and serverAmmoText or serverClipSize == 1 and serverWeaponAmmoData[serverCurrentWeapon] or "");
                        guiSetText(weapon_items[serverItemIndex].name, serverCurrentWeapon);
                        guiSetText(weapon_items[serverItemIndex].limit, serverWeaponBalanceData[serverCurrentWeapon] and "x" .. serverWeaponBalanceData[serverCurrentWeapon] or "");
                    end;
                    if fileExists("images/hud/" .. serverCurrentWeapon .. ".png") then
                        guiStaticImageLoadImage(weapon_items[serverItemIndex].icon, "images/hud/" .. serverCurrentWeapon .. ".png");
                    else
                        guiStaticImageLoadImage(weapon_items[serverItemIndex].icon, "images/hud/fist.png");
                    end;
                    if weaponSave[serverCurrentWeapon] then
                        guiSetProperty(weapon_items[serverItemIndex].gui, "ImageColours", "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF");
                    else
                        guiSetProperty(weapon_items[serverItemIndex].gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    end;
                    serverItemX = serverItemX + 66;
                    if serverItemX > 330 then
                        serverItemX = 0;
                        serverItemY = serverItemY + 86;
                    end;
                else
                    weaponSave[guiGetText(weapon_items[serverItemIndex].name)] = nil;
                    destroyElement(weapon_items[serverItemIndex].gui);
                    weapon_items[serverItemIndex] = nil;
                end;
            end;
            updateSaveWeapons();
            return;
        end;
    end;
    local serverBoundaryTimer = 0;
    onClientColShapeLeave = function(serverColShape, __) 
        if getElementData(source, "Boundings") and serverColShape == localPlayer and getElementData(localPlayer, "Status") == "Play" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
            local serverPlayerVehicle = getPedOccupiedVehicle(localPlayer);
            if not serverPlayerVehicle then
                local serverBoundaryX, serverBoundaryY, serverBoundaryZ = getElementPosition(localPlayer);
                local serverBoundaryVelX, serverBoundaryVelY, serverBoundaryVelZ = getElementVelocity(localPlayer);
                setElementPosition(localPlayer, serverBoundaryX, serverBoundaryY, serverBoundaryZ + 0.1);
                setElementVelocity(localPlayer, -serverBoundaryVelX, -serverBoundaryVelY, -serverBoundaryVelZ);
            elseif getVehicleOccupant(serverPlayerVehicle) == localPlayer then
                local serverVehicleRotX, serverVehicleRotY = getElementRotation(serverPlayerVehicle);
                local serverVehicleVelX, serverVehicleVelY, serverVehicleVelZ = getElementVelocity(serverPlayerVehicle);
                setElementRotation(serverPlayerVehicle, serverVehicleRotX + 180, serverVehicleRotY + 180);
                setElementVelocity(serverPlayerVehicle, -serverVehicleVelX, -serverVehicleVelY, -serverVehicleVelZ);
            end;
            serverBoundaryTimer = getTickCount() + 15000;
            addEventHandler("onClientPreRender", root, showGoBack);
        end;
    end;
    showGoBack = function() 
        local serverIsInsideBounds = true;
        for __, serverColShapeElement in ipairs(getElementsByType("colshape")) do
            if getElementData(serverColShapeElement, "Boundings") and not isElementWithinColShape(localPlayer, serverColShapeElement) then
                serverIsInsideBounds = false;
            end;
        end;
        if serverIsInsideBounds then
            return removeEventHandler("onClientPreRender", root, showGoBack);
        elseif serverBoundaryTimer < getTickCount() then
            callServerFunction("killPed", localPlayer);
            callServerFunction("callClientFunction", root, "outputLangString", "killed_for_out_bounding", getPlayerName(localPlayer));
            return removeEventHandler("onClientPreRender", root, showGoBack);
        else
            dxDrawRectangle(0, 0, xscreen, yscreen, 1610612736);
            dxDrawText(getLanguageString("go_back_to_bounds"), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, 4278190080, getFont(2), "default-bold", "center", "bottom");
            dxDrawText(getLanguageString("go_back_to_bounds"), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, 4294901760, getFont(2), "default-bold", "center", "bottom");
            local serverTimeRemaining = serverBoundaryTimer - getTickCount();
            dxDrawText(string.format(getLanguageString("or_you_will_be_killed"), serverTimeRemaining / 1000), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(1), "default", "center", "top");
            dxDrawText(string.format(getLanguageString("or_you_will_be_killed"), serverTimeRemaining / 1000), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 255), getFont(1), "default", "center", "top");
            return;
        end;
    end;
    callHelpme = function() 
        if not getElementData(localPlayer, "Helpme") and getElementData(localPlayer, "Status") == "Play" then
            setElementData(localPlayer, "Helpme", true);
            if isTimer(helpme[localPlayer]) then
                killTimer(helpme[localPlayer]);
            end;
            helpme[localPlayer] = setTimer(setElementData, 7000, 1, localPlayer, "Helpme", nil);
            outputChatBox(string.format(getLanguageString("help_me"), getPlayerName(localPlayer)), 255, 100, 100, true);
        end;
    end;
    local serverRespawnCooldown = 0;
    forceRespawnPlayer = function() 
        if serverRespawnCooldown + 3000 < getTickCount() and getElementData(localPlayer, "Status") == "Play" and not isRoundPaused() and not isElementInWater(localPlayer) then
            local serverPrimaryTask0 = getPedTask(localPlayer, "primary", 0);
            local serverSecondaryTask0 = getPedTask(localPlayer, "secondary", 0);
            local serverPrimaryTask1b = getPedTask(localPlayer, "primary", 1);
            local serverPrimaryTask3b = getPedTask(localPlayer, "primary", 3);
            local serverPrimaryTask4b = getPedTask(localPlayer, "primary", 4);
            if serverPrimaryTask0 ~= "TASK_COMPLEX_FALL_AND_GET_UP" and serverSecondaryTask0 ~= "TASK_SIMPLE_THROW" and serverSecondaryTask0 ~= "TASK_SIMPLE_USE_GUN" and serverPrimaryTask1b ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and serverPrimaryTask3b ~= "TASK_COMPLEX_LEAVE_CAR" and serverPrimaryTask3b ~= "TASK_COMPLEX_ENTER_CAR_AS_DRIVER" and serverPrimaryTask3b ~= "TASK_COMPLEX_ENTER_CAR_AS_PASSENGER" and serverPrimaryTask3b ~= "TASK_COMPLEX_JUMP" and serverPrimaryTask4b == "TASK_SIMPLE_PLAYER_ON_FOOT" then
                serverRespawnCooldown = getTickCount() + 3000;
                local serverSavedWeaponsData = {};
                for serverWeaponSlot = 0, 12 do
                    local serverSlotWeapon = getPedWeapon(localPlayer, serverWeaponSlot);
                    local serverSlotAmmo = getPedTotalAmmo(localPlayer, serverWeaponSlot);
                    local serverSlotClip = getPedAmmoInClip(localPlayer, serverWeaponSlot);
                    if serverSlotWeapon > 0 and serverSlotAmmo > 0 then
                        if serverWeaponSlot == getPedWeaponSlot(localPlayer) then
                            table.insert(serverSavedWeaponsData, {serverSlotWeapon, serverSlotAmmo, serverSlotClip, true});
                        else
                            table.insert(serverSavedWeaponsData, {serverSlotWeapon, serverSlotAmmo, serverSlotClip, false});
                        end;
                    end;
                end;
                callServerFunction("forceRespawnPlayer", localPlayer, serverSavedWeaponsData);
            end;
        end;
    end;
    onClientPlayerBlipUpdate = function() 
        if source == localPlayer then
            for __, serverOtherPlayerBlip in ipairs(getElementsByType("player")) do
                if source ~= serverOtherPlayerBlip then
                    triggerEvent("onClientPlayerBlipUpdate", serverOtherPlayerBlip);
                end;
            end;
        elseif getElementType(source) == "player" then
            local serverCurrentMode = getTacticsData("Map");
            local serverRadarBlipMode = getTacticsData("modes", serverCurrentMode, "player_radarblip") or getTacticsData("settings", "player_radarblip");
            local serverLocalTeam = getPlayerTeam(localPlayer);
            local serverOtherTeam = getPlayerTeam(source);
            local serverPlayerBlipElement = getElementData(source, "Blip");
            if serverPlayerBlipElement and isElement(serverPlayerBlipElement) then
                local serverNametagRed, serverNametagGreen, serverNametagBlue = getPlayerNametagColor(source);
                if serverOtherTeam then
                    local serverTeamRed, serverTeamGreen, serverTeamBlue = getTeamColor(serverOtherTeam);
                    serverNametagBlue = serverTeamBlue;
                    serverNametagGreen = serverTeamGreen;
                    serverNametagRed = serverTeamRed;
                end;
                if serverRadarBlipMode ~= "none" and getElementData(source, "Status") == "Play" and (serverRadarBlipMode == "all" or serverOtherTeam and serverLocalTeam == serverOtherTeam or serverLocalTeam == getElementsByType("team")[1]) then
                    setBlipColor(serverPlayerBlipElement, serverNametagRed, serverNametagGreen, serverNametagBlue, 255);
                    setBlipSize(serverPlayerBlipElement, 1);
                elseif getElementData(source, "Status") == "Die" then
                    setBlipColor(serverPlayerBlipElement, serverNametagRed / 2, serverNametagGreen / 2, serverNametagBlue / 2, 128);
                    setBlipSize(serverPlayerBlipElement, 1);
                else
                    setBlipColor(serverPlayerBlipElement, 0, 0, 0, 0);
                end;
            end;
            if source ~= localPlayer then
                if serverLocalTeam == getElementsByType("team")[1] then
                    setPlayerNametagShowing(source, true);
                elseif getPlayerProperty(source, "invisible") and serverLocalTeam ~= serverOtherTeam then
                    setPlayerNametagShowing(source, false);
                elseif getTacticsData("settings", "player_nametag") == "all" then
                    setPlayerNametagShowing(source, true);
                elseif getTacticsData("settings", "player_nametag") == "team" and serverLocalTeam == serverOtherTeam then
                    setPlayerNametagShowing(source, true);
                else
                    setPlayerNametagShowing(source, false);
                end;
            end;
        end;
    end;
    showCredits = function() 
        local serverEndingX, serverEndingY = guiGetPosition(credits_ending[1], false);
        guiSetPosition(credits_ending[1], serverEndingX, credits_ending[2], false);
        for __, serverCreditData in ipairs(credits_content) do
            local serverCreditX, serverCreditY = guiGetPosition(serverCreditData[1], false);
            serverEndingY = serverCreditY;
            guiSetPosition(serverCreditData[1], serverCreditX, serverCreditData[2], false);
        end;
        guiBringToFront(credits_window);
        guiSetPosition(credits_window, xscreen * 0.5 - 280, yscreen * 0.5 - 150, false);
        guiBringToFront(credits_window);
        guiSetVisible(credits_window, true);
        showCursor(true);
        if credits_scrolling then
            return;
        else
            credits_scrolling = 0;
            addEventHandler("onClientPreRender", root, scrollingCredits);
            return;
        end;
    end;
    scrollingCredits = function(serverDeltaTime) 
        if not guiGetVisible(credits_window) then
            removeEventHandler("onClientPreRender", root, scrollingCredits);
            credits_scrolling = nil;
            return;
        else
            credits_scrolling = credits_scrolling + serverDeltaTime;
            if credits_scrolling < 30 then
                return;
            else
                credits_scrolling = credits_scrolling % 30;
                local serverCurrentEndingX, serverCurrentEndingY = guiGetPosition(credits_ending[1], false);
                if serverCurrentEndingY > 0 then
                    guiSetPosition(credits_ending[1], serverCurrentEndingX, serverCurrentEndingY - 1, false);
                    for __, serverContentData in ipairs(credits_content) do
                        local serverContentX, serverContentY = guiGetPosition(serverContentData[1], false);
                        serverCurrentEndingY = serverContentY;
                        serverCurrentEndingX = serverContentX;
                        if serverCurrentEndingY > 0 then
                            guiSetPosition(serverContentData[1], serverCurrentEndingX, serverCurrentEndingY - 1, false);
                        else
                            guiSetPosition(serverContentData[1], serverCurrentEndingX, serverCurrentEndingY - 1 - 1, false);
                        end;
                    end;
                else
                    guiSetPosition(credits_ending[1], serverCurrentEndingX, serverCurrentEndingY + credits_ending[2], false);
                    for __, serverScrollData in ipairs(credits_content) do
                        local serverScrollX, serverScrollY = guiGetPosition(serverScrollData[1], false);
                        guiSetPosition(serverScrollData[1], serverScrollX, serverScrollY + credits_ending[2], false);
                    end;
                end;
                return;
            end;
        end;
    end;
    onClientMapStopping = function(__) 
        if isElement(weapon_window) and guiGetVisible(weapon_window) then
            guiSetVisible(weapon_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            if guiCheckBoxGetSelected(config_performance_weapmanager) then
                destroyElement(weapon_window);
            end;
        end;
        if isElement(vehicle_window) and guiGetVisible(vehicle_window) then
            guiSetVisible(vehicle_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            if guiCheckBoxGetSelected(config_performance_vehmanager) then
                destroyElement(vehicle_window);
            end;
        end;
        stopCameraPrepair();
        if isTimer(decelerationSpeed) then
            killTimer(decelerationSpeed);
        end;
    end;
    onClientRoundStart = function() 
        stopCameraPrepair();
    end;
    onClientRoundFinish = function(serverFinishData, __) 
        setGameSpeed(getGameSpeed() / 2);
        if not isTimer(decelerationSpeed) then
            decelerationSpeed = setTimer(function() 
                if getGameSpeed() > 0 then
                    setGameSpeed(math.max(0, getGameSpeed() - 0.02));
                else
                    killTimer(decelerationSpeed);
                end;
            end, 50, 0);
        end;
        local l_name_0 = getRoundMapInfo().name;
        if serverFinishData then
            local serverFormattedResult = "";
            if type(serverFinishData) == "table" then
                if type(serverFinishData[1]) == "string" then
                    local serverResultKey = serverFinishData[1];
                    local serverFormattedArgs = serverFinishData;
                    table.remove(serverFormattedArgs, 1);
                    serverFormattedResult = string.format(getLanguageString(tostring(serverResultKey)), unpack(serverFormattedArgs));
                else
                    local serverColorResultKey = serverFinishData[4];
                    local serverColorFormattedArgs = serverFinishData;
                    table.remove(serverColorFormattedArgs, 1);
                    table.remove(serverColorFormattedArgs, 1);
                    table.remove(serverColorFormattedArgs, 1);
                    table.remove(serverColorFormattedArgs, 1);
                    serverFormattedResult = string.format(getLanguageString(tostring(serverColorResultKey)), unpack(serverColorFormattedArgs));
                end;
            elseif type(serverFinishData) == "string" then
                serverFormattedResult = getLanguageString(serverFinishData);
                if #serverFormattedResult == 0 then
                    serverFormattedResult = tostring(serverFinishData);
                end;
            else
                serverFormattedResult = tostring(serverFinishData);
            end;
            outputLangString("round_finish_result", l_name_0, serverFormattedResult);
        else
            outputLangString("round_finish", l_name_0);
        end;
        playMusic("audio/music_gta3.mp3");
        if respawn_countdown then
            removeEventHandler("onClientPreRender", root, onClientRespawnRender);
        end;
        respawn_countdown = nil;
    end;
    onClientRoundTimesup = function() 
        playVoice("audio/times_up.mp3");
    end;
    doReloadWeapon = function() 
        if not getPedControlState("jump") and getPedTask(localPlayer, "primary", 4) == "TASK_SIMPLE_PLAYER_ON_FOOT" and getPedTask(localPlayer, "primary", 1) ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and getPedTask(localPlayer, "primary", 3) ~= "TASK_COMPLEX_JUMP" then
            callServerFunction("reloadPedWeapon", localPlayer);
        end;
    end;
    onClientVehicleEnter = function(serverEnteringPlayer, serverVehicleSeat) 
        local serverEnterBlip = getElementData(source, "Blip");
        if serverEnterBlip and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            setBlipColor(serverEnterBlip, 0, 0, 0, 0);
        end;
        if serverVehicleSeat == 0 then
            local serverEnterGhostMode = getTacticsData("settings", "ghostmode");
            for __, serverCollisionVehicle in ipairs(getElementsByType("vehicle", root, true)) do
                if serverEnterGhostMode == "team" and getVehicleController(serverCollisionVehicle) and getPlayerTeam(getVehicleController(serverCollisionVehicle)) == getPlayerTeam(serverEnteringPlayer) then
                    setElementCollidableWith(serverCollisionVehicle, source, false);
                elseif serverEnterGhostMode == "all" then
                    setElementCollidableWith(serverCollisionVehicle, source, false);
                else
                    setElementCollidableWith(serverCollisionVehicle, source, true);
                end;
            end;
        end;
    end;
    onClientVehicleStartExit = function(serverExitingPlayer, serverExitSeat, __) 
        local serverExitBlip = getElementData(source, "Blip");
        if serverExitBlip and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            local serverHasOtherOccupants = false;
            local serverVehicleSeats = getVehicleOccupants(source);
            for serverSeat = 0, getVehicleMaxPassengers(source) do
                if serverVehicleSeats[serverSeat] and serverSeat ~= serverExitSeat then
                    serverHasOtherOccupants = true;
                    break;
                end;
            end;
            local serverVehicleDriver = getVehicleController(source);
            if not serverHasOtherOccupants and (not serverVehicleDriver or serverVehicleDriver == serverExitingPlayer) then
                setBlipColor(serverExitBlip, 128, 128, 128, 128);
            end;
        end;
    end;
    onClientVehicleExit = function(serverExitedPlayer, serverExitedSeat) 
        local serverExitVehicleBlip = getElementData(source, "Blip");
        if serverExitVehicleBlip and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            local serverOtherOccupants = false;
            local serverRemainingOccupants = getVehicleOccupants(source);
            for serverRemainingSeat = 0, getVehicleMaxPassengers(source) do
                if serverRemainingOccupants[serverRemainingSeat] and serverRemainingSeat ~= serverExitedSeat then
                    serverOtherOccupants = true;
                    break;
                end;
            end;
            local serverRemainingDriver = getVehicleController(source);
            if not serverOtherOccupants and (not serverRemainingDriver or serverRemainingDriver == serverExitedPlayer) then
                setBlipColor(serverExitVehicleBlip, 128, 128, 128, 128);
            end;
        end;
        if serverExitedSeat == 0 and getTacticsData("settings", "ghostmode") == "team" then
            for __, serverExitCollisionVeh in ipairs(getElementsByType("vehicle", root, true)) do
                setElementCollidableWith(serverExitCollisionVeh, source, true);
                setElementCollidableWith(source, serverExitCollisionVeh, true);
            end;
        end;
    end;
    onClientPlayerRoundSpawn = function() 
        if not getElementData(localPlayer, "Loading") then
            fadeCamera(true, 2);
        end;
        setTimer(function() 
            if getElementData(localPlayer, "Status") ~= "Spectate" then
                return;
            else
                local serverRestoreList = getTacticsData("Restores") or {};
                for __, serverPlayerRestore in ipairs(serverRestoreList) do
                    if serverPlayerRestore[1] == getPlayerName(localPlayer) then
                        outputInfo(string.format(getLanguageString("help_restore"), "R"));
                        return;
                    end;
                end;
                local serverGameMode = getTacticsData("Map");
                if (getTacticsData("modes", serverGameMode, "respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
                    outputInfo(string.format(getLanguageString("help_restore"), "R"));
                end;
                return;
            end;
        end, 1000, 1);
    end;
    onClientPlayerRoundRespawn = function() 
        if not getElementData(localPlayer, "Loading") then
            fadeCamera(true, 2);
        end;
        if respawn_countdown then
            removeEventHandler("onClientPreRender", root, onClientRespawnRender);
            respawn_countdown = nil;
        end;
    end;
    local serverWeatherBlend = {};
    updateWeatherBlend = function() 
        serverWeatherBlend = {};
        local serverWeatherData = getTacticsData("Weather");
        local serverCurrentHour = (getTime() + 1) % 24;
        for serverHourIndex = serverCurrentHour, serverCurrentHour + 22 do
            local serverWeatherHour = serverHourIndex % 24;
            if serverWeatherData[serverWeatherHour] then
                serverWeatherBlend[2] = {
                    hour = serverWeatherHour, 
                    wind = {
                        x = serverWeatherData[serverWeatherHour].wind[1], 
                        y = serverWeatherData[serverWeatherHour].wind[2], 
                        z = serverWeatherData[serverWeatherHour].wind[3]
                    }, 
                    rain = serverWeatherData[serverWeatherHour].rain, 
                    far = serverWeatherData[serverWeatherHour].far, 
                    fog = serverWeatherData[serverWeatherHour].fog, 
                    sky = {
                        rt = serverWeatherData[serverWeatherHour].sky[1], 
                        gt = serverWeatherData[serverWeatherHour].sky[2], 
                        bt = serverWeatherData[serverWeatherHour].sky[3], 
                        rb = serverWeatherData[serverWeatherHour].sky[4], 
                        gb = serverWeatherData[serverWeatherHour].sky[5], 
                        bb = serverWeatherData[serverWeatherHour].sky[6]
                    }, 
                    clouds = serverWeatherData[serverWeatherHour].clouds, 
                    birds = serverWeatherData[serverWeatherHour].birds, 
                    sun = {
                        rc = serverWeatherData[serverWeatherHour].sun[1], 
                        gc = serverWeatherData[serverWeatherHour].sun[2], 
                        bc = serverWeatherData[serverWeatherHour].sun[3], 
                        rs = serverWeatherData[serverWeatherHour].sun[4], 
                        gs = serverWeatherData[serverWeatherHour].sun[5], 
                        bs = serverWeatherData[serverWeatherHour].sun[6], 
                        size = serverWeatherData[serverWeatherHour].sunsize
                    }, 
                    water = {
                        r = serverWeatherData[serverWeatherHour].water[1], 
                        g = serverWeatherData[serverWeatherHour].water[2], 
                        b = serverWeatherData[serverWeatherHour].water[3], 
                        a = serverWeatherData[serverWeatherHour].water[4], 
                        lvl = serverWeatherData[serverWeatherHour].level, 
                        wave = serverWeatherData[serverWeatherHour].wave
                    }, 
                    heat = serverWeatherData[serverWeatherHour].heat, 
                    effect = serverWeatherData[serverWeatherHour].effect
                };
                break;
            end;
        end;
        serverCurrentHour = (serverCurrentHour - 1) % 24;
        for serverPrevHourIndex = serverCurrentHour, serverCurrentHour - 23, -1 do
            local serverPrevWeatherHour = serverPrevHourIndex % 24;
            if serverWeatherData[serverPrevWeatherHour] then
                serverWeatherBlend[1] = {
                    hour = serverPrevWeatherHour, 
                    wind = {
                        x = serverWeatherData[serverPrevWeatherHour].wind[1], 
                        y = serverWeatherData[serverPrevWeatherHour].wind[2], 
                        z = serverWeatherData[serverPrevWeatherHour].wind[3]
                    }, 
                    rain = serverWeatherData[serverPrevWeatherHour].rain, 
                    far = serverWeatherData[serverPrevWeatherHour].far, 
                    fog = serverWeatherData[serverPrevWeatherHour].fog, 
                    sky = {
                        rt = serverWeatherData[serverPrevWeatherHour].sky[1], 
                        gt = serverWeatherData[serverPrevWeatherHour].sky[2], 
                        bt = serverWeatherData[serverPrevWeatherHour].sky[3], 
                        rb = serverWeatherData[serverPrevWeatherHour].sky[4], 
                        gb = serverWeatherData[serverPrevWeatherHour].sky[5], 
                        bb = serverWeatherData[serverPrevWeatherHour].sky[6]
                    }, 
                    clouds = serverWeatherData[serverPrevWeatherHour].clouds, 
                    birds = serverWeatherData[serverPrevWeatherHour].birds, 
                    sun = {
                        rc = serverWeatherData[serverPrevWeatherHour].sun[1], 
                        gc = serverWeatherData[serverPrevWeatherHour].sun[2], 
                        bc = serverWeatherData[serverPrevWeatherHour].sun[3], 
                        rs = serverWeatherData[serverPrevWeatherHour].sun[4], 
                        gs = serverWeatherData[serverPrevWeatherHour].sun[5], 
                        bs = serverWeatherData[serverPrevWeatherHour].sun[6], 
                        size = serverWeatherData[serverPrevWeatherHour].sunsize
                    }, 
                    water = {
                        r = serverWeatherData[serverPrevWeatherHour].water[1], 
                        g = serverWeatherData[serverPrevWeatherHour].water[2], 
                        b = serverWeatherData[serverPrevWeatherHour].water[3], 
                        a = serverWeatherData[serverPrevWeatherHour].water[4], 
                        lvl = serverWeatherData[serverPrevWeatherHour].level, 
                        wave = serverWeatherData[serverPrevWeatherHour].wave
                    }, 
                    heat = serverWeatherData[serverPrevWeatherHour].heat, 
                    effect = serverWeatherData[serverPrevWeatherHour].effect
                };
                break;
            end;
        end;
    end;
    local serverLastHour = 0;
    local serverLastMinute = 0;
    updateWeather = function(serverForceUpdate) 
        local serverGameHour, serverGameMinute = getTime();
        if serverLastHour == serverGameHour and serverLastMinute == serverGameMinute and not serverForceUpdate then
            return;
        else
            local serverBlendFactor = serverGameHour;
            serverLastMinute = serverGameMinute;
            serverLastHour = serverBlendFactor;
            if #serverWeatherBlend ~= 2 then
                updateWeatherBlend();
            end;
            serverBlendFactor = (serverGameHour + serverGameMinute / 60 - serverWeatherBlend[1].hour) / ((serverWeatherBlend[2].hour >= serverWeatherBlend[1].hour and serverWeatherBlend[2].hour or serverWeatherBlend[2].hour + 24) - serverWeatherBlend[1].hour);
            if serverBlendFactor < 0 or serverBlendFactor >= 1 then
                updateWeatherBlend();
                serverBlendFactor = (serverGameHour + serverGameMinute / 60 - serverWeatherBlend[1].hour) / (serverWeatherBlend[2].hour - serverWeatherBlend[1].hour);
            end;
            local function serverLerpFunction(serverStartValue, serverEndValue) 
                return serverStartValue + serverBlendFactor * (serverEndValue - serverStartValue);
            end;
            setWeather(serverWeatherBlend[1].effect or 0);
            setWindVelocity(serverLerpFunction(serverWeatherBlend[1].wind.x, serverWeatherBlend[2].wind.x), serverLerpFunction(serverWeatherBlend[1].wind.y, serverWeatherBlend[2].wind.y), 0);
            setRainLevel(serverLerpFunction(serverWeatherBlend[1].rain, serverWeatherBlend[2].rain));
            setFarClipDistance(serverLerpFunction(serverWeatherBlend[1].far, serverWeatherBlend[2].far));
            setFogDistance(serverLerpFunction(serverWeatherBlend[1].fog, serverWeatherBlend[2].fog));
            setSkyGradient(serverLerpFunction(serverWeatherBlend[1].sky.rt, serverWeatherBlend[2].sky.rt), serverLerpFunction(serverWeatherBlend[1].sky.gt, serverWeatherBlend[2].sky.gt), serverLerpFunction(serverWeatherBlend[1].sky.bt, serverWeatherBlend[2].sky.bt), serverLerpFunction(serverWeatherBlend[1].sky.rb, serverWeatherBlend[2].sky.rb), serverLerpFunction(serverWeatherBlend[1].sky.gb, serverWeatherBlend[2].sky.gb), serverLerpFunction(serverWeatherBlend[1].sky.bb, serverWeatherBlend[2].sky.bb));
            setCloudsEnabled(serverWeatherBlend[1].clouds);
            setBirdsEnabled(serverWeatherBlend[1].birds);
            setSunColor(serverLerpFunction(serverWeatherBlend[1].sun.rc, serverWeatherBlend[2].sun.rc), serverLerpFunction(serverWeatherBlend[1].sun.gc, serverWeatherBlend[2].sun.gc), serverLerpFunction(serverWeatherBlend[1].sun.bc, serverWeatherBlend[2].sun.bc), serverLerpFunction(serverWeatherBlend[1].sun.rs, serverWeatherBlend[2].sun.rs), serverLerpFunction(serverWeatherBlend[1].sun.gs, serverWeatherBlend[2].sun.gs), serverLerpFunction(serverWeatherBlend[1].sun.bs, serverWeatherBlend[2].sun.bs));
            setSunSize(serverLerpFunction(serverWeatherBlend[1].sun.size, serverWeatherBlend[2].sun.size));
            setWaterColor(serverLerpFunction(serverWeatherBlend[1].water.r, serverWeatherBlend[2].water.r), serverLerpFunction(serverWeatherBlend[1].water.g, serverWeatherBlend[2].water.g), serverLerpFunction(serverWeatherBlend[1].water.b, serverWeatherBlend[2].water.b), serverLerpFunction(serverWeatherBlend[1].water.a, serverWeatherBlend[2].water.a));
            setWaterLevel(serverLerpFunction(serverWeatherBlend[1].water.lvl, serverWeatherBlend[2].water.lvl), false, false);
            setWaveHeight(serverLerpFunction(serverWeatherBlend[1].water.wave, serverWeatherBlend[2].water.wave));
            setHeatHaze(serverLerpFunction(serverWeatherBlend[1].heat, serverWeatherBlend[2].heat), 0, 12, 18, 75, 80, 80, 85, true);
            return;
        end;
    end;
    onClientPlayerVehiclepackGot = function(serverSpawnedVehicle, __, serverVehicleHeightCorrection) 
        if getVehicleType(serverSpawnedVehicle) == "Helicopter" then
            setVehicleRotorSpeed(serverSpawnedVehicle, 0.2);
        end;
        if serverVehicleHeightCorrection then
            local serverVehicleBaseHeight = getElementDistanceFromCentreOfMassToBaseOfModel(serverSpawnedVehicle);
            local serverVehPosX, serverVehPosY, serverVehPosZ = getElementPosition(serverSpawnedVehicle);
            setElementPosition(serverSpawnedVehicle, serverVehPosX, serverVehPosY, serverVehPosZ + serverVehicleBaseHeight - serverVehicleHeightCorrection);
        end;
    end;
    getRestoreCount = function() 
        return #(getTacticsData("Restores") or {});
    end;
    getRestoreData = function(serverRestoreIndex) 
        local serverRestoreData = getTacticsData("Restores") or {};
        if not serverRestoreData[serverRestoreIndex] then
            return false;
        else
            local serverPlayerName, serverPlayerTeam, serverPlayerSkin, serverPlayerHealth, serverPlayerArmor, serverPlayerInterior, serverPlayerWeapons, serverPlayerWeaponSlot, serverPlayerVehicleId, serverRestoreX, serverRestoreY, serverRestoreZ, serverRestoreRotation, serverRestoreVelX, serverRestoreVelY, serverRestoreVelZ, serverRestoreOnFire, serverRestoreVehicleSeat, __ = unpack(serverRestoreData[serverRestoreIndex]);
            return {
                name = serverPlayerName, 
                posX = serverRestoreX, 
                posY = serverRestoreY, 
                posZ = serverRestoreZ, 
                rotation = serverRestoreRotation, 
                interior = serverPlayerInterior, 
                team = serverPlayerTeam, 
                skin = serverPlayerSkin, 
                health = serverPlayerHealth, 
                armour = serverPlayerArmor, 
                velocityX = serverRestoreVelX, 
                velocityY = serverRestoreVelY, 
                velocityZ = serverRestoreVelZ, 
                onfire = serverRestoreOnFire, 
                weapons = serverPlayerWeapons, 
                weaponslot = serverPlayerWeaponSlot, 
                vehicle = serverPlayerVehicleId, 
                vehicleseat = serverRestoreVehicleSeat
            };
        end;
    end;
    onClientPlayerRPS = function() 
        outputChatBox(string.format(getLanguageString("rsp_using"), getPlayerName(source)), 255, 100, 100, true);
    end;
    addEvent("onClientMapStarting");
    addEvent("onClientMapStopping", true);
    addEvent("onClientRoundStart", true);
    addEvent("onClientRoundFinish", true);
    addEvent("onClientRoundTimesup", true);
    addEvent("onClientRoundCountdownStarted", true);
    addEvent("onClientPauseToggle", true);
    addEvent("onClientPlayerRoundSpawn", true);
    addEvent("onClientPlayerRoundRespawn", true);
    addEvent("onClientPlayerBlipUpdate", true);
    addEvent("onClientPlayerRPS", true);
    addEvent("onClientPlayerVehiclepackGot", true);
    addEvent("onClientPlayerWeaponpackGot", true);
    addEvent("onClientPlayerGameStatusChange");
    addEvent("onClientRespawnCountdown", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop);
    addEventHandler("onClientResourceStart", root, onClientOtherResourceStart);
    addEventHandler("onClientPlayerJoin", root, onClientPlayerJoin);
    addEventHandler("onClientPlayerQuit", root, onClientPlayerQuit);
    addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerDamage);
    addEventHandler("onClientPlayerSpawn", root, onClientPlayerSpawn);
    addEventHandler("onClientPlayerWasted", root, onClientPlayerWasted);
    addEventHandler("onClientRespawnCountdown", root, onClientRespawnCountdown);
    addEventHandler("onClientElementDataChange", root, onClientElementDataChange);
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
    addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn);
    addEventHandler("onClientMapStarting", root, onClientMapStarting);
    addEventHandler("onClientGUIClick", root, onClientGUIClick);
    addEventHandler("onClientGUIDoubleClick", root, onClientGUIDoubleClick);
    addEventHandler("onClientGUIChanged", root, onClientGUIChanged);
    addEventHandler("onClientMouseEnter", root, onClientMouseEnter);
    addEventHandler("onClientMouseLeave", root, onClientMouseLeave);
    addEventHandler("onClientPauseToggle", root, onClientPauseToggle);
    addEventHandler("onClientColShapeLeave", root, onClientColShapeLeave);
    addEventHandler("onClientPlayerBlipUpdate", root, onClientPlayerBlipUpdate);
    addEventHandler("onClientMapStopping", root, onClientMapStopping);
    addEventHandler("onClientRoundStart", root, onClientRoundStart);
    addEventHandler("onClientRoundFinish", root, onClientRoundFinish);
    addEventHandler("onClientRoundTimesup", root, onClientRoundTimesup);
    addEventHandler("onClientVehicleEnter", root, onClientVehicleEnter);
    addEventHandler("onClientVehicleStartExit", root, onClientVehicleStartExit);
    addEventHandler("onClientVehicleExit", root, onClientVehicleExit);
    addEventHandler("onClientPlayerRoundSpawn", localPlayer, onClientPlayerRoundSpawn);
    addEventHandler("onClientPlayerRoundRespawn", localPlayer, onClientPlayerRoundRespawn);
    addEventHandler("onClientRoundCountdownStarted", root, onClientRoundCountdownStarted);
    addEventHandler("onClientPlayerVehiclepackGot", root, onClientPlayerVehiclepackGot);
    addEventHandler("onDownloadComplete", root, onDownloadComplete);
    addEventHandler("onClientRender", root, updateWeather);
    addEventHandler("onClientPlayerRPS", root, onClientPlayerRPS);
    addEventHandler("onClientRender", root, function() 
        if isElementFrozen(localPlayer) then
            setElementVelocity(localPlayer, 0, 0, 0);
        end;
    end);
    addCommandHandler("team_change", forcedChangeTeam, false);
    addCommandHandler("help_me", callHelpme, false);
    addCommandHandler("rsp", forceRespawnPlayer, false);
    addCommandHandler("credits", showCredits, false);
    addCommandHandler("reload", doReloadWeapon, false);
    bindKey("action", "down", function() 
        setPedControlState("action", false);
    end);
end)();
(function(...) 
    local serverAdminWindowWidth = 480;
    local serverAdminWindowHeight = 480;
    local serverAdminUpdateTimer = false;
    local serverSelectedPlayers = {};
    sortWeaponNames = {};
    convertWeaponNamesToID = {
        golfclub = 2, 
        nightstick = 3, 
        knife = 4, 
        bat = 5, 
        shovel = 6, 
        poolstick = 7, 
        katana = 8, 
        saw = 9, 
        colt45 = 22, 
        silenced = 23, 
        deagle = 24, 
        shotgun = 25, 
        sawnoff = 26, 
        spas12 = 27, 
        uzi = 28, 
        mp5 = 29, 
        ak47 = 30, 
        m4 = 31, 
        tec9 = 32, 
        rifle = 33, 
        sniper = 34, 
        rpg = 35, 
        heatseek = 36, 
        flame = 37, 
        minigun = 38, 
        grenade = 16, 
        teargas = 17, 
        molotov = 18, 
        satchel = 39, 
        spraycan = 41, 
        fireextinguisher = 42, 
        camera = 43, 
        nightvision = 44, 
        infrared = 45, 
        parachute = 46
    };
    convertWeaponIDToNames = {
        [2] = "golfclub", 
        [3] = "nightstick", 
        [4] = "knife", 
        [5] = "bat", 
        [6] = "shovel", 
        [7] = "poolstick", 
        [8] = "katana", 
        [9] = "saw", 
        [22] = "colt45", 
        [23] = "silenced", 
        [24] = "deagle", 
        [25] = "shotgun", 
        [26] = "sawnoff", 
        [27] = "spas12", 
        [28] = "uzi", 
        [29] = "mp5", 
        [30] = "ak47", 
        [31] = "m4", 
        [32] = "tec9", 
        [33] = "rifle", 
        [34] = "sniper", 
        [35] = "rpg", 
        [36] = "heatseek", 
        [37] = "flame", 
        [38] = "minigun", 
        [16] = "grenade", 
        [17] = "teargas", 
        [18] = "molotov", 
        [39] = "satchel", 
        [41] = "spraycan", 
        [42] = "fireextinguisher", 
        [43] = "camera", 
        [44] = "nightvision", 
        [45] = "infrared", 
        [46] = "parachute"
    };
    convertVehicleVariant = {
        [416] = {
            [0] = "37", 
            [1] = "71"
        }, 
        [435] = {
            [0] = "Cok-o-Pops", 
            [1] = "Munky Juice", 
            [2] = "Hinterland", 
            [3] = "Zip", 
            [4] = "RS Haul", 
            [5] = "Ranch"
        }, 
        [450] = {
            [0] = "Filled with gravel/coal/stone"
        }, 
        [485] = {
            [0] = "Earmuffs", 
            [1] = "Small Case", 
            [2] = "Large Case"
        }, 
        [433] = {
            [0] = "Opaque Fabric", 
            [1] = "Camo Netting"
        }, 
        [499] = {
            [0] = "Shady Industries", 
            [1] = "LSD", 
            [2] = "The Uphill Gardener", 
            [3] = "Discount Furniture"
        }, 
        [581] = {
            [0] = "Single Type1", 
            [1] = "Single Type2", 
            [2] = "Dual Type3", 
            [3] = "Half-size", 
            [4] = "Full-size"
        }, 
        [424] = {
            [0] = "Side Panels"
        }, 
        [504] = {
            [0] = "328/White", 
            [1] = "464/Check", 
            [2] = "172/Check", 
            [3] = "100/White", 
            [4] = "284/White", 
            [5] = "505/Check"
        }, 
        [422] = {
            [0] = "Spare Tire", 
            [1] = "Sprunk Cans"
        }, 
        [482] = {
            [0] = "Roof Lights + Spoiler"
        }, 
        [457] = {
            [0] = "Golfbag1", 
            [1] = "Satchel1", 
            [2] = "Golfbag2 Rear Cargo (Pass Side)", 
            [3] = "Satchel2", 
            [4] = "Golfbag3", 
            [5] = "Golfbag4"
        }, 
        [483] = {
            [0] = "Open Curtains & Second Bench Seat", 
            [1] = "Open Roof Vent, Closed Curtains, Bed in Back, Peace Sign"
        }, 
        [415] = {
            [0] = "Single, Placed High", 
            [1] = "Dual, Placed Normally"
        }, 
        [437] = {
            [0] = "Big O Tours", 
            [1] = "Bikini Line"
        }, 
        [472] = {
            [0] = "Items all Over", 
            [1] = "Items Grouped in Back", 
            [2] = "Items all Over + 2 Oars in Front"
        }, 
        [521] = {
            [0] = "Single Type1", 
            [1] = "Dual Type1", 
            [2] = "Dual Type2", 
            [3] = "Half-size", 
            [4] = "Full-size"
        }, 
        [407] = {
            [0] = "64", 
            [1] = "16", 
            [2] = "47"
        }, 
        [455] = {
            [0] = "64", 
            [1] = "16", 
            [2] = "47"
        }, 
        [434] = {
            [0] = "Partial Engine Cover"
        }, 
        [502] = {
            [0] = "96", 
            [1] = "67", 
            [2] = "73", 
            [3] = "52", 
            [4] = "45", 
            [5] = "14"
        }, 
        [503] = {
            [0] = "82", 
            [1] = "26", 
            [2] = "65", 
            [3] = "07", 
            [4] = "36", 
            [5] = "60"
        }, 
        [571] = {
            [0] = "Both Sides", 
            [1] = "Steering Column"
        }, 
        [595] = {
            [0] = "Over passenger section", 
            [1] = "Over driver section"
        }, 
        [484] = {
            [0] = "Windshield over Cabin Entrance"
        }, 
        [500] = {
            [0] = "Roof Over Back", 
            [1] = "Roll Bar in Back"
        }, 
        [556] = {
            [0] = "Roof Spoiler", 
            [1] = "Roof Lights", 
            [2] = "Roll Bar with Lights"
        }, 
        [557] = {
            [0] = "Couldn't Determine 1 = Roof Lights"
        }, 
        [423] = {
            [0] = "Cherry Popping Good", 
            [1] = "Slow Children Ahead"
        }, 
        [414] = {
            [0] = "Toy Corner", 
            [1] = "Binco", 
            [2] = "Semi", 
            [3] = "Shafted Appliances"
        }, 
        [522] = {
            [0] = "Single Pair1", 
            [1] = "Single Pair2", 
            [2] = "Dual Pair2", 
            [3] = "Smooth", 
            [4] = "With Side Cutouts"
        }, 
        [470] = {
            [0] = "Low Cover", 
            [1] = "Roof/High Cover", 
            [2] = "Roll Bar"
        }, 
        [404] = {
            [0] = "Low Cover", 
            [1] = "Roof/High Cover", 
            [2] = "Roll Bar"
        }, 
        [600] = {
            [0] = "Planks", 
            [1] = "Sprunk Cans"
        }, 
        [413] = {
            [0] = "Sound System in Back"
        }, 
        [453] = {
            [0] = "Boxes of Fish", 
            [1] = "Bench"
        }, 
        [442] = {
            [0] = "Brown Style1", 
            [1] = "Black Style2", 
            [2] = "Brown Style3"
        }, 
        [440] = {
            [0] = "Cok-o-Pops", 
            [1] = "Harry Plums", 
            [2] = "Dick Goblin's", 
            [3] = "Final Build", 
            [4] = "Transfender", 
            [5] = "Wheel Arch Angels"
        }, 
        [543] = {
            [0] = "Two Propane Tanks & Crate", 
            [1] = "Two Barrels", 
            [2] = "Sprunk Cans", 
            [3] = "Open Crates"
        }, 
        [605] = {
            [0] = "Two Propane Tanks & Crate", 
            [1] = "Two Barrels", 
            [2] = "Sprunk Cans", 
            [3] = "Open Crates"
        }, 
        [428] = {
            [0] = "Chuff", 
            [1] = "Lock&Load"
        }, 
        [535] = {
            [0] = "Normal", 
            [1] = "Chain (Default has none!)"
        }, 
        [439] = {
            [0] = "Hardtop", 
            [1] = "Softtop (up)", 
            [2] = "Softtop (folded)"
        }, 
        [506] = {
            [0] = "Full Roof"
        }, 
        [601] = {
            [0] = "1", 
            [1] = "9", 
            [2] = "6", 
            [3] = "7"
        }, 
        [459] = {
            [0] = "Boxes of Toys in Back"
        }, 
        [408] = {
            [0] = "Some bits of trash sticking out of the back"
        }, 
        [583] = {
            [0] = "Red Case", 
            [1] = "Green Case"
        }, 
        [552] = {
            [0] = "Cones, Barrel in back + Cone lying on passenger side rail", 
            [1] = "Cones, Barrel in back + Cone lying on driver side rail"
        }, 
        [478] = {
            [0] = "Two Propane Tanks", 
            [1] = "Open Crates", 
            [2] = "Propane Tank and Barrel"
        }, 
        [555] = {
            [0] = "Roof"
        }, 
        [456] = {
            [0] = "Big Gas", 
            [1] = "RS Haul", 
            [2] = "Star Balls", 
            [3] = "Flower Power"
        }, 
        [477] = {
            [0] = "Rear Spoiler"
        }
    };
    weatherSAData = {
        {
            name = "Extra Sunny LA", 
            hours = {
                [0] = {
                    amb = {22, 22, 22}, 
                    obj = {220, 212, 130}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 23, 24, 0, 31, 32}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.3, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 240}, 
                    rgb1 = {87, 87, 87, 127}, 
                    rgb2 = {60, 121, 122, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [5] = {
                    amb = {22, 22, 22}, 
                    obj = {194, 194, 142}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 20, 20, 0, 31, 32}, 
                    sun = {255, 128, 0, 255, 128, 0, 0}, 
                    sprite = {0.2, 1}, 
                    shadow = {150, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {35, 9, 10, 27, 30, 36}, 
                    water = {53, 104, 104, 240}, 
                    rgb1 = {80, 80, 80, 127}, 
                    rgb2 = {60, 190, 190, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [6] = {
                    amb = {22, 22, 22}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0.3, 1}, 
                    shadow = {140, 93, 0}, 
                    far = 800, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {149, 94, 0, 127}, 
                    cloud2 = {25, 120, 0, 1}}, 
                [7] = {
                    amb = {5, 0, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 90, 200, 255}, 
                    sun = {255, 255, 255, 255, 255, 255, 2.2}, 
                    sprite = {0.3, 1}, 
                    shadow = {100, 50, 75}, 
                    far = 800, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {133, 106, 70, 111}, 
                    rgb2 = {96, 61, 15, 127}, 
                    cloud2 = {25, 180, 0, 1}}, 
                [12] = {
                    amb = {11, 0, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {68, 117, 210, 36, 117, 199}, 
                    sun = {255, 255, 255, 255, 255, 255, 1.1}, 
                    sprite = {0, 1}, 
                    shadow = {236, 0, 190}, 
                    far = 800, fog = 10, ground = 0, 
                    cloud = {44, 34, 23, 145, 164, 183}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {66, 66, 48, 127}, 
                    rgb2 = {166, 129, 60, 127}, 
                    cloud2 = {25, 180, 0, 1}}, 
                [19] = {
                    amb = {8, 5, 5}, 
                    obj = {255, 255, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {68, 117, 210, 36, 117, 194}, 
                    sun = {222, 88, 0, 122, 55, 0, 3.9}, 
                    sprite = {0, 1}, 
                    shadow = {110, 40, 75}, 
                    far = 800, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {50, 97, 97, 240}, 
                    rgb1 = {124, 124, 107, 106}, 
                    rgb2 = {86, 50, 10, 127}, 
                    cloud2 = {25, 180, 0, 1}}, 
                [20] = {
                    amb = {25, 14, 14}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 167, 108, 65}, 
                    sun = {255, 128, 0, 255, 128, 0, 2}, 
                    sprite = {0.4, 1}, 
                    shadow = {100, 60, 0}, 
                    far = 800, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 72, 107, 159}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {81, 85, 40, 127}, 
                    rgb2 = {66, 27, 0, 127}, 
                    cloud2 = {25, 140, 0, 1}}, 
                [22] = {
                    amb = {21, 20, 20}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {137, 100, 84, 60, 50, 52}, 
                    sun = {255, 128, 0, 5, 8, 0, 1}, 
                    sprite = {0.3, 1}, 
                    shadow = {160, 100, 0}, 
                    far = 600, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 15, 11, 34}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {209, 143, 84, 127}, 
                    rgb2 = {76, 51, 0, 127}, 
                    cloud2 = {25, 90, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny LA", 
            hours = {
                [0] = {
                    amb = {0, 20, 20}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {5, 12, 15, 12, 14, 13}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.4, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 800, fog = 100, ground = 1, 
                    cloud = {0, 0, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 240}, 
                    rgb1 = {110, 126, 210, 127}, 
                    rgb2 = {0, 81, 104, 212}, 
                    cloud2 = {55, 220, 0, 1}}, 
                [5] = {
                    amb = {6, 20, 20}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 0, 7, 19, 39, 37}, 
                    sun = {255, 128, 0, 255, 128, 0, 0}, 
                    sprite = {0.8, 0.3}, 
                    shadow = {150, 100, 0}, 
                    far = 800, fog = 100, ground = 1, 
                    cloud = {0, 0, 0, 14, 15, 18}, 
                    water = {25, 51, 52, 240}, 
                    rgb1 = {102, 132, 227, 127}, 
                    rgb2 = {4, 85, 95, 162}, 
                    cloud2 = {90, 220, 0, 1}}, 
                [6] = {amb = {22, 17, 8}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 1.2}, 
                    sprite = {0.2, 0.5}, 
                    shadow = {140, 93, 0}, 
                    far = 800, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {149, 94, 0, 127}, 
                    cloud2 = {177, 220, 0, 1}}, 
                [7] = {
                    amb = {12, 4, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {63, 205, 255, 62, 200, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.2}, 
                    sprite = {0, 1}, 
                    shadow = {211, 0, 149}, 
                    far = 800, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {58, 110, 115, 127}, 
                    rgb2 = {123, 70, 14, 121}, 
                    cloud2 = {177, 220, 0, 1}}, 
                [12] = {
                    amb = {12, 10, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {30, 117, 210, 53, 162, 227}, 
                    sun = {189, 175, 0, 168, 98, 14, 1.7}, 
                    sprite = {0, 1}, 
                    shadow = {236, 0, 190}, 
                    far = 800, fog = 100, ground = 0, 
                    cloud = {44, 34, 23, 129, 128, 123}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {70, 121, 120, 120}, 
                    rgb2 = {160, 88, 21, 127}, 
                    cloud2 = {88, 220, 0, 1}}, 
                [19] = {
                    amb = {16, 10, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {74, 156, 208, 67, 144, 182}, 
                    sun = {198, 128, 0, 255, 128, 0, 7.5}, 
                    sprite = {0, 1}, 
                    shadow = {110, 40, 75}, 
                    far = 800, fog = 100, ground = 0.8, 
                    cloud = {120, 40, 40, 155, 155, 155}, 
                    water = {50, 97, 97, 240}, 
                    rgb1 = {90, 123, 113, 106}, 
                    rgb2 = {114, 61, 10, 127}, 
                    cloud2 = {88, 220, 0, 1}}, 
                [20] = {
                    amb = {12, 10, 4}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 167, 118, 65}, 
                    sun = {255, 128, 0, 255, 128, 0, 2}, 
                    sprite = {0.2, 1}, 
                    shadow = {100, 60, 0}, 
                    far = 800, fog = 43, ground = 1, 
                    cloud = {0, 0, 0, 163, 83, 63}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {129, 93, 71, 127}, 
                    rgb2 = {66, 27, 0, 127}, 
                    cloud2 = {177, 220, 0, 1}}, 
                [22] = {
                    amb = {22, 20, 10}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {172, 143, 88, 167, 118, 65}, 
                    sun = {255, 128, 0, 5, 8, 0, 1}, 
                    sprite = {0.4, 0.4}, 
                    shadow = {160, 100, 0}, 
                    far = 800, fog = 41, ground = 1, 
                    cloud = {70, 27, 10, 55, 55, 55}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {129, 0, 0, 127}, 
                    rgb2 = {66, 106, 0, 127}, 
                    cloud2 = {111, 60, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Sunny Smog LA", 
            hours = {
                [0] = {
                    amb = {33, 33, 33}, 
                    obj = {249, 244, 235}, 
                    dir = {255, 255, 255}, 
                    sky = {19, 14, 19, 6, 6, 17}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.9, 0.3
                    }, 
                    shadow = {200, 102, 0}, 
                    far = 800, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 240}, 
                    rgb1 = {50, 61, 114, 127}, 
                    rgb2 = {14, 46, 55, 127}, 
                    cloud2 = {25, 80, 0, 1}}, 
                [5] = {
                    amb = {22, 33, 33}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {16, 16, 22, 15, 15, 20}, 
                    sun = {255, 128, 0, 255, 128, 0, 0}, 
                    sprite = {0.9, 0.3}, 
                    shadow = {150, 100, 0}, 
                    far = 800, fog = 50, ground = 1, 
                    cloud = {35, 9, 10, 27, 30, 36}, 
                    water = {53, 104, 104, 240}, 
                    rgb1 = {93, 90, 114, 127}, 
                    rgb2 = {34, 40, 30, 127}, 
                    cloud2 = {25, 80, 0, 1}}, 
                [6] = {
                    amb = {20, 16, 16}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0.4, 0.2}, 
                    shadow = {140, 93, 0}, 
                    far = 800, fog = 50, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {149, 94, 0, 127}, 
                    cloud2 = {25, 120, 0, 1}}, 
                [7] = {
                    amb = {11, 7, 1}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 114, 148, 166}, 
                    sun = {255, 128, 0, 255, 128, 0, 1.2}, 
                    sprite = {0.8, 0.2}, 
                    shadow = {100, 50, 75}, 
                    far = 800, fog = 10, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {106, 107, 84, 127}, 
                    rgb2 = {96, 61, 15, 127}, 
                    cloud2 = {25, 120, 0, 1}}, 
                [12] = {
                    amb = {14, 7, 2}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 147, 255, 129, 148, 182}, 
                    sun = {255, 128, 0, 255, 128, 0, 1}, 
                    sprite = {0.3, 0.2}, 
                    shadow = {236, 0, 190}, 
                    far = 800, fog = 10, ground = 0, 
                    cloud = {44, 34, 23, 145, 164, 183}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {82, 80, 43, 127}, 
                    rgb2 = {125, 94, 40, 127}, 
                    cloud2 = {25, 50, 0, 1}}, 
                [19] = {
                    amb = {10, 10, 5}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {93, 127, 157, 90, 144, 182}, 
                    sun = {198, 128, 0, 255, 128, 0, 7.5}, 
                    sprite = {1, 0.3}, 
                    shadow = {110, 40, 103}, 
                    far = 800, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {50, 97, 97, 240}, 
                    rgb1 = {124, 93, 67, 106}, 
                    rgb2 = {86, 50, 10, 127}, 
                    cloud2 = {25, 150, 0, 1}}, 
                [20] = {
                    amb = {10, 5, 5}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 167, 118, 65}, 
                    sun = {255, 128, 0, 255, 128, 0, 2}, 
                    sprite = {1, 0.3}, 
                    shadow = {100, 60, 0}, 
                    far = 800, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 72, 107, 159}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {121, 102, 80, 127}, 
                    rgb2 = {44, 24, 0, 127}, 
                    cloud2 = {25, 150, 0, 1}}, 
                [22] = {
                    amb = {22, 12, 15}, 
                    obj = {255, 222, 222}, 
                    dir = {255, 255, 255}, 
                    sky = {209, 150, 84, 167, 118, 65}, 
                    sun = {255, 128, 0, 5, 8, 0, 1}, 
                    sprite = {0.3, 0.3}, 
                    shadow = {160, 100, 0}, 
                    far = 800, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 15, 11, 34}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {44, 24, 0, 127}, 
                    cloud2 = {25, 80, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny Smog LA", 
            hours = {
                [0] = {
                    amb = {33, 33, 33}, 
                    obj = {210, 188, 166}, 
                    dir = {255, 255, 255}, 
                    sky = {22, 5, 12, 13, 13, 31}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.6, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 800, fog = 155, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 240}, 
                    rgb1 = {57, 87, 87, 127}, 
                    rgb2 = {21, 27, 88, 127}, 
                    cloud2 = {122, 90, 0, 1}}, 
                [5] = {
                    amb = {33, 33, 33}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {15, 15, 16, 14, 14, 20}, 
                    sun = {255, 128, 0, 255, 128, 0, 0}, 
                    sprite = {1, 0.4}, 
                    shadow = {150, 100, 0}, 
                    far = 800, fog = 155, ground = 1, 
                    cloud = {35, 9, 10, 27, 30, 36}, 
                    water = {53, 104, 104, 240}, 
                    rgb1 = {50, 78, 114, 127}, 
                    rgb2 = {34, 40, 30, 127}, 
                    cloud2 = {122, 90, 0, 1}}, 
                [6] = {
                    amb = {33, 33, 33}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0.9, 0.3}, 
                    shadow = {140, 93, 0}, 
                    far = 800, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {149, 94, 0, 127}, 
                    cloud2 = {122, 120, 0, 1}}, 
                [7] = {
                    amb = {20, 11, 5}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 222, 204, 200}, 
                    sun = {255, 128, 0, 255, 128, 0, 1.2}, 
                    sprite = {0.1, 0.2}, 
                    shadow = {236, 50, 75}, 
                    far = 800, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {106, 106, 106, 127}, 
                    rgb2 = {96, 61, 15, 127}, 
                    cloud2 = {122, 180, 0, 1}}, 
                [12] = {
                    amb = {15, 7, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {79, 140, 243, 143, 175, 175}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {236, 0, 190}, 
                    far = 800, fog = 80, ground = 0, 
                    cloud = {44, 34, 23, 145, 164, 183}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {127, 123, 110, 127}, 
                    rgb2 = {99, 74, 10, 127}, 
                    cloud2 = {122, 180, 0, 1}}, 
                [19] = {
                    amb = {15, 11, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 90, 144, 182}, 
                    sun = {255, 55, 0, 255, 255, 255, 4.3}, 
                    sprite = {0.4, 0.3}, 
                    shadow = {222, 40, 75}, 
                    far = 800, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {50, 97, 97, 240}, 
                    rgb1 = {124, 124, 107, 106}, 
                    rgb2 = {86, 50, 10, 127}, 
                    cloud2 = {122, 180, 0, 1}}, 
                [20] = {
                    amb = {15, 5, 0}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 167, 118, 65}, 
                    sun = {255, 128, 0, 255, 128, 0, 2}, 
                    sprite = {0.7, 0.3}, 
                    shadow = {100, 60, 0}, 
                    far = 800, 
                    fog = 10, 
                    ground = 1, 
                    cloud = {120, 40, 40, 72, 107, 159}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {121, 93, 71, 127}, 
                    rgb2 = {44, 24, 0, 127}, 
                    cloud2 = {122, 120, 0, 1}}, 
                [22] = {
                    amb = {33, 12, 12}, 
                    obj = {210, 194, 182}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 197, 103, 39}, 
                    sun = {255, 128, 0, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.3}, 
                    shadow = {160, 100, 0}, 
                    far = 800, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 15, 11, 34}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {117, 124, 83, 127}, 
                    rgb2 = {66, 27, 0, 127}, 
                    cloud2 = {122, 90, 0, 1}
                }
            }
        }, 
        {
            name = "Cloudy LA", 
            hours = {
                [0] = {
                    amb = {10, 30, 30}, 
                    obj = {157, 176, 208}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 10, 23, 33}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.2, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 700, fog = 79, ground = 1, 
                    cloud = {30, 20, 0, 23, 28, 30}, 
                    water = {55, 55, 66, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {45, 49, 32, 127}, 
                    cloud2 = {155, 51, 0, 1}}, 
                [5] = {
                    amb = {10, 24, 27}, 
                    obj = {160, 171, 202}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 10, 22, 33}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 700, fog = -22, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {55, 55, 66, 240}, 
                    rgb1 = {80, 85, 91, 127}, 
                    rgb2 = {98, 120, 120, 127}, 
                    cloud2 = {155, 100, 0, 1}}, 
                [6] = {
                    amb = {16, 31, 31}, 
                    obj = {163, 187, 192}, 
                    dir = {255, 255, 255}, 
                    sky = {22, 22, 22, 15, 25, 27}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.4}, 
                    sprite = {0.1, 0.9}, 
                    shadow = {200, 100, 0}, 
                    far = 700, fog = 90, ground = 0.8, 
                    cloud = {100, 34, 25, 23, 28, 30}, 
                    water = {77, 77, 88, 240}, 
                    rgb1 = {63, 80, 80, 127}, 
                    rgb2 = {122, 122, 90, 127}, 
                    cloud2 = {155, 180, 0, 1}}, 
                [7] = {
                    amb = {22, 22, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {125, 145, 151, 125, 145, 151}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.1, 0.7}, 
                    shadow = {80, 50, 0}, 
                    far = 700, fog = -22, ground = 0.5, 
                    cloud = {120, 40, 40, 92, 116, 125}, 
                    water = {77, 77, 88, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {45, 28, 12, 127}, 
                    cloud2 = {155, 180, 0, 1}}, 
                [12] = {
                    amb = {22, 22, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {125, 145, 151, 125, 145, 151}, 
                    sun = {10, 10, 0, 10, 0, 0, 2.8}, 
                    sprite = {0.1, 0.5}, 
                    shadow = {80, 0, 120}, 
                    far = 700, fog = -22, ground = 0.3, 
                    cloud = {120, 100, 100, 92, 116, 123}, 
                    water = {125, 125, 125, 240}, 
                    rgb1 = {80, 80, 80, 127}, 
                    rgb2 = {122, 122, 122, 127}, 
                    cloud2 = {155, 180, 0, 1}}, 
                [19] = {
                    amb = {22, 22, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {125, 145, 151, 125, 145, 151}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {80, 0, 0}, 
                    far = 700, fog = -22, ground = 0.8, 
                    cloud = {120, 100, 100, 92, 116, 123}, 
                    water = {123, 128, 134, 240}, 
                    rgb1 = {44, 44, 44, 127}, 
                    rgb2 = {122, 122, 122, 127}, 
                    cloud2 = {155, 180, 0, 1}}, 
                [20] = {
                    amb = {22, 22, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {34, 56, 62, 62, 72, 75}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.1, 1}, 
                    shadow = {80, 50, 0}, 
                    far = 700, fog = -22, ground = 1, 
                    cloud = {120, 100, 100, 46, 58, 61}, 
                    water = {122, 126, 134, 240}, 
                    rgb1 = {90, 90, 90, 127}, 
                    rgb2 = {90, 122, 122, 127}, 
                    cloud2 = {155, 180, 0, 1}}, 
                [22] = {
                    amb = {24, 28, 20}, 
                    obj = {222, 200, 200}, 
                    dir = {255, 255, 255}, 
                    sky = {15, 15, 20, 20, 22, 22}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.4, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 700, fog = 111, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {10, 70, 60, 240}, 
                    rgb1 = {64, 64, 100, 127}, 
                    rgb2 = {69, 70, 87, 127}, 
                    cloud2 = {155, 20, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny SF", 
            hours = {
                [0] = {
                    amb = {20, 30, 30}, 
                    obj = {133, 133, 133}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 8, 12, 10, 36, 65}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.4, 0.5}, 
                    shadow = {200, 100, 0}, 
                    far = 450, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {19, 40, 52, 240}, 
                    rgb1 = {66, 66, 66, 127}, 
                    rgb2 = {88, 56, 28, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [5] = {
                    amb = {20, 30, 30}, 
                    obj = {143, 143, 143}, 
                    dir = {255, 255, 255}, 
                    sky = {15, 22, 32, 4, 32, 66}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 0.3}, 
                    shadow = {150, 100, 0}, 
                    far = 454, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {21, 41, 56, 240}, 
                    rgb1 = {66, 99, 66, 127}, 
                    rgb2 = {88, 47, 23, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [6] = {
                    amb = {30, 30, 30}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 3}, 
                    sprite = {0.9, 0.2}, 
                    shadow = {140, 100, 0}, 
                    far = 455, fog = 66, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {178, 160, 160, 200}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {45, 47, 23, 127}, 
                    cloud2 = {50, 120, 70, 1}}, 
                [7] = {
                    amb = {24, 26, 30}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 187, 146, 116}, 
                    sun = {255, 128, 0, 255, 0, 0, 3.3}, 
                    sprite = {0.1, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 455, fog = 66, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {55, 62, 64, 127}, 
                    rgb2 = {66, 66, 80, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [12] = {
                    amb = {30, 30, 30}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 90, 200, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 455, fog = 66, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {44, 94, 89, 127}, 
                    rgb2 = {45, 66, 36, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [19] = {
                    amb = {30, 30, 30}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 111, 155, 155}, 
                    sun = {255, 0, 0, 255, 0, 0, 3.3}, 
                    sprite = {0.2, 1}, 
                    shadow = {110, 40, 0}, 
                    far = 455, fog = 66, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {103, 95, 87, 240}, 
                    rgb1 = {33, 99, 99, 127}, 
                    rgb2 = {66, 66, 44, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [20] = {
                    amb = {30, 30, 30}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 189, 165, 155, 130},
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.3, 0.6}, 
                    shadow = {100, 60, 0}, 
                    far = 455, fog = 66, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {124, 66, 44, 127}, 
                    rgb2 = {66, 55, 23, 127}, 
                    cloud2 = {50, 120, 0, 1}}, 
                [22] = {
                    amb = {13, 13, 30}, 
                    obj = {143, 143, 143}, 
                    dir = {255, 255, 255}, 
                    sky = {20, 15, 45, 13, 44, 65}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.5, 0.5}, 
                    shadow = {160, 100, 0}, 
                    far = 455, fog = 66, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {44, 73, 96, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {45, 47, 23, 127}, 
                    cloud2 = {50, 112, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Sunny SF", 
            hours = {
                [0] = {
                    amb = {20, 30, 30}, 
                    obj = {133, 133, 133}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 36, 65, 10, 36, 65}, 
                    sun = {255, 128, 0, 5, 0, 0, 1}, 
                    sprite = {0.4, 0.5}, 
                    shadow = {200, 100, 0}, 
                    far = 450, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {19, 40, 52, 240}, 
                    rgb1 = {66, 66, 66, 127}, 
                    rgb2 = {88, 56, 28, 127}, 
                    cloud2 = {0, 120, 0, 1}
                }, 
                [5] = {
                    amb = {20, 30, 30}, 
                    obj = {143, 143, 143}, 
                    dir = {255, 255, 255}, 
                    sky = {4, 32, 66, 4, 32, 66}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 0.3}, 
                    shadow = {150, 100, 0}, 
                    far = 454, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {21, 41, 56, 240}, 
                    rgb1 = {66, 99, 66, 127}, 
                    rgb2 = {88, 47, 23, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [6] = {
                    amb = {16, 20, 27}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {155, 155, 155, 198, 124, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.7}, 
                    sprite = {0.2, 0.2}, 
                    shadow = {140, 100, 0}, 
                    far = 455, fog = 66, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {178, 160, 160, 200}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {166, 94, 0, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [7] = {
                    amb = {12, 0, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {155, 155, 155, 198, 124, 85}, 
                    sun = {255, 128, 0, 255, 0, 0, 1.7}, 
                    sprite = {0.1, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 455, fog = 66, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {86, 86, 86, 127}, 
                    rgb2 = {166, 94, 0, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [12] = {
                    amb = {30, 30, 30}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 90, 200, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 455, fog = 66, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {44, 94, 89, 127}, 
                    rgb2 = {45, 66, 36, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [19] = {
                    amb = {30, 30, 30}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 111, 155, 155}, 
                    sun = {255, 0, 0, 255, 0, 0, 3.3}, 
                    sprite = {0.2, 1}, 
                    shadow = {110, 40, 0}, 
                    far = 455, fog = 66, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {103, 95, 87, 240}, 
                    rgb1 = {33, 99, 99, 127}, 
                    rgb2 = {66, 66, 44, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [20] = {
                    amb = {30, 30, 30}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 189, 165, 155, 130}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.3, 0.6}, 
                    shadow = {100, 60, 0}, 
                    far = 455, fog = 66, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {124, 66, 44, 127}, 
                    rgb2 = {66, 55, 23, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [22] = {
                    amb = {13, 13, 30}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {5, 25, 45, 13, 44, 65}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.5, 0.5}, shadow = {160, 100, 0}, 
                    far = 455, fog = 66, ground = 1, cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {44, 73, 96, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {45, 47, 23, 127     }, 
                    cloud2 = {0, 112, 0, 1}
                }
            }
        }, 
        {
            name = "Cloudy SF", 
            hours = {
                [0] = {
                    amb = {30, 30, 30}, 
                    obj = {108, 108, 101}, 
                    dir = {255, 255, 255}, 
                    sky = {11, 11, 11, 11, 11, 11}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {30, 20, 0, 23, 28, 30}, 
                    water = {55, 55, 66, 240}, 
                    rgb1 = {64, 64, 12, 127}, 
                    rgb2 = {88, 66, 66, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [5] = {
                    amb = {30, 22, 30}, 
                    obj = {108, 108, 101}, 
                    dir = {255, 255, 255}, 
                    sky = {14, 14, 14, 14, 14, 14}, 
                    sun = {10, 10, 0, 10, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {55, 55, 66, 240}, 
                    rgb1 = {77, 67, 52, 127}, 
                    rgb2 = {85, 72, 66, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [6] = {
                    amb = {30, 30, 30}, 
                    obj = {153, 153, 153}, 
                    dir = {255, 255, 255}, 
                    sky = {41, 46, 47, 31, 36, 37}, 
                    sun = {10, 10, 0, 10, 0, 0, 3.4}, 
                    sprite = {0.9, 0.9}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 0.8, 
                    cloud = {100, 34, 25, 23, 28, 30}, 
                    water = {77, 77, 88, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {77, 77, 77, 127}, 
                    cloud2 = {155, 0, 100, 1}}, 
                [7] = {
                    amb = {5, 5, 12}, 
                    obj = {153, 153, 153}, 
                    dir = {255, 255, 255}, 
                    sky = {62, 72, 75, 62, 72, 75}, 
                    sun = {10, 10, 0, 10, 0, 0, 0}, 
                    sprite = {0.8, 0.7}, 
                    shadow = {200, 50, 0}, 
                    far = 1150, fog = -22, ground = 0.5, 
                    cloud = {120, 40, 40, 46, 58, 61}, 
                    water = {77, 77, 88, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [12] = {
                    amb = {5, 5, 12}, 
                    obj = {122, 123, 123}, 
                    dir = {255, 255, 255}, 
                    sky = {125, 145, 151, 125, 145, 151}, 
                    sun = {10, 10, 0, 10, 0, 0, 2.8}, 
                    sprite = {0.7, 0.5}, 
                    shadow = {80, 0, 120}, 
                    far = 1150, fog = -22, ground = 0.3, 
                    cloud = {120, 100, 100, 92, 116, 123}, 
                    water = {125, 125, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [19] = {
                    amb = {5, 30, 30}, 
                    obj = {123, 123, 123}, 
                    dir = {255, 255, 255}, 
                    sky = {62, 72, 75, 62, 72, 75}, 
                    sun = {10, 10, 0, 10, 0, 0, 3.5}, 
                    sprite = {1, 1}, 
                    shadow = {80, 0, 0}, 
                    far = 1150, fog = -22, ground = 0.8, 
                    cloud = {120, 100, 100, 46, 58, 61}, 
                    water = {123, 128, 134, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [20] = {
                    amb = {30, 30, 30}, 
                    obj = {108, 108, 108}, 
                    dir = {255, 255, 255}, 
                    sky = {62, 72, 75, 62, 72, 75}, 
                    sun = {10, 10, 0, 10, 0, 0, 2}, 
                    sprite = {1, 1}, 
                    shadow = {80, 50, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {120, 100, 100, 46, 58, 61}, 
                    water = {122, 126, 134, 240}, 
                    rgb1 = {64, 64, 55, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {155, 0, 0, 1}}, 
                [22] = {
                    amb = {30, 30, 30}, 
                    obj = {108, 108, 108}, 
                    dir = {255, 255, 255}, 
                    sky = {41, 46, 47, 31, 36, 37}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {77, 77, 88, 240}, 
                    rgb1 = {64, 64, 12, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {155, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Rainy SF", 
            hours = {
                [0] = {
                    amb = {20, 30, 30}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.5, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 5, ground = 1, 
                    cloud = {30, 20, 0, 0, 0, 0}, 
                    water = {59, 68, 77, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {16, 48, 10, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.8}, 
                [5] = {
                    amb = {20, 30, 30}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.6, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 5, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {59, 68, 77, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.8}, 
                [6] = {
                    amb = {20, 30, 30}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.4}, 
                    sprite = {0.4, 0.9}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 5, ground = 0.9, 
                    cloud = {100, 34, 25, 0, 0, 0}, 
                    water = {62, 72, 77, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {155, 0, 100, 1}, 
                    rain = 0.8}, 
                [7] = {
                    amb = {20, 30, 30}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 2.5}, 
                    sprite = {0.4, 0.7}, 
                    shadow = {80, 80, 0}, 
                    far = 650, fog = 5, ground = 0.8, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {107, 117, 122, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.6}, 
                [12] = {
                    amb = {20, 30, 30}, 
                    obj = {186, 186, 186}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.1, 0.5}, 
                    shadow = {80, 50, 120}, 
                    far = 650, fog = 5, ground = 0.7, 
                    cloud = {120, 100, 100, 0, 0, 0}, 
                    water = {141, 141, 140, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 38, 30, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.7}, 
                [19] = {
                    amb = {20, 30, 30}, 
                    obj = {135, 173, 193}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.5}, 
                    sprite = {0.5, 1}, 
                    shadow = {80, 50, 0}, 
                    far = 650, fog = 5, ground = 0.9, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {116, 135, 144, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {10, 46, 22, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.8}, 
                [20] = {
                    amb = {20, 30, 30}, 
                    obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 2}, 
                    sprite = {1, 1}, 
                    shadow = {80, 80, 0}, 
                    far = 650, fog = 5, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {132, 176, 189, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.8}, 
                [22] = {
                    amb = {20, 30, 30}, 
                    obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 5, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {161, 176, 189, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {155, 0, 0, 1}, 
                    rain = 0.8
                }
            }
        }, 
        {
            name = "Foggy SF", 
            hours = {
                [0] = {
                    amb = {33, 33, 33}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 40, 40, 0, 40, 40}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.7, 1}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -200, ground = 1, 
                    cloud = {30, 20, 0, 0, 0, 0}, 
                    water = {120, 120, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [5] = {
                    amb = {33, 33, 33}, 
                    obj = {210, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 45, 45, 0, 45, 45}, 
                    sun = {10, 10, 0, 10, 0, 0, 0}, 
                    sprite = {0.7, 1}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -200, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {120, 120, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [6] = {
                    amb = {33, 33, 33}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 45, 45, 0, 45, 45}, 
                    sun = {0, 10, 0, 10, 0, 0, 3.4}, 
                    sprite = {0.7, 0.9}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -200, ground = 0.8, 
                    cloud = {100, 34, 25, 0, 0, 0}, 
                    water = {128, 128, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 100, 1}}, 
                [7] = {
                    amb = {33, 33, 33}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 50, 50, 40, 50, 50}, 
                    sun = {10, 10, 0, 10, 0, 0, 2.5}, 
                    sprite = {0.7, 0.7}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -200, ground = 0.6, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {128, 128, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [12] = {
                    amb = {13, 13, 13}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {146, 155, 155, 127, 144, 144}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.3, 0.5}, 
                    shadow = {60, 50, 60}, 
                    far = 250, fog = -30, ground = 0.3, 
                    cloud = {120, 100, 100, 0, 0, 0}, 
                    water = {128, 128, 128, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [19] = {
                    amb = {13, 13, 13}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {100, 100, 105, 100, 100, 105}, 
                    sun = {10, 10, 0, 10, 0, 0, 3.5}, 
                    sprite = {0.3, 1}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -70, ground = 0.8, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {123, 123, 124, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 111, 0, 1}}, 
                [20] = {
                    amb = {13, 13, 13}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {41, 60, 60, 35, 53, 50}, 
                    sun = {10, 10, 0, 10, 0, 0, 2}, 
                    sprite = {1, 1}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -80, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {122, 121, 124, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}}, 
                [22] = {
                    amb = {33, 33, 33}, 
                    obj = {141, 141, 141}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 40, 40, 0, 40, 40}, 
                    sun = {10, 10, 0, 10, 0, 0, 1}, 
                    sprite = {0.7, 1}, 
                    shadow = {60, 50, 0}, 
                    far = 150, fog = -100, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {123, 124, 120, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {30, 30, 32, 127}, 
                    cloud2 = {0, 120, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny Vegas", 
            hours = {
                [0] = {
                    amb = {25, 22, 22}, 
                    obj = {144, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {16, 7, 23, 24, 0, 37}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {0.8, 0.3}, 
                    shadow = {200, 100, 0}, 
                    far = 1000, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {88, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [5] = {
                    amb = {24, 16, 25}, 
                    obj = {138, 138, 138}, 
                    dir = {255, 255, 255}, 
                    sky = {20, 4, 19, 31, 11, 27}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {0.8, 0.3}, 
                    shadow = {150, 100, 0}, 
                    far = 1000, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {64, 64, 152, 127}, 
                    rgb2 = {79, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [6] = {
                    amb = {0, 5, 10}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0.1, 0.4}, 
                    shadow = {140, 100, 0}, 
                    far = 1000, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {77, 66, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [7] = {
                    amb = {13, 13, 1}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 90, 200, 255}, 
                    sun = {255, 128, 0, 255, 0, 0, 3.3}, 
                    sprite = {0.1, 0.2}, 
                    shadow = {100, 50, 0}, 
                    far = 1000, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 64, 22, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [12] = {
                    amb = {13, 13, 1}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 90, 200, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.3, 0.1}, 
                    shadow = {150, 0, 150}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {128, 111, 44, 127}, 
                    cloud2 = {122, 88, 0, 1}}, 
                [19] = {
                    amb = {1, 1, 1}, 
                    obj = {163, 159, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 90, 200, 255}, 
                    sun = {255, 255, 255, 255, 255, 255, 3.5}, 
                    sprite = {1, 0.2}, 
                    shadow = {110, 40, 0}, 
                    far = 1000, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {153, 95, 87, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {122, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [20] = {
                    amb = {1, 1, 0}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 136, 110, 74}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {1, 0.2}, 
                    shadow = {100, 60, 0}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {127, 93, 71, 127}, 
                    rgb2 = {83, 11, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [22] = {
                    amb = {12, 6, 12}, 
                    obj = {138, 138, 138}, 
                    dir = {255, 255, 255}, 
                    sky = {31, 15, 44, 39, 24, 64}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.3}, 
                    shadow = {160, 100, 0}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Sunny Vegas", 
            hours = {
                [0] = {
                    amb = {22, 22, 22}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {9, 6, 9, 18, 15, 44}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {0.7, 0.3}, 
                    shadow = {200, 100, 0}, 
                    far = 1000, fog = 200, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {77, 77, 77, 127}, 
                    rgb2 = {88, 66, 41, 127}, 
                    cloud2 = {0, 30, 0, 1}}, 
                [5] = {
                    amb = {12, 12, 12}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 5, 10, 16, 1, 30}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {0.5, 0.4}, 
                    shadow = {150, 100, 0}, 
                    far = 1000, fog = 200, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {124, 106, 116, 127}, 
                    rgb2 = {52, 27, 0, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [6] = {
                    amb = {12, 12, 12}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {141, 99, 81, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0.1, 1}, 
                    shadow = {140, 100, 0}, 
                    far = 1000, fog = 0, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 240}, 
                    rgb1 = {66, 66, 66, 127}, 
                    rgb2 = {90, 70, 20, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [7] = {
                    amb = {13, 4, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 90}, 
                    sun = {255, 128, 0, 255, 0, 0, 3.7}, 
                    sprite = {0, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 1000, fog = 0, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {124, 60, 60, 60}, 
                    rgb2 = {89, 91, 44, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [12] = {
                    amb = {13, 13, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 90, 200, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {64, 64, 64, 64}, 
                    rgb2 = {90, 80, 33, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [19] = {
                    amb = {13, 13, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 90, 200, 255}, 
                    sun = {255, 47, 0, 255, 0, 0, 2.5}, 
                    sprite = {0.4, 0.3}, 
                    shadow = {110, 40, 0}, 
                    far = 1000, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {143, 121, 87, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {114, 57, 27, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [20] = {
                    amb = {13, 13, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 189, 165, 155, 130}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.6, 0.5}, 
                    shadow = {100, 60, 0}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {55, 55, 55, 127}, 
                    rgb2 = {120, 50, 0, 127}, 
                    cloud2 = {0, 90, 0, 1}}, 
                [22] = {
                    amb = {22, 22, 23}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 0, 0, 18, 15, 44}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.7, 0.5}, 
                    shadow = {160, 100, 0}, 
                    far = 1000, fog = 200, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {71, 46, 53, 240}, 
                    rgb1 = {77, 77, 77, 127}, 
                    rgb2 = {122, 55, 33, 127}, 
                    cloud2 = {0, 30, 0, 1}
                }
            }
        }, 
        {
            name = "Cloudy Vegas", 
            hours = {
                [0] = {
                    amb = {2, 20, 33}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {22, 33, 44, 11, 23, 44}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 1000, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {66, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {44, 0, 0, 1}}, 
                [5] = {
                    amb = {11, 22, 33}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {22, 33, 44, 22, 33, 44}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {150, 100, 0}, 
                    far = 1000, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {66, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {44, 0, 0, 1}}, 
                [6] = {
                    amb = {22, 22, 33}, 
                    obj = {188, 188, 187}, 
                    dir = {255, 255, 255}, 
                    sky = {84, 83, 88, 77, 77, 77}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.9, 1}, 
                    shadow = {140, 100, 0}, 
                    far = 1000, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 240}, 
                    rgb1 = {64, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [7] = {
                    amb = {22, 22, 22}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {211, 211, 255, 155, 155, 155}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.8, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 1000, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {66, 55, 21, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [12] = {
                    amb = {22, 22, 22}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {144, 144, 144, 122, 122, 122}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.3, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 100, 100, 88, 88, 88}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {66, 55, 21, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [19] = {
                    amb = {22, 22, 22}, 
                    obj = {188, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {144, 144, 144, 155, 155, 155}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {110, 40, 0}, 
                    far = 1000, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 88, 88, 88}, 
                    water = {153, 95, 87, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {66, 66, 50, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [20] = {
                    amb = {2, 2, 13}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {88, 88, 88, 88, 88, 88}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {100, 60, 0}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {120, 52, 79, 88, 88, 88}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [22] = {
                    amb = {2, 20, 33}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {22, 33, 44, 11, 23, 44}, 
                    sun = {0, 0, 8, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {160, 100, 0}, 
                    far = 1000, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {34, 27, 0, 127}, 
                    cloud2 = {44, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Sunny Countryside", 
            hours = {
                [0] = {
                    amb = {33, 33, 12}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 30, 30, 10, 22, 35}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 0.5}, 
                    shadow = {200, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {89, 97, 80, 127}, 
                    rgb2 = {17, 86, 109, 127}, 
                    cloud2 = {44, 120, 0, 1}}, 
                [5] = {
                    amb = {22, 25, 25}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 30, 30, 10, 22, 35}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 0.4}, 
                    shadow = {150, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {23, 30, 20, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {103, 107, 80, 127}, 
                    rgb2 = {10, 90, 100, 127}, 
                    cloud2 = {88, 120, 0, 1}}, 
                [6] = {
                    amb = {23, 23, 23}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 145, 227, 200, 144, 85}, 
                    sun = {255, 128, 0, 255, 255, 255, 8.4}, 
                    sprite = {0.9, 0.3}, 
                    shadow = {140, 100, 0}, 
                    far = 1500, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 240}, 
                    rgb1 = {124, 124, 69, 127}, 
                    rgb2 = {91, 9, 0, 127}, 
                    cloud2 = {75, 120, 0, 1}}, 
                [7] = {
                    amb = {22, 24, 22}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 187, 146, 116}, 
                    sun = {255, 128, 0, 255, 255, 255, 3.3}, 
                    sprite = {0.3, 0.4}, 
                    shadow = {100, 50, 0}, 
                    far = 1500, fog = 5, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {62, 64, 44, 127}, 
                    rgb2 = {80, 36, 22, 127}, 
                    cloud2 = {81, 120, 0, 1}}, 
                [12] = {
                    amb = {22, 5, 5}, 
                    obj = {203, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 57, 165, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1500, fog = 65, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {60, 60, 46, 127}, 
                    rgb2 = {86, 84, 52, 127}, 
                    cloud2 = {105, 120, 0, 1}}, 
                [19] = {
                    amb = {22, 22, 22}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 165, 155, 130}, 
                    sun = {255, 25, 0, 255, 255, 255, 7.5}, 
                    sprite = {0.6, 0.5}, 
                    shadow = {110, 40, 0}, 
                    far = 1500, fog = 5, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {148, 134, 97, 240}, 
                    rgb1 = {66, 66, 46, 127}, 
                    rgb2 = {80, 72, 32, 127}, 
                    cloud2 = {99, 120, 0, 1}}, 
                [20] = {
                    amb = {5, 5, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 189, 165, 155, 130}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.4, 0.4}, 
                    shadow = {100, 60, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {118, 89, 48, 127}, 
                    rgb2 = {69, 28, 6, 127}, 
                    cloud2 = {62, 120, 0, 1}}, 
                [22] = {
                    amb = {22, 22, 12}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {20, 15, 45, 66, 66, 64}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.3}, 
                    shadow = {160, 100, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {62, 62, 124, 62}, 
                    rgb2 = {132, 80, 40, 127}, 
                    cloud2 = {44, 120, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny Countryside", 
            hours = {
                [0] = {
                    amb = {33, 33, 33}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 22, 35, 10, 22, 35}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 0.5}, 
                    shadow = {200, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {89, 97, 80, 127}, 
                    rgb2 = {17, 86, 109, 127}, 
                    cloud2 = {44, 120, 0, 1}}, 
                [5] = {
                    amb = {22, 25, 25}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 22, 35, 10, 22, 35}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 0.4}, 
                    shadow = {150, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {23, 30, 20, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {103, 107, 80, 127}, 
                    rgb2 = {10, 90, 100, 127}, 
                    cloud2 = {88, 120, 0, 1}}, 
                [6] = {
                    amb = {23, 23, 23}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 145, 227, 200, 144, 85}, 
                    sun = {255, 255, 255, 122, 122, 0, 8.4}, 
                    sprite = {0.9, 0.3}, 
                    shadow = {140, 100, 0}, 
                    far = 1500, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 240}, 
                    rgb1 = {124, 124, 69, 127}, 
                    rgb2 = {91, 9, 0, 127}, 
                    cloud2 = {75, 120, 0, 1}}, 
                [7] = {
                    amb = {5, 5, 5}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 187, 146, 116}, 
                    sun = {255, 255, 255, 122, 122, 0, 3.3}, 
                    sprite = {0.3, 0.4}, 
                    shadow = {100, 50, 0}, 
                    far = 1500, fog = 5, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {62, 64, 44, 127}, 
                    rgb2 = {80, 36, 22, 127}, 
                    cloud2 = {81, 120, 0, 1}}, 
                [12] = {
                    amb = {22, 22, 5}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 180, 255, 57, 165, 255}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0.1, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1500, fog = 65, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {90, 170, 170, 240}, 
                    rgb1 = {60, 60, 46, 127}, 
                    rgb2 = {86, 84, 52, 127}, 
                    cloud2 = {105, 120, 0, 1}}, 
                [19] = {
                    amb = {22, 22, 5}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 157, 165, 155, 130}, 
                    sun = {255, 128, 0, 255, 0, 0, 7.5}, 
                    sprite = {0.6, 0.5}, 
                    shadow = {110, 40, 0}, 
                    far = 1500, fog = 5, ground = 0.8, 
                    cloud = {120, 40, 40, 152, 123, 96}, 
                    water = {148, 134, 97, 240}, 
                    rgb1 = {66, 66, 46, 127}, 
                    rgb2 = {80, 72, 32, 127}, 
                    cloud2 = {99, 120, 0, 1}}, 
                [20] = {
                    amb = {21, 21, 21}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {109, 142, 189, 165, 155, 130}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.4, 0.4}, 
                    shadow = {100, 60, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 54, 55, 55}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {118, 89, 48, 127}, 
                    rgb2 = {69, 28, 6, 127}, 
                    cloud2 = {62, 120, 0, 1}}, 
                [22] = {
                    amb = {33, 33, 33}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {20, 15, 45, 66, 66, 64}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.3}, 
                    shadow = {160, 100, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {62, 62, 124, 62}, 
                    rgb2 = {132, 80, 40, 127}, 
                    cloud2 = {44, 120, 0, 1}
                }
            }
        }, 
        {
            name = "Cloudy Countryside", 
            hours = {
                [0] = {
                    amb = {12, 22, 35}, 
                    obj = {200, 200, 200}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 9, 9, 1, 24, 32}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.4, 0.3}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {30, 20, 0, 23, 28, 30}, 
                    water = {32, 43, 66, 240}, 
                    rgb1 = {77, 77, 77, 127}, 
                    rgb2 = {99, 99, 83, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [5] = {
                    amb = {3, 18, 33}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 9, 9, 1, 24, 32}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.5, 0.3}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {26, 58, 66, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [6] = {
                    amb = {12, 22, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {41, 46, 47, 31, 36, 37}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.4}, 
                    sprite = {0.4, 0.3}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 0.8, 
                    cloud = {100, 34, 25, 23, 28, 30}, 
                    water = {42, 77, 88, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [7] = {
                    amb = {12, 22, 21}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {62, 72, 75, 62, 72, 75}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.1, 0.4}, 
                    shadow = {200, 50, 0}, 
                    far = 1150, fog = -22, ground = 0.5, 
                    cloud = {120, 40, 40, 46, 58, 61}, 
                    water = {52, 77, 88, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [12] = {
                    amb = {2, 5, 5}, 
                    obj = {188, 188, 183}, 
                    dir = {255, 255, 255}, 
                    sky = {125, 145, 151, 125, 145, 151}, 
                    sun = {0, 0, 0, 0, 9, 9, 2}, 
                    sprite = {0.3, 0.3}, 
                    shadow = {80, 0, 120}, 
                    far = 1150, fog = -22, ground = 0.3, 
                    cloud = {120, 100, 100, 92, 116, 123}, 
                    water = {97, 125, 125, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [19] = {
                    amb = {0, 5, 5}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {62, 72, 75, 62, 72, 75}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.5}, 
                    sprite = {0.3, 0.4}, 
                    shadow = {80, 0, 0}, 
                    far = 1150, fog = -22, ground = 0.8, 
                    cloud = {120, 100, 100, 46, 58, 61}, 
                    water = {102, 128, 134, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [20] = {
                    amb = {7, 5, 22}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {36, 36, 40, 31, 36, 44}, 
                    sun = {0, 0, 0, 0, 0, 0, 2}, 
                    sprite = {1, 0.2}, 
                    shadow = {80, 50, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {120, 100, 100, 46, 58, 61}, 
                    water = {105, 126, 134, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}}, 
                [22] = {
                    amb = {5, 22, 33}, 
                    obj = {190, 176, 169}, 
                    dir = {255, 255, 255}, 
                    sky = {7, 9, 9, 1, 24, 32}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {1, 0.2}, 
                    shadow = {200, 100, 0}, 
                    far = 1150, fog = -22, ground = 1, 
                    cloud = {70, 27, 10, 23, 28, 30}, 
                    water = {41, 77, 74, 240}, 
                    rgb1 = {124, 124, 124, 127}, 
                    rgb2 = {48, 48, 48, 127}, 
                    cloud2 = {122, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Rainy Countryside", 
            hours = {
                [0] = {
                    amb = {21, 21, 39}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 1  }, 
                    sprite = {0.6, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 155, ground = 1, 
                    cloud = {30, 20, 0, 0, 0, 0}, 
                    water = {58, 115, 150, 240}, 
                    rgb1 = {38, 64, 98, 127}, 
                    rgb2 = {0, 64, 20, 127}, 
                    cloud2 = {90, 55, 0, 1}, 
                    rain = 1
                }, 
                [5] = {
                    amb = {31, 31, 31}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {50, 50, 50, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.7, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 5, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {59, 68, 77, 240}, 
                    rgb1 = {94, 66, 55, 127}, 
                    rgb2 = {22, 66, 33, 127}, 
                    cloud2 = {90, 120, 0, 1}, 
                    rain = 1
                }, 
                [6] = {
                    amb = {31, 31, 31}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {39, 50, 50, 60, 60, 60}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.4}, 
                    sprite = {0.3, 0.9}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 161, ground = 0.9, 
                    cloud = {100, 34, 25, 0, 0, 0}, 
                    water = {62, 72, 77, 240}, 
                    rgb1 = {88, 89, 110, 127}, 
                    rgb2 = {0, 64, 20, 127}, 
                    cloud2 = {90, 120, 100, 1}, rain = 0.8}, 
                [7] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {69, 69, 69, 79, 79, 79}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0.5, 0.7}, 
                    shadow = {80, 80, 0}, 
                    far = 650, fog = 5, ground = 0.8, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {107, 117, 122, 240}, 
                    rgb1 = {80, 61, 81, 127}, 
                    rgb2 = {14, 61, 20, 127}, 
                    cloud2 = {90, 120, 0, 1}, 
                    rain = 0.9}, 
                [12] = {
                    amb = {21, 21, 21}, 
                    obj = {186, 186, 186}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.7, 0.5}, 
                    shadow = {80, 50, 120}, 
                    far = 650, fog = 5, ground = 0.7, 
                    cloud = {120, 100, 100, 0, 0, 0}, 
                    water = {141, 141, 140, 240}, 
                    rgb1 = {69, 69, 69, 127}, 
                    rgb2 = {55, 55, 55, 127}, 
                    cloud2 = {90, 120, 0, 1}, 
                    rain = 1
                }, 
                [19] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 193}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.5}, 
                    sprite = {0.8, 0.8}, 
                    shadow = {80, 50, 0}, 
                    far = 650, fog = 5, ground = 0.9, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {116, 135, 144, 240}, 
                    rgb1 = {60, 90, 85, 127}, 
                    rgb2 = {38, 42, 22, 127}, 
                    cloud2 = {90, 120, 0, 1}, 
                    rain = 1
                }, 
                [20] = {
                    amb = {22, 22, 22}, 
                    obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 2}, 
                    sprite = {0.8, 1.9}, 
                    shadow = {80, 80, 0}, 
                    far = 650, fog = 123, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {132, 176, 189, 240}, 
                    rgb1 = {38, 64, 99, 127}, 
                    rgb2 = {0, 55, 20, 127}, 
                    cloud2 = {90, 55, 0, 1}, 
                    rain = 1
                }, 
                [22] = {
                    amb = {31, 31, 39}, 
                    obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.5, 0.2}, 
                    shadow = {200, 100, 0}, 
                    far = 650, fog = 188, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {80, 105, 144, 240}, 
                    rgb1 = {38, 64, 98, 127}, 
                    rgb2 = {0, 55, 20, 127}, 
                    cloud2 = {90, 120, 0, 1}, 
                    rain = 1
                }
            }
        }, 
        {
            name = "Extra Sunny Desert", 
            hours = {
                [0] = {
                    amb = {5, 5, 11}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 0, 26, 45, 0, 64}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {84, 109, 141, 127}, 
                    rgb2 = {34, 17, 77, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [5] = {
                    amb = {5, 5, 15}, 
                    obj = {180, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {11, 0, 21, 80, 50, 58}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {0.5, 0.7}, 
                    shadow = {150, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {124, 93, 131, 127}, 
                    rgb2 = {34, 17, 14, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [6] = {
                    amb = {5, 5, 22}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 155, 155, 155, 8.4}, 
                    sprite = {0.1, 1}, 
                    shadow = {140, 100, 0}, 
                    far = 1500, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {159, 138, 120, 240}, 
                    rgb1 = {88, 88, 88, 127}, 
                    rgb2 = {144, 77, 0, 127}, 
                    cloud2 = {0, 69, 0, 1}}, 
                [7] = {
                    amb = {10, 10, 10}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {210, 231, 200, 250, 218, 143}, 
                    sun = {255, 128, 0, 155, 155, 155, 3.8}, 
                    sprite = {0.2, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 1500, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {64, 64, 56, 127}, 
                    rgb2 = {113, 55, 0, 127}, 
                    cloud2 = {0, 188, 0, 1}}, 
                [12] = {
                    amb = {0, 0, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {233, 231, 233, 250, 156, 158}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1500, fog = 111, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {126, 170, 140, 240}, 
                    rgb1 = {77, 77, 66, 127}, 
                    rgb2 = {120, 69, 0, 127}, 
                    cloud2 = {0, 122, 0, 1}}, 
                [19] = {
                    amb = {0, 0, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {210, 231, 200, 250, 218, 143}, 
                    sun = {255, 128, 0, 255, 0, 0, 7.5}, 
                    sprite = {0.6, 1}, 
                    shadow = {110, 40, 0}, 
                    far = 1500, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {139, 112, 87, 240}, 
                    rgb1 = {88, 88, 77, 127}, 
                    rgb2 = {92, 20, 0, 127}, 
                    cloud2 = {0, 188, 0, 1}}, 
                [20] = {
                    amb = {0, 0, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {76, 59, 26, 84, 67, 24}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.4, 1}, 
                    shadow = {100, 60, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 30, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {127, 96, 63, 127}, 
                    rgb2 = {165, 62, 0, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [22] = {
                    amb = {5, 5, 11}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {5, 11, 29, 54, 0, 64}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.5}, 
                    shadow = {160, 100, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {84, 109, 124, 127}, 
                    rgb2 = {34, 17, 77, 127}, 
                    cloud2 = {0, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Sunny Desert", 
            hours = {
                [0] = {
                    amb = {10, 10, 20}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {0, 0, 26, 45, 0, 64}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {84, 109, 141, 127}, 
                    rgb2 = {34, 17, 77, 127}, 
                    cloud2 = {55, 0, 0, 1}}, 
                [5] = {
                    amb = {10, 10, 15}, 
                    obj = {180, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {11, 0, 21, 80, 50, 58}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {0.5, 0.7}, 
                    shadow = {150, 100, 0}, 
                    far = 1500, fog = 100, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {124, 93, 131, 127}, 
                    rgb2 = {34, 17, 14, 127}, 
                    cloud2 = {55, 0, 0, 1}}, 
                [6] = {
                    amb = {5, 5, 22}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {90, 205, 255, 200, 144, 85}, 
                    sun = {255, 128, 0, 155, 155, 155, 8.4}, 
                    sprite = {0.1, 1}, 
                    shadow = {140, 100, 0}, 
                    far = 1500, fog = 100, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {159, 138, 120, 240}, 
                    rgb1 = {88, 88, 88, 127}, 
                    rgb2 = {144, 77, 0, 127}, 
                    cloud2 = {100, 69, 0, 1}}, 
                [7] = {
                    amb = {0, 0, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {210, 231, 200, 250, 218, 143}, 
                    sun = {255, 128, 0, 155, 155, 155, 3.8}, 
                    sprite = {0.2, 1}, 
                    shadow = {100, 50, 0}, 
                    far = 1500, fog = 100, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 240}, 
                    rgb1 = {64, 64, 56, 127}, 
                    rgb2 = {113, 55, 0, 127}, 
                    cloud2 = {55, 188, 0, 1}}, 
                [12] = {
                    amb = {0, 0, 0}, 
                    obj = {188, 188, 188}, 
                    dir = {255, 255, 255}, 
                    sky = {233, 231, 233, 250, 156, 158}, 
                    sun = {255, 128, 0, 255, 128, 0, 2.5}, 
                    sprite = {0, 1}, 
                    shadow = {150, 0, 150}, 
                    far = 1500, fog = 111, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {126, 170, 140, 240}, 
                    rgb1 = {77, 77, 66, 127}, 
                    rgb2 = {120, 69, 0, 127}, 
                    cloud2 = {33, 122, 0, 1}}, 
                [19] = {
                    amb = {0, 0, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {210, 231, 200, 250, 218, 143}, 
                    sun = {255, 128, 0, 255, 0, 0, 7.5}, 
                    sprite = {0.6, 1}, 
                    shadow = {110, 40, 0}, 
                    far = 1500, fog = 10, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {139, 112, 87, 240}, 
                    rgb1 = {88, 88, 77, 127}, 
                    rgb2 = {92, 20, 0, 127}, 
                    cloud2 = {55, 188, 0, 1}}, 
                [20] = {
                    amb = {0, 0, 0}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {181, 150, 84, 167, 108, 65}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {0.4, 1}, 
                    shadow = {100, 60, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {120, 40, 40, 30, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {81, 85, 40, 127}, 
                    rgb2 = {66, 27, 0, 127}, 
                    cloud2 = {53, 0, 0, 1}}, 
                [22] = {
                    amb = {10, 10, 10}, 
                    obj = {163, 163, 163}, 
                    dir = {255, 255, 255}, 
                    sky = {5, 11, 29, 54, 0, 64}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {0.6, 0.5}, 
                    shadow = {160, 100, 0}, 
                    far = 1500, fog = 10, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {84, 109, 124, 127}, 
                    rgb2 = {34, 17, 77, 127}, 
                    cloud2 = {55, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Sandstorm Desert", 
            hours = {
                [0] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {55, 55, 55, 55, 55, 55}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {50, 100, 0}, 
                    far = 150, fog = -111, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {38, 38, 55, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {56, 38, 0, 127}, 
                    cloud2 = {0, 12, 0, 1}}, 
                [5] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {105, 102, 82, 105, 102, 82}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {50, 100, 0}, 
                    far = 150, fog = -111, ground = 1, 
                    cloud = {70, 27, 10, 50, 43, 36}, 
                    water = {53, 62, 68, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {56, 38, 0, 127}, 
                    cloud2 = {0, 12, 0, 1}}, 
                [6] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {112, 109, 89, 112, 109, 89}, 
                    sun = {255, 128, 0, 255, 128, 0, 8.4}, 
                    sprite = {0, 1}, 
                    shadow = {50, 100, 0}, 
                    far = 150, fog = -111, ground = 0.8, 
                    cloud = {100, 34, 25, 120, 92, 88}, 
                    water = {185, 160, 160, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {56, 32, 0, 127}, 
                    cloud2 = {0, 12, 0, 1}}, 
                [7] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {120, 117, 96, 120, 117, 96}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0, 1}, 
                    shadow = {50, 50, 0}, 
                    far = 150, fog = -111, ground = 0.5, 
                    cloud = {120, 40, 40, 159, 142, 106}, 
                    water = {145, 170, 170, 230}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {99, 89, 77, 127}, 
                    cloud2 = {0, 12, 0, 1}}, 
                [12] = {
                    amb = {11, 11, 11}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {166, 163, 140, 166, 163, 140}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {0, 1}, 
                    shadow = {50, 0, 0}, 
                    far = 150, fog = -111, ground = 1, 
                    cloud = {120, 100, 100, 180, 255, 255}, 
                    water = {45, 90, 90, 240}, 
                    rgb1 = {64, 44, 33, 127}, 
                    rgb2 = {99, 99, 77, 127}, 
                    cloud2 = {0, 44, 0, 1}}, 
                [19] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {97, 94, 78, 97, 94, 78}, 
                    sun = {255, 128, 0, 255, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {50, 40, 0}, 
                    far = 150, fog = -111, ground = 0.8, 
                    cloud = {120, 40, 40, 200, 123, 96}, 
                    water = {98, 95, 87, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {99, 99, 99, 127}, 
                    cloud2 = {0, 255, 0, 1}}, 
                [20] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 137, 137}, 
                    dir = {255, 255, 255}, 
                    sky = {87, 84, 69, 87, 84, 69}, 
                    sun = {255, 128, 0, 155, 0, 0, 2}, 
                    sprite = {1, 1}, 
                    shadow = {50, 60, 0}, 
                    far = 150, fog = -111, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {67, 67, 67, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {56, 38, 0, 127}, 
                    cloud2 = {0, 255, 0, 1}}, 
                [22] = {
                    amb = {21, 21, 21}, 
                    obj = {137, 155, 33}, 
                    dir = {255, 255, 255}, 
                    sky = {55, 55, 55, 55, 55, 55}, 
                    sun = {255, 5, 8, 5, 8, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {50, 100, 0}, 
                    far = 150, fog = -111, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {67, 67, 62, 240}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {56, 38, 0, 127}, 
                    cloud2 = {0, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Underwater", 
            hours = {
                [0] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 300, fog = 5, ground = 1, 
                    cloud = {30, 20, 0, 0, 0, 0}, 
                    water = {59, 68, 77, 192}, 
                    rgb1 = {104, 136, 83, 127}, 
                    rgb2 = {24, 76, 16, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [5] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 0}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 300, fog = 5, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {59, 68, 77, 192}, rgb1 = {94, 141, 95, 127}, 
                    rgb2 = {0, 70, 20, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [6] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {10, 10, 10, 20, 20, 20}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.4}, 
                    sprite = {0.9, 0.9}, 
                    shadow = {200, 100, 0}, 
                    far = 300, fog = 5, ground = 0.9, 
                    cloud = {100, 34, 25, 0, 0, 0}, 
                    water = {62, 72, 77, 192}, 
                    rgb1 = {124, 174, 110, 127}, 
                    rgb2 = {0, 64, 20, 127}, 
                    cloud2 = {255, 0, 100, 1}}, 
                [7] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 197}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 2.5}, 
                    sprite = {0.8, 0.7}, 
                    shadow = {80, 80, 0}, 
                    far = 300, fog = 5, ground = 0.8, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {107, 117, 122, 192}, 
                    rgb1 = {124, 153, 104, 127}, 
                    rgb2 = {0, 48, 20, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [12] = {
                    amb = {21, 21, 21}, 
                    obj = {186, 186, 186}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {0.7, 0.5},
                    shadow = {80, 50, 120}, 
                    far = 300, fog = 5, ground = 0.7, 
                    cloud = {120, 100, 100, 0, 0, 0}, 
                    water = {141, 141, 140, 255}, 
                    rgb1 = {124, 143, 109, 127}, 
                    rgb2 = {0, 51, 24, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [19] = {
                    amb = {21, 21, 21}, 
                    obj = {135, 173, 193}, 
                    dir = {255, 255, 255}, 
                    sky = {80, 80, 80, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 3.5}, 
                    sprite = {1, 1}, 
                    shadow = {80, 50, 0}, 
                    far = 300, fog = 5, ground = 0.9, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {116, 135, 144, 192}, 
                    rgb1 = {124, 139, 85, 127}, 
                    rgb2 = {10, 46, 22, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [20] = {
                    amb = {21, 21, 21}, 
                    obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 70, 70, 70}, 
                    sun = {0, 0, 0, 0, 0, 0, 2}, 
                    sprite = {1, 1}, 
                    shadow = {80, 80, 0}, 
                    far = 300, fog = 5, ground = 1, 
                    cloud = {120, 40, 40, 0, 0, 0}, 
                    water = {132, 176, 189, 192}, 
                    rgb1 = {63, 124, 99, 127}, 
                    rgb2 = {0, 87, 20, 127}, 
                    cloud2 = {255, 0, 0, 1}}, 
                [22] = {
                    amb = {21, 21, 21
                    }, obj = {167, 198, 223}, 
                    dir = {255, 255, 255}, 
                    sky = {40, 40, 40, 50, 50, 50}, 
                    sun = {0, 0, 0, 0, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 300, fog = 5, ground = 1, 
                    cloud = {70, 27, 10, 0, 0, 0}, 
                    water = {161, 176, 189, 192}, 
                    rgb1 = {124, 124, 91, 127}, 
                    rgb2 = {0, 85, 20, 127}, 
                    cloud2 = {255, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Colours 1", 
            hours = {
                [0] = {
                    amb = {0, 0, 0}, 
                    obj = {166, 166, 166}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 41, 127}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 0}}, 
                [5] = {
                    amb = {0, 0, 0}, 
                    obj = {121, 122, 122}, 
                    dir = {255, 255, 255}, 
                    sky = {1, 1, 1, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {65, 85, 65, 147}, 
                    rgb1 = {64, 64, 43, 127}, 
                    rgb2 = {73, 69, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [6] = {
                    amb = {0, 0, 0}, 
                    obj = {50, 50, 50}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [7] = {
                    amb = {0, 0, 0}, 
                    obj = {180, 180, 180}, 
                    dir = {255, 255, 255}, 
                    sky = {1, 1, 1, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 46, 127}, 
                    rgb2 = {65, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [12] = {
                    amb = {8, 2, 4}, 
                    obj = {22, 22, 22}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {87, 64, 85, 127}, 
                    rgb2 = {64, 33, 33, 127}, 
                    cloud2 = {0, 0, 0, 0}}, 
                [19] = {
                    amb = {7, 9, 2}, 
                    obj = {54, 55, 55}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {44, 64, 87, 127}, 
                    rgb2 = {99, 99, 99, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [20] = {
                    amb = {0, 0, 0}, 
                    obj = {20, 20, 20}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 146, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [22] = {
                    amb = {0, 0, 0}, 
                    obj = {20, 20, 20}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {0.5, 0.4}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {96, 92, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}
                }
            }
        }, 
        {
            name = "Extra Colours 2", 
            hours = {
                [0] = {
                    amb = {0, 0, 0}, 
                    obj = {99, 99, 99}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {61, 53, 30, 127}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [5] = {
                    amb = {30, 30, 30}, 
                    obj = {20, 20, 20}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 73, 80, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [6] = {
                    amb = {0, 0, 0}, 
                    obj = {20, 20, 20}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 50, 5, 50}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 78, fog = 50, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 16, 64, 127}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [7] = {
                    amb = {0, 0, 0}, 
                    obj = {133, 133, 133}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 0, 0, 0}, 
                    sun = {0, 0, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 0, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 64}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 0}}, 
                [12] = {
                    amb = {0, 0, 0}, 
                    obj = {0, 0, 0}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 0, 0, 0}, 
                    sun = {0, 0, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 0, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {44, 44, 44, 127}, 
                    rgb2 = {33, 64, 64, 127}, 
                    cloud2 = {234, 0, 0, 0}}, 
                [19] = {
                    amb = {0, 0, 0}, 
                    obj = {20, 20, 20}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 146, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}
                }, 
                [20] = {
                    amb = {0, 0, 0}, 
                    obj = {50, 50, 50}, 
                    dir = {255, 255, 255}, 
                    sky = {255, 255, 255, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 64, 64, 127}, 
                    cloud2 = {0, 0, 0, 1}}, 
                [22] = {
                    amb = {0, 0, 0}, 
                    obj = {190, 180, 180}, 
                    dir = {255, 255, 255}, 
                    sky = {1, 1, 1, 5, 5, 5}, 
                    sun = {255, 255, 0, 5, 0, 0, 1}, 
                    sprite = {1, 1}, 
                    shadow = {200, 100, 0}, 
                    far = 400, fog = 100, ground = 1, 
                    cloud = {30, 20, 0, 3, 3, 3}, 
                    water = {85, 85, 65, 192}, 
                    rgb1 = {64, 64, 64, 127}, 
                    rgb2 = {64, 64, 40, 127}, 
                    cloud2 = {0, 0, 0, 1}
                }
            }
        }
    };
    onClientResourceStart = function(__) 
        bindKey("F4", "down", "team_change");
        bindKey("num_4", "down", "help_me");
        bindKey("b", "down", "gun");
        bindKey("F1", "down", "control_panel");
        bindKey("pause", "down", "pause");
        bindKey("f", "down", "weapon_pickup");
        bindKey("backspace", "down", "weapon_drop");
        bindKey("m", "down", "votemap_toggle");
        bindKey("F2", "down", "player_config");
        bindKey("u", "down", "chatbox", "Adminsay");
        bindKey("r", "down", "reload");
        bindKey("horn", "down", toggleGangDriveby);
        bindKey("vehicle_look_left", "down", switchGangDrivebyWeapon);
        bindKey("vehicle_look_right", "down", switchGangDrivebyWeapon);
        setTimer(callServerFunction, 50, 1, "refreshMaps", localPlayer);
    end;
    createAdminPanel = function() 
        admin_window = guiCreateWindow(xscreen * 0.5 - serverAdminWindowWidth * 0.5 - 80, yscreen * 0.5 - serverAdminWindowHeight * 0.5 - 15, serverAdminWindowWidth + 160, serverAdminWindowHeight + 30, "Tactics " .. getTacticsData("version") .. " - Gamemode Control Panel", false);
        guiWindowSetSizable(admin_window, false);
        config_list = guiCreateGridList(0.01, 0.05, 0.23, 0.39, true, admin_window);
        guiGridListSetSortingEnabled(config_list, false);
        guiGridListAddColumn(config_list, "Configurations", 0.8);
        config_flags = guiCreateEdit(0.01, 0.45, 0.23, 0.04, "", true, admin_window);
        guiEditSetReadOnly(config_flags, true);
        guiSetFont(config_flags, "default-small");
        config_delete = guiCreateButton(0.01, 0.5, 0.23, 0.04, "Delete selected", true, admin_window);
        guiSetFont(config_delete, "default-bold-small");
        guiSetProperty(config_delete, "NormalTextColour", "C0FF0000");
        config_save = guiCreateButton(0.01, 0.55, 0.23, 0.04, "Save as...", true, admin_window);
        guiSetFont(config_save, "default-bold-small");
        guiSetProperty(config_save, "NormalTextColour", "C000FF00");
        config_rename = guiCreateButton(0.01, 0.6, 0.23, 0.04, "Rename config...", true, admin_window);
        guiSetFont(config_rename, "default-bold-small");
        config_add = guiCreateButton(0.01, 0.65, 0.23, 0.04, "Insert from HOST...", true, admin_window);
        guiSetFont(config_add, "default-bold-small");
        window_expert = guiCreateCheckBox(0.01, 0.82, 0.23, 0.05, "", false, true, admin_window);
        temp = guiCreateLabel(0.15, 0, 1, 1, "Show Expert Options", true, window_expert);
        guiSetEnabled(temp, false);
        temp = guiCreateLabel(0.15, 0.5, 1, 1, "For advanced users only!", true, window_expert);
        guiSetFont(temp, "default-small");
        guiLabelSetColor(temp, 255, 0, 0);
        guiSetEnabled(temp, false);
        window_updates = guiCreateButton(0.01, 0.89, 0.23, 0.04, "Check for updates", true, admin_window);
        guiSetFont(window_updates, "default-bold-small");
        guiSetProperty(window_updates, "NormalTextColour", "C080FF00");
        window_close = guiCreateButton(0.01, 0.94, 0.23, 0.04, "Close panel", true, admin_window);
        guiSetFont(window_close, "default-bold-small");
        admin_tabs = guiCreateTabPanel(0.25, 0.05, 0.74, 0.94, true, admin_window);
        guiSetFont(admin_tabs, "default-small");
        guiSetProperty(admin_tabs, "TabTextPadding", "0.016");
        admin_tab_players = guiCreateTab("Players", admin_tabs);
        admin_tab_maps = guiCreateTab("Maps", admin_tabs);
        admin_tab_settings = guiCreateTab("Settings", admin_tabs);
        admin_tab_teams = guiCreateTab("Teams", admin_tabs);
        admin_tab_weapons = guiCreateTab("Weapons", admin_tabs);
        admin_tab_vehicles = guiCreateTab("Vehicles", admin_tabs);
        admin_tab_weather = guiCreateTab("Weather", admin_tabs);
        admin_tab_shooting = guiCreateTab("Shooting", admin_tabs);
        guiSetVisible(admin_tab_shooting, false);
        admin_tab_handling = guiCreateTab("Handling", admin_tabs);
        guiSetVisible(admin_tab_handling, false);
        admin_tab_anticheat = guiCreateTab("AC", admin_tabs);
        guiSetVisible(admin_tab_anticheat, false);
        player_list = guiCreateGridList(0.02, 0.02, 0.47, 0.96, true, admin_tab_players);
        guiGridListSetSortingEnabled(player_list, false);
        guiGridListSetSelectionMode(player_list, 1);
        player_id = guiGridListAddColumn(player_list, "ID", 0.15);
        player_name = guiGridListAddColumn(player_list, "Name", 0.5);
        player_status = guiGridListAddColumn(player_list, "Status", 0.2);
        player_info = guiCreateMemo(0.51, 0.02, 0.47, 0.18, "", true, admin_tab_players);
        guiMemoSetReadOnly(player_info, true);
        guiSetFont(player_info, "default-small");
        player_infocopy = guiCreateButton(0.79, 0.65, 0.2, 0.3, "Copy", true, player_info);
        guiSetAlpha(player_infocopy, 1);
        guiSetFont(player_infocopy, "default-bold-small");
        temp = guiCreateLabel(0.51, 0.19999999999999998, 0.47, 0.04, "For everybody", true, admin_tab_players);
        guiLabelSetHorizontalAlign(temp, "center");
        guiSetFont(temp, "default-bold-small");
        player_swapsides = guiCreateButton(0.51, 0.26, 0.23, 0.05, "Swap Sides", true, admin_tab_players);
        guiSetFont(player_swapsides, "default-bold-small");
        player_balancecombobox = guiCreateComboBox(0.75, 0.26, 0.23, 0.2, "", true, admin_tab_players);
        guiComboBoxAddItem(player_balancecombobox, "Lite");
        guiComboBoxAddItem(player_balancecombobox, "Select");
        player_balancebg = guiCreateStaticImage(0, 1, 85, 21, "images/color_pixel.png", false, player_balancecombobox);
        guiSetProperty(player_balancebg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetProperty(player_balancebg, "AlwaysOnTop", "True");
        player_balance = guiCreateButton(0, 0, 1.2, 1, "Balance", true, player_balancebg);
        guiSetFont(player_balance, "default-bold-small");
        guiSetProperty(player_balance, "InheritsAlpha", "False");
        guiSetAlpha(player_balance, 1);
        player_resetstats = guiCreateButton(0.51, 0.32, 0.47, 0.05, "Reset Scores & Stats", true, admin_tab_players);
        guiSetFont(player_resetstats, "default-bold-small");
        player_healall = guiCreateButton(0.51, 0.38, 0.23, 0.05, "     Heal Players", true, admin_tab_players);
        guiSetFont(player_healall, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/health.png", false, player_healall), false);
        player_fixall = guiCreateButton(0.75, 0.38, 0.23, 0.05, "     Fix Vehicles", true, admin_tab_players);
        guiSetFont(player_fixall, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/car.png", false, player_fixall), false);
        temp = guiCreateLabel(0.51, 0.44, 0.47, 0.05, "For selected players", true, admin_tab_players);
        guiLabelSetHorizontalAlign(temp, "center");
        guiSetFont(temp, "default-bold-small");
        player_add = guiCreateButton(0.51, 0.5, 0.23, 0.05, "Add/Remove", true, admin_tab_players);
        guiSetFont(player_add, "default-bold-small");
        player_restore = guiCreateButton(0.75, 0.5, 0.23, 0.05, "     Restore", true, admin_tab_players);
        guiSetFont(player_restore, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/save.png", false, player_restore), false);
        player_setteamcombobox = guiCreateComboBox(0.51, 0.56, 0.23, 0.3, getTeamName(getElementsByType("team")[1]), true, admin_tab_players);
        player_setteambg = guiCreateStaticImage(0, 1, 85, 21, "images/color_pixel.png", false, player_setteamcombobox);
        guiSetProperty(player_setteambg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetProperty(player_setteambg, "AlwaysOnTop", "True");
        player_setteam = guiCreateButton(0, 0, 1.2, 1, getTeamName(getElementsByType("team")[1]), true, player_setteambg);
        guiSetFont(player_setteam, "default-bold-small");
        guiSetProperty(player_setteam, "InheritsAlpha", "False");
        guiSetAlpha(player_setteam, 1);
        player_specskinbtn = guiCreateButton(0.75, 0.56, 0.23, 0.05, "     Spectate Skin", true, admin_tab_players);
        guiSetFont(player_specskinbtn, "default-bold-small");
        player_specskin = guiCreateCheckBox(5, 3, 16, 16, "", false, false, player_specskinbtn);
        player_heal = guiCreateButton(0.51, 0.62, 0.23, 0.05, "     Heal", true, admin_tab_players);
        guiSetFont(player_heal, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/health.png", false, player_heal), false);
        player_fix = guiCreateButton(0.75, 0.62, 0.23, 0.05, "     Fix", true, admin_tab_players);
        guiSetFont(player_fix, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/car.png", false, player_fix), false);
        player_gunmenu = guiCreateButton(0.51, 0.6799999999999999, 0.23, 0.05, "     Gun Menu", true, admin_tab_players);
        guiSetFont(player_gunmenu, "default-bold-small");
        guiSetEnabled(guiCreateStaticImage(5, 3, 16, 16, "images/frag.png", false, player_gunmenu), false);
        player_takescreencombobox = guiCreateComboBox(0.75, 0.6799999999999999, 0.23, 0.37, "320x240:30%", true, admin_tab_players);
        guiComboBoxAddItem(player_takescreencombobox, "320x240:30%");
        guiComboBoxAddItem(player_takescreencombobox, "640x480:45%");
        guiComboBoxAddItem(player_takescreencombobox, "800x600:60%");
        guiComboBoxAddItem(player_takescreencombobox, "1024x768:75%");
        guiComboBoxAddItem(player_takescreencombobox, "My screens");
        player_takescreenbg = guiCreateStaticImage(0, 1, 85, 21, "images/color_pixel.png", false, player_takescreencombobox);
        guiSetProperty(player_takescreenbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetProperty(player_takescreenbg, "AlwaysOnTop", "True");
        player_takescreen = guiCreateButton(0, 0, 1.1, 1, "Screen Shot", true, player_takescreenbg);
        guiSetFont(player_takescreen, "default-bold-small");
        guiSetProperty(player_takescreen, "InheritsAlpha", "False");
        guiSetAlpha(player_takescreen, 1);
        player_redirect = guiCreateButton(0.51, 0.74, 0.23, 0.05, "Redirect", true, admin_tab_players);
        guiSetFont(player_redirect, "default-bold-small");
        player_pause = guiCreateButton(0.51, 0.9199999999999999, 0.47, 0.05, "", true, admin_tab_players);
        guiSetFont(player_pause, "default-bold-small");
        if not isRoundPaused() then
            guiSetText(player_pause, "Pause");
            guiSetProperty(player_pause, "NormalTextColour", "C0FF8000");
        else
            guiSetText(player_pause, "Unpause");
            guiSetProperty(player_pause, "NormalTextColour", "C00080FF");
        end;
        maps_search = guiCreateEdit(0.02, 0.02, 0.47, 0.05, "", true, admin_tab_maps);
        guiSetEnabled(guiCreateStaticImage(0.91, 0.1, 0.08, 0.8, "images/search.png", true, maps_search), false);
        server_maps = guiCreateGridList(0.02, 0.08, 0.47, 0.56, true, admin_tab_maps);
        guiGridListSetSortingEnabled(server_maps, false);
        guiGridListAddColumn(server_maps, "Mode", 0.3);
        guiGridListAddColumn(server_maps, "Name", 0.5);
        guiGridListSetSelectionMode(server_maps, 1);
        maps_include = guiCreateCheckBox(0.02, 0.65, 0.47, 0.05, "Include Disabled Maps", true, true, admin_tab_maps);
        maps_refresh = guiCreateButton(0.02, 0.71, 0.47, 0.05, "Refresh Maps Cache", true, admin_tab_maps);
        guiSetFont(maps_refresh, "default-bold-small");
        guiSetEnabled(maps_refresh, false);
        temp = guiCreateLabel(0.05, 0, 0.9, 1, "Hard!", true, maps_refresh);
        guiSetFont(temp, "default-small");
        guiLabelSetColor(temp, 255, 0, 0);
        guiLabelSetHorizontalAlign(temp, "right");
        guiLabelSetVerticalAlign(temp, "center");
        guiSetEnabled(temp, false);
        maps_disable = guiCreateButton(0.02, 0.77, 0.23, 0.05, "Enable/Disable", true, admin_tab_maps);
        guiSetFont(maps_disable, "default-bold-small");
        maps_end = guiCreateButton(0.26, 0.77, 0.23, 0.05, "End", true, admin_tab_maps);
        guiSetFont(maps_end, "default-bold-small");
        maps_next = guiCreateButton(0.02, 0.83, 0.23, 0.05, "Set next map", true, admin_tab_maps);
        guiSetFont(maps_next, "default-bold-small");
        maps_cancelnext = guiCreateButton(0.26, 0.83, 0.23, 0.05, "Cancel next", true, admin_tab_maps);
        guiSetFont(maps_cancelnext, "default-bold-small");
        maps_switch = guiCreateButton(0.02, 0.89, 0.47, 0.05, "Add >", true, admin_tab_maps);
        guiSetFont(maps_switch, "default-bold-small");
        temp = guiCreateLabel(0.51, 0.02, 0.24, 0.05, "Automatics Rounds", true, admin_tab_maps);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetVerticalAlign(temp, "center");
        cycler_automatics = guiCreateComboBox(0.75, 0.02, 0.23, 0.3, "Lobby", true, admin_tab_maps);
        guiComboBoxAddItem(cycler_automatics, "Lobby");
        guiComboBoxAddItem(cycler_automatics, "Cycle");
        guiComboBoxAddItem(cycler_automatics, "Voting");
        guiComboBoxAddItem(cycler_automatics, "Random");
        server_cycler = guiCreateGridList(0.51, 0.08, 0.47, 0.68, true, admin_tab_maps);
        guiGridListSetSortingEnabled(server_cycler, false);
        guiGridListAddColumn(server_cycler, "#", 0.08);
        guiGridListAddColumn(server_cycler, "Mode", 0.22);
        guiGridListAddColumn(server_cycler, "Name", 0.5);
        guiGridListSetSelectionMode(server_cycler, 1);
        cycler_moveup = guiCreateButton(0.51, 0.77, 0.23, 0.05, "Move Up", true, admin_tab_maps);
        guiSetFont(cycler_moveup, "default-bold-small");
        cycler_randomize = guiCreateButton(0.75, 0.77, 0.23, 0.05, "Randomize", true, admin_tab_maps);
        guiSetFont(cycler_randomize, "default-bold-small");
        cycler_movedown = guiCreateButton(0.51, 0.83, 0.23, 0.05, "Move Down", true, admin_tab_maps);
        guiSetFont(cycler_movedown, "default-bold-small");
        cycler_clear = guiCreateButton(0.75, 0.83, 0.23, 0.05, "Clear", true, admin_tab_maps);
        guiSetFont(cycler_clear, "default-bold-small");
        cycler_switch = guiCreateButton(0.51, 0.89, 0.47, 0.05, "< Remove", true, admin_tab_maps);
        guiSetFont(cycler_switch, "default-bold-small");
        temp = guiCreateLabel(0.02, 0.95, 0.96, 0.04, "Double-click to start map", true, admin_tab_maps);
        guiSetFont(temp, "default-small");
        guiLabelSetHorizontalAlign(temp, "center");
        modes_list = guiCreateGridList(0.02, 0.02, 0.3, 0.91, true, admin_tab_settings);
        guiGridListSetSortingEnabled(modes_list, false);
        guiGridListAddColumn(modes_list, "Section", 0.8);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Tactics", true, false);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "settings", false, false);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "glitches", false, false);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "cheats", false, false);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "limites", false, false);
        guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Modes", true, false);
        modes_disable = guiCreateButton(0.02, 0.94, 0.3, 0.04, "Enable / Disable", true, admin_tab_settings);
        guiSetFont(modes_disable, "default-bold-small");
        modes_rules = guiCreateGridList(0.33, 0.02, 0.65, 0.91, true, admin_tab_settings);
        guiGridListSetSortingEnabled(modes_rules, false);
        guiGridListAddColumn(modes_rules, "Rule", 0.45);
        guiGridListAddColumn(modes_rules, "Value", 0.45);
        temp = guiCreateLabel(0.33, 0.95, 0.65, 0.04, "Double-click to edit rule", true, admin_tab_settings);
        guiSetFont(temp, "default-small");
        guiLabelSetHorizontalAlign(temp, "center");
        weapons_scrollerbg = guiCreateGridList(9, 9, 288, 430, false, admin_tab_weapons);
        weapons_scroller = guiCreateScrollPane(3, 3, 284, 425, false, weapons_scrollerbg);
        weapons_items = {};
        weapons_adding = guiCreateButton(0, 10, 64, 64, "Add", false, weapons_scroller);
        guiSetFont(weapons_adding, "default-bold-small");
        guiSetProperty(weapons_adding, "NormalTextColour", "C000FF00");
        sortWeaponNames = {};
        for serverWeaponName in pairs(convertWeaponNamesToID) do
            table.insert(sortWeaponNames, serverWeaponName);
        end;
        local serverWeaponSlotPriority = {
            [2] = 1, 
            [3] = 2, 
            [4] = 2, 
            [5] = 3, 
            [6] = 3
        };
        table.sort(sortWeaponNames, function(serverFirstWeaponName, serverSecondWeaponName) 
            local serverFirstWeaponID = convertWeaponNamesToID[serverFirstWeaponName] or 46;
            local serverSecondWeaponID = convertWeaponNamesToID[serverSecondWeaponName] or 46;
            local serverFirstWeaponSlot = getSlotFromWeapon(serverFirstWeaponID);
            local serverSecondWeaponSlot = getSlotFromWeapon(serverSecondWeaponID);
            local serverFirstSlotPriority = serverWeaponSlotPriority[serverFirstWeaponSlot] or 4;
            local serverSecondSlotPriority = serverWeaponSlotPriority[serverSecondWeaponSlot] or 4;
            return serverFirstSlotPriority == serverSecondSlotPriority and not (serverFirstWeaponID >= serverSecondWeaponID) or serverFirstSlotPriority < serverSecondSlotPriority;
        end);
        weapons_addnames = guiCreateComboBox(302, 9, 161, 300, sortWeaponNames[1], false, admin_tab_weapons);
        for __, serverSortedWeaponName in ipairs(sortWeaponNames) do
            guiComboBoxAddItem(weapons_addnames, serverSortedWeaponName);
        end;
        weapons_addnamesbg = guiCreateStaticImage(0, 0, 138, 22, "images/color_pixel.png", false, weapons_addnames);
        guiSetProperty(weapons_addnamesbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetProperty(weapons_addnamesbg, "AlwaysOnTop", "True");
        weapons_addname = guiCreateEdit(0, 0, 1.1, 1, sortWeaponNames[1], true, weapons_addnamesbg);
        guiSetProperty(weapons_addname, "InheritsAlpha", "False");
        guiSetAlpha(weapons_addname, 1);
        weapons_addicon = guiCreateStaticImage(350, 36, 64, 64, "images/hud/" .. sortWeaponNames[1] .. ".png", false, admin_tab_weapons);
        guiSetEnabled(weapons_addicon, false);
        temp = guiCreateLabel(302, 106, 80, 22, "Ammo", false, admin_tab_weapons);
        guiSetEnabled(temp, false);
        weapons_addammo = guiCreateEdit(388, 104, 75, 22, "", false, admin_tab_weapons);
        guiEditSetMaxLength(weapons_addammo, 5);
        temp = guiCreateLabel(302, 130, 80, 22, "Limit", false, admin_tab_weapons);
        guiSetEnabled(temp, false);
        weapons_addlimit = guiCreateEdit(388, 128, 75, 22, "", false, admin_tab_weapons);
        guiEditSetMaxLength(weapons_addlimit, 5);
        temp = guiCreateLabel(302, 154, 80, 22, "Cost", false, admin_tab_weapons);
        guiSetEnabled(temp, false);
        weapons_addcost = guiCreateEdit(388, 152, 75, 22, "$", false, admin_tab_weapons);
        guiEditSetMaxLength(weapons_addcost, 7);
        temp = guiCreateLabel(302, 178, 80, 22, "Slot", false, admin_tab_weapons);
        guiSetEnabled(temp, false);
        weapons_addslot = guiCreateEdit(388, 176, 75, 22, "", false, admin_tab_weapons);
        guiEditSetMaxLength(weapons_addslot, 5);
        weapons_save = guiCreateButton(302, 200, 161, 22, "Add/Save", false, admin_tab_weapons);
        guiSetFont(weapons_save, "default-bold-small");
        guiSetProperty(weapons_save, "NormalTextColour", "C000FF00");
        weapons_remove = guiCreateButton(302, 224, 161, 22, "Remove", false, admin_tab_weapons);
        guiSetFont(weapons_remove, "default-bold-small");
        guiSetProperty(weapons_remove, "NormalTextColour", "C0FF0000");
        temp = guiCreateLabel(302, 394, 80, 22, "Max Slots", false, admin_tab_weapons);
        guiSetEnabled(temp, false);
        weapons_slots = guiCreateEdit(387, 392, 75, 22, tostring(getTacticsData("weapon_slots") or "0"), false, admin_tab_weapons);
        guiEditSetMaxLength(weapons_slots, 5);
        weapons_apply = guiCreateButton(302, 416, 161, 22, "Apply", false, admin_tab_weapons);
        guiSetFont(weapons_apply, "default-bold-small");
        guiSetProperty(weapons_apply, "NormalTextColour", "C000FF00");
        shooting_weapon = guiCreateComboBox(0.02, 0.02, 0.54, 0.85, getWeaponNameFromID(22), true, admin_tab_shooting);
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(22));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(23));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(24));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(25));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(26));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(27));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(28));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(32));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(29));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(30));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(31));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(33));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(34));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(35));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(36));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(37));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(38));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(41));
        guiComboBoxAddItem(shooting_weapon, getWeaponNameFromID(42));
        shooting_ok = guiCreateButton(0.57, 0.02, 0.2, 0.052, "Apply", true, admin_tab_shooting);
        guiSetFont(shooting_ok, "default-bold-small");
        guiSetProperty(shooting_ok, "NormalTextColour", "C000FF00");
        shooting_reset = guiCreateButton(0.78, 0.02, 0.2, 0.052, "Set Original", true, admin_tab_shooting);
        guiSetFont(shooting_reset, "default-bold-small");
        guiSetProperty(shooting_reset, "NormalTextColour", "C0FFFF00");
        shooting_generalbg = guiCreateStaticImage(0.02, 0.1, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_shooting);
        guiSetProperty(shooting_generalbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        shooting_general = guiCreateButton(0, 0, 1.1, 1, "Properties", true, shooting_generalbg);
        guiSetFont(shooting_general, "default-bold-small");
        guiSetAlpha(shooting_general, 1);
        guiSetProperty(shooting_general, "NormalTextColour", "FFFFFFFF");
        shooting_animationbg = guiCreateStaticImage(0.02, 0.18, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_shooting);
        guiSetProperty(shooting_animationbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        shooting_animation = guiCreateButton(0, 0, 1.1, 1, "Animation", true, shooting_animationbg);
        guiSetFont(shooting_animation, "default-bold-small");
        guiSetAlpha(shooting_animation, 1);
        shooting_flagsbg = guiCreateStaticImage(0.02, 0.26, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_shooting);
        guiSetProperty(shooting_flagsbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        shooting_flag = guiCreateButton(0, 0, 1.1, 1, "Type", true, shooting_flagsbg);
        guiSetFont(shooting_flag, "default-bold-small");
        guiSetAlpha(shooting_flag, 1);
        shooting_generalpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_shooting);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Weapon Range", true, shooting_generalpane);
        shooting_weapon_range = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "m", true, shooting_generalpane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Target Range", true, shooting_generalpane);
        shooting_target_range = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "m", true, shooting_generalpane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "Accuracy", true, shooting_generalpane);
        shooting_accuracy = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "?", true, shooting_generalpane);
        guiCreateLabel(0.05, 0.205, 0.38, 0.05, "Damage", true, shooting_generalpane);
        shooting_damage = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "hp", true, shooting_generalpane);
        guiCreateLabel(0.05, 0.265, 0.38, 0.05, "Ammo in Clip", true, shooting_generalpane);
        shooting_maximum_clip = guiCreateEdit(0.45, 0.26, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "", true, shooting_generalpane);
        guiCreateLabel(0.05, 0.325, 0.38, 0.05, "Move Speed", true, shooting_generalpane);
        shooting_move_speed = guiCreateEdit(0.45, 0.32, 0.3, 0.055, "", true, shooting_generalpane);
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "% / 100", true, shooting_generalpane);
        shooting_animationpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_shooting);
        guiSetVisible(shooting_animationpane, false);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Start", true, shooting_animationpane);
        shooting_anim_loop_start = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "End", true, shooting_animationpane);
        shooting_anim_loop_stop = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "Bullet Fire", true, shooting_animationpane);
        shooting_anim_loop_bullet_fire = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.205, 0.38, 0.05, "Ducked Start", true, shooting_animationpane);
        shooting_anim2_loop_start = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.265, 0.38, 0.05, "Ducked End", true, shooting_animationpane);
        shooting_anim2_loop_stop = guiCreateEdit(0.45, 0.26, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.325, 0.38, 0.05, "Ducked Bullet Fire", true, shooting_animationpane);
        shooting_anim2_loop_bullet_fire = guiCreateEdit(0.45, 0.32, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "sec", true, shooting_animationpane);
        guiCreateLabel(0.05, 0.385, 0.38, 0.05, "Breakout Time", true, shooting_animationpane);
        shooting_anim_breakout_time = guiCreateEdit(0.45, 0.38, 0.3, 0.055, "", true, shooting_animationpane);
        guiCreateLabel(0.77, 0.385, 0.26, 0.05, "sec", true, shooting_animationpane);
        shooting_flagpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_shooting);
        guiSetVisible(shooting_flagpane, false);
        shooting_flags = {
            {}, 
            {}, 
            {}, 
            {}, 
            {}
        };
        shooting_flags[1][1] = guiCreateCheckBox(0.05, 0.02, 0.45, 0.04, "Joypad aim", false, true, shooting_flagpane);
        shooting_flags[1][2] = guiCreateCheckBox(0.05, 0.07, 0.45, 0.04, "Running aim", false, true, shooting_flagpane);
        shooting_flags[1][4] = guiCreateCheckBox(0.05, 0.12000000000000001, 0.45, 0.04, "1st person", false, true, shooting_flagpane);
        shooting_flags[1][8] = guiCreateCheckBox(0.05, 0.17, 0.45, 0.04, "Free aiming", false, true, shooting_flagpane);
        shooting_flags[2][1] = guiCreateCheckBox(0.05, 0.24000000000000002, 0.45, 0.04, "Move and aim", false, true, shooting_flagpane);
        shooting_flags[2][2] = guiCreateCheckBox(0.05, 0.29, 0.45, 0.04, "Move and fire", false, true, shooting_flagpane);
        shooting_flags[2][4] = guiCreateCheckBox(0.05, 0.34, 0.45, 0.04, "[???]", false, true, shooting_flagpane);
        shooting_flags[2][8] = guiCreateCheckBox(0.05, 0.39, 0.45, 0.04, "[???]", false, true, shooting_flagpane);
        shooting_flags[3][1] = guiCreateCheckBox(0.05, 0.46, 0.45, 0.04, "Is throwing", false, true, shooting_flagpane);
        shooting_flags[3][2] = guiCreateCheckBox(0.05, 0.51, 0.45, 0.04, "Heavy weapon", false, true, shooting_flagpane);
        shooting_flags[3][4] = guiCreateCheckBox(0.05, 0.56, 0.45, 0.04, "Without delay", false, true, shooting_flagpane);
        shooting_flags[3][8] = guiCreateCheckBox(0.05, 0.6100000000000001, 0.45, 0.04, "2x guns", false, true, shooting_flagpane);
        shooting_flags[4][1] = guiCreateCheckBox(0.05, 0.68, 0.45, 0.04, "Has reload", false, true, shooting_flagpane);
        shooting_flags[4][2] = guiCreateCheckBox(0.05, 0.73, 0.45, 0.04, "Has crouching", false, true, shooting_flagpane);
        shooting_flags[4][4] = guiCreateCheckBox(0.05, 0.78, 0.45, 0.04, "[???]", false, true, shooting_flagpane);
        shooting_flags[4][8] = guiCreateCheckBox(0.05, 0.83, 0.45, 0.04, "Full reload time", false, true, shooting_flagpane);
        triggerEvent("onClientGUIComboBoxAccepted", shooting_weapon);
        local serverSortedVehicleNames = {};
        for serverVehicleModelID = 400, 611 do
            if getVehicleNameFromModel(serverVehicleModelID) and #getVehicleNameFromModel(serverVehicleModelID) > 0 then
                table.insert(serverSortedVehicleNames, getVehicleNameFromModel(serverVehicleModelID));
            end;
        end;
        table.sort(serverSortedVehicleNames, function(serverFirstVehicleName, serverSecondVehicleName) 
            return serverFirstVehicleName < serverSecondVehicleName;
        end);
        handling_model = guiCreateComboBox(0.02, 0.02, 0.54, 0.85, getVehicleNameFromModel(411), true, admin_tab_handling);
        for __, serverVehicleName in ipairs(serverSortedVehicleNames) do
            guiComboBoxAddItem(handling_model, serverVehicleName);
        end;
        handling_ok = guiCreateButton(0.57, 0.02, 0.2, 0.052, "Apply", true, admin_tab_handling);
        guiSetFont(handling_ok, "default-bold-small");
        guiSetProperty(handling_ok, "NormalTextColour", "C000FF00");
        handling_reset = guiCreateButton(0.78, 0.02, 0.2, 0.052, "Set Original", true, admin_tab_handling);
        guiSetFont(handling_reset, "default-bold-small");
        guiSetProperty(handling_reset, "NormalTextColour", "C0FFFF00");
        handling_generalbg = guiCreateStaticImage(0.02, 0.1, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_generalbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_general = guiCreateButton(0, 0, 1.1, 1, "Body", true, handling_generalbg);
        guiSetFont(handling_general, "default-bold-small");
        guiSetAlpha(handling_general, 1);
        guiSetProperty(handling_general, "NormalTextColour", "FFFFFFFF");
        handling_enginebg = guiCreateStaticImage(0.02, 0.18, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_enginebg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_engine = guiCreateButton(0, 0, 1.1, 1, "Engine", true, handling_enginebg);
        guiSetFont(handling_engine, "default-bold-small");
        guiSetAlpha(handling_engine, 1);
        handling_wheelsbg = guiCreateStaticImage(0.02, 0.26, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_wheelsbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_wheels = guiCreateButton(0, 0, 1.1, 1, "Wheels", true, handling_wheelsbg);
        guiSetFont(handling_wheels, "default-bold-small");
        guiSetAlpha(handling_wheels, 1);
        handling_suspensionbg = guiCreateStaticImage(0.02, 0.33999999999999997, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_suspensionbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_suspension = guiCreateButton(0, 0, 1.1, 1, "Suspension", true, handling_suspensionbg);
        guiSetFont(handling_suspension, "default-bold-small");
        guiSetAlpha(handling_suspension, 1);
        handling_modelflagbg = guiCreateStaticImage(0.02, 0.42000000000000004, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_modelflagbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_modelflag = guiCreateButton(0, 0, 1.1, 1, "Model", true, handling_modelflagbg);
        guiSetFont(handling_modelflag, "default-bold-small");
        guiSetAlpha(handling_modelflag, 1);
        handling_handlingflagbg = guiCreateStaticImage(0.02, 0.5, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_handlingflagbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_handlingflag = guiCreateButton(0, 0, 1.1, 1, "Handling", true, handling_handlingflagbg);
        guiSetFont(handling_handlingflag, "default-bold-small");
        guiSetAlpha(handling_handlingflag, 1);
        handling_sirensbg = guiCreateStaticImage(0.02, 0.58, 0.18, 0.08, "images/color_pixel.png", true, admin_tab_handling);
        guiSetProperty(handling_sirensbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        handling_sirens = guiCreateButton(0, 0, 1.1, 1, "Sirens", true, handling_sirensbg);
        guiSetFont(handling_sirens, "default-bold-small");
        guiSetAlpha(handling_sirens, 1);
        handling_generalpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Mass", true, handling_generalpane);
        handling_mass = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "kg", true, handling_generalpane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Turn Mass", true, handling_generalpane);
        handling_turnmass = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "kg * m\194\178", true, handling_generalpane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "Drag Coefficient", true, handling_generalpane);
        handling_dragcoeff = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "", true, handling_generalpane);
        temp = guiCreateLabel(0.05, 0.205, 0.3, 0.16, "Center of Mass", true, handling_generalpane);
        guiLabelSetVerticalAlign(temp, "center");
        guiLabelSetHorizontalAlign(temp, "left", true);
        guiLabelSetHorizontalAlign(guiCreateLabel(0.05, 0.205, 0.38, 0.05, "in Width", true, handling_generalpane), "right");
        guiLabelSetHorizontalAlign(guiCreateLabel(0.05, 0.265, 0.38, 0.05, "in Length", true, handling_generalpane), "right");
        guiLabelSetHorizontalAlign(guiCreateLabel(0.05, 0.325, 0.38, 0.05, "in Height", true, handling_generalpane), "right");
        handling_centerofmass_x = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "m (+ in right)", true, handling_generalpane);
        handling_centerofmass_y = guiCreateEdit(0.45, 0.26, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "m (+ in front)", true, handling_generalpane);
        handling_centerofmass_z = guiCreateEdit(0.45, 0.32, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "m (+ in top)", true, handling_generalpane);
        guiCreateLabel(0.05, 0.385, 0.38, 0.05, "Percent Submerged", true, handling_generalpane);
        handling_percentsubmerged = guiCreateEdit(0.45, 0.38, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.385, 0.26, 0.05, "%", true, handling_generalpane);
        guiCreateLabel(0.05, 0.445, 0.38, 0.05, "Seat Offset Distance", true, handling_generalpane);
        handling_seatoffsetdistance = guiCreateEdit(0.45, 0.44, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.445, 0.26, 0.05, "m", true, handling_generalpane);
        guiCreateLabel(0.05, 0.505, 0.38, 0.05, "Collision Damage Multiplier", true, handling_generalpane);
        handling_collisiondamagemultiplier = guiCreateEdit(0.45, 0.5, 0.3, 0.055, "", true, handling_generalpane);
        guiCreateLabel(0.77, 0.505, 0.26, 0.05, "% / 100", true, handling_generalpane);
        guiCreateLabel(0.05, 0.595, 0.38, 0.05, "Variants", true, handling_generalpane);
        handling_variant1 = guiCreateComboBox(0.45, 0.56, 0.3, 0.2, "Random", true, handling_generalpane);
        guiComboBoxAddItem(handling_variant1, "Random");
        handling_variant2 = guiCreateComboBox(0.45, 0.62, 0.3, 0.2, "Random", true, handling_generalpane);
        guiComboBoxAddItem(handling_variant2, "Random");
        guiCreateLabel(0.77, 0.5650000000000001, 0.26, 0.05, "", true, handling_generalpane);
        handling_enginepane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_enginepane, false);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Number of Gears", true, handling_enginepane);
        handling_numberofgears = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, handling_enginepane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "", true, handling_enginepane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Maximal Velocity", true, handling_enginepane);
        handling_maxvelocity = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, handling_enginepane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "km / h", true, handling_enginepane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "Acceleration", true, handling_enginepane);
        handling_engineacceleration = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, handling_enginepane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "m * sec\194\178", true, handling_enginepane);
        guiCreateLabel(0.05, 0.205, 0.38, 0.05, "Inertia", true, handling_enginepane);
        handling_engineinertia = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, handling_enginepane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "kg * m\194\178", true, handling_enginepane);
        guiCreateLabel(0.05, 0.265, 0.38, 0.05, "Drive Type", true, handling_enginepane);
        handling_drivetype = guiCreateComboBox(0.45, 0.26, 0.3, 0.2, "", true, handling_enginepane);
        guiComboBoxAddItem(handling_drivetype, "Rear");
        guiComboBoxAddItem(handling_drivetype, "Front");
        guiComboBoxAddItem(handling_drivetype, "4x4");
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "", true, handling_enginepane);
        guiCreateLabel(0.05, 0.325, 0.38, 0.05, "Engine Type", true, handling_enginepane);
        handling_enginetype = guiCreateComboBox(0.45, 0.32, 0.3, 0.2, "", true, handling_enginepane);
        guiComboBoxAddItem(handling_enginetype, "Petrol");
        guiComboBoxAddItem(handling_enginetype, "Diesel");
        guiComboBoxAddItem(handling_enginetype, "Electric");
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "", true, handling_enginepane);
        handling_wheelspane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_wheelspane, false);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Traction Multiplier", true, handling_wheelspane);
        handling_tractionmultiplier = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Traction Loss", true, handling_wheelspane);
        handling_tractionloss = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "Traction Bias Ratio", true, handling_wheelspane);
        handling_tractionbias = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "(1.0 full front)", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.205, 0.38, 0.05, "Brake Deceleration", true, handling_wheelspane);
        handling_brakedeceleration = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.265, 0.38, 0.05, "Brake Bias Ratio", true, handling_wheelspane);
        handling_brakebias = guiCreateEdit(0.45, 0.26, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "(1.0 full front)", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.325, 0.38, 0.05, "ABS", true, handling_wheelspane);
        handling_abs = guiCreateComboBox(0.45, 0.32, 0.3, 0.18, "", true, handling_wheelspane);
        guiComboBoxAddItem(handling_abs, "Enable");
        guiComboBoxAddItem(handling_abs, "Disable");
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "", true, handling_wheelspane);
        guiCreateLabel(0.05, 0.385, 0.38, 0.05, "Steering Lock", true, handling_wheelspane);
        handling_steeringlock = guiCreateEdit(0.45, 0.38, 0.3, 0.055, "", true, handling_wheelspane);
        guiCreateLabel(0.77, 0.385, 0.26, 0.05, "\194\186", true, handling_wheelspane);
        handling_suspensionpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_suspensionpane, false);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Force Level", true, handling_suspensionpane);
        handling_suspensionforcelevel = guiCreateEdit(0.45, 0.02, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Damping Level", true, handling_suspensionpane);
        handling_suspensiondamping = guiCreateEdit(0.45, 0.08, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.145, 0.38, 0.05, "High Speed Damping", true, handling_suspensionpane);
        handling_suspensionhighspeeddamping = guiCreateEdit(0.45, 0.13999999999999999, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.145, 0.26, 0.05, "", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.205, 0.38, 0.05, "Upper Limit", true, handling_suspensionpane);
        handling_suspensionupperlimit = guiCreateEdit(0.45, 0.19999999999999998, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.205, 0.26, 0.05, "m", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.265, 0.38, 0.05, "Lower Limit", true, handling_suspensionpane);
        handling_suspensionlowerlimit = guiCreateEdit(0.45, 0.26, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.265, 0.26, 0.05, "m", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.325, 0.38, 0.05, "Bias Ratio", true, handling_suspensionpane);
        handling_suspensionfrontrearbias = guiCreateEdit(0.45, 0.32, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.325, 0.26, 0.05, "(1.0 full front)", true, handling_suspensionpane);
        guiCreateLabel(0.05, 0.385, 0.38, 0.05, "Anti-Dive Multiplier", true, handling_suspensionpane);
        handling_suspensionantidivemultiplier = guiCreateEdit(0.45, 0.38, 0.3, 0.055, "", true, handling_suspensionpane);
        guiCreateLabel(0.77, 0.385, 0.26, 0.05, "", true, handling_suspensionpane);
        handling_modelflagpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_modelflagpane, false);
        handling_modelflags = {
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}
        };
        handling_modelflags[1][1] = guiCreateCheckBox(0.05, 0.02, 0.45, 0.04, "Is van", false, true, handling_modelflagpane);
        handling_modelflags[1][2] = guiCreateCheckBox(0.05, 0.07, 0.45, 0.04, "Is bus", false, true, handling_modelflagpane);
        handling_modelflags[1][4] = guiCreateCheckBox(0.05, 0.12000000000000001, 0.45, 0.04, "Is low", false, true, handling_modelflagpane);
        handling_modelflags[1][8] = guiCreateCheckBox(0.05, 0.17, 0.45, 0.04, "Is big", false, true, handling_modelflagpane);
        handling_modelflags[2][1] = guiCreateCheckBox(0.05, 0.24000000000000002, 0.45, 0.04, "Reverse bonnet", false, true, handling_modelflagpane);
        handling_modelflags[2][2] = guiCreateCheckBox(0.05, 0.29, 0.45, 0.04, "Hanging boot", false, true, handling_modelflagpane);
        handling_modelflags[2][4] = guiCreateCheckBox(0.05, 0.34, 0.45, 0.04, "Tailgate boot", false, true, handling_modelflagpane);
        handling_modelflags[2][8] = guiCreateCheckBox(0.05, 0.39, 0.45, 0.04, "Noswing boot", false, true, handling_modelflagpane);
        handling_modelflags[3][1] = guiCreateCheckBox(0.05, 0.46, 0.45, 0.04, "No doors", false, true, handling_modelflagpane);
        handling_modelflags[3][2] = guiCreateCheckBox(0.05, 0.51, 0.45, 0.04, "Tandem seats", false, true, handling_modelflagpane);
        handling_modelflags[3][4] = guiCreateCheckBox(0.05, 0.56, 0.45, 0.04, "Sit in boat", false, true, handling_modelflagpane);
        handling_modelflags[3][8] = guiCreateCheckBox(0.05, 0.6100000000000001, 0.45, 0.04, "Cabriolet", false, true, handling_modelflagpane);
        handling_modelflags[4][1] = guiCreateCheckBox(0.05, 0.68, 0.45, 0.04, "No exhaust", false, true, handling_modelflagpane);
        handling_modelflags[4][2] = guiCreateCheckBox(0.05, 0.73, 0.45, 0.04, "Dbl exhaust", false, true, handling_modelflagpane);
        handling_modelflags[4][4] = guiCreateCheckBox(0.05, 0.78, 0.45, 0.04, "Invis look behind", false, true, handling_modelflagpane);
        handling_modelflags[4][8] = guiCreateCheckBox(0.05, 0.83, 0.45, 0.04, "Force door check", false, true, handling_modelflagpane);
        handling_modelflags[5][1] = guiCreateCheckBox(0.5, 0.02, 0.45, 0.04, "Axle F notilt", false, true, handling_modelflagpane);
        handling_modelflags[5][2] = guiCreateCheckBox(0.5, 0.07, 0.45, 0.04, "Axle F solid", false, true, handling_modelflagpane);
        handling_modelflags[5][4] = guiCreateCheckBox(0.5, 0.12000000000000001, 0.45, 0.04, "Axle F mcpherson", false, true, handling_modelflagpane);
        handling_modelflags[5][8] = guiCreateCheckBox(0.5, 0.17, 0.45, 0.04, "Axle F reverse", false, true, handling_modelflagpane);
        handling_modelflags[6][1] = guiCreateCheckBox(0.5, 0.24000000000000002, 0.45, 0.04, "Axle R notilt", false, true, handling_modelflagpane);
        handling_modelflags[6][2] = guiCreateCheckBox(0.5, 0.29, 0.45, 0.04, "Axle R solid", false, true, handling_modelflagpane);
        handling_modelflags[6][4] = guiCreateCheckBox(0.5, 0.34, 0.45, 0.04, "Axle R mcpherson", false, true, handling_modelflagpane);
        handling_modelflags[6][8] = guiCreateCheckBox(0.5, 0.39, 0.45, 0.04, "Axle R reverse", false, true, handling_modelflagpane);
        handling_modelflags[7][1] = guiCreateCheckBox(0.5, 0.46, 0.45, 0.04, "Is bike", false, true, handling_modelflagpane);
        handling_modelflags[7][2] = guiCreateCheckBox(0.5, 0.51, 0.45, 0.04, "Is heli", false, true, handling_modelflagpane);
        handling_modelflags[7][4] = guiCreateCheckBox(0.5, 0.56, 0.45, 0.04, "Is plane", false, true, handling_modelflagpane);
        handling_modelflags[7][8] = guiCreateCheckBox(0.5, 0.6100000000000001, 0.45, 0.04, "Is boat", false, true, handling_modelflagpane);
        handling_modelflags[8][1] = guiCreateCheckBox(0.5, 0.68, 0.45, 0.04, "Bounce panels", false, true, handling_modelflagpane);
        handling_modelflags[8][2] = guiCreateCheckBox(0.5, 0.73, 0.45, 0.04, "Double R wheels", false, true, handling_modelflagpane);
        handling_modelflags[8][4] = guiCreateCheckBox(0.5, 0.78, 0.45, 0.04, "Force ground clearance", false, true, handling_modelflagpane);
        handling_modelflags[8][8] = guiCreateCheckBox(0.5, 0.83, 0.45, 0.04, "Is hatchback", false, true, handling_modelflagpane);
        handling_handlingflagpane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_handlingflagpane, false);
        handling_handlingflags = {
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}, 
            {}
        };
        handling_handlingflags[1][1] = guiCreateCheckBox(0.05, 0.02, 0.45, 0.04, "1G boost", false, true, handling_handlingflagpane);
        handling_handlingflags[1][2] = guiCreateCheckBox(0.05, 0.07, 0.45, 0.04, "2G boost", false, true, handling_handlingflagpane);
        handling_handlingflags[1][4] = guiCreateCheckBox(0.05, 0.12000000000000001, 0.45, 0.04, "NPC anti roll", false, true, handling_handlingflagpane);
        handling_handlingflags[1][8] = guiCreateCheckBox(0.05, 0.17, 0.45, 0.04, "NPC neutral handl", false, true, handling_handlingflagpane);
        handling_handlingflags[2][1] = guiCreateCheckBox(0.05, 0.24000000000000002, 0.45, 0.04, "No handbrake", false, true, handling_handlingflagpane);
        handling_handlingflags[2][2] = guiCreateCheckBox(0.05, 0.29, 0.45, 0.04, "Steer rearwheels", false, true, handling_handlingflagpane);
        handling_handlingflags[2][4] = guiCreateCheckBox(0.05, 0.34, 0.45, 0.04, "Hb rearwheel steer", false, true, handling_handlingflagpane);
        handling_handlingflags[2][8] = guiCreateCheckBox(0.05, 0.39, 0.45, 0.04, "Alt steer opt", false, true, handling_handlingflagpane);
        handling_handlingflags[3][1] = guiCreateCheckBox(0.05, 0.46, 0.45, 0.04, "Wheel F narrowest", false, true, handling_handlingflagpane);
        handling_handlingflags[3][2] = guiCreateCheckBox(0.05, 0.51, 0.45, 0.04, "Wheel F narrow", false, true, handling_handlingflagpane);
        handling_handlingflags[3][4] = guiCreateCheckBox(0.05, 0.56, 0.45, 0.04, "Wheel F wide", false, true, handling_handlingflagpane);
        handling_handlingflags[3][8] = guiCreateCheckBox(0.05, 0.6100000000000001, 0.45, 0.04, "Wheel F widest", false, true, handling_handlingflagpane);
        handling_handlingflags[4][1] = guiCreateCheckBox(0.05, 0.68, 0.45, 0.04, "Wheel R narrowest", false, true, handling_handlingflagpane);
        handling_handlingflags[4][2] = guiCreateCheckBox(0.05, 0.73, 0.45, 0.04, "Wheel R narrow", false, true, handling_handlingflagpane);
        handling_handlingflags[4][4] = guiCreateCheckBox(0.05, 0.78, 0.45, 0.04, "Wheel R wide", false, true, handling_handlingflagpane);
        handling_handlingflags[4][8] = guiCreateCheckBox(0.05, 0.83, 0.45, 0.04, "Wheel R widest", false, true, handling_handlingflagpane);
        handling_handlingflags[5][1] = guiCreateCheckBox(0.5, 0.02, 0.45, 0.04, "Hydraulic geom", false, true, handling_handlingflagpane);
        handling_handlingflags[5][2] = guiCreateCheckBox(0.5, 0.07, 0.45, 0.04, "Hydraulic inst", false, true, handling_handlingflagpane);
        handling_handlingflags[5][4] = guiCreateCheckBox(0.5, 0.12000000000000001, 0.45, 0.04, "Hydraulic none", false, true, handling_handlingflagpane);
        handling_handlingflags[5][8] = guiCreateCheckBox(0.5, 0.17, 0.45, 0.04, "Nitro inst", false, true, handling_handlingflagpane);
        handling_handlingflags[6][1] = guiCreateCheckBox(0.5, 0.24000000000000002, 0.45, 0.04, "Dirt offroad", false, true, handling_handlingflagpane);
        handling_handlingflags[6][2] = guiCreateCheckBox(0.5, 0.29, 0.45, 0.04, "Sand offroad", false, true, handling_handlingflagpane);
        handling_handlingflags[6][4] = guiCreateCheckBox(0.5, 0.34, 0.45, 0.04, "Halogen lights", false, true, handling_handlingflagpane);
        handling_handlingflags[6][8] = guiCreateCheckBox(0.5, 0.39, 0.45, 0.04, "Proc rearwheel 1st", false, true, handling_handlingflagpane);
        handling_handlingflags[7][1] = guiCreateCheckBox(0.5, 0.46, 0.45, 0.04, "Use maxsp limit", false, true, handling_handlingflagpane);
        handling_handlingflags[7][2] = guiCreateCheckBox(0.5, 0.51, 0.45, 0.04, "Low rider", false, true, handling_handlingflagpane);
        handling_handlingflags[7][4] = guiCreateCheckBox(0.5, 0.56, 0.45, 0.04, "Street racer", false, true, handling_handlingflagpane);
        handling_handlingflags[7][8] = guiCreateCheckBox(0.5, 0.6100000000000001, 0.45, 0.04, "[???]", false, true, handling_handlingflagpane);
        handling_handlingflags[8][1] = guiCreateCheckBox(0.5, 0.68, 0.45, 0.04, "Swinging chassis", false, true, handling_handlingflagpane);
        handling_handlingflags[8][2] = guiCreateCheckBox(0.5, 0.73, 0.45, 0.04, "[???]", false, true, handling_handlingflagpane);
        handling_handlingflags[8][4] = guiCreateCheckBox(0.5, 0.78, 0.45, 0.04, "[???]", false, true, handling_handlingflagpane);
        handling_handlingflags[8][8] = guiCreateCheckBox(0.5, 0.83, 0.45, 0.04, "[???]", false, true, handling_handlingflagpane);
        handling_sirenspane = guiCreateGridList(0.2, 0.09, 0.78, 0.89, true, admin_tab_handling);
        guiSetVisible(handling_sirenspane, false);
        guiCreateLabel(0.05, 0.025, 0.38, 0.05, "Count", true, handling_sirenspane);
        sirens_count = guiCreateComboBox(0.45, 0.02, 0.3, 0.42, "", true, handling_sirenspane);
        guiComboBoxAddItem(sirens_count, "Original");
        guiComboBoxAddItem(sirens_count, "1");
        guiComboBoxAddItem(sirens_count, "2");
        guiComboBoxAddItem(sirens_count, "3");
        guiComboBoxAddItem(sirens_count, "4");
        guiComboBoxAddItem(sirens_count, "5");
        guiComboBoxAddItem(sirens_count, "6");
        guiComboBoxAddItem(sirens_count, "7");
        guiComboBoxAddItem(sirens_count, "8");
        guiCreateLabel(0.77, 0.025, 0.26, 0.05, "", true, handling_sirenspane);
        guiCreateLabel(0.05, 0.08499999999999999, 0.38, 0.05, "Type", true, handling_sirenspane);
        sirens_type = guiCreateComboBox(0.45, 0.08, 0.3, 0.3, "", true, handling_sirenspane);
        guiComboBoxAddItem(sirens_type, "Invisible");
        guiComboBoxAddItem(sirens_type, "Single");
        guiComboBoxAddItem(sirens_type, "Dual");
        guiComboBoxAddItem(sirens_type, "Triple");
        guiComboBoxAddItem(sirens_type, "Quadruple");
        guiComboBoxAddItem(sirens_type, "Quinary");
        guiCreateLabel(0.77, 0.08499999999999999, 0.26, 0.05, "", true, handling_sirenspane);
        sirens_360 = guiCreateCheckBox(0.05, 0.18, 0.45, 0.04, "Visibility 360\194\176", false, true, handling_sirenspane);
        sirens_LOS = guiCreateCheckBox(0.05, 0.23000000000000004, 0.45, 0.04, "Check light of sight", false, true, handling_sirenspane);
        sirens_randomiser = guiCreateCheckBox(0.5, 0.18, 0.45, 0.04, "Randomise order", false, true, handling_sirenspane);
        sirens_silent = guiCreateCheckBox(0.5, 0.23000000000000004, 0.45, 0.04, "Silent siren", false, true, handling_sirenspane);
        guiCreateLabel(0.05, 0.32, 0.164, 0.055, "X offset", true, handling_sirenspane);
        guiCreateLabel(0.23399999999999999, 0.32, 0.164, 0.055, "Y offset", true, handling_sirenspane);
        guiCreateLabel(0.418, 0.32, 0.164, 0.055, "Z offset", true, handling_sirenspane);
        guiCreateLabel(0.6020000000000001, 0.32, 0.164, 0.055, "Color", true, handling_sirenspane);
        guiCreateLabel(0.786, 0.32, 0.164, 0.055, "Min Alpha", true, handling_sirenspane);
        local serverSirenXOffsets = {};
        local serverSirenYOffsets = {};
        local serverSirenZOffsets = {};
        local serverSirenColors = {};
        sirens_minalpha = {};
        sirens_color = serverSirenColors;
        sirens_zcenter = serverSirenZOffsets;
        sirens_ycenter = serverSirenYOffsets;
        sirens_xcenter = serverSirenXOffsets;
        sirens_xcenter[1] = guiCreateEdit(0.05, 0.38, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[1] = guiCreateEdit(0.23399999999999999, 0.38, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[1] = guiCreateEdit(0.418, 0.38, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[1] = guiCreateEdit(0.6020000000000001, 0.38, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[1], true);
        sirens_minalpha[1] = guiCreateEdit(0.786, 0.38, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[2] = guiCreateEdit(0.05, 0.44, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[2] = guiCreateEdit(0.23399999999999999, 0.44, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[2] = guiCreateEdit(0.418, 0.44, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[2] = guiCreateEdit(0.6020000000000001, 0.44, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[2], true);
        sirens_minalpha[2] = guiCreateEdit(0.786, 0.44, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[3] = guiCreateEdit(0.05, 0.5, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[3] = guiCreateEdit(0.23399999999999999, 0.5, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[3] = guiCreateEdit(0.418, 0.5, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[3] = guiCreateEdit(0.6020000000000001, 0.5, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[3], true);
        sirens_minalpha[3] = guiCreateEdit(0.786, 0.5, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[4] = guiCreateEdit(0.05, 0.56, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[4] = guiCreateEdit(0.23399999999999999, 0.56, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[4] = guiCreateEdit(0.418, 0.56, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[4] = guiCreateEdit(0.6020000000000001, 0.56, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[4], true);
        sirens_minalpha[4] = guiCreateEdit(0.786, 0.56, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[5] = guiCreateEdit(0.05, 0.62, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[5] = guiCreateEdit(0.23399999999999999, 0.62, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[5] = guiCreateEdit(0.418, 0.62, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[5] = guiCreateEdit(0.6020000000000001, 0.62, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[5], true);
        sirens_minalpha[5] = guiCreateEdit(0.786, 0.62, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[6] = guiCreateEdit(0.05, 0.6799999999999999, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[6] = guiCreateEdit(0.23399999999999999, 0.6799999999999999, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[6] = guiCreateEdit(0.418, 0.6799999999999999, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[6] = guiCreateEdit(0.6020000000000001, 0.6799999999999999, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[6], true);
        sirens_minalpha[6] = guiCreateEdit(0.786, 0.6799999999999999, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[7] = guiCreateEdit(0.05, 0.74, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[7] = guiCreateEdit(0.23399999999999999, 0.74, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[7] = guiCreateEdit(0.418, 0.74, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[7] = guiCreateEdit(0.6020000000000001, 0.74, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[7], true);
        sirens_minalpha[7] = guiCreateEdit(0.786, 0.74, 0.164, 0.055, "0", true, handling_sirenspane);
        sirens_xcenter[8] = guiCreateEdit(0.05, 0.8, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_ycenter[8] = guiCreateEdit(0.23399999999999999, 0.8, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_zcenter[8] = guiCreateEdit(0.418, 0.8, 0.164, 0.055, "0.000", true, handling_sirenspane);
        sirens_color[8] = guiCreateEdit(0.6020000000000001, 0.8, 0.164, 0.055, "", true, handling_sirenspane);
        guiEditSetReadOnly(sirens_color[8], true);
        sirens_minalpha[8] = guiCreateEdit(0.786, 0.8, 0.164, 0.055, "0", true, handling_sirenspane);
        triggerEvent("onClientGUIComboBoxAccepted", handling_model);
        temp = guiCreateLabel(8, 8, 40, 21, "Side", false, admin_tab_teams);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = guiCreateLabel(53, 8, 120, 21, "Name", false, admin_tab_teams);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = guiCreateLabel(178, 8, 80, 21, "Skins (id,id, )", false, admin_tab_teams);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = guiCreateLabel(263, 8, 50, 21, "Score", false, admin_tab_teams);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = guiCreateLabel(318, 8, 50, 21, "Color", false, admin_tab_teams);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        teams_scroller = guiCreateScrollPane(0, 0.06, 1, 0.9, true, admin_tab_teams);
        guiSetVisible(guiCreateButton(0, 0, 1, 1, "", false, teams_scroller), false);
        teams_teams = {};
        teams_apply = guiCreateButton(0, 0, 70, 21, "Apply", false, teams_scroller);
        guiSetFont(teams_apply, "default-bold-small");
        teams_addteam = guiCreateButton(0, 0, 70, 21, "Add", false, teams_scroller);
        guiSetFont(teams_addteam, "default-bold-small");
        guiSetProperty(teams_addteam, "NormalTextColour", "C000FF00");
        vehicles_disabled = guiCreateGridList(0.02, 0.02, 0.3, 0.91, true, admin_tab_vehicles);
        guiGridListSetSortingEnabled(vehicles_disabled, false);
        guiGridListAddColumn(vehicles_disabled, "Disabled", 0.8);
        guiGridListSetSelectionMode(vehicles_disabled, 1);
        vehicles_enabled = guiCreateGridList(0.33, 0.02, 0.3, 0.91, true, admin_tab_vehicles);
        guiGridListSetSortingEnabled(vehicles_enabled, false);
        guiGridListAddColumn(vehicles_enabled, "Enabled", 0.8);
        guiGridListSetSelectionMode(vehicles_enabled, 1);
        vehicles_enable = guiCreateButton(0.02, 0.94, 0.3, 0.04, "Enable >", true, admin_tab_vehicles);
        guiSetFont(vehicles_enable, "default-bold-small");
        vehicles_disable = guiCreateButton(0.33, 0.94, 0.3, 0.04, "< Disable", true, admin_tab_vehicles);
        guiSetFont(vehicles_disable, "default-bold-small");
        weather_default = guiCreateComboBox(9, 9, 220, 383, "", false, admin_tab_weather);
        for serverWeatherIndex, serverWeatherData in ipairs(weatherSAData) do
            guiComboBoxAddItem(weather_default, string.format("[%i] %s", serverWeatherIndex - 1, serverWeatherData.name));
        end;
        guiComboBoxSetSelected(weather_default, 0);
        weather_load = guiCreateButton(235, 9, 113, 23, "Load Weather", false, admin_tab_weather);
        guiSetFont(weather_load, "default-bold-small");
        guiSetProperty(weather_load, "NormalTextColour", "C000FF00");
        weather_loadhour = guiCreateButton(353, 9, 108, 23, "Load Hour", false, admin_tab_weather);
        guiSetFont(weather_loadhour, "default-bold-small");
        weather_record = guiCreateGridList(9, 36, 339, 77, false, admin_tab_weather);
        guiGridListSetSortingEnabled(weather_record, false);
        guiGridListSetSelectionMode(weather_record, 6);
        guiSetProperty(weather_record, "ColumnsMovable", "False");
        guiSetProperty(weather_record, "ColumnsSizable", "False");
        temp = guiCreateLabel(0.02, 0.8, 0.96, 0.2, "Double-click to load hour", true, weather_record);
        guiSetFont(temp, "default-small");
        guiLabelSetHorizontalAlign(temp, "center");
        guiSetEnabled(temp, false);
        weather_hour = guiCreateComboBox(405, 36, 57, 383, "0", false, admin_tab_weather);
        for serverHourValue = 0, 23 do
            guiComboBoxAddItem(weather_hour, tostring(serverHourValue));
        end;
        weather_insert = guiCreateButton(353, 36, 47, 23, "Add", false, admin_tab_weather);
        guiSetFont(weather_insert, "default-bold-small");
        weather_save = guiCreateButton(353, 63, 108, 23, "Save Hour", false, admin_tab_weather);
        guiSetFont(weather_save, "default-bold-small");
        guiSetProperty(weather_save, "NormalTextColour", "C000FF00");
        weather_delete = guiCreateButton(353, 90, 108, 23, "Delete Hour", false, admin_tab_weather);
        guiSetFont(weather_delete, "default-bold-small");
        guiSetProperty(weather_delete, "NormalTextColour", "C0FF0000");
        temp = guiCreateLabel(10, 117, 200, 21, "Wind Vector & Speed", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        wind_radar = guiCreateStaticImage(10, 142, 64, 64, "images/wind_radar.png", false, admin_tab_weather);
        wind_aim = guiCreateStaticImage(36, 136, 12, 12, "images/color_aim.png", false, admin_tab_weather);
        wind_vector = guiCreateEdit(80, 142, 65, 21, "", false, admin_tab_weather);
        guiCreateLabel(145, 142, 30, 21, " \194\176", false, admin_tab_weather);
        wind_speed = guiCreateEdit(80, 167, 65, 21, "", false, admin_tab_weather);
        guiCreateLabel(145, 167, 30, 21, " m/s", false, admin_tab_weather);
        wind_slide = guiCreateScrollBar(80, 192, 135, 21, true, false, admin_tab_weather);
        guiSetProperty(wind_slide, "StepSize", "1");
        temp = guiCreateLabel(10, 217, 235, 21, "Rain Level", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        rain_level = guiCreateEdit(10, 242, 60, 21, "", false, admin_tab_weather);
        rain_slide = guiCreateScrollBar(75, 242, 140, 21, true, false, admin_tab_weather);
        guiSetProperty(rain_slide, "StepSize", "1");
        temp = guiCreateLabel(10, 267, 235, 21, "Heat Level", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        heat_level = guiCreateEdit(10, 292, 70, 21, "", false, admin_tab_weather);
        heat_levelslide = guiCreateScrollBar(85, 292, 130, 21, true, false, admin_tab_weather);
        guiSetProperty(heat_levelslide, "StepSize", "1");
        temp = guiCreateLabel(10, 317, 235, 21, "Far Clip Distance", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        farclip_distance = guiCreateEdit(10, 342, 70, 21, "", false, admin_tab_weather);
        farclip_slide = guiCreateScrollBar(85, 342, 130, 21, true, false, admin_tab_weather);
        guiSetProperty(farclip_slide, "StepSize", "1");
        temp = guiCreateLabel(10, 367, 235, 21, "Fog Distance", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        fog_distance = guiCreateEdit(10, 392, 70, 21, "", false, admin_tab_weather);
        fog_slide = guiCreateScrollBar(85, 392, 130, 21, true, false, admin_tab_weather);
        guiSetProperty(fog_slide, "StepSize", "1");
        temp = guiCreateLabel(235, 117, 90, 21, "Effect", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        weather_effect = guiCreateComboBox(330, 117, 130, 200, "Clear", false, admin_tab_weather);
        guiComboBoxAddItem(weather_effect, "Clear");
        guiComboBoxAddItem(weather_effect, "Cloudy");
        guiComboBoxAddItem(weather_effect, "Thunder");
        guiComboBoxAddItem(weather_effect, "Storm");
        guiComboBoxAddItem(weather_effect, "Fog");
        temp = guiCreateLabel(235, 142, 235, 21, "Sky Gradient & Clouds", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        sky_topcolor = guiCreateEdit(235, 167, 70, 21, "", false, admin_tab_weather);
        guiEditSetReadOnly(sky_topcolor, true);
        sky_bottomcolor = guiCreateEdit(235, 192, 70, 21, "", false, admin_tab_weather);
        guiEditSetReadOnly(sky_bottomcolor, true);
        sky_clouds = guiCreateCheckBox(235, 217, 70, 21, "Clouds", true, false, admin_tab_weather);
        sky_birds = guiCreateCheckBox(310, 217, 70, 21, "Birds", true, false, admin_tab_weather);
        sky_gradient = guiCreateStaticImage(310, 167, 150, 46, "images/color_pixel.png", false, admin_tab_weather);
        guiSetEnabled(sky_gradient, false);
        sky_clouds_img = guiCreateStaticImage(0, 0, 0.6, 1, "images/sky_clouds.png", true, sky_gradient);
        sky_birds_img = guiCreateStaticImage(0.6, 0.3, 0.4, 0.7, "images/sky_birds.png", true, sky_gradient);
        temp = guiCreateLabel(235, 242, 235, 21, "Sun Size & Color", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        sun_size = guiCreateEdit(235, 267, 70, 21, "", false, admin_tab_weather);
        sun_sizeslide = guiCreateScrollBar(310, 267, 150, 21, true, false, admin_tab_weather);
        guiSetProperty(sun_sizeslide, "StepSize", "1");
        guiCreateLabel(235, 292, 50, 21, "Core", false, admin_tab_weather);
        sun_colora = guiCreateEdit(265, 292, 70, 21, "", false, admin_tab_weather);
        guiEditSetReadOnly(sun_colora, true);
        guiCreateLabel(355, 292, 50, 21, "Shine", false, admin_tab_weather);
        sun_colorb = guiCreateEdit(390, 292, 70, 21, "", false, admin_tab_weather);
        guiEditSetReadOnly(sun_colorb, true);
        temp = guiCreateLabel(235, 317, 235, 21, "Water Level & Color", false, admin_tab_weather);
        guiSetFont(temp, "default-bold-small");
        water_level = guiCreateEdit(235, 342, 70, 21, "", false, admin_tab_weather);
        water_levelslide = guiCreateScrollBar(310, 342, 150, 21, true, false, admin_tab_weather);
        guiSetProperty(water_levelslide, "StepSize", "1");
        guiCreateLabel(235, 367, 50, 21, "Color", false, admin_tab_weather);
        water_color = guiCreateEdit(265, 367, 70, 21, "", false, admin_tab_weather);
        guiEditSetReadOnly(water_color, true);
        guiSetFont(guiCreateLabel(235, 392, 235, 21, "Wave Height", false, admin_tab_weather), "default-bold-small");
        wave_height = guiCreateEdit(235, 417, 70, 21, "", false, admin_tab_weather);
        wave_heightslide = guiCreateScrollBar(310, 417, 150, 21, true, false, admin_tab_weather);
        guiSetProperty(wave_heightslide, "StepSize", "1");
        guiSetFont(guiCreateLabel(0.02, 0.03, 0.23, 0.055, "Action detecting", true, admin_tab_anticheat), "default-bold-small");
        anticheat_action = guiCreateComboBox(0.28, 0.02, 0.35, 0.5, ({
            chat = "Chat message", 
            adminchat = "Adminchat message", 
            kick = "Kick"
        })[getTacticsData("anticheat", "action_detection")] or "", true, admin_tab_anticheat);
        guiComboBoxAddItem(anticheat_action, "Chat message");
        guiComboBoxAddItem(anticheat_action, "Adminchat message");
        guiComboBoxAddItem(anticheat_action, "Kick");
        guiSetFont(guiCreateLabel(0.02, 0.09, 0.23, 0.055, "SpeedHack", true, admin_tab_anticheat), "default-bold-small");
        anticheat_speedhack = guiCreateComboBox(0.28, 0.085, 0.2, 0.2, getTacticsData("anticheat", "speedhach") == "true" and "Enable" or "Disable", true, admin_tab_anticheat);
        guiComboBoxAddItem(anticheat_speedhack, "Enable");
        guiComboBoxAddItem(anticheat_speedhack, "Disable");
        guiSetFont(guiCreateLabel(0.02, 0.15, 0.23, 0.055, "GodMode", true, admin_tab_anticheat), "default-bold-small");
        anticheat_godmode = guiCreateComboBox(0.28, 0.14500000000000002, 0.2, 0.2, getTacticsData("anticheat", "godmode") == "true" and "Enable" or "Disable", true, admin_tab_anticheat);
        guiComboBoxAddItem(anticheat_godmode, "Enable");
        guiComboBoxAddItem(anticheat_godmode, "Disable");
        guiSetFont(guiCreateLabel(0.02, 0.21, 0.23, 0.055, "Mods", true, admin_tab_anticheat), "default-bold-small");
        anticheat_mods = guiCreateComboBox(0.28, 0.20500000000000002, 0.2, 0.2, getTacticsData("anticheat", "mods") == "true" and "Enable" or "Disable", true, admin_tab_anticheat);
        guiComboBoxAddItem(anticheat_mods, "Enable");
        guiComboBoxAddItem(anticheat_mods, "Disable");
        anticheat_modslist = guiCreateGridList(0.02, 0.27, 0.47, 0.65, true, admin_tab_anticheat);
        guiGridListSetSortingEnabled(anticheat_modslist, false);
        guiGridListAddColumn(anticheat_modslist, "Modification", 0.55);
        guiGridListAddColumn(anticheat_modslist, "Search", 0.3);
        anticheat_modsadd = guiCreateButton(0.02, 0.93, 0.23, 0.05, "Add", true, admin_tab_anticheat);
        guiSetFont(anticheat_modsadd, "default-bold-small");
        anticheat_modsdel = guiCreateButton(0.26, 0.93, 0.23, 0.05, "Delete", true, admin_tab_anticheat);
        guiSetFont(anticheat_modsdel, "default-bold-small");
        refreshSettingsConfig();
        refreshTeamConfig();
        remakeAdminWeaponsPack();
        refreshVehicleConfig();
        refreshWeatherConfig();
        updateAdminMaps();
        refreshCyclerResources();
        updateAdmin();
        refreshAnticheatSearch();
        return admin_window;
    end;
    createAdminRenameConfig = function() 
        rename_window = guiCreateWindow(xscreen * 0.5 - 42.5, yscreen * 0.5 - 130, 240, 85, "Rename Config", false);
        guiWindowSetSizable(rename_window, false);
        guiSetFont(guiCreateLabel(12, 26, 80, 20.8, "Filename", false, rename_window), "default-bold-small");
        rename_name = guiCreateEdit(80, 26, 160, 20.8, "", false, rename_window);
        rename_ok = guiCreateButton(12, 52, 103.2, 18.2, "Rename", false, rename_window);
        guiSetFont(rename_ok, "default-bold-small");
        rename_cancel = guiCreateButton(122.4, 52, 103.2, 18.2, "Cancel", false, rename_window);
        guiSetFont(rename_cancel, "default-bold-small");
        return rename_window;
    end;
    createAdminAddConfig = function() 
        add_window = guiCreateWindow(xscreen * 0.5 - 42.5, yscreen * 0.5 - 130, 240, 85, "Add Config", false);
        guiWindowSetSizable(add_window, false);
        guiSetFont(guiCreateLabel(12, 26, 80, 20.8, "Filename", false, add_window), "default-bold-small");
        add_name = guiCreateEdit(80, 26, 160, 20.8, "", false, add_window);
        add_ok = guiCreateButton(12, 52, 103.2, 18.2, "Add", false, add_window);
        guiSetFont(add_ok, "default-bold-small");
        add_cancel = guiCreateButton(122.4, 52, 103.2, 18.2, "Cancel", false, add_window);
        guiSetFont(add_cancel, "default-bold-small");
        return add_window;
    end;
    createAdminSaveConfig = function() 
        save_window = guiCreateWindow(xscreen * 0.5 - 120, yscreen * 0.5 - 130, 240, 260, "Save Config", false);
        guiWindowSetSizable(save_window, false);
        guiSetFont(guiCreateLabel(0.05, 0.1, 0.25, 0.08, "Name", true, save_window), "default-bold-small");
        local serverSelectedConfigName = "";
        if isElement(admin_window) then
            local serverSelectedConfigIndex = guiGridListGetSelectedItem(config_list);
            if serverSelectedConfigIndex > -1 then
                serverSelectedConfigName = guiGridListGetItemText(config_list, serverSelectedConfigIndex, 1);
            end;
        end;
        save_name = guiCreateEdit(0.25, 0.1, 0.75, 0.08, serverSelectedConfigName, true, save_window);
        guiSetFont(guiCreateLabel(0.05, 0.2, 0.25, 0.08, "Tabs", true, save_window), "default-bold-small");
        save_all = guiCreateCheckBox(0.25, 0.2, 0.75, 0.08, "All", true, true, save_window);
        save_maps = guiCreateCheckBox(0.25, 0.28, 0.3, 0.08, "Maps", true, true, save_window);
        guiSetEnabled(save_maps, false);
        save_settings = guiCreateCheckBox(0.25, 0.36, 0.3, 0.08, "Settings", true, true, save_window);
        guiSetEnabled(save_settings, false);
        save_teams = guiCreateCheckBox(0.25, 0.44, 0.3, 0.08, "Teams", true, true, save_window);
        guiSetEnabled(save_teams, false);
        save_weapons = guiCreateCheckBox(0.25, 0.52, 0.3, 0.08, "Weapons", true, true, save_window);
        guiSetEnabled(save_weapons, false);
        save_vehicles = guiCreateCheckBox(0.25, 0.6000000000000001, 0.35, 0.08, "Vehicles", true, true, save_window);
        guiSetEnabled(save_vehicles, false);
        save_weather = guiCreateCheckBox(0.6, 0.28, 0.35, 0.08, "Weather", true, true, save_window);
        guiSetEnabled(save_weather, false);
        save_shooting = guiCreateCheckBox(0.6, 0.36, 0.35, 0.08, "Shooting", true, true, save_window);
        guiSetEnabled(save_shooting, false);
        guiSetVisible(save_shooting, false);
        save_handling = guiCreateCheckBox(0.6, 0.44, 0.35, 0.08, "Handling", true, true, save_window);
        guiSetEnabled(save_handling, false);
        guiSetVisible(save_handling, false);
        save_anticheat = guiCreateCheckBox(0.6, 0.52, 0.35, 0.08, "AC", true, true, save_window);
        guiSetEnabled(save_anticheat, false);
        guiSetVisible(save_anticheat, false);
        save_ok = guiCreateButton(0.05, 0.88, 0.43, 0.07, "Save", true, save_window);
        guiSetFont(save_ok, "default-bold-small");
        save_cancel = guiCreateButton(0.51, 0.88, 0.43, 0.07, "Cancel", true, save_window);
        guiSetFont(save_cancel, "default-bold-small");
        return save_window;
    end;
    createAdminScreen = function() 
        screen_window = guiCreateWindow(xscreen * 0.5 - 120, yscreen * 0.5 - 150, 240, 120, "Screen Shot", false);
        guiWindowSetSizable(screen_window, false);
        screen_image = guiCreateStaticImage(10, 25, 1, 1, "images/color_pixel.png", false, screen_window);
        screen_menu = guiCreateStaticImage(0, 0, 320, 32, "images/color_pixel.png", false, screen_image);
        guiSetProperty(screen_menu, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
        screen_close = guiCreateButton(5, 5, 80, 22, "Close", false, screen_menu);
        guiSetFont(screen_close, "default-bold-small");
        screen_name = guiCreateEdit(90, 5, 170, 22, "", false, screen_menu);
        screen_save = guiCreateButton(265, 5, 50, 22, "Save", false, screen_menu);
        screen_list = guiCreateComboBox(90, 5, 225, 200, "", false, screen_menu);
        guiSetProperty(screen_list, "ClippedByParent", "False");
        local serverScreenshotsXML = xmlLoadFile("screenshots/_list.xml");
        if serverScreenshotsXML then
            local serverScreenshotFilename = nil;
            for __, serverScreenshotXMLNode in ipairs(xmlNodeGetChildren(serverScreenshotsXML)) do
                serverScreenshotFilename = xmlNodeGetAttribute(serverScreenshotXMLNode, "src");
                if serverScreenshotFilename then
                    if fileExists("screenshots/" .. serverScreenshotFilename .. ".jpg") then
                        guiComboBoxAddItem(screen_list, serverScreenshotFilename);
                    else
                        xmlDestroyNode(serverScreenshotXMLNode);
                    end;
                end;
            end;
            if serverScreenshotFilename then
                guiSetText(screen_list, serverScreenshotFilename);
            end;
            xmlSaveFile(serverScreenshotsXML);
            xmlUnloadFile(serverScreenshotsXML);
        end;
        guiSetVisible(screen_list, false);
        guiSetFont(screen_save, "default-bold-small");
        guiEditSetReadOnly(screen_name, true);
        guiSetAlpha(screen_menu, 0.2);
        return screen_window;
    end;
    createAdminRedirect = function() 
        redirect_window = guiCreateWindow(xscreen * 0.5 - 120, yscreen * 0.5 - 150, 240, 120, "Redirect", false);
        guiWindowSetSizable(redirect_window, false);
        guiCreateLabel(0.05, 0.2, 0.17, 0.18, "Host:", true, redirect_window);
        redirect_ip = guiCreateEdit(0.2, 0.2, 0.5, 0.18, "", true, redirect_window);
        redirect_port = guiCreateEdit(0.72, 0.2, 0.26, 0.18, "", true, redirect_window);
        guiEditSetMaxLength(redirect_port, 5);
        guiCreateLabel(0.05, 0.4, 0.17, 0.2, "Pass:", true, redirect_window);
        redirect_password = guiCreateEdit(0.2, 0.4, 0.78, 0.18, "", true, redirect_window);
        guiEditSetMasked(redirect_password, true);
        redirect_reconnect = guiCreateCheckBox(0.2, 0.57, 0.78, 0.16, "Reconnect", false, true, redirect_window);
        guiSetEnabled(redirect_reconnect, false);
        redirect_yes = guiCreateButton(0.05, 0.75, 0.4, 0.18, "Connect", true, redirect_window);
        guiSetFont(redirect_yes, "default-bold-small");
        redirect_no = guiCreateButton(0.55, 0.75, 0.4, 0.18, "Close", true, redirect_window);
        guiSetFont(redirect_no, "default-bold-small");
        return redirect_window;
    end;
    createAdminRestore = function() 
        restore_window = guiCreateWindow(xscreen * 0.5 - 150, yscreen * 0.5 - 100, 300, 200, "", false);
        guiWindowSetSizable(restore_window, false);
        restore_list = guiCreateGridList(0.01, 0.1, 0.98, 0.7, true, restore_window);
        guiGridListSetSortingEnabled(restore_list, false);
        restore_name = guiGridListAddColumn(restore_list, "Name", 0.6);
        restore_team = guiGridListAddColumn(restore_list, "Team", 0.3);
        restore_yes = guiCreateButton(0.33, 0.85, 0.15, 0.1, "Yes", true, restore_window);
        guiSetFont(restore_yes, "default-bold-small");
        restore_no = guiCreateButton(0.52, 0.85, 0.15, 0.1, "No", true, restore_window);
        guiSetFont(restore_no, "default-bold-small");
        restore_player = false;
        return restore_window;
    end;
    createAdminRules = function() 
        rules_window = guiCreateWindow(xscreen * 0.5 - 120, yscreen * 0.5 - 50, 240, 100, "Change rule", false);
        guiWindowSetSizable(rules_window, false);
        rules_label = guiCreateLabel(12, 25, 216, 20, "", false, rules_window);
        rules_edit = guiCreateEdit(24, 45, 192, 20, "", false, rules_window);
        rules_list = guiCreateGridList(24, 45, 192, 20, false, rules_window);
        guiGridListSetSortingEnabled(rules_list, false);
        guiGridListAddColumn(rules_list, "Values", 0.8);
        rules_time = guiCreateEdit(60, 55, 100, 20, "00:00:00.0", false, rules_window);
        rules_time_up = guiCreateStaticImage(160, 55, 20, 10, "images/numericup.png", false, rules_window);
        rules_time_down = guiCreateStaticImage(160, 65, 20, 10, "images/numericdown.png", false, rules_window);
        rules_ok = guiCreateButton(60, 70, 57.6, 20, "Edit", false, rules_window);
        guiSetFont(rules_ok, "default-bold-small");
        rules_cancel = guiCreateButton(122.4, 70, 57.6, 20, "Cancel", false, rules_window);
        guiSetFont(rules_cancel, "default-bold-small");
        return rules_window;
    end;
    createAdminPalette = function() 
        palette_window = guiCreateWindow(xscreen * 0.5 - 150, yscreen * 0.5 - 165, 300, 330, "Color Palette", false);
        guiWindowSetSizable(palette_window, false);
        guiSetAlpha(palette_window, 1);
        palette_hue = guiCreateStaticImage(0.05, 0.09, 0.75, 0.65, "images/color_hue.png", true, palette_window);
        palette_color2 = guiCreateStaticImage(0.05, 0.76, 0.25, 0.12, "images/color_pixel.png", true, palette_window);
        palette_color1 = guiCreateStaticImage(0.83, 0.09, 0.1, 0.65, "images/color_pixel.png", true, palette_window);
        palette_light = guiCreateStaticImage(0.83, 0.09, 0.1, 0.65, "images/color_light.png", true, palette_window);
        palette_aim = guiCreateStaticImage(0.03, 0.07, 0.04, 0.04, "images/color_aim.png", true, palette_window);
        palette_aim2 = guiCreateStaticImage(0.93, 0.07, 0.04, 0.04, "images/color_aim2.png", true, palette_window);
        local serverPaletteHueValue = 0;
        local serverPaletteSaturationValue = 0;
        local serverPaletteLightnessValue = 0;
        palette_element = nil;
        palette_L = serverPaletteLightnessValue;
        palette_S = serverPaletteSaturationValue;
        palette_H = serverPaletteHueValue;
        temp = guiCreateLabel(0.32, 0.76, 0.1, 0.06, "R", true, palette_window);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetColor(temp, 255, 0, 0);
        palette_rr = guiCreateEdit(0.35, 0.76, 0.17, 0.06, "", true, palette_window);
        guiEditSetMaxLength(palette_rr, 3);
        temp = guiCreateLabel(0.53, 0.76, 0.1, 0.06, "G", true, palette_window);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetColor(temp, 0, 255, 0);
        palette_gg = guiCreateEdit(0.56, 0.76, 0.17, 0.06, "", true, palette_window);
        guiEditSetMaxLength(palette_gg, 3);
        temp = guiCreateLabel(0.74, 0.76, 0.1, 0.06, "B", true, palette_window);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetColor(temp, 0, 0, 255);
        palette_bb = guiCreateEdit(0.77, 0.76, 0.17, 0.06, "", true, palette_window);
        guiEditSetMaxLength(palette_bb, 3);
        temp = guiCreateLabel(0.32, 0.83, 0.1, 0.06, "A", true, palette_window);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetColor(temp, 255, 255, 255);
        palette_aa = guiCreateEdit(0.35, 0.83, 0.17, 0.06, "255", true, palette_window);
        guiEditSetMaxLength(palette_aa, 3);
        temp = guiCreateLabel(0.53, 0.83, 0.1, 0.06, "Hex", true, palette_window);
        guiSetFont(temp, "default-bold-small");
        palette_hex = guiCreateEdit(0.62, 0.83, 0.32, 0.06, "", true, palette_window);
        guiEditSetMaxLength(palette_hex, 8);
        palette_ok = guiCreateButton(0.25, 0.91, 0.24, 0.06, "OK", true, palette_window);
        guiSetFont(palette_ok, "default-bold-small");
        palette_cancel = guiCreateButton(0.51, 0.91, 0.24, 0.06, "Close", true, palette_window);
        guiSetFont(palette_cancel, "default-bold-small");
        return palette_window;
    end;
    createAdminMods = function() 
        mods_window = guiCreateWindow(xscreen * 0.5 - 150, yscreen * 0.5 - 60, 300, 120, "Change mod", false);
        guiWindowSetSizable(mods_window, false);
        guiSetFont(guiCreateLabel(12, 25, 275, 50, "Name", false, mods_window), "default-bold-small");
        mods_name = guiCreateEdit(62, 25, 275, 20, "", false, mods_window);
        mods_label = guiCreateLabel(12, 45, 275, 20, "Use '*' for group of any character", false, mods_window);
        guiSetFont(guiCreateLabel(12, 65, 275, 50, "Search", false, mods_window), "default-bold-small");
        mods_edit = guiCreateEdit(62, 65, 275, 20, "", false, mods_window);
        mods_type_name = guiCreateRadioButton(12, 90, 50, 20, "Name", false, mods_window);
        mods_type_hash = guiCreateRadioButton(64, 90, 50, 20, "Hash", false, mods_window);
        guiRadioButtonSetSelected(mods_type_name, true);
        mods_ok = guiCreateButton(150, 90, 67, 20, "Set", false, mods_window);
        guiSetFont(mods_ok, "default-bold-small");
        mods_cancel = guiCreateButton(222, 90, 67, 20, "Cancel", false, mods_window);
        guiSetFont(mods_cancel, "default-bold-small");
        return mods_window;
    end;
    refreshAnticheatSearch = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverAnticheatModList = getTacticsData("anticheat", "modslist") or {};
            local serverAnticheatRowCount = guiGridListGetRowCount(anticheat_modslist);
            for serverAnticheatRowIndex = 0, math.max(serverAnticheatRowCount, #serverAnticheatModList) do
                if serverAnticheatRowIndex < #serverAnticheatModList then
                    if serverAnticheatRowCount <= serverAnticheatRowIndex then
                        guiGridListAddRow(anticheat_modslist);
                    end;
                    guiGridListSetItemText(anticheat_modslist, serverAnticheatRowIndex, 1, tostring(serverAnticheatModList[serverAnticheatRowIndex + 1].name), false, false);
                    guiGridListSetItemText(anticheat_modslist, serverAnticheatRowIndex, 2, tostring(serverAnticheatModList[serverAnticheatRowIndex + 1].search), false, false);
                    guiGridListSetItemData(anticheat_modslist, serverAnticheatRowIndex, 2, tostring(serverAnticheatModList[serverAnticheatRowIndex + 1].type));
                else
                    guiGridListRemoveRow(anticheat_modslist, serverAnticheatRowIndex);
                end;
            end;
            return;
        end;
    end;
    refreshSettingsConfig = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverSelectedModeIndex = guiGridListGetSelectedItem(modes_list);
            local serverSelectedModeText = false;
            if serverSelectedModeIndex ~= -1 then
                serverSelectedModeText = guiGridListGetItemText(modes_list, serverSelectedModeIndex, 1);
            end;
            guiGridListClear(modes_list);
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Tactics", true, false);
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "settings", false, false);
            if serverSelectedModeText == "settings" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "glitches", false, false);
            if serverSelectedModeText == "glitches" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "cheats", false, false);
            if serverSelectedModeText == "cheats" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "limites", false, false);
            if serverSelectedModeText == "limites" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Modes", true, false);
            local serverSortedModes = {};
            local serverPairsIterator = pairs;
            local serverModesData = getTacticsData("modes") or {};
            for serverModeKey, serverModeData in serverPairsIterator(serverModesData) do
                table.insert(serverSortedModes, {serverModeKey, serverModeData});
            end;
            table.sort(serverSortedModes, function(serverFirstModeEntry, serverSecondModeEntry) 
                return serverFirstModeEntry[1] < serverSecondModeEntry[1];
            end);
            for __, serverModeEntry in ipairs(serverSortedModes) do
                local serverModeName = tostring(serverModeEntry[1]);
                local serverModeSettings = serverModeEntry[2] or {};
                local serverModeRowIndex = guiGridListAddRow(modes_list);
                guiGridListSetItemText(modes_list, serverModeRowIndex, 1, serverModeName, false, false);
                if serverModeSettings.enable == "false" then
                    guiGridListSetItemColor(modes_list, serverModeRowIndex, 1, 255, 0, 0);
                end;
                if serverSelectedModeText == serverModeName then
                    guiGridListSetSelectedItem(modes_list, serverModeRowIndex, 1);
                end;
            end;
            triggerEvent("onClientGUIClick", modes_list, "left");
            return;
        end;
    end;
    refreshWeatherConfig = function() 
        if not isElement(admin_window) then
            return;
        else
            while guiGridListGetColumnCount(weather_record) > 0 do
                guiGridListRemoveColumn(weather_record, 1);
            end;
            local serverSelectedWeatherColumn = 0;
            local serverWeatherData = getTacticsData("Weather") or {};
            local serverCurrentHour = getTime();
            for serverHourIndex = 0, 23 do
                if serverWeatherData[serverHourIndex] then
                    local serverWeatherColumnIndex = guiGridListAddColumn(weather_record, tostring(serverHourIndex) .. "h", 0.08);
                    guiGridListAddRow(weather_record);
                    guiGridListAddRow(weather_record);
                    guiGridListSetItemText(weather_record, 0, serverWeatherColumnIndex, " ", false, false);
                    guiGridListSetItemText(weather_record, 1, serverWeatherColumnIndex, " ", false, false);
                    guiGridListSetItemData(weather_record, 1, serverWeatherColumnIndex, tostring(serverHourIndex));
                    if tonumber(serverHourIndex) <= serverCurrentHour then
                        serverSelectedWeatherColumn = serverWeatherColumnIndex;
                    end;
                end;
            end;
            if guiGridListGetSelectedItem(weather_record) < 0 then
                if serverSelectedWeatherColumn == 0 then
                    serverSelectedWeatherColumn = guiGridListGetColumnCount(weather_record);
                end;
                guiGridListSetSelectedItem(weather_record, 0, serverSelectedWeatherColumn);
                triggerEvent("onClientGUIDoubleClick", weather_record, "left");
            end;
            return;
        end;
    end;
    refreshConfiglist = function(serverConfigDataParameter) 
        if not isElement(admin_window) then
            return;
        else
            guiGridListClear(config_list);
            for __, serverConfigEntry in ipairs(serverConfigDataParameter) do
                row = guiGridListAddRow(config_list);
                guiGridListSetItemText(config_list, row, 1, serverConfigEntry[1], false, false);
                guiGridListSetItemData(config_list, row, 1, serverConfigEntry[3]);
                guiGridListSetItemColor(config_list, row, 1, serverConfigEntry[2], 255, serverConfigEntry[2]);
            end;
            return;
        end;
    end;
    updateAdmin = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverPlayersList = {};
            for __, serverPlayerElement in ipairs(getElementsByType("player")) do
                if not getPlayerTeam(serverPlayerElement) then
                    table.insert(serverPlayersList, {serverPlayerElement, nil});
                end;
            end;
            for __, serverTeamElement in ipairs(getElementsByType("team")) do
                for __, serverTeamPlayer in ipairs(getPlayersInTeam(serverTeamElement)) do
                    table.insert(serverPlayersList, {serverTeamPlayer, serverTeamElement});
                end;
            end;
            local serverPlayerGridRowCount = guiGridListGetRowCount(player_list);
            local serverSelectedPlayerIDs = {};
            for __, serverSelectedPlayer in ipairs(guiGridListGetSelectedItems(player_list)) do
                if serverSelectedPlayer.column == player_id then
                    serverSelectedPlayerIDs[guiGridListGetItemText(player_list, serverSelectedPlayer.row, player_id)] = true;
                end;
            end;
            guiGridListSetSelectedItem(player_list, 0, 0);
            for serverPlayerRowIndex = 0, math.max(serverPlayerGridRowCount, #serverPlayersList) do
                if serverPlayerRowIndex < #serverPlayersList then
                    local serverCurrentPlayer = serverPlayersList[serverPlayerRowIndex + 1][1];
                    local serverPlayerTeam = serverPlayersList[serverPlayerRowIndex + 1][2];
                    if serverPlayerGridRowCount <= serverPlayerRowIndex then
                        guiGridListAddRow(player_list);
                    end;
                    guiGridListSetItemText(player_list, serverPlayerRowIndex, player_id, tostring(getElementID(serverCurrentPlayer)), false, false)
                    if serverSelectedPlayerIDs[getElementID(serverCurrentPlayer)] then
                        guiGridListSetSelectedItem(player_list, serverPlayerRowIndex, player_id, false);
                    end;
                    guiGridListSetItemText(player_list, serverPlayerRowIndex, player_name, removeColorCoding(getPlayerName(serverCurrentPlayer)), false, false);
                    if not serverPlayerTeam then
                        guiGridListSetItemColor(player_list, serverPlayerRowIndex, player_name, 255, 255, 255);
                    else
                        guiGridListSetItemColor(player_list, serverPlayerRowIndex, player_name, getTeamColor(serverPlayerTeam));
                    end;
                    local serverPlayerStatus = getElementData(serverCurrentPlayer, "Status") or "";
                    if serverPlayerStatus == "Play" and getTacticsData("settings", "player_information") == "true" then
                        serverPlayerStatus = tostring(math.floor(getElementHealth(serverCurrentPlayer) + getPedArmor(serverCurrentPlayer)));
                    end;
                    if serverPlayerStatus == "Spectate" then
                        serverPlayerStatus = "";
                    end;
                    guiGridListSetItemText(player_list, serverPlayerRowIndex, player_status, serverPlayerStatus, false, false);
                else
                    guiGridListRemoveRow(player_list, #serverPlayersList);
                end;
            end;
            local serverSelectedPlayerItems = guiGridListGetSelectedItems(player_list);
            if #serverSelectedPlayerItems == 3 then
                local serverSelectedPlayerElement = getElementByID(guiGridListGetItemText(player_list, serverSelectedPlayerItems[1].row, player_id));
                if serverSelectedPlayerElement and isElement(serverSelectedPlayerElement) then
                    local serverPlayerInfoText = "Nickname: " .. getPlayerName(serverSelectedPlayerElement) .. "\nSerial: " .. tostring(getElementData(serverSelectedPlayerElement, "Serial")) .. "\nIP: " .. tostring(getElementData(serverSelectedPlayerElement, "IP")) .. "\nVersion: " .. tostring(getElementData(serverSelectedPlayerElement, "Version")) .. "\n";
                    if guiGetText(player_info) ~= serverPlayerInfoText then
                        guiSetText(player_info, serverPlayerInfoText);
                    end;
                    if getElementData(serverSelectedPlayerElement, "Status") == "Play" then
                        if guiGetText(player_add) ~= "Remove" then
                            guiSetText(player_add, "Remove");
                        end;
                    elseif guiGetText(player_add) ~= "Add" then
                        guiSetText(player_add, "Add");
                    end;
                    guiCheckBoxSetSelected(player_specskin, getElementData(serverSelectedPlayerElement, "spectateskin") and true or false);
                end;
            else
                if guiGetText(player_info) ~= "" then
                    guiSetText(player_info, "");
                end;
                if guiGetText(player_add) ~= "Add/Remove" then
                    guiSetText(player_add, "Add/Remove");
                end;
                if guiCheckBoxGetSelected(player_specskin) then
                    guiCheckBoxSetSelected(player_specskin, false);
                end;
            end;
            local serverIsPaused, serverPauseTimer = isRoundPaused();
            if serverIsPaused then
                if serverPauseTimer then
                    guiSetText(player_pause, "Unpause ... " .. string.format("%.0f", serverPauseTimer / 1000));
                else
                    guiSetText(player_pause, "Unpause");
                end;
                guiSetProperty(player_pause, "NormalTextColour", "C00080FF");
            end;
            return;
        end;
    end;
    refreshCyclerResources = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverCyclerResources = getTacticsData("Resources");
            if serverCyclerResources and #serverCyclerResources > 0 then
                local serverCurrentResourceIndex = getTacticsData("ResourceCurrent");
                local serverCyclerRowCount = guiGridListGetRowCount(server_cycler);
                for serverResourceIndex = 1, math.max(serverCyclerRowCount, #serverCyclerResources) do
                    if serverResourceIndex <= #serverCyclerResources then
                        local serverResourceName = serverCyclerResources[serverResourceIndex][1];
                        local serverResourceMode = serverCyclerResources[serverResourceIndex][2];
                        local serverResourceDisplayName = serverCyclerResources[serverResourceIndex][3];
                        if serverCyclerRowCount < serverResourceIndex then
                            guiGridListAddRow(server_cycler);
                        end;
                        guiGridListSetItemText(server_cycler, serverResourceIndex - 1, 1, tostring(serverResourceIndex), true, false);
                        guiGridListSetItemText(server_cycler, serverResourceIndex - 1, 2, serverResourceMode, false, false);
                        guiGridListSetItemData(server_cycler, serverResourceIndex - 1, 2, serverResourceName);
                        guiGridListSetItemText(server_cycler, serverResourceIndex - 1, 3, serverResourceDisplayName, false, false);
                        if serverCurrentResourceIndex == serverResourceIndex then
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 1, 255, 40, 0);
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 2, 255, 40, 0);
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 3, 255, 40, 0);
                        else
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 1, 255, 255, 255);
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 2, 255, 255, 255);
                            guiGridListSetItemColor(server_cycler, serverResourceIndex - 1, 3, 255, 255, 255);
                        end;
                    else
                        guiGridListRemoveRow(server_cycler, #serverCyclerResources);
                    end;
                end;
            else
                guiGridListClear(server_cycler);
            end;
            return;
        end;
    end;
    refreshRestores = function() 
        if not isElement(restore_window) then
            return;
        else
            guiGridListClear(restore_list);
            local serverRestoresData = getTacticsData("Restores");
            if not serverRestoresData then
                return;
            else
                for __, serverRestoreEntry in ipairs(serverRestoresData) do
                    local serverRestoreRowIndex = guiGridListAddRow(restore_list);
                    guiGridListSetItemText(restore_list, serverRestoreRowIndex, restore_name, tostring(serverRestoreEntry[1]), false, false);
                    guiGridListSetItemText(restore_list, serverRestoreRowIndex, restore_team, getTeamName(serverRestoreEntry[2]), false, false);
                end;
                return;
            end;
        end;
    end;
    refreshTeamConfig = function() 
        if not isElement(admin_window) then
            return;
        else
            for serverTeamIndex, serverTeamGUI in ipairs(teams_teams) do
                destroyElement(serverTeamGUI.name);
                destroyElement(serverTeamGUI.color);
                if serverTeamIndex > 1 then
                    destroyElement(serverTeamGUI.side);
                    destroyElement(serverTeamGUI.skin);
                    destroyElement(serverTeamGUI.score);
                    destroyElement(serverTeamGUI.remove);
                end;
                teams_teams[serverTeamIndex] = nil;
            end;
            teams_teams = {};
            local serverTeamYPosition = 0;
            local serverTeamsList = getElementsByType("team");
            for serverTeamListIndex, serverTeamObject in ipairs(serverTeamsList) do
                local serverTeamSideEdit = nil;
                local serverTeamSkinEdit = nil;
                local serverTeamScoreEdit = nil;
                local serverTeamRemoveButton = nil;
                local serverTeamNameEdit = guiCreateEdit(53, serverTeamYPosition * 25, 120, 21, getTeamName(serverTeamObject), false, teams_scroller);
                if serverTeamListIndex > 1 then
                    local serverTeamSideValue = getElementData(serverTeamObject, "Side") or serverTeamListIndex;
                    serverTeamSideEdit = guiCreateEdit(8, serverTeamYPosition * 25, 40, 21, tostring(serverTeamSideValue), false, teams_scroller);
                    guiEditSetReadOnly(serverTeamSideEdit, true);
                    guiSetProperty(serverTeamSideEdit, "WantsMultiClickEvents", "False");
                    if serverTeamsList[serverTeamSideValue + 1] then
                        guiSetProperty(serverTeamSideEdit, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(serverTeamsList[serverTeamSideValue + 1])));
                    end;
                    local serverTeamSkinsText = "";
                    local l_ipairs_0 = ipairs;
                    local serverTeamSkins = getElementData(serverTeamObject, "Skins") or {};
                    for serverSkinIndex, serverSkinID in l_ipairs_0(serverTeamSkins) do
                        if serverSkinIndex > 1 then
                            serverTeamSkinsText = serverTeamSkinsText .. "," .. tostring(serverSkinID);
                        else
                            serverTeamSkinsText = tostring(serverSkinID);
                        end;
                    end;
                    serverTeamSkinEdit = guiCreateEdit(178, serverTeamYPosition * 25, 80, 21, tostring(serverTeamSkinsText), false, teams_scroller);
                    l_ipairs_0 = getElementData(serverTeamObject, "Score") or 0;
                    serverTeamScoreEdit = guiCreateEdit(263, serverTeamYPosition * 25, 50, 21, tostring(l_ipairs_0), false, teams_scroller);
                end;
                local serverTeamColorEdit = guiCreateEdit(318, serverTeamYPosition * 25, 50, 21, "", false, teams_scroller);
                guiEditSetReadOnly(serverTeamColorEdit, true);
                guiSetProperty(serverTeamColorEdit, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(serverTeamObject)));
                if serverTeamListIndex > 1 then
                    serverTeamRemoveButton = guiCreateButton(373, serverTeamYPosition * 25, 70, 21, "Remove", false, teams_scroller);
                    guiSetFont(serverTeamRemoveButton, "default-bold-small");
                    guiSetProperty(serverTeamRemoveButton, "NormalTextColour", "C0FF0000");
                end;
                if serverTeamListIndex > 1 then
                    table.insert(teams_teams, {name = serverTeamNameEdit, color = serverTeamColorEdit, side = serverTeamSideEdit, skin = serverTeamSkinEdit, score = serverTeamScoreEdit, remove = serverTeamRemoveButton});
                else
                    table.insert(teams_teams, {name = serverTeamNameEdit, color = serverTeamColorEdit});
                end;
                serverTeamYPosition = serverTeamYPosition + 1;
            end;
            guiSetPosition(teams_apply, 298, serverTeamYPosition * 25, false);
            guiSetPosition(teams_addteam, 373, serverTeamYPosition * 25, false);
            return;
        end;
    end;
    refreshVehicleConfig = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverEnabledVehicles = {};
            local serverDisabledVehicles = {};
            local serverDisabledVehiclesData = getTacticsData("disabled_vehicles") or {};
            for serverVehicleModelID = 400, 611 do
                if #getVehicleNameFromModel(serverVehicleModelID) > 0 then
                    if serverDisabledVehiclesData[serverVehicleModelID] then
                        table.insert(serverDisabledVehicles, {serverVehicleModelID, getVehicleNameFromModel(serverVehicleModelID)});
                    else table.insert(serverEnabledVehicles, {serverVehicleModelID, getVehicleNameFromModel(serverVehicleModelID)});
                    end;
                end;
            end;
            table.sort(serverEnabledVehicles, function(serverFirstVehicle, serverSecondVehicle) 
                return serverFirstVehicle[2] < serverSecondVehicle[2];
            end);
            table.sort(serverDisabledVehicles, function(serverFirstDisabledVehicle, serverSecondDisabledVehicle) 
                return serverFirstDisabledVehicle[2] < serverSecondDisabledVehicle[2];
            end);
            local serverDisabledGridRowCount = guiGridListGetRowCount(vehicles_disabled);
            local serverEnabledGridRowCount = guiGridListGetRowCount(vehicles_enabled);
            for serverDisabledVehicleIndex = 0, math.max(#serverDisabledVehicles, serverDisabledGridRowCount) do
                if serverDisabledVehicleIndex < #serverDisabledVehicles then
                    local serverDisabledModelID, serverDisabledVehicleName = unpack(serverDisabledVehicles[serverDisabledVehicleIndex + 1]);
                    if serverDisabledVehicleIndex < serverDisabledGridRowCount then
                        guiGridListSetItemText(vehicles_disabled, serverDisabledVehicleIndex, 1, serverDisabledVehicleName, false, false);
                        guiGridListSetItemData(vehicles_disabled, serverDisabledVehicleIndex, 1, tostring(serverDisabledModelID));
                    else
                        local serverDisabledRowIndex = guiGridListAddRow(vehicles_disabled);
                        guiGridListSetItemText(vehicles_disabled, serverDisabledRowIndex, 1, serverDisabledVehicleName, false, false);
                        guiGridListSetItemData(vehicles_disabled, serverDisabledRowIndex, 1, tostring(serverDisabledModelID));
                        guiGridListSetItemColor(vehicles_disabled, serverDisabledRowIndex, 1, 255, 0, 0);
                    end;
                else
                    guiGridListRemoveRow(vehicles_disabled, #serverDisabledVehicles);
                end;
            end;
            for serverEnabledVehicleIndex = 0, math.max(#serverEnabledVehicles, serverEnabledGridRowCount) do
                if serverEnabledVehicleIndex < #serverEnabledVehicles then
                    local serverEnabledModelID, serverEnabledVehicleName = unpack(serverEnabledVehicles[serverEnabledVehicleIndex + 1]);
                    if serverEnabledVehicleIndex < serverEnabledGridRowCount then
                        guiGridListSetItemText(vehicles_enabled, serverEnabledVehicleIndex, 1, serverEnabledVehicleName, false, false);
                        guiGridListSetItemData(vehicles_enabled, serverEnabledVehicleIndex, 1, tostring(serverEnabledModelID));
                    else
                        local serverEnabledRowIndex = guiGridListAddRow(vehicles_enabled);
                        guiGridListSetItemText(vehicles_enabled, serverEnabledRowIndex, 1, serverEnabledVehicleName, false, false);
                        guiGridListSetItemData(vehicles_enabled, serverEnabledRowIndex, 1, tostring(serverEnabledModelID));
                        guiGridListSetItemColor(vehicles_enabled, serverEnabledRowIndex, 1, 0, 255, 0);
                    end;
                else
                    guiGridListRemoveRow(vehicles_enabled, #serverEnabledVehicles);
                end;
            end;
            return;
        end;
    end;
    toggleAdmin = function() 
        if guiGetInputEnabled() then
            return;
        else
            if not isElement(admin_window) or not guiGetVisible(admin_window) then
                callServerFunction("showAdminPanel", localPlayer);
            else
                if isTimer(serverAdminUpdateTimer) then
                    killTimer(serverAdminUpdateTimer);
                end;
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(admin_window);
                    if isElement(restore_window) then
                        destroyElement(restore_window);
                    end;
                    if isElement(redirect_window) then
                        destroyElement(redirect_window);
                    end;
                    if isElement(save_window) then
                        destroyElement(save_window);
                    end;
                    if isElement(add_window) then
                        destroyElement(add_window);
                    end;
                    if isElement(rules_window) then
                        destroyElement(rules_window);
                    end;
                    if isElement(palette_window) then
                        destroyElement(palette_window);
                    end;
                    if isElement(rename_window) then
                        destroyElement(rename_window);
                    end;
                    if isElement(screen_window) then
                        destroyElement(screen_window);
                    end;
                    if isElement(mods_window) then
                        destroyElement(mods_window);
                    end;
                else
                    guiSetVisible(admin_window, false);
                    guiSetVisible(restore_window, false);
                    guiSetVisible(redirect_window, false);
                    guiSetVisible(save_window, false);
                    guiSetVisible(add_window, false);
                    guiSetVisible(rules_window, false);
                    guiSetVisible(palette_window, false);
                    guiSetVisible(rename_window, false);
                    guiSetVisible(screen_window, false);
                    guiSetVisible(mods_window, false);
                end;
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            return;
        end;
    end;
    showClientAdminPanel = function(serverAdminPermissions) 
        if not isElement(admin_window) or not guiGetVisible(admin_window) then
            if not isElement(admin_window) then
                createAdminPanel();
            end;
            callServerFunction("refreshConfiglist", localPlayer);
            if isTimer(serverAdminUpdateTimer) then
                killTimer(serverAdminUpdateTimer);
            end;
            serverAdminUpdateTimer = setTimer(updateAdmin, 500, 0);
            guiSetEnabled(config_list, serverAdminPermissions.configs);
            guiSetEnabled(config_delete, serverAdminPermissions.configs);
            guiSetEnabled(config_save, serverAdminPermissions.configs);
            guiSetEnabled(config_rename, serverAdminPermissions.configs);
            guiSetEnabled(config_add, serverAdminPermissions.configs);
            guiSetEnabled(admin_tab_players, serverAdminPermissions.tab_players);
            guiSetEnabled(admin_tab_maps, serverAdminPermissions.tab_maps);
            guiSetEnabled(admin_tab_settings, serverAdminPermissions.tab_settings);
            guiSetEnabled(admin_tab_teams, serverAdminPermissions.tab_teams);
            guiSetEnabled(admin_tab_weapons, serverAdminPermissions.tab_weapons);
            guiSetEnabled(admin_tab_vehicles, serverAdminPermissions.tab_vehicles);
            guiSetEnabled(admin_tab_weather, serverAdminPermissions.tab_weather);
            guiSetEnabled(admin_tab_shooting, serverAdminPermissions.tab_shooting);
            guiSetEnabled(admin_tab_handling, serverAdminPermissions.tab_handling);
            guiSetEnabled(admin_tab_anticheat, serverAdminPermissions.tab_anticheat);
            guiBringToFront(admin_window);
            guiSetVisible(admin_window, true);
            showCursor(true);
        end;
    end;
    onClientGUIAccepted = function(__) 
        if source == rules_edit then
            triggerEvent("onClientGUIClick", rules_ok, "left", "up");
        end;
    end;
    onClientGUIScroll = function(__) 
        if source == wind_slide then
            local serverWindScrollPosition = guiScrollBarGetScrollPosition(wind_slide);
            guiSetText(wind_speed, string.format("%.1f", 0.5 * serverWindScrollPosition));
        end;
        if source == rain_slide then
            local serverRainScrollPosition = guiScrollBarGetScrollPosition(rain_slide);
            guiSetText(rain_level, string.format("%.1f", 0.02 * serverRainScrollPosition));
        end;
        if source == sun_sizeslide then
            local serverSunSizeScrollPosition = guiScrollBarGetScrollPosition(sun_sizeslide);
            guiSetText(sun_size, string.format("%.1f", 0.5 * serverSunSizeScrollPosition));
        end;
        if source == farclip_slide then
            local serverFarClipScrollPosition = guiScrollBarGetScrollPosition(farclip_slide);
            guiSetText(farclip_distance, string.format("%.1f", 30 * serverFarClipScrollPosition));
        end;
        if source == fog_slide then
            local serverFogScrollPosition = guiScrollBarGetScrollPosition(fog_slide);
            guiSetText(fog_distance, string.format("%.1f", 40 * serverFogScrollPosition - 1000));
        end;
        if source == heat_levelslide then
            local serverHeatScrollPosition = guiScrollBarGetScrollPosition(heat_levelslide);
            guiSetText(heat_level, string.format("%.1f", 2.55 * serverHeatScrollPosition));
        end;
        if source == wave_heightslide then
            local serverWaveScrollPosition = guiScrollBarGetScrollPosition(wave_heightslide);
            guiSetText(wave_height, string.format("%.1f", 0.1 * serverWaveScrollPosition));
        end;
        if source == water_levelslide then
            local serverWaterLevelScrollPosition = guiScrollBarGetScrollPosition(water_levelslide);
            guiSetText(water_level, string.format("%.1f", 4 * serverWaterLevelScrollPosition - 200));
        end;
    end;
    onClientGUIClick = function(serverClickSource, __, __, __) 
        if isElement(admin_window) and guiGetVisible(player_list) then
            serverSelectedPlayers = {};
            local serverSelectedGridItems = guiGridListGetSelectedItems(player_list);
            if serverSelectedGridItems then
                for __, serverGridItem in ipairs(serverSelectedGridItems) do
                    if serverGridItem.column == player_id then
                        local serverClickedPlayer = getElementByID(tostring(guiGridListGetItemText(player_list, serverGridItem.row, player_id)));
                        if serverClickedPlayer == localPlayer then
                            table.insert(serverSelectedPlayers, serverClickedPlayer);
                        else
                            table.insert(serverSelectedPlayers, 1, serverClickedPlayer);
                        end;
                    end;
                end;
            end;
            if #serverSelectedPlayers == 0 then
                serverSelectedPlayers = nil;
            end;
        end;
        if source == rules_time_up or source == rules_time_down then
            local serverTimeText = guiGetText(rules_time);
            local serverCaretIndex = tonumber(guiGetProperty(rules_time, "CaratIndex"));
            local serverTimePart = gettok(serverTimeText, 1, string.byte("."));
            local serverHoursValue = tonumber(gettok(serverTimePart, 1, string.byte(":"))) or 0;
            local serverMinutesValue = tonumber(gettok(serverTimePart, 2, string.byte(":"))) or 0;
            local serverSecondsValue = tonumber(gettok(serverTimePart, 3, string.byte(":"))) or 0;
            local serverMillisecondsValue = tonumber(gettok(serverTimeText, 2, string.byte("."))) or 0;
            if serverCaretIndex < 3 then
                if source == rules_time_up then
                    serverHoursValue = (serverHoursValue + 1) % 24;
                else
                    serverHoursValue = (serverHoursValue - 1) % 24;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverHoursValue, serverMinutesValue, serverSecondsValue, serverMillisecondsValue));
                guiEditSetCaretIndex(rules_time, 2);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            elseif serverCaretIndex < 6 then
                if source == rules_time_up then
                    serverMinutesValue = (serverMinutesValue + 1) % 60;
                else
                    serverMinutesValue = (serverMinutesValue - 1) % 60;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverHoursValue, serverMinutesValue, serverSecondsValue, serverMillisecondsValue));
                guiEditSetCaretIndex(rules_time, 5);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            elseif serverCaretIndex < 9 then
                if source == rules_time_up then
                    serverSecondsValue = (serverSecondsValue + 1) % 60;
                else
                    serverSecondsValue = (serverSecondsValue - 1) % 60;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverHoursValue, serverMinutesValue, serverSecondsValue, serverMillisecondsValue));
                guiEditSetCaretIndex(rules_time, 8);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            else
                if source == rules_time_up then
                    serverMillisecondsValue = (serverMillisecondsValue + 1) % 10;
                else
                    serverMillisecondsValue = (serverMillisecondsValue - 1) % 10;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverHoursValue, serverMinutesValue, serverSecondsValue, serverMillisecondsValue));
                guiEditSetCaretIndex(rules_time, 10);
                guiSetProperty(rules_time, "SelectionLength", "-1");
            end;
            guiBringToFront(rules_time);
        end;
        if serverClickSource ~= "left" and isElement(admin_window) and guiGetVisible(admin_tab_teams) then
            for __, serverTeamGUIElement in ipairs(teams_teams) do
                if source == serverTeamGUIElement.side then
                    local serverAvailableTeams = getElementsByType("team");
                    table.remove(serverAvailableTeams, 1);
                    local serverNewSideValue = tonumber(guiGetText(source));
                    serverNewSideValue = serverNewSideValue <= 1 and #serverAvailableTeams or serverNewSideValue - 1;
                    guiSetText(source, tostring(serverNewSideValue));
                    guiSetProperty(source, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(serverAvailableTeams[serverNewSideValue])));
                end;
                return;
            end;
        end;
        if source == window_updates then
            callServerFunction("onPlayerCheckUpdates", localPlayer);
            return;
        elseif source == window_close then
            toggleAdmin();
            return;
        elseif source == player_list then
            updateAdmin();
            return;
        elseif source == player_setteam then
            if not serverSelectedPlayers then
                return;
            else
                local serverSelectedTeam = getTeamFromName(guiGetText(player_setteam));
                for __, serverTargetPlayer in ipairs(serverSelectedPlayers) do
                    triggerServerEvent("onPlayerTeamSelect", serverTargetPlayer, serverSelectedTeam, true);
                end;
                return;
            end;
        elseif source == player_balance then
            callServerFunction("balanceTeams", localPlayer);
            return;
        elseif source == player_specskinbtn then
            if not serverSelectedPlayers or #serverSelectedPlayers > 1 then
                return;
            else
                guiCheckBoxSetSelected(player_specskin, not guiCheckBoxGetSelected(player_specskin));
                callServerFunction("setElementData", serverSelectedPlayers[1], "spectateskin", guiCheckBoxGetSelected(player_specskin));
                return;
            end;
        elseif source == player_specskin then
            if not serverSelectedPlayers or #serverSelectedPlayers > 1 then
                return;
            else
                callServerFunction("setElementData", serverSelectedPlayers[1], "spectateskin", guiCheckBoxGetSelected(player_specskin));
                return;
            end;
        elseif source == player_heal then
            if not serverSelectedPlayers then
                return;
            else
                for __, serverHealPlayer in ipairs(serverSelectedPlayers) do
                    callServerFunction("setElementHealth", serverHealPlayer, 200);
                    callServerFunction("callClientFunction", root, "outputLangString", "player_healed", getPlayerName(serverHealPlayer));
                end;
                return;
            end;
        elseif source == player_fix then
            if not serverSelectedPlayers then
                return;
            else
                for __, serverFixPlayer in ipairs(serverSelectedPlayers) do
                    local serverPlayerVehicle = getPedOccupiedVehicle(serverFixPlayer);
                    if serverPlayerVehicle then
                        callServerFunction("fixVehicle", serverPlayerVehicle);
                        callServerFunction("callClientFunction", root, "outputLangString", "vehicle_healed", getPlayerName(serverFixPlayer));
                    end;
                end;
                return;
            end;
        elseif source == player_healall then
            for __, serverAllPlayersHeal in ipairs(getElementsByType("player")) do
                callServerFunction("setElementHealth", serverAllPlayersHeal, 1000);
            end;
            callServerFunction("callClientFunction", root, "outputLangString", "player_all_healed");
            return;
        elseif source == player_fixall then
            for __, serverAllPlayersFix in ipairs(getElementsByType("player")) do
                local serverPlayerVehicleFix = getPedOccupiedVehicle(serverAllPlayersFix);
                if serverPlayerVehicleFix then
                    callServerFunction("fixVehicle", serverPlayerVehicleFix);
                end;
            end;
            callServerFunction("callClientFunction", root, "outputLangString", "vehicle_all_healed");
            return;
        elseif source == player_swapsides then
            callServerFunction("swapTeams");
            callServerFunction("callClientFunction", root, "outputLangString", "team_swaped");
            return;
        elseif source == player_add then
            if not serverSelectedPlayers then
                return;
            else
                for __, serverAddRemovePlayer in ipairs(serverSelectedPlayers) do
                    if getPlayerTeam(serverAddRemovePlayer) and getPlayerTeam(serverAddRemovePlayer) ~= getElementsByType("team")[1] and not getElementData(serverAddRemovePlayer, "Loading") then
                        if getElementData(serverAddRemovePlayer, "Status") == "Play" then
                            callServerFunction("removePlayer", localPlayer, "", getElementID(serverAddRemovePlayer));
                        else
                            callServerFunction("addPlayer", localPlayer, "", getElementID(serverAddRemovePlayer));
                        end;
                    end;
                end;
                return;
            end;
        elseif source == player_restore then
            if not serverSelectedPlayers or #serverSelectedPlayers > 1 then
                return;
            else
                callServerFunction("restorePlayer", localPlayer, "", getElementID(serverSelectedPlayers[1]));
                return;
            end;
        elseif source == restore_yes then
            local serverSelectedRestoreIndex = guiGridListGetSelectedItem(restore_list);
            if serverSelectedRestoreIndex == -1 then
                return;
            else
                callServerFunction("restorePlayerLoad", restore_player, serverSelectedRestoreIndex + 1);
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(restore_window);
                else
                    guiSetVisible(restore_window, false);
                end;
                restore_player = false;
                return;
            end;
        elseif source == restore_no then
            if guiCheckBoxGetSelected(config_performance_adminpanel) then
                destroyElement(restore_window);
            else
                guiSetVisible(restore_window, false);
            end;
            restore_player = false;
            if isAllGuiHidden() then
                showCursor(false);
            end;
            return;
        elseif source == player_gunmenu then
            if not serverSelectedPlayers then
                return;
            else
                for __, serverGunMenuPlayer in ipairs(serverSelectedPlayers) do
                    callServerFunction("setElementData", serverGunMenuPlayer, "Weapons", true);
                    callServerFunction("callClientFunction", root, "outputLangString", "player_can_weapon_choice", getPlayerName(serverGunMenuPlayer));
                end;
                return;
            end;
        elseif source == player_pause then
            togglePause();
            return;
        elseif source == maps_refresh then
            callServerFunction("refreshMaps", localPlayer, true);
            return;
        elseif source == maps_include then
            updateAdminMaps();
            return;
        elseif source == maps_next then
            local serverSelectedMapItems = guiGridListGetSelectedItems(server_maps);
            if #serverSelectedMapItems ~= 2 then
                return;
            else
                local serverSelectedMapData = guiGridListGetItemData(server_maps, serverSelectedMapItems[1].row, 1);
                callServerFunction("setNextMap", tostring(serverSelectedMapData));
                return;
            end;
        elseif source == maps_cancelnext then
            callServerFunction("cancelNextMap");
            return;
        elseif source == maps_switch then
            local serverSwitchMapItems = guiGridListGetSelectedItems(server_maps);
            if not serverSwitchMapItems then
                return;
            else
                local serverUpdatedResources = getTacticsData("Resources") or {};
                local serverInsertOffset = 1;
                for __, serverResourceItem in ipairs(serverSwitchMapItems) do
                    if serverResourceItem.column == 1 then
                        local serverMapResourceName = guiGridListGetItemData(server_maps, serverResourceItem.row, 1);
                        local serverMapMode = guiGridListGetItemText(server_maps, serverResourceItem.row, 1);
                        local serverMapName = guiGridListGetItemText(server_maps, serverResourceItem.row, 2);
                        local serverSelectedCyclerItems = guiGridListGetSelectedItems(server_cycler);
                        if #serverSelectedCyclerItems == 2 then
                            table.insert(serverUpdatedResources, serverSelectedCyclerItems[1].row + serverInsertOffset, {serverMapResourceName, serverMapMode, serverMapName});
                        else
                            table.insert(serverUpdatedResources, {serverMapResourceName, serverMapMode, serverMapName});
                        end;
                        serverInsertOffset = serverInsertOffset + 1;
                    end;
                end;
                setTacticsData(serverUpdatedResources, "Resources");
                return;
            end;
        elseif source == maps_disable then
            local serverDisableMapItems = guiGridListGetSelectedItems(server_maps);
            if not serverDisableMapItems then
                return;
            else
                local serverDisabledMaps = getTacticsData("map_disabled") or {};
                local __ = 1;
                for __, serverDisabledMapItem in ipairs(serverDisableMapItems) do
                    if serverDisabledMapItem.column == 1 then
                        local serverMapToDisable = guiGridListGetItemData(server_maps, serverDisabledMapItem.row, 1);
                        local serverMapModeText = guiGridListGetItemText(server_maps, serverDisabledMapItem.row, 1);
                        if #serverMapToDisable > #serverMapModeText then
                            local __ = guiGridListGetItemColor(server_maps, serverDisabledMapItem.row, 1);
                            if not serverDisabledMaps[serverMapToDisable] then
                                serverDisabledMaps[serverMapToDisable] = true;
                            else
                                serverDisabledMaps[serverMapToDisable] = nil;
                            end;
                        end;
                    end;
                end;
                setTacticsData(serverDisabledMaps, "map_disabled");
                return;
            end;
        elseif source == maps_end then
            callServerFunction("onRoundStop", localPlayer);
            return;
        elseif source == cycler_switch then
            local serverCyclerSelectedItems = guiGridListGetSelectedItems(server_cycler);
            if not serverCyclerSelectedItems then
                return;
            else
                local serverCyclerResourcesList = getTacticsData("Resources") or {};
                local serverRemoveOffset = 1;
                for __, serverCyclerItem in ipairs(serverCyclerSelectedItems) do
                    if serverCyclerItem.column == 1 then
                        table.remove(serverCyclerResourcesList, serverCyclerItem.row + serverRemoveOffset);
                        serverRemoveOffset = serverRemoveOffset - 1;
                    end;
                end;
                setTacticsData(serverCyclerResourcesList, "Resources");
                return;
            end;
        elseif source == cycler_moveup then
            local serverMoveUpIndex = guiGridListGetSelectedItem(server_cycler);
            if serverMoveUpIndex and serverMoveUpIndex > 0 then
                local serverResourcesForMove = getTacticsData("Resources") or {};
                local serverMovedResource = serverResourcesForMove[serverMoveUpIndex + 1];
                if serverMovedResource then
                    table.remove(serverResourcesForMove, serverMoveUpIndex + 1);
                    table.insert(serverResourcesForMove, serverMoveUpIndex, serverMovedResource);
                    setTacticsData(serverResourcesForMove, "Resources");
                    guiGridListSetSelectedItem(server_cycler, serverMoveUpIndex - 1, 2);
                end;
            end;
            return;
        elseif source == cycler_movedown then
            local serverMoveDownIndex = guiGridListGetSelectedItem(server_cycler);
            if serverMoveDownIndex > -1 then
                local serverResourcesForMoveDown = getTacticsData("Resources") or {};
                if serverMoveDownIndex + 1 < #serverResourcesForMoveDown then
                    local serverResourceToMoveDown = serverResourcesForMoveDown[serverMoveDownIndex + 1];
                    if serverResourceToMoveDown then
                        table.remove(serverResourcesForMoveDown, serverMoveDownIndex + 1);
                        table.insert(serverResourcesForMoveDown, serverMoveDownIndex + 2, serverResourceToMoveDown);
                        setTacticsData(serverResourcesForMoveDown, "Resources");
                        guiGridListSetSelectedItem(server_cycler, serverMoveDownIndex + 1, 2);
                    end;
                end;
            end;
            return;
        elseif source == cycler_clear then
            setTacticsData({}, "Resources");
            return;
        elseif source == cycler_randomize then
            local serverRandomizeResources = getTacticsData("Resources") or {};
            local serverRandomizedResources = {};
            while #serverRandomizeResources > 0 do
                local serverRandomIndex = math.random(#serverRandomizeResources);
                table.insert(serverRandomizedResources, serverRandomizeResources[serverRandomIndex]);
                table.remove(serverRandomizeResources, serverRandomIndex);
            end;
            setTacticsData(serverRandomizedResources, "Resources");
            return;
        elseif source == player_resetstats then
            callServerFunction("resetStats", localPlayer);
            return;
        elseif source == player_redirect then
            if not isElement(redirect_window) then
                createAdminRedirect();
            end;
            guiBringToFront(redirect_window);
            guiSetVisible(redirect_window, true);
            return;
        elseif source == redirect_reconnect then
            if guiCheckBoxGetSelected(redirect_reconnect) then
                guiSetEnabled(redirect_ip, false);
                guiSetEnabled(redirect_port, false);
                guiSetEnabled(redirect_password, false);
            else
                guiSetEnabled(redirect_ip, true);
                guiSetEnabled(redirect_port, true);
                guiSetEnabled(redirect_password, true);
            end;
            return;
        elseif source == redirect_yes then
            if not serverSelectedPlayers then
                return;
            else
                local serverRedirectIP = nil;
                local serverRedirectPort = nil;
                local serverRedirectPassword = nil;
                if not guiCheckBoxGetSelected(redirect_reconnect) then
                    serverRedirectIP = guiGetText(redirect_ip);
                    serverRedirectPort = guiGetText(redirect_port);
                    serverRedirectPassword = guiGetText(redirect_password);
                    if #serverRedirectPassword == 0 then
                        serverRedirectPassword = false;
                    end;
                end;
                callServerFunction("connectPlayers", localPlayer, serverSelectedPlayers, serverRedirectIP, serverRedirectPort, serverRedirectPassword);
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(redirect_window);
                else
                    guiSetVisible(redirect_window, false);
                end;
                return;
            end;
        elseif source == redirect_no then
            if guiCheckBoxGetSelected(config_performance_adminpanel) then
                destroyElement(redirect_window);
            else
                guiSetVisible(redirect_window, false);
            end;
            return;
        else
            if isElement(admin_window) and guiGetVisible(admin_tab_teams) then
                for serverTeamGUIUpdateIndex, serverTeamGUIUpdate in ipairs(teams_teams) do
                    if source == serverTeamGUIUpdate.side then
                        local serverAllTeams = getElementsByType("team");
                        table.remove(serverAllTeams, 1);
                        local serverUpdatedSideValue = tonumber(guiGetText(source));
                        serverUpdatedSideValue = #serverAllTeams <= serverUpdatedSideValue and 1 or serverUpdatedSideValue + 1;
                        guiSetText(source, tostring(serverUpdatedSideValue));
                        guiSetProperty(source, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(serverAllTeams[serverUpdatedSideValue])));
                        return;
                    elseif source == serverTeamGUIUpdate.color then
                        if not isElement(palette_window) then
                            createAdminPalette();
                        end;
                        palette_element = source;
                        local serverColorString = guiGetProperty(source, "ReadOnlyBGColour");
                        local serverColorRed, serverColorGreen, serverColorBlue = getColorFromString("#" .. string.sub(serverColorString, 3, -1));
                        guiSetText(palette_rr, tostring(serverColorRed));
                        guiSetText(palette_gg, tostring(serverColorGreen));
                        guiSetText(palette_bb, tostring(serverColorBlue));
                        guiBringToFront(palette_window);
                        guiSetVisible(palette_window, true);
                        return;
                    elseif source == serverTeamGUIUpdate.remove then
                        local serverTeamToRemove = getElementsByType("team");
                        callServerFunction("removeServerTeam", serverTeamToRemove[serverTeamGUIUpdateIndex]);
                        callServerFunction("callClientFunction", root, "refreshTeamConfig");
                        return;
                    end;
                end;
            end;
            if source == palette_ok then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(palette_window);
                else
                    guiSetVisible(palette_window, false);
                end;
                
                if isElement(palette_element) and isElement(palette_hex) then
                    guiSetProperty(palette_element, "ReadOnlyBGColour", guiGetText(palette_hex));
                    guiBringToFront(palette_element);
                    triggerEvent("onPaletteSetColor", palette_element, guiGetText(palette_hex));
                end;
                
                palette_element = nil;
                return;
            elseif source == palette_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(palette_window);
                else
                    guiSetVisible(palette_window, false);
                end;
                return;
            elseif source == teams_apply then
                local serverTeamsConfig = {};
                for serverTeamConfigIndex, __ in ipairs(getElementsByType("team")) do
                    local serverTeamConfig = {};
                    if serverTeamConfigIndex > 1 then
                        serverTeamConfig.side = guiGetText(teams_teams[serverTeamConfigIndex].side);
                        serverTeamConfig.skin = guiGetText(teams_teams[serverTeamConfigIndex].skin);
                        serverTeamConfig.score = tonumber(guiGetText(teams_teams[serverTeamConfigIndex].score));
                    end;
                    serverTeamConfig.name = guiGetText(teams_teams[serverTeamConfigIndex].name);
                    local serverColorProperty = guiGetProperty(teams_teams[serverTeamConfigIndex].color, "ReadOnlyBGColour");
                    local serverColorAlpha, serverConfigRed, serverConfigGreen, serverConfigBlue = getColorFromString("#" .. serverColorProperty);
                    serverTeamConfig.bb = serverConfigBlue;
                    serverTeamConfig.gg = serverConfigGreen;
                    serverTeamConfig.rr = serverConfigRed;
                    _ = serverColorAlpha;
                    table.insert(serverTeamsConfig, serverTeamConfig);
                end;
                callServerFunction("saveTeamsConfig", serverTeamsConfig);
                return;
            elseif source == teams_addteam then
                callServerFunction("addServerTeam");
                callServerFunction("callClientFunction", root, "refreshTeamConfig");
                return;
            elseif source == vehicles_enable then
                local serverEnableVehicleItems = guiGridListGetSelectedItems(vehicles_disabled);
                if not serverEnableVehicleItems then
                    return;
                else
                    local serverUpdatedDisabledVehicles = getTacticsData("disabled_vehicles") or {};
                    for __, serverEnableVehicleItem in ipairs(serverEnableVehicleItems) do
                        serverUpdatedDisabledVehicles[tonumber(guiGridListGetItemData(vehicles_disabled, serverEnableVehicleItem.row, 1))] = nil;
                    end;
                    setTacticsData(serverUpdatedDisabledVehicles, "disabled_vehicles");
                    return;
                end;
            elseif source == vehicles_disable then
                local serverDisableVehicleItems = guiGridListGetSelectedItems(vehicles_enabled);
                if not serverDisableVehicleItems then
                    return;
                else
                    local serverUpdatedEnabledVehicles = getTacticsData("disabled_vehicles") or {};
                    for __, serverDisableVehicleItem in ipairs(serverDisableVehicleItems) do
                        serverUpdatedEnabledVehicles[tonumber(guiGridListGetItemData(vehicles_enabled, serverDisableVehicleItem.row, 1))] = true;
                    end;
                    setTacticsData(serverUpdatedEnabledVehicles, "disabled_vehicles");
                    return;
                end;
            elseif source == config_save then
                if not isElement(save_window) then
                    createAdminSaveConfig();
                end;
                guiBringToFront(save_window);
                guiSetVisible(save_window, true);
                return;
            elseif source == config_rename then
                if not isElement(admin_window) then
                    return;
                else
                    local serverSelectedConfigIndex = guiGridListGetSelectedItem(config_list);
                    if serverSelectedConfigIndex == -1 then
                        return;
                    else
                        local serverSelectedConfigName = guiGridListGetItemText(config_list, serverSelectedConfigIndex, 1);
                        if serverSelectedConfigName == "_default" then
                            return outputChatBox("Not available", 255, 0, 0);
                        else
                            if not isElement(rename_window) then
                                createAdminRenameConfig();
                            end;
                            guiSetText(rename_name, serverSelectedConfigName);
                            guiBringToFront(rename_window);
                            guiSetVisible(rename_window, true);
                            return;
                        end;
                    end;
                end;
            elseif source == rename_ok then
                local serverRenameConfigIndex = guiGridListGetSelectedItem(config_list);
                if serverRenameConfigIndex == -1 then
                    return;
                else
                    local serverRenameConfigOldName = guiGridListGetItemText(config_list, serverRenameConfigIndex, 1);
                    if serverRenameConfigOldName == "_default" then
                        return outputChatBox("Not available", 255, 0, 0);
                    else
                        local serverRenameConfigNewName = guiGetText(rename_name);
                        if #serverRenameConfigNewName == 0 or not serverRenameConfigNewName then
                            return;
                        else
                            callServerFunction("renameConfig", serverRenameConfigOldName, serverRenameConfigNewName, localPlayer);
                            if guiCheckBoxGetSelected(config_performance_adminpanel) then
                                destroyElement(rename_window);
                            else
                                guiSetVisible(rename_window, false);
                            end;
                            return;
                        end;
                    end;
                end;
            elseif source == rename_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rename_window);
                else
                    guiSetVisible(rename_window, false);
                end;
                return;
            elseif source == config_add then
                if not isElement(add_window) then
                    createAdminAddConfig();
                end;
                guiBringToFront(add_window);
                guiSetVisible(add_window, true);
                return;
            elseif source == add_ok then
                local serverAddConfigName = guiGetText(add_name);
                if #serverAddConfigName == 0 or not serverAddConfigName then
                    return;
                else
                    callServerFunction("addConfig", serverAddConfigName, localPlayer);
                    if guiCheckBoxGetSelected(config_performance_adminpanel) then
                        destroyElement(add_window);
                    else
                        guiSetVisible(add_window, false);
                    end;
                    return;
                end;
            elseif source == add_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(add_window);
                else
                    guiSetVisible(add_window, false);
                end;
                return;
            elseif source == save_ok then
                if not isElement(save_window) then
                    createAdminSaveConfig();
                end;
                local serverSaveConfigName = guiGetText(save_name);
                if #serverSaveConfigName == 0 or not serverSaveConfigName then
                    return;
                elseif serverSaveConfigName == "_default" then
                    return outputChatBox("Not available", 255, 0, 0);
                else
                    local serverSaveOptions = {};
                    if guiCheckBoxGetSelected(save_all) then
                        serverSaveOptions = {
                            Maps = true, 
                            Settings = true, 
                            Teams = true, 
                            Weapons = true, 
                            Vehicles = true, 
                            Weather = true, 
                            Shooting = true, 
                            Handling = true, 
                            AC = true
                        };
                    else
                        serverSaveOptions = {
                            Maps = guiCheckBoxGetSelected(save_maps), 
                            Settings = guiCheckBoxGetSelected(save_settings), 
                            Teams = guiCheckBoxGetSelected(save_teams), 
                            Weapons = guiCheckBoxGetSelected(save_weapons), 
                            Vehicles = guiCheckBoxGetSelected(save_vehicles), 
                            Weather = guiCheckBoxGetSelected(save_weather), 
                            Shooting = guiCheckBoxGetSelected(save_shooting), 
                            Handling = guiCheckBoxGetSelected(save_handling), 
                            AC = guiCheckBoxGetSelected(save_anticheat)
                        };
                    end;
                    if not guiCheckBoxGetSelected(window_expert) then
                        serverSaveOptions.Shooting = false;
                        serverSaveOptions.Handling = false;
                        serverSaveOptions.AC = false;
                    end;
                    callServerFunction("saveConfig", serverSaveConfigName, localPlayer, serverSaveOptions);
                    if guiCheckBoxGetSelected(config_performance_adminpanel) then
                        destroyElement(save_window);
                    else
                        guiSetVisible(save_window, false);
                    end;
                    return;
                end;
            elseif source == save_all then
                if guiCheckBoxGetSelected(save_all) then
                    guiSetEnabled(save_maps, false);
                    guiSetEnabled(save_settings, false);
                    guiSetEnabled(save_teams, false);
                    guiSetEnabled(save_weapons, false);
                    guiSetEnabled(save_vehicles, false);
                    guiSetEnabled(save_weather, false);
                    guiSetEnabled(save_shooting, false);
                    guiSetEnabled(save_handling, false);
                    guiSetEnabled(save_anticheat, false);
                else
                    guiSetEnabled(save_maps, true);
                    guiSetEnabled(save_settings, true);
                    guiSetEnabled(save_teams, true);
                    guiSetEnabled(save_weapons, true);
                    guiSetEnabled(save_vehicles, true);
                    guiSetEnabled(save_weather, true);
                    guiSetEnabled(save_shooting, true);
                    guiSetEnabled(save_handling, true);
                    guiSetEnabled(save_anticheat, true);
                end;
                return;
            elseif source == save_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(save_window);
                else
                    guiSetVisible(save_window, false);
                end;
                return;
            elseif source == config_delete then
                local serverDeleteConfigIndex = guiGridListGetSelectedItem(config_list);
                if serverDeleteConfigIndex == -1 then
                    return;
                else
                    local serverDeleteConfigName = guiGridListGetItemText(config_list, serverDeleteConfigIndex, 1);
                    if serverDeleteConfigName == "_default" then
                        return outputChatBox("Not available", 255, 0, 0);
                    else
                        callServerFunction("deleteConfig", serverDeleteConfigName, localPlayer);
                        return;
                    end;
                end;
            elseif source == config_list then
                local serverConfigListIndex = guiGridListGetSelectedItem(config_list);
                if serverConfigListIndex == -1 then
                    guiSetText(config_flags, "");
                    return;
                else
                    local serverConfigListItem = guiGridListGetItemText(config_list, serverConfigListIndex, 1);
                    local serverConfigFlags = guiGridListGetItemData(config_list, serverConfigListIndex, 1);
                    if isElement(save_window) then
                        guiSetText(save_name, serverConfigListItem);
                    end;
                    guiSetText(config_flags, serverConfigFlags);
                    return;
                end;
            elseif source == modes_list then
                local serverSelectedModeRow = guiGridListGetSelectedItem(modes_list);
                if serverSelectedModeRow == -1 then
                    return guiGridListClear(modes_rules);
                else
                    local serverSelectedModeType = guiGridListGetItemText(modes_list, serverSelectedModeRow, 1);
                    local serverModeRules = {};
                    if serverSelectedModeType == "settings" then
                        local serverSettingsIterator = pairs;
                        local serverSettingsData = getTacticsData("settings") or {};
                        for serverSettingKey, serverSettingValue in serverSettingsIterator(serverSettingsData) do
                            local serverSettingSeparator = string.find(tostring(serverSettingValue), "|");
                            if serverSettingSeparator then
                                table.insert(serverModeRules, {serverSettingKey, string.sub(serverSettingValue, 1, serverSettingSeparator - 1), serverSettingValue});
                            else
                                table.insert(serverModeRules, {serverSettingKey, serverSettingValue, serverSettingValue});
                            end;
                        end;
                    elseif serverSelectedModeType == "glitches" then
                        local serverGlichesIterator = pairs;
                        local serverGlichesData = getTacticsData("glitches") or {};
                        for serverGlitchKey, serverGlitchValue in serverGlichesIterator(serverGlichesData) do
                            local serverGlitchSeparator = string.find(tostring(serverGlitchValue), "|");
                            if serverGlitchSeparator then
                                table.insert(serverModeRules, {serverGlitchKey, string.sub(serverGlitchValue, 1, serverGlitchSeparator - 1), serverGlitchValue});
                            else
                                table.insert(serverModeRules, {serverGlitchKey, serverGlitchValue, serverGlitchValue});
                            end;
                        end;
                    elseif serverSelectedModeType == "cheats" then
                        local serverCheatsIterator = pairs;
                        local serverCheatsData = getTacticsData("cheats") or {};
                        for serverCheatKey, serverCheatValue in serverCheatsIterator(serverCheatsData) do
                            local serverCheatSeparator = string.find(tostring(serverCheatValue), "|");
                            if serverCheatSeparator then
                                table.insert(serverModeRules, {serverCheatKey, string.sub(serverCheatValue, 1, serverCheatSeparator - 1), serverCheatValue});
                            else
                                table.insert(serverModeRules, {serverCheatKey, serverCheatValue, serverCheatValue});
                            end;
                        end;
                    elseif serverSelectedModeType == "limites" then
                        local serverLimitsIterator = pairs;
                        local serverLimitsData = getTacticsData("limites") or {};
                        for serverLimitKey, serverLimitValue in serverLimitsIterator(serverLimitsData) do
                            local serverLimitSeparator = string.find(tostring(serverLimitValue), "|");
                            if serverLimitSeparator then
                                table.insert(serverModeRules, {serverLimitKey, string.sub(serverLimitValue, 1, serverLimitSeparator - 1), serverLimitValue});
                            else
                                table.insert(serverModeRules, {serverLimitKey, serverLimitValue, serverLimitValue});
                            end;
                        end;
                    else
                        local serverModesIterator = pairs;
                        local serverModeSpecificData = getTacticsData("modes", serverSelectedModeType) or {};
                        for serverModeDataKey, serverModeDataValue in serverModesIterator(serverModeSpecificData) do
                            if serverModeDataKey ~= "name" then
                                local serverModeDataSeparator = string.find(tostring(serverModeDataValue), "|");
                                if serverModeDataSeparator then
                                    table.insert(serverModeRules, {serverModeDataKey, string.sub(serverModeDataValue, 1, serverModeDataSeparator - 1), serverModeDataValue});
                                else
                                    table.insert(serverModeRules, {serverModeDataKey, serverModeDataValue, serverModeDataValue});
                                end;
                            end;
                        end;
                    end;
                    table.sort(serverModeRules, function(serverFirstRule, serverSecondRule) 
                        return serverFirstRule[1] < serverSecondRule[1];
                    end);
                    local serverRulesRowCount = guiGridListGetRowCount(modes_rules);
                    for serverRuleIndex = 0, math.max(serverRulesRowCount, #serverModeRules) do
                        if serverRuleIndex < #serverModeRules then
                            local serverRuleName = tostring(serverModeRules[serverRuleIndex + 1][1]);
                            local serverRuleValue = tostring(serverModeRules[serverRuleIndex + 1][2]);
                            local serverRuleFullValue = tostring(serverModeRules[serverRuleIndex + 1][3]);
                            if serverRuleIndex < serverRulesRowCount then
                                guiGridListSetItemText(modes_rules, serverRuleIndex, 1, serverRuleName, false, false);
                                guiGridListSetItemText(modes_rules, serverRuleIndex, 2, serverRuleValue, false, false);
                                guiGridListSetItemData(modes_rules, serverRuleIndex, 2, serverRuleFullValue);
                                if serverRuleValue == "true" then
                                    guiGridListSetItemColor(modes_rules, serverRuleIndex, 2, 0, 255, 0);
                                elseif serverRuleValue == "false" then
                                    guiGridListSetItemColor(modes_rules, serverRuleIndex, 2, 255, 0, 0);
                                elseif serverRuleValue ~= serverRuleFullValue then
                                    guiGridListSetItemColor(modes_rules, serverRuleIndex, 2, 255, 255, 0);
                                else
                                    guiGridListSetItemColor(modes_rules, serverRuleIndex, 2, 255, 255, 255);
                                end;
                            else
                                local serverRuleRowIndex = guiGridListAddRow(modes_rules);
                                guiGridListSetItemText(modes_rules, serverRuleRowIndex, 1, serverRuleName, false, false);
                                guiGridListSetItemText(modes_rules, serverRuleRowIndex, 2, serverRuleValue, false, false);
                                guiGridListSetItemData(modes_rules, serverRuleRowIndex, 2, serverRuleFullValue);
                                if serverRuleValue == "true" then
                                    guiGridListSetItemColor(modes_rules, serverRuleRowIndex, 2, 0, 255, 0);
                                elseif serverRuleValue == "false" then
                                    guiGridListSetItemColor(modes_rules, serverRuleRowIndex, 2, 255, 0, 0);
                                elseif serverRuleValue ~= serverRuleFullValue then
                                    guiGridListSetItemColor(modes_rules, serverRuleRowIndex, 2, 255, 255, 0);
                                else
                                    guiGridListSetItemColor(modes_rules, serverRuleRowIndex, 2, 255, 255, 255);
                                end;
                            end;
                        else
                            guiGridListRemoveRow(modes_rules, #serverModeRules, 1);
                        end;
                    end;
                    return;
                end;
            elseif source == rules_ok then
                local serverSelectedModeForRule = guiGridListGetSelectedItem(modes_list);
                local serverSelectedRuleIndex = guiGridListGetSelectedItem(modes_rules);
                local serverNewRuleValue = nil;
                if guiGetVisible(rules_edit) then
                    serverNewRuleValue = guiGetText(rules_edit);
                    if getDataType(serverNewRuleValue) ~= "string" then
                        serverNewRuleValue = nil;
                    end;
                elseif guiGetVisible(rules_list) then
                    local serverSelectedRuleListIndex = guiGridListGetSelectedItem(rules_list);
                    if serverSelectedRuleListIndex > -1 then
                        serverNewRuleValue = guiGridListGetItemText(rules_list, serverSelectedRuleListIndex, 1);
                    end;
                elseif guiGetVisible(rules_time) then
                    local serverTimeRuleText = guiGetText(rules_time);
                    local serverTimeHours = tonumber(gettok(serverTimeRuleText, 1, string.byte(":"))) or 0;
                    local serverTimeMinutes = tonumber(gettok(serverTimeRuleText, 2, string.byte(":"))) or 0;
                    local serverTimeSecondsPart = gettok(serverTimeRuleText, 3, string.byte(":")) or "0";
                    local serverTimeMilliseconds = tonumber(gettok(serverTimeSecondsPart, 2, string.byte("."))) or 0;
                    serverTimeSecondsPart = tonumber(gettok(serverTimeSecondsPart, 1, string.byte("."))) or 0;
                    serverNewRuleValue = string.format("%02i", serverTimeSecondsPart);
                    if serverTimeHours > 0 then
                        serverNewRuleValue = string.format("%i:%02i:", serverTimeHours, serverTimeMinutes) .. serverNewRuleValue;
                    else
                        serverNewRuleValue = string.format("%i:", serverTimeMinutes) .. serverNewRuleValue;
                    end;
                    if serverTimeMilliseconds > 0 then
                        serverNewRuleValue = serverNewRuleValue .. string.format(".%i", serverTimeMilliseconds);
                    end;
                end;
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rules_window);
                else
                    guiSetVisible(rules_window, false);
                end;
                if serverNewRuleValue ~= nil and isElement(admin_window) then
                    if serverSelectedModeForRule == -1 or serverSelectedRuleIndex == -1 then
                        return;
                    else
                        local serverRuleCategory = guiGridListGetItemText(modes_list, serverSelectedModeForRule, 1);
                        local serverRuleKey = guiGridListGetItemText(modes_rules, serverSelectedRuleIndex, 1);
                        if serverRuleCategory == "settings" then
                            setTacticsData(serverNewRuleValue, "settings", serverRuleKey, true);
                        elseif serverRuleCategory == "glitches" then
                            setTacticsData(serverNewRuleValue, "glitches", serverRuleKey, true);
                        elseif serverRuleCategory == "cheats" then
                            setTacticsData(serverNewRuleValue, "cheats", serverRuleKey, true);
                        elseif serverRuleCategory == "limites" then
                            setTacticsData(serverNewRuleValue, "limites", serverRuleKey, true);
                        else
                            setTacticsData(serverNewRuleValue, "modes", serverRuleCategory, serverRuleKey, true);
                        end;
                    end;
                end;
                return;
            elseif source == rules_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rules_window);
                else
                    guiSetVisible(rules_window, false);
                end;
                return;
            elseif source == modes_disable then
                local serverDisableModeIndex = guiGridListGetSelectedItem(modes_list);
                if serverDisableModeIndex == -1 then
                    return;
                else
                    local serverModeToDisable = guiGridListGetItemText(modes_list, serverDisableModeIndex, 1);
                    if getTacticsData("modes", serverModeToDisable, "enable") == "true" then
                        setTacticsData("false", "modes", serverModeToDisable, "enable", true);
                    elseif getTacticsData("modes", serverModeToDisable) then
                        setTacticsData("true", "modes", serverModeToDisable, "enable", true);
                    end;
                    return;
                end;
            elseif source == sky_topcolor or source == sky_bottomcolor or source == sun_colora or source == sun_colorb or source == water_color then
                if not isElement(palette_window) then
                    createAdminPalette();
                end;
                palette_element = source;
                local serverColorReadOnly = guiGetProperty(source, "ReadOnlyBGColour");
                local serverPaletteAlpha, serverPaletteRed, serverPaletteGreen, serverPaletteBlue = getColorFromString("#" .. string.sub(serverColorReadOnly, 1, -1));
                guiSetText(palette_rr, tostring(serverPaletteRed));
                guiSetText(palette_gg, tostring(serverPaletteGreen));
                guiSetText(palette_bb, tostring(serverPaletteBlue));
                guiSetText(palette_aa, tostring(serverPaletteAlpha));
                guiBringToFront(palette_window);
                guiSetVisible(palette_window, true);
                return;
            elseif source == sky_clouds then
                guiSetVisible(sky_clouds_img, guiCheckBoxGetSelected(sky_clouds));
                return;
            elseif source == sky_birds then
                guiSetVisible(sky_birds_img, guiCheckBoxGetSelected(sky_birds));
                return;
            elseif source == weather_load then
                local serverSelectedWeatherIndex = guiComboBoxGetSelected(weather_default);
                if not weatherSAData[serverSelectedWeatherIndex + 1] then
                    return;
                else
                    local serverCurrentWeatherData = getTacticsData("Weather") or {};
                    local serverSpecialWeatherEffects = {
                        [0] = true, 
                        [9] = true,
                        [8] = true, 
                        [10] = true, 
                        [19] = true
                    };
                    local serverNewWeatherData = {};
                    for serverWeatherHourKey, serverWeatherHourData in pairs(weatherSAData[serverSelectedWeatherIndex + 1].hours) do
                        local serverWindX = 0;
                        local serverWindY = 0;
                        local serverWindZ = 0;
                        if serverCurrentWeatherData[serverWeatherHourKey] then
                            local serverExistingWindX, serverExistingWindY, serverExistingWindZ = unpack(serverCurrentWeatherData[serverWeatherHourKey].wind);
                            serverWindZ = serverExistingWindZ;
                            serverWindY = serverExistingWindY;
                            serverWindX = serverExistingWindX;
                        end;
                        local serverSkyTopRed, serverSkyTopGreen, serverSkyTopBlue, serverSkyBottomRed, serverSkyBottomGreen, serverSkyBottomBlue = unpack(serverWeatherHourData.sky);
                        local serverSunCoreRed, serverSunCoreGreen, serverSunCoreBlue, serverSunShineRed, serverSunShineGreen, serverSunShineBlue, serverSunSizeValue = unpack(serverWeatherHourData.sun);
                        local serverWaterRed, serverWaterGreen, serverWaterBlue, serverWaterAlpha = unpack(serverWeatherHourData.water);
                        serverNewWeatherData[serverWeatherHourKey] = {
                            wind = {not serverWindX and 0 or serverWindX, 
                                not serverWindY and 0 or serverWindY, 
                                not serverWindZ and 0 or serverWindZ}, 
                            rain = tonumber(serverWeatherHourData.rain or 0), 
                            far = tonumber(serverWeatherHourData.far), 
                            fog = tonumber(serverWeatherHourData.fog), 
                            sky = {serverSkyTopRed, serverSkyTopGreen, serverSkyTopBlue, serverSkyBottomRed, serverSkyBottomGreen, serverSkyBottomBlue}, 
                            clouds = true, birds = true, 
                            sun = {serverSunCoreRed, serverSunCoreGreen, serverSunCoreBlue, serverSunShineRed, serverSunShineGreen, serverSunShineBlue}, 
                            sunsize = tonumber(serverSunSizeValue), 
                            water = {serverWaterRed, serverWaterGreen, serverWaterBlue, serverWaterAlpha}, 
                            level = 0, wave = 0, heat = 0, 
                            effect = serverSpecialWeatherEffects[serverSelectedWeatherIndex] and serverSelectedWeatherIndex or 0
                        };
                    end;
                    setTacticsData(serverNewWeatherData, "Weather");
                    return;
                end;
            elseif source == weather_loadhour then
                local serverLoadHourWeatherIndex = guiComboBoxGetSelected(weather_default);
                if not weatherSAData[serverLoadHourWeatherIndex + 1] then
                    return;
                else
                    local __, serverSelectedWeatherColumnIndex = guiGridListGetSelectedItem(weather_record);
                    if serverSelectedWeatherColumnIndex < 1 then
                        return;
                    else
                        local serverSelectedWeatherHour = tonumber(guiGridListGetItemData(weather_record, 1, serverSelectedWeatherColumnIndex));
                        if not serverSelectedWeatherHour then
                            return;
                        elseif not weatherSAData[serverLoadHourWeatherIndex + 1].hours[serverSelectedWeatherHour] then
                            return;
                        else
                            local serverWeatherDataForHour = getTacticsData("Weather") or {};
                            local serverHourSpecialEffects = {
                                [0] = true, 
                                [10] = true, 
                                [8] = true, 
                                [19] = true, 
                                [9] = true
                            };
                            local __ = {};
                            local serverSourceWeatherData = weatherSAData[serverLoadHourWeatherIndex + 1].hours[serverSelectedWeatherHour];
                            local serverExistingHourWindX, serverExistingHourWindY, serverExistingHourWindZ = unpack(serverWeatherDataForHour[serverSelectedWeatherHour].wind);
                            local serverHourSkyTopRed, serverHourSkyTopGreen, serverHourSkyTopBlue, serverHourSkyBottomRed, serverHourSkyBottomGreen, serverHourSkyBottomBlue = unpack(serverSourceWeatherData.sky);
                            local serverHourSunCoreRed, serverHourSunCoreGreen, serverHourSunCoreBlue, serverHourSunShineRed, serverHourSunShineGreen, serverHourSunShineBlue, serverHourSunSize = unpack(serverSourceWeatherData.sun);
                            local serverHourWaterRed, serverHourWaterGreen, serverHourWaterBlue, serverHourWaterAlpha = unpack(serverSourceWeatherData.water);
                            serverWeatherDataForHour[serverSelectedWeatherHour] = {
                                wind = {
                                    serverExistingHourWindX or 0, 
                                    serverExistingHourWindY or 0, 
                                    serverExistingHourWindZ or 0
                                }, 
                                rain = tonumber(serverSourceWeatherData.rain or 0), 
                                far = tonumber(serverSourceWeatherData.far), 
                                fog = tonumber(serverSourceWeatherData.fog), 
                                sky = {
                                    serverHourSkyTopRed, 
                                    serverHourSkyTopGreen, 
                                    serverHourSkyTopBlue, 
                                    serverHourSkyBottomRed, 
                                    serverHourSkyBottomGreen, 
                                    serverHourSkyBottomBlue
                                }, 
                                clouds = true, 
                                birds = true, 
                                sun = {
                                    serverHourSunCoreRed, 
                                    serverHourSunCoreGreen, 
                                    serverHourSunCoreBlue, 
                                    serverHourSunShineRed, 
                                    serverHourSunShineGreen, 
                                    serverHourSunShineBlue
                                }, 
                                sunsize = tonumber(serverHourSunSize), 
                                water = {
                                    serverHourWaterRed, 
                                    serverHourWaterGreen, 
                                    serverHourWaterBlue, 
                                    serverHourWaterAlpha
                                }, 
                                level = 0, 
                                wave = 0, 
                                heat = 0, 
                                effect = serverHourSpecialEffects[serverLoadHourWeatherIndex] and serverLoadHourWeatherIndex or 0
                            };
                            setTacticsData(serverWeatherDataForHour, "Weather");
                            return;
                        end;
                    end;
                end;
            elseif source == weather_insert then
                local serverInsertHour = tonumber(guiGetText(weather_hour));
                if not serverInsertHour then
                    return;
                else
                    local serverWeatherDataInsert = getTacticsData("Weather") or {};
                    if serverWeatherDataInsert[serverInsertHour] then
                        return;
                    else
                        local serverInsertSpecialEffects = {
                            [0] = true, 
                            [10] = true, 
                            [8] = true, 
                            [19] = true, 
                            [9] = true
                        };
                        serverWeatherDataInsert[serverInsertHour] = {
                            wind = {
                                getWindVelocity()
                            }, 
                            rain = getRainLevel(), 
                            far = getFarClipDistance(), 
                            fog = getFogDistance(), 
                            sky = {
                                getSkyGradient()
                            }, 
                            clouds = getCloudsEnabled(), 
                            birds = getBirdsEnabled(), 
                            sun = {
                                getSunColor()
                            }, 
                            sunsize = getSunSize(), 
                            water = {
                                getWaterColor()
                            }, 
                            wave = getWaveHeight(), 
                            level = getWaterLevel(3000, 3000, 0), 
                            heat = ({
                                getHeatHaze()
                            })[1] or 0, 
                            effect = serverInsertSpecialEffects[getWeather()] and getWeather() or 0
                        };
                        setTacticsData(serverWeatherDataInsert, "Weather");
                        return;
                    end;
                end;
            elseif source == weather_delete then
                local __, serverDeleteColumnIndex = guiGridListGetSelectedItem(weather_record);
                if serverDeleteColumnIndex < 1 then
                    return;
                else
                    local serverHourToDelete = tonumber(guiGridListGetItemData(weather_record, 1, serverDeleteColumnIndex));
                    if not serverHourToDelete then
                        return;
                    else
                        local serverUpdatedWeatherData = getTacticsData("Weather") or {};
                        serverUpdatedWeatherData[serverHourToDelete] = nil;
                        setTacticsData(serverUpdatedWeatherData, "Weather");
                        return;
                    end;
                end;
            elseif source == weather_save then
                local __, serverSaveColumnIndex = guiGridListGetSelectedItem(weather_record);
                if serverSaveColumnIndex < 1 then
                    return;
                else
                    local serverHourToSave = tonumber(guiGridListGetItemData(weather_record, 1, serverSaveColumnIndex));
                    if not serverHourToSave then
                        return;
                    else
                        local serverWeatherDataToSave = getTacticsData("Weather") or {};
                        local serverWindAngleRadians = math.rad(tonumber(guiGetText(wind_vector))) or 0;
                        local serverWindSpeedMeters = tonumber(guiGetText(wind_speed)) * 3.6 / 200 or 0;
                        local serverWindVelocityX = -serverWindSpeedMeters * math.sin(serverWindAngleRadians);
                        local serverWindVelocityY = serverWindSpeedMeters * math.cos(serverWindAngleRadians);
                        local serverWindVelocityZ = 0;
                        local serverSavedSkyTopRed, serverSavedSkyTopGreen, serverSavedSkyTopBlue = getColorFromString("#" .. string.sub(guiGetProperty(sky_topcolor, "ReadOnlyBGColour"), 3, -1));
                        local serverSavedSkyBottomRed, serverSavedSkyBottomGreen, serverSavedSkyBottomBlue = getColorFromString("#" .. string.sub(guiGetProperty(sky_bottomcolor, "ReadOnlyBGColour"), 3, -1));
                        local serverSavedSunCoreRed, serverSavedSunCoreGreen, serverSavedSunCoreBlue = getColorFromString("#" .. string.sub(guiGetProperty(sun_colora, "ReadOnlyBGColour"), 3, -1));
                        local serverSavedSunShineRed, serverSavedSunShineGreen, serverSavedSunShineBlue = getColorFromString("#" .. string.sub(guiGetProperty(sun_colorb, "ReadOnlyBGColour"), 3, -1));
                        local serverSavedWaterAlpha, serverSavedWaterRed, serverSavedWaterGreen, serverSavedWaterBlue = getColorFromString("#" .. string.sub(guiGetProperty(water_color, "ReadOnlyBGColour"), 1, -1));
                        local serverWeatherEffectMapping = {
                            Clear = 0, 
                            Cloudy = 10, 
                            Thunder = 8, 
                            Storm = 19, 
                            Fog = 9
                        };
                        serverWeatherDataToSave[serverHourToSave] = {
                            wind = {
                                serverWindVelocityX, 
                                serverWindVelocityY, 
                                serverWindVelocityZ
                            }, 
                            rain = tonumber(guiGetText(rain_level)), 
                            far = tonumber(guiGetText(farclip_distance)), 
                            fog = tonumber(guiGetText(fog_distance)), 
                            sky = {
                                serverSavedSkyTopRed, 
                                serverSavedSkyTopGreen, 
                                serverSavedSkyTopBlue, 
                                serverSavedSkyBottomRed, 
                                serverSavedSkyBottomGreen, 
                                serverSavedSkyBottomBlue
                            }, 
                            clouds = guiCheckBoxGetSelected(sky_clouds), 
                            birds = guiCheckBoxGetSelected(sky_birds), 
                            sun = {
                                serverSavedSunCoreRed, 
                                serverSavedSunCoreGreen, 
                                serverSavedSunCoreBlue, 
                                serverSavedSunShineRed, 
                                serverSavedSunShineGreen, 
                                serverSavedSunShineBlue
                            }, 
                            sunsize = tonumber(guiGetText(sun_size)), 
                            water = {
                                serverSavedWaterRed, 
                                serverSavedWaterGreen, 
                                serverSavedWaterBlue, 
                                serverSavedWaterAlpha
                            }, 
                            level = tonumber(guiGetText(water_level)), 
                            wave = tonumber(guiGetText(wave_height)), 
                            heat = tonumber(guiGetText(heat_level)), 
                            effect = serverWeatherEffectMapping[guiGetText(weather_effect)] or tonumber(guiGetText(weather_effect))
                        };
                        setTacticsData(serverWeatherDataToSave, "Weather");
                        return;
                    end;
                end;
            elseif source == shooting_ok then
                local serverShootingWeaponID = getWeaponIDFromName(guiGetText(shooting_weapon));
                local serverWeaponRange = guiGetText(shooting_weapon_range);
                local serverTargetRange = guiGetText(shooting_target_range);
                local serverAccuracyValue = guiGetText(shooting_accuracy);
                local serverDamageValue = guiGetText(shooting_damage);
                local serverMaximumClip = guiGetText(shooting_maximum_clip);
                local serverMoveSpeed = guiGetText(shooting_move_speed);
                local serverAnimLoopStart = guiGetText(shooting_anim_loop_start);
                local serverAnimLoopStop = guiGetText(shooting_anim_loop_stop);
                local serverAnimBulletFire = guiGetText(shooting_anim_loop_bullet_fire);
                local serverAnim2LoopStart = guiGetText(shooting_anim2_loop_start);
                local serverAnim2LoopStop = guiGetText(shooting_anim2_loop_stop);
                local serverAnim2BulletFire = guiGetText(shooting_anim2_loop_bullet_fire);
                local serverAnimBreakoutTime = guiGetText(shooting_anim_breakout_time);
                local serverWeaponFlags = {
                    {}, 
                    {}, 
                    {}, 
                    {}, 
                    {}
                };
                for serverFlagCategory = 1, 4 do
                    serverWeaponFlags[serverFlagCategory][1] = guiCheckBoxGetSelected(shooting_flags[serverFlagCategory][1]);
                    serverWeaponFlags[serverFlagCategory][2] = guiCheckBoxGetSelected(shooting_flags[serverFlagCategory][2]);
                    serverWeaponFlags[serverFlagCategory][4] = guiCheckBoxGetSelected(shooting_flags[serverFlagCategory][4]);
                    serverWeaponFlags[serverFlagCategory][8] = guiCheckBoxGetSelected(shooting_flags[serverFlagCategory][8]);
                end;
                callServerFunction("changeWeaponProperty", localPlayer, serverShootingWeaponID, serverWeaponRange, serverTargetRange, serverAccuracyValue, serverDamageValue, serverMaximumClip, serverMoveSpeed, serverAnimLoopStart, serverAnimLoopStop, serverAnimBulletFire, serverAnim2LoopStart, serverAnim2LoopStop, serverAnim2BulletFire, serverAnimBreakoutTime, serverWeaponFlags);
                return;
            elseif source == shooting_reset then
                local serverResetWeaponID = getWeaponIDFromName(guiGetText(shooting_weapon));
                callServerFunction("resetWeaponProperty", localPlayer, serverResetWeaponID);
                return;
            elseif source == handling_ok then
                local serverHandlingData = {};
                local serverVehicleModelForHandling = getVehicleModelFromName(guiGetText(handling_model));
                serverHandlingData.mass = tonumber(guiGetText(handling_mass));
                serverHandlingData.turnMass = tonumber(guiGetText(handling_turnmass));
                serverHandlingData.dragCoeff = tonumber(guiGetText(handling_dragcoeff));
                serverHandlingData.centerOfMass = {
                    tonumber(guiGetText(handling_centerofmass_x)), 
                    tonumber(guiGetText(handling_centerofmass_y)), 
                    tonumber(guiGetText(handling_centerofmass_z))
                };
                serverHandlingData.percentSubmerged = tonumber(guiGetText(handling_percentsubmerged));
                serverHandlingData.tractionMultiplier = tonumber(guiGetText(handling_tractionmultiplier));
                serverHandlingData.tractionLoss = tonumber(guiGetText(handling_tractionloss));
                serverHandlingData.tractionBias = tonumber(guiGetText(handling_tractionbias));
                serverHandlingData.numberOfGears = tonumber(guiGetText(handling_numberofgears));
                serverHandlingData.maxVelocity = tonumber(guiGetText(handling_maxvelocity));
                serverHandlingData.engineAcceleration = tonumber(guiGetText(handling_engineacceleration));
                serverHandlingData.engineInertia = tonumber(guiGetText(handling_engineinertia));
                serverHandlingData.driveType = ({
                    ["4x4"] = "awd", 
                    Front = "fwd", 
                    Rear = "rwd"
                })[guiGetText(handling_drivetype)];
                serverHandlingData.engineType = ({
                    Petrol = "petrol", 
                    Diesel = "diesel", 
                    Electric = "electric"
                })[guiGetText(handling_enginetype)];
                serverHandlingData.brakeDeceleration = tonumber(guiGetText(handling_brakedeceleration));
                serverHandlingData.brakeBias = tonumber(guiGetText(handling_brakebias));
                serverHandlingData.ABS = guiGetText(handling_abs) == "Enable";
                serverHandlingData.steeringLock = tonumber(guiGetText(handling_steeringlock));
                serverHandlingData.suspensionForceLevel = tonumber(guiGetText(handling_suspensionforcelevel));
                serverHandlingData.suspensionDamping = tonumber(guiGetText(handling_suspensiondamping));
                serverHandlingData.suspensionHighSpeedDamping = tonumber(guiGetText(handling_suspensionhighspeeddamping));
                serverHandlingData.suspensionUpperLimit = tonumber(guiGetText(handling_suspensionupperlimit));
                serverHandlingData.suspensionLowerLimit = tonumber(guiGetText(handling_suspensionlowerlimit));
                serverHandlingData.suspensionFrontRearBias = tonumber(guiGetText(handling_suspensionfrontrearbias));
                serverHandlingData.suspensionAntiDiveMultiplier = tonumber(guiGetText(handling_suspensionantidivemultiplier));
                serverHandlingData.seatOffsetDistance = tonumber(guiGetText(handling_seatoffsetdistance));
                serverHandlingData.collisionDamageMultiplier = tonumber(guiGetText(handling_collisiondamagemultiplier));
                local serverModelFlagsHex = "";
                for serverModelFlagByte = 1, 8 do
                    local serverModelFlagValue = 0;
                    if guiCheckBoxGetSelected(handling_modelflags[serverModelFlagByte][8]) then
                        serverModelFlagValue = serverModelFlagValue + 8;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[serverModelFlagByte][4]) then
                        serverModelFlagValue = serverModelFlagValue + 4;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[serverModelFlagByte][2]) then
                        serverModelFlagValue = serverModelFlagValue + 2;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[serverModelFlagByte][1]) then
                        serverModelFlagValue = serverModelFlagValue + 1;
                    end;
                    serverModelFlagsHex = string.format("%01X", serverModelFlagValue) .. serverModelFlagsHex;
                end;
                serverHandlingData.modelFlags = "0x" .. serverModelFlagsHex;
                local serverHandlingFlagsHex = "";
                for serverHandlingFlagByte = 1, 8 do
                    local serverHandlingFlagValue = 0;
                    if guiCheckBoxGetSelected(handling_handlingflags[serverHandlingFlagByte][8]) then
                        serverHandlingFlagValue = serverHandlingFlagValue + 8;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[serverHandlingFlagByte][4]) then
                        serverHandlingFlagValue = serverHandlingFlagValue + 4;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[serverHandlingFlagByte][2]) then
                        serverHandlingFlagValue = serverHandlingFlagValue + 2;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[serverHandlingFlagByte][1]) then
                        serverHandlingFlagValue = serverHandlingFlagValue + 1;
                    end;
                    serverHandlingFlagsHex = string.format("%01X", serverHandlingFlagValue) .. serverHandlingFlagsHex;
                end;
                serverHandlingData.handlingFlags = "0x" .. serverHandlingFlagsHex;
                serverHandlingData.sirens = {};
                serverHandlingData.sirens.count = tonumber(guiGetText(sirens_count)) or 0;
                serverHandlingData.sirens.type = ({
                    Invisible = 1, 
                    Single = 2, 
                    Dual = 3, 
                    Triple = 4, 
                    Quadruple = 5, 
                    Quinary = 6
                })[guiGetText(sirens_type)];
                serverHandlingData.sirens.flags = {
                    ["360"] = guiCheckBoxGetSelected(sirens_360), 
                    DoLOSCheck = guiCheckBoxGetSelected(sirens_LOS), 
                    UseRandomiser = guiCheckBoxGetSelected(sirens_randomiser), 
                    Silent = guiCheckBoxGetSelected(sirens_silent)
                };
                for serverSirenIndex = 1, 8 do
                    serverHandlingData.sirens[serverSirenIndex] = {
                        x = guiGetText(sirens_xcenter[serverSirenIndex]), 
                        y = guiGetText(sirens_ycenter[serverSirenIndex]), 
                        z = guiGetText(sirens_zcenter[serverSirenIndex]), 
                        color = guiGetProperty(sirens_color[serverSirenIndex], "ReadOnlyBGColour"), 
                        minalpha = guiGetText(sirens_minalpha[serverSirenIndex])
                    };
                end;
                callServerFunction("changeVehicleHandling", localPlayer, serverVehicleModelForHandling, serverHandlingData);
                return;
            elseif source == handling_reset then
                local serverResetVehicleModel = getVehicleModelFromName(guiGetText(handling_model));
                callServerFunction("resetVehicleHandling", localPlayer, serverResetVehicleModel);
                return;
            elseif source == window_expert then
                if guiCheckBoxGetSelected(window_expert) then
                    guiSetVisible(admin_tab_anticheat, true);
                    guiSetVisible(admin_tab_shooting, true);
                    guiSetVisible(admin_tab_handling, true);
                    guiSetEnabled(maps_refresh, true);
                    if isElement(save_window) then
                        guiSetVisible(save_shooting, true);
                        guiSetVisible(save_handling, true);
                        guiSetVisible(save_anticheat, true);
                    end;
                else
                    guiSetVisible(admin_tab_anticheat, false);
                    guiSetVisible(admin_tab_shooting, false);
                    guiSetVisible(admin_tab_handling, false);
                    guiSetEnabled(maps_refresh, false);
                    if isElement(save_window) then
                        guiSetVisible(save_shooting, false);
                        guiSetVisible(save_handling, false);
                        guiSetVisible(save_anticheat, false);
                    end;
                    local serverSelectedTab = guiGetSelectedTab(admin_tabs);
                    if serverSelectedTab == admin_tab_shooting or serverSelectedTab == admin_tab_handling or serverSelectedTab == admin_tab_anticheat then
                        guiSetSelectedTab(admin_tabs, admin_tab_players);
                    end;
                end;
                return;
            elseif source == anticheat_modsadd then
                if not isElement(mods_window) then
                    createAdminMods();
                end;
                guiSetText(mods_name, "");
                guiSetText(mods_edit, "");
                guiSetText(mods_ok, "Add");
                guiRadioButtonSetSelected(mods_type_name, true);
                guiBringToFront(mods_window);
                guiSetVisible(mods_window, true);
                return;
            elseif source == mods_ok then
                if guiGetText(mods_ok) == "Add" then
                    local serverModName = guiGetText(mods_name);
                    local serverModSearch = guiGetText(mods_edit);
                    if #serverModName == 0 or #serverModSearch == 0 then
                        return;
                    else
                        local serverModType = guiRadioButtonGetSelected(mods_type_name) and "name" or "hash";
                        callServerFunction("addAnticheatModsearch", serverModName, serverModSearch, serverModType);
                        if guiCheckBoxGetSelected(config_performance_adminpanel) then
                            destroyElement(mods_window);
                        else
                            guiSetVisible(mods_window, false);
                        end;
                    end;
                elseif guiGetText(mods_ok) == "Set" then
                    local serverSelectedModIndex = guiGridListGetSelectedItem(anticheat_modslist);
                    if serverSelectedModIndex == -1 then
                        return;
                    else
                        local serverEditModName = guiGetText(mods_name);
                        local serverEditModSearch = guiGetText(mods_edit);
                        if #serverEditModName == 0 or #serverEditModSearch == 0 then
                            return;
                        else
                            local serverEditModType = guiRadioButtonGetSelected(mods_type_name) and "name" or "hash";
                            callServerFunction("setAnticheatModsearch", serverSelectedModIndex, serverEditModName, serverEditModSearch, serverEditModType);
                            if guiCheckBoxGetSelected(config_performance_adminpanel) then
                                destroyElement(mods_window);
                            else
                                guiSetVisible(mods_window, false);
                            end;
                        end;
                    end;
                end;
                return;
            elseif source == mods_cancel then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(mods_window);
                else
                    guiSetVisible(mods_window, false);
                end;
                return;
            elseif source == anticheat_modsdel then
                local serverDeleteModIndex = guiGridListGetSelectedItem(anticheat_modslist);
                if serverDeleteModIndex == -1 then
                    return;
                else
                    callServerFunction("removeAnticheatModsearch", serverDeleteModIndex);
                    return;
                end;
            elseif source == player_infocopy then
                setClipboard(guiGetText(player_info));
                return;
            elseif source == player_takescreen then
                if not serverSelectedPlayers or #serverSelectedPlayers > 1 then
                    return;
                else
                    callServerFunction("takePlayerScreenShot", serverSelectedPlayers[1], 320, 240, getPlayerName(localPlayer) .. " 320 240 " .. getPlayerName(serverSelectedPlayers[1]), 30, 5000);
                    guiSetEnabled(player_takescreen, false);
                    guiSetEnabled(player_takescreencombobox, false);
                    screenTimeout = setTimer(function() 
                        guiSetEnabled(player_takescreen, true);
                        guiSetEnabled(player_takescreencombobox, true);
                    end, 30000, 1);
                    return;
                end;
            elseif source == screen_save then
                local serverScreenshotName = guiGetText(screen_name);
                local serverScreenshotExists = fileExists("screenshots/" .. serverScreenshotName .. ".jpg");
                if serverScreenshotExists then
                    fileDelete("screenshots/" .. serverScreenshotName .. ".jpg");
                end;
                local serverSourceScreenshotFile = fileOpen("screenshots/_screen.jpg");
                local serverDestScreenshotFile = fileCreate("screenshots/" .. serverScreenshotName .. ".jpg");
                while not fileIsEOF(serverSourceScreenshotFile) do
                    fileWrite(serverDestScreenshotFile, fileRead(serverSourceScreenshotFile, 500));
                end;
                fileClose(serverSourceScreenshotFile);
                fileClose(serverDestScreenshotFile);
                if not serverScreenshotExists then
                    local serverScreenshotsXML = xmlLoadFile("screenshots/_list.xml") or xmlCreateFile("screenshots/_list.xml", "screenshots");
                    local serverScreenshotXMLNode = xmlCreateChild(serverScreenshotsXML, "screenshot");
                    xmlNodeSetAttribute(serverScreenshotXMLNode, "src", serverScreenshotName);
                    xmlSaveFile(serverScreenshotsXML);
                    xmlUnloadFile(serverScreenshotsXML);
                    guiComboBoxAddItem(screen_list, serverScreenshotName);
                end;
                guiSetVisible(screen_name, false);
                guiSetVisible(screen_save, false);
                guiSetText(screen_list, serverScreenshotName);
                guiSetVisible(screen_list, true);
                return;
            elseif source == screen_close then
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(screen_window);
                else
                    guiSetVisible(screen_window, false);
                end;
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                return;
            elseif source == shooting_general then
                guiSetProperty(shooting_general, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(shooting_animation, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(shooting_flag, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(shooting_generalpane, true);
                guiSetVisible(shooting_animationpane, false);
                guiSetVisible(shooting_flagpane, false);
                return;
            elseif source == shooting_animation then
                guiSetProperty(shooting_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(shooting_animation, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(shooting_flag, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(shooting_generalpane, false);
                guiSetVisible(shooting_animationpane, true);
                guiSetVisible(shooting_flagpane, false);
                return;
            elseif source == shooting_flag then
                guiSetProperty(shooting_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(shooting_animation, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(shooting_flag, "NormalTextColour", "FFFFFFFF");
                guiSetVisible(shooting_generalpane, false);
                guiSetVisible(shooting_animationpane, false);
                guiSetVisible(shooting_flagpane, true);
                return;
            elseif source == handling_general then
                guiSetProperty(handling_general, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, true);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_engine then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, true);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_wheels then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, true);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_suspension then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, true);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_modelflag then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, true);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_handlingflag then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(handling_sirens, "NormalTextColour", "FF7C7C7C");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, true);
                guiSetVisible(handling_sirenspane, false);
                return;
            elseif source == handling_sirens then
                guiSetProperty(handling_general, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_engine, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_wheels, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_suspension, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_modelflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_handlingflag, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(handling_sirens, "NormalTextColour", "FFFFFFFF");
                guiSetVisible(handling_generalpane, false);
                guiSetVisible(handling_enginepane, false);
                guiSetVisible(handling_wheelspane, false);
                guiSetVisible(handling_suspensionpane, false);
                guiSetVisible(handling_modelflagpane, false);
                guiSetVisible(handling_handlingflagpane, false);
                guiSetVisible(handling_sirenspane, true);
                return;
            else
                if isElement(admin_window) and guiGetVisible(admin_tab_handling) and guiGetVisible(handling_sirenspane) then
                    for __, serverSirenColorElement in ipairs(sirens_color) do
                        if source == serverSirenColorElement then
                            if not isElement(palette_window) then
                                createAdminPalette();
                            end;
                            palette_element = source;
                            local serverSirenColorString = guiGetProperty(source, "ReadOnlyBGColour");
                            local serverSirenColorRed, serverSirenColorGreen, serverSirenColorBlue = getColorFromString("#" .. string.sub(serverSirenColorString, 3, -1));
                            guiSetText(palette_rr, tostring(serverSirenColorRed));
                            guiSetText(palette_gg, tostring(serverSirenColorGreen));
                            guiSetText(palette_bb, tostring(serverSirenColorBlue));
                            guiBringToFront(palette_window);
                            guiSetVisible(palette_window, true);
                            return;
                        end;
                    end;
                end;
                if isElement(admin_window) and guiGetVisible(admin_tab_weapons) then
                    if source == weapons_adding then
                        local serverWeaponsPackData = getTacticsData("weaponspack") or {};
                        local serverWeaponBalanceData = getTacticsData("weapon_balance") or {};
                        local serverWeaponCostData = getTacticsData("weapon_cost") or {};
                        local serverWeaponSlotData = getTacticsData("weapon_slot") or {};
                        for __, serverAvailableWeapon in ipairs(sortWeaponNames) do
                            if not serverWeaponsPackData[serverAvailableWeapon] then
                                guiSetText(weapons_addname, serverAvailableWeapon);
                                local serverWeaponID = convertWeaponNamesToID[serverAvailableWeapon];
                                local serverDefaultAmmo = serverWeaponID >= 22 and serverWeaponID <= 39 and tonumber(getWeaponProperty(serverWeaponID, "pro", "maximum_clip_ammo")) or 1;
                                guiSetText(weapons_addammo, tostring(serverDefaultAmmo));
                                guiSetText(weapons_addlimit, serverWeaponBalanceData[serverAvailableWeapon] or "");
                                guiSetText(weapons_addcost, serverWeaponCostData[serverAvailableWeapon] or "$");
                                guiSetText(weapons_addslot, serverWeaponSlotData[serverAvailableWeapon] or serverWeaponID and tostring(getSlotFromWeapon(serverWeaponID)) or "13");
                                break;
                            end;
                        end;
                        return;
                    elseif source == weapons_save then
                        local serverSelectedWeaponName = guiGetText(weapons_addname);
                        local serverSelectedWeaponID = convertWeaponNamesToID[serverSelectedWeaponName];
                        local serverAmmoValue = guiGetText(weapons_addammo);
                        if #serverSelectedWeaponName == 0 or #serverAmmoValue == 0 or not tonumber(serverAmmoValue) then
                            return;
                        else
                            local serverLimitValue = guiGetText(weapons_addlimit);
                            local serverCostValue = guiGetText(weapons_addcost):gsub("%$", "");
                            local serverSlotValue = guiGetText(weapons_addslot);
                            setTacticsData(tostring(serverAmmoValue), "weaponspack", tostring(serverSelectedWeaponName));
                            if #serverLimitValue > 0 and tonumber(serverLimitValue) then
                                setTacticsData(tostring(serverLimitValue), "weapon_balance", tostring(serverSelectedWeaponName));
                            else
                                setTacticsData(nil, "weapon_balance", tostring(serverSelectedWeaponName));
                            end;
                            if #serverCostValue > 0 and tonumber(serverCostValue) then
                                setTacticsData(tostring(serverCostValue), "weapon_cost", tostring(serverSelectedWeaponName));
                            else
                                setTacticsData(nil, "weapon_cost", tostring(serverSelectedWeaponName));
                            end;
                            if #serverSlotValue > 0 and tonumber(serverSlotValue) and (serverSelectedWeaponID and tonumber(serverSlotValue) ~= getSlotFromWeapon(serverSelectedWeaponID) or tonumber(serverSlotValue) ~= 13) then
                                setTacticsData(tostring(serverSlotValue), "weapon_slot", tostring(serverSelectedWeaponName));
                            else
                                setTacticsData(nil, "weapon_slot", tostring(serverSelectedWeaponName));
                            end;
                            return;
                        end;
                    elseif source == weapons_remove then
                        local serverRemoveWeaponName = guiGetText(weapons_addname);
                        if #serverRemoveWeaponName == 0 then
                            return;
                        else
                            setTacticsData(nil, "weaponspack", tostring(serverRemoveWeaponName));
                            return;
                        end;
                    elseif source == weapons_apply then
                        local serverSlotCount = guiGetText(weapons_slots);
                        if #serverSlotCount == 0 or not tonumber(serverSlotCount) then
                            return;
                        else
                            setTacticsData(tonumber(serverSlotCount), "weapon_slots");
                            return;
                        end;
                    else
                        for __, serverWeaponItem in ipairs(weapons_items) do
                            if source == serverWeaponItem.gui then
                                local serverItemWeaponName = guiGetText(serverWeaponItem.name);
                                local serverTotalAmmo = 0;
                                for __, serverAmmoPart in ipairs(split(guiGetText(serverWeaponItem.ammo), string.byte("-"))) do
                                    serverTotalAmmo = serverTotalAmmo + tonumber(serverAmmoPart);
                                end;
                                serverTotalAmmo = tostring(math.max(serverTotalAmmo, 1));
                                local serverItemLimit = guiGetText(serverWeaponItem.limit);
                                if #serverItemLimit > 1 then
                                    serverItemLimit = string.sub(serverItemLimit, 2);
                                end;
                                guiSetText(weapons_addname, serverItemWeaponName);
                                guiSetText(weapons_addammo, serverTotalAmmo);
                                guiSetText(weapons_addlimit, serverItemLimit);
                                local serverItemWeaponID = convertWeaponNamesToID[serverItemWeaponName];
                                local serverWeaponCosts = getTacticsData("weapon_cost") or {};
                                local serverWeaponSlots = getTacticsData("weapon_slot") or {};
                                guiSetText(weapons_addcost, serverWeaponCosts[serverItemWeaponName] or "");
                                guiSetText(weapons_addslot, serverWeaponSlots[serverItemWeaponName] or serverItemWeaponID and tostring(getSlotFromWeapon(serverItemWeaponID)) or "13");
                                return;
                            end;
                        end;
                    end;
                end;
                return;
            end;
        end;
    end;
    onClientGUIChanged = function(__) 
        if source == rules_time then
            local serverCleanedTimeText = guiGetText(rules_time):gsub("[^0-9:.]+", "");
            local serverTimeWithoutMilliseconds = gettok(serverCleanedTimeText, 1, string.byte("."));
            local serverTimeHours = tonumber(gettok(serverTimeWithoutMilliseconds, 1, string.byte(":"))) or 0;
            local serverTimeMinutes = tonumber(gettok(serverTimeWithoutMilliseconds, 2, string.byte(":"))) or 0;
            local serverTimeSeconds = tonumber(gettok(serverTimeWithoutMilliseconds, 3, string.byte(":"))) or 0;
            local serverTimeMilliseconds = tonumber(gettok(serverCleanedTimeText, 2, string.byte("."))) or 0;
            if serverTimeHours >= 0 and serverTimeHours < 24 and serverTimeMinutes >= 0 and serverTimeMinutes < 60 and serverTimeSeconds >= 0 and serverTimeSeconds < 60 and serverTimeMilliseconds >= 0 and serverTimeMilliseconds < 10 then
                return;
            else
                local serverAdjustedCaretIndex = serverTimeHours % 24;
                local v1215 = serverTimeMinutes % 60;
                local v1216 = serverTimeSeconds % 60;
                serverTimeMilliseconds = serverTimeMilliseconds % 10;
                serverTimeSeconds = v1216;
                serverTimeMinutes = v1215;
                serverTimeHours = serverAdjustedCaretIndex;
                serverAdjustedCaretIndex = tonumber(guiGetProperty(rules_time, "CaratIndex"));
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverTimeHours, serverTimeMinutes, serverTimeSeconds, serverTimeMilliseconds));
                guiEditSetCaretIndex(rules_time, serverAdjustedCaretIndex);
                return;
            end;
        elseif source == maps_search then
            updateAdminMaps();
            return;
        elseif source == palette_rr or source == palette_gg or source == palette_bb then
            local serverPaletteRedValue = tonumber(guiGetText(palette_rr));
            local serverPaletteGreenValue = tonumber(guiGetText(palette_gg));
            local serverPaletteBlueValue = tonumber(guiGetText(palette_bb));
            local serverPaletteAlphaValue = tonumber(guiGetText(palette_aa));
            if type(serverPaletteRedValue) ~= "number" then
                serverPaletteRedValue = 0;
            end;
            if type(serverPaletteGreenValue) ~= "number" then
                serverPaletteGreenValue = 0;
            end;
            if type(serverPaletteBlueValue) ~= "number" then
                serverPaletteBlueValue = 0;
            end;
            if type(serverPaletteAlphaValue) ~= "number" then
                serverPaletteAlphaValue = 0;
            end;
            guiSetText(palette_hex, string.format("%02X%02X%02X%02X", serverPaletteAlphaValue, serverPaletteRedValue, serverPaletteGreenValue, serverPaletteBlueValue));
            return;
        elseif source == palette_hex and not palette_mode then
            local serverHexColorText = guiGetText(palette_hex);
            local serverHexAlpha, serverHexRed, serverHexGreen, serverHexBlue = getColorFromString("#" .. serverHexColorText);
            if type(serverHexRed) ~= "number" then
                serverHexRed = 0;
            end;
            if type(serverHexGreen) ~= "number" then
                serverHexGreen = 0;
            end;
            if type(serverHexBlue) ~= "number" then
                serverHexBlue = 0;
            end;
            local serverHueFromHex, serverSaturationFromHex, serverLightnessFromHex = RGBtoHSL(serverHexRed, serverHexGreen, serverHexBlue);
            palette_L = serverLightnessFromHex;
            palette_S = serverSaturationFromHex;
            palette_H = serverHueFromHex;
            guiSetPosition(palette_aim, 0.03 + 0.75 * (palette_H / 360), 0.07 + 0.65 * (1 - palette_S), true);
            guiSetPosition(palette_aim2, 0.93, 0.07 + 0.65 * (1 - palette_L), true);
            serverHueFromHex = string.format("%02X%02X%02X%02X", serverHexAlpha, HSLtoRGB(palette_H, palette_S, 0.5));
            guiSetProperty(palette_color1, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", serverHueFromHex, serverHueFromHex, serverHueFromHex, serverHueFromHex));
            guiSetProperty(palette_color2, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", serverHexColorText, serverHexColorText, serverHexColorText, serverHexColorText));
            return;
        elseif source == wind_vector then
            local serverWindAngle = tonumber(guiGetText(wind_vector)) or 0;
            local serverRadarX, serverRadarY = guiGetPosition(wind_radar, false);
            guiSetPosition(wind_aim, serverRadarX + 32 - 32 * math.sin(math.rad(serverWindAngle)) - 6, serverRadarY + 32 - 32 * math.cos(math.rad(serverWindAngle)) - 6, false);
            return;
        elseif source == fog_distance or source == farclip_distance then
            local serverFarClipValue = tonumber(guiGetText(farclip_distance)) or 0;
            if (tonumber(guiGetText(fog_distance)) or 0) > serverFarClipValue - 0.1 then
                guiSetText(fog_distance, string.format("%.1f", serverFarClipValue - 0.1));
            end;
            return;
        elseif source == handling_mass then
            if tonumber(guiGetText(handling_mass)) < 1 then
                guiSetText(handling_mass, "1.0");
            end;
            if tonumber(guiGetText(handling_mass)) > 100000 then
                guiSetText(handling_mass, "100000.0");
            end;
            return;
        elseif source == handling_turnmass then
            if tonumber(guiGetText(handling_turnmass)) < 0 then
                guiSetText(handling_turnmass, "0.0");
            end;
            if tonumber(guiGetText(handling_turnmass)) > 1000000 then
                guiSetText(handling_turnmass, "1000000.0");
            end;
            return;
        elseif source == handling_dragcoeff then
            if tonumber(guiGetText(handling_dragcoeff)) < -200 then
                guiSetText(handling_dragcoeff, "-200.0");
            end;
            if tonumber(guiGetText(handling_dragcoeff)) > 200 then
                guiSetText(handling_dragcoeff, "200.0");
            end;
            return;
        elseif source == handling_centerofmass_x then
            if tonumber(guiGetText(handling_centerofmass_x)) < -10 then
                guiSetText(handling_centerofmass_x, "-10.0");
            end;
            if tonumber(guiGetText(handling_centerofmass_x)) > 10 then
                guiSetText(handling_centerofmass_x, "10.0");
            end;
            return;
        elseif source == handling_centerofmass_y then
            if tonumber(guiGetText(handling_centerofmass_y)) < -10 then
                guiSetText(handling_centerofmass_y, "-10.0");
            end;
            if tonumber(guiGetText(handling_centerofmass_y)) > 10 then
                guiSetText(handling_centerofmass_y, "10.0");
            end;
            return;
        elseif source == handling_centerofmass_z then
            if tonumber(guiGetText(handling_centerofmass_z)) < -10 then
                guiSetText(handling_centerofmass_z, "-10.0");
            end;
            if tonumber(guiGetText(handling_centerofmass_z)) > 10 then
                guiSetText(handling_centerofmass_z, "10.0");
            end;
            return;
        elseif source == handling_percentsubmerged then
            if tonumber(guiGetText(handling_percentsubmerged)) < 1 then
                guiSetText(handling_percentsubmerged, "1");
            end;
            if tonumber(guiGetText(handling_percentsubmerged)) > 99999 then
                guiSetText(handling_percentsubmerged, "99999");
            end;
            return;
        elseif source == handling_tractionmultiplier then
            if tonumber(guiGetText(handling_tractionmultiplier)) < -100000 then
                guiSetText(handling_tractionmultiplier, "-100000.0");
            end;
            if tonumber(guiGetText(handling_tractionmultiplier)) > 100000 then
                guiSetText(handling_tractionmultiplier, "100000.0");
            end;
            return;
        elseif source == handling_tractionloss then
            if tonumber(guiGetText(handling_tractionloss)) < 0 then
                guiSetText(handling_tractionloss, "0.0");
            end;
            if tonumber(guiGetText(handling_tractionloss)) > 100 then
                guiSetText(handling_tractionloss, "100.0");
            end;
            return;
        elseif source == handling_tractionbias then
            if tonumber(guiGetText(handling_tractionbias)) < 0 then
                guiSetText(handling_tractionbias, "0.0");
            end;
            if tonumber(guiGetText(handling_tractionbias)) > 1 then
                guiSetText(handling_tractionbias, "1.0");
            end;
            return;
        elseif source == handling_numberofgears then
            if tonumber(guiGetText(handling_numberofgears)) < 1 then
                guiSetText(handling_numberofgears, "1");
            end;
            if tonumber(guiGetText(handling_numberofgears)) > 5 then
                guiSetText(handling_numberofgears, "5");
            end;
            return;
        elseif source == handling_maxvelocity then
            if tonumber(guiGetText(handling_maxvelocity)) < 0.1 then
                guiSetText(handling_maxvelocity, "0.1");
            end;
            if tonumber(guiGetText(handling_maxvelocity)) > 200000 then
                guiSetText(handling_maxvelocity, "200000.0");
            end;
            return;
        elseif source == handling_engineacceleration then
            if tonumber(guiGetText(handling_engineacceleration)) < 0 then
                guiSetText(handling_engineacceleration, "0.0");
            end;
            if tonumber(guiGetText(handling_engineacceleration)) > 100000 then
                guiSetText(handling_engineacceleration, "100000.0");
            end;
            return;
        elseif source == handling_engineinertia then
            if tonumber(guiGetText(handling_engineinertia)) < -1000 then
                guiSetText(handling_engineinertia, "-1000.0");
            end;
            if tonumber(guiGetText(handling_engineinertia)) > 1000 then
                guiSetText(handling_engineinertia, "1000.0");
            end;
            return;
        elseif source == handling_brakedeceleration then
            if tonumber(guiGetText(handling_brakedeceleration)) < 0.1 then
                guiSetText(handling_brakedeceleration, "0.1");
            end;
            if tonumber(guiGetText(handling_brakedeceleration)) > 100000 then
                guiSetText(handling_brakedeceleration, "100000.0");
            end;
            return;
        elseif source == handling_brakebias then
            if tonumber(guiGetText(handling_brakebias)) < 0 then
                guiSetText(handling_brakebias, "0.0");
            end;
            if tonumber(guiGetText(handling_brakebias)) > 1 then
                guiSetText(handling_brakebias, "1.0");
            end;
            return;
        elseif source == handling_steeringlock then
            if tonumber(guiGetText(handling_steeringlock)) < 0 then
                guiSetText(handling_steeringlock, "0.0");
            end;
            if tonumber(guiGetText(handling_steeringlock)) > 360 then
                guiSetText(handling_steeringlock, "360.0");
            end;
            return;
        elseif source == handling_suspensionforcelevel then
            if tonumber(guiGetText(handling_suspensionforcelevel)) < 0 then
                guiSetText(handling_suspensionforcelevel, "0.0");
            end;
            if tonumber(guiGetText(handling_suspensionforcelevel)) > 100 then
                guiSetText(handling_suspensionforcelevel, "100.0");
            end;
            return;
        elseif source == handling_suspensiondamping then
            if tonumber(guiGetText(handling_suspensiondamping)) < 0 then
                guiSetText(handling_suspensiondamping, "0.0");
            end;
            if tonumber(guiGetText(handling_suspensiondamping)) > 100 then
                guiSetText(handling_suspensiondamping, "100.0");
            end;
            return;
        elseif source == handling_suspensionhighspeeddamping then
            if tonumber(guiGetText(handling_suspensionhighspeeddamping)) < 0 then
                guiSetText(handling_suspensionhighspeeddamping, "0.0");
            end;
            if tonumber(guiGetText(handling_suspensionhighspeeddamping)) > 600 then
                guiSetText(handling_suspensionhighspeeddamping, "600.0");
            end;
            return;
        elseif source == handling_suspensionupperlimit then
            if tonumber(guiGetText(handling_suspensionupperlimit)) < -50 then
                guiSetText(handling_suspensionupperlimit, "-50.0");
            end;
            if tonumber(guiGetText(handling_suspensionupperlimit)) > 50 then
                guiSetText(handling_suspensionupperlimit, "50.0");
            end;
            return;
        elseif source == handling_suspensionlowerlimit then
            if tonumber(guiGetText(handling_suspensionlowerlimit)) < -50 then
                guiSetText(handling_suspensionlowerlimit, "-50.0");
            end;
            if tonumber(guiGetText(handling_suspensionlowerlimit)) > 50 then
                guiSetText(handling_suspensionlowerlimit, "50.0");
            end;
            return;
        elseif source == handling_suspensionfrontrearbias then
            if tonumber(guiGetText(handling_suspensionfrontrearbias)) < 0 then
                guiSetText(handling_suspensionfrontrearbias, "0.0");
            end;
            if tonumber(guiGetText(handling_suspensionfrontrearbias)) > 1 then
                guiSetText(handling_suspensionfrontrearbias, "1.0");
            end;
            return;
        elseif source == handling_suspensionantidivemultiplier then
            if tonumber(guiGetText(handling_suspensionantidivemultiplier)) < 0 then
                guiSetText(handling_suspensionantidivemultiplier, "0.0");
            end;
            if tonumber(guiGetText(handling_suspensionantidivemultiplier)) > 30 then
                guiSetText(handling_suspensionantidivemultiplier, "30.0");
            end;
            return;
        elseif source == handling_seatoffsetdistance then
            if tonumber(guiGetText(handling_seatoffsetdistance)) < -20 then
                guiSetText(handling_seatoffsetdistance, "-20.0");
            end;
            if tonumber(guiGetText(handling_seatoffsetdistance)) > 20 then
                guiSetText(handling_seatoffsetdistance, "20.0");
            end;
            return;
        elseif source == handling_collisiondamagemultiplier then
            if tonumber(guiGetText(handling_collisiondamagemultiplier)) < 0 then
                guiSetText(handling_collisiondamagemultiplier, "0.0");
            end;
            if tonumber(guiGetText(handling_collisiondamagemultiplier)) > 10 then
                guiSetText(handling_collisiondamagemultiplier, "10.0");
            end;
            return;
        elseif source == sirens_count then
            local serverSirenCountValue = tonumber(guiGetText(sirens_count));
            if not serverSirenCountValue then
                for serverSirenIndex = 1, 8 do
                    guiSetEnabled(sirens_xcenter[serverSirenIndex], false);
                    guiSetEnabled(sirens_ycenter[serverSirenIndex], false);
                    guiSetEnabled(sirens_zcenter[serverSirenIndex], false);
                    guiSetEnabled(sirens_color[serverSirenIndex], false);
                    guiSetEnabled(sirens_minalpha[serverSirenIndex], false);
                end;
            else
                for serverEnabledSirenIndex = 1, 8 do
                    guiSetEnabled(sirens_xcenter[serverEnabledSirenIndex], serverEnabledSirenIndex <= serverSirenCountValue);
                    guiSetEnabled(sirens_ycenter[serverEnabledSirenIndex], serverEnabledSirenIndex <= serverSirenCountValue);
                    guiSetEnabled(sirens_zcenter[serverEnabledSirenIndex], serverEnabledSirenIndex <= serverSirenCountValue);
                    guiSetEnabled(sirens_color[serverEnabledSirenIndex], serverEnabledSirenIndex <= serverSirenCountValue);
                    guiSetEnabled(sirens_minalpha[serverEnabledSirenIndex], serverEnabledSirenIndex <= serverSirenCountValue);
                end;
            end;
            return;
        elseif source == weapons_addname then
            local serverWeaponNameInput = guiGetText(weapons_addname);
            guiSetText(weapons_addnames, serverWeaponNameInput);
            local serverWeaponIDFromName = convertWeaponNamesToID[serverWeaponNameInput];
            if serverWeaponIDFromName then
                local serverDefaultClipAmmo = serverWeaponIDFromName >= 16 and serverWeaponIDFromName <= 43 and getWeaponProperty(serverWeaponIDFromName, "pro", "maximum_clip_ammo") or 1;
                local serverWeaponSlot = getSlotFromWeapon(serverWeaponIDFromName);
                guiSetText(weapons_addammo, tostring(serverDefaultClipAmmo));
                guiSetText(weapons_addlimit, "");
                guiSetText(weapons_addcost, "$");
                guiSetText(weapons_addslot, tostring(serverWeaponSlot));
            end;
            if fileExists("images/hud/" .. serverWeaponNameInput .. ".png") then
                guiStaticImageLoadImage(weapons_addicon, "images/hud/" .. serverWeaponNameInput .. ".png");
            else
                guiStaticImageLoadImage(weapons_addicon, "images/color_pixel.png");
            end;
            return;
        elseif source == weapons_addcost then
            local serverCostWithoutDollar = guiGetText(weapons_addcost):gsub("%$", "");
            guiSetText(weapons_addcost, "$" .. serverCostWithoutDollar);
            if tonumber(guiGetProperty(weapons_addcost, "CaratIndex")) < 1 then
                guiEditSetCaretIndex(weapons_addcost, 1);
            end;
            return;
        elseif source == weapons_addslot then
            local serverUniqueSlotCount = 0;
            local serverSlotColorMapping = {};
            local serverWeaponSlotData = getTacticsData("weapon_slot") or {};
            for __, serverWeaponItemData in ipairs(weapons_items) do
                local serverItemWeaponName = guiGetText(serverWeaponItemData.name);
                local serverItemWeaponID = convertWeaponNamesToID[serverItemWeaponName];
                local serverItemSlotValue = tonumber(serverWeaponSlotData[serverItemWeaponName]) or serverItemWeaponID and getSlotFromWeapon(serverItemWeaponID) or 13;
                if not serverSlotColorMapping[serverItemSlotValue] then
                    serverUniqueSlotCount = serverUniqueSlotCount + 1;
                    serverSlotColorMapping[serverItemSlotValue] = serverUniqueSlotCount;
                end;
            end;
            local serverCurrentSlotText = guiGetText(weapons_addslot);
            if not serverSlotColorMapping[serverCurrentSlotText] then
                serverUniqueSlotCount = serverUniqueSlotCount + 1;
                serverSlotColorMapping[serverCurrentSlotText] = serverUniqueSlotCount;
            end;
            local serverSlotColorHex = string.format("%02X%02X%02X", HSLtoRGB(360 * serverSlotColorMapping[serverCurrentSlotText] / serverUniqueSlotCount, 0.5, 0.5));
            guiSetProperty(weapons_addicon, "ImageColours", "tl:FF" .. serverSlotColorHex .. " tr:FF" .. serverSlotColorHex .. " bl:FF" .. serverSlotColorHex .. " br:FF" .. serverSlotColorHex .. "");
            return;
        else
            return;
        end;
    end;
    onClientGUIMouseUp = function(__, __, __) 
        local serverPaletteModeTemp = nil;
        palette_mode = serverPaletteModeTemp;
        wind_mode = nil;
    end;
    onClientGUIFocus = function() 
        if source == player_setteamcombobox then
            guiComboBoxClear(player_setteamcombobox);
            local serverTeamsForComboBox = getElementsByType("team");
            table.insert(serverTeamsForComboBox, serverTeamsForComboBox[1]);
            table.remove(serverTeamsForComboBox, 1);
            for __, serverTeamElementForCombo in ipairs(serverTeamsForComboBox) do
                guiComboBoxAddItem(player_setteamcombobox, getTeamName(serverTeamElementForCombo));
            end;
            return;
        elseif source == weapons_addcost then
            if tonumber(guiGetProperty(weapons_addcost, "CaratIndex")) < 1 then
                guiEditSetCaretIndex(weapons_addcost, 1);
            end;
            return;
        else
            return;
        end;
    end;
    onClientGUIMouseDown = function(__, __, __) 
        if source == palette_aim or source == palette_hue then
            palette_mode = 1;
            guiBringToFront(palette_light);
            guiBringToFront(palette_aim);
            guiBringToFront(palette_aim2);
            return;
        elseif source == palette_aim2 or source == palette_light or source == palette_color1 then
            palette_mode = 2;
            guiBringToFront(palette_light);
            guiBringToFront(palette_aim);
            guiBringToFront(palette_aim2);
            return;
        elseif source == wind_aim or source == wind_radar then
            wind_mode = 1;
            guiBringToFront(wind_aim);
            return;
        else
            return;
        end;
    end;
    onClientCursorMove = function(__, __, serverCursorX, serverCursorY, __, __, __) 
        if isElement(palette_window) and guiGetVisible(palette_window) then
            if palette_mode == 1 then
                local serverPaletteWindowX, serverPaletteWindowY = guiGetPosition(palette_window, false);
                local serverPaletteWindowWidth, serverPaletteWindowHeight = guiGetSize(palette_window, false);
                local serverRelativeCursorX = (serverCursorX - serverPaletteWindowX - 0.05 * serverPaletteWindowWidth) / (0.75 * serverPaletteWindowWidth);
                local serverRelativeCursorY = (serverCursorY - serverPaletteWindowY - 0.09 * serverPaletteWindowHeight) / (0.65 * serverPaletteWindowHeight);
                palette_H = 360 * math.min(math.max(serverRelativeCursorX, 0), 1);
                palette_S = 1 - math.min(math.max(serverRelativeCursorY, 0), 1);
                guiSetPosition(palette_aim, 0.03 + 0.75 * (palette_H / 360), 0.07 + 0.65 * (1 - palette_S), true);
                local serverMidLightnessColor = string.format("%02X%02X%02X", HSLtoRGB(palette_H, palette_S, 0.5));
                local serverCalculatedRed, serverCalculatedGreen, serverCalculatedBlue = HSLtoRGB(palette_H, palette_S, palette_L);
                local serverFullColorHex = string.format("%02X%02X%02X", serverCalculatedRed, serverCalculatedGreen, serverCalculatedBlue);
                guiSetProperty(palette_color1, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", serverMidLightnessColor, serverMidLightnessColor, serverMidLightnessColor, serverMidLightnessColor));
                guiSetProperty(palette_color2, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", serverFullColorHex, serverFullColorHex, serverFullColorHex, serverFullColorHex));
                guiSetText(palette_rr, tostring(serverCalculatedRed));
                guiSetText(palette_gg, tostring(serverCalculatedGreen));
                guiSetText(palette_bb, tostring(serverCalculatedBlue));
                return;
            elseif palette_mode == 2 then
                local __, serverPaletteWindowYOnly = guiGetPosition(palette_window, false);
                local __, serverPaletteWindowHeightOnly = guiGetSize(palette_window, false);
                local serverRelativeCursorYOnly = (serverCursorY - serverPaletteWindowYOnly - 0.09 * serverPaletteWindowHeightOnly) / (0.65 * serverPaletteWindowHeightOnly);
                palette_L = 1 - math.min(math.max(serverRelativeCursorYOnly, 0), 1);
                guiSetPosition(palette_aim2, 0.93, 0.07 + 0.65 * (1 - palette_L), true);
                local serverMidLightnessHex = string.format("%02X%02X%02X", HSLtoRGB(palette_H, palette_S, 0.5));
                local serverLightnessRed, serverLightnessGreen, serverLightnessBlue = HSLtoRGB(palette_H, palette_S, palette_L);
                local serverLightnessColorHex = string.format("%02X%02X%02X", serverLightnessRed, serverLightnessGreen, serverLightnessBlue);
                guiSetProperty(palette_color1, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", serverMidLightnessHex, serverMidLightnessHex, serverMidLightnessHex, serverMidLightnessHex));
                guiSetProperty(palette_color2, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", serverLightnessColorHex, serverLightnessColorHex, serverLightnessColorHex, serverLightnessColorHex));
                guiSetText(palette_rr, tostring(serverLightnessRed));
                guiSetText(palette_gg, tostring(serverLightnessGreen));
                guiSetText(palette_bb, tostring(serverLightnessBlue));
                return;
            elseif wind_mode == 1 then
                local serverAdminWindowX, serverAdminWindowY = guiGetPosition(admin_window, false);
                local serverWindRadarX, serverWindRadarY = guiGetPosition(wind_radar, false);
                local serverCalculatedWindAngle = getAngleBetweenPoints2D(serverAdminWindowX + 160 + serverWindRadarX + 32, serverCursorY, serverCursorX, serverAdminWindowY + 50 + serverWindRadarY + 32);
                guiSetText(wind_vector, string.format("%.1f", serverCalculatedWindAngle));
                return;
            end;
        end;
    end;
    onPaletteSetColor = function(serverColorElement) 
        if source == sky_topcolor then
            local serverBottomColorProperty = guiGetProperty(sky_bottomcolor, "ReadOnlyBGColour");
            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", serverColorElement, serverColorElement, serverBottomColorProperty, serverBottomColorProperty));
        end;
        if source == sky_bottomcolor then
            local serverTopColorProperty = guiGetProperty(sky_topcolor, "ReadOnlyBGColour");
            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", serverTopColorProperty, serverTopColorProperty, serverColorElement, serverColorElement));
        end;
    end;
    onClientGUIDoubleClick = function(v1297, __, __, __) 
        if v1297 ~= "left" then
            return;
        else
            if source == weather_record then
                local __, serverSelectedWeatherColumn = guiGridListGetSelectedItem(weather_record);
                if serverSelectedWeatherColumn < 1 then
                    return;
                else
                    local serverSelectedWeatherHour = tonumber(guiGridListGetItemData(weather_record, 1, serverSelectedWeatherColumn));
                    if not serverSelectedWeatherHour then
                        return;
                    else
                        local serverHourWeatherData = getTacticsData("Weather") or {};
                        if not serverHourWeatherData[serverSelectedWeatherHour] then
                            return;
                        else
                            serverHourWeatherData = serverHourWeatherData[serverSelectedWeatherHour];
                            guiSetText(wind_vector, string.format("%.1f", getAngleBetweenPoints2D(0, 0, serverHourWeatherData.wind[1], serverHourWeatherData.wind[2])));
                            guiSetText(wind_speed, string.format("%.1f", 200 * math.sqrt(serverHourWeatherData.wind[1] ^ 2 + serverHourWeatherData.wind[2] ^ 2) / 3.6));
                            guiScrollBarSetScrollPosition(wind_slide, math.min(200 * math.sqrt(serverHourWeatherData.wind[1] ^ 2 + serverHourWeatherData.wind[2] ^ 2) / 3.6 * 2, 100));
                            guiScrollBarSetScrollPosition(heat_levelslide, math.min(serverHourWeatherData.heat / 2.55, 100));
                            guiSetText(heat_level, string.format("%.1f", serverHourWeatherData.heat));
                            guiScrollBarSetScrollPosition(rain_slide, math.min(50 * serverHourWeatherData.rain, 100));
                            guiSetText(rain_level, string.format("%.1f", serverHourWeatherData.rain));
                            guiScrollBarSetScrollPosition(farclip_slide, math.min(serverHourWeatherData.far / 30, 100));
                            guiSetText(farclip_distance, string.format("%.1f", serverHourWeatherData.far));
                            guiScrollBarSetScrollPosition(fog_slide, math.min((serverHourWeatherData.fog + 1000) / 40, 100));
                            guiSetText(fog_distance, string.format("%.1f", serverHourWeatherData.fog));
                            guiSetProperty(sky_topcolor, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", serverHourWeatherData.sky[1], serverHourWeatherData.sky[2], serverHourWeatherData.sky[3]));
                            guiBringToFront(sky_topcolor);
                            guiSetProperty(sky_bottomcolor, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", serverHourWeatherData.sky[4], serverHourWeatherData.sky[5], serverHourWeatherData.sky[6]));
                            guiBringToFront(sky_bottomcolor);
                            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:FF%02X%02X%02X tr:FF%02X%02X%02X bl:FF%02X%02X%02X br:FF%02X%02X%02X", serverHourWeatherData.sky[1], serverHourWeatherData.sky[2], serverHourWeatherData.sky[3], serverHourWeatherData.sky[1], serverHourWeatherData.sky[2], serverHourWeatherData.sky[3], serverHourWeatherData.sky[4], serverHourWeatherData.sky[5], serverHourWeatherData.sky[6], serverHourWeatherData.sky[4], serverHourWeatherData.sky[5], serverHourWeatherData.sky[6]));
                            guiSetVisible(sky_clouds_img, serverHourWeatherData.clouds);
                            guiCheckBoxSetSelected(sky_clouds, serverHourWeatherData.clouds);
                            guiSetVisible(sky_birds_img, serverHourWeatherData.birds);
                            guiCheckBoxSetSelected(sky_birds, serverHourWeatherData.birds);
                            guiScrollBarSetScrollPosition(sun_sizeslide, math.min(serverHourWeatherData.sunsize * 2, 100));
                            guiSetText(sun_size, string.format("%.1f", serverHourWeatherData.sunsize));
                            guiSetProperty(sun_colora, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", serverHourWeatherData.sun[1], serverHourWeatherData.sun[2], serverHourWeatherData.sun[3]));
                            guiBringToFront(sun_colora);
                            guiSetProperty(sun_colorb, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", serverHourWeatherData.sun[4], serverHourWeatherData.sun[5], serverHourWeatherData.sun[6]));
                            guiBringToFront(sun_colorb);
                            guiSetProperty(water_color, "ReadOnlyBGColour", string.format("%02X%02X%02X%02X", serverHourWeatherData.water[4], serverHourWeatherData.water[1], serverHourWeatherData.water[2], serverHourWeatherData.water[3]));
                            guiBringToFront(water_color);
                            guiScrollBarSetScrollPosition(water_levelslide, math.min((serverHourWeatherData.level + 200) / 4, 100));
                            guiSetText(water_level, string.format("%.1f", serverHourWeatherData.level));
                            guiScrollBarSetScrollPosition(wave_heightslide, math.min(serverHourWeatherData.wave * 10, 100));
                            guiSetText(wave_height, string.format("%.1f", serverHourWeatherData.wave));
                            local serverWeatherEffectNames = {
                                [0] = "Clear", 
                                [10] = "Cloudy", 
                                [8] = "Thunder", 
                                [19] = "Storm", 
                                [9] = "Fog"
                            };
                            guiSetText(weather_effect, serverWeatherEffectNames[serverHourWeatherData.effect] or tostring(serverHourWeatherData.effect));
                        end;
                    end;
                end;
            end;
            if source == server_maps then
                local serverSelectedMapIndex = guiGridListGetSelectedItem(server_maps);
                if serverSelectedMapIndex == -1 then
                    return;
                else
                    local serverSelectedMapResource = guiGridListGetItemData(server_maps, serverSelectedMapIndex, 1);
                    callServerFunction("startMap", serverSelectedMapResource);
                end;
            end;
            if source == server_cycler then
                local serverSelectedCyclerIndex = guiGridListGetSelectedItem(server_cycler);
                if serverSelectedCyclerIndex == -1 then
                    return;
                else
                    local serverSelectedCyclerResource = guiGridListGetItemData(server_cycler, serverSelectedCyclerIndex, 2);
                    callServerFunction("startMap", serverSelectedCyclerResource, serverSelectedCyclerIndex + 1);
                end;
            end;
            if source == config_list then
                local serverSelectedConfigGridIndex = guiGridListGetSelectedItem(config_list);
                if serverSelectedConfigGridIndex == -1 then
                    return;
                else
                    local serverSelectedConfigName = guiGridListGetItemText(config_list, serverSelectedConfigGridIndex, 1);
                    callServerFunction("startConfig", serverSelectedConfigName);
                end;
            end;
            if source == restore_list then
                local serverSelectedRestoreRow = guiGridListGetSelectedItem(restore_list);
                if serverSelectedRestoreRow == -1 then
                    return;
                else
                    callServerFunction("restorePlayerLoad", restore_player, serverSelectedRestoreRow + 1);
                    if guiCheckBoxGetSelected(config_performance_adminpanel) then
                        destroyElement(restore_window);
                    else
                        guiSetVisible(restore_window, false);
                    end;
                    restore_player = false;
                end;
            end;
            if source == vehicles_disabled then
                local serverSelectedDisabledVehicle = guiGridListGetSelectedItem(vehicles_disabled);
                if serverSelectedDisabledVehicle == -1 then
                    return;
                else
                    local serverDisabledVehicleModel = tonumber(guiGridListGetItemData(vehicles_disabled, serverSelectedDisabledVehicle, 1));
                    setTacticsData(nil, "disabled_vehicles", serverDisabledVehicleModel);
                end;
            end;
            if source == vehicles_enabled then
                local serverSelectedEnabledVehicle = guiGridListGetSelectedItem(vehicles_enabled);
                if serverSelectedEnabledVehicle == -1 then
                    return;
                else
                    local serverEnabledVehicleModel = tonumber(guiGridListGetItemData(vehicles_enabled, serverSelectedEnabledVehicle, 1));
                    setTacticsData(true, "disabled_vehicles", serverEnabledVehicleModel);
                end;
            end;
            if source == modes_rules then
                local serverSelectedModeForRule = guiGridListGetSelectedItem(modes_list);
                local serverSelectedRuleForEdit = guiGridListGetSelectedItem(modes_rules);
                if serverSelectedRuleForEdit == -1 or serverSelectedModeForRule == -1 then
                    return;
                else
                    local serverRuleCategoryName = guiGridListGetItemText(modes_list, serverSelectedModeForRule, 1);
                    local serverRuleKeyName = guiGridListGetItemText(modes_rules, serverSelectedRuleForEdit, 1);
                    local serverRuleCurrentValue = guiGridListGetItemData(modes_rules, serverSelectedRuleForEdit, 2);
                    if serverRuleCurrentValue == "true" then
                        if serverRuleCategoryName == "settings" then
                            setTacticsData("false", "settings", serverRuleKeyName);
                        elseif serverRuleCategoryName == "glitches" then
                            setTacticsData("false", "glitches", serverRuleKeyName);
                        elseif serverRuleCategoryName == "cheats" then
                            setTacticsData("false", "cheats", serverRuleKeyName);
                        elseif serverRuleCategoryName == "limites" then
                            setTacticsData("false", "limites", serverRuleKeyName);
                        else
                            setTacticsData("false", "modes", serverRuleCategoryName, serverRuleKeyName);
                        end;
                    elseif serverRuleCurrentValue == "false" then
                        if serverRuleCategoryName == "settings" then
                            setTacticsData("true", "settings", serverRuleKeyName);
                        elseif serverRuleCategoryName == "glitches" then
                            setTacticsData("true", "glitches", serverRuleKeyName);
                        elseif serverRuleCategoryName == "cheats" then
                            setTacticsData("true", "cheats", serverRuleKeyName);
                        elseif serverRuleCategoryName == "limites" then
                            setTacticsData("true", "limites", serverRuleKeyName);
                        else
                            setTacticsData("true", "modes", serverRuleCategoryName, serverRuleKeyName);
                        end;
                    else
                        if not isElement(rules_window) then
                            createAdminRules();
                        end;
                        if string.find(serverRuleCurrentValue, "|") then
                            guiSetVisible(rules_edit, false);
                            guiSetVisible(rules_list, true);
                            guiSetVisible(rules_time, false);
                            guiSetVisible(rules_time_up, false);
                            guiSetVisible(rules_time_down, false);
                            guiGridListClear(rules_list);
                            local serverCurrentRuleValue = string.sub(serverRuleCurrentValue, 1, string.find(serverRuleCurrentValue, "|") - 1);
                            local serverRuleOptionsString = string.sub(serverRuleCurrentValue, string.find(serverRuleCurrentValue, "|") + 1, -1);
                            local serverRuleOption = {};
                            local serverOptionStartIndex = 1;
                            local serverOptionSeparatorIndex = 1;
                            local serverRuleOptionRow = nil;
                            while serverOptionSeparatorIndex do
                                serverOptionSeparatorIndex = string.find(serverRuleOptionsString, ",", serverOptionStartIndex);
                                if serverOptionSeparatorIndex then
                                    serverRuleOption = string.sub(serverRuleOptionsString, serverOptionStartIndex, serverOptionSeparatorIndex - 1);
                                    serverOptionStartIndex = serverOptionSeparatorIndex + 1;
                                else
                                    serverRuleOption = string.sub(serverRuleOptionsString, serverOptionStartIndex, -1);
                                end;
                                serverRuleOptionRow = guiGridListAddRow(rules_list);
                                guiGridListSetItemText(rules_list, serverRuleOptionRow, 1, serverRuleOption, false, false);
                                if serverRuleOption == serverCurrentRuleValue then
                                    guiGridListSetSelectedItem(rules_list, serverRuleOptionRow, 1);
                                end;
                            end;
                            guiSetPosition(rules_window, xscreen * 0.5 - 120, (yscreen - 130 - 14 * serverRuleOptionRow) * 0.5, false);
                            guiSetSize(rules_window, 240, 130 + 14 * serverRuleOptionRow, false);
                            guiSetPosition(rules_ok, 60, 100 + 14 * serverRuleOptionRow, false);
                            guiSetPosition(rules_cancel, 122.4, 100 + 14 * serverRuleOptionRow, false);
                            guiSetSize(rules_list, 192, 50 + 14 * serverRuleOptionRow, false);
                            guiSetText(rules_label, "Choise new value for '" .. serverRuleKeyName .. "'");
                        elseif string.find(serverRuleCurrentValue, ":") then
                            guiSetVisible(rules_edit, false);
                            guiSetVisible(rules_list, false);
                            guiSetVisible(rules_time, true);
                            guiSetVisible(rules_time_up, true);
                            guiSetVisible(rules_time_down, true);
                            guiSetPosition(rules_window, (xscreen - 240) * 0.5, (yscreen - 120) * 0.5, false);
                            guiSetSize(rules_window, 240, 120, false);
                            guiSetPosition(rules_ok, 60, 90, false);
                            guiSetPosition(rules_cancel, 122.4, 90, false);
                            guiSetText(rules_label, "Choise new time for '" .. serverRuleKeyName .. "'");
                            local serverTimeParts = split(tostring(serverRuleCurrentValue), string.byte(":"));
                            local serverRuleHours = tonumber(serverTimeParts[#serverTimeParts - 2]) or 0;
                            local serverRuleMinutes = tonumber(serverTimeParts[#serverTimeParts - 1]) or 0;
                            local serverRuleSeconds = tonumber(gettok(serverTimeParts[#serverTimeParts], 1, string.byte("."))) or 0;
                            local serverRuleMilliseconds = tonumber(gettok(serverTimeParts[#serverTimeParts], 2, string.byte("."))) or 0;
                            guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", serverRuleHours, serverRuleMinutes, serverRuleSeconds, serverRuleMilliseconds));
                        else
                            guiSetVisible(rules_edit, true);
                            guiSetVisible(rules_list, false);
                            guiSetVisible(rules_time, false);
                            guiSetVisible(rules_time_up, false);
                            guiSetVisible(rules_time_down, false);
                            guiSetPosition(rules_window, (xscreen - 240) * 0.5, (yscreen - 100) * 0.5, false);
                            guiSetSize(rules_window, 240, 100, false);
                            guiSetPosition(rules_ok, 60, 70, false);
                            guiSetPosition(rules_cancel, 122.4, 70, false);
                            guiSetText(rules_label, "Enter new value for '" .. serverRuleKeyName .. "'");
                            guiSetText(rules_edit, tostring(serverRuleCurrentValue));
                        end;
                        guiBringToFront(rules_window);
                        guiSetVisible(rules_window, true);
                    end;
                end;
            end;
            if source == anticheat_modslist then
                if not isElement(mods_window) then
                    createAdminMods();
                end;
                local serverSelectedModRow = guiGridListGetSelectedItem(anticheat_modslist);
                if serverSelectedModRow == -1 then
                    return;
                else
                    local serverModNameText = guiGridListGetItemText(anticheat_modslist, serverSelectedModRow, 1);
                    local serverModSearchText = guiGridListGetItemText(anticheat_modslist, serverSelectedModRow, 2);
                    local serverModTypeText = guiGridListGetItemData(anticheat_modslist, serverSelectedModRow, 2);
                    guiSetText(mods_name, serverModNameText);
                    guiSetText(mods_edit, serverModSearchText);
                    guiSetText(mods_ok, "Set");
                    if serverModTypeText == "name" then
                        guiRadioButtonSetSelected(mods_type_name, true);
                    end;
                    if serverModTypeText == "hash" then
                        guiRadioButtonSetSelected(mods_type_hash, true);
                    end;
                    guiBringToFront(mods_window);
                    guiSetVisible(mods_window, true);
                end;
            end;
            if source == rules_list then
                local serverSelectedModeForRuleList = guiGridListGetSelectedItem(modes_list);
                local serverSelectedRuleForList = guiGridListGetSelectedItem(modes_rules);
                local serverSelectedRuleListItem = guiGridListGetSelectedItem(rules_list);
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rules_window);
                else
                    guiSetVisible(rules_window, false);
                end;
                if serverSelectedRuleListItem > -1 and isElement(admin_window) then
                    local serverSelectedRuleValue = guiGridListGetItemText(rules_list, serverSelectedRuleListItem, 1);
                    if serverSelectedModeForRuleList == -1 or serverSelectedRuleForList == -1 then
                        return;
                    else
                        local serverRuleListCategory = guiGridListGetItemText(modes_list, serverSelectedModeForRuleList, 1);
                        local serverRuleListKey = guiGridListGetItemText(modes_rules, serverSelectedRuleForList, 1);
                        if serverRuleListCategory == "settings" then
                            setTacticsData(serverSelectedRuleValue, "settings", serverRuleListKey, true);
                        elseif serverRuleListCategory == "glitches" then
                            setTacticsData(serverSelectedRuleValue, "glitches", serverRuleListKey, true);
                        elseif serverRuleListCategory == "cheats" then
                            setTacticsData(serverSelectedRuleValue, "cheats", serverRuleListKey, true);
                        elseif serverRuleListCategory == "limites" then
                            setTacticsData(serverSelectedRuleValue, "limites", serverRuleListKey, true);
                        else
                            setTacticsData(serverSelectedRuleValue, "modes", serverRuleListCategory, serverRuleListKey, true);
                        end;
                    end;
                end;
            end;
            return;
        end;
    end;
    onClientGUIComboBoxAccepted = function(__) 
        if source == shooting_weapon then
            local serverShootingWeaponID = getWeaponIDFromName(guiGetText(shooting_weapon));
            guiSetText(shooting_weapon_range, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "weapon_range")));
            guiSetText(shooting_target_range, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "target_range")));
            guiSetText(shooting_accuracy, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "accuracy")));
            guiSetText(shooting_damage, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "damage") / 3));
            guiSetText(shooting_maximum_clip, getWeaponProperty(serverShootingWeaponID, "pro", "maximum_clip_ammo"));
            guiSetText(shooting_move_speed, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "move_speed")));
            guiSetText(shooting_anim_loop_start, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim_loop_start")));
            guiSetText(shooting_anim_loop_stop, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim_loop_stop")));
            guiSetText(shooting_anim_loop_bullet_fire, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim_loop_bullet_fire")));
            guiSetText(shooting_anim2_loop_start, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim2_loop_start")));
            guiSetText(shooting_anim2_loop_stop, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim2_loop_stop")));
            guiSetText(shooting_anim2_loop_bullet_fire, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim2_loop_bullet_fire")));
            guiSetText(shooting_anim_breakout_time, string.format("%.4f", getWeaponProperty(serverShootingWeaponID, "pro", "anim_breakout_time")));
            local serverWeaponFlagsHex = string.reverse(string.format("%06X", getWeaponProperty(serverShootingWeaponID, "pro", "flags")));
            for serverFlagByteIndex = 1, 4 do
                local serverFlagByteValue = tonumber(string.sub(serverWeaponFlagsHex, serverFlagByteIndex, serverFlagByteIndex), 16);
                if serverFlagByteValue then
                    if serverFlagByteValue >= 8 then
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][8], true);
                        serverFlagByteValue = serverFlagByteValue - 8;
                    else
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][8], false);
                    end;
                    if serverFlagByteValue >= 4 then
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][4], true);
                        serverFlagByteValue = serverFlagByteValue - 4;
                    else
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][4], false);
                    end;
                    if serverFlagByteValue >= 2 then
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][2], true);
                        serverFlagByteValue = serverFlagByteValue - 2;
                    else
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][2], false);
                    end;
                    if serverFlagByteValue >= 1 then
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][1], true);
                        serverFlagByteValue = serverFlagByteValue - 1;
                    else
                        guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][1], false);
                    end;
                else
                    guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][1], false);
                    guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][2], false);
                    guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][4], false);
                    guiCheckBoxSetSelected(shooting_flags[serverFlagByteIndex][8], false);
                end;
            end;
        end;
        if source == handling_model then
            local serverHandlingVehicleModel = getVehicleModelFromName(guiGetText(handling_model));
            local serverCustomHandlingData = (getTacticsData("handlings") or {})[serverHandlingVehicleModel] or {};
            local serverOriginalHandlingData = getOriginalHandling(serverHandlingVehicleModel);
            guiSetText(handling_mass, string.format("%.1f", serverCustomHandlingData.mass or serverOriginalHandlingData.mass));
            guiSetText(handling_turnmass, string.format("%.1f", serverCustomHandlingData.turnMass or serverOriginalHandlingData.turnMass));
            guiSetText(handling_dragcoeff, string.format("%.3f", serverCustomHandlingData.dragCoeff or serverOriginalHandlingData.dragCoeff));
            guiSetText(handling_centerofmass_x, string.format("%.3f", serverCustomHandlingData.centerOfMass and serverCustomHandlingData.centerOfMass[1] or serverOriginalHandlingData.centerOfMass[1]));
            guiSetText(handling_centerofmass_y, string.format("%.3f", serverCustomHandlingData.centerOfMass and serverCustomHandlingData.centerOfMass[2] or serverOriginalHandlingData.centerOfMass[2]));
            guiSetText(handling_centerofmass_z, string.format("%.3f", serverCustomHandlingData.centerOfMass and serverCustomHandlingData.centerOfMass[3] or serverOriginalHandlingData.centerOfMass[3]));
            guiSetText(handling_percentsubmerged, string.format("%.0f", serverCustomHandlingData.percentSubmerged or serverOriginalHandlingData.percentSubmerged));
            guiSetText(handling_tractionmultiplier, string.format("%.3f", serverCustomHandlingData.tractionMultiplier or serverOriginalHandlingData.tractionMultiplier));
            guiSetText(handling_tractionloss, string.format("%.3f", serverCustomHandlingData.tractionLoss or serverOriginalHandlingData.tractionLoss));
            guiSetText(handling_tractionbias, string.format("%.3f", serverCustomHandlingData.tractionBias or serverOriginalHandlingData.tractionBias));
            guiSetText(handling_numberofgears, string.format("%.0f", serverCustomHandlingData.numberOfGears or serverOriginalHandlingData.numberOfGears));
            guiSetText(handling_maxvelocity, string.format("%.3f", serverCustomHandlingData.maxVelocity or serverOriginalHandlingData.maxVelocity));
            guiSetText(handling_engineacceleration, string.format("%.3f", serverCustomHandlingData.engineAcceleration or serverOriginalHandlingData.engineAcceleration));
            guiSetText(handling_engineinertia, string.format("%.3f", serverCustomHandlingData.engineInertia or serverOriginalHandlingData.engineInertia));
            guiSetText(handling_drivetype, ({
                awd = "4x4", 
                fwd = "Front", 
                rwd = "Rear"
            })[serverCustomHandlingData.driveType or serverOriginalHandlingData.driveType]);
            guiSetText(handling_enginetype, ({
                petrol = "Petrol", 
                diesel = "Diesel", 
                electric = "Electric"
            })[serverCustomHandlingData.engineType or serverOriginalHandlingData.engineType]);
            guiSetText(handling_brakedeceleration, string.format("%.3f", serverCustomHandlingData.brakeDeceleration or serverOriginalHandlingData.brakeDeceleration));
            guiSetText(handling_brakebias, string.format("%.3f", serverCustomHandlingData.brakeBias or serverOriginalHandlingData.brakeBias));
            guiSetText(handling_abs, serverCustomHandlingData.ABS ~= nil and (serverCustomHandlingData.ABS and "Enable" or "Disable") or serverOriginalHandlingData.ABS and "Enable" or "Disable");
            guiSetText(handling_steeringlock, string.format("%.3f", serverCustomHandlingData.steeringLock or serverOriginalHandlingData.steeringLock));
            guiSetText(handling_suspensionforcelevel, string.format("%.3f", serverCustomHandlingData.suspensionForceLevel or serverOriginalHandlingData.suspensionForceLevel));
            guiSetText(handling_suspensiondamping, string.format("%.3f", serverCustomHandlingData.suspensionDamping or serverOriginalHandlingData.suspensionDamping));
            guiSetText(handling_suspensionhighspeeddamping, string.format("%.3f", serverCustomHandlingData.suspensionHighSpeedDamping or serverOriginalHandlingData.suspensionHighSpeedDamping));
            guiSetText(handling_suspensionupperlimit, string.format("%.3f", serverCustomHandlingData.suspensionUpperLimit or serverOriginalHandlingData.suspensionUpperLimit));
            guiSetText(handling_suspensionlowerlimit, string.format("%.3f", serverCustomHandlingData.suspensionLowerLimit or serverOriginalHandlingData.suspensionLowerLimit));
            guiSetText(handling_suspensionfrontrearbias, string.format("%.3f", serverCustomHandlingData.suspensionFrontRearBias or serverOriginalHandlingData.suspensionFrontRearBias));
            guiSetText(handling_suspensionantidivemultiplier, string.format("%.3f", serverCustomHandlingData.suspensionAntiDiveMultiplier or serverOriginalHandlingData.suspensionAntiDiveMultiplier));
            guiSetText(handling_seatoffsetdistance, string.format("%.3f", serverCustomHandlingData.seatOffsetDistance or serverOriginalHandlingData.seatOffsetDistance));
            guiSetText(handling_collisiondamagemultiplier, string.format("%.3f", serverCustomHandlingData.collisionDamageMultiplier or serverOriginalHandlingData.collisionDamageMultiplier));
            guiSetText(handling_variant1, string.format("%.3f", serverCustomHandlingData.collisionDamageMultiplier or serverOriginalHandlingData.collisionDamageMultiplier));
            guiComboBoxClear(handling_variant1);
            guiComboBoxClear(handling_variant2);
            guiComboBoxAddItem(handling_variant1, "Random");
            guiComboBoxAddItem(handling_variant2, "Random");
            local serverVariantIterator = pairs;
            local serverVehicleVariants = convertVehicleVariant[serverHandlingVehicleModel] or {};
            for __, serverVariantValue in serverVariantIterator(serverVehicleVariants) do
                guiComboBoxAddItem(handling_variant1, tostring(serverVariantValue));
                guiComboBoxAddItem(handling_variant2, tostring(serverVariantValue));
            end;
            serverVariantIterator = string.reverse(string.format("%08X", tonumber(serverCustomHandlingData.modelFlags) or serverOriginalHandlingData.modelFlags));
            serverVehicleVariants = string.reverse(string.format("%08X", tonumber(serverCustomHandlingData.handlingFlags) or serverOriginalHandlingData.handlingFlags));
            for serverFlagBytePosition = 1, 8 do
                local serverModelFlagByte = tonumber("0x" .. string.sub(serverVariantIterator, serverFlagBytePosition, serverFlagBytePosition)) or 0;
                local serverHandlingFlagByte = tonumber("0x" .. string.sub(serverVehicleVariants, serverFlagBytePosition, serverFlagBytePosition)) or 0;
                for serverBitPosition = 3, 0, -1 do
                    local serverBitValue = 2 ^ serverBitPosition;
                    if serverBitValue <= serverModelFlagByte and serverModelFlagByte % serverBitValue >= 0 then
                        serverModelFlagByte = serverModelFlagByte - serverBitValue;
                        guiCheckBoxSetSelected(handling_modelflags[serverFlagBytePosition][serverBitValue], true);
                    else
                        guiCheckBoxSetSelected(handling_modelflags[serverFlagBytePosition][serverBitValue], false);
                    end;
                    if serverBitValue <= serverHandlingFlagByte and serverHandlingFlagByte % serverBitValue >= 0 then
                        serverHandlingFlagByte = serverHandlingFlagByte - serverBitValue;
                        guiCheckBoxSetSelected(handling_handlingflags[serverFlagBytePosition][serverBitValue], true);
                    else
                        guiCheckBoxSetSelected(handling_handlingflags[serverFlagBytePosition][serverBitValue], false);
                    end;
                end;
            end;
            if not serverCustomHandlingData.sirens then
                guiSetText(sirens_count, "Original");
                guiSetText(sirens_type, "Dual");
                guiCheckBoxSetSelected(sirens_360, false);
                guiCheckBoxSetSelected(sirens_LOS, false);
                guiCheckBoxSetSelected(sirens_randomiser, false);
                guiCheckBoxSetSelected(sirens_silent, false);
                for serverSirenSetupIndex = 1, 8 do
                    guiSetText(sirens_xcenter[serverSirenSetupIndex], "0.000");
                    guiSetText(sirens_ycenter[serverSirenSetupIndex], "0.000");
                    guiSetText(sirens_zcenter[serverSirenSetupIndex], "0.000");
                    guiSetProperty(sirens_color[serverSirenSetupIndex], "ReadOnlyBGColour", "FF808080");
                    guiBringToFront(sirens_color[serverSirenSetupIndex]);
                    guiSetText(sirens_minalpha[serverSirenSetupIndex], "0");
                    guiSetEnabled(sirens_xcenter[serverSirenSetupIndex], false);
                    guiSetEnabled(sirens_ycenter[serverSirenSetupIndex], false);
                    guiSetEnabled(sirens_zcenter[serverSirenSetupIndex], false);
                    guiSetEnabled(sirens_color[serverSirenSetupIndex], false);
                    guiSetEnabled(sirens_minalpha[serverSirenSetupIndex], false);
                end;
            else
                guiSetText(sirens_count, serverCustomHandlingData.sirens.count == 0 and "Original" or tostring(serverCustomHandlingData.sirens.count));
                guiSetText(sirens_type, ({
                    [1] = "Invisible", 
                    [2] = "Single", 
                    [3] = "Dual", 
                    [4] = "Triple", 
                    [5] = "Quadruple", 
                    [6] = "Quinary"
                })[serverCustomHandlingData.sirens.type]);
                guiCheckBoxSetSelected(sirens_360, serverCustomHandlingData.sirens.flags["360"]);
                guiCheckBoxSetSelected(sirens_LOS, serverCustomHandlingData.sirens.flags.DoLOSCheck);
                guiCheckBoxSetSelected(sirens_randomiser, serverCustomHandlingData.sirens.flags.UseRandomiser);
                guiCheckBoxSetSelected(sirens_silent, serverCustomHandlingData.sirens.flags.Silent);
                for serverSirenDataIndex = 1, 8 do
                    if serverSirenDataIndex <= serverCustomHandlingData.sirens.count then
                        guiSetText(sirens_xcenter[serverSirenDataIndex], string.format("%.3f", serverCustomHandlingData.sirens[serverSirenDataIndex].x));
                        guiSetText(sirens_ycenter[serverSirenDataIndex], string.format("%.3f", serverCustomHandlingData.sirens[serverSirenDataIndex].y));
                        guiSetText(sirens_zcenter[serverSirenDataIndex], string.format("%.3f", serverCustomHandlingData.sirens[serverSirenDataIndex].z));
                        guiSetProperty(sirens_color[serverSirenDataIndex], "ReadOnlyBGColour", serverCustomHandlingData.sirens[serverSirenDataIndex].color);
                        guiBringToFront(sirens_color[serverSirenDataIndex]);
                        guiSetText(sirens_minalpha[serverSirenDataIndex], tostring(serverCustomHandlingData.sirens[serverSirenDataIndex].minalpha));
                    else
                        guiSetText(sirens_xcenter[serverSirenDataIndex], "0.000");
                        guiSetText(sirens_ycenter[serverSirenDataIndex], "0.000");
                        guiSetText(sirens_zcenter[serverSirenDataIndex], "0.000");
                        guiSetProperty(sirens_color[serverSirenDataIndex], "ReadOnlyBGColour", "FF808080");
                        guiBringToFront(sirens_color[serverSirenDataIndex]);
                        guiSetText(sirens_minalpha[serverSirenDataIndex], "0");
                    end;
                    guiSetEnabled(sirens_xcenter[serverSirenDataIndex], serverSirenDataIndex <= serverCustomHandlingData.sirens.count);
                    guiSetEnabled(sirens_ycenter[serverSirenDataIndex], serverSirenDataIndex <= serverCustomHandlingData.sirens.count);
                    guiSetEnabled(sirens_zcenter[serverSirenDataIndex], serverSirenDataIndex <= serverCustomHandlingData.sirens.count);
                    guiSetEnabled(sirens_color[serverSirenDataIndex], serverSirenDataIndex <= serverCustomHandlingData.sirens.count);
                    guiSetEnabled(sirens_minalpha[serverSirenDataIndex], serverSirenDataIndex <= serverCustomHandlingData.sirens.count);
                end;
            end;
        end;
        if source == anticheat_action then
            local serverAnticheatActionValue = ({
                ["Chat message"] = "chat", 
                ["Adminchat message"] = "adminchat", 
                Kick = "kick"
            })[guiGetText(anticheat_action)];
            setTacticsData(serverAnticheatActionValue, "anticheat", "action_detection", true);
        end;
        if source == anticheat_speedhack then
            local serverSpeedhackSetting = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_speedhack)];
            setTacticsData(serverSpeedhackSetting, "anticheat", "speedhack");
        end;
        if source == anticheat_godmode then
            local serverGodmodeSetting = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_godmode)];
            setTacticsData(serverGodmodeSetting, "anticheat", "godmode");
        end;
        if source == anticheat_mods then
            local serverModsSetting = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_mods)];
            setTacticsData(serverModsSetting, "anticheat", "mods");
        end;
        if source == player_setteamcombobox then
            local serverSelectedTeamObject = getTeamFromName(guiGetText(player_setteamcombobox));
            guiSetText(player_setteam, guiGetText(player_setteamcombobox));
            if not serverSelectedPlayers then
                return;
            else
                for __, serverTargetPlayerForTeam in ipairs(serverSelectedPlayers) do
                    triggerServerEvent("onPlayerTeamSelect", serverTargetPlayerForTeam, serverSelectedTeamObject, true);
                end;
            end;
        end;
        if source == player_balancecombobox then
            local serverBalanceType = guiGetText(player_balancecombobox);
            if serverBalanceType == "Select" then
                callServerFunction("balanceTeams", localPlayer, serverBalanceType, serverSelectedPlayers);
            else
                callServerFunction("balanceTeams", localPlayer, serverBalanceType);
            end;
        end;
        if source == screen_list then
            loadScreenShot(guiGetText(screen_list));
        end;
        if source == player_takescreencombobox then
            if guiGetText(player_takescreencombobox) == "My screens" then
                guiSetText(player_takescreencombobox, "320x240:30%");
                if not isElement(screen_window) then
                    createAdminScreen();
                end;
                loadScreenShot(guiGetText(screen_list));
                return;
            elseif not serverSelectedPlayers or #serverSelectedPlayers > 1 then
                return;
            else
                local serverScreenshotOption = guiGetText(player_takescreencombobox);
                local serverResolutionPart = gettok(serverScreenshotOption, 1, string.byte(":"));
                local serverScreenshotWidth = tonumber(gettok(serverResolutionPart, 1, string.byte("x")));
                local serverScreenshotHeight = tonumber(gettok(serverResolutionPart, 2, string.byte("x")));
                local serverQualityPercentage = tonumber(({
                    gettok(serverScreenshotOption, 2, string.byte(":")):gsub("%%", "")
                })[1]);
                if serverResolutionPart then
                    callServerFunction("takePlayerScreenShot", serverSelectedPlayers[1], serverScreenshotWidth, serverScreenshotHeight, getPlayerName(localPlayer) .. " " .. serverScreenshotWidth .. " " .. serverScreenshotHeight .. " " .. serverQualityPercentage, serverQualityPercentage, 5000);
                end;
                guiSetText(player_takescreencombobox, "320x240:30%");
                guiSetEnabled(player_takescreen, false);
                guiSetEnabled(player_takescreencombobox, false);
                screenTimeout = setTimer(function() 
                    guiSetEnabled(player_takescreen, true);
                    guiSetEnabled(player_takescreencombobox, true);
                end, 30000, 1);
            end;
        end;
        if source == sirens_count then
            local serverSirenCountNumber = tonumber(guiGetText(sirens_count));
            if not serverSirenCountNumber then
                for serverSirenDisableIndex = 1, 8 do
                    guiSetEnabled(sirens_xcenter[serverSirenDisableIndex], false);
                    guiSetEnabled(sirens_ycenter[serverSirenDisableIndex], false);
                    guiSetEnabled(sirens_zcenter[serverSirenDisableIndex], false);
                    guiSetEnabled(sirens_color[serverSirenDisableIndex], false);
                    guiSetEnabled(sirens_minalpha[serverSirenDisableIndex], false);
                end;
            else
                for serverSirenEnableIndex = 1, 8 do
                    guiSetEnabled(sirens_xcenter[serverSirenEnableIndex], serverSirenEnableIndex <= serverSirenCountNumber);
                    guiSetEnabled(sirens_ycenter[serverSirenEnableIndex], serverSirenEnableIndex <= serverSirenCountNumber);
                    guiSetEnabled(sirens_zcenter[serverSirenEnableIndex], serverSirenEnableIndex <= serverSirenCountNumber);
                    guiSetEnabled(sirens_color[serverSirenEnableIndex], serverSirenEnableIndex <= serverSirenCountNumber);
                    guiSetEnabled(sirens_minalpha[serverSirenEnableIndex], serverSirenEnableIndex <= serverSirenCountNumber);
                end;
            end;
        end;
        if source == weapons_addnames then
            local serverSelectedWeaponFromCombo = guiGetText(weapons_addnames);
            guiStaticImageLoadImage(weapons_addicon, "images/hud/" .. serverSelectedWeaponFromCombo .. ".png");
            guiSetText(weapons_addname, serverSelectedWeaponFromCombo);
            guiEditSetCaretIndex(weapons_addname, 0);
            guiSetProperty(weapons_addname, "SelectionLength", tostring(#serverSelectedWeaponFromCombo));
            setTimer(guiBringToFront, 50, 1, weapons_addname);
        end;
        if source == cycler_automatics then
            local serverAutomaticsModeText = guiGetText(cycler_automatics);
            serverAutomaticsModeText = ({
                Lobby = "lobby", 
                Cycle = "cycler", 
                Voting = "voting", 
                Random = "random"
            })[serverAutomaticsModeText];
            setTacticsData(serverAutomaticsModeText or "lobby", "automatics", true);
        end;
    end;
    onClientGUITabSwitched = function(serverSwitchedTab) 
        if serverSwitchedTab == admin_tab_settings and guiGridListGetSelectedItem(modes_list) == -1 then
            guiGridListSetSelectedItem(modes_list, 1, 1);
            triggerEvent("onClientGUIClick", modes_list, "left", "up");
        end;
    end;
    refreshWeaponProperties = function() 
        if not isElement(admin_window) then
            return;
        else
            triggerEvent("onClientGUIComboBoxAccepted", shooting_weapon);
            return;
        end;
    end;
    local serverMapsCache = {};
    onClientMapsUpdate = function(serverMapsDataParameter) 
        serverMapsCache = serverMapsDataParameter;
        updateAdminMaps();
    end;
    updateAdminMaps = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverDisabledMapsList = getTacticsData("map_disabled") or {};
            local serverMapSearchText = guiGetText(maps_search);
            local serverFilteredMaps = {};
            for __, serverMapEntry in ipairs(serverMapsCache) do
                local serverShouldDisplayMap = true;
                if #serverMapSearchText > 0 then
                    for serverSearchTerm in string.gmatch(serverMapSearchText, "[^ ]+") do
                        if string.sub(serverSearchTerm, 1, 1) == "-" then
                            if #serverSearchTerm > 1 then
                                serverSearchTerm = string.sub(serverSearchTerm, 2, -1);
                                if string.find(string.lower(serverMapEntry[2]), string.lower(serverSearchTerm)) or string.find(string.lower(serverMapEntry[3]), string.lower(serverSearchTerm)) then
                                    serverShouldDisplayMap = false;
                                end;
                            end;
                        elseif not string.find(string.lower(serverMapEntry[2]), string.lower(serverSearchTerm)) and not string.find(string.lower(serverMapEntry[3]), string.lower(serverSearchTerm)) then
                            serverShouldDisplayMap = false;
                        end;
                    end;
                end;
                if not guiCheckBoxGetSelected(maps_include) and (serverDisabledMapsList[tostring(serverMapEntry[1])] or getTacticsData("modes", string.lower(serverMapEntry[2]), "enable") == "false") then
                    serverShouldDisplayMap = false;
                end;
                if serverShouldDisplayMap then
                    table.insert(serverFilteredMaps, serverMapEntry);
                end;
            end;
            table.sort(serverFilteredMaps, function(serverFirstMapEntry, serverSecondMapEntry) 
                return serverFirstMapEntry[2] < serverSecondMapEntry[2] or serverFirstMapEntry[2] == serverSecondMapEntry[2] and serverFirstMapEntry[3] < serverSecondMapEntry[3];
            end);
            table.insert(serverFilteredMaps, true);
            local serverDefinedModes = {};
            for serverModeKeyName, __ in pairs(getTacticsData("modes_defined")) do
                table.insert(serverDefinedModes, {serverModeKeyName, string.upper(string.sub(serverModeKeyName, 1, 1)) .. string.sub(serverModeKeyName, 2), "Random"});
            end;
            table.sort(serverDefinedModes, function(serverFirstModeEntry, serverSecondModeEntry) 
                return serverFirstModeEntry[1] < serverSecondModeEntry[1];
            end);
            for __, serverModeDefinition in ipairs(serverDefinedModes) do
                table.insert(serverFilteredMaps, serverModeDefinition);
            end;
            local serverCurrentMapResource = getTacticsData("MapResName");
            local serverMapsGridRowCount = guiGridListGetRowCount(server_maps);
            for serverMapDisplayIndex = 1, math.max(serverMapsGridRowCount, #serverFilteredMaps) do
                if serverMapDisplayIndex <= #serverFilteredMaps then
                    local serverMapResourceID = "";
                    local serverMapModeName = "";
                    local serverMapDisplayName = "-------------";
                    local serverIsSeparator = true;
                    if type(serverFilteredMaps[serverMapDisplayIndex]) == "table" then
                        local serverMapResource, serverMapModeType, serverMapNameText = unpack(serverFilteredMaps[serverMapDisplayIndex]);
                        serverMapDisplayName = serverMapNameText;
                        serverMapModeName = serverMapModeType;
                        serverMapResourceID = serverMapResource;
                        serverIsSeparator = false;
                    end;
                    if serverMapsGridRowCount < serverMapDisplayIndex then
                        guiGridListAddRow(server_maps);
                    end;
                    guiGridListSetItemText(server_maps, serverMapDisplayIndex - 1, 1, serverMapModeName, serverIsSeparator, false);
                    guiGridListSetItemData(server_maps, serverMapDisplayIndex - 1, 1, serverMapResourceID);
                    guiGridListSetItemText(server_maps, serverMapDisplayIndex - 1, 2, serverMapDisplayName, serverIsSeparator, false);
                    if serverCurrentMapResource == serverMapResourceID then
                        if getTacticsData("modes", string.lower(serverMapModeName), "enable") == "false" then
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 1, 0, 128, 0);
                        else
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 1, 0, 255, 0);
                        end;
                        if serverDisabledMapsList[serverMapResourceID] then
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 2, 0, 128, 0);
                        else
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 2, 0, 255, 0);
                        end;
                    else
                        if getTacticsData("modes", string.lower(serverMapModeName), "enable") == "false" then
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 1, 128, 128, 128);
                        else
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 1, 255, 255, 255);
                        end;
                        if serverDisabledMapsList[serverMapResourceID] then
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 2, 128, 128, 128);
                        else
                            guiGridListSetItemColor(server_maps, serverMapDisplayIndex - 1, 2, 255, 255, 255);
                        end;
                    end;
                else
                    guiGridListRemoveRow(server_maps, #serverFilteredMaps);
                end;
            end;
            return;
        end;
    end;
    onClientTacticsChange = function(serverTacticsChangePath, serverTacticsChangeNewValue) 
        if serverTacticsChangePath[1] == "version" then
            if not isElement(admin_window) then
                return;
            else
                guiSetText(admin_window, "Tactics " .. getTacticsData("version") .. " - Gamemode Control Panel");
            end;
        end;
        if serverTacticsChangePath[1] == "ResourceCurrent" and isElement(server_cycler) then
            if not isElement(admin_window) then
                return;
            else
                for serverCyclerRow = 0, guiGridListGetRowCount(server_cycler) do
                    if getTacticsData("ResourceCurrent") == serverCyclerRow + 1 then
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 1, 255, 40, 0);
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 2, 255, 40, 0);
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 3, 255, 40, 0);
                    else
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 1, 255, 255, 255);
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 2, 255, 255, 255);
                        guiGridListSetItemColor(server_cycler, serverCyclerRow, 3, 255, 255, 255);
                    end;
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "Resources" then
            refreshCyclerResources();
        end;
        if serverTacticsChangePath[1] == "automatics" then
            if not isElement(admin_window) then
                return;
            else
                local serverAutomaticsMode = getTacticsData("automatics");
                serverAutomaticsMode = ({
                    lobby = "Lobby", 
                    cycler = "Cycle", 
                    voting = "Voting", 
                    random = "Random"
                })[serverAutomaticsMode];
                if serverAutomaticsMode then
                    guiSetText(cycler_automatics, serverAutomaticsMode);
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "disabled_vehicles" then
            refreshVehicleConfig();
        end;
        if serverTacticsChangePath[1] == "modes" or serverTacticsChangePath[1] == "settings" or serverTacticsChangePath[1] == "glitches" or serverTacticsChangePath[1] == "cheats" or serverTacticsChangePath[1] == "limites" then
            refreshSettingsConfig();
        end;
        if serverTacticsChangePath[1] == "weaponspack" or serverTacticsChangePath[1] == "weapon_balance" or serverTacticsChangePath[1] == "weapon_slot" then
            remakeAdminWeaponsPack();
        end;
        if serverTacticsChangePath[1] == "weapon_slots" then
            if not isElement(admin_window) then
                return;
            else
                local serverWeaponSlotsValue = tostring(getTacticsData("weapon_slots")) or "0";
                guiSetText(weapons_slots, serverWeaponSlotsValue);
            end;
        end;
        if serverTacticsChangePath[1] == "Weather" then
            refreshWeatherConfig();
        end;
        if serverTacticsChangePath[1] == "settings" then
            if serverTacticsChangePath[2] == "dontfire" then
                local serverDontFireSetting = getTacticsData("settings", "dontfire");
                if serverDontFireSetting == "true" then
                    bindKey("fire", "down", dontfireKey);
                    bindKey("aim_weapon", "down", dontfireKey);
                    addEventHandler("onClientPlayerDamage", localPlayer, dontfireDamage);
                elseif serverDontFireSetting == "false" then
                    unbindKey("fire", "down", dontfireKey);
                    unbindKey("aim_weapon", "down", dontfireKey);
                    removeEventHandler("onClientPlayerDamage", localPlayer, dontfireDamage);
                end;
            end;
            if serverTacticsChangePath[2] == "streetlamps" then
                local serverStreetLampModels = {1211, 1214, 1215, 1223, 1226, 1231, 1232, 1257, 1258, 1269, 1270, 1278, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1306, 1307, 1308, 1315, 1319, 1350, 1351, 1352, 1363, 1366, 1367, 1478, 1568, 3398, 3407, 3408, 3447, 3459, 3460, 3463, 3516, 3853, 3854, 3855, 3875};
                if getTacticsData("settings", "streetlamps") == "true" then
                    for __, serverLampModel in ipairs(serverStreetLampModels) do
                        restoreWorldModel(serverLampModel, 10000, 0, 0, 0);
                    end;
                else
                    for __, serverRemoveLampModel in ipairs(serverStreetLampModels) do
                        removeWorldModel(serverRemoveLampModel, 10000, 0, 0, 0);
                    end;
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "anticheat" then
            if not isElement(admin_window) then
                return;
            else
                if serverTacticsChangePath[2] == "action_detection" then
                    guiSetText(anticheat_action, ({
                        chat = "Chat message", 
                        adminchat = "Adminchat message", 
                        kick = "Kick"
                    })[getTacticsData("anticheat", "action_detection")]);
                end;
                if serverTacticsChangePath[2] == "speedhach" then
                    if getTacticsData("anticheat", "speedhach") == "true" then
                        guiSetText(anticheat_speedhack, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_speedhack, "Disable");
                    end;
                end;
                if serverTacticsChangePath[2] == "godmode" then
                    if getTacticsData("anticheat", "godmode") == "true" then
                        guiSetText(anticheat_godmode, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_godmode, "Disable");
                    end;
                end;
                if serverTacticsChangePath[2] == "mods" then
                    if getTacticsData("anticheat", "mods") == "true" then
                        guiSetText(anticheat_mods, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_mods, "Disable");
                    end;
                end;
                if serverTacticsChangePath[2] == "modslist" then
                    refreshAnticheatSearch();
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "handlings" then
            if not isElement(admin_window) then
                return;
            else
                local serverHandlingsData = getTacticsData("handlings");
                local serverCurrentHandlingModel = getVehicleModelFromName(guiGetText(handling_model));
                if serverHandlingsData[serverCurrentHandlingModel] or (serverTacticsChangeNewValue or {})[serverCurrentHandlingModel] then
                    triggerEvent("onClientGUIComboBoxAccepted", handling_model);
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "map_disabled" or serverTacticsChangePath[1] == "modes" and serverTacticsChangePath[3] == "enable" then
            updateAdminMaps();
        end;
    end;
    dontfireKey = function(serverControlStateKey, __) 
        if isElementInWater(localPlayer) then
            return;
        else
            local serverCurrentWeapon = getPedWeapon(localPlayer);
            if serverCurrentWeapon == 43 or serverCurrentWeapon == 44 or serverCurrentWeapon == 45 or serverCurrentWeapon == 46 then
                return;
            else
                setPedControlState(serverControlStateKey, false);
                return;
            end;
        end;
    end;
    dontfireDamage = function() 
        cancelEvent();
    end;
    togglePause = function(__, serverPauseReason) 
        triggerServerEvent("onPause", resourceRoot, serverPauseReason, localPlayer);
    end;
    forcePlay = function() 
        triggerServerEvent("onPlay", resourceRoot);
    end;
    remakeAdminWeaponsPack = function() 
        if not isElement(admin_window) then
            return;
        else
            local serverWeaponsPack = getTacticsData("weaponspack") or {};
            local serverWeaponBalance = getTacticsData("weapon_balance") or {};
            if not getTacticsData("weapon_cost") then
                local __ = {};
            end;
            local serverAvailableWeaponsList = {};
            for serverWeaponKey in pairs(serverWeaponsPack) do
                if serverWeaponKey ~= nil then
                    table.insert(serverAvailableWeaponsList, serverWeaponKey);
                end;
            end;
            local serverWeaponSlotPriorityMap = {
                [2] = 1, 
                [3] = 2, 
                [4] = 2, 
                [5] = 3, 
                [6] = 3
            };
            table.sort(serverAvailableWeaponsList, function(serverFirstWeaponForSort, serverSecondWeaponForSort) 
                local serverFirstWeaponSortID = convertWeaponNamesToID[serverFirstWeaponForSort] or 46;
                local serverSecondWeaponSortID = convertWeaponNamesToID[serverSecondWeaponForSort] or 46;
                local serverFirstWeaponSortSlot = getSlotFromWeapon(serverFirstWeaponSortID);
                local serverSecondWeaponSortSlot = getSlotFromWeapon(serverSecondWeaponSortID);
                local serverFirstSlotPriority = serverWeaponSlotPriorityMap[serverFirstWeaponSortSlot] or 4;
                local serverSecondSlotPriority = serverWeaponSlotPriorityMap[serverSecondWeaponSortSlot] or 4;
                return serverFirstSlotPriority == serverSecondSlotPriority and not (serverFirstWeaponSortID >= serverSecondWeaponSortID) or serverFirstSlotPriority < serverSecondSlotPriority;
            end);
            local serverWeaponGridX = 0;
            local serverWeaponGridY = 0;
            for serverWeaponItemIndex = 1, math.max(#weapons_items, #serverAvailableWeaponsList) do
                if serverWeaponItemIndex <= #serverAvailableWeaponsList then
                    local serverWeaponToDisplay = serverAvailableWeaponsList[serverWeaponItemIndex];
                    local serverWeaponClipSize = 0;
                    local serverWeaponDisplayID = convertWeaponNamesToID[serverWeaponToDisplay] or 16;
                    if serverWeaponDisplayID >= 16 and serverWeaponDisplayID <= 18 or serverWeaponDisplayID >= 22 and serverWeaponDisplayID <= 39 or serverWeaponDisplayID >= 41 and serverWeaponDisplayID <= 43 then
                        serverWeaponClipSize = tonumber(getWeaponProperty(serverWeaponDisplayID, "pro", "maximum_clip_ammo")) or 1;
                    end;
                    local serverAmmoDisplayText = math.max(0, math.floor(tonumber(serverWeaponsPack[serverWeaponToDisplay]) - serverWeaponClipSize)) .. "-" .. math.min(tonumber(serverWeaponsPack[serverWeaponToDisplay]), serverWeaponClipSize);
                    if #weapons_items < serverWeaponItemIndex then
                        local serverWeaponButton = guiCreateButton(serverWeaponGridX, serverWeaponGridY, 64, 84, "", false, weapons_scroller);
                        local serverWeaponIcon = guiCreateStaticImage(2, 5, 60, 64, "images/hud/fist.png", false, serverWeaponButton);
                        guiSetEnabled(serverWeaponIcon, false);
                        local serverAmmoLabel = guiCreateLabel(1, 60, 62, 20, serverWeaponClipSize > 1 and serverAmmoDisplayText or serverWeaponClipSize == 1 and serverWeaponsPack[serverWeaponToDisplay] or "", false, serverWeaponButton);
                        guiLabelSetHorizontalAlign(serverAmmoLabel, "center", false);
                        guiLabelSetVerticalAlign(serverAmmoLabel, "center");
                        guiSetEnabled(serverAmmoLabel, false);
                        local serverWeaponNameLabel = guiCreateLabel(1, 5, 62, 20, serverWeaponToDisplay, false, serverWeaponButton);
                        guiSetFont(serverWeaponNameLabel, "default-small");
                        guiSetEnabled(serverWeaponNameLabel, false);
                        local serverWeaponLimitLabel = guiCreateLabel(1, 5, 62, 20, serverWeaponBalance[serverWeaponToDisplay] and "x" .. serverWeaponBalance[serverWeaponToDisplay] or "", false, serverWeaponButton);
                        guiLabelSetHorizontalAlign(serverWeaponLimitLabel, "right", false);
                        guiLabelSetColor(serverWeaponLimitLabel, 255, 0, 0);
                        guiSetEnabled(serverWeaponLimitLabel, false);
                        table.insert(weapons_items, {gui = serverWeaponButton, icon = serverWeaponIcon, name = serverWeaponNameLabel, ammo = serverAmmoLabel, limit = serverWeaponLimitLabel});
                    else
                        guiSetPosition(weapons_items[serverWeaponItemIndex].gui, serverWeaponGridX, serverWeaponGridY, false);
                        guiSetText(weapons_items[serverWeaponItemIndex].ammo, serverWeaponClipSize > 1 and serverAmmoDisplayText or serverWeaponClipSize == 1 and serverWeaponsPack[serverWeaponToDisplay] or "");
                        guiSetText(weapons_items[serverWeaponItemIndex].name, serverWeaponToDisplay);
                        guiSetText(weapons_items[serverWeaponItemIndex].limit, serverWeaponBalance[serverWeaponToDisplay] and "x" .. serverWeaponBalance[serverWeaponToDisplay] or "");
                    end;
                    if fileExists("images/hud/" .. serverWeaponToDisplay .. ".png") then
                        guiStaticImageLoadImage(weapons_items[serverWeaponItemIndex].icon, "images/hud/" .. serverWeaponToDisplay .. ".png");
                    else
                        guiStaticImageLoadImage(weapons_items[serverWeaponItemIndex].icon, "images/hud/fist.png");
                    end;
                    guiSetProperty(weapons_items[serverWeaponItemIndex].gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    serverWeaponGridX = serverWeaponGridX + 66;
                    if serverWeaponGridX > 198 then
                        serverWeaponGridX = 0;
                        serverWeaponGridY = serverWeaponGridY + 86;
                    end;
                else
                    destroyElement(weapons_items[serverWeaponItemIndex].gui);
                    weapons_items[serverWeaponItemIndex] = nil;
                end;
            end;
            local serverUniqueSlotsCount = 0;
            local serverSlotColorIndex = {};
            local serverWeaponSlotConfig = getTacticsData("weapon_slot") or {};
            for __, serverWeaponGridItem in ipairs(weapons_items) do
                local serverGridWeaponName = guiGetText(serverWeaponGridItem.name);
                local serverGridWeaponID = convertWeaponNamesToID[serverGridWeaponName];
                local serverGridWeaponSlot = tonumber(serverWeaponSlotConfig[serverGridWeaponName]) or serverGridWeaponID and getSlotFromWeapon(serverGridWeaponID) or 13;
                if not serverSlotColorIndex[serverGridWeaponSlot] then
                    serverUniqueSlotsCount = serverUniqueSlotsCount + 1;
                    serverSlotColorIndex[serverGridWeaponSlot] = serverUniqueSlotsCount;
                end;
            end;
            for __, serverWeaponItemForColor in ipairs(weapons_items) do
                local serverColorWeaponName = guiGetText(serverWeaponItemForColor.name);
                local serverColorWeaponID = convertWeaponNamesToID[serverColorWeaponName];
                local serverColorWeaponSlot = tonumber(serverWeaponSlotConfig[serverColorWeaponName]) or serverColorWeaponID and getSlotFromWeapon(serverColorWeaponID) or 13;
                local serverSlotColorRGB = string.format("%02X%02X%02X", HSLtoRGB(360 * serverSlotColorIndex[serverColorWeaponSlot] / serverUniqueSlotsCount, 0.5, 0.5));
                guiSetProperty(serverWeaponItemForColor.icon, "ImageColours", "tl:FF" .. serverSlotColorRGB .. " tr:FF" .. serverSlotColorRGB .. " bl:FF" .. serverSlotColorRGB .. " br:FF" .. serverSlotColorRGB .. "");
            end;
            guiSetPosition(weapons_adding, serverWeaponGridX, serverWeaponGridY + 10, false);
            guiComboBoxClear(weapons_addnames);
            for __, serverSortedWeapon in ipairs(sortWeaponNames) do
                if not serverWeaponsPack[serverSortedWeapon] then
                    guiComboBoxAddItem(weapons_addnames, serverSortedWeapon);
                end;
            end;
            return;
        end;
    end;
    toRestoreChoise = function(serverPlayerToRestore) 
        if not isElement(restore_window) then
            createAdminRestore();
        end;
        restore_player = serverPlayerToRestore;
        guiSetText(restore_window, "Restore " .. getPlayerName(serverPlayerToRestore));
        refreshRestores();
        guiBringToFront(restore_window);
        guiSetVisible(restore_window, true);
        showCursor(true);
    end;
    RGBtoHSL = function(serverRedInput, serverGreenInput, serverBlueInput) 
        local serverRedNormalized = serverRedInput / 255;
        local serverGreenNormalized = serverGreenInput / 255;
        local serverBlueNormalized = serverBlueInput / 255;
        local serverMaxColor = math.max(serverRedNormalized, serverGreenNormalized, serverBlueNormalized);
        local serverMinColor = math.min(serverRedNormalized, serverGreenNormalized, serverBlueNormalized);
        local serverHueResult = serverMaxColor == serverMinColor and 0 or serverMaxColor == serverRedNormalized and serverBlueNormalized <= serverGreenNormalized and 60 * ((serverGreenNormalized - serverBlueNormalized) / (serverMaxColor - serverMinColor)) or serverMaxColor == serverRedNormalized and serverGreenNormalized < serverBlueNormalized and 60 * ((serverGreenNormalized - serverBlueNormalized) / (serverMaxColor - serverMinColor)) + 360 or serverMaxColor == serverGreenNormalized and 60 * ((serverBlueNormalized - serverRedNormalized) / (serverMaxColor - serverMinColor)) + 120 or serverMaxColor == serverBlueNormalized and 60 * ((serverRedNormalized - serverGreenNormalized) / (serverMaxColor - serverMinColor)) + 240 or 360;
        local serverLightnessResult = 0.5 * (serverMaxColor + serverMinColor);
        return serverHueResult, serverLightnessResult == 0 and 0 or serverMaxColor == serverMinColor and 0 or serverLightnessResult > 0 and serverLightnessResult <= 0.5 and (serverMaxColor - serverMinColor) / (2 * serverLightnessResult) or serverLightnessResult > 0.5 and serverLightnessResult < 1 and (serverMaxColor - serverMinColor) / (2 - 2 * serverLightnessResult) or 1, serverLightnessResult;
    end;
    HSLtoRGB = function(serverHueInput, serverSaturationInput, serverLightnessInput) 
        local serverTemporaryValue1 = serverLightnessInput < 0.5 and serverLightnessInput * (1 + serverSaturationInput) or serverLightnessInput + serverSaturationInput - serverLightnessInput * serverSaturationInput;
        local serverTemporaryValue2 = 2 * serverLightnessInput - serverTemporaryValue1;
        local serverHueNormalized = serverHueInput / 360;
        local serverHueRed = serverHueNormalized + 0.3333333333333333;
        local serverHueGreen = serverHueNormalized;
        local serverHueBlue = serverHueNormalized - 0.3333333333333333;
        if serverHueRed < 0 then
            serverHueRed = serverHueRed + 1;
        end;
        if serverHueGreen < 0 then
            serverHueGreen = serverHueGreen + 1;
        end;
        if serverHueBlue < 0 then
            serverHueBlue = serverHueBlue + 1;
        end;
        if serverHueRed > 1 then
            serverHueRed = serverHueRed - 1;
        end;
        if serverHueGreen > 1 then
            serverHueGreen = serverHueGreen - 1;
        end;
        if serverHueBlue > 1 then
            serverHueBlue = serverHueBlue - 1;
        end;
        local serverRedResult = serverHueRed < 0.16666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * 6 * serverHueRed or serverHueRed >= 0.16666666666666666 and serverHueRed < 0.5 and serverTemporaryValue1 or serverHueRed >= 0.5 and serverHueRed < 0.6666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * (0.6666666666666666 - serverHueRed) * 6 or serverTemporaryValue2;
        local serverGreenResult = serverHueGreen < 0.16666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * 6 * serverHueGreen or serverHueGreen >= 0.16666666666666666 and serverHueGreen < 0.5 and serverTemporaryValue1 or serverHueGreen >= 0.5 and serverHueGreen < 0.6666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * (0.6666666666666666 - serverHueGreen) * 6 or serverTemporaryValue2;
        local serverBlueResult = serverHueBlue < 0.16666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * 6 * serverHueBlue or serverHueBlue >= 0.16666666666666666 and serverHueBlue < 0.5 and serverTemporaryValue1 or serverHueBlue >= 0.5 and serverHueBlue < 0.6666666666666666 and serverTemporaryValue2 + (serverTemporaryValue1 - serverTemporaryValue2) * (0.6666666666666666 - serverHueBlue) * 6 or serverTemporaryValue2;
        return math.floor(255 * serverRedResult), math.floor(255 * serverGreenResult), (math.floor(255 * serverBlueResult));
    end;
    executeRuncode = function(__, serverTargetPlayerName, ...) 
        local serverConcatenatedCode = table.concat({
            ...
        }, " ");
        if not serverTargetPlayerName or not getPlayerFromName(serverTargetPlayerName) then
            serverConcatenatedCode = serverTargetPlayerName .. " " .. serverConcatenatedCode;
            serverTargetPlayerName = localPlayer;
        else
            serverTargetPlayerName = getPlayerFromName(serverTargetPlayerName);
        end;
        callServerFunction("executeClientRuncode", localPlayer, serverTargetPlayerName, serverConcatenatedCode);
    end;
    stopRuncode = function(__, serverStopTargetPlayer) 
        if not serverStopTargetPlayer or not getPlayerFromName(serverStopTargetPlayer) then
            serverStopTargetPlayer = localPlayer;
        else
            serverStopTargetPlayer = getPlayerFromName(serverStopTargetPlayer);
        end;
        callServerFunction("stopClientRuncode", localPlayer, serverStopTargetPlayer);
    end;
    local serverRuncodeEnvironments = {};
    local serverEventHandlerContainers = {};
    local serverKeyBindContainers = {};
    local serverCommandHandlerContainers = {};
    local serverTimerContainers = {};
    createAddEventHandlerFunction = function(serverContainerID) 
        return function(serverEventName, serverEventElement, serverEventHandler, serverEventPropagated) 
            if type(serverEventName) == "string" and isElement(serverEventElement) and type(serverEventHandler) == "function" then
                if serverEventPropagated == nil or type(serverEventPropagated) ~= "boolean" then
                    serverEventPropagated = true;
                end;
                if addEventHandler(serverEventName, serverEventElement, serverEventHandler, serverEventPropagated) then
                    table.insert(serverEventHandlerContainers[serverContainerID], {serverEventName, serverEventElement, serverEventHandler});
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createBindKeyFunction = function(serverBindContainerID) 
        return function(...) 
            local serverBindArguments = {
                ...
            };
            local serverBindKeyName = table.remove(serverBindArguments, 1);
            local serverBindKeyState = table.remove(serverBindArguments, 1);
            local serverBindHandler = table.remove(serverBindArguments, 1);
            local serverBindExtraArgs = serverBindArguments;
            if type(serverBindKeyName) ~= "string" or type(serverBindKeyState) ~= "string" or type(serverBindHandler) ~= "string" and type(serverBindHandler) ~= "function" then
                return false;
            else
                serverBindArguments = {serverBindKeyName, serverBindKeyState, serverBindHandler, unpack(serverBindExtraArgs)};
                if bindKey(unpack(serverBindArguments)) then
                    table.insert(serverKeyBindContainers[serverBindContainerID], serverBindArguments);
                    return true;
                else
                    return false;
                end;
            end;
        end;
    end;
    createAddCommandHandlerFunction = function(serverCommandContainerID) 
        return function(serverCommandName, serverCommandHandler, serverCommandCaseSensitive, __) 
            if type(serverCommandName) == "string" and type(serverCommandHandler) == "function" then
                local serverCommandArgs = nil;
                serverCommandArgs = {
                    serverCommandName, 
                    serverCommandHandler, 
                    type(serverCommandCaseSensitive) ~= "boolean" or serverCommandCaseSensitive
                };
                if addCommandHandler(unpack(serverCommandArgs)) then
                    table.insert(serverCommandHandlerContainers[serverCommandContainerID], serverCommandArgs);
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createSetTimerFunction = function(serverTimerContainerID) 
        return function(serverTimerFunction, serverTimerInterval, serverTimerRepeats, ...) 
            if type(serverTimerFunction) == "function" and type(serverTimerInterval) == "number" and type(serverTimerRepeats) == "number" then
                local serverTimerReference = setTimer(serverTimerFunction, serverTimerInterval, serverTimerRepeats, ...);
                if serverTimerReference then
                    table.insert(serverTimerContainers[serverTimerContainerID], serverTimerReference);
                    return serverTimerReference;
                end;
            end;
            return false;
        end;
    end;
    createRemoveEventHandlerFunction = function(serverRemoveEventContainerID) 
        return function(serverRemoveEventName, serverRemoveEventElement, serverRemoveEventHandler) 
            if type(serverRemoveEventName) == "string" and isElement(serverRemoveEventElement) and type(serverRemoveEventHandler) == "function" then
                for serverEventIndex, serverEventData in ipairs(serverEventHandlerContainers[serverRemoveEventContainerID]) do
                    if serverEventData[1] == serverRemoveEventName and serverEventData[2] == serverRemoveEventElement and serverEventData[3] == serverRemoveEventHandler and removeEventHandler(unpack(serverEventData)) then
                        table.remove(serverEventHandlerContainers[serverRemoveEventContainerID], serverEventIndex);
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    createUnbindKeyFunction = function(serverUnbindContainerID) 
        return function(...) 
            local serverUnbindArguments = {
                ...
            };
            local serverUnbindKeyName = table.remove(serverUnbindArguments, 1);
            local serverUnbindKeyState = table.remove(serverUnbindArguments, 1);
            local serverUnbindHandler = table.remove(serverUnbindArguments, 1);
            if type(serverUnbindKeyName) ~= "string" then
                return false;
            else
                if type(serverUnbindKeyState) ~= "string" or not serverUnbindKeyState then
                    serverUnbindKeyState = nil;
                end;
                if type(serverUnbindHandler) ~= "string" and type(serverUnbindHandler) ~= "function" or not serverUnbindHandler then
                    serverUnbindHandler = nil;
                end;
                serverUnbindArguments = {
                    serverUnbindKeyName, 
                    serverUnbindKeyState, 
                    serverUnbindHandler
                };
                local serverUnbindSuccess = false;
                for serverUnbindIndex, serverUnbindData in ipairs(serverKeyBindContainers[serverUnbindContainerID]) do
                    if serverUnbindData[1] == serverUnbindArguments[1] and (not serverUnbindArguments[2] or serverUnbindArguments[2] == serverUnbindData[2]) and (not serverUnbindArguments[3] or serverUnbindArguments[3] == serverUnbindData[3]) and unbindKey(unpack(serverUnbindData)) then
                        table.remove(serverKeyBindContainers[serverUnbindContainerID], serverUnbindIndex);
                        serverUnbindSuccess = true;
                    end;
                end;
                return serverUnbindSuccess;
            end;
        end;
    end;
    createRemoveCommandHandlerFunction = function(serverRemoveCommandContainerID) 
        return function(serverRemoveCommandName, serverRemoveCommandHandler) 
            local serverRemoveSuccess = false;
            if type(serverRemoveCommandName) == "string" and type(serverRemoveCommandHandler) == "function" then
                for serverCommandIndex, serverCommandData in ipairs(serverCommandHandlerContainers[serverRemoveCommandContainerID]) do
                    if serverCommandData[1] == serverRemoveCommandName and (not serverCommandData[2] or serverCommandData[2] == serverRemoveCommandHandler) and removeCommandHandler(unpack(serverCommandData)) then
                        table.remove(serverCommandHandlerContainers[serverRemoveCommandContainerID], serverCommandIndex);
                        serverRemoveSuccess = true;
                    end;
                end;
            end;
            return serverRemoveSuccess;
        end;
    end;
    createKillTimerFunction = function(serverKillTimerContainerID) 
        return function(serverTimerToKill) 
            local serverKillSuccess = false;
            for serverTimerIndex, serverTimerData in ipairs(serverTimerContainers[serverKillTimerContainerID]) do
                if serverTimerData == serverTimerToKill and killTimer(serverTimerToKill) then
                    table.remove(serverTimerContainers[serverKillTimerContainerID], serverTimerIndex);
                    serverKillSuccess = true;
                end;
            end;
            return serverKillSuccess;
        end;
    end;
    cleanEventHandlerContainer = function(serverCleanEventContainerID) 
        if not serverEventHandlerContainers[serverCleanEventContainerID] then
            return;
        else
            for __, serverEventToClean in ipairs(serverEventHandlerContainers[serverCleanEventContainerID]) do
                if isElement(serverEventToClean[2]) then
                    removeEventHandler(unpack(serverEventToClean));
                end;
            end;
            serverEventHandlerContainers[serverCleanEventContainerID] = nil;
            return;
        end;
    end;
    cleanKeyBindContainer = function(serverCleanKeyContainerID) 
        if not serverKeyBindContainers[serverCleanKeyContainerID] then
            return;
        else
            for __, serverKeyBindToClean in ipairs(serverKeyBindContainers[serverCleanKeyContainerID]) do
                unbindKey(unpack(serverKeyBindToClean));
            end;
            serverKeyBindContainers[serverCleanKeyContainerID] = nil;
            return;
        end;
    end;
    cleanCommandHandlerContainer = function(serverCleanCommandContainerID) 
        if not serverCommandHandlerContainers[serverCleanCommandContainerID] then
            return;
        else
            for __, serverCommandToClean in ipairs(serverCommandHandlerContainers[serverCleanCommandContainerID]) do
                removeCommandHandler(unpack(serverCommandToClean));
            end;
            serverCommandHandlerContainers[serverCleanCommandContainerID] = nil;
            return;
        end;
    end;
    cleanTimerContainer = function(serverCleanTimerContainerID) 
        if not serverTimerContainers[serverCleanTimerContainerID] then
            return;
        else
            for __, serverTimerToClean in ipairs(serverTimerContainers[serverCleanTimerContainerID]) do
                if isTimer(serverTimerToClean) then
                    killTimer(serverTimerToClean);
                end;
            end;
            serverTimerContainers[serverCleanTimerContainerID] = nil;
            return;
        end;
    end;
    stopClientRuncode = function(serverStopRuncodePlayer) 
        if not serverRuncodeEnvironments[serverStopRuncodePlayer] then
            callServerFunction("outputChatBox", "Not running!", serverStopRuncodePlayer, 0, 128, 0, true);
            return;
        else
            cleanEventHandlerContainer(serverStopRuncodePlayer);
            cleanKeyBindContainer(serverStopRuncodePlayer);
            cleanCommandHandlerContainer(serverStopRuncodePlayer);
            cleanTimerContainer(serverStopRuncodePlayer);
            serverRuncodeEnvironments[serverStopRuncodePlayer] = nil;
            callServerFunction("outputChatBox", "Stopped!", serverStopRuncodePlayer, 0, 128, 0, true);
            return;
        end;
    end;
    executeClientRuncode = function(serverExecuteRuncodePlayer, serverExecuteRuncodeScript) 
        if not serverEventHandlerContainers[serverExecuteRuncodePlayer] then
            serverEventHandlerContainers[serverExecuteRuncodePlayer] = {};
        end;
        if not serverKeyBindContainers[serverExecuteRuncodePlayer] then
            serverKeyBindContainers[serverExecuteRuncodePlayer] = {};
        end;
        if not serverCommandHandlerContainers[serverExecuteRuncodePlayer] then
            serverCommandHandlerContainers[serverExecuteRuncodePlayer] = {};
        end;
        if not serverTimerContainers[serverExecuteRuncodePlayer] then
            serverTimerContainers[serverExecuteRuncodePlayer] = {};
        end;
        if not serverRuncodeEnvironments[serverExecuteRuncodePlayer] then
            serverRuncodeEnvironments[serverExecuteRuncodePlayer] = {
                addEventHandler = createAddEventHandlerFunction(serverExecuteRuncodePlayer), 
                removeEventHandler = createRemoveEventHandlerFunction(serverExecuteRuncodePlayer), 
                bindKey = createBindKeyFunction(serverExecuteRuncodePlayer), 
                unbindKey = createUnbindKeyFunction(serverExecuteRuncodePlayer), 
                addCommandHandler = createAddCommandHandlerFunction(serverExecuteRuncodePlayer), 
                removeCommandHandler = createRemoveCommandHandlerFunction(serverExecuteRuncodePlayer), 
                setTimer = createSetTimerFunction(serverExecuteRuncodePlayer), 
                killTimer = createKillTimerFunction(serverExecuteRuncodePlayer)
            };
            setmetatable(serverRuncodeEnvironments[serverExecuteRuncodePlayer], {
                __index = _G
            });
        end;
        local serverIsStatement = false;
        local serverCompiledFunction, serverCompileError = loadstring("return " .. serverExecuteRuncodeScript);
        if serverCompileError then
            serverIsStatement = true;
            local serverRecompiledFunction, serverRecompileError = loadstring(tostring(serverExecuteRuncodeScript));
            serverCompileError = serverRecompileError;
            serverCompiledFunction = serverRecompiledFunction;
        end;
        if serverCompileError then
            callServerFunction("outputChatBox", "ERROR: " .. serverCompileError, serverExecuteRuncodePlayer, 255, 0, 0, true);
            return;
        else
            serverCompiledFunction = setfenv(serverCompiledFunction, serverRuncodeEnvironments[serverExecuteRuncodePlayer]);
            local serverExecutionResults = {
                pcall(serverCompiledFunction)
            };
            if not serverExecutionResults[1] then
                callServerFunction("outputChatBox", "ERROR: " .. serverExecutionResults[2], serverExecuteRuncodePlayer, 255, 0, 0, true);
                return;
            else
                if not serverIsStatement then
                    local serverResultString = "";
                    for serverResultIndex = 2, #serverExecutionResults do
                        local serverFormattedResult = "";
                        if serverResultIndex > 2 then
                            serverResultString = serverResultString .. "#00FF00, ";
                        end;
                        local serverResultValue = serverExecutionResults[serverResultIndex];
                        if type(serverResultValue) == "table" then
                            for serverTableKey, __ in pairs(serverResultValue) do
                                if #serverFormattedResult > 0 then
                                    serverFormattedResult = serverFormattedResult .. ", ";
                                end;
                                if type(serverTableKey) == "userdata" then
                                    if isElement(serverTableKey) then
                                        serverFormattedResult = serverFormattedResult .. "#66CC66" .. getElementType(serverResultValue) .. "#B1B100";
                                    else
                                        serverFormattedResult = serverFormattedResult .. "#66CC66element#B1B100";
                                    end;
                                elseif type(serverTableKey) == "string" then
                                    serverFormattedResult = serverFormattedResult .. "#FF0000\"" .. serverTableKey .. "\"#B1B100";
                                else
                                    serverFormattedResult = serverFormattedResult .. "#000099" .. tostring(serverTableKey) .. "#B1B100";
                                end;
                            end;
                            serverFormattedResult = "#B1B100{" .. serverFormattedResult .. "}";
                        elseif type(serverResultValue) == "userdata" then
                            if isElement(serverResultValue) then
                                serverFormattedResult = "#66CC66" .. getElementType(serverResultValue) .. string.gsub(tostring(serverResultValue), "userdata:", "");
                            else
                                serverFormattedResult = "#66CC66element" .. string.gsub(tostring(serverResultValue), "userdata:", "");
                            end;
                        elseif type(serverResultValue) == "string" then
                            serverFormattedResult = "#FF0000\"" .. serverResultValue .. "\"";
                        elseif type(serverResultValue) == "function" then
                            serverFormattedResult = "#0000FF" .. tostring(serverResultValue);
                        elseif type(serverResultValue) == "thread" then
                            serverFormattedResult = "#808080" .. tostring(serverResultValue);
                        else
                            serverFormattedResult = "#000099" .. tostring(serverResultValue);
                        end;
                        serverResultString = serverResultString .. serverFormattedResult;
                    end;
                    serverResultString = "Return: " .. serverResultString;
                    callServerFunction("outputChatBox", string.sub(serverResultString, 1, 128), serverExecuteRuncodePlayer, 0, 255, 0, true);
                elseif not serverCompileError then
                    callServerFunction("outputChatBox", "Executed!", serverExecuteRuncodePlayer, 0, 128, 0, true);
                end;
                return;
            end;
        end;
    end;
    addEvent("onExecuteClientRuncode", true);
    addEventHandler("onExecuteClientRuncode", root, executeClientRuncode);
    local serverScreenSource = nil;
    takeDisabledScreenShot = function(serverScreenshotParameters) 
        local __, serverScreenWidth, serverScreenHeight = unpack(split(serverScreenshotParameters, " "));
        serverScreenSource = dxCreateScreenSource(tonumber(serverScreenWidth), tonumber(serverScreenHeight));
        if not serverScreenSource then
            return;
        else
            setElementData(serverScreenSource, "ScreenData", serverScreenshotParameters, false);
            addEventHandler("onClientRender", root, onClientRenderDisabledScreenShot);
            return;
        end;
    end;
    onClientRenderDisabledScreenShot = function() 
        dxUpdateScreenSource(serverScreenSource);
        local serverScreenPixels = dxGetTexturePixels(serverScreenSource);
        if serverScreenPixels then
            outputDebugString("1 = " .. #serverScreenPixels);
            local serverScreenDataString = getElementData(serverScreenSource, "ScreenData");
            local __, __, __, serverScreenshotQuality = unpack(split(serverScreenDataString, " "));
            serverScreenPixels = dxConvertPixels(serverScreenPixels, "jpeg", tonumber(serverScreenshotQuality));
            triggerLatentServerEvent("onPlayerDisabledScreenShot", localPlayer, "disabled", "ok", serverScreenPixels, getRealTime().timestamp, serverScreenDataString);
        end;
        destroyElement(serverScreenSource);
        serverScreenSource = nil;
        removeEventHandler("onClientRender", root, onClientRenderDisabledScreenShot);
    end;
    onClientPlayerScreenShot = function(serverScreenshotStatus, serverScreenshotData, serverScreenshotWidthParam, serverScreenshotHeightParam, serverScreenshotFilenameParam) 
        if isTimer(screenTimeout) then
            killTimer(screenTimeout);
        end;
        if isElement(admin_window) then
            guiSetEnabled(player_takescreen, true);
            guiSetEnabled(player_takescreencombobox, true);
        end;
        if serverScreenshotStatus == "disabled" then
            outputLangString("screen_disabled");
            return;
        elseif serverScreenshotStatus == "minimized" then
            outputLangString("screen_minimized");
            return;
        else
            local serverScreenshotFile = fileCreate("screenshots/_screen.jpg");
            if not serverScreenshotFile then
                return;
            else
                fileWrite(serverScreenshotFile, serverScreenshotData);
                fileClose(serverScreenshotFile);
                local serverWindowWidth = serverScreenshotWidthParam + 20;
                local serverWindowHeight = serverScreenshotHeightParam + 53;
                if serverScreenshotWidthParam + 20 > xscreen then
                    local serverAdjustedWidth = xscreen;
                    serverWindowHeight = xscreen * 0.75 + 15;
                    serverWindowWidth = serverAdjustedWidth;
                end;
                if serverScreenshotHeightParam + 53 > yscreen then
                    local serverAdjustedHeight = yscreen / 0.75 - 15;
                    serverWindowHeight = yscreen;
                    serverWindowWidth = serverAdjustedHeight;
                end;
                if not isElement(screen_window) then
                    createAdminScreen();
                end;
                guiBringToFront(screen_window);
                guiSetPosition(screen_window, xscreen * 0.5 - serverWindowWidth * 0.5, yscreen * 0.5 - serverWindowHeight * 0.5, false);
                guiSetSize(screen_window, serverWindowWidth, serverWindowHeight, false);
                guiSetSize(screen_image, serverWindowWidth - 20, serverWindowHeight - 53, false);
                guiStaticImageLoadImage(screen_image, "screenshots/_screen.jpg");
                guiSetAlpha(screen_menu, 0.2);
                guiSetText(screen_name, serverScreenshotFilenameParam);
                guiSetVisible(screen_list, false);
                guiSetVisible(screen_name, true);
                guiSetVisible(screen_save, true);
                guiBringToFront(screen_window);
                guiSetVisible(screen_window, true);
                showCursor(true);
                return;
            end;
        end;
    end;
    loadScreenShot = function(serverScreenshotToLoad) 
        if not fileExists("screenshots/" .. serverScreenshotToLoad .. ".jpg") then
            return;
        else
            local serverLoadedScreenshotData = "";
            local serverScreenshotFileHandle = fileOpen("screenshots/" .. serverScreenshotToLoad .. ".jpg", true);
            while not fileIsEOF(serverScreenshotFileHandle) do
                serverLoadedScreenshotData = serverLoadedScreenshotData .. fileRead(serverScreenshotFileHandle, 500);
            end;
            fileClose(serverScreenshotFileHandle);
            local serverImageWidth, serverImageHeight = dxGetPixelsSize(serverLoadedScreenshotData);
            local serverLoadWindowWidth = serverImageWidth + 20;
            local serverLoadWindowHeight = serverImageHeight + 35;
            if serverImageWidth + 20 > xscreen then
                local serverLoadAdjustedWidth = xscreen;
                serverLoadWindowHeight = xscreen * 0.75 + 15;
                serverLoadWindowWidth = serverLoadAdjustedWidth;
            end;
            if serverImageHeight + 35 > yscreen then
                local serverLoadAdjustedHeight = yscreen / 0.75 - 15;
                serverLoadWindowHeight = yscreen;
                serverLoadWindowWidth = serverLoadAdjustedHeight;
            end;
            if not isElement(screen_window) then
                createAdminScreen();
            end;
            guiSetPosition(screen_window, xscreen * 0.5 - serverLoadWindowWidth * 0.5, yscreen * 0.5 - serverLoadWindowHeight * 0.5, false);
            guiSetSize(screen_window, serverLoadWindowWidth, serverLoadWindowHeight, false);
            guiSetSize(screen_image, serverLoadWindowWidth - 20, serverLoadWindowHeight - 35, false);
            guiStaticImageLoadImage(screen_image, "screenshots/" .. serverScreenshotToLoad .. ".jpg");
            guiSetAlpha(screen_menu, 0.2);
            guiSetText(screen_name, serverScreenshotToLoad);
            guiSetVisible(screen_name, false);
            guiSetVisible(screen_save, false);
            guiSetVisible(screen_list, true);
            guiBringToFront(screen_window);
            guiSetVisible(screen_window, true);
            setTimer(guiBringToFront, 50, 1, screen_window);
            return;
        end;
    end;
    onClientMouseEnter = function(__, __) 
        if source == screen_image then
            guiSetAlpha(screen_menu, 0.2);
        end;
        if source == screen_menu or source == screen_name or source == screen_save or source == screen_list then
            guiSetAlpha(screen_menu, 1);
        end;
    end;
    onClientMouseLeave = function(__, __) 
        if source == screen_image then
            guiSetAlpha(screen_menu, 1);
        end;
    end;
    toggleGangDriveby = function() 
        if getTacticsData("settings", "player_can_driveby") ~= "true" then
            return;
        else
            if getPedWeaponSlot(localPlayer) == 0 then
                switchGangDrivebyWeapon();
            end;
            callServerFunction("toggleGangDriveby", localPlayer);
            return;
        end;
    end;
    switchGangDrivebyWeapon = function(serverSwitchDirection) 
        if getTacticsData("settings", "player_can_driveby") ~= "true" then
            return;
        elseif not isPedDoingGangDriveby(localPlayer) and serverSwitchDirection then
            return;
        else
            local __ = {};
            local serverAvailableWeaponSlots = {};
            local serverCurrentSlotIndex = -1;
            for serverSlotCheck = 0, 12 do
                if getPedWeapon(localPlayer, serverSlotCheck) > 0 then
                    if serverSlotCheck == getPedWeaponSlot(localPlayer) then
                        serverCurrentSlotIndex = #serverAvailableWeaponSlots;
                    end;
                    table.insert(serverAvailableWeaponSlots, serverSlotCheck);
                end;
            end;
            if #serverAvailableWeaponSlots < 1 then
                return;
            else
                if serverSwitchDirection == "vehicle_look_left" or not serverSwitchDirection then
                    serverCurrentSlotIndex = (serverCurrentSlotIndex + 1) % #serverAvailableWeaponSlots;
                elseif serverSwitchDirection == "vehicle_look_right" then
                    serverCurrentSlotIndex = (serverCurrentSlotIndex - 1) % #serverAvailableWeaponSlots;
                end;
                setPedWeaponSlot(localPlayer, serverAvailableWeaponSlots[serverCurrentSlotIndex + 1]);
                return;
            end;
        end;
    end;
    onClientVehicleExit = function(serverExitingPlayer) 
        if serverExitingPlayer == localPlayer and isPedDoingGangDriveby(localPlayer) then
            setPedDoingGangDriveby(localPlayer, false);
        end;
    end;
    onClientPauseToggle = function(serverPauseState) 
        if not isElement(admin_window) then
            return;
        else
            if not serverPauseState then
                guiSetText(player_pause, "Pause");
                guiSetProperty(player_pause, "NormalTextColour", "C0FF8000");
            else
                guiSetText(player_pause, "Unpause");
                guiSetProperty(player_pause, "NormalTextColour", "C00080FF");
            end;
            return;
        end;
    end;
    onClientMapStarting = function() 
        updateAdminMaps();
        if isElement(admin_window) then
            guiSetText(player_pause, "Pause");
            guiSetProperty(player_pause, "NormalTextColour", "C0FF8000");
        end;
    end;
    addEvent("onClientMapsUpdate", true);
    addEvent("onPaletteSetColor");
    addEvent("onClientPlayerScreenShot", true);
    addEvent("takeDisabledScreenShot", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientGUIClick", root, onClientGUIClick);
    addEventHandler("onClientGUIChanged", root, onClientGUIChanged);
    addEventHandler("onClientGUIAccepted", root, onClientGUIAccepted);
    addEventHandler("onClientGUIScroll", root, onClientGUIScroll);
    addEventHandler("onClientGUIMouseUp", root, onClientGUIMouseUp);
    addEventHandler("onClientGUIMouseDown", root, onClientGUIMouseDown);
    addEventHandler("onClientGUIFocus", root, onClientGUIFocus);
    addEventHandler("onClientCursorMove", root, onClientCursorMove);
    addEventHandler("onClientGUIDoubleClick", root, onClientGUIDoubleClick);
    addEventHandler("onClientGUIComboBoxAccepted", root, onClientGUIComboBoxAccepted);
    addEventHandler("onClientGUITabSwitched", root, onClientGUITabSwitched);
    addEventHandler("onClientMouseEnter", root, onClientMouseEnter);
    addEventHandler("onClientMouseLeave", root, onClientMouseLeave);
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
    addEventHandler("onClientMapsUpdate", root, onClientMapsUpdate);
    addEventHandler("onPaletteSetColor", root, onPaletteSetColor);
    addEventHandler("onClientPlayerScreenShot", root, onClientPlayerScreenShot);
    addEventHandler("takeDisabledScreenShot", root, takeDisabledScreenShot);
    addEventHandler("onClientMapStarting", root, onClientMapStarting);
    addEventHandler("onClientVehicleStartExit", root, onClientVehicleExit);
    addEventHandler("onClientVehicleExit", root, onClientVehicleExit);
    addEventHandler("onClientPauseToggle", root, onClientPauseToggle);
    addCommandHandler("play", forcePlay, false);
    addCommandHandler("pause", togglePause, false);
    addCommandHandler("control_panel", toggleAdmin, false);
    addCommandHandler("cexe", executeRuncode, false);
    addCommandHandler("cexestop", stopRuncode, false);
end)();
(function(...) 
    local serverSpeedhackTimer = nil;
    local serverLastSecondCheck = 0;
    local serverGodmodeAttackers = {};
    local worldSpecialProperties = {
        hovercars = true, 
        aircars = true, 
        extrabunny = true, 
        extrajump = true, 
        knockoffbike = true
    };
    onClientTacticsChange = function(serverTacticsChangePath, __) 
        if (not worldSpecialProperties[property]) then return false end
        if serverTacticsChangePath[1] == "cheats" then
            local serverCheatsData = getTacticsData("cheats");
            if worldSpecialProperties[serverTacticsChangePath[2]] then
                setWorldSpecialPropertyEnabled(serverTacticsChangePath[2], serverCheatsData[serverTacticsChangePath[2]] == "true");
            end;
            if serverTacticsChangePath[2] == "magnetcars" then
                if serverCheatsData.magnetcars == "true" then
                    addEventHandler("onClientPreRender", root, magnetcars_onClientPreRender);
                    addEventHandler("onClientPlayerVehicleExit", localPlayer, magnetcars_onClientPlayerVehicleExit);
                else
                    removeEventHandler("onClientPreRender", root, magnetcars_onClientPreRender);
                    removeEventHandler("onClientPlayerVehicleExit", localPlayer, magnetcars_onClientPlayerVehicleExit);
                    local serverPlayerVehicle = getPedOccupiedVehicle(localPlayer);
                    if serverPlayerVehicle then
                        setVehicleGravity(serverPlayerVehicle, 0, 0, -1);
                    end;
                end;
            end;
        end;
        if serverTacticsChangePath[1] == "anticheat" then
            local serverAnticheatData = getTacticsData("anticheat");
            if serverTacticsChangePath[2] == "speedhack" then
                if serverAnticheatData.speedhack == "true" then
                    serverLastSecondCheck = getRealTime().second;
                    serverSpeedhackTimer = setTimer(checkSH, 60000, 0);
                elseif isTimer(serverSpeedhackTimer) then
                    killTimer(serverSpeedhackTimer);
                end;
            end;
            if serverTacticsChangePath[2] == "godmode" then
                if serverAnticheatData.godmode == "true" then
                    addEventHandler("onClientPlayerWeaponFire", root, godmode_onClientPlayerWeaponFire);
                    addEventHandler("onClientPlayerDamage", localPlayer, godmode_onClientPlayerDamage);
                else
                    removeEventHandler("onClientPlayerWeaponFire", root, godmode_onClientPlayerWeaponFire);
                    removeEventHandler("onClientPlayerDamage", localPlayer, godmode_onClientPlayerDamage);
                end;
            end;
        end;
    end;
    walkwater_onClientRender = function() 
        local serverPlayerX, serverPlayerY, serverPlayerZ = getElementPosition(localPlayer);
        local serverWaterLevel = getWaterLevel(serverPlayerX, serverPlayerY, serverPlayerZ, true);
        if serverWaterLevel then
            if serverPlayerZ - 0.5 < serverWaterLevel then
                setElementPosition(localPlayer, serverPlayerX, serverPlayerY, serverWaterLevel + 0.5, false);
            end;
            if not isElement(solidwater) then
                solidwater = createObject(8171, getElementPosition(localPlayer));
                setElementAlpha(solidwater, 0);
            end;
            local serverSolidwaterX = 10 * math.floor(serverPlayerX / 10);
            serverPlayerY = 10 * math.floor(serverPlayerY / 10);
            serverPlayerX = serverSolidwaterX;
            local serverSolidwaterY;
            serverSolidwaterX, serverSolidwaterY = getElementPosition(solidwater);
            setElementPosition(solidwater, serverSolidwaterX, serverSolidwaterY, serverWaterLevel - 0.1);
            if serverSolidwaterX ~= serverPlayerX or serverSolidwaterY ~= serverPlayerY then
                destroyElement(solidwater);
                solidwater = createObject(8171, serverPlayerX, serverPlayerY, serverWaterLevel - 0.1);
                setElementAlpha(solidwater, 0);
            end;
            setElementInterior(solidwater, getCameraInterior() + 1);
        elseif isElement(solidwater) then
            destroyElement(solidwater);
        end;
    end;
    magnetcars_onClientPreRender = function() 
        local serverOccupiedVehicle = getPedOccupiedVehicle(localPlayer);
        if not serverOccupiedVehicle then
            return;
        else
            local serverVehicleType = getVehicleType(serverOccupiedVehicle);
            if serverVehicleType ~= "Automobile" and serverVehicleType ~= "Bike" and serverVehicleType ~= "BMX" and serverVehicleType ~= "Monster Truck" and serverVehicleType ~= "Quad" then
                return;
            else
                local serverVehicleX, serverVehicleY, serverVehicleZ = getElementPosition(serverOccupiedVehicle);
                local serverGravityX, serverGravityY, serverGravityZ = getVehicleGravity(serverOccupiedVehicle);
                local serverForwardVector = getElementVector(serverOccupiedVehicle, 0, 1, 0, true);
                local serverUpVector = getElementVector(serverOccupiedVehicle, 0, 0, 1, true);
                local serverRightVector = getElementVector(serverOccupiedVehicle, 1, 0, 0, true);
                local serverRaycastDistance = 50;
                local __, serverHitXForward, serverHitYForward, serverHitZForward, __, serverNormalXForward, serverNormalYForward, serverNormalZForward = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX + serverRaycastDistance * serverForwardVector[1], serverVehicleY + serverRaycastDistance * serverForwardVector[2], serverVehicleZ + serverRaycastDistance * serverForwardVector[3], true, false, false);
                local serverDistanceForward = serverHitXForward and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXForward, serverHitYForward, serverHitZForward) or 100500;
                local __, serverHitXBackward, serverHitYBackward, serverHitZBackward, __, serverNormalXBackward, serverNormalYBackward, serverNormalZBackward = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX - serverRaycastDistance * serverForwardVector[1], serverVehicleY - serverRaycastDistance * serverForwardVector[2], serverVehicleZ - serverRaycastDistance * serverForwardVector[3], true, false, false);
                local serverDistanceBackward = serverHitXBackward and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXBackward, serverHitYBackward, serverHitZBackward) or 100500;
                local __, serverHitXUp, serverHitYUp, serverHitZUp, __, serverNormalXUp, serverNormalYUp, serverNormalZUp = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX + serverRaycastDistance * serverUpVector[1], serverVehicleY + serverRaycastDistance * serverUpVector[2], serverVehicleZ + serverRaycastDistance * serverUpVector[3], true, false, false);
                local serverDistanceUp = serverHitXUp and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXUp, serverHitYUp, serverHitZUp) or 100500;
                local __, serverHitXDown, serverHitYDown, serverHitZDown, __, serverNormalXDown, serverNormalYDown, serverNormalZDown = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX - serverRaycastDistance * serverUpVector[1], serverVehicleY - serverRaycastDistance * serverUpVector[2], serverVehicleZ - serverRaycastDistance * serverUpVector[3], true, false, false);
                local serverDistanceDown = serverHitXDown and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXDown, serverHitYDown, serverHitZDown) or 100500;
                local __, serverHitXRight, serverHitYRight, serverHitZRight, __, serverNormalXRight, serverNormalYRight, serverNormalZRight = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX + serverRaycastDistance * serverRightVector[1], serverVehicleY + serverRaycastDistance * serverRightVector[2], serverVehicleZ + serverRaycastDistance * serverRightVector[3], true, false, false);
                local serverDistanceRight = serverHitXRight and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXRight, serverHitYRight, serverHitZRight) or 100500;
                local __, serverHitXLeft, serverHitYLeft, serverHitZLeft, __, serverNormalXLeft, serverNormalYLeft, serverNormalZLeft = processLineOfSight(serverVehicleX, serverVehicleY, serverVehicleZ, serverVehicleX - serverRaycastDistance * serverRightVector[1], serverVehicleY - serverRaycastDistance * serverRightVector[2], serverVehicleZ - serverRaycastDistance * serverRightVector[3], true, false, false);
                local serverDistanceLeft = serverHitXLeft and getDistanceBetweenPoints3D(serverVehicleX, serverVehicleY, serverVehicleZ, serverHitXLeft, serverHitYLeft, serverHitZLeft) or 100500;
                local serverMinDistance = math.min(serverDistanceForward, serverDistanceBackward, serverDistanceUp, serverDistanceDown, serverDistanceRight, serverDistanceLeft);
                if serverMinDistance < serverRaycastDistance then
                    local serverTargetGravityX = 0;
                    local serverTargetGravityY = 0;
                    local serverTargetGravityZ = -1;
                    if serverMinDistance == serverDistanceForward and serverHitXForward then
                        local serverNormXForward = -serverNormalXForward;
                        local serverNormYForward = -serverNormalYForward;
                        serverTargetGravityZ = -serverNormalZForward;
                        serverTargetGravityY = serverNormYForward;
                        serverTargetGravityX = serverNormXForward;
                    end;
                    if serverMinDistance == serverDistanceBackward and serverHitXBackward then
                        local serverNormXBackward = -serverNormalXBackward;
                        local serverNormYBackward = -serverNormalYBackward;
                        serverTargetGravityZ = -serverNormalZBackward;
                        serverTargetGravityY = serverNormYBackward;
                        serverTargetGravityX = serverNormXBackward;
                    end;
                    if serverMinDistance == serverDistanceUp and serverHitXUp then
                        local serverNormXUp = -serverNormalXUp;
                        local serverNormYUp = -serverNormalYUp;
                        serverTargetGravityZ = -serverNormalZUp;
                        serverTargetGravityY = serverNormYUp;
                        serverTargetGravityX = serverNormXUp;
                    end;
                    if serverMinDistance == serverDistanceDown and serverHitXDown then
                        local serverNormXDown = -serverNormalXDown;
                        local serverNormYDown = -serverNormalYDown;
                        serverTargetGravityZ = -serverNormalZDown;
                        serverTargetGravityY = serverNormYDown;
                        serverTargetGravityX = serverNormXDown;
                    end;
                    if serverMinDistance == serverDistanceRight and serverHitXRight then
                        local serverNormXRight = -serverNormalXRight;
                        local serverNormYRight = -serverNormalYRight;
                        serverTargetGravityZ = -serverNormalZRight;
                        serverTargetGravityY = serverNormYRight;
                        serverTargetGravityX = serverNormXRight;
                    end;
                    if serverMinDistance == serverDistanceLeft and serverHitXLeft then
                        local serverNormXLeft = -serverNormalXLeft;
                        local serverNormYLeft = -serverNormalYLeft;
                        serverTargetGravityZ = -serverNormalZLeft;
                        serverTargetGravityY = serverNormYLeft;
                        serverTargetGravityX = serverNormXLeft;
                    end;
                    setVehicleGravity(serverOccupiedVehicle, serverGravityX + 0.05 * (serverTargetGravityX - serverGravityX), serverGravityY + 0.05 * (serverTargetGravityY - serverGravityY), serverGravityZ + 0.05 * (serverTargetGravityZ - serverGravityZ));
                else
                    setVehicleGravity(serverOccupiedVehicle, serverGravityX + 0.05 * (0 - serverGravityX), serverGravityY + 0.05 * (0 - serverGravityY), serverGravityZ + 0.05 * (-1 - serverGravityZ));
                end;
                return;
            end;
        end;
    end;
    magnetcars_onClientPlayerVehicleExit = function(serverExitedVehicle, __) 
        local serverExitedVehicleType = getVehicleType(serverExitedVehicle);
        if serverExitedVehicleType == "Automobile" or serverExitedVehicleType == "Bike" or serverExitedVehicleType == "BMX" or serverExitedVehicleType == "Monster Truck" or serverExitedVehicleType == "Quad" then
            setVehicleGravity(source, 0, 0, -1);
        end;
    end;
    checkSH = function() 
        local serverCurrentSecond = getRealTime().second;
        if math.floor(100 * (60 + serverLastSecondCheck - serverCurrentSecond) / 60) > 101 or math.floor(100 * (60 + serverLastSecondCheck - serverCurrentSecond) / 60) < 99 then
            doPunishment(string.format("SpeedHack %s.%X.%X", serverLastSecondCheck - serverCurrentSecond > 0 and "I" or "R", math.floor(100 * (60 + serverLastSecondCheck - serverCurrentSecond) / 60), 100 * math.abs(serverLastSecondCheck - serverCurrentSecond)));
        end;
        serverLastSecondCheck = serverCurrentSecond;
    end;
    godmode_onClientPlayerWeaponFire = function(serverWeaponID, __, __, __, __, __, serverHitPlayer) 
        if serverHitPlayer == localPlayer and source ~= localPlayer and serverWeaponID >= 22 and serverWeaponID <= 34 then
            if serverGodmodeAttackers[source] or isPedDead(localPlayer) or getElementHealth(localPlayer) <= 0 or getPlayerTeam(localPlayer) and getPlayerTeam(localPlayer) == getPlayerTeam(source) and not getTeamFriendlyFire(getPlayerTeam(localPlayer)) then
                serverGodmodeAttackers[source] = nil;
            else
                doPunishment(string.format("GodMode %X", serverWeaponID));
                serverGodmodeAttackers[source] = nil;
            end;
        end;
    end;
    godmode_onClientPlayerDamage = function(serverDamageSource, serverDamageWeapon, __, __) 
        if serverDamageSource ~= localPlayer and serverDamageWeapon >= 22 and serverDamageWeapon <= 34 then
            serverGodmodeAttackers[serverDamageSource] = true;
        end;
    end;
    doPunishment = function(serverPunishmentReason) 
        callServerFunction("doPunishment", localPlayer, serverPunishmentReason);
    end;
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
end)();
(function(...) 
    pickupWeapon = function() 
        if isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local serverCurrentTask = getPedTask(localPlayer, "secondary", 0);
            if serverCurrentTask == "TASK_SIMPLE_THROW" or serverCurrentTask == "TASK_SIMPLE_USE_GUN" then
                return;
            else
                local serverPlayerPosX, serverPlayerPosY, serverPlayerPosZ = getElementPosition(localPlayer);
                local serverPickupsList = getElementsByType("pickup", root, true);
                if not serverPickupsList or #serverPickupsList == 0 then
                    return;
                else
                    if #serverPickupsList > 1 then
                        table.sort(serverPickupsList, function(serverFirstPickup, serverSecondPickup) 
                            local serverPickup1X, serverPickup1Y, serverPickup1Z = getElementPosition(serverFirstPickup);
                            local serverPickup2X, serverPickup2Y, serverPickup2Z = getElementPosition(serverSecondPickup);
                            return getDistanceBetweenPoints3D(serverPlayerPosX, serverPlayerPosY, serverPlayerPosZ, serverPickup1X, serverPickup1Y, serverPickup1Z) < getDistanceBetweenPoints3D(serverPlayerPosX, serverPlayerPosY, serverPlayerPosZ, serverPickup2X, serverPickup2Y, serverPickup2Z);
                        end);
                    end;
                    local serverNearestPickupX, serverNearestPickupY, serverNearestPickupZ = getElementPosition(serverPickupsList[1]);
                    if getDistanceBetweenPoints3D(serverPlayerPosX, serverPlayerPosY, serverPlayerPosZ, serverNearestPickupX, serverNearestPickupY, serverNearestPickupZ) > 2 then
                        return;
                    else
                        local serverPickupWeaponID = getPickupWeapon(serverPickupsList[1]);
                        local serverPickupWeaponName = convertWeaponIDToNames[serverPickupWeaponID];
                        local serverPickupWeaponSlot = getSlotFromWeapon(serverPickupWeaponID);
                        local serverCurrentWeapon = getPedWeapon(localPlayer);
                        local __ = {};
                        local __ = false;
                        local __ = false;
                        local serverWeaponsPackData = getTacticsData("weaponspack");
                        if not serverWeaponsPackData[serverPickupWeaponName] then
                            callServerFunction("pickupWeapon", localPlayer, serverPickupsList[1]);
                            return setPedControlState("enter_exit", false);
                        else
                            local serverOccupiedSlots = {};
                            for serverSlotIndex = 0, 12 do
                                if getPedWeapon(localPlayer, serverSlotIndex) > 0 and getPedTotalAmmo(localPlayer, serverSlotIndex) > 0 then
                                    if serverSlotIndex == serverPickupWeaponSlot then
                                        callServerFunction("replaceWeapon", localPlayer, serverPickupsList[1], serverSlotIndex);
                                        return setPedControlState("enter_exit", false);
                                    else
                                        table.insert(serverOccupiedSlots, serverSlotIndex);
                                    end;
                                end;
                            end;
                            local serverMaxWeaponSlots = getTacticsData("weapon_slots") or 0;
                            if serverMaxWeaponSlots == 0 or #serverOccupiedSlots < serverMaxWeaponSlots then
                                callServerFunction("pickupWeapon", localPlayer, serverPickupsList[1]);
                                return setPedControlState("enter_exit", false);
                            elseif serverCurrentWeapon > 0 then
                                if serverWeaponsPackData[convertWeaponIDToNames[serverCurrentWeapon]] then
                                    callServerFunction("replaceWeapon", localPlayer, serverPickupsList[1], getPedWeaponSlot(localPlayer));
                                    return setPedControlState("enter_exit", false);
                                else
                                    callServerFunction("pickupWeapon", localPlayer, serverPickupsList[1]);
                                    return setPedControlState("enter_exit", false);
                                end;
                            elseif #serverOccupiedSlots > 0 then
                                callServerFunction("replaceWeapon", localPlayer, serverPickupsList[1], serverOccupiedSlots[1]);
                                return setPedControlState("enter_exit", false);
                            else
                                return;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    dropWeapon = function() 
        if isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local serverDropTask = getPedTask(localPlayer, "secondary", 0);
            if serverDropTask == "TASK_SIMPLE_THROW" or serverDropTask == "TASK_SIMPLE_USE_GUN" then
                return;
            else
                if getPedTotalAmmo(localPlayer) ~= 0 then
                    setElementData(localPlayer, "Weapons", nil);
                    callServerFunction("dropWeapon", localPlayer);
                end;
                return;
            end;
        end;
    end;
    local serverPickupInfoText = nil;
    onClientPlayerPickupHit = function(__, serverPickupElement) 
        if not serverPickupElement or isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local serverPickupHitTask = getPedTask(localPlayer, "secondary", 0);
            if serverPickupHitTask == "TASK_SIMPLE_THROW" or serverPickupHitTask == "TASK_SIMPLE_USE_GUN" then
                return;
            else
                serverPickupInfoText = outputInfo(string.format(getLanguageString("help_pickup"), string.upper(next(getBoundKeys("weapon_pickup")))));
                return;
            end;
        end;
    end;
    onClientPlayerPickupLeave = function(__, serverLeavingPickup) 
        if serverLeavingPickup and serverPickupInfoText then
            hideInfo(serverPickupInfoText);
        end;
    end;
    addCommandHandler("weapon_pickup", pickupWeapon, false);
    addCommandHandler("weapon_drop", dropWeapon, false);
    addEventHandler("onClientPlayerPickupHit", localPlayer, onClientPlayerPickupHit);
    addEventHandler("onClientPlayerPickupLeave", localPlayer, onClientPlayerPickupLeave);
end)();
(function(...) 
    local serverCameraPosX = 0;
    local serverCameraPosY = 0;
    local serverCameraPosZ = 0;
    local serverCameraYaw = 0;
    local serverCameraPitch = 0;
    local serverFreeCameraSpeed = 0;
    local serverSpectateMode = "playertarget";
    local serverKeyStates = {};
    local serverWeaponRecoilFactor = 1;
    local serverWeaponScaleFactors = {
        [24] = 0.5, 
        [25] = 1, 
        [29] = 0.5, 
        [30] = 0.5, 
        [31] = 0.5, 
        [33] = 0.5
    };
    local serverPlayerCameraOffsets = {
        xcam = 0, 
        ycam = 0, 
        zcam = 0, 
        xsee = 0, 
        ysee = 0, 
        zsee = 0, 
        fov = 70
    };
    laseraimRender = {};
    onClientResourceStart = function(__) 
        aim_m4 = guiCreateStaticImage(0, 0, 0, 0, "images/aim_m4.png", false);
        guiSetVisible(aim_m4, false);
        guiSetEnabled(aim_m4, false);
        aim_rocket = guiCreateStaticImage(0, 0, 0, 0, "images/aim_rocket.png", false);
        guiSetVisible(aim_rocket, false);
        guiSetEnabled(aim_rocket, false);
        aim_sniper = guiCreateStaticImage(0, 0, 0, 0, "images/aim_sniper.png", false);
        guiSetVisible(aim_sniper, false);
        guiSetEnabled(aim_sniper, false);
        aim_sniper2 = guiCreateStaticImage(xscreen * 0.5 - yscreen * 0.5, 0, yscreen, yscreen, "images/aim_sniper.png", false);
        guiSetVisible(aim_sniper2, false);
        guiSetEnabled(aim_sniper2, false);
        speclist = guiCreateLabel(xscreen * 0.03125, yscreen * 0.375, xscreen, yscreen, "", false);
        guiSetVisible(speclist, false);
        guiSetEnabled(speclist, false);
        guiSetFont(speclist, "default-small");
        guiSetAlpha(speclist, 0.5);
        laseraimTexture = dxCreateTexture("images/sphere.png");
    end;
    setCameraSpectating = function(serverTargetPlayer, serverModeParam) 
        local serverLocalPlayerTeam = getPlayerTeam(localPlayer);
        if serverModeParam then
            serverSpectateMode = serverModeParam;
        end;
        if serverTargetPlayer then
            local serverCanSpectateEnemy = getTacticsData("settings", "spectate_enemy") or getTacticsData("modes", getTacticsData("Map"), "spectate_enemy");
            if serverTargetPlayer ~= localPlayer and getElementData(serverTargetPlayer, "Status") == "Play" then
                if getPlayerTeam(serverTargetPlayer) == serverLocalPlayerTeam or serverCanSpectateEnemy == "true" or serverLocalPlayerTeam == getElementsByType("team")[1] or getRoundState() == "started" then
                    setElementData(localPlayer, "spectarget", serverTargetPlayer);
                    if serverSpectateMode == "freecamera" then
                        local serverTargetPosX, serverTargetPosY, serverTargetPosZ = getElementPosition(serverTargetPlayer);
                        serverCameraPosZ = serverTargetPosZ;
                        serverCameraPosY = serverTargetPosY;
                        serverCameraPosX = serverTargetPosX;
                    else
                        setCameraTarget(serverTargetPlayer);
                    end;
                else
                    setElementData(localPlayer, "spectarget", nil);
                    return setCameraMatrix(getCameraMatrix());
                end;
            end;
        end;
        if setElementData(localPlayer, "Status", "Spectate") and not serverTargetPlayer and serverModeParam ~= "freecamera" then
            switchSpectating();
        end;
        if serverModeParam == "freecamera" then
            local serverCamPosX, serverCamPosY, serverCamPosZ, serverCamLookX, serverCamLookY, serverCamLookZ = getCameraMatrix();
            local serverCamDistance = getDistanceBetweenPoints3D(serverCamPosX, serverCamPosY, serverCamPosZ, serverCamLookX, serverCamLookY, serverCamLookZ);
            local serverTempCamPosX = serverCamPosX;
            local serverTempCamPosY = serverCamPosY;
            serverCameraPosZ = serverCamPosZ;
            serverCameraPosY = serverTempCamPosY;
            serverCameraPosX = serverTempCamPosX;
            serverCameraPitch = math.asin((serverCamLookZ - serverCamPosZ) / serverCamDistance);
            serverCameraYaw = math.abs(serverCamLookX - serverCamPosX) ~= 0 and math.cos(serverCameraPitch) ~= 0 and (serverCamLookX - serverCamPosX) / math.abs(serverCamLookX - serverCamPosX) * math.acos((serverCamLookY - serverCamPosY) / (serverCamDistance * math.cos(serverCameraPitch))) or 0;
        end;
        return true;
    end;
    switchSpectating = function(serverSwitchDirection) 
        if getElementData(localPlayer, "Status") ~= "Spectate" or getElementDimension(localPlayer) == 10 then
            return;
        else
            local serverPlayerTeam = getPlayerTeam(localPlayer);
            local serverCurrentSpectateTarget = getElementData(localPlayer, "spectarget");
            local serverValidSpectatePlayers = {};
            local serverAllAlivePlayers = {};
            local serverSpectateEnemySetting = getTacticsData("settings", "spectate_enemy") or getTacticsData("modes", getTacticsData("Map"), "spectate_enemy");
            for __, serverPlayerElement in ipairs(getElementsByType("player")) do
                if serverPlayerElement ~= localPlayer and getElementData(serverPlayerElement, "Status") == "Play" then
                    table.insert(serverAllAlivePlayers, serverPlayerElement);
                    if getPlayerTeam(serverPlayerElement) == serverPlayerTeam or serverSpectateEnemySetting == "true" then
                        table.insert(serverValidSpectatePlayers, serverPlayerElement);
                    end;
                end;
            end;
            if #serverValidSpectatePlayers == 0 then
                if serverPlayerTeam == getElementsByType("team")[1] or getRoundState() == "started" then
                    if #serverAllAlivePlayers == 0 then
                        setElementData(localPlayer, "spectarget", nil);
                        return setCameraMatrix(getCameraMatrix());
                    else
                        serverValidSpectatePlayers = serverAllAlivePlayers;
                    end;
                else
                    setElementData(localPlayer, "spectarget", nil);
                    return setCameraMatrix(getCameraMatrix());
                end;
            end;
            local serverNewTarget = false;
            if serverSwitchDirection == "q" or serverSwitchDirection == "arrow_l" then
                for serverPlayerIndex, serverPlayerCheck in ipairs(serverValidSpectatePlayers) do
                    if serverPlayerCheck == serverCurrentSpectateTarget then
                        serverNewTarget = serverValidSpectatePlayers[serverPlayerIndex - 1] ~= nil and serverValidSpectatePlayers[serverPlayerIndex - 1] or serverValidSpectatePlayers[#serverValidSpectatePlayers];
                        break;
                    end;
                end;
                if not serverNewTarget then
                    serverNewTarget = serverValidSpectatePlayers[#serverValidSpectatePlayers];
                end;
            elseif serverSwitchDirection == "e" or serverSwitchDirection == "arrow_r" then
                for serverNextIndex, serverNextPlayer in ipairs(serverValidSpectatePlayers) do
                    if serverNextPlayer == serverCurrentSpectateTarget then
                        serverNewTarget = serverValidSpectatePlayers[serverNextIndex + 1] ~= nil and serverValidSpectatePlayers[serverNextIndex + 1] or serverValidSpectatePlayers[1];
                        break;
                    end;
                end;
                if not serverNewTarget then
                    serverNewTarget = serverValidSpectatePlayers[1];
                end;
            else
                table.sort(serverValidSpectatePlayers, function(serverPlayerA, serverPlayerB) 
                    local serverCamX, serverCamY, serverCamZ = getCameraMatrix();
                    local serverPlayerAPosX, serverPlayerAPosY, serverPlayerAPosZ = getElementPosition(serverPlayerA);
                    local serverPlayerBPosX, serverPlayerBPosY, serverPlayerBPosZ = getElementPosition(serverPlayerB);
                    return getDistanceBetweenPoints3D(serverPlayerAPosX, serverPlayerAPosY, serverPlayerAPosZ, serverCamX, serverCamY, serverCamZ) < getDistanceBetweenPoints3D(serverPlayerBPosX, serverPlayerBPosY, serverPlayerBPosZ, serverCamX, serverCamY, serverCamZ);
                end);
                serverNewTarget = serverValidSpectatePlayers[1];
            end;
            if serverNewTarget then
                if serverSpectateMode == "freecamera" then
                    local v1816, v1817, v1818 = getElementPosition(serverNewTarget);
                    serverCameraPosZ = v1818;
                    serverCameraPosY = v1817;
                    serverCameraPosX = v1816;
                else
                    setElementData(localPlayer, "spectarget", serverNewTarget);
                    setCameraTarget(serverNewTarget);
                end;
            end;
            return;
        end;
    end;
    spec_onClientPreRender = function(__) 
        if serverSpectateMode == "playertarget" then
            local serverSpectateTarget = getElementData(localPlayer, "spectarget");
            if serverSpectateTarget and isElement(serverSpectateTarget) then
                if getCameraTarget() ~= serverSpectateTarget and getCameraTarget() ~= getPedOccupiedVehicle(serverSpectateTarget) then
                    setCameraTarget(serverSpectateTarget);
                end;
                if not getCameraTarget() then
                    setCameraTarget(serverSpectateTarget);
                end;
                local serverTargetScreenX, serverTargetScreenY, serverTargetScreenZ = getPedTargetCollision(serverSpectateTarget);
                if not serverTargetScreenX then
                    local serverEndPosX, serverEndPosY, serverEndPosZ = getPedTargetEnd(serverSpectateTarget);
                    serverTargetScreenZ = serverEndPosZ;
                    serverTargetScreenY = serverEndPosY;
                    serverTargetScreenX = serverEndPosX;
                end;
                if serverTargetScreenX then
                    local serverScreenX, serverScreenY = getScreenFromWorldPosition(serverTargetScreenX, serverTargetScreenY, serverTargetScreenZ);
                    serverTargetScreenY = serverScreenY;
                    serverTargetScreenX = serverScreenX;
                end;
                if getPedControlState(serverSpectateTarget, "aim_weapon") and getPedTask(serverSpectateTarget, "secondary", 0) == "TASK_SIMPLE_USE_GUN" and serverTargetScreenX then
                    local serverTargetWeapon = getPedWeapon(serverSpectateTarget);
                    if serverTargetWeapon == 34 then
                        if guiGetVisible(aim_m4) then
                            guiSetVisible(aim_m4, false);
                        end;
                        if guiGetVisible(aim_rocket) then
                            guiSetVisible(aim_rocket, false);
                        end;
                        if not guiGetVisible(aim_sniper) then
                            guiSetVisible(aim_sniper, true);
                        end;
                        if guiGetVisible(aim_sniper2) then
                            guiSetVisible(aim_sniper2, false);
                        end;
                        guiSetPosition(aim_sniper, serverTargetScreenX - xscreen * 0.0645, serverTargetScreenY - yscreen * 0.0915, false);
                        guiSetSize(aim_sniper, xscreen * 0.129, yscreen * 0.183, false);
                    elseif serverTargetWeapon == 35 or serverTargetWeapon == 36 then
                        if guiGetVisible(aim_m4) then
                            guiSetVisible(aim_m4, false);
                        end;
                        if not guiGetVisible(aim_rocket) then
                            guiSetVisible(aim_rocket, true);
                        end;
                        if guiGetVisible(aim_sniper) then
                            guiSetVisible(aim_sniper, false);
                        end;
                        if guiGetVisible(aim_sniper2) then
                            guiSetVisible(aim_sniper2, false);
                        end;
                        guiSetPosition(aim_rocket, serverTargetScreenX - xscreen * 0.072, serverTargetScreenY - yscreen * 0.1025, false);
                        guiSetSize(aim_rocket, xscreen * 0.144, yscreen * 0.205, false);
                    elseif serverWeaponScaleFactors[serverTargetWeapon] then
                        if not guiGetVisible(aim_m4) then
                            guiSetVisible(aim_m4, true);
                        end;
                        if guiGetVisible(aim_rocket) then
                            guiSetVisible(aim_rocket, false);
                        end;
                        if guiGetVisible(aim_sniper) then
                            guiSetVisible(aim_sniper, false);
                        end;
                        if guiGetVisible(aim_sniper2) then
                            guiSetVisible(aim_sniper2, false);
                        end;
                        guiSetPosition(aim_m4, serverTargetScreenX - xscreen * 0.02 * serverWeaponScaleFactors[serverTargetWeapon] * serverWeaponRecoilFactor, serverTargetScreenY - yscreen * 0.02667 * serverWeaponScaleFactors[serverTargetWeapon] * serverWeaponRecoilFactor, false);
                        guiSetSize(aim_m4, xscreen * 0.04 * serverWeaponScaleFactors[serverTargetWeapon] * serverWeaponRecoilFactor, yscreen * 0.05333 * serverWeaponScaleFactors[serverTargetWeapon] * serverWeaponRecoilFactor, false);
                    else
                        if guiGetVisible(aim_m4) then
                            guiSetVisible(aim_m4, false);
                        end;
                        if guiGetVisible(aim_rocket) then
                            guiSetVisible(aim_rocket, false);
                        end;
                        if guiGetVisible(aim_sniper) then
                            guiSetVisible(aim_sniper, false);
                        end;
                        if guiGetVisible(aim_sniper2) then
                            guiSetVisible(aim_sniper2, false);
                        end;
                    end;
                else
                    if guiGetVisible(aim_m4) then
                        guiSetVisible(aim_m4, false);
                    end;
                    if guiGetVisible(aim_rocket) then
                        guiSetVisible(aim_rocket, false);
                    end;
                    if guiGetVisible(aim_sniper) then
                        guiSetVisible(aim_sniper, false);
                    end;
                    if guiGetVisible(aim_sniper2) then
                        guiSetVisible(aim_sniper2, false);
                    end;
                end;
                if serverWeaponRecoilFactor > 1 then
                    serverWeaponRecoilFactor = serverWeaponRecoilFactor - 0.05 * (serverWeaponRecoilFactor - 1);
                else
                    serverWeaponRecoilFactor = 1;
                end;
                setElementInterior(localPlayer, getElementInterior(serverSpectateTarget));
                setCameraInterior(getElementInterior(serverSpectateTarget));
            else
                switchSpectating();
                if guiGetVisible(aim_m4) then
                    guiSetVisible(aim_m4, false);
                end;
                if guiGetVisible(aim_rocket) then
                    guiSetVisible(aim_rocket, false);
                end;
                if guiGetVisible(aim_sniper) then
                    guiSetVisible(aim_sniper, false);
                end;
                if guiGetVisible(aim_sniper2) then
                    guiSetVisible(aim_sniper2, false);
                end;
            end;
        elseif serverSpectateMode == "playercamera" then
            local serverCamTargetPlayer = getElementData(localPlayer, "spectarget");
            if serverCamTargetPlayer and isElement(serverCamTargetPlayer) then
                if getPedOccupiedVehicle(serverCamTargetPlayer) then
                    if not getCameraTarget() or getCameraTarget() ~= getPedOccupiedVehicle(serverCamTargetPlayer) then
                        setCameraTarget(serverCamTargetPlayer);
                    end;
                    local serverVehicleCamX, serverVehicleCamY, serverVehicleCamZ = getCameraMatrix();
                    local serverPlayerPosX, serverPlayerPosY, serverPlayerPosZ = getElementPosition(serverCamTargetPlayer);
                    serverPlayerCameraOffsets = {
                        xcam = serverVehicleCamX - serverPlayerPosX, 
                        ycam = serverVehicleCamY - serverPlayerPosY, 
                        zcam = serverVehicleCamZ - serverPlayerPosZ, 
                        xsee = 0, 
                        ysee = 0, 
                        zsee = 0, 
                        fov = 70
                    };
                    if guiGetVisible(aim_m4) then
                        guiSetVisible(aim_m4, false);
                    end;
                    if guiGetVisible(aim_rocket) then
                        guiSetVisible(aim_rocket, false);
                    end;
                    if guiGetVisible(aim_sniper) then
                        guiSetVisible(aim_sniper, false);
                    end;
                    if guiGetVisible(aim_sniper2) then
                        guiSetVisible(aim_sniper2, false);
                    end;
                    if getElementAlpha(serverCamTargetPlayer) == 0 then
                        setElementAlpha(serverCamTargetPlayer, 255);
                    end;
                else
                    local serverLerpFactor = 0.5;
                    local serverPlayerX, serverPlayerY, serverPlayerZ = getElementPosition(serverCamTargetPlayer);
                    local serverAimStartX, serverAimStartY, serverAimStartZ = getPedTargetStart(serverCamTargetPlayer);
                    local serverAimEndX, serverAimEndY, serverAimEndZ = getPedTargetEnd(serverCamTargetPlayer);
                    local serverStartDistance = getDistanceBetweenPoints3D(serverAimStartX, serverAimStartY, serverAimStartZ, serverPlayerX, serverPlayerY, serverPlayerZ);
                    local serverEndDistance = getDistanceBetweenPoints3D(serverAimStartX, serverAimStartY, serverAimStartZ, serverAimEndX, serverAimEndY, serverAimEndZ);
                    if getPedControlState(serverCamTargetPlayer, "aim_weapon") and getPedTask(serverCamTargetPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN" and serverStartDistance < 3 and serverEndDistance > 0 and tonumber(tostring(serverEndDistance)) then
                        local serverWeaponID = getPedWeapon(serverCamTargetPlayer);
                        local serverWeaponFOV = ({
                            [30] = 55, 
                            [31] = 50, 
                            [33] = 40, 
                            [34] = 12
                        })[serverWeaponID] or 70;
                        local serverCameraDistance = ({
                            [34] = 2, 
                            [35] = 2, 
                            [36] = 2, 
                            [43] = 2
                        })[serverWeaponID] or 3.25;
                        local serverAimDistance = getDistanceBetweenPoints3D(serverAimStartX, serverAimStartY, serverAimStartZ, serverAimEndX, serverAimEndY, serverAimEndZ);
                        local serverNewCamX = serverAimStartX - serverCameraDistance * (serverAimEndX - serverAimStartX) / serverAimDistance;
                        local serverNewCamY = serverAimStartY - serverCameraDistance * (serverAimEndY - serverAimStartY) / serverAimDistance;
                        local serverNewCamZ = serverAimStartZ - serverCameraDistance * (serverAimEndZ - serverAimStartZ) / serverAimDistance;
                        serverNewCamX = serverPlayerCameraOffsets.xcam + serverLerpFactor * (serverNewCamX - serverPlayerX - serverPlayerCameraOffsets.xcam);
                        serverNewCamY = serverPlayerCameraOffsets.ycam + serverLerpFactor * (serverNewCamY - serverPlayerY - serverPlayerCameraOffsets.ycam);
                        serverNewCamZ = serverPlayerCameraOffsets.zcam + serverLerpFactor * (serverNewCamZ - serverPlayerZ - serverPlayerCameraOffsets.zcam);
                        serverAimStartX = serverPlayerCameraOffsets.xsee + serverLerpFactor * (serverAimStartX - serverPlayerX - serverPlayerCameraOffsets.xsee);
                        serverAimStartY = serverPlayerCameraOffsets.ysee + serverLerpFactor * (serverAimStartY - serverPlayerY - serverPlayerCameraOffsets.ysee);
                        serverAimStartZ = serverPlayerCameraOffsets.zsee + serverLerpFactor * (serverAimStartZ - serverPlayerZ - serverPlayerCameraOffsets.zsee);
                        serverWeaponFOV = serverPlayerCameraOffsets.fov + serverLerpFactor * (serverWeaponFOV - serverPlayerCameraOffsets.fov);
                        serverPlayerCameraOffsets = {
                            xcam = serverNewCamX, 
                            ycam = serverNewCamY, 
                            zcam = serverNewCamZ, 
                            xsee = serverAimStartX, 
                            ysee = serverAimStartY, 
                            zsee = serverAimStartZ, 
                            fov = serverWeaponFOV
                        };
                        local serverFinalCamX = serverNewCamX + serverPlayerX;
                        local serverFinalCamY = serverNewCamY + serverPlayerY;
                        serverNewCamZ = serverNewCamZ + serverPlayerZ;
                        serverNewCamY = serverFinalCamY;
                        serverNewCamX = serverFinalCamX;
                        serverFinalCamX = serverAimStartX + serverPlayerX;
                        serverFinalCamY = serverAimStartY + serverPlayerY;
                        serverAimStartZ = serverAimStartZ + serverPlayerZ;
                        serverAimStartY = serverFinalCamY;
                        serverAimStartX = serverFinalCamX;
                        local serverHitX, serverHitY;
                        serverFinalCamX, serverFinalCamY, serverHitX, serverHitY = processLineOfSight(serverAimStartX, serverAimStartY, serverAimStartZ, serverNewCamX, serverNewCamY, serverNewCamZ, true, true, false);
                        if serverFinalCamX then
                            local serverTempFinalCamY = serverFinalCamY;
                            local serverTempHitX = serverHitX;
                            serverNewCamZ = serverHitY;
                            serverNewCamY = serverTempHitX;
                            serverNewCamX = serverTempFinalCamY;
                        end;
                        setCameraMatrix(serverNewCamX, serverNewCamY, serverNewCamZ, serverAimStartX, serverAimStartY, serverAimStartZ, 0, serverWeaponFOV);
                        if serverCameraDistance == 2 then
                            if getElementAlpha(serverCamTargetPlayer) == 255 then
                                setElementAlpha(serverCamTargetPlayer, 0);
                            end;
                        elseif getElementAlpha(serverCamTargetPlayer) == 0 then
                            setElementAlpha(serverCamTargetPlayer, 255);
                        end;
                        local serverCollisionX, serverCollisionY, serverCollisionZ = getPedTargetCollision(serverCamTargetPlayer);
                        if not serverCollisionX then
                            local serverEndAimX, serverEndAimY, serverEndAimZ = getPedTargetEnd(serverCamTargetPlayer);
                            serverCollisionZ = serverEndAimZ;
                            serverCollisionY = serverEndAimY;
                            serverCollisionX = serverEndAimX;
                        end;
                        local serverAimScreenX, serverAimScreenY = getScreenFromWorldPosition(serverCollisionX, serverCollisionY, serverCollisionZ);
                        if serverAimScreenX then
                            if serverWeaponID == 34 then
                                if guiGetVisible(aim_m4) then
                                    guiSetVisible(aim_m4, false);
                                end;
                                if guiGetVisible(aim_rocket) then
                                    guiSetVisible(aim_rocket, false);
                                end;
                                if guiGetVisible(aim_sniper) then
                                    guiSetVisible(aim_sniper, false);
                                end;
                                if not guiGetVisible(aim_sniper2) then
                                    guiSetVisible(aim_sniper2, true);
                                end;
                                guiSetPosition(aim_sniper, serverAimScreenX - xscreen * 0.0645, serverAimScreenY - yscreen * 0.0915, false);
                                guiSetSize(aim_sniper, xscreen * 0.129, yscreen * 0.183, false);
                            elseif serverWeaponID == 35 or serverWeaponID == 36 then
                                if guiGetVisible(aim_m4) then
                                    guiSetVisible(aim_m4, false);
                                end;
                                if not guiGetVisible(aim_rocket) then
                                    guiSetVisible(aim_rocket, true);
                                end;
                                if guiGetVisible(aim_sniper) then
                                    guiSetVisible(aim_sniper, false);
                                end;
                                if guiGetVisible(aim_sniper2) then
                                    guiSetVisible(aim_sniper2, false);
                                end;
                                guiSetPosition(aim_rocket, serverAimScreenX - xscreen * 0.072, serverAimScreenY - yscreen * 0.1025, false);
                                guiSetSize(aim_rocket, xscreen * 0.144, yscreen * 0.205, false);
                            elseif serverWeaponScaleFactors[serverWeaponID] then
                                if not guiGetVisible(aim_m4) then
                                    guiSetVisible(aim_m4, true);
                                end;
                                if guiGetVisible(aim_rocket) then
                                    guiSetVisible(aim_rocket, false);
                                end;
                                if guiGetVisible(aim_sniper) then
                                    guiSetVisible(aim_sniper, false);
                                end;
                                if guiGetVisible(aim_sniper2) then
                                    guiSetVisible(aim_sniper2, false);
                                end;
                                guiSetPosition(aim_m4, serverAimScreenX - xscreen * 0.02 * serverWeaponScaleFactors[serverWeaponID] * serverWeaponRecoilFactor, serverAimScreenY - yscreen * 0.02667 * serverWeaponScaleFactors[serverWeaponID] * serverWeaponRecoilFactor, false);
                                guiSetSize(aim_m4, xscreen * 0.04 * serverWeaponScaleFactors[serverWeaponID] * serverWeaponRecoilFactor, yscreen * 0.05333 * serverWeaponScaleFactors[serverWeaponID] * serverWeaponRecoilFactor, false);
                            else
                                if guiGetVisible(aim_m4) then
                                    guiSetVisible(aim_m4, false);
                                end;
                                if guiGetVisible(aim_rocket) then
                                    guiSetVisible(aim_rocket, false);
                                end;
                                if guiGetVisible(aim_sniper) then
                                    guiSetVisible(aim_sniper, false);
                                end;
                                if guiGetVisible(aim_sniper2) then
                                    guiSetVisible(aim_sniper2, false);
                                end;
                            end;
                        else
                            if guiGetVisible(aim_m4) then
                                guiSetVisible(aim_m4, false);
                            end;
                            if guiGetVisible(aim_rocket) then
                                guiSetVisible(aim_rocket, false);
                            end;
                            if guiGetVisible(aim_sniper) then
                                guiSetVisible(aim_sniper, false);
                            end;
                            if guiGetVisible(aim_sniper2) then
                                guiSetVisible(aim_sniper2, false);
                            end;
                        end;
                    else
                        local serverThirdPersonX, serverThirdPersonY, serverThirdPersonZ = getElementPosition(serverCamTargetPlayer);
                        local serverCameraRotation = math.rad(360 - getPedCameraRotation(serverCamTargetPlayer));
                        local serverCameraAngle = math.rad(15);
                        local serverLookAtX = 0;
                        local serverLookAtY = 0;
                        local serverLookAtZ = 0.6;
                        if isPedDucked(serverCamTargetPlayer) then
                            serverLookAtZ = -0.1;
                        end;
                        local serverOffsetX = 3.5 * math.sin(serverCameraRotation) * math.cos(serverCameraAngle);
                        local serverOffsetY = -3.5 * math.cos(serverCameraRotation) * math.cos(serverCameraAngle);
                        local serverOffsetZ = 3.5 * math.sin(serverCameraAngle) + serverLookAtZ;
                        serverOffsetX = serverPlayerCameraOffsets.xcam + serverLerpFactor * (serverOffsetX - serverPlayerCameraOffsets.xcam);
                        serverOffsetY = serverPlayerCameraOffsets.ycam + serverLerpFactor * (serverOffsetY - serverPlayerCameraOffsets.ycam);
                        serverOffsetZ = serverPlayerCameraOffsets.zcam + serverLerpFactor * (serverOffsetZ - serverPlayerCameraOffsets.zcam);
                        serverLookAtX = serverPlayerCameraOffsets.xsee + serverLerpFactor * (serverLookAtX - serverPlayerCameraOffsets.xsee);
                        serverLookAtY = serverPlayerCameraOffsets.ysee + serverLerpFactor * (serverLookAtY - serverPlayerCameraOffsets.ysee);
                        serverLookAtZ = serverPlayerCameraOffsets.zsee + serverLerpFactor * (serverLookAtZ - serverPlayerCameraOffsets.zsee);
                        local serverThirdPersonFOV = serverPlayerCameraOffsets.fov + serverLerpFactor * (70 - serverPlayerCameraOffsets.fov);
                        serverPlayerCameraOffsets = {
                            xcam = serverOffsetX, 
                            ycam = serverOffsetY, 
                            zcam = serverOffsetZ, 
                            xsee = serverLookAtX, 
                            ysee = serverLookAtY, 
                            zsee = serverLookAtZ, 
                            fov = serverThirdPersonFOV
                        };
                        local serverFinalThirdCamX = serverOffsetX + serverThirdPersonX;
                        local serverFinalThirdCamY = serverOffsetY + serverThirdPersonY;
                        serverOffsetZ = serverOffsetZ + serverThirdPersonZ;
                        serverOffsetY = serverFinalThirdCamY;
                        serverOffsetX = serverFinalThirdCamX;
                        serverFinalThirdCamX = serverLookAtX + serverThirdPersonX;
                        serverFinalThirdCamY = serverLookAtY + serverThirdPersonY;
                        serverLookAtZ = serverLookAtZ + serverThirdPersonZ;
                        serverLookAtY = serverFinalThirdCamY;
                        serverLookAtX = serverFinalThirdCamX;
                        local serverWallHitX, serverWallHitY;
                        serverFinalThirdCamX, serverFinalThirdCamY, serverWallHitX, serverWallHitY = processLineOfSight(serverLookAtX, serverLookAtY, serverLookAtZ, serverOffsetX, serverOffsetY, serverOffsetZ, true, true, false);
                        if serverFinalThirdCamX then
                            local serverTempFinalThirdCamY = serverFinalThirdCamY;
                            local serverTempWallHitX = serverWallHitX;
                            serverOffsetZ = serverWallHitY;
                            serverOffsetY = serverTempWallHitX;
                            serverOffsetX = serverTempFinalThirdCamY;
                        end;
                        setCameraMatrix(serverOffsetX, serverOffsetY, serverOffsetZ, serverLookAtX, serverLookAtY, serverLookAtZ, 0, serverThirdPersonFOV);
                        if guiGetVisible(aim_m4) then
                            guiSetVisible(aim_m4, false);
                        end;
                        if guiGetVisible(aim_rocket) then
                            guiSetVisible(aim_rocket, false);
                        end;
                        if guiGetVisible(aim_sniper) then
                            guiSetVisible(aim_sniper, false);
                        end;
                        if guiGetVisible(aim_sniper2) then
                            guiSetVisible(aim_sniper2, false);
                        end;
                        if getElementAlpha(serverCamTargetPlayer) == 0 then
                            setElementAlpha(serverCamTargetPlayer, 255);
                        end;
                    end;
                    if serverWeaponRecoilFactor > 1 then
                        serverWeaponRecoilFactor = serverWeaponRecoilFactor - 0.05 * (serverWeaponRecoilFactor - 1);
                    else
                        serverWeaponRecoilFactor = 1;
                    end;
                    setElementInterior(localPlayer, getElementInterior(serverCamTargetPlayer));
                    setCameraInterior(getElementInterior(serverCamTargetPlayer));
                end;
            else
                switchSpectating();
                if guiGetVisible(aim_m4) then
                    guiSetVisible(aim_m4, false);
                end;
                if guiGetVisible(aim_rocket) then
                    guiSetVisible(aim_rocket, false);
                end;
                if guiGetVisible(aim_sniper) then
                    guiSetVisible(aim_sniper, false);
                end;
                if guiGetVisible(aim_sniper2) then
                    guiSetVisible(aim_sniper2, false);
                end;
            end;
        elseif serverSpectateMode == "freecamera" then
            if guiGetVisible(aim_m4) then
                guiSetVisible(aim_m4, false);
            end;
            if guiGetVisible(aim_rocket) then
                guiSetVisible(aim_rocket, false);
            end;
            if guiGetVisible(aim_sniper) then
                guiSetVisible(aim_sniper, false);
            end;
            if guiGetVisible(aim_sniper2) then
                guiSetVisible(aim_sniper2, false);
            end;
            local serverFreeCamPosX, serverFreeCamPosY, serverFreeCamPosZ, serverFreeCamLookX, serverFreeCamLookY, serverFreeCamLookZ = getCameraMatrix();
            local serverFreeCamMaxDistance = 2000;
            if getCameraTarget() then
                local serverTempFreeCamPosX = serverFreeCamPosX;
                local serverTempFreeCamPosY = serverFreeCamPosY;
                serverCameraPosZ = serverFreeCamPosZ;
                serverCameraPosY = serverTempFreeCamPosY;
                serverCameraPosX = serverTempFreeCamPosX;
                setCameraMatrix(serverFreeCamPosX, serverFreeCamPosY, serverFreeCamPosZ, serverFreeCamLookX, serverFreeCamLookY, serverFreeCamLookZ);
                serverCameraPitch = math.asin((serverFreeCamLookZ - serverFreeCamPosZ) / serverFreeCamMaxDistance);
                serverCameraYaw = math.abs(serverFreeCamLookX - serverFreeCamPosX) ~= 0 and math.cos(serverCameraPitch) ~= 0 and (serverFreeCamLookX - serverFreeCamPosX) / math.abs(serverFreeCamLookX - serverFreeCamPosX) * math.acos((serverFreeCamLookY - serverFreeCamPosY) / (serverFreeCamMaxDistance * math.cos(serverCameraPitch))) or 0;
            end;
            if serverKeyStates.sprint then
                if serverFreeCameraSpeed < 2 then
                    serverFreeCameraSpeed = 2;
                elseif serverFreeCameraSpeed < 20 then
                    serverFreeCameraSpeed = serverFreeCameraSpeed + 0.05;
                end;
            elseif serverKeyStates.walk then
                if serverFreeCameraSpeed < 0.1 then
                    serverFreeCameraSpeed = 0.1;
                elseif serverFreeCameraSpeed > 0.1 then
                    serverFreeCameraSpeed = serverFreeCameraSpeed - 0.1;
                end;
            elseif serverFreeCameraSpeed < 0.6 then
                serverFreeCameraSpeed = 0.6;
            elseif serverFreeCameraSpeed > 0.6 then
                serverFreeCameraSpeed = serverFreeCameraSpeed - 0.1;
            end;
            local serverMoveX = 0;
            local serverMoveY = 0;
            local serverMoveZ = 0;
            if serverKeyStates.forwards then
                serverMoveX = (serverFreeCamLookX - serverFreeCamPosX) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
                serverMoveY = (serverFreeCamLookY - serverFreeCamPosY) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
                serverMoveZ = (serverFreeCamLookZ - serverFreeCamPosZ) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
            end;
            if serverKeyStates.backwards then
                serverMoveX = (serverFreeCamPosX - serverFreeCamLookX) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
                serverMoveY = (serverFreeCamPosY - serverFreeCamLookY) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
                serverMoveZ = (serverFreeCamPosZ - serverFreeCamLookZ) * serverFreeCameraSpeed / serverFreeCamMaxDistance;
            end;
            local serverCameraAngle2D = getAngleBetweenPoints2D(serverFreeCamPosX, serverFreeCamPosY, serverFreeCamLookX, serverFreeCamLookY);
            if serverKeyStates.left then
                serverMoveX = serverMoveX + serverFreeCameraSpeed * math.cos(math.rad(serverCameraAngle2D + 180));
                serverMoveY = serverMoveY + serverFreeCameraSpeed * math.sin(math.rad(serverCameraAngle2D + 180));
            end;
            if serverKeyStates.right then
                serverMoveX = serverMoveX + serverFreeCameraSpeed * math.cos(math.rad(serverCameraAngle2D));
                serverMoveY = serverMoveY + serverFreeCameraSpeed * math.sin(math.rad(serverCameraAngle2D));
            end;
            if serverKeyStates.jump then
                serverMoveZ = serverMoveZ + 0.66 * serverFreeCameraSpeed;
            end;
            if serverKeyStates.crouch then
                serverMoveZ = serverMoveZ - 0.66 * serverFreeCameraSpeed;
            end;
            local serverNewFreeCamX = serverCameraPosX + serverMoveX;
            local serverNewFreeCamY = serverCameraPosY + serverMoveY;
            serverCameraPosZ = serverCameraPosZ + serverMoveZ;
            serverCameraPosY = serverNewFreeCamY;
            serverCameraPosX = serverNewFreeCamX;
            if serverCameraPitch > 0.499 * math.pi then
                serverCameraPitch = 0.499 * math.pi;
            end;
            if serverCameraPitch < -0.499 * math.pi then
                serverCameraPitch = -0.499 * math.pi;
            end;
            serverNewFreeCamX = serverFreeCamPosX + 0.1 * (serverCameraPosX - serverFreeCamPosX);
            serverNewFreeCamY = serverFreeCamPosY + 0.1 * (serverCameraPosY - serverFreeCamPosY);
            serverFreeCamPosZ = serverFreeCamPosZ + 0.1 * (serverCameraPosZ - serverFreeCamPosZ);
            serverFreeCamPosY = serverNewFreeCamY;
            serverFreeCamPosX = serverNewFreeCamX;
            xpoint2 = serverCameraPosX + serverFreeCamMaxDistance * math.sin(serverCameraYaw) * math.cos(serverCameraPitch);
            ypoint2 = serverCameraPosY + serverFreeCamMaxDistance * math.cos(serverCameraYaw) * math.cos(serverCameraPitch);
            zpoint2 = serverCameraPosZ + serverFreeCamMaxDistance * math.sin(serverCameraPitch);
            setCameraMatrix(serverFreeCamPosX, serverFreeCamPosY, serverFreeCamPosZ, xpoint2, ypoint2, zpoint2);
        end;
    end;
    spec_onClientCursorMove = function(serverCursorDeltaX, serverCursorDeltaY, serverCursorX, serverCursorY) 
        if serverSpectateMode == "freecamera" and not isCursorShowing() and not isMTAWindowActive() then
            serverCursorDeltaX = serverCursorX - 0.5 * xscreen;
            serverCursorDeltaY = serverCursorY - 0.5 * yscreen;
            serverCameraYaw = (serverCameraYaw + serverCursorDeltaX * 0.002) % (2 * math.pi);
            serverCameraPitch = serverCameraPitch - serverCursorDeltaY * 0.002;
        end;
    end;
    spec_onClientVehicleEnterExit = function(serverVehicleElement, __) 
        if getElementData(localPlayer, "spectarget") == serverVehicleElement and serverSpectateMode == "playertarget" then
            setCameraTarget(serverVehicleElement);
        end;
    end;
    pressControl = function(serverControlName, serverControlState) 
        if serverControlState == "down" then
            serverKeyStates[serverControlName] = true;
        else
            serverKeyStates[serverControlName] = nil;
        end;
    end;
    changeCameraView = function() 
        if getPlayerTeam(localPlayer) and getElementDimension(localPlayer) ~= 10 then
            local serverPrevSpectateTarget = getElementData(localPlayer, "spectarget");
            if serverPrevSpectateTarget and getElementAlpha(serverPrevSpectateTarget) == 0 then
                setElementAlpha(serverPrevSpectateTarget, 255);
            end;
            local serverPreviousSpectateMode = serverSpectateMode;
            setPedControlState("change_camera", false);
            if serverPreviousSpectateMode == "playertarget" then
                serverSpectateMode = "playercamera";
            elseif serverPreviousSpectateMode == "playercamera" and getPlayerTeam(localPlayer) == getElementsByType("team")[1] then
                local serverChangeCamPosX, serverChangeCamPosY, serverChangeCamPosZ, serverChangeCamLookX, serverChangeCamLookY, serverChangeCamLookZ = getCameraMatrix();
                local serverCamDistance = serverChangeCamPosX;
                local serverTempChangeCamPosY = serverChangeCamPosY;
                serverCameraPosZ = serverChangeCamPosZ;
                serverCameraPosY = serverTempChangeCamPosY;
                serverCameraPosX = serverCamDistance;
                serverCamDistance = getDistanceBetweenPoints3D(serverChangeCamPosX, serverChangeCamPosY, serverChangeCamPosZ, serverChangeCamLookX, serverChangeCamLookY, serverChangeCamLookZ);
                serverCameraPitch = math.asin((serverChangeCamLookZ - serverChangeCamPosZ) / serverCamDistance);
                serverCameraYaw = math.abs(serverChangeCamLookX - serverChangeCamPosX) ~= 0 and math.cos(serverCameraPitch) ~= 0 and (serverChangeCamLookX - serverChangeCamPosX) / math.abs(serverChangeCamLookX - serverChangeCamPosX) * math.acos((serverChangeCamLookY - serverChangeCamPosY) / (serverCamDistance * math.cos(serverCameraPitch))) or 0;
                setElementData(localPlayer, "spectarget", nil);
                serverSpectateMode = "freecamera";
            elseif serverPreviousSpectateMode == "freecamera" then
                serverSpectateMode = "playertarget";
                switchSpectating();
            else
                serverSpectateMode = "playertarget";
            end;
            playSoundFrontEnd(11);
            triggerEvent("onClientCameraSpectateModeChange", localPlayer, serverPreviousSpectateMode, serverPrevSpectateTarget);
        end;
    end;
    local serverWeaponRecoilStanding = {
        [24] = 2.3, 
        [29] = 0.3, 
        [30] = 0.5, 
        [31] = 0.15
    };
    local serverWeaponRecoilCrouching = {
        [24] = 0.7, 
        [29] = 0.03, 
        [30] = 0.08
    };
    spec_onClientPlayerWeaponFire = function(serverWeaponFired, __, __, __, __, __, __) 
        if getElementData(localPlayer, "spectarget") == source then
            if not isPedDucked(source) then
                if serverWeaponRecoilStanding[serverWeaponFired] then
                    serverWeaponRecoilFactor = serverWeaponRecoilFactor + serverWeaponRecoilStanding[serverWeaponFired];
                end;
            elseif serverWeaponRecoilCrouching[serverWeaponFired] then
                serverWeaponRecoilFactor = serverWeaponRecoilFactor + serverWeaponRecoilCrouching[serverWeaponFired];
            end;
        end;
    end;
    local serverSpectateHelpText = nil;
    onClientElementDataChange = function(serverDataName, serverDataOldValue) 
        if getElementData(localPlayer, "Status") == "Spectate" and getElementData(localPlayer, "spectarget") == source and serverDataName == "Status" and getElementData(source, serverDataName) == "Spectate" then
            switchSpectating();
        end;
        if getElementData(localPlayer, "Status") == "Spectate" and serverSpectateMode ~= "freecamera" and not getElementData(localPlayer, "spectarget") and serverDataName == "Status" and getElementData(source, serverDataName) == "Play" then
            setCameraSpectating(source);
        end;
        if source == localPlayer and serverDataName == "Status" then
            local serverDataNewValue = getElementData(source, serverDataName);
            if serverDataNewValue == "Spectate" and serverDataOldValue ~= "Spectate" then
                if getPlayerTeam(localPlayer) == getElementsByType("team")[1] or getElementData(localPlayer, "spectateskin") then
                    setElementPosition(localPlayer, 0, 0, 0);
                end;
                if serverSpectateMode == "freecamera" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                    serverSpectateMode = "playertarget";
                end;
                setElementFrozen(localPlayer, true);
                toggleAllControls(false, true, false);
                toggleControl("enter_passenger", false);
                if not getCameraTarget() or serverSpectateMode == "freecamera" then
                    local serverStatusCamPosX, serverStatusCamPosY, serverStatusCamPosZ, serverStatusCamLookX, serverStatusCamLookY, serverStatusCamLookZ = getCameraMatrix();
                    local serverStatusCamDistance = getDistanceBetweenPoints3D(serverStatusCamPosX, serverStatusCamPosY, serverStatusCamPosZ, serverStatusCamLookX, serverStatusCamLookY, serverStatusCamLookZ);
                    local serverTempStatusCamPosX = serverStatusCamPosX;
                    local serverTempStatusCamPosY = serverStatusCamPosY;
                    serverCameraPosZ = serverStatusCamPosZ;
                    serverCameraPosY = serverTempStatusCamPosY;
                    serverCameraPosX = serverTempStatusCamPosX;
                    serverCameraPitch = math.asin((serverStatusCamLookZ - serverStatusCamPosZ) / serverStatusCamDistance);
                    serverCameraYaw = math.abs(serverStatusCamLookX - serverStatusCamPosX) ~= 0 and math.cos(serverCameraPitch) ~= 0 and (serverStatusCamLookX - serverStatusCamPosX) / math.abs(serverStatusCamLookX - serverStatusCamPosX) * math.acos((serverStatusCamLookY - serverStatusCamPosY) / (serverStatusCamDistance * math.cos(serverCameraPitch))) or 0;
                end;
                serverKeyStates = {};
                bindKey("forwards", "both", pressControl);
                bindKey("backwards", "both", pressControl);
                bindKey("left", "both", pressControl);
                bindKey("right", "both", pressControl);
                bindKey("jump", "both", pressControl);
                bindKey("crouch", "both", pressControl);
                bindKey("sprint", "both", pressControl);
                bindKey("walk", "both", pressControl);
                bindKey("q", "down", switchSpectating);
                bindKey("e", "down", switchSpectating);
                bindKey("arrow_l", "down", switchSpectating);
                bindKey("arrow_r", "down", switchSpectating);
                bindKey("change_camera", "down", changeCameraView);
                addEventHandler("onClientPreRender", root, spec_onClientPreRender);
                addEventHandler("onClientCursorMove", root, spec_onClientCursorMove);
                addEventHandler("onClientVehicleEnter", root, spec_onClientVehicleEnterExit);
                addEventHandler("onClientVehicleExit", root, spec_onClientVehicleEnterExit);
                addEventHandler("onClientVehicleStartExit", root, spec_onClientVehicleEnterExit);
                addEventHandler("onClientPlayerWeaponFire", root, spec_onClientPlayerWeaponFire);
                addEventHandler("onClientTacticsChange", root, spec_onClientTacticsChange);
                serverSpectateHelpText = outputInfo(string.format(getLanguageString("help_spectate"), string.upper(next(getBoundKeys("change_camera")))));
                if not getElementData(localPlayer, "Loading") then
                    fadeCamera(true, 2);
                end;
                triggerEvent("onClientCameraSpectateStart", localPlayer);
            elseif serverDataNewValue ~= "Spectate" and serverDataOldValue == "Spectate" then
                if guiGetVisible(aim_m4) then
                    guiSetVisible(aim_m4, false);
                end;
                if guiGetVisible(aim_rocket) then
                    guiSetVisible(aim_rocket, false);
                end;
                if guiGetVisible(aim_sniper) then
                    guiSetVisible(aim_sniper, false);
                end;
                unbindKey("forwards", "both", pressControl);
                unbindKey("backwards", "both", pressControl);
                unbindKey("left", "both", pressControl);
                unbindKey("right", "both", pressControl);
                unbindKey("jump", "both", pressControl);
                unbindKey("crouch", "both", pressControl);
                unbindKey("sprint", "both", pressControl);
                unbindKey("walk", "both", pressControl);
                unbindKey("q", "down", switchSpectating);
                unbindKey("e", "down", switchSpectating);
                unbindKey("arrow_l", "down", switchSpectating);
                unbindKey("arrow_r", "down", switchSpectating);
                unbindKey("change_camera", "down", changeCameraView);
                removeEventHandler("onClientPreRender", root, spec_onClientPreRender);
                removeEventHandler("onClientCursorMove", root, spec_onClientCursorMove);
                removeEventHandler("onClientVehicleEnter", root, spec_onClientVehicleEnterExit);
                removeEventHandler("onClientVehicleExit", root, spec_onClientVehicleEnterExit);
                removeEventHandler("onClientVehicleStartExit", root, spec_onClientVehicleEnterExit);
                removeEventHandler("onClientPlayerWeaponFire", root, spec_onClientPlayerWeaponFire);
                removeEventHandler("onClientTacticsChange", root, spec_onClientTacticsChange);
                if getRoundState() == "started" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] and not getElementData(localPlayer, "spectateskin") then
                    setElementFrozen(localPlayer, false);
                    toggleAllControls(true);
                end;
                setCameraTarget(localPlayer);
                local serverOldSpectateTarget = getElementData(localPlayer, "spectarget");
                setElementData(localPlayer, "spectarget", nil);
                if guiGetVisible(aim_m4) then
                    guiSetVisible(aim_m4, false);
                end;
                if guiGetVisible(aim_rocket) then
                    guiSetVisible(aim_rocket, false);
                end;
                if guiGetVisible(aim_sniper) then
                    guiSetVisible(aim_sniper, false);
                end;
                if guiGetVisible(aim_sniper2) then
                    guiSetVisible(aim_sniper2, false);
                end;
                if serverSpectateHelpText then
                    hideInfo(serverSpectateHelpText);
                end;
                triggerEvent("onClientCameraSpectateStop", localPlayer, serverOldSpectateTarget, serverSpectateMode);
                if isElement(serverOldSpectateTarget) and getElementAlpha(serverOldSpectateTarget) == 0 then
                    setElementAlpha(serverOldSpectateTarget, 255);
                end;
            end;
        end;
        if serverDataName == "spectarget" then
            if source == localPlayer and getElementData(localPlayer, "Status") == "Spectate" then
                triggerEvent("onClientCameraSpectateTargetChange", localPlayer, serverDataOldValue);
                if isElement(serverDataOldValue) and getElementAlpha(serverDataOldValue) == 0 then
                    setElementAlpha(serverDataOldValue, 255);
                end;
            end;
            local serverCurrentTarget = getElementData(localPlayer, "Status") ~= "Spectate" and localPlayer or getElementData(localPlayer, "spectarget");
            if getElementData(source, serverDataName) == serverCurrentTarget or serverDataOldValue == serverCurrentTarget then
                updateSpectatorsList();
            elseif source == localPlayer then
                updateSpectatorsList();
            end;
        end;
        if serverDataName == "laseraim" and isElementStreamedIn(source) then
            if getElementData(source, serverDataName) and not laseraimRender[source] then
                if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                    addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                end;
                local serverLaserPosX, serverLaserPosY, serverLaserPosZ = getElementPosition(source);
                laseraimRender[source] = createMarker(serverLaserPosX, serverLaserPosY, serverLaserPosZ, "corona", 0.5, 0, 0, 0, 0);
                if source == localPlayer then
                    setPlayerHudComponentVisible("crosshair", false);
                end;
            elseif laseraimRender[source] then
                if source == localPlayer then
                    setPlayerHudComponentVisible("crosshair", true);
                end;
                destroyElement(laseraimRender[source]);
                laseraimRender[source] = nil;
                if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                    removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                end;
            end;
        end;
    end;
    onClientElementStreamIn = function() 
        if getElementData(source, "laseraim") and not laseraimRender[source] then
            if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
            end;
            local serverStreamPosX, serverStreamPosY, serverStreamPosZ = getElementPosition(source);
            laseraimRender[source] = createMarker(serverStreamPosX, serverStreamPosY, serverStreamPosZ, "corona", 0.2, 0, 0, 0, 0);
        end;
    end;
    onClientElementStreamOut = function() 
        if getElementData(source, "laseraim") and laseraimRender[source] then
            destroyElement(laseraimRender[source]);
            laseraimRender[source] = nil;
            if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
            end;
        end;
    end;
    onClientLaseraimRender = function() 
        for serverPlayerWithLaser, serverLaserMarker in pairs(laseraimRender) do
            local serverLaserWeapon = getPedWeapon(serverPlayerWithLaser);
            if serverLaserWeapon >= 22 and serverLaserWeapon <= 38 then
                local serverMuzzlePosX, serverMuzzlePosY, serverMuzzlePosZ = getPedWeaponMuzzlePosition(serverPlayerWithLaser);
                local serverCollisionPosX, serverCollisionPosY, serverCollisionPosZ, serverSurfaceNormalX, serverSurfaceNormalY, serverSurfaceNormalZ, serverLightingNormal = getPedTargetCollision(serverPlayerWithLaser);
                local serverTargetEndX, serverTargetEndY, serverTargetEndZ = getPedTargetEnd(serverPlayerWithLaser);
                local serverMuzzleDistance = getDistanceBetweenPoints3D(serverMuzzlePosX, serverMuzzlePosY, serverMuzzlePosZ, serverTargetEndX, serverTargetEndY, serverTargetEndZ);
                if not getPedControlState(serverPlayerWithLaser, "aim_weapon") or not getPedTask(serverPlayerWithLaser, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
                    local serverBonePosX, serverBonePosY, serverBonePosZ = getPedBonePosition(serverPlayerWithLaser, 24);
                    local serverBoneDistance = getDistanceBetweenPoints3D(serverMuzzlePosX, serverMuzzlePosY, serverMuzzlePosZ, serverBonePosX, serverBonePosY, serverBonePosZ);
                    local serverDefaultEndX = serverMuzzlePosX + serverMuzzleDistance * (serverMuzzlePosX - serverBonePosX) / serverBoneDistance;
                    local serverDefaultEndY = serverMuzzlePosY + serverMuzzleDistance * (serverMuzzlePosY - serverBonePosY) / serverBoneDistance;
                    serverTargetEndZ = serverMuzzlePosZ + serverMuzzleDistance * (serverMuzzlePosZ - serverBonePosZ) / serverBoneDistance;
                    serverTargetEndY = serverDefaultEndY;
                    serverTargetEndX = serverDefaultEndX;
                    local serverDefaultEndZ, serverHitResultX, serverHitResultY, serverHitResultZ, serverMaterialProperty, serverLightingProperty;
                    serverDefaultEndX, serverDefaultEndY, serverDefaultEndZ, serverHitResultX, serverHitResultY, serverHitResultZ, serverMaterialProperty, serverLightingProperty = processLineOfSight(serverMuzzlePosX, serverMuzzlePosY, serverMuzzlePosZ, serverTargetEndX, serverTargetEndY, serverTargetEndZ, true, true, true, false, false, false, true, false, serverPlayerWithLaser);
                    serverLightingNormal = serverLightingProperty;
                    serverSurfaceNormalZ = serverMaterialProperty;
                    serverSurfaceNormalY = serverHitResultZ;
                    _ = serverHitResultY;
                    serverCollisionPosZ = serverHitResultX;
                    serverCollisionPosY = serverDefaultEndZ;
                    serverCollisionPosX = serverDefaultEndY;
                    serverSurfaceNormalX = serverDefaultEndX;
                elseif serverCollisionPosX then
                    local serverCollisionDistance = getDistanceBetweenPoints3D(serverMuzzlePosX, serverMuzzlePosY, serverMuzzlePosZ, serverCollisionPosX, serverCollisionPosY, serverCollisionPosZ);
                    local serverNormalX = (serverMuzzlePosX - serverCollisionPosX) / serverCollisionDistance;
                    local serverNormalY = (serverMuzzlePosY - serverCollisionPosY) / serverCollisionDistance;
                    local serverNormalZ = (serverMuzzlePosZ - serverCollisionPosZ) / serverCollisionDistance;
                    local serverAdjustedHitX, serverAdjustedHitY, serverAdjustedHitZ, serverAdjustedNormalX, serverAdjustedNormalY, serverAdjustedNormalZ, serverAdjustedMaterial, serverAdjustedLighting = processLineOfSight(serverCollisionPosX + serverNormalX, serverCollisionPosY + serverNormalY, serverCollisionPosZ + serverNormalZ, serverCollisionPosX - serverNormalX, serverCollisionPosY - serverNormalY, serverCollisionPosZ - serverNormalZ, true, true, true, false, false, false, true, false, serverPlayerWithLaser);
                    serverLightingNormal = serverAdjustedLighting;
                    serverSurfaceNormalZ = serverAdjustedMaterial;
                    serverSurfaceNormalY = serverAdjustedNormalZ;
                    _ = serverAdjustedNormalY;
                    serverCollisionPosZ = serverAdjustedNormalX;
                    serverCollisionPosY = serverAdjustedHitZ;
                    serverCollisionPosX = serverAdjustedHitY;
                    serverSurfaceNormalX = serverAdjustedHitX;
                end;
                local serverSurfaceAngle = dxDrawLine3D;
                local serverNormalOffsetX = serverMuzzlePosX;
                local serverNormalOffsetY = serverMuzzlePosY;
                local serverNormalOffsetZ = serverMuzzlePosZ;
                local v1996;
                if not serverCollisionPosX then
                    v1996 = serverTargetEndX;
                else
                    v1996 = serverCollisionPosX;
                end;
                local v1997;
                if not serverCollisionPosY then
                    v1997 = serverTargetEndY;
                else
                    v1997 = serverCollisionPosY;
                end;
                local v1998;
                if not serverCollisionPosZ then
                    v1998 = serverTargetEndZ;
                else
                    v1998 = serverCollisionPosZ;
                end;
                serverSurfaceAngle(serverNormalOffsetX, serverNormalOffsetY, serverNormalOffsetZ, v1996, v1997, v1998, 1090453504);
                if serverCollisionPosX and serverSurfaceNormalY then
                    serverSurfaceAngle = math.rad(getAngleBetweenPoints2D(0, 0, serverSurfaceNormalY, serverSurfaceNormalZ));
                    serverCollisionPosX = serverCollisionPosX + 0.01 * serverSurfaceNormalY;
                    serverCollisionPosY = serverCollisionPosY + 0.01 * serverSurfaceNormalZ;
                    serverCollisionPosZ = serverCollisionPosZ + 0.01 * serverLightingNormal;
                    serverNormalOffsetX = 0.05 * serverLightingNormal * math.sin(serverSurfaceAngle);
                    serverNormalOffsetY = -0.05 * serverLightingNormal * math.cos(serverSurfaceAngle);
                    serverNormalOffsetZ = 0.05 * math.sqrt(serverSurfaceNormalY ^ 2 + serverSurfaceNormalZ ^ 2);
                    dxDrawMaterialLine3D(serverCollisionPosX, serverCollisionPosY, serverCollisionPosZ, serverCollisionPosX, serverCollisionPosY, serverCollisionPosZ, laseraimTexture, 0, 0);
                    dxDrawMaterialLine3D(serverCollisionPosX - serverNormalOffsetX, serverCollisionPosY - serverNormalOffsetY, serverCollisionPosZ - serverNormalOffsetZ, serverCollisionPosX + serverNormalOffsetX, serverCollisionPosY + serverNormalOffsetY, serverCollisionPosZ + serverNormalOffsetZ, laseraimTexture, 0.1, 4294901760, serverCollisionPosX - serverNormalOffsetX + serverSurfaceNormalY, serverCollisionPosY - serverNormalOffsetY + serverSurfaceNormalZ, serverCollisionPosZ - serverNormalOffsetZ + serverLightingNormal);
                    setElementPosition(serverLaserMarker, serverCollisionPosX, serverCollisionPosY, serverCollisionPosZ);
                    setMarkerColor(serverLaserMarker, 255, 0, 0, 32);
                else
                    setMarkerColor(serverLaserMarker, 0, 0, 0, 0);
                    setElementPosition(serverLaserMarker, getElementPosition(serverPlayerWithLaser));
                end;
            else
                setMarkerColor(serverLaserMarker, 0, 0, 0, 0);
                setElementPosition(serverLaserMarker, getElementPosition(serverPlayerWithLaser));
            end;
        end;
    end;
    toggleLaseraim = function() 
        if getPedControlState("aim_weapon") and getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
            if getElementData(localPlayer, "laseraim") then
                setElementData(localPlayer, "laseraim", nil);
            else
                setElementData(localPlayer, "laseraim", true);
            end;
        end;
    end;
    onClientPlayerQuit = function() 
        if laseraimRender[source] then
            destroyElement(laseraimRender[source]);
            laseraimRender[source] = nil;
            if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
            end;
        end;
        if getElementData(source, "Status") == "Spectate" and (getElementData(source, "spectarget") == getElementData(localPlayer, "spectarget") or getElementData(source, "spectarget") == localPlayer) then
            setTimer(updateSpectatorsList, 50, 1);
        end;
    end;
    onClientPlayerChangeNick = function(__, __) 
        if getElementData(source, "Status") == "Spectate" and (getElementData(source, "spectarget") == getElementData(localPlayer, "spectarget") or getElementData(source, "spectarget") == localPlayer) then
            updateSpectatorsList();
        end;
    end;
    updateSpectatorsList = function() 
        local serverListTargetPlayer = getElementData(localPlayer, "Status") ~= "Spectate" and localPlayer or getElementData(localPlayer, "spectarget");
        if not serverListTargetPlayer then
            return guiSetVisible(speclist, false);
        else
            local serverSpectatorsText = "";
            for __, serverSpectatingPlayer in ipairs(getElementsByType("player")) do
                if getElementData(serverSpectatingPlayer, "Status") == "Spectate" and getElementData(serverSpectatingPlayer, "spectarget") == serverListTargetPlayer then
                    serverSpectatorsText = serverSpectatorsText .. "\n" .. removeColorCoding(getPlayerName(serverSpectatingPlayer));
                end;
            end;
            if string.len(serverSpectatorsText) == 0 then
                return guiSetVisible(speclist, false);
            else
                guiSetText(speclist, "Spectation:" .. serverSpectatorsText);
                guiSetVisible(speclist, true);
                return;
            end;
        end;
    end;
    getCameraSpectateTarget = function() 
        return getElementData(localPlayer, "spectarget");
    end;
    getCameraSpectateMode = function() 
        return serverSpectateMode;
    end;
    spec_onClientTacticsChange = function(serverTacticsChangeData, __) 
        if serverTacticsChangeData[1] == "settings" and serverTacticsChangeData[2] == "spectate_enemy" and serverSpectateMode ~= "freecamera" then
            local serverCurrentSpecTarget = getElementData(localPlayer, "spectarget");
            if not serverCurrentSpecTarget or not isElement(serverCurrentSpecTarget) then
                switchSpectating();
            end;
        end;
    end;
    addEvent("onClientCameraSpectateStart");
    addEvent("onClientCameraSpectateStop");
    addEvent("onClientCameraSpectateTargetChange");
    addEvent("onClientCameraSpectateModeChange");
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientElementDataChange", root, onClientElementDataChange);
    addEventHandler("onClientPlayerQuit", root, onClientPlayerQuit);
    addEventHandler("onClientPlayerChangeNick", root, onClientPlayerChangeNick);
    addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn);
    addEventHandler("onClientElementStreamOut", root, onClientElementStreamOut);
    addCommandHandler("laser_aim", toggleLaseraim);
    bindKey("F", "down", "laser_aim");
end)();
(function(...) 
    local serverMaxPlayers = 0;
    local serverCustomColumns = {};
    local serverRowReferences = {};
    onClientResourceStart = function(__) 
        tab_window = guiCreateGridList(0.5 * xscreen - 280, 0.5 * yscreen - 180, 560, 360, false);
        guiSetAlpha(tab_window, 0.8);
        guiSetVisible(tab_window, false);
        tab_label1 = guiCreateLabel(10, 0, 550, 20, "", false, tab_window);
        tab_label2 = guiCreateLabel(0, 0, 550, 20, "", false, tab_window);
        guiLabelSetHorizontalAlign(tab_label2, "right");
        guiLabelSetVerticalAlign(tab_label1, "center");
        guiLabelSetVerticalAlign(tab_label2, "center");
        tab_list = guiCreateGridList(5, 20, 535, 355, false, tab_window);
        guiGridListSetSortingEnabled(tab_list, false);
        tab_id = guiGridListAddColumn(tab_list, "ID", 0.06);
        tab_name = guiGridListAddColumn(tab_list, "Name", 0.24);
        tab_score = guiGridListAddColumn(tab_list, "Score", 0.07);
        tab_status = guiGridListAddColumn(tab_list, "Status", 0.1);
        tab_fps = guiGridListAddColumn(tab_list, "FPS", 0.06);
        tab_packet = guiGridListAddColumn(tab_list, "Loss", 0.06);
        tab_ping = guiGridListAddColumn(tab_list, "Ping", 0.06);
    end;
    onClientTabboardChange = function(serverTabboardData, serverServerName, serverMaxSlots, serverServerInfo) 
        if serverServerName then
            serverMaxPlayers = serverMaxSlots;
            guiSetText(tab_label1, serverServerName .. " [" .. serverServerInfo.os .. "]");
            guiSetText(tab_label2, #getElementsByType("player") .. "/" .. serverMaxSlots);
        end;
        if not tab_packet then
            return;
        else
            for __, __ in pairs(serverCustomColumns) do
                guiGridListRemoveColumn(tab_list, tab_packet + 1);
            end;
            guiGridListRemoveColumn(tab_list, tab_packet + 1);
            serverCustomColumns = {};
            for __, serverColumnData in ipairs(serverTabboardData) do
                serverCustomColumns[serverColumnData[1]] = guiGridListAddColumn(tab_list, serverColumnData[1], serverColumnData[2]);
            end;
            tab_ping = guiGridListAddColumn(tab_list, "Ping", 0.06);
            if guiGetVisible(tab_window) then
                refreshElements();
            end;
            return;
        end;
    end;
    refreshElements = function() 
        guiSetText(tab_label2, #getElementsByType("player") .. "/" .. serverMaxPlayers);
        guiGridListClear(tab_list);
        serverRowReferences = {};
        for __, serverTabPlayer in ipairs(getElementsByType("player")) do
            if not getPlayerTeam(serverTabPlayer) then
                serverRowReferences[serverTabPlayer] = guiGridListAddRow(tab_list);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_id, getElementID(serverTabPlayer) or "", false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_name, removeColorCoding(getPlayerName(serverTabPlayer)), false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_score, getElementData(serverTabPlayer, "Score") and tostring(getElementData(serverTabPlayer, "Score")) or "", false, false);
                local serverPlayerStatus = getElementData(serverTabPlayer, "Status") or "";
                if serverPlayerStatus == "Play" and getTacticsData("settings", "player_information") == "true" then
                    serverPlayerStatus = tostring(math.floor(getElementHealth(serverTabPlayer) + getPedArmor(serverTabPlayer)));
                end;
                if serverPlayerStatus == "Spectate" then
                    serverPlayerStatus = "";
                end;
                if getElementData(serverTabPlayer, "Loading") then
                    serverPlayerStatus = "Loading";
                end;
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_status, serverPlayerStatus, false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_fps, tostring(getElementData(serverTabPlayer, "FPS") or ""), false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_packet, string.format("%.2f", getElementData(serverTabPlayer, "PLoss") or 0), false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], tab_ping, tostring(getPlayerPing(serverTabPlayer)), false, false);
                for serverColumnName, serverColumnID in pairs(serverCustomColumns) do
                    guiGridListSetItemText(tab_list, serverRowReferences[serverTabPlayer], serverColumnID, getElementData(serverTabPlayer, serverColumnName) and tostring(getElementData(serverTabPlayer, serverColumnName)) or "", false, false);
                end;
            end;
        end;
        local serverTeamList = getElementsByType("team");
        table.insert(serverTeamList, serverTeamList[1]);
        table.remove(serverTeamList, 1);
        for serverTeamIndex, serverTeamElement in ipairs(serverTeamList) do
            local serverTeamColorR, serverTeamColorG, serverTeamColorB = getTeamColor(serverTeamElement);
            serverRowReferences[serverTeamElement] = guiGridListAddRow(tab_list);
            guiGridListSetItemText(tab_list, serverRowReferences[serverTeamElement], tab_score, getElementData(serverTeamElement, "Score") and tostring(getElementData(serverTeamElement, "Score")) or "", true, false);
            for serverTeamColumnName, serverTeamColumnID in pairs(serverCustomColumns) do
                if getElementData(serverTeamElement, serverTeamColumnName) then
                    guiGridListSetItemText(tab_list, serverRowReferences[serverTeamElement], serverTeamColumnID, tostring(getElementData(serverTeamElement, serverTeamColumnName)), true, false);
                end;
            end;
            local serverAlivePlayersCount = 0;
            for __, serverTeamPlayer in ipairs(getPlayersInTeam(serverTeamElement)) do
                serverRowReferences[serverTeamPlayer] = guiGridListAddRow(tab_list);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_id, getElementID(serverTeamPlayer) or "", false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_name, removeColorCoding(getPlayerName(serverTeamPlayer)), false, false);
                guiGridListSetItemColor(tab_list, serverRowReferences[serverTeamPlayer], tab_name, serverTeamColorR, serverTeamColorG, serverTeamColorB);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_score, getElementData(serverTeamPlayer, "Score") and tostring(getElementData(serverTeamPlayer, "Score")) or "", false, false);
                local serverTeamPlayerStatus = getElementData(serverTeamPlayer, "Status") or "";
                if serverTeamPlayerStatus == "Play" then
                    serverAlivePlayersCount = serverAlivePlayersCount + 1;
                    if getTacticsData("settings", "player_information") == "true" then
                        serverTeamPlayerStatus = serverTeamIndex < #serverTeamList and tostring(math.floor(getElementHealth(serverTeamPlayer) + getPedArmor(serverTeamPlayer))) or "";
                    end;
                end;
                if serverTeamPlayerStatus == "Spectate" then
                    serverTeamPlayerStatus = "";
                end;
                if getElementData(serverTeamPlayer, "Loading") then
                    serverTeamPlayerStatus = "Loading";
                end;
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_status, serverTeamPlayerStatus, false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_fps, tostring(getElementData(serverTeamPlayer, "FPS") or ""), false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_packet, string.format("%.2f", getElementData(serverTeamPlayer, "PLoss") or 0), false, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], tab_ping, tostring(getPlayerPing(serverTeamPlayer)), false, false);
                for serverPlayerColumnName, serverPlayerColumnID in pairs(serverCustomColumns) do
                    guiGridListSetItemText(tab_list, serverRowReferences[serverTeamPlayer], serverPlayerColumnID, serverTeamIndex < #serverTeamList and getElementData(serverTeamPlayer, serverPlayerColumnName) and tostring(getElementData(serverTeamPlayer, serverPlayerColumnName)) or "", false, false);
                end;
            end;
            if serverTeamIndex < #serverTeamList then
                local serverTeamSides = getTacticsData("Teamsides") or {};
                local serverSideNames = getTacticsData("SideNames") or {};
                local serverTeamSideName = "";
                if serverTeamSides[serverTeamElement] then
                    serverTeamSideName = serverSideNames[(serverTeamSides[serverTeamElement] - 1) % #serverSideNames + 1];
                end;
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamElement], tab_name, getTeamName(serverTeamElement) .. " (" .. serverTeamSideName .. ")", true, false);
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamElement], tab_status, serverAlivePlayersCount .. " / " .. countPlayersInTeam(serverTeamElement), true, false);
                guiGridListSetItemColor(tab_list, serverRowReferences[serverTeamElement], tab_status, serverTeamColorR, serverTeamColorG, serverTeamColorB);
            else
                guiGridListSetItemText(tab_list, serverRowReferences[serverTeamElement], tab_name, getTeamName(serverTeamElement), true, false);
            end;
            guiGridListSetItemColor(tab_list, serverRowReferences[serverTeamElement], tab_name, serverTeamColorR, serverTeamColorG, serverTeamColorB);
        end;
        guiGridListSetSelectedItem(tab_list, serverRowReferences[localPlayer], tab_name);
        local serverRowCount = guiGridListGetRowCount(tab_list);
        local serverWindowHeight = math.min(14 * serverRowCount + 60, yscreen);
        local __, serverCurrentHeight = guiGetSize(tab_list, false);
        if serverWindowHeight ~= serverCurrentHeight then
            guiSetSize(tab_window, 560, serverWindowHeight, false);
            guiSetPosition(tab_window, 0.5 * xscreen - 280, 0.5 * yscreen - 0.5 * serverWindowHeight, false);
            guiSetSize(tab_list, 550, serverWindowHeight - 20 - 5, false);
        end;
    end;
    refreshData = function(serverDataElement, serverDataKey, serverDataValue) 
        if not serverRowReferences[serverDataElement] then
            return;
        else
            serverDataValue = not serverDataValue and "" or tostring(serverDataValue);
            if getElementType(serverDataElement) == "team" then
                if serverCustomColumns[serverDataKey] then
                    guiGridListSetItemText(tab_list, serverRowReferences[serverDataElement], serverCustomColumns[serverDataKey], serverDataValue, true, false);
                end;
            elseif serverDataKey == "Status" then
                local serverUpdatedStatus = getElementData(serverDataElement, "Status") or "";
                if serverUpdatedStatus == "Play" and getTacticsData("settings", "player_information") == "true" then
                    serverUpdatedStatus = tostring(math.floor(getElementHealth(serverDataElement) + getPedArmor(serverDataElement)));
                end;
                if serverUpdatedStatus == "Spectate" then
                    serverUpdatedStatus = "";
                end;
                if getElementData(serverDataElement, "Loading") then
                    serverUpdatedStatus = "Loading";
                end;
                guiGridListSetItemText(tab_list, serverRowReferences[serverDataElement], tab_status, serverUpdatedStatus, false, false);
            elseif serverDataKey == "FPS" then
                guiGridListSetItemText(tab_list, serverRowReferences[serverDataElement], tab_fps, serverDataValue, false, false);
            elseif serverDataKey == "PLoss" then
                guiGridListSetItemText(tab_list, serverRowReferences[serverDataElement], tab_packet, string.format("%.2f", serverDataValue or 0), false, false);
            elseif serverCustomColumns[serverDataKey] then
                guiGridListSetItemText(tab_list, serverRowReferences[serverDataElement], serverCustomColumns[serverDataKey], serverDataValue, false, false);
            end;
            return;
        end;
    end;
    refreshPings = function() 
        local serverFirstTeam = getElementsByType("team")[1];
        for __, serverPingPlayer in ipairs(getElementsByType("player")) do
            if getElementData(serverPingPlayer, "Status") == "Play" and getPlayerTeam(serverPingPlayer) ~= serverFirstTeam and getTacticsData("settings", "player_information") == "true" and not getElementData(serverPingPlayer, "Loading") then
                guiGridListSetItemText(tab_list, serverRowReferences[serverPingPlayer], tab_status, tostring(math.floor(getElementHealth(serverPingPlayer) + getPedArmor(serverPingPlayer))), false, false);
            end;
            guiGridListSetItemText(tab_list, serverRowReferences[serverPingPlayer], tab_ping, tostring(getPlayerPing(serverPingPlayer)), false, false);
        end;
        if guiGetVisible(tab_list) then
            setTimer(refreshPings, 500, 1);
        end;
    end;
    toggleTabboard = function(__, serverKeyState) 
        if not guiGetVisible(tab_window) and serverKeyState == "down" then
            refreshElements();
            setTimer(refreshPings, 500, 1);
            guiBringToFront(tab_window);
            guiSetVisible(tab_window, true);
            addEventHandler("onClientElementDataChange", root, refreshElementData);
            addEventHandler("onClientPlayerChangeNick", root, refreshNick);
            addEventHandler("onClientPlayerJoin", root, refreshElements);
            addEventHandler("onClientPlayerQuit", root, refreshQuit);
            bindKey("mouse2", "both", toggleCursor);
        elseif guiGetVisible(tab_window) and serverKeyState == "up" then
            removeEventHandler("onClientElementDataChange", root, refreshElementData);
            removeEventHandler("onClientPlayerChangeNick", root, refreshNick);
            removeEventHandler("onClientPlayerJoin", root, refreshElements);
            removeEventHandler("onClientPlayerQuit", root, refreshQuit);
            unbindKey("mouse2", "both", toggleCursor);
            guiSetVisible(tab_window, false);
            if getKeyState("mouse2") and isAllGuiHidden() then
                showCursor(false);
            end;
        end;
    end;
    toggleCursor = function(__, serverMouseState) 
        if guiGetVisible(tab_list) and serverMouseState == "down" then
            showCursor(true);
        elseif guiGetVisible(tab_list) and serverMouseState == "up" and isAllGuiHidden() then
            showCursor(false);
        end;
    end;
    refreshElementData = function(serverChangedData, __) 
        if getElementType(source) == "team" or getElementType(source) == "player" then
            if serverChangedData == "Loading" then
                refreshData(source, "Status");
            else
                refreshData(source, serverChangedData, getElementData(source, serverChangedData));
            end;
        end;
    end;
    refreshNick = function(__, serverNewNickname) 
        guiGridListSetItemText(tab_list, serverRowReferences[source], tab_name, removeColorCoding(serverNewNickname), false, false);
    end;
    refreshQuit = function() 
        setTimer(refreshElements, 50, 1);
    end;
    addEvent("onClientTabboardChange", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientTabboardChange", root, onClientTabboardChange);
    bindKey("tab", "both", toggleTabboard);
end)();
(function(...) 
    local serverValidProperties = {
        invulnerable = true, 
        invisible = true, 
        freezable = true, 
        flammable = true, 
        movespeed = true, 
        regenerable = true
    };
    local __ = {
        freezable = 0, 
        flammable = 0
    };
    local serverActiveProperties = {};
    setPlayerProperty = function(serverPropertyName, serverPropertyValue) 
        if not serverValidProperties[serverPropertyName] then
            return false;
        else
            local serverPlayerProperties = getElementData(localPlayer, "Properties") or {};
            if serverPropertyValue ~= nil and serverPropertyValue ~= false then
                serverPlayerProperties[serverPropertyName] = serverPropertyValue;
            else
                serverPlayerProperties[serverPropertyName] = nil;
            end;
            return setElementData(localPlayer, "Properties", serverPlayerProperties);
        end;
    end;
    givePlayerProperty = function(serverTimedPropertyName, serverTimedValue, serverDuration) 
        if not serverValidProperties[serverTimedPropertyName] then
            return false;
        else
            local serverTimedProperties = getElementData(localPlayer, "Properties") or {};
            if serverTimedValue ~= nil and serverTimedValue ~= false then
                serverTimedProperties[serverTimedPropertyName] = {
                    serverTimedValue, 
                    serverDuration
                };
            else
                serverTimedProperties[serverTimedPropertyName] = nil;
            end;
            return setElementData(localPlayer, "Properties", serverTimedProperties);
        end;
    end;
    getPlayerProperty = function(serverPropertyPlayer, serverPropertyKey) 
        if not serverPropertyPlayer or not isElement(serverPropertyPlayer) or not serverValidProperties[serverPropertyKey] then
            return false;
        else
            local serverPropertyData = getElementData(localPlayer, "Properties") or {};
            if type(serverPropertyData[serverPropertyKey]) == "table" then
                return unpack(serverPropertyData[serverPropertyKey]);
            else
                return serverPropertyData[serverPropertyKey];
            end;
        end;
    end;
    onClientPlayerInvulnerable = function(__, __, __, __) 
        cancelEvent();
    end;
    onClientMovespeedRender = function() 
        local serverSpeedMultiplier = type(serverActiveProperties.movespeed) == "table" and serverActiveProperties.movespeed[1] or serverActiveProperties.movespeed;
        local serverFrameTime = 1000 / getElementData(localPlayer, "FPS") * getGameSpeed();
        local serverVelocityX, serverVelocityY = getElementVelocity(localPlayer);
        local serverContactElement = getPedContactElement(localPlayer);
        if serverContactElement then
            local serverElementVelX, serverElementVelY = getElementVelocity(serverContactElement);
            local serverRelativeVelX = serverVelocityX - serverElementVelX;
            serverVelocityY = serverVelocityY - serverElementVelY;
            serverVelocityX = serverRelativeVelX;
        end;
        if math.sqrt(serverVelocityX ^ 2 + serverVelocityY ^ 2) > 0.02 then
            local serverPlayerXPos, serverPlayerYPos, serverPlayerZPos = getElementPosition(localPlayer);
            local serverNewXPos = serverPlayerXPos + (serverSpeedMultiplier - 1) * serverFrameTime * (200 * serverVelocityX / 3600);
            local serverNewYPos = serverPlayerYPos + (serverSpeedMultiplier - 1) * serverFrameTime * (200 * serverVelocityY / 3600);
            local serverAdjustedPlayerZ = serverPlayerZPos;
            if serverContactElement then
                local serverContactVelX, serverContactVelY, serverContactVelZ = getElementVelocity(serverContactElement);
                serverNewXPos = serverNewXPos + serverFrameTime * (200 * serverContactVelX / 3600);
                serverNewYPos = serverNewYPos + serverFrameTime * (200 * serverContactVelY / 3600);
                serverAdjustedPlayerZ = serverAdjustedPlayerZ + serverFrameTime * (200 * serverContactVelZ / 3600);
            end;
            if isLineOfSightClear(serverPlayerXPos, serverPlayerYPos, serverPlayerZPos, serverNewXPos, serverNewYPos, serverAdjustedPlayerZ, true, true, true, true, true, false, false, localPlayer) then
                setElementPosition(localPlayer, serverNewXPos, serverNewYPos, serverAdjustedPlayerZ, false);
            end;
        end;
    end;
    onClientPropertiesRender = function(serverDeltaTime) 
        local serverAdjustedDelta = serverDeltaTime * getGameSpeed();
        local serverIconXPosition = xscreen * 0.06;
        for serverPropertyType, serverPropertyInfo in pairs(serverActiveProperties) do
            local serverIconImage = "images/" .. serverPropertyType .. ".png";
            local serverPropertyParam1, serverPropertyParam2, serverPropertyParam3 = unpack(type(serverPropertyInfo) == "table" and serverPropertyInfo or {
                serverPropertyInfo
            });
            if serverPropertyType == "invulnerable" then
                local serverStartHealth = tonumber(getTacticsData("settings", "player_start_health"));
                setElementHealth(localPlayer, serverStartHealth);
            elseif serverPropertyType == "movespeed" then
                serverIconImage = serverPropertyParam1 < 1 and "images/speeddown.png" or "images/speedup.png";
            elseif serverPropertyType == "regenerable" then
                setElementHealth(localPlayer, getElementHealth(localPlayer) + 0.001 * serverPropertyParam1 * serverAdjustedDelta);
            end;
            local serverTimeRatio = nil;
            if serverPropertyParam3 then
                serverPropertyParam2 = math.max(serverPropertyParam2 - serverAdjustedDelta, 0);
                serverActiveProperties[serverPropertyType] = {
                    serverPropertyParam1, 
                    serverPropertyParam2, 
                    serverPropertyParam3
                };
                serverTimeRatio = serverPropertyParam2 / serverPropertyParam3;
                if serverTimeRatio <= 0 then
                    serverTimeRatio = 0;
                    local serverUpdatedProperties = getElementData(localPlayer, "Properties") or {};
                    serverUpdatedProperties[serverPropertyType] = nil;
                    setElementData(localPlayer, "Properties", serverUpdatedProperties);
                end;
            end;
            dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, serverIconImage, 0, 0, 0, white);
            if serverTimeRatio then
                if serverTimeRatio >= 1 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_100.png", 0, 0, 0, white);
                elseif serverTimeRatio > 0.5 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_50.png", 0, 0, 0, white);
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_50.png", -360 * (serverTimeRatio - 0.5), 0, 0, white);
                elseif serverTimeRatio > 0.25 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_25.png", 0, 0, 0, white);
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_25.png", -360 * (serverTimeRatio - 0.25), 0, 0, white);
                elseif serverTimeRatio > 0.125 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_12.png", 0, 0, 0, white);
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_12.png", -360 * (serverTimeRatio - 0.125), 0, 0, white);
                elseif serverTimeRatio > 0.0625 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_6.png", 0, 0, 0, white);
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_6.png", -360 * (serverTimeRatio - 0.0625), 0, 0, white);
                elseif serverTimeRatio > 0.03125 then
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_3.png", 0, 0, 0, white);
                    dxDrawImage(serverIconXPosition, yscreen * 0.75 - 32, 32, 32, "images/factor_3.png", -360 * (serverTimeRatio - 0.03125), 0, 0, white);
                end;
            end;
            serverIconXPosition = serverIconXPosition + 48;
        end;
    end;
    onClientWallhackRender = function() 
        if getCameraGoggleEffect() ~= "thermalvision" then
            return;
        else
            local function v2127(serverWallhackPlayer, serverBoneID1, serverBoneID2) 
                local serverBone1X, serverBone1Y, serverBone1Z = getPedBonePosition(serverWallhackPlayer, serverBoneID1);
                local serverBone2X, serverBone2Y, serverBone2Z = getPedBonePosition(serverWallhackPlayer, serverBoneID2);
                local serverDistanceToCamera = getDistanceBetweenPoints3D(serverBone1X, serverBone1Y, serverBone1Z, getCameraMatrix());
                local serverScreenPos1X, serverScreenPos1Y = getScreenFromWorldPosition(serverBone1X, serverBone1Y, serverBone1Z, 360, false);
                local serverScreenPos2X, serverScreenPos2Y = getScreenFromWorldPosition(serverBone2X, serverBone2Y, serverBone2Z, 360, false);
                if serverScreenPos1X and serverScreenPos2X then
                    local serverCenterX = (serverScreenPos1X + serverScreenPos2X) / 2;
                    local serverCenterY = (serverScreenPos1Y + serverScreenPos2Y) / 2;
                    local serverWidthFactor = xscreen * 0.3 / math.max(1, serverDistanceToCamera);
                    local serverHeightFactor = 2 * getDistanceBetweenPoints2D(serverScreenPos1X, serverScreenPos1Y, serverScreenPos2X, serverScreenPos2Y);
                    local serverRotationAngle = getAngleBetweenPoints2D(serverScreenPos1X, serverScreenPos1Y, serverScreenPos2X, serverScreenPos2Y);
                    serverHeightFactor = math.max(serverWidthFactor, serverHeightFactor);
                    local serverAlphaValue = 255 / math.max(1, 0.3 * serverDistanceToCamera);
                    dxDrawImage(serverCenterX - serverWidthFactor * 0.5, serverCenterY - serverHeightFactor * 0.5, serverWidthFactor, serverHeightFactor, "images/sphere.png", serverRotationAngle, 0, 0, tocolor(255, 64, 0, serverAlphaValue));
                end;
            end;
            for __, serverThermalPlayer in ipairs(getElementsByType("player", root, true)) do
                v2127(serverThermalPlayer, 6, 7);
                for serverHeadBone = 2, 4 do
                    v2127(serverThermalPlayer, serverHeadBone - 1, serverHeadBone);
                end;
                for serverSpineBone = 22, 25 do
                    v2127(serverThermalPlayer, serverSpineBone - 1, serverSpineBone);
                end;
                for serverArmBone = 32, 35 do
                    v2127(serverThermalPlayer, serverArmBone - 1, serverArmBone);
                end;
                for serverHandBone = 42, 44 do
                    v2127(serverThermalPlayer, serverHandBone - 1, serverHandBone);
                end;
                for serverLegBone = 52, 54 do
                    v2127(serverThermalPlayer, serverLegBone - 1, serverLegBone);
                end;
            end;
            return;
        end;
    end;
    onClientResourceStart = function() 
        for __, serverOtherPlayer in ipairs(getElementsByType("player")) do
            if (getElementData(localPlayer, "Properties") or {}).invisible then
                setElementAlpha(serverOtherPlayer, 2);
            end;
        end;
    end;
    onClientPlayerPropertiesChange = function(serverChangedProperty, serverOldPropertyData) 
        if getElementType(source) ~= "player" then
            return;
        elseif serverChangedProperty ~= "Properties" then
            return;
        else
            local serverNewPropertyData = getElementData(source, "Properties");
            if not serverOldPropertyData or serverNewPropertyData.invisible ~= serverOldPropertyData.invisible then
                if serverNewPropertyData.invisible then
                    setElementAlpha(source, 2);
                else
                    setElementAlpha(source, 255);
                end;
                triggerEvent("onClientPlayerBlipUpdate", source);
            end;
            return;
        end;
    end;
    onClientPropertiesChange = function(serverLocalDataName, serverLocalOldData) 
        if serverLocalDataName ~= "Properties" then
            return;
        else
            local serverLocalProperties = getElementData(localPlayer, "Properties");
            if (not serverLocalOldData or next(serverLocalOldData)) and not next(serverLocalProperties) then
                removeEventHandler("onClientPreRender", root, onClientPropertiesRender);
            end;
            for serverPropertyCheck in pairs(serverValidProperties) do
                if not serverLocalOldData or type(serverLocalProperties[serverPropertyCheck]) ~= type(serverLocalOldData[serverPropertyCheck]) or type(serverLocalProperties[serverPropertyCheck]) ~= "table" and serverLocalProperties[serverPropertyCheck] ~= serverLocalOldData[serverPropertyCheck] or type(serverLocalProperties[serverPropertyCheck]) == "table" and (serverLocalProperties[serverPropertyCheck][1] ~= serverLocalOldData[serverPropertyCheck][1] or serverLocalProperties[serverPropertyCheck][2] ~= serverLocalOldData[serverPropertyCheck][2]) then
                    if serverLocalProperties[serverPropertyCheck] then
                        if type(serverLocalProperties[serverPropertyCheck]) == "table" then
                            local serverTimedPropValue, serverTimedPropDuration = unpack(serverLocalProperties[serverPropertyCheck]);
                            serverActiveProperties[serverPropertyCheck] = {
                                serverTimedPropValue, 
                                serverTimedPropDuration, 
                                serverTimedPropDuration
                            };
                        else
                            serverActiveProperties[serverPropertyCheck] = serverLocalProperties[serverPropertyCheck];
                        end;
                        if not serverLocalOldData or not serverLocalOldData[serverPropertyCheck] then
                            if serverPropertyCheck == "invulnerable" then
                                addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerInvulnerable);
                            end;
                            if serverPropertyCheck == "movespeed" then
                                addEventHandler("onClientRender", root, onClientMovespeedRender);
                            end;
                        end;
                    elseif serverLocalOldData and serverLocalOldData[serverPropertyCheck] then
                        if serverPropertyCheck == "invulnerable" then
                            removeEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerInvulnerable);
                        end;
                        if serverPropertyCheck == "movespeed" then
                            removeEventHandler("onClientRender", root, onClientMovespeedRender);
                        end;
                        serverActiveProperties[serverPropertyCheck] = nil;
                    end;
                end;
            end;
            if (not serverLocalOldData or not next(serverLocalOldData)) and next(serverLocalProperties) then
                addEventHandler("onClientPreRender", root, onClientPropertiesRender);
            end;
            return;
        end;
    end;
    addEventHandler("onClientElementDataChange", root, onClientPlayerPropertiesChange);
    addEventHandler("onClientElementDataChange", localPlayer, onClientPropertiesChange);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientHUDRender", root, onClientWallhackRender);
end)();
(function(...) 
    local serverCurrentVote = nil;
    local serverVoteLabels = {};
    local serverVoteTimer = nil;
    onClientResourceStart = function(__) 
        vote_window = guiCreateWindow(0.5 * xscreen - 150, 0.5 * yscreen - 200, 300, 400, "Map manager", false);
        guiWindowSetSizable(vote_window, false);
        guiSetVisible(vote_window, false);
        vote_maps = guiCreateGridList(0.02, 0.12, 0.96, 0.79, true, vote_window);
        guiGridListSetSortingEnabled(vote_maps, false);
        guiGridListAddColumn(vote_maps, "Mode", 0.3);
        guiGridListAddColumn(vote_maps, "Name", 0.6);
        vote_search = guiCreateEdit(0.02, 0.06, 0.96, 0.055, "", true, vote_window);
        guiSetEnabled(guiCreateStaticImage(0.925, 0.1, 0.065, 0.8, "images/search.png", true, vote_search), false);
        vote_view = guiCreateButton(0.02, 0.92, 0.31, 0.06, "Preview", true, vote_window);
        addEventHandler("onClientGUIClick", vote_view, onClientGUIClick_vote_view);
        guiSetFont(vote_view, "default-bold-small");
        vote_add = guiCreateButton(0.35, 0.92, 0.31, 0.06, "Vote", true, vote_window);
        addEventHandler("onClientGUIClick", vote_add, onClientGUIClick_vote_add);
        guiSetFont(vote_add, "default-bold-small");
        guiSetProperty(vote_add, "NormalTextColour", "C000FF00");
        vote_close = guiCreateButton(0.67, 0.92, 0.31, 0.06, "Close", true, vote_window);
        addEventHandler("onClientGUIClick", vote_close, onClientGUIClick_vote_close);
        guiSetFont(vote_close, "default-bold-small");
        voting_window = guiCreateWindow(xscreen - 200, yscreen - 200 - xscreen * 0.03, 200, 200, "Voting", false);
        guiSetVisible(voting_window, false);
        guiWindowSetMovable(voting_window, false);
        guiWindowSetSizable(voting_window, false);
    end;
    updateVoting = function() 
        local serverVotingData = getTacticsData("voting");
        if serverVotingData and serverVotingData.rows and #serverVotingData.rows > 0 then
            local serverMaxLabelWidth = 0;
            for serverVoteIndex = 1, math.max(#serverVotingData.rows + 1, #serverVoteLabels) do
                if serverVoteIndex <= #serverVotingData.rows then
                    local serverVoteRow = serverVotingData.rows[serverVoteIndex];
                    if #serverVoteLabels < serverVoteIndex then
                        serverVoteLabels[serverVoteIndex] = guiCreateLabel(20, 5 + serverVoteIndex * 20, xscreen, 40, serverVoteIndex .. " - " .. (serverVoteRow.label or serverVoteRow.resname) .. " (" .. tonumber(serverVoteRow.votes) .. ")", false, voting_window);
                        guiSetFont(serverVoteLabels[serverVoteIndex], "default-bold-small");
                    else
                        guiSetText(serverVoteLabels[serverVoteIndex], serverVoteIndex .. " - " .. (serverVoteRow.label or serverVoteRow.resname) .. " (" .. tonumber(serverVoteRow.votes) .. ")");
                    end;
                    if serverCurrentVote == serverVoteIndex then
                        guiLabelSetColor(serverVoteLabels[serverVoteIndex], 255, 128, 0);
                    else
                        guiLabelSetColor(serverVoteLabels[serverVoteIndex], 255, 255, 255);
                    end;
                    local serverRowWidth = dxGetTextWidth(serverVoteIndex .. " - " .. (serverVoteRow.label or serverVoteRow.resname) .. " (" .. tonumber(serverVoteRow.votes) .. ")", 1, "default-bold");
                    if serverMaxLabelWidth < serverRowWidth + 40 then
                        serverMaxLabelWidth = serverRowWidth + 40;
                    end;
                elseif serverVoteIndex == #serverVotingData.rows + 1 then
                    if #serverVoteLabels < serverVoteIndex then
                        serverVoteLabels[serverVoteIndex] = guiCreateLabel(20, 5 + serverVoteIndex * 20, xscreen, 40, "0 - Cancel (" .. tonumber(serverVotingData.cancel) .. ")", false, voting_window);
                        guiSetFont(serverVoteLabels[serverVoteIndex], "default-bold-small");
                    else
                        guiSetText(serverVoteLabels[serverVoteIndex], "0 - Cancel (" .. tonumber(serverVotingData.cancel) .. ")");
                    end;
                    if serverCurrentVote == 0 then
                        guiLabelSetColor(serverVoteLabels[serverVoteIndex], 255, 128, 0);
                    else
                        guiLabelSetColor(serverVoteLabels[serverVoteIndex], 255, 255, 255);
                    end;
                    local serverCancelWidth = dxGetTextWidth("0 - Cancel (" .. tonumber(serverVotingData.cancel) .. ")", 1, "default-bold");
                    if serverMaxLabelWidth < serverCancelWidth + 40 then
                        serverMaxLabelWidth = serverCancelWidth + 40;
                    end;
                else
                    destroyElement(serverVoteLabels[serverVoteIndex]);
                    serverVoteLabels[serverVoteIndex] = nil;
                end;
            end;
            height = (#serverVotingData.rows + 1) * 20 + 30;
            guiSetPosition(voting_window, xscreen - serverMaxLabelWidth, yscreen - height, false);
            guiSetSize(voting_window, serverMaxLabelWidth, height, false);
            guiBringToFront(voting_window);
            guiSetVisible(voting_window, true);
        else
            guiSetVisible(voting_window, false);
            serverCurrentVote = nil;
        end;
    end;
    updateVoteTime = function(serverRemainingTime) 
        if serverRemainingTime > 0 then
            guiSetText(voting_window, "Voting ... " .. serverRemainingTime .. " sec");
            serverVoteTimer = setTimer(updateVoteTime, 1000, 1, serverRemainingTime - 1);
        end;
    end;
    setVote = function(__, __, serverVoteChoice) 
        local serverVoteInfo = getTacticsData("voting");
        if serverVoteInfo and serverVoteInfo.rows and #serverVoteInfo.rows > 0 and (not serverVoteChoice or serverVoteChoice <= #serverVoteInfo.rows) then
            triggerServerEvent("onPlayerVote", localPlayer, serverVoteChoice, serverCurrentVote);
            serverCurrentVote = serverVoteChoice;
        end;
    end;
    commandVote = function(__, serverVoteMode, serverVoteMap) 
        if not serverVoteMode or not serverVoteMap then
            return outputChatBox(getLanguageString("syntax_vote"), 255, 100, 100, true);
        else
            local serverDefinedModes = getTacticsData("modes_defined") or {};
            local serverModesList = getLanguageString("supported_modes");
            for serverModeName in pairs(serverDefinedModes) do
                serverModesList = serverModesList .. serverModeName .. ", ";
                if serverVoteMode == serverModeName then
                    return triggerServerEvent("onPlayerVote", localPlayer, serverVoteMode .. "_" .. serverVoteMap, nil, "map");
                end;
            end;
            outputChatBox(string.sub(serverModesList, 1, -3), 255, 100, 100, true);
            return;
        end;
    end;
    onClientGUIClick_vote_view = function(serverClickButton, __, __, __) 
        if serverClickButton ~= "left" then
            return;
        else
            if isElement(previewRoot) then
                setElementDimension(localPlayer, 0);
                removeEventHandler("onClientPlayerSpawn", localPlayer, Preview_onClientPlayerSpawn);
                removeEventHandler("onClientElementDataChange", localPlayer, Preview_onClientElementDataChange);
                removeEventHandler("onClientRender", root, Preview_onClientRender);
                destroyElement(previewRoot);
                guiSetText(vote_view, "Preview");
                guiSetProperty(vote_view, "NormalTextColour", "C07C7C7C");
                if getTacticsData("Map") == "lobby" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] and not getElementData(localPlayer, "spectateskin") then
                    setElementData(localPlayer, "Status", "Play");
                    setCameraTarget(localPlayer);
                else
                    setCameraSpectating(nil, "playertarget");
                end;
            elseif getElementData(localPlayer, "Status") == "Play" and getTacticsData("Map") ~= "lobby" then
                return;
            else
                local serverSelectedRow = guiGridListGetSelectedItem(vote_maps);
                if serverSelectedRow < 0 then
                    return;
                else
                    local serverMapResource = guiGridListGetItemData(vote_maps, serverSelectedRow, 1);
                    triggerServerEvent("onPlayerPreview", localPlayer, serverMapResource);
                    guiSetText(vote_view, "Exit");
                    guiSetProperty(vote_view, "NormalTextColour", "C0FF0000");
                end;
            end;
            return;
        end;
    end;
    onClientGUIClick_vote_add = function(serverAddClickButton, __, __, __) 
        if serverAddClickButton ~= "left" then
            return;
        else
            local serverAddSelectedRow = guiGridListGetSelectedItem(vote_maps);
            if serverAddSelectedRow < 0 then
                return;
            else
                local serverAddMapResource = guiGridListGetItemData(vote_maps, serverAddSelectedRow, 1);
                triggerServerEvent("onPlayerVote", localPlayer, serverAddMapResource, nil, "map");
                guiSetVisible(vote_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                return;
            end;
        end;
    end;
    onClientGUIClick_vote_close = function(serverCloseClickButton, __, __, __) 
        if serverCloseClickButton ~= "left" then
            return;
        else
            guiSetVisible(vote_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            return;
        end;
    end;
    onClientGUIDoubleClick = function(serverDoubleClickButton, __, __, __) 
        if serverDoubleClickButton == "left" and source == vote_maps then
            local serverDoubleSelectedRow = guiGridListGetSelectedItem(vote_maps);
            if serverDoubleSelectedRow < 0 then
                return;
            else
                local serverDoubleMapResource = guiGridListGetItemData(vote_maps, serverDoubleSelectedRow, 1);
                triggerServerEvent("onPlayerVote", localPlayer, serverDoubleMapResource, nil, "map");
                guiSetVisible(vote_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
        end;
    end;
    onClientGUIChanged = function(__) 
        if source == vote_search then
            updateVoteMaps();
        end;
    end;
    local serverAvailableMaps = {};
    onClientMapsUpdate = function(serverMapsData) 
        serverAvailableMaps = serverMapsData;
        updateVoteMaps();
    end;
    updateVoteMaps = function() 
        local serverDisabledMaps = getTacticsData("map_disabled") or {};
        local serverSearchText = guiGetText(vote_search);
        local serverFilteredMaps = {};
        for __, serverMapEntry in ipairs(serverAvailableMaps) do
            local serverIsVisible = true;
            if #serverSearchText > 0 then
                for serverSearchWord in string.gmatch(serverSearchText, "[^ ]+") do
                    if string.sub(serverSearchWord, 1, 1) == "-" then
                        if #serverSearchWord > 1 then
                            serverSearchWord = string.sub(serverSearchWord, 2, -1);
                            if string.find(string.lower(serverMapEntry[2]), string.lower(serverSearchWord)) or string.find(string.lower(serverMapEntry[3]), string.lower(serverSearchWord)) then
                                serverIsVisible = false;
                            end;
                        end;
                    elseif not string.find(string.lower(serverMapEntry[2]), string.lower(serverSearchWord)) and not string.find(string.lower(serverMapEntry[3]), string.lower(serverSearchWord)) then
                        serverIsVisible = false;
                    end;
                end;
            end;
            if serverDisabledMaps[tostring(serverMapEntry[1])] or getTacticsData("modes", string.lower(serverMapEntry[2]), "enable") == "false" then
                serverIsVisible = false;
            end;
            if serverIsVisible then
                table.insert(serverFilteredMaps, serverMapEntry);
            end;
        end;
        table.sort(serverFilteredMaps, function(serverMapA, serverMapB) 
            return serverMapA[2] < serverMapB[2] or serverMapA[2] == serverMapB[2] and serverMapA[3] < serverMapB[3];
        end);
        local serverCurrentMapResource = getTacticsData("MapResName");
        local serverRowCountMaps = guiGridListGetRowCount(vote_maps);
        for serverMapIndex = 1, math.max(serverRowCountMaps, #serverFilteredMaps) do
            if serverMapIndex <= #serverFilteredMaps then
                local serverMapResName, serverMapMode, serverMapDisplayName, __, __ = unpack(serverFilteredMaps[serverMapIndex]);
                if serverRowCountMaps < serverMapIndex then
                    guiGridListAddRow(vote_maps);
                end;
                guiGridListSetItemText(vote_maps, serverMapIndex - 1, 1, serverMapMode, false, false);
                guiGridListSetItemData(vote_maps, serverMapIndex - 1, 1, serverMapResName);
                guiGridListSetItemText(vote_maps, serverMapIndex - 1, 2, serverMapDisplayName, false, false);
                if serverCurrentMapResource == serverMapResName then
                    if serverDisabledMaps[serverMapResName] or getTacticsData("modes", string.lower(serverMapMode), "enable") == "false" then
                        guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 1, 0, 128, 0);
                        guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 2, 0, 128, 0);
                    else
                        guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 1, 0, 255, 0);
                        guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 2, 0, 255, 0);
                    end;
                elseif serverDisabledMaps[serverMapResName] or getTacticsData("modes", string.lower(serverMapMode), "enable") == "false" then
                    guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 1, 128, 128, 128);
                    guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 2, 128, 128, 128);
                else
                    guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 1, 255, 255, 255);
                    guiGridListSetItemColor(vote_maps, serverMapIndex - 1, 2, 255, 255, 255);
                end;
            else
                guiGridListRemoveRow(vote_maps, #serverFilteredMaps);
            end;
        end;
    end;
    toggleVoting = function() 
        if not guiGetVisible(vote_window) then
            updateVoteMaps();
            guiBringToFront(vote_window);
            guiSetVisible(vote_window, true);
            showCursor(true);
        else
            guiSetVisible(vote_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
        end;
    end;
    onClientTacticsChange = function(serverTacticsChangePath, serverTacticsOldValue) 
        if serverTacticsChangePath[1] == "map_disabled" or serverTacticsChangePath[1] == "modes" and serverTacticsChangePath[3] == "enable" then
            updateVoteMaps();
        end;
        if serverTacticsChangePath[1] == "voting" then
            local serverUpdatedVotingData = getTacticsData("voting");
            if serverUpdatedVotingData and not serverTacticsOldValue and serverTacticsChangePath[2] == "start" then
                bindKey("1", "down", setVote, 1);
                bindKey("2", "down", setVote, 2);
                bindKey("3", "down", setVote, 3);
                bindKey("4", "down", setVote, 4);
                bindKey("5", "down", setVote, 5);
                bindKey("6", "down", setVote, 6);
                bindKey("7", "down", setVote, 7);
                bindKey("8", "down", setVote, 8);
                bindKey("9", "down", setVote, 9);
                bindKey("0", "down", setVote, 0);
                bindKey("num_1", "down", setVote, 1);
                bindKey("num_2", "down", setVote, 2);
                bindKey("num_3", "down", setVote, 3);
                bindKey("num_4", "down", setVote, 4);
                bindKey("num_5", "down", setVote, 5);
                bindKey("num_6", "down", setVote, 6);
                bindKey("num_7", "down", setVote, 7);
                bindKey("num_8", "down", setVote, 8);
                bindKey("num_9", "down", setVote, 9);
                bindKey("num_0", "down", setVote, 0);
                bindKey("backspace", "down", setVote, nil);
                local serverTimeUntilVote = serverUpdatedVotingData.start - (getTickCount() + addTickCount);
                local serverSecondsRemaining = math.floor(serverTimeUntilVote / 1000);
                guiSetText(voting_window, "Voting ... " .. serverSecondsRemaining .. " sec");
                serverVoteTimer = setTimer(updateVoteTime, math.max(50, serverTimeUntilVote - serverSecondsRemaining * 1000), 1, serverSecondsRemaining);
            elseif not serverUpdatedVotingData and serverTacticsOldValue then
                if isTimer(serverVoteTimer) then
                    killTimer(serverVoteTimer);
                end;
                unbindKey("1", "down", setVote);
                unbindKey("2", "down", setVote);
                unbindKey("3", "down", setVote);
                unbindKey("4", "down", setVote);
                unbindKey("5", "down", setVote);
                unbindKey("6", "down", setVote);
                unbindKey("7", "down", setVote);
                unbindKey("8", "down", setVote);
                unbindKey("9", "down", setVote);
                unbindKey("0", "down", setVote);
                unbindKey("num_1", "down", setVote);
                unbindKey("num_2", "down", setVote);
                unbindKey("num_3", "down", setVote);
                unbindKey("num_4", "down", setVote);
                unbindKey("num_5", "down", setVote);
                unbindKey("num_6", "down", setVote);
                unbindKey("num_7", "down", setVote);
                unbindKey("num_8", "down", setVote);
                unbindKey("num_9", "down", setVote);
                unbindKey("num_0", "down", setVote);
                unbindKey("backspace", "down", setVote);
            end;
            updateVoting();
        end;
    end;
    onClientPreviewMapLoading = function(serverPreviewMapName, serverMapElements) 
        local serverAntiRushPoints = {};
        local serverCentralMarker = nil;
        local serverTeam1Spawns = {};
        local serverTeam2Spawns = {};
        local serverNeutralSpawns = {};
        for __, serverMapElement in ipairs(serverMapElements) do
            if serverMapElement[1] == "Anti_Rush_Point" then
                table.insert(serverAntiRushPoints, {
                    x = tonumber(serverMapElement[2].posX) or 0, 
                    y = tonumber(serverMapElement[2].posY) or 0, 
                    z = tonumber(serverMapElement[2].posZ) or 0
                });
            end;
            if serverMapElement[1] == "Central_Marker" then
                serverCentralMarker = {
                    x = tonumber(serverMapElement[2].posX) or 0, 
                    y = tonumber(serverMapElement[2].posY) or 0, 
                    z = tonumber(serverMapElement[2].posZ) or 0
                };
            end;
            if serverMapElement[1] == "Team1" then
                table.insert(serverTeam1Spawns, {
                    x = tonumber(serverMapElement[2].posX) or 0, 
                    y = tonumber(serverMapElement[2].posY) or 0, 
                    z = tonumber(serverMapElement[2].posZ) or 0, 
                    rot = tonumber(serverMapElement[2].rotation) or tonumber(serverMapElement[2].rotZ) or 0
                });
            end;
            if serverMapElement[1] == "Team2" then
                table.insert(serverTeam2Spawns, {
                    x = tonumber(serverMapElement[2].posX) or 0, 
                    y = tonumber(serverMapElement[2].posY) or 0, 
                    z = tonumber(serverMapElement[2].posZ) or 0, 
                    rot = tonumber(serverMapElement[2].rotation) or tonumber(serverMapElement[2].rotZ) or 0
                });
            end;
            if serverMapElement[1] == "spawnpoint" then
                table.insert(serverNeutralSpawns, {
                    x = tonumber(serverMapElement[2].posX) or 0, 
                    y = tonumber(serverMapElement[2].posY) or 0, 
                    z = tonumber(serverMapElement[2].posZ) or 0, 
                    rot = tonumber(serverMapElement[2].rotation) or tonumber(serverMapElement[2].rotZ) or 0
                });
            end;
        end;
        if not serverCentralMarker then
            guiSetText(vote_view, "Preview");
            guiSetProperty(vote_view, "NormalTextColour", "C07C7C7C");
            return;
        else
            setElementDimension(localPlayer, 10);
            if isElement(previewRoot) then
                destroyElement(previewRoot);
            end;
            previewRoot = createElement("preview", "previewRoot");
            for __, serverTeam1Spawn in ipairs(serverTeam1Spawns) do
                local serverTeam1Ped = createPed(0, serverTeam1Spawn.x, serverTeam1Spawn.y, serverTeam1Spawn.z, serverTeam1Spawn.rot);
                setElementFrozen(serverTeam1Ped, true);
                setElementParent(serverTeam1Ped, previewRoot);
                setElementDimension(serverTeam1Ped, 10);
                local serverTeam1Marker = createMarker(serverTeam1Spawn.x, serverTeam1Spawn.y, serverTeam1Spawn.z, "corona", 2, 255, 0, 0, 32);
                attachElements(serverTeam1Marker, serverTeam1Ped);
                setElementDimension(serverTeam1Marker, 10);
                local serverTeam1Blip = createBlipAttachedTo(serverTeam1Ped, 0, 1, 255, 0, 0, 255, -1);
                setElementParent(serverTeam1Blip, previewRoot);
                setElementDimension(serverTeam1Blip, 10);
            end;
            for __, serverTeam2Spawn in ipairs(serverTeam2Spawns) do
                local serverTeam2Ped = createPed(0, serverTeam2Spawn.x, serverTeam2Spawn.y, serverTeam2Spawn.z, serverTeam2Spawn.rot);
                setElementFrozen(serverTeam2Ped, true);
                setElementParent(serverTeam2Ped, previewRoot);
                setElementDimension(serverTeam2Ped, 10);
                local serverTeam2Marker = createMarker(serverTeam2Spawn.x, serverTeam2Spawn.y, serverTeam2Spawn.z, "corona", 2, 0, 0, 255, 32);
                attachElements(serverTeam2Marker, serverTeam2Ped);
                setElementDimension(serverTeam2Marker, 10);
                local serverTeam2Blip = createBlipAttachedTo(serverTeam2Ped, 0, 1, 0, 0, 255, 255, -1);
                setElementParent(serverTeam2Blip, previewRoot);
                setElementDimension(serverTeam2Blip, 10);
            end;
            for __, serverNeutralSpawn in ipairs(serverNeutralSpawns) do
                local serverNeutralPed = createPed(0, serverNeutralSpawn.x, serverNeutralSpawn.y, serverNeutralSpawn.z, serverNeutralSpawn.rot);
                setElementFrozen(serverNeutralPed, true);
                setElementParent(serverNeutralPed, previewRoot);
                setElementDimension(serverNeutralPed, 10);
                local serverNeutralMarker = createMarker(serverNeutralSpawn.x, serverNeutralSpawn.y, serverNeutralSpawn.z, "corona", 2, 255, 255, 255, 32);
                attachElements(serverNeutralMarker, serverNeutralPed);
                setElementDimension(serverNeutralMarker, 10);
                local serverNeutralBlip = createBlipAttachedTo(serverNeutralPed, 0, 1, 255, 255, 255, 255, -1);
                setElementParent(serverNeutralBlip, previewRoot);
                setElementDimension(serverNeutralBlip, 10);
            end;
            if #serverAntiRushPoints > 0 then
                if #serverAntiRushPoints == 2 then
                    serverAntiRushPoints = {
                        {
                            math.min(serverAntiRushPoints[1].x, serverAntiRushPoints[2].x), 
                            math.min(serverAntiRushPoints[1].y, serverAntiRushPoints[2].y)
                        }, 
                        {
                            math.max(serverAntiRushPoints[1].x, serverAntiRushPoints[2].x), 
                            math.min(serverAntiRushPoints[1].y, serverAntiRushPoints[2].y)
                        }, 
                        {
                            math.max(serverAntiRushPoints[1].x, serverAntiRushPoints[2].x), 
                            math.max(serverAntiRushPoints[1].y, serverAntiRushPoints[2].y)
                        }, 
                        {
                            math.min(serverAntiRushPoints[1].x, serverAntiRushPoints[2].x), 
                            math.max(serverAntiRushPoints[1].y, serverAntiRushPoints[2].y)
                        }
                    };
                end;
                if #serverAntiRushPoints > 1 then
                    local serverRadarAreaSize = 12;
                    local serverPolygonPoints = {
                        serverCentralMarker.x, 
                        serverCentralMarker.y
                    };
                    for serverPointIndex, serverRushPoint in ipairs(serverAntiRushPoints) do
                        table.insert(serverPolygonPoints, serverRushPoint.x);
                        table.insert(serverPolygonPoints, serverRushPoint.y);
                        local serverAntiRushObject = createObject(3380, serverRushPoint.x, serverRushPoint.y, serverRushPoint.z);
                        setElementParent(serverAntiRushObject, previewRoot);
                        setElementDimension(serverAntiRushObject, 10);
                        local serverNextPoint = serverPointIndex < #serverAntiRushPoints and serverAntiRushPoints[serverPointIndex + 1] or serverAntiRushPoints[1];
                        local serverSegmentCount = math.floor(getDistanceBetweenPoints2D(serverRushPoint.x, serverRushPoint.y, serverNextPoint.x, serverNextPoint.y) / 5);
                        local serverSegmentStepX = (serverNextPoint.x - serverRushPoint.x) / serverSegmentCount;
                        local serverSegmentStepY = (serverNextPoint.y - serverRushPoint.y) / serverSegmentCount;
                        for serverSegmentIndex = 0, serverSegmentCount do
                            local serverRadarSegment = createRadarArea(serverRushPoint.x - serverRadarAreaSize * 0.5 + serverSegmentStepX * serverSegmentIndex, serverRushPoint.y - serverRadarAreaSize * 0.5 + serverSegmentStepY * serverSegmentIndex, serverRadarAreaSize, serverRadarAreaSize, 128, 0, 0, 255);
                            setElementParent(serverRadarSegment, previewRoot);
                            setElementDimension(serverRadarSegment, 10);
                        end;
                    end;
                end;
            end;
            setCameraMatrix(serverCentralMarker.x - 50, serverCentralMarker.y - 50, serverCentralMarker.z + 40, serverCentralMarker.x, serverCentralMarker.y, serverCentralMarker.z);
            setCameraSpectating(nil, "freecamera");
            addEventHandler("onClientPlayerSpawn", localPlayer, Preview_onClientPlayerSpawn);
            addEventHandler("onClientElementDataChange", localPlayer, Preview_onClientElementDataChange);
            addEventHandler("onClientRender", root, Preview_onClientRender);
            triggerEvent("onClientPreviewMapCreating", previewRoot, serverPreviewMapName, serverMapElements);
            return;
        end;
    end;
    Preview_onClientRender = function() 
        local serverObjectPositions = {};
        for __, serverAntiRushObject in ipairs(getElementsByType("object")) do
            if getElementModel(serverAntiRushObject) == 3380 and getElementDimension(serverAntiRushObject) == 10 then
                local serverObjectX, serverObjectY = getElementPosition(serverAntiRushObject);
                table.insert(serverObjectPositions, {serverObjectX, serverObjectY});
            end;
        end;
        if #serverObjectPositions > 0 then
            if #serverObjectPositions == 2 then
                serverObjectPositions = {
                    {
                        math.min(serverObjectPositions[1][1], serverObjectPositions[2][1]), 
                        math.min(serverObjectPositions[1][2], serverObjectPositions[2][2])
                    }, 
                    {
                        math.max(serverObjectPositions[1][1], serverObjectPositions[2][1]), 
                        math.min(serverObjectPositions[1][2], serverObjectPositions[2][2])
                    }, 
                    {
                        math.max(serverObjectPositions[1][1], serverObjectPositions[2][1]), 
                        math.max(serverObjectPositions[1][2], serverObjectPositions[2][2])
                    }, 
                    {
                        math.min(serverObjectPositions[1][1], serverObjectPositions[2][1]), 
                        math.max(serverObjectPositions[1][2], serverObjectPositions[2][2])
                    }
                };
            end;
            if #serverObjectPositions > 1 then
                for serverPolyIndex, serverPolyPoint in ipairs(serverObjectPositions) do
                    local serverNextPolyPoint = serverPolyIndex < #serverObjectPositions and serverObjectPositions[serverPolyIndex + 1] or serverObjectPositions[1];
                    local serverScreenX1, serverScreenY1 = getScreenFromWorldPosition(serverPolyPoint[1], serverPolyPoint[2], getGroundPosition(serverPolyPoint[1], serverPolyPoint[2], 1500), 360);
                    local serverScreenX2, serverScreenY2 = getScreenFromWorldPosition(serverNextPolyPoint[1], serverNextPolyPoint[2], getGroundPosition(serverNextPolyPoint[1], serverNextPolyPoint[2], 1500), 360);
                    if serverScreenX1 and serverScreenX2 then
                        dxDrawLine(serverScreenX1, serverScreenY1, serverScreenX2, serverScreenY2, 2157969408, 5);
                    end;
                end;
            end;
        end;
    end;
    Preview_onClientPlayerSpawn = function() 
        if isElement(previewRoot) then
            setElementDimension(localPlayer, 0);
            removeEventHandler("onClientPlayerSpawn", localPlayer, Preview_onClientPlayerSpawn);
            removeEventHandler("onClientElementDataChange", localPlayer, Preview_onClientElementDataChange);
            removeEventHandler("onClientRender", root, Preview_onClientRender);
            destroyElement(previewRoot);
            guiSetText(vote_view, "Preview");
            guiSetProperty(vote_view, "NormalTextColour", "C07C7C7C");
        end;
    end;
    Preview_onClientElementDataChange = function(serverStatusDataName, __) 
        if serverStatusDataName == "Status" and isElement(previewRoot) then
            setElementDimension(localPlayer, 0);
            removeEventHandler("onClientPlayerSpawn", localPlayer, Preview_onClientPlayerSpawn);
            removeEventHandler("onClientElementDataChange", localPlayer, Preview_onClientElementDataChange);
            removeEventHandler("onClientRender", root, Preview_onClientRender);
            destroyElement(previewRoot);
            guiSetText(vote_view, "Preview");
            guiSetProperty(vote_view, "NormalTextColour", "C07C7C7C");
        end;
    end;
    addEvent("onClientPreviewMapLoading", true);
    addEvent("onClientPreviewMapCreating", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientMapsUpdate", root, onClientMapsUpdate);
    addEventHandler("onClientGUIDoubleClick", root, onClientGUIDoubleClick);
    addEventHandler("onClientGUIChanged", root, onClientGUIChanged);
    addEventHandler("onClientPreviewMapLoading", root, onClientPreviewMapLoading);
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
    addEventHandler("onClientMapStarting", root, updateVoteMaps);
    addCommandHandler("vote", commandVote, false);
    addCommandHandler("votemap_toggle", toggleVoting, false);
end)();
(function(...) 
    local serverFontHeight = dxGetFontHeight(1, "clear");
    addEventHandler("onClientResourceStart", resourceRoot, function() 
        components = {};
        components_update = {};
        components.elementlist = {};
        components.elementlist.root = guiCreateStaticImage(xscreen * 0.776, yscreen * 0.173, xscreen * 0.174, yscreen * 0.04, "images/color_pixel.png", false);
        guiSetProperty(components.elementlist.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetVisible(components.elementlist.root, false);
        guiSetEnabled(components.elementlist.root, false);
        components.elementlist.image = {};
        components.elementlist.custom = {};
        components.playerlist = {};
        components.playerlist.root = guiCreateStaticImage(0, 0, 0, 0, "images/color_pixel.png", false);
        guiSetProperty(components.playerlist.root, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
        guiSetVisible(components.playerlist.root, false);
        guiSetEnabled(components.playerlist.root, false);
        components.playerlist.players = {};
        components.playerlist.players.root = guiCreateStaticImage(5, 2, 0, yscreen, "images/color_pixel.png", false, components.playerlist.root);
        guiSetProperty(components.playerlist.players.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        components.playerlist.icon = {};
        components.playerlist.info = {};
        components.playerlist.info.root = guiCreateStaticImage(0, 0, 0, yscreen, "images/color_pixel.png", false, components.playerlist.root);
        guiSetProperty(components.playerlist.info.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        components.playerlist.rows = 0;
        components.playerlist.custom = {};
        components.race = {};
        components.race.root = guiCreateStaticImage(0, 0, 0, 0, "images/color_pixel.png", false);
        guiSetProperty(components.race.root, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
        guiSetVisible(components.race.root, false);
        guiSetEnabled(components.race.root, false);
        components.race.rank = guiCreateLabel(0, 0, xscreen, 2 * serverFontHeight, "", false, components.race.root);
        guiLabelSetHorizontalAlign(components.race.rank, "right");
        guiSetFont(components.race.rank, fontTactics);
        components.race.players = guiCreateLabel(0, 0, xscreen, 2 * serverFontHeight, "", false, components.race.root);
        components.race.checkpoint = guiCreateLabel(0, 0, 0, 0, "", false, components.race.root);
        guiLabelSetHorizontalAlign(components.race.checkpoint, "center");
        components.race.timepass = guiCreateLabel(0, 0, 0, 0, "", false, components.race.root);
        guiLabelSetHorizontalAlign(components.race.timepass, "center");
        components.race.info = guiCreateLabel(0, 0, 0, 0, "", false, components.race.root);
        guiLabelSetHorizontalAlign(components.race.info, "center");
        components.race.custom = {};
        components.teamlist = {};
        components.teamlist.root = guiCreateStaticImage(0, 0, 0, 0, "images/color_pixel.png", false);
        guiSetProperty(components.teamlist.root, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
        guiSetVisible(components.teamlist.root, false);
        guiSetEnabled(components.teamlist.root, false);
        components.teamlist.teamname = {};
        components.teamlist.teamname.root = guiCreateStaticImage(5, 2, 0, yscreen, "images/color_pixel.png", false, components.teamlist.root);
        guiSetProperty(components.teamlist.teamname.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        components.teamlist.players = {};
        components.teamlist.players.root = guiCreateStaticImage(0, 0, 0, yscreen, "images/color_pixel.png", false, components.teamlist.root);
        guiSetProperty(components.teamlist.players.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        components.teamlist.icon = {};
        components.teamlist.info = {};
        components.teamlist.info.root = guiCreateStaticImage(0, 0, 0, yscreen, "images/color_pixel.png", false, components.teamlist.root);
        guiSetProperty(components.teamlist.info.root, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        components.teamlist.rows = 0;
        components.teamlist.custom = {};
        components.timeleft = {};
        components.timeleft.root = guiCreateStaticImage(xscreen * 0.5 - 31, yscreen * 0.053, 62, serverFontHeight, "images/color_pixel.png", false);
        guiSetProperty(components.timeleft.root, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
        guiSetVisible(components.timeleft.root, false);
        guiSetEnabled(components.timeleft.root, false);
        components.timeleft.text = guiCreateLabel(0, 0, 1, 1, "", true, components.timeleft.root);
        guiSetFont(components.timeleft.text, "clear-normal");
        guiLabelSetHorizontalAlign(components.timeleft.text, "center");
        guiLabelSetVerticalAlign(components.timeleft.text, "center");
        components.timeleft.custom = {};
        components.nitro = {};
        components.nitro.root = guiCreateStaticImage(xscreen * 0.03175, yscreen * 0.768, math.floor(xscreen * 0.0165), math.floor(yscreen * 0.17), "images/color_pixel.png", false);
        guiSetProperty(components.nitro.root, "ImageColours", "tl:60000000 tr:60000000 bl:60000000 br:60000000");
        guiSetVisible(components.nitro.root, false);
        guiSetEnabled(components.nitro.root, false);
        components.nitro.level = guiCreateStaticImage(0, 0, 1, 1, "images/color_pixel.png", true, components.nitro.root);
        guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
        components.nitro.arrow = guiCreateStaticImage(-math.floor(xscreen * 0.03375 * 0.28), 0, math.floor(xscreen * 0.03375 * 0.97), math.floor(yscreen * 0.004), "images/color_pixel.png", false, components.nitro.level);
        guiSetProperty(components.nitro.arrow, "ImageColours", "tl:A0C0C0C0 tr:A0C0C0C0 bl:A0C0C0C0 br:A0C0C0C0");
        guiSetProperty(components.nitro.arrow, "ClippedByParent", "False");
    end);
    showRoundHudComponent = function(serverComponentName, serverShowComponent, serverShouldUpdate) 
        if not components[serverComponentName] then
            return nil;
        elseif serverShowComponent and not guiGetVisible(components[serverComponentName].root) then
            updateRoundHudComponent(serverComponentName);
            guiSetVisible(components[serverComponentName].root, true);
            components_update[serverComponentName] = setTimer(updateRoundHudComponent, serverComponentName == "race" and 50 or 500, 0, serverComponentName);
            if serverShouldUpdate == true then
                setRoundHudComponent(serverComponentName);
            end;
            return true;
        elseif not serverShowComponent and guiGetVisible(components[serverComponentName].root) then
            guiSetVisible(components[serverComponentName].root, false);
            killTimer(components_update[serverComponentName]);
            if serverShouldUpdate == nil or serverShouldUpdate == true then
                setRoundHudComponent(serverComponentName);
            end;
            return true;
        else
            return false;
        end;
    end;
    isShowRoundHudComponent = function(serverComponentCheck) 
        if not components[serverComponentCheck] or not isElement(components[serverComponentCheck].root) then
            return nil;
        else
            return guiGetVisible(components[serverComponentCheck].root);
        end;
    end;
    setRoundHudComponent = function(serverComponentToSet, ...) 
        if not components[serverComponentToSet] then
            return nil;
        else
            local serverComponentArgs = {...};
            if serverComponentToSet == "elementlist" then
                if serverComponentArgs[1] ~= nil and type(serverComponentArgs[1]) ~= "table" and type(serverComponentArgs[1]) ~= "function" then
                    return false;
                elseif serverComponentArgs[2] ~= nil and type(serverComponentArgs[2]) ~= "function" then
                    return false;
                else
                    components.elementlist.custom.elements = serverComponentArgs[1];
                    components.elementlist.custom.draw = serverComponentArgs[2];
                    return true;
                end;
            elseif serverComponentToSet == "playerlist" then
                if serverComponentArgs[1] ~= nil and type(serverComponentArgs[1]) ~= "string" and type(serverComponentArgs[1]) ~= "function" then
                    return false;
                elseif serverComponentArgs[2] ~= nil and type(serverComponentArgs[2]) ~= "function" then
                    return false;
                elseif serverComponentArgs[3] ~= nil and type(serverComponentArgs[3]) ~= "boolean" then
                    return false;
                elseif serverComponentArgs[4] ~= nil and type(serverComponentArgs[4]) ~= "number" then
                    return false;
                else
                    if serverComponentArgs[1] and components.playerlist.custom.icon ~= serverComponentArgs[1] and type(serverComponentArgs[1]) == "string" then
                        for serverIconIndex = 1, components.playerlist.rows do
                            guiStaticImageLoadImage(components.playerlist.icon[serverIconIndex], serverComponentArgs[1]);
                        end;
                    elseif components.playerlist.custom.icon then
                        for serverPlayerListIcon = 1, components.playerlist.rows do
                            guiStaticImageLoadImage(components.playerlist.icon[serverPlayerListIcon], "images/frag.png");
                        end;
                    end;
                    components.playerlist.custom.icon = serverComponentArgs[1];
                    components.playerlist.custom.func = serverComponentArgs[2];
                    components.playerlist.custom.sort = serverComponentArgs[3];
                    components.playerlist.custom.rows = serverComponentArgs[4];
                    return true;
                end;
            elseif serverComponentToSet == "race" then
                if serverComponentArgs[1] ~= nil and type(serverComponentArgs[1]) ~= "boolean" then
                    return false;
                elseif serverComponentArgs[2] ~= nil and type(serverComponentArgs[2]) ~= "boolean" then
                    return false;
                elseif serverComponentArgs[3] ~= nil and type(serverComponentArgs[3]) ~= "function" then
                    return false;
                else
                    components.race.custom.timepass = serverComponentArgs[1];
                    components.race.custom.checkpoints = serverComponentArgs[2];
                    components.race.custom.info = serverComponentArgs[3];
                    return true;
                end;
            elseif serverComponentToSet == "teamlist" then
                if serverComponentArgs[1] ~= nil and type(serverComponentArgs[1]) ~= "string" and type(serverComponentArgs[1]) ~= "function" then
                    return false;
                elseif serverComponentArgs[2] ~= nil and type(serverComponentArgs[2]) ~= "function" then
                    return false;
                elseif serverComponentArgs[3] ~= nil and type(serverComponentArgs[3]) ~= "boolean" then
                    return false;
                elseif serverComponentArgs[4] ~= nil and type(serverComponentArgs[4]) ~= "number" then
                    return false;
                else
                    if serverComponentArgs[1] and components.teamlist.custom.icon ~= serverComponentArgs[1] and type(serverComponentArgs[1]) == "string" then
                        for serverTeamListIcon = 1, components.teamlist.rows do
                            guiStaticImageLoadImage(components.teamlist.icon[serverTeamListIcon], serverComponentArgs[1]);
                        end;
                    elseif components.teamlist.custom.icon then
                        for serverTeamListIndex = 1, components.teamlist.rows do
                            guiStaticImageLoadImage(components.teamlist.icon[serverTeamListIndex], "images/score.png");
                        end;
                    end;
                    components.teamlist.custom.icon = serverComponentArgs[1];
                    components.teamlist.custom.func = serverComponentArgs[2];
                    components.teamlist.custom.sort = serverComponentArgs[3];
                    components.teamlist.custom.rows = serverComponentArgs[4];
                    return true;
                end;
            elseif serverComponentToSet == "timeleft" then
                if serverComponentArgs[1] ~= nil and type(serverComponentArgs[1]) ~= "function" and type(serverComponentArgs[1]) ~= "string" then
                    return false;
                elseif serverComponentArgs[2] ~= nil and type(serverComponentArgs[2]) ~= "number" then
                    return false;
                elseif serverComponentArgs[3] ~= nil and type(serverComponentArgs[3]) ~= "number" then
                    return false;
                elseif serverComponentArgs[4] ~= nil and type(serverComponentArgs[4]) ~= "number" then
                    return false;
                else
                    components.timeleft.custom.text = serverComponentArgs[1];
                    if type(serverComponentArgs[1]) == "string" then
                        guiSetText(components.timeleft.text, serverComponentArgs[1]);
                    end;
                    if type(serverComponentArgs[1]) == "function" then
                        guiSetText(components.timeleft.text, serverComponentArgs[1]());
                    end;
                    if serverComponentArgs[2] and serverComponentArgs[3] and serverComponentArgs[4] then
                        guiLabelSetColor(components.timeleft.text, serverComponentArgs[2], serverComponentArgs[3], serverComponentArgs[4]);
                    else
                        guiLabelSetColor(components.timeleft.text, 255, 255, 255);
                    end;
                    return true;
                end;
            else
                return false;
            end;
        end;
    end;
    updateRoundHudComponent = function(serverUpdateComponent) 
        if serverUpdateComponent == "elementlist" then
            local serverElementListData = type(components.elementlist.custom.elements) == "table" and components.elementlist.custom.elements or type(components.elementlist.custom.elements) == "function" and components.elementlist.custom.elements() or {};
            for serverElementIndex = 1, math.max(#serverElementListData, #components.elementlist.image) do
                if serverElementIndex <= #serverElementListData then
                    local serverElementImage, serverElementColorR, serverElementColorG, serverElementColorB = components.elementlist.custom.draw(serverElementListData, serverElementIndex);
                    local serverElementWidth = math.min((xscreen * 0.174 - yscreen * 0.04) / 6, (xscreen * 0.174 - yscreen * 0.04) / #serverElementListData);
                    if not components.elementlist.image[serverElementIndex] then
                        components.elementlist.image[serverElementIndex] = guiCreateStaticImage((serverElementIndex - 1) * serverElementWidth, 0, yscreen * 0.04, yscreen * 0.04, serverElementImage, false, components.elementlist.root);
                    else
                        guiStaticImageLoadImage(components.elementlist.image[serverElementIndex], serverElementImage);
                    end;
                    local serverColorHex = string.format("%02X%02X%02X%02X", a or 255, serverElementColorR, serverElementColorG, serverElementColorB);
                    guiSetProperty(components.elementlist.image[serverElementIndex], "ImageColours", "tl:" .. serverColorHex .. " tr:" .. serverColorHex .. " bl:" .. serverColorHex .. " br:" .. serverColorHex);
                else
                    destroyElement(components.elementlist.image[serverElementIndex]);
                    components.elementlist.image[serverElementIndex] = nil;
                end;
            end;
        end;
        if serverUpdateComponent == "playerlist" then
            local serverActivePlayers = {};
            for __, serverPlayerElement in ipairs(getElementsByType("player")) do
                if getPlayerGameStatus(serverPlayerElement) == "Play" or getPlayerGameStatus(serverPlayerElement) == "Die" then
                    table.insert(serverActivePlayers, serverPlayerElement);
                end;
            end;
            if components.playerlist.custom.sort ~= nil and #serverActivePlayers > 1 then
                table.sort(serverActivePlayers, function(serverSortPlayerA, serverSortPlayerB) 
                    local serverPlayerValueA = components.playerlist.custom.func(serverSortPlayerA);
                    local serverPlayerValueB = components.playerlist.custom.func(serverSortPlayerB);
                    return components.playerlist.custom.sort and not (serverPlayerValueB >= serverPlayerValueA) or serverPlayerValueA < serverPlayerValueB;
                end);
            end;
            local serverColumnWidths = {0, 0};
            local serverLocalPlayerFound = false;
            local serverMaxRows = math.min(#serverActivePlayers, components.playerlist.custom.rows or 2);
            for serverRowIndex = 1, math.max(serverMaxRows, components.playerlist.rows) do
                if serverRowIndex <= serverMaxRows then
                    local serverCurrentPlayer = serverActivePlayers[serverRowIndex];
                    if serverCurrentPlayer == localPlayer then
                        serverLocalPlayerFound = true;
                    end;
                    if serverRowIndex == serverMaxRows and not serverLocalPlayerFound and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                        serverCurrentPlayer = localPlayer;
                    end;
                    local serverPlayerName = getPlayerName(serverCurrentPlayer);
                    local serverPlayerValue = components.playerlist.custom.func and components.playerlist.custom.func(serverCurrentPlayer) or tostring(getElementData(serverCurrentPlayer, "Kills"));
                    local serverPlayerIcon = type(components.playerlist.custom.icon) == "string" and components.playerlist.custom.icon or type(components.playerlist.custom.icon) == "function" and components.playerlist.custom.icon(serverCurrentPlayer) or "images/frag.png";
                    if not components.playerlist.players[serverRowIndex] then
                        components.playerlist.rows = components.playerlist.rows + 1;
                        components.playerlist.players[serverRowIndex] = guiCreateLabel(0, (serverRowIndex - 1) * serverFontHeight, xscreen, serverFontHeight, serverPlayerName, false, components.playerlist.players.root);
                        guiSetFont(components.playerlist.players[serverRowIndex], "clear-normal");
                        components.playerlist.icon[serverRowIndex] = guiCreateStaticImage(0, (serverRowIndex - 1) * serverFontHeight, serverFontHeight, serverFontHeight, serverPlayerIcon, false, components.playerlist.info.root);
                        setElementParent(components.playerlist.icon[serverRowIndex], components.playerlist.players[serverRowIndex]);
                        components.playerlist.info[serverRowIndex] = guiCreateLabel(serverFontHeight + 5, (serverRowIndex - 1) * serverFontHeight, xscreen, serverFontHeight, serverPlayerValue, false, components.playerlist.info.root);
                        setElementParent(components.playerlist.info[serverRowIndex], components.playerlist.players[serverRowIndex]);
                        guiSetFont(components.playerlist.info[serverRowIndex], "clear-normal");
                    else
                        if guiGetText(components.playerlist.players[serverRowIndex]) ~= serverPlayerName then
                            guiSetText(components.playerlist.players[serverRowIndex], serverPlayerName);
                        end;
                        if guiGetText(components.playerlist.info[serverRowIndex]) ~= serverPlayerValue then
                            guiSetText(components.playerlist.info[serverRowIndex], serverPlayerValue);
                        end;
                        if type(components.playerlist.custom.icon) == "function" then
                            guiStaticImageLoadImage(components.playerlist.icon[serverRowIndex], serverPlayerIcon);
                        end;
                    end;
                    serverColumnWidths[1] = math.max(serverColumnWidths[1], dxGetTextWidth(serverPlayerName, 1, "clear"));
                    serverColumnWidths[2] = math.max(serverColumnWidths[2], dxGetTextWidth(serverPlayerValue, 1, "clear"));
                else
                    destroyElement(components.playerlist.players[serverRowIndex]);
                    components.playerlist.players[serverRowIndex] = nil;
                    components.playerlist.rows = components.playerlist.rows - 1;
                end;
            end;
            components.playerlist.rows = serverMaxRows;
            if guiGetSize(components.playerlist.players.root, false) ~= serverColumnWidths[1] then
                guiSetSize(components.playerlist.players.root, serverColumnWidths[1], serverMaxRows * serverFontHeight, false);
                guiSetPosition(components.playerlist.info.root, 5 + serverColumnWidths[1] + 5, 2, false);
            end;
            if guiGetSize(components.playerlist.info.root, false) ~= serverFontHeight + 5 + serverColumnWidths[2] then
                guiSetSize(components.playerlist.info.root, serverFontHeight + 5 + serverColumnWidths[2], yscreen, false);
            end;
            local serverPlayerListWidth, serverPlayerListHeight = guiGetSize(components.playerlist.root, false);
            if serverPlayerListWidth ~= 5 + serverColumnWidths[1] + 5 + serverFontHeight + 5 + serverColumnWidths[2] + 5 or serverPlayerListHeight ~= 2 + serverMaxRows * serverFontHeight + 2 then
                guiSetSize(components.playerlist.root, 5 + serverColumnWidths[1] + 5 + serverFontHeight + 5 + serverColumnWidths[2] + 5, 2 + serverMaxRows * serverFontHeight + 2, false);
                guiSetPosition(components.playerlist.root, xscreen * 0.95 - (5 + serverColumnWidths[1] + 5 + serverFontHeight + 5 + serverColumnWidths[2] + 5), yscreen * 0.935 - (2 + serverMaxRows * serverFontHeight + 2), false);
            end;
        end;
        if serverUpdateComponent == "race" then
            local serverRaceTarget = getCameraTarget();
            if serverRaceTarget and getElementType(serverRaceTarget) == "vehicle" then
                serverRaceTarget = getVehicleOccupant(serverRaceTarget);
            end;
            if not serverRaceTarget then
                return;
            else
                local serverMaxRaceWidth = 0;
                local serverCurrentRow = 2;
                if components.race.custom.timepass and getRoundState() ~= "finished" then
                    local serverElapsedTime = 0;
                    local serverTimeStart = getTacticsData("timestart");
                    if serverTimeStart then
                        serverElapsedTime = math.max(0, isRoundPaused() and serverTimeStart or getTickCount() + addTickCount - serverTimeStart);
                    end;
                    local serverTimeFormatted = MSecToTime(serverElapsedTime, 2);
                    serverMaxRaceWidth = math.max(serverMaxRaceWidth, dxGetTextWidth(serverTimeFormatted, 1, "clear"));
                    timepassrow = serverCurrentRow;
                    serverCurrentRow = serverCurrentRow + 1;
                    if guiGetText(components.race.timepass) ~= serverTimeFormatted then
                        guiSetText(components.race.timepass, serverTimeFormatted);
                    end;
                end;
                if components.race.custom.checkpoints then
                    local serverCheckpointText = tostring(getElementData(serverRaceTarget, "Checkpoint")) .. "/" .. #getElementsByType("checkpoint");
                    serverMaxRaceWidth = math.max(serverMaxRaceWidth, dxGetTextWidth(serverCheckpointText, 1, "clear"));
                    checkpointrow = serverCurrentRow;
                    serverCurrentRow = serverCurrentRow + 1;
                    if guiGetText(components.race.checkpoint) ~= serverCheckpointText then
                        guiSetText(components.race.checkpoint, serverCheckpointText);
                    end;
                end;
                if type(components.race.custom.info) == "function" then
                    local serverRaceInfoText = tostring(components.race.custom.info(serverRaceTarget));
                    serverMaxRaceWidth = math.max(serverMaxRaceWidth, dxGetTextWidth(serverRaceInfoText, 1, "clear"));
                    inforow = serverCurrentRow;
                    serverCurrentRow = serverCurrentRow + 1;
                    if guiGetText(components.race.info) ~= serverRaceInfoText then
                        guiSetText(components.race.info, serverRaceInfoText);
                    end;
                end;
                local serverPlayerRank = getElementData(serverRaceTarget, "Rank") or 0;
                serverMaxRaceWidth = math.max(serverMaxRaceWidth, 2 * dxGetTextWidth(serverPlayerRank, 1, "diploma"));
                if guiGetText(components.race.rank) ~= serverPlayerRank then
                    guiSetText(components.race.rank, serverPlayerRank);
                end;
                local serverTotalPlayers = 0;
                for __, serverRaceTeam in ipairs(getTacticsData("Sides")) do
                    serverTotalPlayers = serverTotalPlayers + countPlayersInTeam(serverRaceTeam);
                end;
                serverTotalPlayers = tostring(serverTotalPlayers);
                local serverRankSuffix = (not (serverPlayerRank >= 10) or serverPlayerRank > 20) and ({
                    [1] = "st", 
                    [2] = "nd", 
                    [3] = "rd"
                })[serverPlayerRank % 10] or "th";
                serverMaxRaceWidth = math.max(serverMaxRaceWidth, 2 * dxGetTextWidth(serverRankSuffix, 1, "clear"), 2 * dxGetTextWidth(serverTotalPlayers, 1, "clear"));
                if guiGetText(components.race.players) ~= serverRankSuffix .. "\n/" .. serverTotalPlayers then
                    guiSetText(components.race.players, serverRankSuffix .. "\n/" .. serverTotalPlayers);
                end;
                local serverRaceWidth, serverRaceHeight = guiGetSize(components.race.root, false);
                if serverRaceWidth ~= 5 + serverMaxRaceWidth + 5 or serverRaceHeight ~= 2 + serverCurrentRow * serverFontHeight + 2 then
                    guiSetSize(components.race.root, 5 + serverMaxRaceWidth + 5, 2 + serverCurrentRow * serverFontHeight + 2, false);
                    guiSetPosition(components.race.root, xscreen * 0.95 - (5 + serverMaxRaceWidth + 5), yscreen * 0.935 - (2 + serverCurrentRow * serverFontHeight + 2), false);
                    guiSetSize(components.race.rank, 5 + serverMaxRaceWidth / 2, 2 * serverFontHeight, false);
                    guiSetPosition(components.race.players, 5 + serverMaxRaceWidth / 2, 0, false);
                    if timepassrow then
                        guiSetPosition(components.race.timepass, 0, 2 + timepassrow * serverFontHeight, false);
                        guiSetSize(components.race.timepass, 5 + serverMaxRaceWidth + 5, serverFontHeight, false);
                    end;
                    if checkpointrow then
                        guiSetPosition(components.race.checkpoint, 0, 2 + checkpointrow * serverFontHeight, false);
                        guiSetSize(components.race.checkpoint, 5 + serverMaxRaceWidth + 5, serverFontHeight, false);
                    end;
                    if inforow then
                        guiSetPosition(components.race.info, 0, 2 + inforow * serverFontHeight, false);
                        guiSetSize(components.race.info, 5 + serverMaxRaceWidth + 5, serverFontHeight, false);
                    end;
                end;
            end;
        end;
        if serverUpdateComponent == "teamlist" then
            local serverGameTeams = getElementsByType("team");
            table.remove(serverGameTeams, 1);
            if components.teamlist.custom.sort ~= nil and #serverGameTeams > 1 then
                table.sort(serverGameTeams, function(serverTeamSortA, serverTeamSortB) 
                    local serverTeamValueA = components.teamlist.custom.func(serverTeamSortA);
                    local serverTeamValueB = components.teamlist.custom.func(serverTeamSortB);
                    return components.teamlist.custom.sort and not (serverTeamValueB >= serverTeamValueA) or serverTeamValueA < serverTeamValueB;
                end);
            end;
            local serverTeamWidths = {0, 0, 0};
            local serverPlayerTeamFound = false;
            local serverMaxTeamRows = math.min(#serverGameTeams, components.teamlist.custom.rows or 3);
            for serverTeamRowIndex = 1, math.max(serverMaxTeamRows, components.teamlist.rows) do
                if serverTeamRowIndex <= serverMaxTeamRows then
                    local serverCurrentTeam = serverGameTeams[serverTeamRowIndex];
                    if serverCurrentTeam == getPlayerTeam(localPlayer) then
                        serverPlayerTeamFound = true;
                    end;
                    if serverTeamRowIndex == serverMaxTeamRows and not serverPlayerTeamFound and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                        serverCurrentTeam = getPlayerTeam(localPlayer) or serverGameTeams[serverTeamRowIndex];
                    end;
                    local serverTeamName = getTeamName(serverCurrentTeam);
                    local serverAliveCount = 0;
                    for __, serverTeamPlayerEntry in ipairs(getPlayersInTeam(serverCurrentTeam)) do
                        if getElementData(serverTeamPlayerEntry, "Status") == "Play" then
                            serverAliveCount = serverAliveCount + 1;
                        end;
                    end;
                    serverAliveCount = tostring(serverAliveCount);
                    local serverTeamValue = components.teamlist.custom.func and components.teamlist.custom.func(serverCurrentTeam) or tostring(getElementData(serverCurrentTeam, "Score"));
                    local serverTeamIcon = type(components.teamlist.custom.icon) == "string" and components.teamlist.custom.icon or type(components.teamlist.custom.icon) == "function" and components.teamlist.custom.icon(serverCurrentTeam) or "images/score.png";
                    if not components.teamlist.players[serverTeamRowIndex] then
                        components.teamlist.rows = components.teamlist.rows + 1;
                        components.teamlist.players[serverTeamRowIndex] = guiCreateLabel(0, (serverTeamRowIndex - 1) * serverFontHeight, xscreen, serverFontHeight, serverAliveCount, false, components.teamlist.players.root);
                        guiSetFont(components.teamlist.players[serverTeamRowIndex], "clear-normal");
                        components.teamlist.teamname[serverTeamRowIndex] = guiCreateLabel(0, (serverTeamRowIndex - 1) * serverFontHeight, xscreen, serverFontHeight, serverTeamName, false, components.teamlist.teamname.root);
                        guiLabelSetColor(components.teamlist.teamname[serverTeamRowIndex], getTeamColor(serverCurrentTeam));
                        setElementParent(components.teamlist.teamname[serverTeamRowIndex], components.teamlist.players[serverTeamRowIndex]);
                        guiSetFont(components.teamlist.teamname[serverTeamRowIndex], "clear-normal");
                        components.teamlist.icon[serverTeamRowIndex] = guiCreateStaticImage(0, (serverTeamRowIndex - 1) * serverFontHeight, serverFontHeight, serverFontHeight, serverTeamIcon, false, components.teamlist.info.root);
                        setElementParent(components.teamlist.icon[serverTeamRowIndex], components.teamlist.players[serverTeamRowIndex]);
                        components.teamlist.info[serverTeamRowIndex] = guiCreateLabel(serverFontHeight + 5, (serverTeamRowIndex - 1) * serverFontHeight, xscreen, serverFontHeight, serverTeamValue, false, components.teamlist.info.root);
                        setElementParent(components.teamlist.info[serverTeamRowIndex], components.teamlist.players[serverTeamRowIndex]);
                        guiSetFont(components.teamlist.info[serverTeamRowIndex], "clear-normal");
                    else
                        if guiGetText(components.teamlist.teamname[serverTeamRowIndex]) ~= serverTeamName then
                            guiSetText(components.teamlist.teamname[serverTeamRowIndex], serverTeamName);
                        end;
                        guiLabelSetColor(components.teamlist.teamname[serverTeamRowIndex], getTeamColor(serverCurrentTeam));
                        if guiGetText(components.teamlist.players[serverTeamRowIndex]) ~= serverAliveCount then
                            guiSetText(components.teamlist.players[serverTeamRowIndex], serverAliveCount);
                        end;
                        if guiGetText(components.teamlist.info[serverTeamRowIndex]) ~= serverTeamValue then
                            guiSetText(components.teamlist.info[serverTeamRowIndex], serverTeamValue);
                        end;
                        if type(components.teamlist.custom.icon) == "function" then
                            guiStaticImageLoadImage(components.teamlist.icon[serverTeamRowIndex], serverTeamIcon);
                        end;
                    end;
                    serverTeamWidths[1] = math.max(serverTeamWidths[1], dxGetTextWidth(serverTeamName, 1, "clear"));
                    serverTeamWidths[2] = math.max(serverTeamWidths[2], dxGetTextWidth(serverAliveCount, 1, "clear"));
                    serverTeamWidths[3] = math.max(serverTeamWidths[3], dxGetTextWidth(serverTeamValue, 1, "clear"));
                else
                    destroyElement(components.teamlist.players[serverTeamRowIndex]);
                    components.teamlist.players[serverTeamRowIndex] = nil;
                    components.teamlist.rows = components.teamlist.rows - 1;
                end;
            end;
            components.teamlist.rows = serverMaxTeamRows;
            if guiGetSize(components.teamlist.teamname.root, false) ~= serverTeamWidths[1] then
                guiSetSize(components.teamlist.teamname.root, serverTeamWidths[1], yscreen, false);
                guiSetPosition(components.teamlist.players.root, 5 + serverTeamWidths[1] + 5, 2, false);
                guiSetPosition(components.teamlist.info.root, 5 + serverTeamWidths[1] + 5 + serverTeamWidths[2] + 5, 2, false);
            end;
            if guiGetSize(components.teamlist.players.root, false) ~= serverTeamWidths[2] then
                guiSetSize(components.teamlist.players.root, serverTeamWidths[2], yscreen, false);
                guiSetPosition(components.teamlist.info.root, 5 + serverTeamWidths[1] + 5 + serverTeamWidths[2] + 5, 2, false);
            end;
            if guiGetSize(components.teamlist.info.root, false) ~= serverFontHeight + 5 + serverTeamWidths[3] then
                guiSetSize(components.teamlist.info.root, serverFontHeight + 5 + serverTeamWidths[3], yscreen, false);
            end;
            local serverTeamListWidth, serverTeamListHeight = guiGetSize(components.teamlist.root, false);
            if serverTeamListWidth ~= 5 + serverTeamWidths[1] + 5 + serverTeamWidths[2] + 5 + serverFontHeight + 5 + serverTeamWidths[3] + 5 or serverTeamListHeight ~= 2 + serverMaxTeamRows * serverFontHeight + 2 then
                guiSetSize(components.teamlist.root, 5 + serverTeamWidths[1] + 5 + serverTeamWidths[2] + 5 + serverFontHeight + 5 + serverTeamWidths[3] + 5, 2 + serverMaxTeamRows * serverFontHeight + 2, false);
                guiSetPosition(components.teamlist.root, xscreen * 0.95 - (5 + serverTeamWidths[1] + 5 + serverTeamWidths[2] + 5 + serverFontHeight + 5 + serverTeamWidths[3] + 5), yscreen * 0.935 - (2 + serverMaxTeamRows * serverFontHeight + 2), false);
            end;
        end;
        if serverUpdateComponent == "timeleft" then
            local serverCurrentTimeText = guiGetText(components.timeleft.text);
            local serverNewTimeText = "--:--";
            if getRoundState() == "stopped" then
                local serverTimeLimit = getTacticsData("modes", getTacticsData("Map"), "timelimit");
                if serverTimeLimit then
                    serverNewTimeText = serverTimeLimit;
                end;
            elseif type(components.timeleft.custom.text) == "string" then
                serverNewTimeText = components.timeleft.custom.text;
            elseif type(components.timeleft.custom.text) == "function" then
                serverNewTimeText = components.timeleft.custom.text();
            else
                local serverTimeLeftData = getTacticsData("timeleft");
                if serverTimeLeftData then
                    local serverRemainingTime = getTacticsData("Pause") or serverTimeLeftData - (getTickCount() + addTickCount);
                    if type(serverRemainingTime) ~= "number" or serverRemainingTime < 0 then
                        serverRemainingTime = 0;
                    end;
                    serverNewTimeText = MSecToTime(serverRemainingTime, 0);
                end;
            end;
            if serverCurrentTimeText ~= serverNewTimeText and getRoundState() ~= "finished" then
                if serverNewTimeText == "5:00" and serverCurrentTimeText == "5:01" then
                    playVoice("audio/last_five_minutes.mp3");
                elseif serverNewTimeText == "1:00" and serverCurrentTimeText == "1:01" then
                    playVoice("audio/last_minute.mp3");
                end;
                if serverCurrentTimeText ~= serverNewTimeText then
                    guiSetText(components.timeleft.text, serverNewTimeText);
                    local serverTimeWidth = dxGetTextWidth(serverNewTimeText, 1, "clear") + 10;
                    guiSetPosition(components.timeleft.root, (xscreen - serverTimeWidth) * 0.5, yscreen * 0.053, false);
                    guiSetSize(components.timeleft.root, serverTimeWidth, 20, false);
                end;
            end;
        end;
    end;
    dxDrawAnimatedImage = function(serverAnimationImage, serverAnimationType) 
        if type(dataAnimatedImages) ~= "table" then
            dataAnimatedImages = {};
        end;
        table.insert(dataAnimatedImages, {serverAnimationImage, serverAnimationType, getTickCount()});
        if #dataAnimatedImages == 1 then
            addEventHandler("onClientRender", root, onClientAnimatedImagesRender);
        end;
        return #dataAnimatedImages;
    end;
    dxStopAnimatedImage = function(serverAnimationIndex) 
        if dataAnimatedImages[serverAnimationIndex] then
            table.remove(dataAnimatedImages, serverAnimationIndex);
            if #dataAnimatedImages == 0 then
                removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
            end;
            return true;
        else
            return false;
        end;
    end;
    onClientAnimatedImagesRender = function() 
        for serverAnimIndex, serverAnimationData in ipairs(dataAnimatedImages) do
            local serverAnimImage, serverAnimType, serverAnimStartTime = unpack(serverAnimationData);
            local serverAnimElapsed = getTickCount() - serverAnimStartTime;
            if serverAnimType == 1 then
                if serverAnimElapsed < 100 then
                    local serverAnimScale1 = 1 - serverAnimElapsed / 100;
                    dxDrawImage(xscreen * 0.5 - 64 - yscreen * serverAnimScale1, yscreen * 0.3 - 32 - yscreen * 0.5 * serverAnimScale1, yscreen * serverAnimScale1 + 128, yscreen * serverAnimScale1 + 64, serverAnimImage, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - serverAnimScale1)), true);
                elseif serverAnimElapsed < 600 then
                    local serverAnimProgress1 = (serverAnimElapsed - 100) / 500;
                    dxDrawImage(xscreen * 0.5 - 64 + xscreen * serverAnimProgress1 * 0.1, yscreen * 0.3 - 32, 128, 64, serverAnimImage, 0, 0, 0, 4294967295, true);
                elseif serverAnimElapsed < 700 then
                    local serverAnimProgress2 = (serverAnimElapsed - 600) / 100;
                    dxDrawImage(xscreen * 0.6 - 64 + xscreen * serverAnimProgress2 * 0.4, yscreen * 0.3 - 32, 128, 64, serverAnimImage, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - serverAnimProgress2)), true);
                else
                    table.remove(dataAnimatedImages, serverAnimIndex);
                    if #dataAnimatedImages == 0 then
                        return removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
                    end;
                end;
            elseif serverAnimType == 2 then
                if serverAnimElapsed < 100 then
                    local serverAnimScale2 = 1 - serverAnimElapsed / 100;
                    dxDrawImage(xscreen * 0.5 - 64 + 32 * serverAnimScale2, yscreen * 0.3 - 32 - yscreen * 0.25 * serverAnimScale2, yscreen * serverAnimScale2 + 128, yscreen * serverAnimScale2 + 64, serverAnimImage, 30 * serverAnimScale2, 0, 0, tocolor(255, 255, 255, 255 * (1 - serverAnimScale2)), true);
                elseif serverAnimElapsed < 150 then
                    local serverAnimProgress3 = (serverAnimElapsed - 100) / 50;
                    dxDrawImage(xscreen * 0.5 - 64 - 128 * serverAnimProgress3, yscreen * 0.3 - 32 - 64 * serverAnimProgress3, 256 * serverAnimProgress3 + 128, 128 * serverAnimProgress3 + 64, serverAnimImage, 0, 0, 0, 4294967295, true);
                elseif serverAnimElapsed < 200 then
                    local serverAnimScale3 = 1 - (serverAnimElapsed - 150) / 50;
                    dxDrawImage(xscreen * 0.5 - 64 - 128 * serverAnimScale3, yscreen * 0.3 - 32 - 64 * serverAnimScale3, 256 * serverAnimScale3 + 128, 128 * serverAnimScale3 + 64, serverAnimImage, 0, 0, 0, 4294967295, true);
                elseif serverAnimElapsed < 2200 then
                    local serverAnimProgress4 = (serverAnimElapsed - 200) / 2000;
                    dxDrawImage(xscreen * 0.5 - 64 + 16 * serverAnimProgress4, yscreen * 0.3 - 32 + 8 * serverAnimProgress4, 128 - 32 * serverAnimProgress4, 64 - 16 * serverAnimProgress4, serverAnimImage, 0, 0, 0, 4294967295, true);
                elseif serverAnimElapsed < 2300 then
                    local serverAnimProgress5 = (serverAnimElapsed - 2200) / 100;
                    dxDrawImage(xscreen * 0.5 - 48, yscreen * 0.3 - 24 + yscreen * 0.5 * serverAnimProgress5, 96, 48, serverAnimImage, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - serverAnimProgress5)), true);
                else
                    table.remove(dataAnimatedImages, serverAnimIndex);
                    if #dataAnimatedImages == 0 then
                        return removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
                    end;
                end;
            end;
        end;
    end;
    nitroLevel = nil;
    local serverNitroActive = nil;
    local serverNitroToggleState = nil;
    local serverPlayerVehicle = nil;
    onClientNitroPreRender = function(serverDeltaTime) 
        local serverCurrentVehicle = getPedOccupiedVehicle(localPlayer);
        if serverCurrentVehicle and getVehicleOccupant(serverCurrentVehicle) == localPlayer then
            serverPlayerVehicle = serverCurrentVehicle;
            local serverNitroUpgrade = getVehicleUpgradeOnSlot(serverCurrentVehicle, 8);
            local serverVehicleType = getVehicleType(serverCurrentVehicle);
            if (serverNitroUpgrade > 0 or nitroLevel) and (serverVehicleType == "Automobile" or serverVehicleType == "Quad" or serverVehicleType == "Monster Truck") then
                if not nitroLevel then
                    nitroLevel = getElementData(serverCurrentVehicle, "nitroLevel") or 20000;
                    guiSetPosition(components.nitro.level, 0, 1 - nitroLevel / 20000, true);
                    guiSetSize(components.nitro.level, 1, nitroLevel / 20000, true);
                    guiSetVisible(components.nitro.root, true);
                end;
                local serverNitroControlSetting = guiGetText(config_gameplay_nitrocontrol);
                if serverNitroControlSetting == "Normal" then
                    if (getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire")) and not serverNitroActive then
                        serverNitroActive = 20000;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                    end;
                elseif serverNitroControlSetting == "Hold" then
                    if getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire") then
                        if not serverNitroActive then
                            serverNitroActive = 20000;
                            guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                            callServerFunction("removeVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                            removeVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                            addVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                            callServerFunction("addVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                        end;
                    elseif serverNitroActive then
                        callServerFunction("removeVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                        removeVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                        setElementData(serverCurrentVehicle, "nitroLevel", nitroLevel);
                        serverNitroActive = nil;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                        addVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                        callServerFunction("addVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                    end;
                elseif serverNitroControlSetting == "Toggle" then
                    if getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire") then
                        if not serverNitroToggleState then
                            serverNitroToggleState = true;
                            if not serverNitroActive then
                                serverNitroActive = 20000;
                                guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                            elseif serverNitroActive then
                                serverNitroActive = nil;
                                guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                                setPedControlState("vehicle_fire", false);
                                setPedControlState("vehicle_secondary_fire", false);
                                callServerFunction("removeVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                                removeVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                                addVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                                callServerFunction("addVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                            end;
                        end;
                    else
                        serverNitroToggleState = nil;
                    end;
                end;
                if serverNitroActive then
                    serverNitroActive = serverNitroActive - serverDeltaTime * getGameSpeed();
                    nitroLevel = nitroLevel - serverDeltaTime * getGameSpeed();
                    guiSetPosition(components.nitro.level, 0, 1 - nitroLevel / 20000, true);
                    guiSetSize(components.nitro.level, 1, nitroLevel / 20000, true);
                    if nitroLevel <= 0 then
                        callServerFunction("removeVehicleUpgrade", serverCurrentVehicle, serverNitroUpgrade);
                        removeVehicleUpgrade(serverCurrentVehicle, serverNitroUpgrade);
                        setElementData(serverCurrentVehicle, "nitroLevel", nil);
                        guiSetVisible(components.nitro.root, false);
                        nitroLevel = nil;
                        serverNitroActive = nil;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                    end;
                end;
            elseif nitroLevel then
                nitroLevel = nil;
                serverNitroActive = nil;
                guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                setElementData(serverCurrentVehicle, "nitroLevel", nil);
                guiSetVisible(components.nitro.root, false);
            end;
        elseif nitroLevel then
            if isElement(serverPlayerVehicle) then
                setElementData(serverPlayerVehicle, "nitroLevel", nitroLevel);
            end;
            nitroLevel = nil;
            serverNitroActive = nil;
            guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
            guiSetVisible(components.nitro.root, false);
        end;
    end;
    addEventHandler("onClientPreRender", root, onClientNitroPreRender);
    local serverInfoTimer = nil;
    local serverInfoIdCounter = 0;
    infowindow = guiCreateStaticImage(0.3, 0.838, 0.7, 0.1, "images/color_pixel.png", true);
    guiSetProperty(infowindow, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
    guiSetVisible(infowindow, false);
    local serverInfoLabel = guiCreateLabel(5, 5, xscreen * 0.7 - 10, yscreen, "", false, infowindow);
    outputInfo = function(serverInfoText, serverInfoDuration) 
        if type(serverInfoText) ~= "string" or #serverInfoText < 1 then
            return false;
        else
            if guiGetText(serverInfoLabel) ~= serverInfoText then
                guiSetText(serverInfoLabel, serverInfoText);
                local serverTextWidth = dxGetTextWidth(serverInfoText, 1, "default");
                local serverTextHeight = dxGetFontHeight(1, "default") * (string.count(serverInfoText, "\n") + 1);
                guiSetPosition(infowindow, 0.225, 0.938 - (serverTextHeight + 10) / yscreen, true);
                guiSetSize(infowindow, serverTextWidth + 10, serverTextHeight + 10, false);
                serverInfoIdCounter = serverInfoIdCounter + 1;
            end;
            if not guiGetVisible(infowindow) and guiGetAlpha(infowindow) > 0.1 then
                playSoundFrontEnd(11);
            end;
            guiSetVisible(infowindow, true);
            if not serverInfoDuration then
                serverInfoDuration = 5000;
            end;
            if isTimer(serverInfoTimer) then
                killTimer(serverInfoTimer);
            end;
            serverInfoTimer = setTimer(guiSetVisible, serverInfoDuration, 1, infowindow, false);
            return serverInfoIdCounter;
        end;
    end;
    hideInfo = function(serverInfoToHide) 
        if serverInfoIdCounter == serverInfoToHide or not serverInfoToHide then
            if isTimer(serverInfoTimer) then
                killTimer(serverInfoTimer);
            end;
            guiSetVisible(infowindow, false);
            return true;
        else
            return false;
        end;
    end;
end)();
(function(...) 
    currentMenu = 1;
    currentTeam = 0;
    currentSkin = {};
    currentPed = {};
    currentCamera = {};
    onClientResourceStart = function(__) 
        joining_background = guiCreateStaticImage(0, 0, 1, 1, "images/color_pixel.png", true);
        guiSetProperty(joining_background, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetVisible(joining_background, false);
        joining_selection = guiCreateStaticImage(0.04500000000000001, 0.745, 0.31, 0.05, "images/color_pixel.png", true, joining_background);
        guiSetProperty(joining_selection, "ImageColours", "tl:40FFFFFF tr:40FFFFFF bl:40FFFFFF br:40FFFFFF");
        guiSetEnabled(joining_selection, false);
        joining_credits = guiCreateLabel(0.05000000000000002, 0.6000000000000001, 0.3, 0.04, "Credits", true, joining_background);
        guiSetFont(joining_credits, "sa-header");
        guiLabelSetHorizontalAlign(joining_credits, "center");
        guiLabelSetVerticalAlign(joining_credits, "center");
        joining_language = guiCreateLabel(0.05000000000000002, 0.65, 0.3, 0.04, "Language", true, joining_background);
        guiSetFont(joining_language, "sa-header");
        guiLabelSetHorizontalAlign(joining_language, "center");
        guiLabelSetVerticalAlign(joining_language, "center");
        joining_skinleft = guiCreateStaticImage(0.05000000000000002, 0.7000000000000001, 0.04, 0.04, "images/key_arrow_l.png", true, joining_background);
        guiSetVisible(joining_skinleft, false);
        joining_skinname = guiCreateLabel(0.09000000000000001, 0.7000000000000001, 0.22, 0.04, "", true, joining_background);
        guiSetVisible(joining_skinname, false);
        guiSetFont(joining_skinname, "sa-header");
        guiLabelSetHorizontalAlign(joining_skinname, "center");
        guiLabelSetVerticalAlign(joining_skinname, "center");
        joining_skinright = guiCreateStaticImage(0.31, 0.7000000000000001, 0.04, 0.04, "images/key_arrow_r.png", true, joining_background);
        guiSetVisible(joining_skinright, false);
        joining_teamleft = guiCreateStaticImage(0.05000000000000002, 0.75, 0.04, 0.04, "images/key_arrow_l.png", true, joining_background);
        joining_teamname = guiCreateLabel(0.09000000000000001, 0.75, 0.22, 0.04, "Auto-assign", true, joining_background);
        guiSetFont(joining_teamname, "sa-header");
        guiLabelSetHorizontalAlign(joining_teamname, "center");
        guiLabelSetVerticalAlign(joining_teamname, "center");
        joining_teamright = guiCreateStaticImage(0.31, 0.75, 0.04, 0.04, "images/key_arrow_r.png", true, joining_background);
        joining_spawn = guiCreateLabel(0.05000000000000002, 0.8, 0.3, 0.04, "Join to game", true, joining_background);
        guiSetFont(joining_spawn, "sa-header");
        guiLabelSetHorizontalAlign(joining_spawn, "center");
        guiLabelSetVerticalAlign(joining_spawn, "center");
    end;
    onClientJoiningRender = function() 
        if guiGetVisible(joining_background) then
            dxDrawRectangle(0, 0, xscreen * 0.4, yscreen, 4278190080);
        end;
        local serverCamPosX, serverCamPosY, serverCamPosZ, serverCamLookX, serverCamLookY, serverCamLookZ = getCameraMatrix();
        local serverTargetCamX, serverTargetCamY, serverTargetCamZ, serverTargetLookX, serverTargetLookY, serverTargetLookZ = unpack(currentCamera);
        local serverLerpSpeed = 0.1;
        setCameraMatrix(serverCamPosX + serverLerpSpeed * (serverTargetCamX - serverCamPosX), serverCamPosY + serverLerpSpeed * (serverTargetCamY - serverCamPosY), serverCamPosZ + serverLerpSpeed * (serverTargetCamZ - serverCamPosZ), serverCamLookX + serverLerpSpeed * (serverTargetLookX - serverCamLookX), serverCamLookY + serverLerpSpeed * (serverTargetLookY - serverCamLookY), serverCamLookZ + serverLerpSpeed * (serverTargetLookZ - serverCamLookZ));
    end;
    onClientJoiningTimer = function() 
        if currentTeam == 0 then
            local __ = classtm;
            classtm = (classtm or 1) + 1;
            local serverTeamCount = getElementsByType("team");
            if classtm > #serverTeamCount then
                classtm = 1;
            end;
            local serverSelectedTeam = serverTeamCount[classtm];
            guiLabelSetColor(joining_teamname, getTeamColor(serverSelectedTeam));
        elseif not getPedAnimation(currentPed[currentTeam]) then
            local serverRandomAnimation = ({
                "shift", 
                "shldr", 
                "stretch", 
                "strleg", 
                "time"
            })[math.random(5)];
            for __, serverPedElement in ipairs(currentPed) do
                setPedAnimation(serverPedElement, "PLAYIDLES", serverRandomAnimation, -1, false, false, false, false);
            end;
        end;
    end;
    switchCurrentTeam = function(serverSwitchParam, __, serverDirection) 
        if type(serverSwitchParam) == "number" then
            serverDirection = serverSwitchParam;
        end;
        local serverAllTeams = getElementsByType("team");
        table.insert(serverAllTeams, serverAllTeams[1]);
        table.remove(serverAllTeams, 1);
        if currentMenu == 2 then
            local serverTeamSkins = getElementData(serverAllTeams[currentTeam], "Skins") or {
                71
            };
            currentSkin[currentTeam] = (currentSkin[currentTeam] + serverDirection) % (#serverTeamSkins + 1);
            if currentSkin[currentTeam] > 0 then
                setElementModel(currentPed[currentTeam], serverTeamSkins[currentSkin[currentTeam]]);
                setPedAnimation(currentPed[currentTeam], "PLAYIDLES", "null");
                guiSetText(joining_skinname, string.format("%i/%i", currentSkin[currentTeam], #serverTeamSkins));
            else
                guiSetText(joining_skinname, "Spectate");
            end;
        elseif currentMenu == 1 then
            if serverDirection > 0 then
                playSoundFrontEnd(18);
            else
                playSoundFrontEnd(17);
            end;
            local l_currentTeam_0 = currentTeam;
            currentTeam = (currentTeam + serverDirection) % (#serverAllTeams + 1);
            if l_currentTeam_0 and currentPed[l_currentTeam_0] then
                setElementAlpha(currentPed[l_currentTeam_0], 0);
            end;
            if currentTeam > 0 then
                setElementAlpha(currentPed[currentTeam], 255);
                guiSetText(joining_teamname, getTeamName(serverAllTeams[currentTeam]));
                guiLabelSetColor(joining_teamname, getTeamColor(serverAllTeams[currentTeam]));
                currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      
                if currentTeam < #serverAllTeams then
                    if currentSkin[currentTeam] > 0 then
                        local serverSkinModel = getElementData(serverAllTeams[currentTeam], "Skins") or {
                            71
                        };
                        guiSetText(joining_skinname, string.format("%i/%i", currentSkin[currentTeam], #serverSkinModel));
                    else
                        guiSetText(joining_skinname, "Spectate");
                    end;
                    guiSetVisible(joining_skinleft, true);
                    guiSetVisible(joining_skinname, true);
                    guiSetVisible(joining_skinright, true);
                else
                    guiSetVisible(joining_skinleft, false);
                    guiSetVisible(joining_skinname, false);
                    guiSetVisible(joining_skinright, false);
                end;
            else
                guiSetText(joining_teamname, "Auto-assign");
                currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    
                guiSetVisible(joining_skinleft, false);
                guiSetVisible(joining_skinname, false);
                guiSetVisible(joining_skinright, false);
            end;
        end;
    end;
    switchCurrentMenu = function(serverMenuParam1, serverMenuParam2, serverMenuIndex) 
        if not serverMenuParam2 then
            serverMenuIndex = serverMenuParam1;
        end;
        local serverNewMenu = 0;
        if type(serverMenuIndex) == "number" then
            serverNewMenu = (currentMenu + serverMenuIndex) % 5;
            if serverNewMenu == 2 and (currentTeam == 0 or currentTeam == #getElementsByType("team")) then
                serverNewMenu = (serverNewMenu + serverMenuIndex) % 5;
            end;
        else
            serverNewMenu = tonumber(serverMenuIndex) or 0;
        end;
        if serverNewMenu == 4 then
            currentCamera = {314.7, -140.2, 1005.5, 1343, -1848.7, 1157.2};     
        elseif serverNewMenu == 3 then
            currentCamera = {315.1, -131.4, 1004.6, 1881.5, 951.9, 394.4};      
        elseif currentTeam == 0 then
            currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    
        else
            currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      
        end;
        if currentMenu ~= serverNewMenu then
            playSoundFrontEnd(3);
            currentMenu = serverNewMenu;
            guiSetPosition(joining_selection, 0.04500000000000001, 0.8 - 0.05 * serverNewMenu - 0.005, true);
        end;
    end;
    selectCurrentTeam = function() 
        if currentMenu == 0 or currentMenu == 1 or currentMenu == 2 then
            if currentTeam > 0 then
                currentCamera = {309.9, -132.9, 1004, -1197.3, 1181.2, 963.9};      
            else
                currentCamera = {315.4, -136.7, 1005.3, 2244.4, -506.5, 1382.8};     
            end;
            unbindKey("arrow_l", "down", switchCurrentTeam);
            unbindKey("arrow_r", "down", switchCurrentTeam);
            unbindKey("arrow_u", "down", switchCurrentMenu);
            unbindKey("arrow_d", "down", switchCurrentMenu);
            unbindKey("enter", "down", selectCurrentTeam);
            guiSetVisible(joining_background, false);
            playSoundFrontEnd(11);
            fadeCamera(false, 1);
            setTimer(function() 
                if currentTeam > 0 then
                    local serverTeamArray = getElementsByType("team");
                    table.insert(serverTeamArray, serverTeamArray[1]);
                    table.remove(serverTeamArray, 1);
                    if not getElementData(serverTeamArray[currentTeam], "Skins") then
                        local __ = {
                            71
                        };
                    end;
                    setElementData(localPlayer, "spectateskin", currentSkin[currentTeam] <= 0 or nil);
                    triggerServerEvent("onPlayerTeamSelect", localPlayer, serverTeamArray[currentTeam], getElementModel(currentPed[currentTeam]));
                else
                    setElementData(localPlayer, "spectateskin", nil);
                    triggerServerEvent("onPlayerTeamSelect", localPlayer);
                end;
            end, 1000, 1);
        elseif currentMenu == 3 then
            executeCommandHandler("player_config", "Gameplay");
        elseif currentMenu == 4 then
            executeCommandHandler("credits");
        end;
    end;
    onClientElementDataChange = function(serverDataChanged, serverOldValue) 
        if serverDataChanged == "Status" then
            if getElementData(source, serverDataChanged) == "Joining" and serverOldValue ~= "Joining" then
                setElementData(localPlayer, "Loading", nil);
                stopCameraPrepair();
                bindKey("arrow_l", "down", switchCurrentTeam, -1);
                bindKey("arrow_r", "down", switchCurrentTeam, 1);
                bindKey("arrow_u", "down", switchCurrentMenu, 1);
                bindKey("arrow_d", "down", switchCurrentMenu, -1);
                bindKey("enter", "down", selectCurrentTeam);
                addEventHandler("onClientRender", root, onClientJoiningRender);
                classAutoChoice = setTimer(onClientJoiningTimer, 200, 0);
                if currentTeam > 0 then
                    currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      
                else
                    currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    
                end;
                setCameraMatrix(315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8);         
                setElementInterior(localPlayer, 7);
                setCameraInterior(7);
                local serverSortedTeams = getElementsByType("team");
                table.insert(serverSortedTeams, serverSortedTeams[1]);
                table.remove(serverSortedTeams, 1);
                for serverTeamIdx, serverTeamData in ipairs(serverSortedTeams) do
                    currentSkin[serverTeamIdx] = 1;
                    local serverDefaultSkin = (getElementData(serverTeamData, "Skins") or {
                        71
                    })[1];
                    currentPed[serverTeamIdx] = createPed(serverDefaultSkin, 308.2, -131.4, 1004, 220);
                    setElementInterior(currentPed[serverTeamIdx], 7);
                    setElementFrozen(currentPed[serverTeamIdx], true);
                    if currentTeam ~= serverTeamIdx then
                        setElementAlpha(currentPed[serverTeamIdx], 0);
                    end;
                end;
                guiSetVisible(joining_background, true);
                showCursor(true);
            elseif getElementData(source, serverDataChanged) ~= "Joining" and serverOldValue == "Joining" then
                unbindKey("arrow_l", "down", switchCurrentTeam);
                unbindKey("arrow_r", "down", switchCurrentTeam);
                unbindKey("arrow_u", "down", switchCurrentMenu);
                unbindKey("arrow_d", "down", switchCurrentMenu);
                unbindKey("enter", "down", selectCurrentTeam);
                guiSetVisible(joining_background, false);
                for __, serverPedToDestroy in ipairs(currentPed) do
                    if isElement(serverPedToDestroy) then
                        destroyElement(serverPedToDestroy);
                    end;
                end;
                currentPed = {};
                killTimer(classAutoChoice);
                removeEventHandler("onClientRender", root, onClientJoiningRender);
                setCameraTarget(localPlayer);
                updateWeather();
                guiSetVisible(joining_background, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
        end;
    end;
    onClientGUIClick = function(serverMouseButton, __, __, __) 
        if serverMouseButton ~= "left" then
            return;
        else
            if source == joining_credits then
                executeCommandHandler("credits");
            end;
            if source == joining_language then
                executeCommandHandler("player_config", "Gameplay");
            end;
            if source == joining_teamleft or source == joining_skinleft then
                switchCurrentTeam(-1);
            end;
            if source == joining_teamright or source == joining_skinright then
                switchCurrentTeam(1);
            end;
            if source == joining_spawn or source == joining_teamname or source == joining_skinname then
                selectCurrentTeam();
            end;
            return;
        end;
    end;
    onClientMouseEnter = function(__, __) 
        if source == joining_credits then
            switchCurrentMenu("4");
        end;
        if source == joining_language then
            switchCurrentMenu("3");
        end;
        if source == joining_skinname or source == joining_skinleft or source == joining_skinright then
            switchCurrentMenu("2");
        end;
        if source == joining_teamname or source == joining_teamleft or source == joining_teamright then
            switchCurrentMenu("1");
        end;
        if source == joining_spawn then
            switchCurrentMenu("0");
        end;
    end;
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientElementDataChange", localPlayer, onClientElementDataChange);
    addEventHandler("onClientGUIClick", root, onClientGUIClick);
    addEventHandler("onClientMouseEnter", root, onClientMouseEnter);
end)();
(function(...) 
    loadedLanguage = false;
    fpsdata = {{0, getTickCount()}};
    plossdata = {{0, getTickCount()}};
    onClientResourceStart = function(__) 
        loadedLanguage = false;
        _loadingConfig = true; 
        _client = xmlLoadFile("config/_client.xml");
        if not _client then
            _client = xmlCreateFile("config/_client.xml", "config");
        end;
        config_window = guiCreateWindow(xscreen * 0.5 - 240, yscreen * 0.5 - 240, 480, 480, "", false);
        guiWindowSetSizable(config_window, false);
        guiSetVisible(config_window, false);
        config_pagelist = guiCreateGridList(5, 25, 120, 420, false, config_window);
        guiGridListSetSortingEnabled(config_pagelist, false);
        guiGridListAddColumn(config_pagelist, "Contents", 0.8);
        config_pages = {Settings = {Audio = true, Gameplay = true, Performance = true}};
        config_scrollers = {};
        config_scrollers.Audio = guiCreateGridList(135, 25, 340, 460, false, config_window);
        guiSetVisible(config_scrollers.Audio, false);
        if not _client then
            _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
        end;
        local serverAudioNode = xmlFindChild(_client, "audio", 0);
        if not serverAudioNode then
            serverAudioNode = xmlCreateChild(_client, "audio");
            if not xmlNodeGetAttribute(serverAudioNode, "voice") then
                xmlNodeSetAttribute(serverAudioNode, "voice", "true");
            end;
            if not xmlNodeGetAttribute(serverAudioNode, "voicevol") then
                xmlNodeSetAttribute(serverAudioNode, "voicevol", "100");
            end;
            if not xmlNodeGetAttribute(serverAudioNode, "music") then
                xmlNodeSetAttribute(serverAudioNode, "music", "true");
            end;
            if not xmlNodeGetAttribute(serverAudioNode, "musicvol") then
                xmlNodeSetAttribute(serverAudioNode, "musicvol", "100");
            end;
        end;
        temp = xmlNodeGetAttribute(serverAudioNode, "voice") or "true";
        config_audio_voice = guiCreateCheckBox(0.05, 0.04, 0.33, 0.04, "Voice Sounds", temp == "true", true, config_scrollers.Audio);
        config_audio_voicevol = guiCreateScrollBar(0.42, 0.04, 0.43, 0.04, true, true, config_scrollers.Audio);
        config_audio_voicelab = guiCreateLabel(0.85, 0.04, 0.1, 0.04, "100%", true, config_scrollers.Audio);
        temp = tonumber(xmlNodeGetAttribute(serverAudioNode, "voicevol") or "100");
        guiSetProperty(config_audio_voicevol, "ScrollPosition", tostring(temp));
        guiSetText(config_audio_voicelab, temp .. "%");
        temp = xmlNodeGetAttribute(serverAudioNode, "music") or "true";
        config_audio_music = guiCreateCheckBox(0.05, 0.1, 0.33, 0.04, "Music", temp == "true", true, config_scrollers.Audio);
        config_audio_musicvol = guiCreateScrollBar(0.42, 0.1, 0.43, 0.04, true, true, config_scrollers.Audio);
        config_audio_musiclab = guiCreateLabel(0.85, 0.1, 0.1, 0.04, "100%", true, config_scrollers.Audio);
        temp = tonumber(xmlNodeGetAttribute(serverAudioNode, "musicvol") or "100");
        guiSetProperty(config_audio_musicvol, "ScrollPosition", tostring(temp));
        guiSetText(config_audio_musiclab, temp .. "%");
        config_scrollers.Gameplay = guiCreateGridList(135, 25, 340, 460, false, config_window);
        guiSetVisible(config_scrollers.Gameplay, false);
        local serverGameplayNode = xmlFindChild(_client, "gameplay", 0);
        if not serverGameplayNode then
            serverGameplayNode = xmlCreateChild(_client, "gameplay");
            xmlNodeSetAttribute(serverGameplayNode, "language", "language/english.lng");
            xmlNodeSetAttribute(serverGameplayNode, "nitrocontrol", "toggle");
        end;
        guiCreateLabel(0.05, 0.04, 0.43, 0.04, "Language:", true, config_scrollers.Gameplay);
        local serverLanguageSetting = xmlNodeGetAttribute(serverGameplayNode, "language") or "language/english.lng";
        config_gameplay_language = guiCreateComboBox(0.52, 0.04, 0.43, 0.6, "", true, config_scrollers.Gameplay);
        config_gameplay_languagelist = {};
        local serverLanguagesFile = xmlLoadFile("language/languages.xml");
        if serverLanguagesFile then
            local serverLanguageNodes = xmlNodeGetChildren(serverLanguagesFile);
            table.sort(serverLanguageNodes, function(serverLangNodeA, serverLangNodeB) 
                return xmlNodeGetAttribute(serverLangNodeA, "src") < xmlNodeGetAttribute(serverLangNodeB, "src");
            end);
            for __, serverLanguageNode in ipairs(serverLanguageNodes) do
                local serverLanguagePath = xmlNodeGetAttribute(serverLanguageNode, "src");
                local serverLanguageXML = xmlLoadFile(serverLanguagePath);
                if serverLanguageXML then
                    local serverLanguageName = xmlNodeGetAttribute(serverLanguageXML, "name");
                    guiComboBoxAddItem(config_gameplay_language, serverLanguageName);
                    config_gameplay_languagelist[serverLanguagePath] = serverLanguageName;
                    config_gameplay_languagelist[serverLanguageName] = serverLanguagePath;
                    if serverLanguagePath == serverLanguageSetting then
                        guiSetText(config_gameplay_language, serverLanguageName);
                    end;
                    xmlUnloadFile(serverLanguageXML);
                end;
            end;
            xmlUnloadFile(serverLanguagesFile);
        end;
        guiCreateLabel(0.05, 0.1, 0.43, 0.04, "Nitro Control:", true, config_scrollers.Gameplay);
        local serverNitroControlSetting = xmlNodeGetAttribute(serverGameplayNode, "nitrocontrol") or "toggle";
        config_gameplay_nitrocontrol = guiCreateComboBox(0.52, 0.1, 0.43, 0.2, ({toggle = "Toggle", hold = "Hold"})[serverNitroControlSetting], true, config_scrollers.Gameplay);
        guiComboBoxAddItem(config_gameplay_nitrocontrol, "Toggle");
        guiComboBoxAddItem(config_gameplay_nitrocontrol, "Hold");
        config_scrollers.Performance = guiCreateGridList(135, 25, 340, 460, false, config_window);
        guiSetVisible(config_scrollers.Performance, false);
        local serverPerformanceNode = xmlFindChild(_client, "performance", 0);
        if not serverPerformanceNode then
            serverPerformanceNode = xmlCreateChild(_client, "performance");
            xmlNodeSetAttribute(serverPerformanceNode, "vehmanager", "false");
            xmlNodeSetAttribute(serverPerformanceNode, "weapmanager", "true");
            xmlNodeSetAttribute(serverPerformanceNode, "fpsgraphic", "false");
            xmlNodeSetAttribute(serverPerformanceNode, "plossgraphic", "false");
            xmlNodeSetAttribute(serverPerformanceNode, "speclist", "true");
            xmlNodeSetAttribute(serverPerformanceNode, "roundhud", "false");
            xmlNodeSetAttribute(serverPerformanceNode, "valueshud", "false");
            xmlNodeSetAttribute(serverPerformanceNode, "helpinfo", "true");
            xmlNodeSetAttribute(serverPerformanceNode, "laser", "true");
        end;
        config_performance_usecpu = guiCreateLabel(0.05, 0.04, 0.3, 0.06, "CPU: 0.0%", true, config_scrollers.Performance);
        config_performance_usetiming = guiCreateLabel(0.35, 0.04, 0.3, 0.06, "Timing: 0.000", true, config_scrollers.Performance);
        config_performance_usememory = guiCreateLabel(0.65, 0.04, 0.3, 0.06, "Memory: 0 KB", true, config_scrollers.Performance);
        temp = guiCreateLabel(0.05, 0.1, 0.9, 0.06, "Unload hidden GUI", true, config_scrollers.Performance);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = xmlNodeGetAttribute(serverPerformanceNode, "vehmanager") or "false";
        config_performance_vehmanager = guiCreateCheckBox(0.05, 0.16, 0.43, 0.04, "Vehicle manager", temp == "true", true, config_scrollers.Performance);
        if temp ~= "true" then
            guiSetVisible(createVehicleManager(), false);
        end;
        temp = xmlNodeGetAttribute(serverPerformanceNode, "weapmanager") or "false";
        config_performance_weapmanager = guiCreateCheckBox(0.52, 0.16, 0.43, 0.04, "Weapon manager", temp == "true", true, config_scrollers.Performance);
        if temp ~= "true" then
            guiSetVisible(createWeaponManager(), false);
        end;
        temp = xmlNodeGetAttribute(serverPerformanceNode, "adminpanel") or "true";
        config_performance_adminpanel = guiCreateCheckBox(0.05, 0.22, 0.43, 0.04, "Admin Panel", temp == "false", true, config_scrollers.Performance);
        if temp ~= "false" then
            guiSetVisible(createAdminPanel(), false);
            guiSetVisible(createAdminRestore(), false);
            guiSetVisible(createAdminRedirect(), false);
            guiSetVisible(createAdminSaveConfig(), false);
            guiSetVisible(createAdminAddConfig(), false);
            guiSetVisible(createAdminRules(), false);
            guiSetVisible(createAdminPalette(), false);
            guiSetVisible(createAdminRenameConfig(), false);
            guiSetVisible(createAdminScreen(), false);
            guiSetVisible(createAdminMods(), false);
        end;
        temp = guiCreateLabel(0.05, 0.27999999999999997, 0.9, 0.06, "Rendering", true, config_scrollers.Performance);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = xmlNodeGetAttribute(serverPerformanceNode, "fpsgraphic") or "true";
        config_performance_fps = guiCreateCheckBox(0.05, 0.33999999999999997, 0.43, 0.04, "FPS Diagram", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "plossgraphic") or "true";
        config_performance_ploss = guiCreateCheckBox(0.05, 0.39999999999999997, 0.43, 0.04, "PacketLoss Diagram", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "helpinfo") or "true";
        config_performance_helpinfo = guiCreateCheckBox(0.05, 0.45999999999999996, 0.43, 0.04, "Help Info", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "speclist") or "true";
        config_performance_spec = guiCreateCheckBox(0.52, 0.33999999999999997, 0.43, 0.04, "Spectate List", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "roundhud") or "true";
        config_performance_roundhud = guiCreateCheckBox(0.52, 0.39999999999999997, 0.43, 0.04, "Round HUD", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "valueshud") or "true";
        config_performance_valueshud = guiCreateCheckBox(0.52, 0.45999999999999996, 0.43, 0.04, "Values of HUD", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(serverPerformanceNode, "laser") or "true";
        config_performance_laser = guiCreateCheckBox(0.05, 0.52, 0.43, 0.04, "Aim Lasers", temp == "true", true, config_scrollers.Performance);
        guiGridListClear(config_pagelist);
        for serverConfigCategory, serverCategoryData in pairs(config_pages) do
            if type(serverCategoryData) == "table" then
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, serverConfigCategory, true, false);
                for serverSubCategory in pairs(serverCategoryData) do
                    guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, serverSubCategory, false, false);
                end;
            else
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, serverConfigCategory, false, false);
            end;
        end;
        config_close = guiCreateButton(5, 450, 120, 30, "Close", false, config_window);
        guiSetFont(config_close, "default-bold-small");
        xmlSaveFile(_client);
        _loadingConfig = false; 
        values_hud = guiCreateStaticImage(0, 0, xscreen, yscreen, "images/color_pixel.png", false);
        guiSetProperty(values_hud, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        guiSetVisible(values_hud, false);
        guiSetEnabled(values_hud, false);
        hud_health = guiCreateLabel(xscreen * 0.955, yscreen * 0.158 - 20, 100, 40, "", false, values_hud);
        guiLabelSetVerticalAlign(hud_health, "center");
        guiSetFont(hud_health, "default-bold-small");
        guiLabelSetColor(hud_health, 180, 29, 25);
        hud_armor = guiCreateLabel(xscreen * 0.955, yscreen * 0.11 - 20, 100, 40, "", false, values_hud);
        guiLabelSetVerticalAlign(hud_armor, "center");
        guiSetFont(hud_armor, "default-bold-small");
        guiLabelSetColor(hud_armor, 240, 240, 240);
        hud_fps = guiCreateLabel(xscreen * 0.955, yscreen * 0.012 - 20, 100, 40, "", false);
        guiLabelSetVerticalAlign(hud_fps, "center");
        guiSetFont(hud_fps, "default-bold-small");
        guiLabelSetColor(hud_fps, 0, 255, 0);
        hud_ploss = guiCreateLabel(xscreen * 0.955, yscreen * 0.042 - 20, 100, 40, "", false);
        guiLabelSetVerticalAlign(hud_ploss, "center");
        guiSetFont(hud_ploss, "default-bold-small");
        guiLabelSetColor(hud_ploss, 0, 128, 255);
        if guiCheckBoxGetSelected(config_performance_fps) and getElementData(localPlayer, "Status") ~= "Joining" then
            addEventHandler("onClientRender", root, onClientFPSDiagramRender);
        else
            guiSetVisible(hud_fps, false);
        end;
        if guiCheckBoxGetSelected(config_performance_ploss) and getElementData(localPlayer, "Status") ~= "Joining" then
            addEventHandler("onClientRender", root, onClientPLossDiagramRender);
        else
            guiSetVisible(hud_ploss, false);
        end;
        if guiCheckBoxGetSelected(config_performance_valueshud) then
            addEventHandler("onClientElementDataChange", localPlayer, onClientValuesHUDElementDataChange);
            if getElementData(localPlayer, "Status") == "Play" then
                addEventHandler("onClientRender", root, onClientValuesHUDRender);
                guiSetVisible(values_hud, true);
            end;
        end;
    end;
    local serverDiagramX = xscreen * 0.78;
    local serverDiagramY = yscreen * 0.012;
    local serverDiagramWidth = xscreen * 0.17;
    local serverDiagramHeight = yscreen * 0.03;
    local serverLineThickness = math.ceil(yscreen * 0.001);
    local __ = xscreen * 0.955;
    local serverMaxFPS = 50;
    local serverMinFPS = 0;
    local serverFpsColor = tocolor(0, 255, 0);
    onClientFPSDiagramRender = function() 
        local serverCurrentTick = getTickCount();
        local serverFadeTime = 30000;
        for serverFpsIndex, serverFpsEntry in ipairs(fpsdata) do
            local serverFpsValue1 = 1 - (math.max(math.min(tonumber(serverFpsEntry[1]), serverMaxFPS), serverMinFPS) - serverMinFPS) / (serverMaxFPS - serverMinFPS);
            local serverFpsValue2 = serverFpsIndex < #fpsdata and 1 - (math.max(math.min(tonumber(fpsdata[serverFpsIndex + 1][1]), serverMaxFPS), serverMinFPS) - serverMinFPS) / (serverMaxFPS - serverMinFPS) or serverFpsValue1;
            local serverTimeFactor1 = math.min(1, (serverCurrentTick - serverFpsEntry[2]) / serverFadeTime);
            if serverFpsIndex > 1 then
                local serverTimeFactor2 = (serverCurrentTick - fpsdata[serverFpsIndex - 1][2]) / serverFadeTime;
                if serverTimeFactor2 >= 1 then
                    for __ = serverFpsIndex, #fpsdata do
                        table.remove(fpsdata, serverFpsIndex);
                    end;
                    break;
                else
                    dxDrawLine(serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverTimeFactor1, serverDiagramY + serverDiagramHeight * serverFpsValue2, serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverTimeFactor2, serverDiagramY + serverDiagramHeight * serverFpsValue1, serverFpsColor, serverLineThickness);
                end;
            else
                dxDrawLine(serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverTimeFactor1, serverDiagramY + serverDiagramHeight * serverFpsValue2, serverDiagramX + serverDiagramWidth, serverDiagramY + serverDiagramHeight * serverFpsValue1, serverFpsColor, serverLineThickness);
            end;
        end;
        local serverFpsText = tostring(fpsdata[1][1]);
        if guiGetText(hud_fps) ~= serverFpsText then
            guiSetText(hud_fps, serverFpsText);
        end;
    end;
    local serverMaxPacketLoss = 10;
    local serverMinPacketLoss = 0;
    local serverPacketLossColor = tocolor(0, 128, 255);
    onClientPLossDiagramRender = function() 
        local serverPlossTick = getTickCount();
        local serverPlossFadeTime = 30000;
        for serverPlossIndex, serverPlossEntry in ipairs(plossdata) do
            local serverPlossValue1 = 1 - (math.max(math.min(tonumber(serverPlossEntry[1]), serverMaxPacketLoss), serverMinPacketLoss) - serverMinPacketLoss) / (serverMaxPacketLoss - serverMinPacketLoss);
            local serverPlossValue2 = serverPlossIndex < #plossdata and 1 - (math.max(math.min(tonumber(plossdata[serverPlossIndex + 1][1]), serverMaxPacketLoss), serverMinPacketLoss) - serverMinPacketLoss) / (serverMaxPacketLoss - serverMinPacketLoss) or serverPlossValue1;
            local serverPlossFactor1 = math.min(1, (serverPlossTick - serverPlossEntry[2]) / serverPlossFadeTime);
            if serverPlossIndex > 1 then
                local serverPlossFactor2 = (serverPlossTick - plossdata[serverPlossIndex - 1][2]) / serverPlossFadeTime;
                if serverPlossFactor2 >= 1 then
                    for __ = serverPlossIndex, #plossdata do
                        table.remove(plossdata, serverPlossIndex);
                    end;
                    break;
                else
                    dxDrawLine(serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverPlossFactor1, serverDiagramY + serverDiagramHeight * serverPlossValue2, serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverPlossFactor2, serverDiagramY + serverDiagramHeight * serverPlossValue1, serverPacketLossColor, serverLineThickness);
                end;
            else
                dxDrawLine(serverDiagramX + serverDiagramWidth - serverDiagramWidth * serverPlossFactor1, serverDiagramY + serverDiagramHeight * serverPlossValue2, serverDiagramX + serverDiagramWidth, serverDiagramY + serverDiagramHeight * serverPlossValue1, serverPacketLossColor, serverLineThickness);
            end;
        end;
        local serverPlossText = string.format("%.2f", plossdata[1][1]);
        if guiGetText(hud_ploss) ~= serverPlossText then
            guiSetText(hud_ploss, serverPlossText);
        end;
    end;
    local serverFpsCounter = 0;
    local serverUpdateCounter = 0;
    local serverLowFPSWarnings = 0;
    local serverHighPingWarnings = 0;
    local serverHighPacketLossWarnings = 0;
    local serverMaxTotalPacketLoss = 100;
    local serverMaxPing = 65536;
    local serverMaxFPSWarnings = 10;
    local serverMaxPingWarnings = 10;
    local serverMaxPacketLossWarnings = 3;
    onClientFPSCount = function() 
        serverFpsCounter = serverFpsCounter + 1;
    end;
    updateLimites = function() 
        setElementData(localPlayer, "FPS", tostring(serverFpsCounter), false);
        setElementData(localPlayer, "PLoss", tostring(getNetworkStats().packetlossLastSecond), false);
        if serverFpsCounter < serverMinFPS then
            serverLowFPSWarnings = serverLowFPSWarnings + 1;
            if serverMaxFPSWarnings < serverLowFPSWarnings then
                callServerFunction("kickPlayer", localPlayer, "Low FPS (" .. serverFpsCounter .. " < " .. serverMinFPS .. ")");
                serverLowFPSWarnings = 0;
            end;
        else
            serverLowFPSWarnings = 0;
        end;
        if getPlayerPing(localPlayer) > serverMaxPing then
            serverHighPingWarnings = serverHighPingWarnings + 1;
            if serverMaxPingWarnings < serverHighPingWarnings then
                callServerFunction("kickPlayer", localPlayer, "High Ping (" .. getPlayerPing(localPlayer) .. " > " .. serverMaxPing .. ")");
                serverHighPingWarnings = 0;
            end;
        else
            serverHighPingWarnings = 0;
        end;
        if serverMaxPacketLoss > 0 then
            local l_packetlossLastSecond_0 = getNetworkStats().packetlossLastSecond;
            if serverMaxPacketLoss < l_packetlossLastSecond_0 then
                serverHighPacketLossWarnings = serverHighPacketLossWarnings + 1;
                if serverMaxPacketLossWarnings < serverHighPacketLossWarnings then
                    callServerFunction("kickPlayer", localPlayer, string.format("High Packetloss (%.2f > %.2f)", l_packetlossLastSecond_0, serverMaxPacketLoss));
                    serverHighPacketLossWarnings = 0;
                end;
            else
                serverHighPacketLossWarnings = 0;
            end;
        end;
        if serverMaxTotalPacketLoss > 0 then
            local l_packetlossTotal_0 = getNetworkStats().packetlossTotal;
            if serverMaxTotalPacketLoss < l_packetlossTotal_0 then
                callServerFunction("kickPlayer", localPlayer, string.format("High Packetloss Total (%.2f > %.2f)", l_packetlossTotal_0, serverMaxTotalPacketLoss));
            end;
        end;
        serverFpsCounter = -1;
        serverUpdateCounter = serverUpdateCounter + 1;
        if serverUpdateCounter > 10 then
            setElementData(localPlayer, "FPS", getElementData(localPlayer, "FPS"))
            setElementData(localPlayer, "PLoss", getElementData(localPlayer, "PLoss"))
            serverUpdateCounter = 0;
        end;
    end;
    addUserPanelPage = function(serverPanelCategory, serverPanelName)
        if config_scrollers[serverPanelName] then
            return false;
        else
            config_pages[serverPanelCategory][serverPanelName] = true;
            config_scrollers[serverPanelName] = guiCreateGridList(135, 25, 340, 460, false, config_window);
            guiSetVisible(config_scrollers[serverPanelName], false);
            guiGridListClear(config_pagelist);
            for serverPageCategory, serverPageData in pairs(config_pages) do
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, serverPageCategory, true, false);
                for serverPageName in pairs(serverPageData) do
                    guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, serverPageName, false, false);
                end;
            end;
            return config_scrollers[serverPanelName];
        end;
    end;
    onClientTacticsChange = function(serverTacticsChange, __) 
        if serverTacticsChange[1] == "version" then
            local serverVersionNumber = getTacticsData("version");
            guiSetText(config_window, "Tactics " .. tostring(serverVersionNumber) .. " - User Panel");
        end;
        if serverTacticsChange[1] == "limites" then
            if serverTacticsChange[2] == "fps_limit" then
                serverMaxFPS = tonumber(getTacticsData("limites", "fps_limit"));
            elseif serverTacticsChange[2] == "fps_minimal" then
                serverMinFPS = tonumber(getTacticsData("limites", "fps_minimal"));
            elseif serverTacticsChange[2] == "packetloss_second" then
                serverMaxPacketLoss = tonumber(getTacticsData("limites", "packetloss_second"));
                if serverMaxPacketLoss == 0 then
                    serverMaxPacketLoss = 10;
                end;
            elseif serverTacticsChange[2] == "packetloss_total" then
                serverMaxTotalPacketLoss = tonumber(getTacticsData("limites", "packetloss_total"));
            elseif serverTacticsChange[2] == "ping_maximal" then
                serverMaxPing = tonumber(getTacticsData("limites", "ping_maximal"));
            elseif serverTacticsChange[2] == "warnings_fps" then
                serverMaxFPSWarnings = tonumber(getTacticsData("limites", "warnings_fps"));
            elseif serverTacticsChange[2] == "warnings_ping" then
                serverMaxPingWarnings = tonumber(getTacticsData("limites", "warnings_ping"));
            elseif serverTacticsChange[2] == "warnings_packetloss" then
                serverMaxPacketLossWarnings = tonumber(getTacticsData("limites", "warnings_packetloss"));
            end;
        end;
    end;
    checkPerformance = function() 
        if not guiGetVisible(config_scrollers.Performance) then
            return killTimer(updPerformance);
        else
            local __, serverTimingStats = getPerformanceStats("Lua timing", "", "tactics");
            local __, serverMemoryStats = getPerformanceStats("Lua memory", "", "tactics");
            local serverCpuUsage = serverTimingStats[1][2];
            local serverLuaTiming = serverTimingStats[1][3];
            local serverLuaMemory = serverMemoryStats[1][3];
            guiSetText(config_performance_usecpu, "CPU: " .. serverCpuUsage);
            guiSetText(config_performance_usetiming, "Timing: " .. serverLuaTiming);
            guiSetText(config_performance_usememory, "Memory: " .. serverLuaMemory);
            return;
        end;
    end;
    onClientGUIClick = function(serverConfigMouseButton, __, __, __) 
        if serverConfigMouseButton ~= "left" then
            return;
        else
            if source == config_pagelist then
                local serverSelectedPage = false;
                local serverSelectedRow = guiGridListGetSelectedItem(config_pagelist);
                if serverSelectedRow >= 0 then
                    serverSelectedPage = guiGridListGetItemText(config_pagelist, serverSelectedRow, 1);
                end;
                for serverScrollerName, serverScrollerElement in pairs(config_scrollers) do
                    if serverSelectedPage == serverScrollerName then
                        guiSetVisible(serverScrollerElement, true);
                        if serverSelectedPage == "Performance" and not isTimer(updPerformance) then
                            updPerformance = setTimer(checkPerformance, 500, 0);
                        end;
                    else
                        guiSetVisible(serverScrollerElement, false);
                    end;
                end;
            end;
            if source == config_close then
                guiSetVisible(config_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if source == config_performance_fps then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverPerformanceConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_fps) then
                    xmlNodeSetAttribute(serverPerformanceConfigNode, "fpsgraphic", "true");
                    addEventHandler("onClientRender", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, true);
                else
                    xmlNodeSetAttribute(serverPerformanceConfigNode, "fpsgraphic", "false");
                    removeEventHandler("onClientRender", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, false);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_ploss then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverPlossConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_ploss) then
                    xmlNodeSetAttribute(serverPlossConfigNode, "plossgraphic", "true");
                    addEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, true);
                else
                    xmlNodeSetAttribute(serverPlossConfigNode, "plossgraphic", "false");
                    removeEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, false);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_spec then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverSpecListConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_spec) then
                    xmlNodeSetAttribute(serverSpecListConfigNode, "speclist", "true");
                    guiSetAlpha(speclist, 0.5);
                else
                    xmlNodeSetAttribute(serverSpecListConfigNode, "speclist", "false");
                    guiSetAlpha(speclist, 0);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_roundhud then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverRoundHudConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_roundhud) then
                    xmlNodeSetAttribute(serverRoundHudConfigNode, "roundhud", "true");
                    for __, serverHudComponent in pairs(components) do
                        guiSetAlpha(serverHudComponent.root, 1);
                    end;
                else
                    xmlNodeSetAttribute(serverRoundHudConfigNode, "roundhud", "false");
                    for __, serverComponentEntry in pairs(components) do
                        guiSetAlpha(serverComponentEntry.root, 0);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_helpinfo then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverHelpInfoConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_helpinfo) then
                    xmlNodeSetAttribute(serverHelpInfoConfigNode, "helpinfo", "true");
                    guiSetAlpha(infowindow, 1);
                else
                    xmlNodeSetAttribute(serverHelpInfoConfigNode, "helpinfo", "false");
                    guiSetAlpha(infowindow, 0);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_valueshud then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverValuesHudConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_valueshud) then
                    xmlNodeSetAttribute(serverValuesHudConfigNode, "valueshud", "true");
                    guiSetAlpha(values_hud, 1);
                    addEventHandler("onClientElementDataChange", localPlayer, onClientValuesHUDElementDataChange);
                    if getElementData(localPlayer, "Status") == "Play" then
                        addEventHandler("onClientRender", root, onClientValuesHUDRender);
                    end;
                else
                    xmlNodeSetAttribute(serverValuesHudConfigNode, "valueshud", "false");
                    guiSetAlpha(values_hud, 0);
                    removeEventHandler("onClientElementDataChange", localPlayer, onClientValuesHUDElementDataChange);
                    if getElementData(localPlayer, "Status") == "Play" then
                        removeEventHandler("onClientRender", root, onClientValuesHUDRender);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_laser then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverLaserConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_laser) then
                    xmlNodeSetAttribute(serverLaserConfigNode, "laser", "true");
                    if next(laseraimRender) then
                        addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                    end;
                else
                    xmlNodeSetAttribute(serverLaserConfigNode, "laser", "false");
                    if next(laseraimRender) then
                        removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                        for __, serverLaserMarker in pairs(laseraimRender) do
                            setMarkerColor(serverLaserMarker, 0, 0, 0, 0);
                        end;
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_audio_voice then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverVoiceConfigNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
                if guiCheckBoxGetSelected(config_audio_voice) then
                    xmlNodeSetAttribute(serverVoiceConfigNode, "voice", "true");
                else
                    xmlNodeSetAttribute(serverVoiceConfigNode, "voice", "false");
                end;
                xmlSaveFile(_client);
            end;
            if source == config_audio_music then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverMusicConfigNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
                if guiCheckBoxGetSelected(config_audio_music) then
                    xmlNodeSetAttribute(serverMusicConfigNode, "music", "true");
                else
                    xmlNodeSetAttribute(serverMusicConfigNode, "music", "false");
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_vehmanager then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverVehicleManagerConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_vehmanager) then
                    xmlNodeSetAttribute(serverVehicleManagerConfigNode, "vehmanager", "true");
                    if not guiGetVisible(vehicle_window) then
                        destroyElement(vehicle_window);
                    end;
                else
                    xmlNodeSetAttribute(serverVehicleManagerConfigNode, "vehmanager", "false");
                    if not isElement(vehicle_window) then
                        guiSetVisible(createVehicleManager(), false);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_weapmanager then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverWeaponManagerConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_weapmanager) then
                    xmlNodeSetAttribute(serverWeaponManagerConfigNode, "weapmanager", "true");
                    if not guiGetVisible(weapon_window) then
                        destroyElement(weapon_window);
                    end;
                else
                    xmlNodeSetAttribute(serverWeaponManagerConfigNode, "weapmanager", "false");
                    if not isElement(weapon_window) then
                        guiSetVisible(createWeaponManager(), false);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_adminpanel then
                if not _client then
                    _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                end;
                local serverAdminPanelConfigNode = xmlFindChild(_client, "performance", 0) or xmlCreateChild(_client, "performance");
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    xmlNodeSetAttribute(serverAdminPanelConfigNode, "adminpanel", "true");
                    if not guiGetVisible(admin_window) then
                        destroyElement(admin_window);
                    end;
                    if not guiGetVisible(restore_window) then
                        destroyElement(restore_window);
                    end;
                    if not guiGetVisible(redirect_window) then
                        destroyElement(redirect_window);
                    end;
                    if not guiGetVisible(save_window) then
                        destroyElement(save_window);
                    end;
                    if not guiGetVisible(add_window) then
                        destroyElement(add_window);
                    end;
                    if not guiGetVisible(rules_window) then
                        destroyElement(rules_window);
                    end;
                    if not guiGetVisible(palette_window) then
                        destroyElement(palette_window);
                    end;
                    if not guiGetVisible(rename_window) then
                        destroyElement(rename_window);
                    end;
                    if not guiGetVisible(screen_window) then
                        destroyElement(screen_window);
                    end;
                    if not guiGetVisible(mods_window) then
                        destroyElement(mods_window);
                    end;
                else
                    xmlNodeSetAttribute(serverAdminPanelConfigNode, "adminpanel", "false");
                    if not isElement(admin_window) then
                        guiSetVisible(createAdminPanel(), false);
                    end;
                    if not isElement(restore_window) then
                        guiSetVisible(createAdminRestore(), false);
                    end;
                    if not isElement(redirect_window) then
                        guiSetVisible(createAdminRedirect(), false);
                    end;
                    if not isElement(save_window) then
                        guiSetVisible(createAdminSaveConfig(), false);
                    end;
                    if not isElement(add_window) then
                        guiSetVisible(createAdminAddConfig(), false);
                    end;
                    if not isElement(rules_window) then
                        guiSetVisible(createAdminRules(), false);
                    end;
                    if not isElement(palette_window) then
                        guiSetVisible(createAdminPalette(), false);
                    end;
                    if not isElement(rename_window) then
                        guiSetVisible(createAdminRenameConfig(), false);
                    end;
                    if not isElement(screen_window) then
                        guiSetVisible(createAdminScreen(), false);
                    end;
                    if not isElement(mods_window) then
                        guiSetVisible(createAdminMods(), false);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            return;
        end;
    end;
    onClientGUIScroll = function(__) 
        if source == config_audio_voicevol then
            local serverVoiceVolume = guiScrollBarGetScrollPosition(config_audio_voicevol);
            guiSetText(config_audio_voicelab, serverVoiceVolume .. "%");
            for __, serverVoiceSound in pairs(voiceThread) do
                if serverVoiceSound then
                    setSoundVolume(serverVoiceSound, 0.01 * serverVoiceVolume);
                end;
            end;
            if isTimer(voiceScroll) then
                resetTimer(voiceScroll);
            else
                voiceScroll = setTimer(function() 
                    if not _client then
                        _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                    end;
                    local serverVoiceVolumeNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
                    local serverSavedVoiceVolume = guiScrollBarGetScrollPosition(config_audio_voicevol);
                    xmlNodeSetAttribute(serverVoiceVolumeNode, "voicevol", tostring(serverSavedVoiceVolume));
                    if serverSavedVoiceVolume == 0 then
                        local currentVoice = xmlNodeGetAttribute(serverVoiceVolumeNode, "voice");
                        if currentVoice == "true" then
                            xmlNodeSetAttribute(serverVoiceVolumeNode, "voice", "false");
                            guiCheckBoxSetSelected(config_audio_voice, false);
                        end;
                    end;
                    xmlSaveFile(_client);
                end, 500, 1);
            end;
        end;
        if source == config_audio_musicvol then
            local serverMusicVolume = guiScrollBarGetScrollPosition(config_audio_musicvol);
            guiSetText(config_audio_musiclab, serverMusicVolume .. "%");
            for __, serverMusicSound in pairs(musicThread) do
                if serverMusicSound then
                    setSoundVolume(serverMusicSound, 0.01 * serverMusicVolume);
                end;
            end;
            if isTimer(musicScroll) then
                resetTimer(musicScroll);
            else
                musicScroll = setTimer(function() 
                    if not _client then
                        _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
                    end;
                    local serverMusicVolumeNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
                    local serverSavedMusicVolume = guiScrollBarGetScrollPosition(config_audio_musicvol);
                    xmlNodeSetAttribute(serverMusicVolumeNode, "musicvol", tostring(serverSavedMusicVolume));
                    if serverSavedMusicVolume == 0 then
                        local currentMusic = xmlNodeGetAttribute(serverMusicVolumeNode, "music");
                        if currentMusic == "true" then
                            xmlNodeSetAttribute(serverMusicVolumeNode, "music", "false");
                            guiCheckBoxSetSelected(config_audio_music, false);
                        end;
                    end;
                    xmlSaveFile(_client);
                end, 500, 1);
            end;
        end;
    end;
    onClientGUIBlur = function() 
        if source == config_audio_voicevol then
            if not _client then
                _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
            end;
            local serverBlurVoiceNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
            local serverBlurVoiceVolume = guiScrollBarGetScrollPosition(config_audio_voicevol);
            xmlNodeSetAttribute(serverBlurVoiceNode, "voicevol", tostring(serverBlurVoiceVolume));
            xmlSaveFile(_client);
        end;
        if source == config_audio_musicvol then
            if not _client then
                _client = xmlLoadFile("config/_client.xml") or xmlCreateFile("config/_client.xml", "config");
            end;
            local serverBlurMusicNode = xmlFindChild(_client, "audio", 0) or xmlCreateChild(_client, "audio");
            local serverBlurMusicVolume = guiScrollBarGetScrollPosition(config_audio_musicvol);
            xmlNodeSetAttribute(serverBlurMusicNode, "musicvol", tostring(serverBlurMusicVolume));
            xmlSaveFile(_client);
        end;
    end;
    onClientGUIComboBoxAccepted = function(__) 
        if source == config_gameplay_language then
            local serverSelectedLanguagePath = config_gameplay_languagelist[guiGetText(config_gameplay_language)];
            loadedLanguage = {};
            local serverLanguageXMLFile = xmlLoadFile(serverSelectedLanguagePath);
            outputChatBox("v2539: " .. inspect(serverLanguageXMLFile))
            if serverLanguageXMLFile then
                local serverLanguageDisplayName = xmlNodeGetAttribute(serverLanguageXMLFile, "name") or "";
                local serverLanguageAuthor = xmlNodeGetAttribute(serverLanguageXMLFile, "author") or "";
                outputChatBox(serverLanguageDisplayName .. " (" .. serverLanguageAuthor .. ")", 255, 100, 100, true);
                for __, serverLanguageEntry in ipairs(xmlNodeGetChildren(serverLanguageXMLFile)) do
                    loadedLanguage[xmlNodeGetName(serverLanguageEntry)] = xmlNodeGetAttribute(serverLanguageEntry, "string");
                end;
                xmlUnloadFile(serverLanguageXMLFile);
                local serverGameplayConfigNode = xmlFindChild(_client, "gameplay", 0) or xmlCreateChild(_client, "gameplay");
                xmlNodeSetAttribute(serverGameplayConfigNode, "language", serverSelectedLanguagePath);
                xmlSaveFile(_client);
                triggerEvent("onClientLanguageChange", localPlayer, serverSelectedLanguagePath);
            end;
        end;
        if source == config_gameplay_nitrocontrol then
            local serverNitroControlValue = ({
                Toggle = "toggle", 
                Hold = "hold"
            })[guiGetText(config_gameplay_nitrocontrol)];
            local serverNitroConfigNode = xmlFindChild(_client, "gameplay", 0) or xmlCreateChild(_client, "gameplay");
            xmlNodeSetAttribute(serverNitroConfigNode, "nitrocontrol", serverNitroControlValue);
            xmlSaveFile(_client);
        end;
    end;
    togglePlayerConfig = function(__, serverPageToOpen) 
        if guiGetInputEnabled() then
            return;
        else
            if guiGetVisible(config_window) then
                guiSetVisible(config_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            else
                if serverPageToOpen then
                    for serverPageRow = 0, guiGridListGetRowCount(config_pagelist) do
                        if guiGridListGetItemText(config_pagelist, serverPageRow, 1) == serverPageToOpen then
                            guiGridListSetSelectedItem(config_pagelist, serverPageRow, 1);
                            triggerEvent("onClientGUIClick", config_pagelist, "left", "up");
                            break;
                        end;
                    end;
                end;
                guiBringToFront(config_window);
                guiSetVisible(config_window, true);
                showCursor(true);
                if not isTimer(updPerformance) then
                    updPerformance = setTimer(checkPerformance, 500, 0);
                end;
            end;
            return;
        end;
    end;
    onClientValuesHUDRender = function() 
        local serverHealthText = tostring(math.ceil(getElementHealth(localPlayer)));
        if guiGetText(hud_health) ~= serverHealthText then
            guiSetText(hud_health, serverHealthText);
        end;
        local serverArmorValue = getPedArmor(localPlayer);
        if serverArmorValue > 0 then
            if not guiGetVisible(hud_armor) then
                guiSetVisible(hud_armor, true);
            end;
            serverArmorValue = tostring(math.ceil(serverArmorValue));
            if guiGetText(hud_armor) ~= serverArmorValue then
                guiSetText(hud_armor, serverArmorValue);
            end;
        elseif guiGetVisible(hud_armor) then
            guiSetVisible(hud_armor, false);
        end;
    end;
    onClientValuesHUDElementDataChange = function(serverStatusDataName, serverOldStatus) 
        if serverStatusDataName ~= "Status" then
            return;
        else
            if serverOldStatus == "Play" then
                removeEventHandler("onClientRender", root, onClientValuesHUDRender);
                guiSetVisible(values_hud, false);
            elseif getElementData(source, serverStatusDataName) == "Play" then
                addEventHandler("onClientRender", root, onClientValuesHUDRender);
                guiSetVisible(values_hud, true);
            end;
            return;
        end;
    end;
    onDownloadComplete = function() 
        guiSetAlpha(infowindow, guiCheckBoxGetSelected(config_performance_helpinfo) and 1 or 0);
        guiSetAlpha(speclist, guiCheckBoxGetSelected(config_performance_spec) and 0.5 or 0);
        for __, serverRoundComponent in pairs(components) do
            guiSetAlpha(serverRoundComponent.root, guiCheckBoxGetSelected(config_performance_roundhud) and 1 or 0);
        end;
        guiSetAlpha(values_hud, guiCheckBoxGetSelected(config_performance_valueshud) and 1 or 0);
    end;
    onClientElementDataChange = function(v2556, v2557) 
        if v2556 == "FPS" then
            table.insert(fpsdata, 1, {
                getElementData(localPlayer, "FPS"), 
                getTickCount()
            });
        end;
        if v2556 == "PLoss" then
            table.insert(plossdata, 1, {
                getElementData(localPlayer, "PLoss"), 
                getTickCount()
            });
        end;
        if v2556 == "Status" then
            if v2557 == "Joining" then
                if guiCheckBoxGetSelected(config_performance_fps) then
                    addEventHandler("onClientRender", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, true);
                end;
                if guiCheckBoxGetSelected(config_performance_ploss) then
                    addEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, true);
                end;
            elseif getElementData(localPlayer, "Status") == "Joining" then
                if guiCheckBoxGetSelected(config_performance_fps) then
                    removeEventHandler("onClientRender", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, false);
                end;
                if guiCheckBoxGetSelected(config_performance_ploss) then
                    removeEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, false);
                end;
            end;
        end;
    end;
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
    addEventHandler("onClientGUIClick", root, onClientGUIClick);
    addEventHandler("onClientGUIScroll", root, onClientGUIScroll);
    addEventHandler("onClientGUIBlur", root, onClientGUIBlur);
    addEventHandler("onClientGUIComboBoxAccepted", root, onClientGUIComboBoxAccepted);
    addEventHandler("onClientRender", root, onClientFPSCount);
    addEventHandler("onDownloadComplete", root, onDownloadComplete);
    addEventHandler("onClientElementDataChange", localPlayer, onClientElementDataChange);
    setTimer(updateLimites, 1000, 0);
    addCommandHandler("player_config", togglePlayerConfig, false);
end)();
(function(...) 
    local serverStatColumns = {
        {"Damage", 1}, 
        {"Kills", 1}, 
        {"Deaths", -1}
    };
    local serverLeftImageFile = nil;
    local serverRightImageFile = nil;
    onClientResourceStart = function(__) 
        statistic_window = guiCreateWindow(xscreen * 0.5 - 320, yscreen * 0.5 - 240, 640, 480, "Round statistic", false);
        guiWindowSetSizable(statistic_window, false);
        guiSetVisible(statistic_window, false);
        roundScores = guiCreateLabel(10, 25, 620, 35, "", false, statistic_window);
        guiSetFont(roundScores, fontTactics);
        guiLabelSetHorizontalAlign(roundScores, "center");
        guiSetEnabled(roundScores, false);
        leftImage = guiCreateStaticImage(10, 25, 55, 55, "images/color_pixel.png", false, statistic_window);
        guiSetVisible(leftImage, false);
        guiSetEnabled(leftImage, false);
        rightImage = guiCreateStaticImage(575, 25, 55, 55, "images/color_pixel.png", false, statistic_window);
        guiSetVisible(rightImage, false);
        guiSetEnabled(rightImage, false);
        leftTeam = guiCreateLabel(10, 25, 310, 35, "", false, statistic_window);
        guiSetFont(leftTeam, fontTactics);
        guiSetEnabled(leftTeam, false);
        rightTeam = guiCreateLabel(320, 25, 310, 35, "", false, statistic_window);
        guiSetFont(rightTeam, fontTactics);
        guiLabelSetHorizontalAlign(rightTeam, "right");
        guiSetEnabled(rightTeam, false);
        leftSide = guiCreateLabel(10, 60, 300, 20, "", false, statistic_window);
        guiLabelSetHorizontalAlign(leftSide, "right");
        guiSetEnabled(leftSide, false);
        rightSide = guiCreateLabel(330, 60, 300, 20, "", false, statistic_window);
        guiSetEnabled(rightSide, false);
        statistic_players = guiCreateGridList(5, 80, 630, 365, false, statistic_window);
        guiGridListSetSortingEnabled(statistic_players, false);
        guiGridListAddColumn(statistic_players, "Name", 0.3);
        statistic_log = guiCreateMemo(5, 80, 630, 365, "", false, statistic_window);
        guiMemoSetReadOnly(statistic_log, true);
        guiSetVisible(statistic_log, false);
        local serverPlayersTabWidth = 30 + dxGetTextWidth("Players", 1, "default-bold");
        statistic_tabplayersbg = guiCreateStaticImage(15, 445, serverPlayersTabWidth, 32, "images/color_pixel.png", false, statistic_window);
        guiSetProperty(statistic_tabplayersbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        statistic_tabplayers = guiCreateButton(0, -8, serverPlayersTabWidth, 32, "Players", false, statistic_tabplayersbg);
        guiSetFont(statistic_tabplayers, "default-bold-small");
        guiSetProperty(statistic_tabplayers, "NormalTextColour", "FFFFFFFF");
        local serverLogTabWidth = 30 + dxGetTextWidth("Log", 1, "default-bold");
        statistic_tablogbg = guiCreateStaticImage(14 + serverPlayersTabWidth, 445, serverLogTabWidth, 32, "images/color_pixel.png", false, statistic_window);
        guiSetProperty(statistic_tablogbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        statistic_tablog = guiCreateButton(0, -8, serverLogTabWidth, 32, "Log", false, statistic_tablogbg);
        guiSetFont(statistic_tablog, "default-bold-small");
        statistic_copy = guiCreateButton(390, 450, 170, 25, "Copy to clipboard", false, statistic_window);
        guiSetFont(statistic_copy, "default-bold-small");
        statistic_close = guiCreateButton(565, 450, 120, 25, "Close", false, statistic_window);
        guiSetFont(statistic_close, "default-bold-small");
    end;
    updateRoundStatistic = function(serverRoundName, serverTeamResults, serverRoundLog, serverShowHelp) 
        if not serverStatColumns or #serverStatColumns == 0 then
            return;
        else
            if #serverTeamResults > 2 then
                table.sort(serverTeamResults, function(serverTeamResultA, serverTeamResultB) 
                    return serverTeamResultA.score > serverTeamResultB.score;
                end);
            end;
            guiSetText(statistic_window, "Round statistic - " .. serverRoundName);
            guiSetPosition(statistic_players, 5, 80, false);
            guiSetSize(statistic_players, 630, 365, false);
            guiSetText(roundScores, " : ");
            for serverResultIndex = 1, math.min(#serverTeamResults, 2) do
                local serverTeamResult = serverTeamResults[serverResultIndex];
                if serverResultIndex == 1 then
                    if serverTeamResult.image then
                        serverLeftImageFile = fileCreate("images/_leftimagefile.jpg");
                    end;
                    if serverTeamResult.image and serverLeftImageFile then
                        fileWrite(serverLeftImageFile, serverTeamResult.image);
                        fileClose(serverLeftImageFile);
                        guiStaticImageLoadImage(leftImage, "images/_leftimagefile.jpg");
                        guiSetVisible(leftImage, true);
                        guiSetVisible(leftTeam, false);
                    else
                        guiSetText(leftTeam, serverTeamResult.name);
                        guiSetVisible(leftImage, false);
                        guiSetVisible(leftTeam, true);
                    end;
                    guiLabelSetColor(leftTeam, serverTeamResult.r, serverTeamResult.g, serverTeamResult.b);
                    guiSetText(leftSide, serverTeamResult.side);
                    guiSetText(roundScores, serverTeamResult.score .. guiGetText(roundScores));
                else
                    if serverTeamResult.image then
                        serverRightImageFile = fileCreate("images/_rightimagefile.jpg");
                    end;
                    if serverTeamResult.image and serverRightImageFile then
                        fileWrite(serverRightImageFile, serverTeamResult.image);
                        fileClose(serverRightImageFile);
                        guiStaticImageLoadImage(rightImage, "images/_rightimagefile.jpg");
                        guiSetVisible(rightImage, true);
                        guiSetVisible(rightTeam, false);
                    else
                        guiSetText(rightTeam, serverTeamResult.name);
                        guiSetVisible(rightImage, false);
                        guiSetVisible(rightTeam, true);
                    end;
                    guiLabelSetColor(rightTeam, serverTeamResult.r, serverTeamResult.g, serverTeamResult.b);
                    guiSetText(rightSide, serverTeamResult.side);
                    guiSetText(roundScores, guiGetText(roundScores) .. serverTeamResult.score);
                end;
            end;
            guiGridListClear(statistic_players);
            for __ = 2, guiGridListGetColumnCount(statistic_players) do
                guiGridListRemoveColumn(statistic_players, 2);
            end;
            for __, serverStatColumn in ipairs(serverStatColumns) do
                guiGridListAddColumn(statistic_players, serverStatColumn[1], 0.65 / #serverStatColumns);
            end;
            for __, serverTeamResultEntry in ipairs(serverTeamResults) do
                local serverGridRow = guiGridListAddRow(statistic_players);
                guiGridListSetItemText(statistic_players, serverGridRow, 1, serverTeamResultEntry.name .. " - " .. serverTeamResultEntry.score, true, false);
                guiGridListSetItemColor(statistic_players, serverGridRow, 1, serverTeamResultEntry.r, serverTeamResultEntry.g, serverTeamResultEntry.b);
                for serverColumnIndex, serverColumnInfo in ipairs(serverStatColumns) do
                    if serverTeamResultEntry[serverColumnInfo] then
                        guiGridListSetItemColor(statistic_players, serverGridRow, serverColumnIndex + 1, tostring(serverTeamResultEntry[serverColumnInfo]), true, false);
                    end;
                end;
                table.sort(serverTeamResultEntry.players, function(serverPlayerStatA, serverPlayerStatB) 
                    for __, serverSortColumn in ipairs(serverStatColumns) do
                        if tonumber(serverPlayerStatA[serverSortColumn[1]]) > tonumber(serverPlayerStatB[serverSortColumn[1]]) then
                            return serverSortColumn[2] > 0;
                        elseif tonumber(serverPlayerStatA[serverSortColumn[1]]) < tonumber(serverPlayerStatB[serverSortColumn[1]]) then
                            return serverSortColumn[2] < 0;
                        end;
                    end;
                    return false;
                end);
                for __, serverPlayerStat in ipairs(serverTeamResultEntry.players) do
                    serverGridRow = guiGridListAddRow(statistic_players);
                    guiGridListSetItemText(statistic_players, serverGridRow, 1, serverPlayerStat.name, false, false);
                    guiGridListSetItemColor(statistic_players, serverGridRow, 1, serverTeamResultEntry.r, serverTeamResultEntry.g, serverTeamResultEntry.b);
                    for serverPlayerColumnIndex, serverPlayerColumnInfo in ipairs(serverStatColumns) do
                        guiGridListSetItemText(statistic_players, serverGridRow, serverPlayerColumnIndex + 1, serverPlayerStat[serverPlayerColumnInfo[1]] and tostring(serverPlayerStat[serverPlayerColumnInfo[1]]) or "", false, false);
                    end;
                end;
            end;
            guiSetText(statistic_log, serverRoundLog or "");
            if serverShowHelp then
                return;
            else
                outputInfo(string.format(getLanguageString("help_roundlog"), string.upper(next(getBoundKeys("round_stat")))));
                return;
            end;
        end;
    end;
    toggleRoundStatistic = function() 
        if not guiGetVisible(statistic_window) then
            guiSetVisible(statistic_window, true);
            showCursor(true);
        else
            guiSetVisible(statistic_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
        end;
    end;
    onClientGUIClick = function(serverStatMouseButton, __, __, __) 
        if serverStatMouseButton ~= "left" then
            return;
        else
            if source == statistic_close then
                guiSetVisible(statistic_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if source == statistic_copy then
                local serverColumnPadding = 4;
                local serverClipboardText = guiGetText(statistic_window) .. "\n\n";
                for __, serverColumnEntry in ipairs(serverStatColumns) do
                    serverColumnPadding = math.max(serverColumnPadding, #tostring(serverColumnEntry[1]));
                end;
                for serverClipboardRow = 0, guiGridListGetRowCount(statistic_players) do
                    for serverClipboardColumn = 1, #serverStatColumns + 1 do
                        local serverCellText = guiGridListGetItemText(statistic_players, serverClipboardRow, serverClipboardColumn);
                        serverColumnPadding = math.max(serverColumnPadding, #tostring(serverCellText));
                    end;
                end;
                serverColumnPadding = serverColumnPadding + 3;
                serverClipboardText = serverClipboardText .. "Name" .. string.rep(" ", serverColumnPadding - 4);
                for __, serverClipboardColumnEntry in ipairs(serverStatColumns) do
                    local serverColumnTitle = serverClipboardColumnEntry[1];
                    serverClipboardText = serverClipboardText .. serverColumnTitle .. string.rep(" ", serverColumnPadding - #serverColumnTitle);
                end;
                serverClipboardText = serverClipboardText .. "\n";
                for serverExportRow = 0, guiGridListGetRowCount(statistic_players) do
                    for serverExportColumn = 1, #serverStatColumns + 1 do
                        local serverExportCell = guiGridListGetItemText(statistic_players, serverExportRow, serverExportColumn);
                        serverClipboardText = serverClipboardText .. serverExportCell .. string.rep(" ", serverColumnPadding - #serverExportCell);
                    end;
                    serverClipboardText = serverClipboardText .. "\n";
                end;
                serverClipboardText = serverClipboardText .. "\n" .. guiGetText(statistic_log);
                setClipboard(serverClipboardText);
            end;
            if source == statistic_tabplayers then
                guiSetVisible(statistic_players, true);
                guiSetVisible(statistic_log, false);
                guiSetProperty(statistic_tabplayers, "NormalTextColour", "FFFFFFFF");
                guiSetProperty(statistic_tablog, "NormalTextColour", "FF7C7C7C");
            end;
            if source == statistic_tablog then
                guiSetVisible(statistic_players, false);
                guiSetVisible(statistic_log, true);
                guiSetProperty(statistic_tabplayers, "NormalTextColour", "FF7C7C7C");
                guiSetProperty(statistic_tablog, "NormalTextColour", "FFFFFFFF");
            end;
            return;
        end;
    end;
    onClientStatisticChange = function(...) 
        serverStatColumns = {};
        for __, serverStatChangeArg in ipairs({
            ...
        }) do
            if type(serverStatChangeArg) == "string" then
                table.insert(serverStatColumns, {
                    tostring(serverStatChangeArg)
                });
            elseif #serverStatColumns > 0 then
                serverStatColumns[#serverStatColumns][2] = serverStatChangeArg;
            end;
        end;
    end;
    addEvent("onClientStatisticChange", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientGUIClick", root, onClientGUIClick);
    addEventHandler("onClientStatisticChange", root, onClientStatisticChange);
    addCommandHandler("round_stat", toggleRoundStatistic, false);
    bindKey("F5", "down", "round_stat");
end)();
