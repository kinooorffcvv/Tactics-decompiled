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
                        for v15 = #tableTactics - 1, 2, -1 do
                            rcv2[v15 - 1][tableTactics[v15]] = rcv2[v15];
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
            addEventHandler("onSetTacticsData", root, function(v16, ...)
                setTacticsData(v16, ...);
            end);
        end;
    else
        local v17 = getElementByID("Tactics");
        do
            local l_v17_0 = v17;
            initTacticsData = function()
                local v19 = {};
                local function v20(v21, v22, v23)
                    for v24, v25 in pairs(v21) do
                        v19[v23] = v24;
                        if type(v25) == "table" and #v25 == 0 and type(next(v25)) == "string" then
                            v20(v25, v22[v24] or {}, v23 + 1);
                            v19[v23 + 1] = nil;
                        elseif type(v22[v24]) == "table" or v25 ~= v22[v24] then
                            triggerEvent("onClientTacticsChange", l_v17_0, v19, v22[v24]);
                        end;
                        v22[v24] = nil;
                    end;
                    for v26, v27 in pairs(v22) do
                        v19[v23] = v26;
                        if type(v21[v26]) == "table" and #v21[v26] == 0 and type(next(v21[v26])) == "string" then
                            v20(v21[v26], v27 or {}, v23 + 1);
                            v19[v23 + 1] = nil;
                        elseif type(v27) == "table" or v21[v26] ~= v27 then
                            triggerEvent("onClientTacticsChange", l_v17_0, v19, v27);
                        end;
                    end;
                end;
                for __, v29 in ipairs(getAllTacticsData()) do
                    local v30 = getElementData(l_v17_0, v29);
                    v19[1] = v29;
                    if type(v30) == "table" and #v30 == 0 and type(next(v30)) == "string" then
                        v20(v30, {}, 2);
                        v19[2] = nil;
                    else
                        triggerEvent("onClientTacticsChange", l_v17_0, v19, nil);
                    end;
                end;
            end;
            addEvent("onDownloadComplete");
            addEventHandler("onDownloadComplete", root, initTacticsData);
            local function v43(v31, v32) --[[ Line: 142 ]]
                local v33 = {};
                local function v34(v35, v36, v37) --[[ Line: 144 ]]
                    -- upvalues: v33 (ref), v34 (ref)
                    for v38, v39 in pairs(v35) do
                        v33[v37] = v38;
                        if type(v39) == "table" and #v39 == 0 and type(next(v39)) == "string" then
                            v34(v39, v36[v38] or {}, v37 + 1);
                            v33[v37 + 1] = nil;
                        elseif type(v36[v38]) == "table" or v39 ~= v36[v38] then
                            triggerEvent("onClientTacticsChange", source, v33, v36[v38]);
                        end;
                        v36[v38] = nil;
                    end;
                    for v40, v41 in pairs(v36) do
                        v33[v37] = v40;
                        if type(v35[v40]) == "table" and #v35[v40] == 0 and type(next(v35[v40])) == "string" then
                            v34(v35[v40], v41 or {}, v37 + 1);
                            v33[v37 + 1] = nil;
                        elseif type(v41) == "table" or v35[v40] ~= v41 then
                            triggerEvent("onClientTacticsChange", source, v33, v41);
                        end;
                    end;
                end;
                local v42 = getElementData(source, v31);
                v33[1] = v31;
                if type(v42) == "table" and #v42 == 0 and type(next(v42)) == "string" then
                    v34(v42, v32 or {}, 2);
                    v33[2] = nil;
                else
                    triggerEvent("onClientTacticsChange", source, v33, v32);
                end;
            end;
            addEvent("onClientTacticsChange");
            addEventHandler("onClientElementDataChange", l_v17_0, v43);
            getAllTacticsData = function() --[[ Line: 176 ]]
                -- upvalues: l_v17_0 (ref)
                return getElementData(l_v17_0, "AllData") or {};
            end;
            getTacticsData = function(...) --[[ Line: 179 ]]
                -- upvalues: l_v17_0 (ref)
                local v44 = true;
                local v45 = {...};
                if type(v45[#v45]) == "boolean" then
                    v44 = table.remove(v45);
                end;
                if #v45 == 1 then
                    local v46 = getElementData(l_v17_0, v45[1]);
                    if v44 and type(v46) == "string" and string.find(v46, "|") then
                        return gettok(v46, 1, string.byte("|")), split(gettok(v46, 2, string.byte("|")), ",");
                    else
                        return v46;
                    end;
                elseif #v45 > 1 then
                    local v47 = nil;
                    for v48, v49 in ipairs(v45) do
                        if v48 == 1 then
                            v47 = getElementData(l_v17_0, v49);
                        else
                            v47 = v47[v49];
                        end;
                        if not v47 then
                            return nil;
                        end;
                    end;
                    if v44 and type(v47) == "string" and string.find(v47, "|") then
                        return gettok(v47, 1, string.byte("|")), split(gettok(v47, 2, string.byte("|")), ",");
                    else
                        return v47;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(v50) --[[ Line: 208 ]]
                if type(v50) == "string" then
                    if string.find(v50, "|") then
                        return "parameter";
                    elseif string.find(v50, ":") then
                        return "time";
                    elseif v50 == "true" or v50 == "false" then
                        return "toggle";
                    end;
                end;
                return type(v50);
            end;
            setTacticsData = function(v51, ...) --[[ Line: 216 ]]
                -- upvalues: l_v17_0 (ref)
                triggerServerEvent("onSetTacticsData", resourceRoot, v51, ...);
            end;
        end;
    end;
    if triggerServerEvent ~= nil then
        local v52, v53 = guiGetScreenSize();
        yscreen = v53;
        xscreen = v52;
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
        setCameraPrepair = function(v54, v55, v56, v57) --[[ Line: 233 ]]
            if not v55 or not v56 or not v57 then
                local v58 = getElementsByType("Central_Marker")[1];
                if isElement(v58) then
                    local v59, v60, v61 = getElementPosition(v58);
                    v57 = v61;
                    v56 = v60;
                    v55 = v59;
                else
                    local v62, v63, v64 = getElementPosition(localPlayer);
                    v57 = v64;
                    v56 = v63;
                    v55 = v62;
                end;
            end;
            if not v54 then
                v54 = 70;
            end;
            setCameraMatrix(v55, v56, v57, v55, v56, v57 + v54);
            setElementData(localPlayer, "Prepair", {v55, v56, v57, v54}, false);
            return true;
        end;
        stopCameraPrepair = function() --[[ Line: 247 ]]
            if setElementData(localPlayer, "Prepair", nil, false) then
                setCameraTarget(localPlayer);
            end;
        end;
        getFont = function(v65) --[[ Line: 252 ]]
            return tonumber(0.015 * v65 * yscreen / 9);
        end;
        getPlayerLanguage = function() --[[ Line: 255 ]]
            if not isElement(config_gameplay_language) then
                return "language/english.lng";
            else
                local v66 = guiGetText(config_gameplay_language);
                return v66 and config_gameplay_languagelist[v66] or "language/english.lng";
            end;
        end;
        setPlayerLanguage = function(v67) --[[ Line: 260 ]]
            if config_gameplay_languagelist[guiGetText(config_gameplay_language)] == v67 then
                return false;
            else
                local v68 = xmlLoadFile(v67);
                if v68 then
                    loadedLanguage = {};
                    local v69 = xmlNodeGetAttribute(v68, "name") or "";
                    local v70 = xmlNodeGetAttribute(v68, "author") or "";
                    outputChatBox(v69 .. " (" .. v70 .. ")", 255, 100, 100, true);
                    for __, v72 in ipairs(xmlNodeGetChildren(v68)) do
                        loadedLanguage[xmlNodeGetName(v72)] = xmlNodeGetAttribute(v72, "string");
                    end;
                    xmlUnloadFile(v68);
                    local v73 = xmlFindChild(_client, "gameplay", 0);
                    xmlNodeSetAttribute(v73, "language", v67);
                    xmlSaveFile(_client);
                    if not config_gameplay_languagelist[v67] then
                        config_gameplay_languagelist[v67] = v69;
                    end;
                    if not config_gameplay_languagelist[v69] then
                        config_gameplay_languagelist[v69] = v67;
                    end;
                    guiSetText(config_gameplay_language, v69);
                    triggerEvent("onClientLanguageChange", localPlayer, v67);
                    return true;
                else
                    return false;
                end;
            end;
        end;
        getLanguageString = function(v74) --[[ Line: 283 ]]
            if type(loadedLanguage) ~= "table" then
                loadedLanguage = {};
                local v75 = getPlayerLanguage();
                local v76 = xmlLoadFile(v75);
                if v76 then
                    for __, v78 in ipairs(xmlNodeGetChildren(v76)) do
                        loadedLanguage[xmlNodeGetName(v78)] = xmlNodeGetAttribute(v78, "string");
                    end;
                    xmlUnloadFile(v76);
                end;
            end;
            return loadedLanguage[tostring(v74)] or "";
        end;
        outputLangString = function(v79, ...) --[[ Line: 297 ]]
            local v80 = {...};
            if #v80 > 0 then
                outputChatBox(string.format(getLanguageString(tostring(v79)), unpack(v80)), 255, 100, 100, true);
            else
                outputChatBox(getLanguageString(tostring(v79)), 255, 100, 100, true);
            end;
        end;
        isAllGuiHidden = function() --[[ Line: 305 ]]
            if getElementData(localPlayer, "Status") == "Joining" then
                return false;
            else
                for __, v82 in ipairs(getElementsByType("gui-window", resourceRoot)) do
                    if guiGetVisible(v82) and v82 ~= voting_window then
                        return false;
                    end;
                end;
                return true;
            end;
        end;
        isRoundPaused = function() --[[ Line: 312 ]]
            if getTacticsData("Pause") then
                local v83 = getTacticsData("Unpause");
                if v83 then
                    return true, v83 - (getTickCount() + addTickCount);
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        voiceThread = {};
        playVoice = function(v84, v85, v86, v87) --[[ Line: 324 ]]
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(voiceThread[v84]) then
                return voiceThread[v84];
            else
                voiceThread[v84] = playSound(v84, v85 or false);
                if not v86 then
                    v86 = 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol);
                else
                    v86 = math.min(v86, 0.01 * guiScrollBarGetScrollPosition(config_audio_voicevol));
                end;
                setSoundVolume(voiceThread[v84], v86);
                setSoundSpeed(voiceThread[v84], v87 or 1);
                return voiceThread[v84];
            end;
        end;
        musicThread = {};
        playMusic = function(v88, v89, v90) --[[ Line: 334 ]]
            if not guiCheckBoxGetSelected(config_audio_voice) then
                return false;
            elseif isElement(musicThread[v88]) then
                return musicThread[v88];
            else
                musicThread[v88] = playSound(v88, v89 or false);
                if not v90 then
                    v90 = 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol);
                else
                    v90 = math.min(v90, 0.01 * guiScrollBarGetScrollPosition(config_audio_musicvol));
                end;
                setSoundVolume(musicThread[v88], not v90 and 1 or v90);
                setSoundSpeed(musicThread[v88], speed or 1);
                return musicThread[v88];
            end;
        end;
        getAngleBetweenPoints2D = function(v91, v92, v93, v94) --[[ Line: 343 ]]
            local v95 = 0 - math.deg(math.atan2(v93 - v91, v94 - v92));
            if v95 < 0 then
                v95 = v95 + 360;
            end;
            return v95;
        end;
        getAngleBetweenAngles2D = function(v96, v97) --[[ Line: 348 ]]
            local v98;
            if v96 < v97 then
                if v96 < v97 - 180 then
                    v98 = v96 - (v97 - 360);
                else
                    v98 = v96 - v97;
                end;
            elseif v97 + 180 < v96 then
                v98 = v96 - (v97 + 360);
            else
                v98 = v96 - v97;
            end;
            return v98;
        end;
        replaceCustom = {};
        loadCustomObject = function(v99, v100, v101) --[[ Line: 366 ]]
            local v102 = {model = v99};
            local v103 = false;
            if v100 then
                v102.txd = engineLoadTXD(v100);
                v103 = engineImportTXD(v102.txd, v99);
            end;
            if v101 then
                v102.dff = engineLoadDFF(v101, v99);
                v103 = engineReplaceModel(v102.dff, v99);
            end;
            if v103 then
                table.insert(replaceCustom, v102);
            end;
            return v103;
        end;
        addEventHandler("onClientMapStopping", root, function() --[[ Line: 380 ]]
            for __, v105 in ipairs(replaceCustom) do
                if v105.txd and isElement(v105.txd) then
                    destroyElement(v105.txd);
                end;
                if v105.dff and isElement(v105.dff) then
                    destroyElement(v105.dff);
                    engineRestoreModel(v105.model);
                end;
            end;
            replaceCustom = {};
        end);
        getElementVector = function(v106, v107, v108, v109, v110) --[[ Line: 392 ]]
            if not isElement(v106) then
                return false;
            else
                local v111 = getElementMatrix(v106);
                local v112 = {};
                if not v110 then
                    v112[1] = v107 * v111[1][1] + v108 * v111[2][1] + v109 * v111[3][1] + v111[4][1];
                    v112[2] = v107 * v111[1][2] + v108 * v111[2][2] + v109 * v111[3][2] + v111[4][2];
                    v112[3] = v107 * v111[1][3] + v108 * v111[2][3] + v109 * v111[3][3] + v111[4][3];
                else
                    v112[1] = v107 * v111[1][1] + v108 * v111[2][1] + v109 * v111[3][1];
                    v112[2] = v107 * v111[1][2] + v108 * v111[2][2] + v109 * v111[3][2];
                    v112[3] = v107 * v111[1][3] + v108 * v111[2][3] + v109 * v111[3][3];
                end;
                return v112;
            end;
        end;
        callServerFunction = function(v113, ...) --[[ Line: 407 ]]
            local v114 = {...};
            if v114[1] then
                for v115, v116 in next, v114 do
                    if type(v116) == "number" then
                        v114[v115] = tostring(v116);
                    end;
                end;
            end;
            triggerServerEvent("onClientCallsServerFunction", resourceRoot, v113, unpack(v114));
        end;
        callClientFunction = function(v117, ...) --[[ Line: 416 ]]
            local v118 = {...};
            if v118[1] then
                for v119, v120 in next, v118 do
                    v118[v119] = tonumber(v120) or v120;
                end;
            end;
            loadstring("return " .. v117)()(unpack(v118));
        end;
        addEvent("onServerCallsClientFunction", true);
        addEventHandler("onServerCallsClientFunction", root, callClientFunction);
        addEvent("onClientLanguageChange");
        addEvent("onOutputLangString", true);
        addEventHandler("onOutputLangString", root, outputLangString);
    else
        outputLangString = function(v121, v122, ...) --[[ Line: 429 ]]
            triggerClientEvent(v121, "onOutputLangString", root, v122, ...);
        end;
        getString = function(v123) --[[ Line: 440 ]]
            if not serverLanguage then
                serverLanguage = {};
                local v124 = xmlLoadFile("language/english.lng");
                if v124 then
                    for __, v126 in ipairs(xmlNodeGetChildren(v124)) do
                        serverLanguage[xmlNodeGetName(v126)] = xmlNodeGetAttribute(v126, "string");
                    end;
                end;
            end;
            return serverLanguage[tostring(v123)] or "";
        end;
        setCameraPrepair = function(v127, v128, v129, v130, v131) --[[ Line: 452 ]]
            if not v129 or not v130 or not v131 then
                local v132 = getElementsByType("Central_Marker")[1];
                if isElement(v132) then
                    local v133, v134, v135 = getElementPosition(v132);
                    v131 = v135;
                    v130 = v134;
                    v129 = v133;
                else
                    local v136, v137, v138 = getElementPosition(v127);
                    v131 = v138;
                    v130 = v137;
                    v129 = v136;
                end;
            end;
            if not v128 then
                v128 = 70;
            end;
            setCameraMatrix(v127, v129, v130, v131, v129, v130, v131 + v128);
            setElementData(v127, "Prepair", {v129, v130, v131, v128});
        end;
        stopCameraPrepair = function(v139) --[[ Line: 465 ]]
            if setElementData(v139, "Prepair", nil) then
                setCameraTarget(v139, v139);
            end;
        end;
        setCameraSpectating = function(v140, ...) --[[ Line: 470 ]]
            if v140 and isElement(v140) then
                callClientFunction(v140, "setCameraSpectating", ...);
                return true;
            else
                return false;
            end;
        end;
        isRoundPaused = function() --[[ Line: 477 ]]
            if getTacticsData("Pause") then
                local v141 = getTacticsData("Unpause");
                if v141 then
                    return true, v141 - getTickCount();
                else
                    return true;
                end;
            else
                return false;
            end;
        end;
        createMapVehicle = function(v142, v143, v144, v145, v146, v147, v148) --[[ Line: 488 ]]
            local v149 = createVehicle(v142, v143, v144, v145, v146, v147, v148);
            setElementParent(v149, getRoundMapDynamicRoot());
            return v149;
        end;
        callClientFunction = function(v150, v151, ...) --[[ Line: 493 ]]
            local v152 = {...};
            if v152[1] then
                for v153, v154 in next, v152 do
                    if type(v154) == "number" then
                        v152[v153] = tostring(v154);
                    end;
                end;
            end;
            triggerClientEvent(v150, "onServerCallsClientFunction", root, v151, unpack(v152 or {}));
        end;
        callServerFunction = function(v155, ...) --[[ Line: 502 ]]
            local v156 = {...};
            if v156[1] then
                for v157, v158 in next, v156 do
                    v156[v157] = tonumber(v158) or v158;
                end;
            end;
            loadstring("return " .. v155)()(unpack(v156));
        end;
        addEvent("onClientCallsServerFunction", true);
        addEventHandler("onClientCallsServerFunction", root, callServerFunction);
    end;
    getRoundMapRoot = function(v159) --[[ Line: 512 ]]
        if v159 then
            return getResourceRootElement(v159);
        else
            local v160 = getResourceFromName(getTacticsData("MapResName"));
            if v160 then
                return getResourceRootElement(v160);
            else
                return root;
            end;
        end;
    end;
    getRoundMapDynamicRoot = function(v161) --[[ Line: 521 ]]
        if v161 then
            return getResourceDynamicElementRoot(v161);
        else
            local v162 = getResourceFromName(getTacticsData("MapResName"));
            if v162 then
                return getResourceDynamicElementRoot(v162);
            else
                return root;
            end;
        end;
    end;
    removeColorCoding = function(v163) --[[ Line: 530 ]]
        return type(v163) == "string" and string.gsub(v163, "#%x%x%x%x%x%x", "") or v163;
    end;
    TimeToSec = function(v164) --[[ Line: 533 ]]
        if not string.find(tostring(v164), ":") then
            return false;
        else
            local v165 = split(tostring(v164), string.byte(":"));
            local v166 = tonumber(v165[#v165 - 2]) or 0;
            local v167 = tonumber(v165[#v165 - 1]) or 0;
            local v168 = tonumber(v165[#v165]);
            return 3600 * v166 + 60 * v167 + v168;
        end;
    end;
    MSecToTime = function(v169, v170) --[[ Line: 541 ]]
        if type(v169) ~= "number" then
            return false;
        else
            if type(v170) ~= "number" then
                v170 = 1;
            end;
            local v171 = math.floor(v169 / 3600000) or 0;
            local v172 = math.floor(v169 / 60000) - v171 * 60 or 0;
            local v173 = math.floor(v169 / 1000) - v172 * 60 - v171 * 3600 or 0;
            local v174 = v169 - v173 * 1000 - v172 * 60000 - v171 * 3600000 or 0;
            local v175 = string.format("%02i", v173);
            if v171 > 0 then
                v175 = string.format("%i:%02i:", v171, v172) .. v175;
            else
                v175 = string.format("%i:", v172) .. v175;
            end;
            if v170 > 0 then
                local v176 = string.sub(string.format("%." .. v170 .. "f", 0.001 * v174), 2);
                if #v176 - 1 < v170 then
                    v176 = v176 .. string.rep("0", v170 - (#v176 - 1));
                end;
                v175 = v175 .. v176;
            end;
            return v175;
        end;
    end;
    string.count = function(v177, v178) --[[ Line: 563 ]]
        local v179 = 0;
        local v180 = string.find(v177, v178);
        while v180 do
            v179 = v179 + 1;
            v180 = string.find(v177, v178, v180 + 1);
        end;
        return v179;
    end;
    getRoundMapInfo = function() --[[ Line: 572 ]]
        return {
            modename = getTacticsData("Map"), 
            name = getTacticsData("MapName") or "unnamed", 
            author = getTacticsData("MapAuthor"), 
            resname = getTacticsData("MapResName"), 
            mapnext = getTacticsData("ResourceNext")
        };
    end;
    getRoundModeSettings = function(...) --[[ Line: 581 ]]
        local v181 = {...};
        local v182 = getTacticsData("Map");
        local v183 = {getTacticsData("modes", v182, unpack(v181))};
        if v183[1] then
            return unpack(v183);
        else
            return getTacticsData(unpack(v181));
        end;
    end;
    getUnreadyPlayers = function() --[[ Line: 590 ]]
        local v184 = {};
        for __, v186 in ipairs(getElementsByType("player")) do
            if getElementData(v186, "Loading") and getElementData(v186, "Status") == "Play" then
                table.insert(v184, v186);
            end;
        end;
        if #v184 > 1 then
            return v184;
        else
            return v184[1] or false;
        end;
    end;
    getPlayerGameStatus = function(v187) --[[ Line: 600 ]]
        if not isElement(v187) then
            return false;
        elseif getElementData(v187, "Loading") then
            return "Loading";
        else
            return getElementData(v187, "Status");
        end;
    end;
    getRoundState = function() --[[ Line: 605 ]]
        return (getTacticsData("roundState"));
    end;
end)();
(function(...) --[[ Line: 0 ]]
    addTickCount = 0;
    helpme = {};
    helpmeArrow = {};
    local v188 = false;
    weaponSave = {};
    weaponMemory = false;
    fixTickCount = function(v189) --[[ Line: 13 ]]
        addTickCount = v189 - getTickCount();
    end;
    showCountdown = function(v190) --[[ Line: 16 ]]
        if v190 == 0 then
            dxDrawAnimatedImage("images/count_go.png", 2);
            if not playVoice("audio/count_go.mp3") then
                playSoundFrontEnd(45);
            end;
        elseif v190 <= 3 then
            dxDrawAnimatedImage("images/count_" .. v190 .. ".png", 1);
            if not playVoice("audio/count_" .. v190 .. ".mp3") then
                playSoundFrontEnd(44);
            end;
        end;
    end;
    onClientResourceStart = function(__) --[[ Line: 29 ]]
        -- upvalues: v188 (ref)
        fontTactics = guiCreateFont("verdana.ttf", 20) or fontTactics;
        v188 = false;
        label_version = guiCreateLabel(0, yscreen - 30, xscreen - 5, 30, "", false);
        guiSetEnabled(label_version, false);
        guiLabelSetHorizontalAlign(label_version, "right", false);
        guiSetAlpha(label_version, 0.5);
        mapstring = guiCreateLabel(5, yscreen - 15, xscreen, 15, tostring(getTacticsData("MapName", false)), false);
        guiSetEnabled(mapstring, false);
        guiSetAlpha(mapstring, 0.5);
        for __, v193 in ipairs(getElementsByType("player")) do
            if v193 ~= localPlayer then
                local v194 = createBlipAttachedTo(v193, 0, 2, 0, 0, 0, 0);
                setElementData(v193, "Blip", v194, false);
                setElementParent(v194, v193);
            end;
        end;
        for __, v196 in ipairs(getElementsByType("vehicle")) do
            local v197 = createBlipAttachedTo(v196, 0, 0, 0, 0, 0, 0, -1);
            setElementData(v196, "Blip", v197, false);
            setElementParent(v197, v196);
        end;
        credits_window = guiCreateWindow(xscreen * 0.5 - 280, yscreen * 0.5 - 150, 560, 300, "", false);
        guiWindowSetSizable(credits_window, false);
        guiSetVisible(credits_window, false);
        credits_content = {};
        credits_height = 300;
        local function v202(v198, v199) --[[ Line: 58 ]]
            local v200 = guiCreateLabel(0, credits_height, 560, 1000, v198, false, credits_window);
            if not v199 then
                v199 = 0;
            end;
            if v199 == 1 then
                guiSetFont(v200, "default-bold-small");
            end;
            if v199 == 2 then
                guiSetFont(v200, fontTactics);
            end;
            guiSetEnabled(v200, false);
            guiLabelSetHorizontalAlign(v200, "center", false);
            table.insert(credits_content, {v200, credits_height});
            local v201 = {
                [0] = 50, 
                [1] = 20, 
                [2] = 80
            };
            credits_height = credits_height + string.count(v198, "\n") * guiLabelGetFontHeight(v200) + v201[v199];
            return v200;
        end;
        credits_version = v202("", 2);
        v202("Author, Scripting & Idea", 1);
        v202("Alexander \"Lex128\"");
        v202("Interface Design", 1);
        v202("Alexander \"Lex128\"\nDenis \"spitfire\"\nDenis \"Den\"\nand unknown creator of countdown images");
        v202("Speech Synthesis", 1);
        v202("SitePal.com");
        v202("Mapping", 1);
        v202("Maxim \"Saint\"\nAlexander \"Lex128\"\nStar \"Easterdie\"");
        v202("Language Support", 1);
        v202("Osamah \"iComm2a\"\nEddy \"Dorega\"\nLaith \"C4neeL\"\nViktor \"Rubik\"\nAlexander \"Zaibatsu\"\nJoseph \"Randy\"\nAdrian \"vnm\"\nLukas \"Lukis\"\nNikolas \"Dante\"\nAriel \"arielszz\"");
        v202("Develop open-source", 1);
        v202("Ariel \"arielszz\"");
        v202("Special Thanks", 1);
        v202("Nikita \"Vincent\"\nSemen \"DJ_Semen\"\nSergey \"3ap\"");
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
        addEventHandler("onClientGUIMouseDown", root, function() --[[ Line: 121 ]]
            if (getElementType(source) == "gui-edit" or getElementType(source) == "gui-memo") and guiGetProperty(source, "ReadOnly") ~= "True" then
                guiSetInputEnabled(true);
            elseif guiGetInputEnabled() then
                guiSetInputEnabled(false);
            end;
        end);
        setTimer(triggerServerEvent, 150, 1, "onPlayerDownloadComplete", localPlayer);
        setTimer(triggerEvent, 150, 1, "onDownloadComplete", root);
    end;
    onClientResourceStop = function() --[[ Line: 131 ]]
        for __, v204 in ipairs(currentPed) do
            if isElement(v204) then
                destroyElement(v204);
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
    createVehicleManager = function() --[[ Line: 150 ]]
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
    createWeaponManager = function() --[[ Line: 171 ]]
        weapon_window = guiCreateWindow(xscreen * 0.5 - 310, yscreen * 0.5 - 160, 620, 320, "Weapon Manager", false);
        guiWindowSetSizable(weapon_window, false);
        weapon_properties = guiCreateLabel(435, 28, 185, 230, "", false, weapon_window);
        local v205 = getTacticsData("weapon_slots") or 0;
        weapon_slots = guiCreateLabel(435, 244, 185, 22, "You can choice " .. (v205 > 0 and v205 or "any") .. " weapons", false, weapon_window);
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
    onClientOtherResourceStart = function(v206) --[[ Line: 191 ]]
        if getThisResource() ~= v206 and getResourceName(v206) == getTacticsData("MapResName") and getElementData(localPlayer, "Status") then
            local v207 = {
                modename = getTacticsData("Map"), 
                name = getTacticsData("MapName", false) or "unnamed", 
                author = getTacticsData("MapAuthor", false), 
                resname = getResourceName(v206), 
                resource = v206
            };
            if v207.modename then
                triggerServerEvent("onPlayerMapLoad", localPlayer);
                triggerEvent("onClientMapStarting", root, v207);
            end;
        end;
    end;
    updateTeamManager = function() --[[ Line: 205 ]]
        local v208 = getElementsByType("team");
        table.insert(v208, v208[1]);
        table.remove(v208, 1);
        for v209, v210 in ipairs(v208) do
            if v210 == getPlayerTeam(localPlayer) then
                table.remove(v208, v209);
                break;
            end;
        end;
        local __ = 1;
        for v212 = 1, math.max(#v208, #team_button) do
            if v212 <= #v208 then
                if #team_button < v212 then
                    team_button[v212] = guiCreateButton(5, 5 + 22 * v212, 120, 20, "", false, team_window);
                    guiSetFont(team_button[v212], "default-bold-small");
                end;
                guiSetText(team_button[v212], getTeamName(v208[v212]));
                guiSetProperty(team_button[v212], "NormalTextColour", string.format("FF%02X%02X%02X", getTeamColor(v208[v212])));
                guiBringToFront(team_button[v212]);
            else
                destroyElement(team_button[v212]);
                table.remove(team_button);
            end;
        end;
        guiCheckBoxSetSelected(team_specskin, getElementData(localPlayer, "spectateskin") and true or false);
        guiSetSize(team_window, 260, 5 + 22 * math.max(3, #v208) + 22 + 8, false);
        guiSetPosition(team_joining, 135, 5 + 22 * math.max(2, #v208 - 1), false);
        guiSetPosition(team_close, 135, 5 + 22 * math.max(3, #v208), false);
    end;
    createRadarPolyline = function(v213, v214, v215, v216, v217, v218, v219, v220) --[[ Line: 235 ]]
        if type(v213) ~= "table" and type(v213) ~= "userdata" then
            return false;
        else
            if not v214 then
                v214 = 128;
            end;
            if not v215 then
                v215 = 0;
            end;
            if not v216 then
                v216 = 0;
            end;
            if not v217 then
                v217 = 255;
            end;
            if not v219 then
                v219 = 12;
            end;
            if not v220 then
                v220 = getRoundMapDynamicRoot();
            end;
            local function isValidNumber(num)
                return type(num) == "number" and num == num
            end
            if not isValidNumber(v219) or v219 <= 0 then
                v219 = 12;
            end;
            if not isValidNumber(v214) then v214 = 128 end
            if not isValidNumber(v215) then v215 = 0 end
            if not isValidNumber(v216) then v216 = 0 end
            if not isValidNumber(v217) then v217 = 255 end
            for v221, v222 in ipairs(v213) do
                local v223 = 0;
                local v224 = 0;
                local v225 = 0;
                local v226 = 0;
                if isElement(v222) then
                    local v227 = tonumber(getElementData(v222, "posX"));
                    v224 = tonumber(getElementData(v222, "posY"));
                    v223 = v227;
                else
                    local v228, v229 = unpack(v222);
                    v224 = v229;
                    v223 = v228;
                end;
                if not isValidNumber(v223) or not isValidNumber(v224) then
                    return false;
                end;
            
                local v230 = v221 < #v213 and v213[v221 + 1] or v218 and v213[1];
                if v230 then
                    if isElement(v230) then
                        local v231 = tonumber(getElementData(v230, "posX"));
                        v226 = tonumber(getElementData(v230, "posY"));
                        v225 = v231;
                    else
                        local v232, v233 = unpack(v230);
                        v226 = v233;
                        v225 = v232;
                    end;
                    if not isValidNumber(v225) or not isValidNumber(v226) then
                        return false;
                    end;
                    local distance = getDistanceBetweenPoints2D(v223, v224, v225, v226);
                    if not isValidNumber(distance) then
                        return false;
                    end
                
                    if distance <= 0 then
                        local xPos = v223 - v219 * 0.5
                        local yPos = v224 - v219 * 0.5
                    
                        if isValidNumber(xPos) and isValidNumber(yPos) then
                            local v238 = createRadarArea(xPos, yPos, v219, v219, v214, v215, v216, v217);
                            if v238 and isElement(v238) and v220 and isElement(v220) then
                                setElementParent(v238, v220);
                            end;
                        end
                    else
                        local v234 = math.floor(distance / (0.4 * v219));
                        if v234 < 1 then
                            v234 = 1;
                        end;
                        local v235 = (v225 - v223) / v234;
                        local v236 = (v226 - v224) / v234;
                        if not isValidNumber(v235) or not isValidNumber(v236) then
                            return false;
                        end;
                        for v237 = 0, v234 do
                            local xPos = v223 - v219 * 0.5 + v235 * v237;
                            local yPos = v224 - v219 * 0.5 + v236 * v237;
                            if isValidNumber(xPos) and isValidNumber(yPos) then
                                local v238
                                if isValidNumber(xPos) and isValidNumber(yPos) and isValidNumber(v219) then
                                    v238 = createRadarArea(xPos, yPos, v219, v219, v214, v215, v216, v217);
                                end
                                if v238 and isElement(v238) then
                                    if v220 and isElement(v220) then
                                        setElementParent(v238, v220);
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
    onClientMapStarting = function(__) --[[ Line: 267 ]]
        local v240 = {};
        for __, v242 in ipairs(getElementsByType("Anti_Rush_Point")) do
            local v243 = tonumber(getElementData(v242, "posX"));
            local v244 = tonumber(getElementData(v242, "posY"));
            table.insert(v240, {v243, v244});
        end;
        if #v240 > 0 then
            if #v240 == 2 then
                v240 = {
                    {math.min(v240[1][1], v240[2][1]), math.min(v240[1][2], v240[2][2])}, 
                    {math.max(v240[1][1], v240[2][1]), math.min(v240[1][2], v240[2][2])}, 
                    {math.max(v240[1][1], v240[2][1]), math.max(v240[1][2], v240[2][2])}, 
                    {math.min(v240[1][1], v240[2][1]), math.max(v240[1][2], v240[2][2])}
                };
            end;
            if #v240 > 1 then
                local v245 = getRoundMapDynamicRoot();
                local v246 = {};
                local v247 = getElementsByType("Central_Marker")[1];
                table.insert(v246, tonumber(getElementData(v247, "posX")));
                table.insert(v246, tonumber(getElementData(v247, "posY")));
                for __, v249 in ipairs(v240) do
                    table.insert(v246, v249[1]);
                    table.insert(v246, v249[2]);
                end;
                createRadarPolyline(v240, 128, 0, 0, 255, true, 12, v245);
                local v250 = createColPolygon(unpack(v246));
                setElementParent(v250, v245);
                setElementData(v250, "Boundings", true, false);
            end;
        end;
        if getElementData(localPlayer, "Loading") and type(notreadyCounter) ~= "number" then
            local v251 = getElementsByType("Central_Marker")[1] or getElementsByType("spawnpoint")[1];
            if v251 then
                local v252 = tonumber(getElementData(v251, "posX"));
                local v253 = tonumber(getElementData(v251, "posY"));
                local v254 = tonumber(getElementData(v251, "posZ"));
                if not v252 or not v253 or not v254 then
                    local v255, v256, v257 = getElementPosition(v251);
                    v254 = v257;
                    v253 = v256;
                    v252 = v255;
                end;
                if v252 and v253 and v254 then
                    setCameraMatrix(v252, v253, v254 + 1, v252, v253, v254);
                end;
            end;
        end;
    end;
    onClientPlayerJoin = function() --[[ Line: 307 ]]
        local v258 = createBlipAttachedTo(source, 0, 2, 0, 0, 0, 0);
        setElementData(source, "Blip", v258, false);
        setElementParent(v258, source);
    end;
    onClientPlayerQuit = function(__) --[[ Line: 312 ]]
        local v260 = getElementData(source, "Blip");
        if v260 then
            destroyElement(v260);
        end;
    end;
    onClientPlayerDamage = function(v261, __, __, __) --[[ Line: 316 ]]
        if isElement(v261) and localPlayer ~= v261 then
            if getElementType(v261) == "vehicle" then
                v261 = getVehicleController(v261);
            end;
            if getElementType(v261) ~= "player" then
                return;
            else
                local v265 = getPlayerTeam(v261);
                local v266 = getPlayerTeam(localPlayer);
                if v266 and v265 and v265 ~= v266 and getElementData(v266, "Side") == getElementData(v265, "Side") then
                    cancelEvent();
                end;
            end;
        end;
    end;
    onClientPlayerSpawn = function(__) --[[ Line: 329 ]]
        if source ~= localPlayer then
            setElementCollisionsEnabled(source, true);
        else
            setElementRotation(localPlayer, 0, 0, getPedRotation(localPlayer));
        end;
    end;
    onClientPlayerWasted = function(__, v269, __) --[[ Line: 332 ]]
        if source == localPlayer then
            if v269 == 16 or v269 == 19 or v269 == 35 or v269 == 36 or v269 == 37 or v269 == 39 or v269 == 51 or v269 == 59 then
                playVoice("audio/toasted.mp3");
            else
                playVoice("audio/wasted.mp3");
            end;
            setCameraMatrix(getCameraMatrix());
        else
            setElementCollisionsEnabled(source, false);
        end;
    end;
    onClientRespawnCountdown = function(v271) --[[ Line: 344 ]]
        if respawn_countdown then
            return;
        else
            addEventHandler("onClientPreRender", root, onClientRespawnRender);
            respawn_countdown = v271;
            return;
        end;
    end;
    onClientRespawnRender = function(v272) --[[ Line: 349 ]]
        respawn_countdown = respawn_countdown - v272 * getGameSpeed();
        local v273 = tonumber(getRoundModeSettings("respawn_lives") or getTacticsData("settings", "respawn_lives") or tonumber(0));
        local v274 = getElementData(localPlayer, "RespawnLives");
        if v274 and v273 > 0 then
            dxDrawText(tostring(v274), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, 4278190080, getFont(2), "default-bold", "center", "bottom");
            dxDrawText(tostring(v274), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 128), getFont(2), "default-bold", "center", "bottom");
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
    local v275 = nil;
    local v276 = nil;
    onClientRoundCountdownStarted = function(v277) --[[ Line: 368 ]]
        -- upvalues: v276 (ref)
        local v278, v279, v280 = getElementPosition(localPlayer);
        local v281 = math.rad(getPedRotation(localPlayer));
        local v282 = math.rad(2.86431884766);
        local v283 = 0;
        local v284 = 0;
        local v285 = 0.6;
        if isPedDucked(localPlayer) then v285 = -0.1; end;
        local v286 = 3.5 * math.sin(v281) * math.cos(v282);
        local v287 = -3.5 * math.cos(v281) * math.cos(v282);
        local v288 = 3.5 * math.sin(v282) + v285;
        v276 = {
            getTickCount(), v277, v286 + v278, v287 + v279, v288 + v280, v283 + v278, v284 + v279, v285 + v280};
    end;
    onClientPrepairRender = function() --[[ Line: 377 ]]
        -- upvalues: v275 (ref), v276 (ref)
        local v289 = getElementData(localPlayer, "Prepair");
        if v289 and not getCameraTarget() then
            local v290, v291, v292, v293 = unpack(v289);
            local v294, v295, v296 = getCameraMatrix();
            v275 = (v275 or getAngleBetweenPoints2D(v290, v291, v294, v295)) + 1;
            local v297 = math.rad(v275);
            local v298 = v290 - v293 * math.sin(v297);
            local v299 = v291 + v293 * math.cos(v297);
            v296 = v292 + 0.5 * v293;
            v295 = v299;
            v294 = v298;
            if v276 == nil or getElementData(localPlayer, "Status") ~= "Play" then
                setCameraMatrix(v294, v295, v296, v290, v291, v292);
            elseif type(v276) == "table" then
                local v300, v301, v302, v303, v304, v305;
                v298, v299, v300, v301, v302, v303, v304, v305 = unpack(v276);
                local v306 = getEasingValue(math.max(0, math.min(1, (getTickCount() - v298) / v299)), "InOutQuad");
                v275 = v275 - v306;
                local v307 = v294 + v306 * (v300 - v294);
                local v308 = v295 + v306 * (v301 - v295);
                local v309 = v296 + v306 * (v302 - v296);
                local v310 = v290 + v306 * (v303 - v290);
                local v311 = v291 + v306 * (v304 - v291);
                local v312 = v292 + v306 * (v305 - v292);
                setCameraMatrix(v307, v308, v309, v310, v311, v312);
                if v306 == 1 then
                    stopCameraPrepair();
                end;
            end;
        elseif v289 then
            stopCameraPrepair();
        end;
    end;
    onDownloadCompleteingRender = function() --[[ Line: 399 ]]
        if type(notreadyCounter) ~= "number" or notreadyCounter < 3000 then
            local v313 = 30 * math.floor(getTickCount() % 1000 * 0.012);
            dxDrawImage(xscreen * 0.5 - 32, yscreen * 0.5 - 32, 64, 64, "images/loading.png", v313);
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
            local v314, v315 = getCameraMatrix();
            if not isLineOfSightClear(v314, v315, 1500, v314, v315, -100) or testLineAgainstWater(v314, v315, 1500, v314, v315, -100) then
                notreadyCounter = 0;
            end;
        end;
    end;
    onDownloadComplete = function() --[[ Line: 421 ]]
        local v316 = getRoundMapInfo();
        if v316.modename then
            triggerServerEvent("onPlayerMapLoad", localPlayer);
            triggerEvent("onClientMapStarting", root, v316);
        end;
        local v317 = getTacticsData("weaponspack") or {};
        local v318 = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
        local v319 = fromJSON(xmlNodeGetAttribute(v318, "selected") or "[ [ ] ]");
        weaponSave = {};
        local v320 = getTacticsData("weapon_slots") or 0;
        local v321 = 0;
        for __, v323 in ipairs(v319) do
            if v317[v323] and (v320 == 0 or v321 < v320) then
                weaponSave[v323] = true;
                v321 = v321 + 1;
            end;
        end;
        remakeWeaponsPack();
    end;
    local v324 = {};
    onClientPauseRender = function() --[[ Line: 443 ]]
        -- upvalues: v324 (ref)
        dxDrawRectangle(0, 0, xscreen, yscreen, tocolor(0, 0, 0, 96));
        dxDrawText(getLanguageString("pause"), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(2), "default-bold", "center", "bottom");
        dxDrawText(getLanguageString("pause"), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(0, 128, 255), getFont(2), "default-bold", "center", "bottom");
        local v325 = getTacticsData("Unpause");
        if v325 then
            local v326 = v325 - (getTickCount() + addTickCount);
            dxDrawText(string.format(getLanguageString("unpausing_in"), v326 / 1000), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(1), "default", "center", "top");
            dxDrawText(string.format(getLanguageString("unpausing_in"), v326 / 1000), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 255), getFont(1), "default", "center", "top");
        end;
        local v327 = getPedTask(localPlayer, "primary", 1);
        local v328 = getPedTask(localPlayer, "primary", 3);
        local v329 = getPedTask(localPlayer, "primary", 4);
        for __, v331 in ipairs(getElementsByType("projectile", root, true)) do
            if v324[v331] then
                local v332, v333, v334, v335, v336, v337 = unpack(v324[v331]);
                setElementPosition(v331, v332, v333, v334, false);
                setElementVelocity(v331, v335, v336, v337);
            else
                local v338, v339, v340 = getElementPosition(v331);
                local v341, v342, v343 = getElementVelocity(v331);
                v324[v331] = {v338, v339, v340, v341, v342, v343};
            end;
        end;
        if getElementData(localPlayer, "Status") == "Play" and v329 == "TASK_SIMPLE_PLAYER_ON_FOOT" and v327 ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and v328 ~= "TASK_COMPLEX_JUMP" then
            if not xpause then
                local v344, v345, v346 = getElementPosition(localPlayer);
                zpause = v346;
                ypause = v345;
                xpause = v344;
                rpause = getPedRotation(localPlayer);
            end;
            setElementPosition(localPlayer, xpause, ypause, zpause, false);
            setPedRotation(localPlayer, rpause);
        elseif xpause then
            xpause = nil;
        end;
    end;
    local v347 = "";
    local v348 = "";
    local v349 = 4294967295;
    local v350 = 4278190080;
    local v351 = xscreen * 0.5;
    local v352 = yscreen * 0.35;
    local v353 = xscreen * 0.502;
    local v354 = yscreen * 0.352;
    local v355 = getFont(2);
    local v356 = getFont(1);
    onClientMessageRender = function() --[[ Line: 486 ]]
        -- upvalues: v347 (ref), v353 (ref), v354 (ref), v350 (ref), v355 (ref), v351 (ref), v352 (ref), v349 (ref), v348 (ref), v356 (ref)
        dxDrawText(v347, v353, v354, v353, v354, v350, v355, "default-bold", "center", "bottom");
        dxDrawText(v347, v351, v352, v351, v352, v349, v355, "default-bold", "center", "bottom");
        dxDrawText(v348, v353, v354, v353, v354, v350, v356, "default", "center", "top");
        dxDrawText(v348, v351, v352, v351, v352, 4294967295, v356, "default", "center", "top");
    end;
    onClientPlayerTarget = function(v357) --[[ Line: 492 ]]
        -- upvalues: v188 (ref)
        if v357 and not v188 then
            v188 = true;
            addEventHandler("onClientRender", root, onClientVehicleNametagRender);
        end;
    end;
    local v358 = yscreen * 0.011;
    local v359 = xscreen * 0.06;
    local v360 = yscreen * 0.025;
    local v361 = xscreen * 0.003;
    onClientVehicleNametagRender = function() --[[ Line: 502 ]]
        -- upvalues: v359 (ref), v361 (ref), v358 (ref), v360 (ref), v188 (ref)
        local v362 = getPedTarget(localPlayer);
        if v362 and getElementType(v362) == "vehicle" then
            local v363, v364, v365 = getElementPosition(v362);
            local v366, v367 = getScreenFromWorldPosition(v363, v364, v365);
            if v366 then
                local v368 = (getElementHealth(v362) - 250) / 750;
                if v368 < 0 then
                    v368 = 0;
                end;
                local v369 = math.floor(512 * (1 - v368));
                local v370 = math.floor(512 * v368);
                v369 = math.min(math.max(v369, 0), 255);
                v370 = math.min(math.max(v370, 0), 255);
                dxDrawRectangle(v366 - 0.5 * v359 - v361, v367 - 0.5 * v358 - v361 + v360, v359 + 2 * v361, v358 + 2 * v361, tocolor(0, 0, 0, 180));
                dxDrawRectangle(v366 - 0.5 * v359 + v359 * v368, v367 - 0.5 * v358 + v360, (1 - v368) * v359, v358, tocolor(math.floor(0.33 * v369), math.floor(0.33 * v370), 0, 180));
                dxDrawRectangle(v366 - 0.5 * v359, v367 - 0.5 * v358 + v360, v359 * v368, v358, tocolor(v369, v370, 0, 180));
            end;
        else
            v188 = false;
            removeEventHandler("onClientRender", root, onClientVehicleNametagRender);
        end;
    end;
    forcedChangeTeam = function() --[[ Line: 522 ]]
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
    onClientWeaponDisable = function() --[[ Line: 553 ]]
        setElementData(localPlayer, "Weapons", nil);
    end;
    onClientElementDataChange = function(v371, v372) --[[ Line: 556 ]]
        -- upvalues: v275 (ref), v276 (ref)
        if v371 == "Status" and getElementType(source) == "player" then
            triggerEvent("onClientPlayerGameStatusChange", source, v372);
            triggerEvent("onClientPlayerBlipUpdate", source);
        end;
        if source == localPlayer then
            if v371 == "Prepair" then
                if getElementData(localPlayer, "Prepair") and not v372 then
                    v275 = nil;
                    v276 = nil;
                    addEventHandler("onClientPreRender", root, onClientPrepairRender);
                elseif not getElementData(localPlayer, "Prepair") and v372 then
                    removeEventHandler("onClientPreRender", root, onClientPrepairRender);
                    v275 = nil;
                    v276 = nil;
                end;
            end;
            if v371 == "Weapons" then
                if getElementData(localPlayer, "Weapons") == true then
                    addEventHandler("onClientPlayerWeaponFire", localPlayer, onClientWeaponDisable);
                else
                    removeEventHandler("onClientPlayerWeaponFire", localPlayer, onClientWeaponDisable);
                end;
            end;
            if v371 == "Loading" then
                if getElementData(localPlayer, "Loading") and not v372 then
                    notreadyCounter = nil;
                    fadeCamera(false, 0);
                    addEventHandler("onClientRender", root, onDownloadCompleteingRender);
                elseif not getElementData(localPlayer, "Loading") and v372 then
                    removeEventHandler("onClientRender", root, onDownloadCompleteingRender);
                    fadeCamera(true, 0);
                end;
            end;
        end;
        if v371 == "Helpme" and source ~= localPlayer then
            local v373 = getElementData(source, v371);
            local v374 = getPlayerTeam(localPlayer);
            local v375 = getPlayerTeam(source);
            if v373 and v374 and (v374 == getElementsByType("team")[1] or v374 == v375) then
                if isTimer(helpme[source]) then
                    killTimer(helpme[source]);
                end;
                helpme[source] = setTimer(function(v376) --[[ Line: 597 ]]
                    if not isElement(v376) or not getElementData(v376, "Helpme") then
                        killTimer(helpme[v376]);
                    end;
                    if isElement(helpmeArrow[v376]) then
                        destroyElement(helpmeArrow[v376]);
                    else
                        helpmeArrow[v376] = createMarker(0, 0, 0, "arrow", 0.5, 255, 255, 0, 128);
                        attachElements(helpmeArrow[v376], v376, 0, 0, 2);
                        setElementInterior(helpmeArrow[v376], getElementInterior(v376));
                        setElementParent(helpmeArrow[v376], v376);
                        local v377 = createBlipAttachedTo(helpmeArrow[v376], 0, 2, 255, 255, 0, 255, 1);
                        setElementParent(v377, helpmeArrow[v376]);
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
    onClientTacticsChange = function(v378, v379) --[[ Line: 619 ]]
        -- upvalues: v347 (ref), v348 (ref), v349 (ref), v188 (ref)
        if v378[1] == "version" then
            local v380 = getTacticsData("version");
            guiSetText(label_version, "Tactics " .. tostring(v380));
            guiSetText(credits_window, "Tactics " .. tostring(v380));
            guiSetText(credits_version, "Tactics " .. tostring(v380));
        end;
        if v378[1] == "message" then
            local v381 = getTacticsData("message");
            if v381 then
                v347 = "";
                v348 = "";
                v349 = 4294967295;
                if type(v381[1]) == "table" then
                    if type(v381[1][1]) == "string" then
                        local v382 = v381[1][1];
                        local v383 = v381[1];
                        table.remove(v383, 1);
                        if #v383 > 0 then
                            v347 = string.format(getLanguageString(v382), unpack(v383));
                        elseif v382 then
                            v347 = getLanguageString(v382);
                        end;
                        if #v347 == 0 then
                            v347 = tostring(v382);
                        end;
                    elseif type(v381[1][4]) == "string" then
                        local v384 = tonumber(v381[1][1]);
                        local v385 = tonumber(v381[1][2]);
                        local v386 = tonumber(v381[1][3]);
                        local v387 = v381[1][4];
                        local v388 = v381[1];
                        v349 = tocolor(v384, v385, v386);
                        if #v388 > 4 then
                            table.remove(v388, 4);
                            table.remove(v388, 3);
                            table.remove(v388, 2);
                            table.remove(v388, 1);
                            v347 = string.format(getLanguageString(v387), unpack(v388));
                        elseif v387 then
                            v347 = getLanguageString(v387);
                        end;
                        if #v347 == 0 then
                            v347 = tostring(v387);
                        end;
                    end;
                elseif type(v381[1]) == "string" then
                    v347 = getLanguageString(v381[1]);
                    if #v347 == 0 then
                        v347 = tostring(v381[1]);
                    end;
                else
                    v347 = tostring(v381[1]);
                end;
                if type(v381[2]) == "table" then
                    local v389 = v381[2][1];
                    local v390 = v381[2];
                    table.remove(v390, 1);
                    v348 = string.format(getLanguageString(tostring(v389)), unpack(v390));
                elseif type(v381[2]) == "string" then
                    v348 = getLanguageString(v381[2]);
                    if #v348 == 0 then
                        v348 = tostring(v381[2]);
                    end;
                else
                    v348 = tostring(v381[2]);
                end;
                v347 = removeColorCoding(v347);
                v348 = removeColorCoding(v348);
            end;
            if v381 and not v379 then
                addEventHandler("onClientRender", root, onClientMessageRender);
            elseif not v381 and v379 then
                removeEventHandler("onClientRender", root, onClientMessageRender);
            end;
        end;
        if v378[1] == "Pause" then
            local v391 = getTacticsData("Pause");
            if v391 and not v379 then
                addEventHandler("onClientRender", root, onClientPauseRender);
            elseif not v391 and v379 then
                removeEventHandler("onClientRender", root, onClientPauseRender);
                xpause = nil;
            end;
        end;
        if v378[1] == "weaponspack" or v378[1] == "weapon_balance" or v378[1] == "weapon_cost" then
            remakeWeaponsPack();
        end;
        if v378[1] == "weapon_slots" then
            local v392 = getTacticsData("weapon_slots") or 0;
            if v392 > 0 then
                local v393 = 0;
                if isElement(weapon_window) then
                    guiSetText(weapon_slots, "You can choice " .. v392 .. " weapons");
                    for __, v395 in ipairs(weapon_items) do
                        if guiGetProperty(v395.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            v393 = v393 + 1;
                            if v392 < v393 then
                                guiSetProperty(v395.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                                weaponSave[guiGetText(v395.name)] = nil;
                            end;
                        end;
                    end;
                else
                    for v396 in pairs(weaponSave) do
                        v393 = v393 + 1;
                        if v392 < v393 then
                            weaponSave[v396] = nil;
                        end;
                    end;
                end;
                if v392 < v393 then
                    updateSaveWeapons();
                end;
            elseif isElement(weapon_window) then
                guiSetText(weapon_slots, "You can choice any weapons");
            end;
        end;
        if v378[1] == "settings" then
            if v378[2] == "ghostmode" then
                local v397 = getTacticsData("settings", "ghostmode");
                if v397 == "all" or v397 == "team" then
                    setCameraClip(true, false);
                else
                    setCameraClip(true, true);
                end;
                for __, v399 in ipairs(getElementsByType("player", root, true)) do
                    for __, v401 in ipairs(getElementsByType("player", root, true)) do
                        if v397 == "all" then
                            setElementCollidableWith(v399, v401, false);
                        elseif v397 == "team" and getPlayerTeam(v399) == getPlayerTeam(v401) then
                            setElementCollidableWith(v399, v401, false);
                        else
                            setElementCollidableWith(v399, v401, true);
                        end;
                    end;
                end;
                for __, v403 in ipairs(getElementsByType("vehicle", root, true)) do
                    for __, v405 in ipairs(getElementsByType("vehicle", root, true)) do
                        if v397 == "all" then
                            setElementCollidableWith(v403, v405, false);
                        elseif v397 == "team" and getVehicleController(v403) and getVehicleController(v405) and getPlayerTeam(getVehicleController(v403)) == getPlayerTeam(getVehicleController(v405)) then
                            setElementCollidableWith(v403, v405, false);
                        else
                            setElementCollidableWith(v403, v405, true);
                        end;
                    end;
                end;
            end;
            if v378[2] == "time" then
                updateWeather();
            end;
            if v378[2] == "time_minuteduration" then
                updateWeather();
            end;
            if v378[2] == "gravity" then
                setGravity(tonumber(getTacticsData("settings", "gravity")));
            end;
            if v378[2] == "player_radarblip" or v378[2] == "player_nametag" then
                triggerEvent("onClientPlayerBlipUpdate", localPlayer);
            end;
            if v378[2] == "blurlevel" then
                setBlurLevel(tonumber(getTacticsData("settings", "blurlevel")) or 36);
            end;
            if v378[2] == "heli_killing" then
                if getTacticsData("settings", "heli_killing") == "false" then
                    addEventHandler("onClientPlayerHeliKilled", root, cancelEvent);
                    addEventHandler("onClientPedHeliKilled", root, cancelEvent);
                else
                    removeEventHandler("onClientPlayerHeliKilled", root, cancelEvent);
                    removeEventHandler("onClientPedHeliKilled", root, cancelEvent);
                end;
            end;
            if v378[2] == "stealth_killing" then
                if getTacticsData("settings", "stealth_killing") == "false" then
                    addEventHandler("onClientPlayerStealthKill", localPlayer, cancelEvent);
                else
                    removeEventHandler("onClientPlayerStealthKill", localPlayer, cancelEvent);
                end;
            end;
            if v378[2] == "vehicle_radarblip" then
                local v406 = getTacticsData("settings", "vehicle_radarblip");
                for __, v408 in ipairs(getElementsByType("vehicle")) do
                    local v409 = getElementData(v408, "Blip");
                    if v409 then
                        local v410 = 0;
                        local v411 = 0;
                        local v412 = 0;
                        local v413 = 0;
                        if v406 == "always" then
                            local v414 = 128;
                            local v415 = 128;
                            local v416 = 128;
                            v413 = 128;
                            v412 = v416;
                            v411 = v415;
                            v410 = v414;
                        elseif v406 == "unoccupied" then
                            local v417 = false;
                            local v418 = getVehicleOccupants(v408);
                            for v419 = 0, getVehicleMaxPassengers(v408) do
                                if v418[v419] then
                                    v417 = true;
                                    break;
                                end;
                            end;
                            if not v417 and not getVehicleController(v408) then
                                local v420 = 128;
                                local v421 = 128;
                                local v422 = 128;
                                v413 = 128;
                                v412 = v422;
                                v411 = v421;
                                v410 = v420;
                            end;
                        end;
                        setBlipColor(v409, v410, v411, v412, v413);
                    end;
                end;
            end;
            if v378[2] == "vehicle_nametag" then
                if getTacticsData("settings", "vehicle_nametag") == "true" then
                    addEventHandler("onClientPlayerTarget", localPlayer, onClientPlayerTarget);
                else
                    if v188 then
                        v188 = false;
                        removeEventHandler("onClientRender", root, onClientVehicleNametagRender);
                    end;
                    removeEventHandler("onClientPlayerTarget", localPlayer, onClientPlayerTarget);
                end;
            end;
        end;
        if v378[1] == "MapName" then
            guiSetText(mapstring, tostring(getTacticsData("MapName", false)));
        end;
        if v378[1] == "Weather" then
            updateWeatherBlend();
            updateWeather(true);
        end;
    end;
    onClientElementStreamIn = function() --[[ Line: 831 ]]
        if getElementType(source) == "player" then
            local v423 = getTacticsData("settings", "ghostmode");
            for __, v425 in ipairs(getElementsByType("player", root, true)) do
                if v423 == "all" then
                    setElementCollidableWith(v425, source, false);
                    setElementCollidableWith(source, v425, false);
                elseif v423 == "team" and getPlayerTeam(v425) == getPlayerTeam(source) then
                    setElementCollidableWith(v425, source, false);
                    setElementCollidableWith(source, v425, false);
                else
                    setElementCollidableWith(v425, source, true);
                    setElementCollidableWith(source, v425, true);
                end;
            end;
        end;
        if getElementType(source) == "vehicle" then
            local v426 = getTacticsData("settings", "ghostmode");
            for __, v428 in ipairs(getElementsByType("vehicle", root, true)) do
                if v426 == "all" then
                    setElementCollidableWith(v428, source, false);
                    setElementCollidableWith(source, v428, false);
                elseif v426 == "all" and getVehicleController(v428) and getVehicleController(source) and getElementType(getVehicleController(v428)) == "player" and getElementType(getVehicleController(source)) == "player" and getPlayerTeam(getVehicleController(v428)) == getPlayerTeam(getVehicleController(source)) then
                    setElementCollidableWith(v428, source, false);
                    setElementCollidableWith(source, v428, false);
                else
                    setElementCollidableWith(v428, source, true);
                    setElementCollidableWith(source, v428, true);
                end;
            end;
            if not getElementData(source, "Blip") then
                local v429 = getTacticsData("settings", "vehicle_radarblip");
                local v430 = 0;
                local v431 = 0;
                local v432 = 0;
                local v433 = 0;
                if v429 == "always" then
                    local v434 = 128;
                    local v435 = 128;
                    local v436 = 128;
                    v433 = 128;
                    v432 = v436;
                    v431 = v435;
                    v430 = v434;
                elseif v429 == "unoccupied" then
                    local v437 = false;
                    local v438 = getVehicleOccupants(source);
                    for v439 = 0, getVehicleMaxPassengers(source) do
                        if v438[v439] then
                            v437 = true;
                            break;
                        end;
                    end;
                    if not v437 and not getVehicleController(source) then
                        local v440 = 128;
                        local v441 = 128;
                        local v442 = 128;
                        v433 = 128;
                        v432 = v442;
                        v431 = v441;
                        v430 = v440;
                    end;
                end;
                local v443 = createBlipAttachedTo(source, 0, 0, v430, v431, v432, v433, -1);
                setElementData(source, "Blip", v443, false);
                setElementParent(v443, source);
            end;
            local v444 = getTacticsData("settings", "vehicle_tank_explodable") == "true";
            setVehicleFuelTankExplodable(source, v444);
        end;
    end;
    onClientGUIClick = function(v445, __, __, __) --[[ Line: 888 ]]
        if v445 ~= "left" then
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
                    local v449 = {};
                    local v450 = getTacticsData("weaponspack") or {};
                    for v451 in pairs(weaponSave) do
                        local v452 = convertWeaponNamesToID[v451];
                        local v453 = tonumber(v450[v451]) or 0;
                        table.insert(v449, {id = v452, ammo = math.max(v453, 1), name = v451});
                    end;
                    callServerFunction("onPlayerWeaponpackChose", localPlayer, v449);
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
                for __, v455 in ipairs(team_button) do
                    if source == v455 then
                        local v456 = getTeamFromName(tostring(guiGetText(source)));
                        local v457 = (getElementData(v456, "Skins") or {
                            71
                        })[1];
                        triggerServerEvent("onPlayerTeamSelect", localPlayer, v456, v457);
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
                local v458 = guiGridListGetSelectedItem(vehicle_list);
                if v458 ~= -1 then
                    local v459 = getVehicleModelFromName(guiGridListGetItemText(vehicle_list, v458, 1));
                    if v459 then
                        local v460 = nil;
                        local v461 = getPedOccupiedVehicle(localPlayer);
                        if v461 then
                            v460 = getElementDistanceFromCentreOfMassToBaseOfModel(v461);
                        end;
                        callServerFunction("onPlayerVehicleSelect", localPlayer, v459, v460);
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
                    local v462 = {};
                    for __, v464 in ipairs(weapon_items) do
                        if guiGetProperty(v464.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            table.insert(v462, guiGetText(v464.name));
                        end;
                    end;
                    if #v462 > 1 then
                        table.sort(v462, function(v465, v466) --[[ Line: 977 ]]
                            return v465 < v466;
                        end);
                    end;
                    local v467 = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
                    xmlNodeSetAttribute(v467, "selected", toJSON(v462));
                else
                    weaponMemory = false;
                    local v468 = xmlFindChild(_client, "weaponpack", 0);
                    if v468 then
                        xmlDestroyNode(v468);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if isElement(weapon_window) and guiGetVisible(weapon_window) then
                local v469 = false;
                for __, v471 in ipairs(weapon_items) do
                    if source == v471.gui then
                        local v472 = getTacticsData("weapon_slot") or {};
                        v469 = true;
                        local v473 = guiGetText(v471.name);
                        if guiGetProperty(v471.gui, "ImageColours") ~= "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            local v474 = convertWeaponNamesToID[v473];
                            local v475 = tonumber(v472[v473]) or v474 and getSlotFromWeapon(v474) or 13;
                            for __, v477 in ipairs(weapon_items) do
                                if guiGetProperty(v477.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                                    local v478 = guiGetText(v477.name);
                                    local v479 = convertWeaponNamesToID[v478];
                                    if v475 == (tonumber(v472[v478]) or v479 and getSlotFromWeapon(v479) or 13) then
                                        guiSetProperty(v477.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                                        weaponSave[v478] = nil;
                                    end;
                                end;
                            end;
                            local v480 = getTacticsData("weapon_slots") or 0;
                            local v481 = 0;
                            for __ in pairs(weaponSave) do
                                v481 = v481 + 1;
                            end;
                            if v480 == 0 or v481 < v480 then
                                guiSetProperty(v471.gui, "ImageColours", "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF");
                                weaponSave[v473] = true;
                                break;
                            else
                                break;
                            end;
                        elseif guiGetProperty(v471.gui, "ImageColours") == "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF" then
                            guiSetProperty(v471.gui, "ImageColours", "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF");
                            weaponSave[v473] = nil;
                            break;
                        else
                            break;
                        end;
                    end;
                end;
                if v469 then
                    updateSaveWeapons();
                end;
            end;
            return;
        end;
    end;
    updateSaveWeapons = function() --[[ Line: 1026 ]]
        local v483 = xmlFindChild(_client, "weaponpack", 0) or xmlCreateChild(_client, "weaponpack");
        local v484 = fromJSON(xmlNodeGetAttribute(v483, "selected") or "[ [ ] ]");
        local v485 = {};
        for v486, __ in pairs(weaponSave) do
            table.insert(v485, v486);
        end;
        if #v485 > 1 then
            table.sort(v485, function(v488, v489) --[[ Line: 1034 ]]
                return v488 < v489;
            end);
        end;
        local v490 = true;
        for v491, v492 in ipairs(v484) do
            if v492 ~= v485[v491] then
                v490 = false;
                break;
            end;
        end;
        if #v484 ~= #v485 or #v484 == 0 then
            v490 = false;
        end;
        weaponMemory = v490;
        if isElement(weapon_window) then
            guiCheckBoxSetSelected(weapon_memory, v490);
        end;
    end;
    onClientGUIDoubleClick = function(v493, __, __, __) --[[ Line: 1048 ]]
        if v493 ~= "left" then
            return;
        else
            if source == vehicle_list then
                local v497 = guiGridListGetSelectedItem(vehicle_list);
                if v497 ~= -1 then
                    local v498 = getVehicleModelFromName(guiGridListGetItemText(vehicle_list, v497, 1));
                    if v498 then
                        local v499 = nil;
                        local v500 = getPedOccupiedVehicle(localPlayer);
                        if v500 then
                            v499 = getElementDistanceFromCentreOfMassToBaseOfModel(v500);
                        end;
                        callServerFunction("onPlayerVehicleSelect", localPlayer, v498, v499);
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
    onClientGUIChanged = function(__) --[[ Line: 1066 ]]
        if source == vehicle_search then
            updateVehicleList();
        end;
    end;
    onClientMouseEnter = function(__, __) --[[ Line: 1071 ]]
        if isElement(weapon_window) and guiGetVisible(weapon_window) then
            for __, v505 in ipairs(weapon_items) do
                if source == v505.gui then
                    if guiGetProperty(v505.gui, "ImageColours") == "tl:00000000 tr:00000000 bl:00000000 br:00000000" then
                        guiSetProperty(v505.gui, "ImageColours", "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF");
                    end;
                    local v506 = guiGetText(v505.name);
                    local v507 = convertWeaponNamesToID[v506] or 0;
                    local v508 = "Name: " .. v506;
                    local __ = "-";
                    if v506 == "grenade" or v506 == "satchel" or v506 == "rocket" or v506 == "headseek" then
                        v508 = v508 .. "\nDamage: explosion";
                    elseif v506 == "teargas" or v506 == "spray" or v506 == "fireextinguisher" then
                        v508 = v508 .. "\nDamage: gas";
                    elseif v506 == "flame" or v506 == "molotov" then
                        v508 = v508 .. "\nDamage: fire";
                    elseif v507 >= 22 and v507 <= 39 and getWeaponProperty(v507, "pro", "damage") then
                        if v506 == "shotgun" or v506 == "sawnoff" then
                            v508 = v508 .. "\nDamage: " .. string.format("shot %.1f ~ %.1f hp", getWeaponProperty(v507, "pro", "damage") / 3, getWeaponProperty(v507, "pro", "damage") * 5);
                        elseif v506 == "spas12" then
                            v508 = v508 .. "\nDamage: " .. string.format("shot %.1f ~ %.1f hp", getWeaponProperty(v507, "pro", "damage") / 3, getWeaponProperty(v507, "pro", "damage") * 2.66);
                        else
                            v508 = v508 .. "\nDamage: " .. string.format("bullet %.1f hp", getWeaponProperty(v507, "pro", "damage") / 3);
                        end;
                    else
                        v508 = v508 .. "\nDamage: -";
                    end;
                    if v507 >= 22 and v507 <= 39 then
                        local v510 = getWeaponProperty(v507, "pro", "anim_loop_start");
                        local v511 = getWeaponProperty(v507, "pro", "anim_loop_stop");
                        if v510 and v511 then
                            v508 = v508 .. "\nFire Rate: " .. math.floor(60 / (v511 - v510)) .. " r/min";
                        end;
                        if getWeaponProperty(v507, "pro", "weapon_range") then
                            v508 = v508 .. "\nRange: " .. math.floor(getWeaponProperty(v507, "pro", "weapon_range")) .. " m";
                        end;
                    end;
                    guiSetText(weapon_properties, v508);
                end;
            end;
        end;
    end;
    onClientMouseLeave = function(__, __) --[[ Line: 1115 ]]
        if isElement(weapon_window) and guiGetVisible(weapon_window) then
            for __, v515 in ipairs(weapon_items) do
                if source == v515.gui then
                    if guiGetProperty(v515.gui, "ImageColours") == "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF" then
                        guiSetProperty(v515.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    end;
                    guiSetText(weapon_properties, "");
                end;
            end;
        end;
    end;
    toggleVehicleManager = function(__, v517) --[[ Line: 1127 ]]
        if v517 then
            if getVehicleModelFromName(v517) then
                v517 = getVehicleModelFromName(v517);
            else
                v517 = math.floor(tonumber(v517));
            end;
            if not (getTacticsData("disabled_vehicles") or {})[v517] and v517 >= 400 and v517 <= 611 then
                local v518 = nil;
                local v519 = getPedOccupiedVehicle(localPlayer);
                if v519 then
                    v518 = getElementDistanceFromCentreOfMassToBaseOfModel(v519);
                end;
                callServerFunction("onPlayerVehicleSelect", localPlayer, v517, v518);
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
    updateVehicleList = function() --[[ Line: 1170 ]]
        local v520 = guiCheckBoxGetSelected(vehicle_car);
        local v521 = guiCheckBoxGetSelected(vehicle_bike);
        local v522 = guiCheckBoxGetSelected(vehicle_plane);
        local v523 = guiCheckBoxGetSelected(vehicle_heli);
        local v524 = guiCheckBoxGetSelected(vehicle_boat);
        local v525 = guiGetText(vehicle_search);
        local v526 = getTacticsData("disabled_vehicles") or {};
        local v527 = {};
        for v528 = 400, 611 do
            local v529 = getVehicleNameFromModel(v528);
            if not v526[v528] and #v529 > 0 then
                local v530 = false;
                local v531 = getVehicleType(v528);
                if v520 and (v531 == "Automobile" or v531 == "Monster Truck") then
                    v530 = true;
                end;
                if v521 and (v531 == "Bike" or v531 == "BMX" or v531 == "Quad") then
                    v530 = true;
                end;
                if v522 and v531 == "Plane" then
                    v530 = true;
                end;
                if v523 and v531 == "Helicopter" then
                    v530 = true;
                end;
                if v524 and v531 == "Boat" then
                    v530 = true;
                end;
                if #v525 > 0 then
                    for v532 in string.gmatch(v525, "[^ ]+") do
                        if string.sub(v532, 1, 1) == "-" then
                            v532 = string.sub(v532, 2, -1);
                            if string.find(tostring(v528), v532) or string.find(string.lower(v529), string.lower(v532)) then
                                v530 = false;
                            end;
                        elseif not string.find(tostring(v528), v532) and not string.find(string.lower(v529), string.lower(v532)) then
                            v530 = false;
                        end;
                    end;
                end;
                if v530 then
                    table.insert(v527, {v528, v529});
                end;
            end;
        end;
        table.sort(v527, function(v533, v534) --[[ Line: 1206 ]]
            return v533[2] < v534[2];
        end);
        guiGridListClear(vehicle_list);
        for __, v536 in ipairs(v527) do
            local v537 = guiGridListAddRow(vehicle_list);
            guiGridListSetItemText(vehicle_list, v537, 1, v536[2], false, false);
        end;
    end;
    toggleWeaponManager = function(v538) --[[ Line: 1213 ]]
        if (not isElement(weapon_window) or not guiGetVisible(weapon_window)) and v538 ~= false or v538 == true then
            if isElement(weapon_window) and v538 == true and guiCheckBoxGetSelected(weapon_memory) and not guiGetVisible(weapon_window) then
                triggerEvent("onClientGUIClick", weapon_accept, "left", "up", 0, 0);
                return;
            elseif not isElement(weapon_window) and v538 == true and weaponMemory then
                if not getElementData(localPlayer, "Weapons") then
                    return outputChatBox(getLanguageString("weapon_choice_disabled"), 255, 100, 100);
                else
                    local v539 = {};
                    local v540 = getTacticsData("weaponspack") or {};
                    for v541 in pairs(weaponSave) do
                        local v542 = convertWeaponNamesToID[v541];
                        local v543 = tonumber(v540[v541]) or 0;
                        table.insert(v539, {id = v542, ammo = math.max(v543, 1), name = v541});
                    end;
                    callServerFunction("onPlayerWeaponpackChose", localPlayer, v539);
                    return;
                end;
            else
                if isElement(weapon_window) then
                    for __, v545 in ipairs(weapon_items) do
                        if guiGetProperty(v545.gui, "ImageColours") == "tl:20FFFFFF tr:20FFFFFF bl:20FFFFFF br:20FFFFFF" then
                            guiSetProperty(v545.gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
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
    onClientPauseToggle = function(v546) --[[ Line: 1252 ]]
        -- upvalues: v324 (ref)
        for __, v548 in ipairs(getElementsByType("sound")) do
            setSoundPaused(v548, v546);
        end;
        if v546 then
            v324 = {};
            for __, v550 in ipairs(getElementsByType("projectile")) do
                local v551, v552, v553 = getElementPosition(v550);
                local v554, v555, v556 = getElementVelocity(v550);
                v324[v550] = {v551, v552, v553, v554, v555, v556};
            end;
        end;
        if getElementData(localPlayer, "Status") == "Play" then
            local v557 = {
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
            if v546 then
                local v558 = {};
                for __, v560 in ipairs(v557) do
                    if getPedControlState(v560) and v560 ~= "fire" and v560 ~= "vehicle_fire" and v560 ~= "vehicle_secondary_fire" and v560 ~= "enter_exit" then
                        table.insert(v558, v560);
                    end;
                end;
                toggleAllControls(false, true, false);
                toggleControl("enter_passenger", false);
                for __, v562 in ipairs(v558) do
                    setPedControlState(v562, true);
                end;
            else
                toggleAllControls(true);
                for __, v564 in ipairs(v557) do
                    local v565 = getBoundKeys(v564) or {};
                    local v566 = false;
                    for v567, __ in pairs(v565) do
                        if getKeyState(v567) then
                            v566 = true;
                            break;
                        end;
                    end;
                    setPedControlState(v564, v566);
                end;
            end;
        end;
    end;
    remakeWeaponsPack = function() --[[ Line: 1294 ]]
        if not isElement(weapon_window) then
            return;
        else
            local v569 = getTacticsData("weaponspack") or {};
            local v570 = getTacticsData("weapon_balance") or {};
            if not getTacticsData("weapon_cost") then
                local __ = {};
            end;
            local v572 = {};
            for v573 in pairs(v569) do
                if v573 ~= nil then
                    table.insert(v572, v573);
                end;
            end;
            local v574 = {
                [2] = 1, 
                [3] = 2, 
                [4] = 2, 
                [5] = 3, 
                [6] = 3
            };
            table.sort(v572, function(v575, v576) --[[ Line: 1302 ]]
                -- upvalues: v574 (ref)
                local v577 = convertWeaponNamesToID[v575] or 46;
                local v578 = convertWeaponNamesToID[v576] or 46;
                local v579 = getSlotFromWeapon(v577);
                local v580 = getSlotFromWeapon(v578);
                local v581 = v574[v579] or 4;
                local v582 = v574[v580] or 4;
                return v581 == v582 and not (v577 >= v578) or v581 < v582;
            end);
            local v583 = 0;
            local v584 = 0;
            for v585 = 1, math.max(#weapon_items, #v572) do
                if v585 <= #v572 then
                    local v586 = v572[v585];
                    local v587 = 0;
                    local v588 = convertWeaponNamesToID[v586] or 16;
                    if v588 >= 16 and v588 <= 18 or v588 >= 22 and v588 <= 39 or v588 >= 41 and v588 <= 43 then
                        v587 = tonumber(getWeaponProperty(v588, "pro", "maximum_clip_ammo")) or 1;
                    end;
                    local v589 = math.max(0, math.floor(tonumber(v569[v586]) - v587)) .. "-" .. math.min(tonumber(v569[v586]), v587);
                    if #weapon_items < v585 then
                        local v590 = guiCreateStaticImage(v583, v584, 64, 84, "images/color_pixel.png", false, weapon_scroller);
                        local v591 = guiCreateStaticImage(2, 5, 60, 64, "images/hud/fist.png", false, v590);
                        guiSetEnabled(v591, false);
                        local v592 = guiCreateLabel(1, 60, 62, 20, v587 > 1 and v589 or v587 == 1 and v569[v586] or "", false, v590);
                        guiLabelSetHorizontalAlign(v592, "center", false);
                        guiLabelSetVerticalAlign(v592, "center");
                        guiSetEnabled(v592, false);
                        local v593 = guiCreateLabel(1, 5, 62, 20, v586, false, v590);
                        guiSetFont(v593, "default-small");
                        guiSetEnabled(v593, false);
                        local v594 = guiCreateLabel(1, 5, 62, 20, v570[v586] and "x" .. v570[v586] or "", false, v590);
                        guiLabelSetHorizontalAlign(v594, "right", false);
                        guiLabelSetColor(v594, 255, 0, 0);
                        guiSetEnabled(v594, false);
                        table.insert(weapon_items, {gui = v590, icon = v591, name = v593, ammo = v592, limit = v594});
                    else
                        guiSetPosition(weapon_items[v585].gui, v583, v584, false);
                        guiSetText(weapon_items[v585].ammo, v587 > 1 and v589 or v587 == 1 and v569[v586] or "");
                        guiSetText(weapon_items[v585].name, v586);
                        guiSetText(weapon_items[v585].limit, v570[v586] and "x" .. v570[v586] or "");
                    end;
                    if fileExists("images/hud/" .. v586 .. ".png") then
                        guiStaticImageLoadImage(weapon_items[v585].icon, "images/hud/" .. v586 .. ".png");
                    else
                        guiStaticImageLoadImage(weapon_items[v585].icon, "images/hud/fist.png");
                    end;
                    if weaponSave[v586] then
                        guiSetProperty(weapon_items[v585].gui, "ImageColours", "tl:80FFFFFF tr:80FFFFFF bl:80FFFFFF br:80FFFFFF");
                    else
                        guiSetProperty(weapon_items[v585].gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    end;
                    v583 = v583 + 66;
                    if v583 > 330 then
                        v583 = 0;
                        v584 = v584 + 86;
                    end;
                else
                    weaponSave[guiGetText(weapon_items[v585].name)] = nil;
                    destroyElement(weapon_items[v585].gui);
                    weapon_items[v585] = nil;
                end;
            end;
            updateSaveWeapons();
            return;
        end;
    end;
    local v595 = 0;
    onClientColShapeLeave = function(v596, __) --[[ Line: 1380 ]]
        -- upvalues: v595 (ref)
        if getElementData(source, "Boundings") and v596 == localPlayer and getElementData(localPlayer, "Status") == "Play" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
            local v598 = getPedOccupiedVehicle(localPlayer);
            if not v598 then
                local v599, v600, v601 = getElementPosition(localPlayer);
                local v602, v603, v604 = getElementVelocity(localPlayer);
                setElementPosition(localPlayer, v599, v600, v601 + 0.1);
                setElementVelocity(localPlayer, -v602, -v603, -v604);
            elseif getVehicleOccupant(v598) == localPlayer then
                local v605, v606 = getElementRotation(v598);
                local v607, v608, v609 = getElementVelocity(v598);
                setElementRotation(v598, v605 + 180, v606 + 180);
                setElementVelocity(v598, -v607, -v608, -v609);
            end;
            v595 = getTickCount() + 15000;
            addEventHandler("onClientPreRender", root, showGoBack);
        end;
    end;
    showGoBack = function() --[[ Line: 1403 ]]
        -- upvalues: v595 (ref)
        local v610 = true;
        for __, v612 in ipairs(getElementsByType("colshape")) do
            if getElementData(v612, "Boundings") and not isElementWithinColShape(localPlayer, v612) then
                v610 = false;
            end;
        end;
        if v610 then
            return removeEventHandler("onClientPreRender", root, showGoBack);
        elseif v595 < getTickCount() then
            callServerFunction("killPed", localPlayer);
            callServerFunction("callClientFunction", root, "outputLangString", "killed_for_out_bounding", getPlayerName(localPlayer));
            return removeEventHandler("onClientPreRender", root, showGoBack);
        else
            dxDrawRectangle(0, 0, xscreen, yscreen, 1610612736);
            dxDrawText(getLanguageString("go_back_to_bounds"), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, 4278190080, getFont(2), "default-bold", "center", "bottom");
            dxDrawText(getLanguageString("go_back_to_bounds"), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, 4294901760, getFont(2), "default-bold", "center", "bottom");
            local v613 = v595 - getTickCount();
            dxDrawText(string.format(getLanguageString("or_you_will_be_killed"), v613 / 1000), xscreen * 0.502, yscreen * 0.352, xscreen * 0.502, yscreen * 0.352, tocolor(0, 0, 0), getFont(1), "default", "center", "top");
            dxDrawText(string.format(getLanguageString("or_you_will_be_killed"), v613 / 1000), xscreen * 0.5, yscreen * 0.35, xscreen * 0.5, yscreen * 0.35, tocolor(255, 255, 255), getFont(1), "default", "center", "top");
            return;
        end;
    end;
    callHelpme = function() --[[ Line: 1431 ]]
        if not getElementData(localPlayer, "Helpme") and getElementData(localPlayer, "Status") == "Play" then
            setElementData(localPlayer, "Helpme", true);
            if isTimer(helpme[localPlayer]) then
                killTimer(helpme[localPlayer]);
            end;
            helpme[localPlayer] = setTimer(setElementData, 7000, 1, localPlayer, "Helpme", nil);
            outputChatBox(string.format(getLanguageString("help_me"), getPlayerName(localPlayer)), 255, 100, 100, true);
        end;
    end;
    local v614 = 0;
    forceRespawnPlayer = function() --[[ Line: 1440 ]]
        -- upvalues: v614 (ref)
        if v614 + 3000 < getTickCount() and getElementData(localPlayer, "Status") == "Play" and not isRoundPaused() and not isElementInWater(localPlayer) then
            local v615 = getPedTask(localPlayer, "primary", 0);
            local v616 = getPedTask(localPlayer, "secondary", 0);
            local v617 = getPedTask(localPlayer, "primary", 1);
            local v618 = getPedTask(localPlayer, "primary", 3);
            local v619 = getPedTask(localPlayer, "primary", 4);
            if v615 ~= "TASK_COMPLEX_FALL_AND_GET_UP" and v616 ~= "TASK_SIMPLE_THROW" and v616 ~= "TASK_SIMPLE_USE_GUN" and v617 ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and v618 ~= "TASK_COMPLEX_LEAVE_CAR" and v618 ~= "TASK_COMPLEX_ENTER_CAR_AS_DRIVER" and v618 ~= "TASK_COMPLEX_ENTER_CAR_AS_PASSENGER" and v618 ~= "TASK_COMPLEX_JUMP" and v619 == "TASK_SIMPLE_PLAYER_ON_FOOT" then
                v614 = getTickCount() + 3000;
                local v620 = {};
                for v621 = 0, 12 do
                    local v622 = getPedWeapon(localPlayer, v621);
                    local v623 = getPedTotalAmmo(localPlayer, v621);
                    local v624 = getPedAmmoInClip(localPlayer, v621);
                    if v622 > 0 and v623 > 0 then
                        if v621 == getPedWeaponSlot(localPlayer) then
                            table.insert(v620, {v622, v623, v624, true});
                        else
                            table.insert(v620, {v622, v623, v624, false});
                        end;
                    end;
                end;
                callServerFunction("forceRespawnPlayer", localPlayer, v620);
            end;
        end;
    end;
    onClientPlayerBlipUpdate = function() --[[ Line: 1474 ]]
        if source == localPlayer then
            for __, v626 in ipairs(getElementsByType("player")) do
                if source ~= v626 then
                    triggerEvent("onClientPlayerBlipUpdate", v626);
                end;
            end;
        elseif getElementType(source) == "player" then
            local v627 = getTacticsData("Map");
            local v628 = getTacticsData("modes", v627, "player_radarblip") or getTacticsData("settings", "player_radarblip");
            local v629 = getPlayerTeam(localPlayer);
            local v630 = getPlayerTeam(source);
            local v631 = getElementData(source, "Blip");
            if v631 and isElement(v631) then
                local v632, v633, v634 = getPlayerNametagColor(source);
                if v630 then
                    local v635, v636, v637 = getTeamColor(v630);
                    v634 = v637;
                    v633 = v636;
                    v632 = v635;
                end;
                if v628 ~= "none" and getElementData(source, "Status") == "Play" and (v628 == "all" or v630 and v629 == v630 or v629 == getElementsByType("team")[1]) then
                    setBlipColor(v631, v632, v633, v634, 255);
                    setBlipSize(v631, 1);
                elseif getElementData(source, "Status") == "Die" then
                    setBlipColor(v631, v632 / 2, v633 / 2, v634 / 2, 128);
                    setBlipSize(v631, 1);
                else
                    setBlipColor(v631, 0, 0, 0, 0);
                end;
            end;
            if source ~= localPlayer then
                if v629 == getElementsByType("team")[1] then
                    setPlayerNametagShowing(source, true);
                elseif getPlayerProperty(source, "invisible") and v629 ~= v630 then
                    setPlayerNametagShowing(source, false);
                elseif getTacticsData("settings", "player_nametag") == "all" then
                    setPlayerNametagShowing(source, true);
                elseif getTacticsData("settings", "player_nametag") == "team" and v629 == v630 then
                    setPlayerNametagShowing(source, true);
                else
                    setPlayerNametagShowing(source, false);
                end;
            end;
        end;
    end;
    showCredits = function() --[[ Line: 1515 ]]
        local v638, v639 = guiGetPosition(credits_ending[1], false);
        guiSetPosition(credits_ending[1], v638, credits_ending[2], false);
        for __, v641 in ipairs(credits_content) do
            local v642, v643 = guiGetPosition(v641[1], false);
            v639 = v643;
            guiSetPosition(v641[1], v642, v641[2], false);
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
    scrollingCredits = function(v644) --[[ Line: 1531 ]]
        if not guiGetVisible(credits_window) then
            removeEventHandler("onClientPreRender", root, scrollingCredits);
            credits_scrolling = nil;
            return;
        else
            credits_scrolling = credits_scrolling + v644;
            if credits_scrolling < 30 then
                return;
            else
                credits_scrolling = credits_scrolling % 30;
                local v645, v646 = guiGetPosition(credits_ending[1], false);
                if v646 > 0 then
                    guiSetPosition(credits_ending[1], v645, v646 - 1, false);
                    for __, v648 in ipairs(credits_content) do
                        local v649, v650 = guiGetPosition(v648[1], false);
                        v646 = v650;
                        v645 = v649;
                        if v646 > 0 then
                            guiSetPosition(v648[1], v645, v646 - 1, false);
                        else
                            guiSetPosition(v648[1], v645, v646 - 1 - 1, false);
                        end;
                    end;
                else
                    guiSetPosition(credits_ending[1], v645, v646 + credits_ending[2], false);
                    for __, v652 in ipairs(credits_content) do
                        local v653, v654 = guiGetPosition(v652[1], false);
                        guiSetPosition(v652[1], v653, v654 + credits_ending[2], false);
                    end;
                end;
                return;
            end;
        end;
    end;
    onClientMapStopping = function(__) --[[ Line: 1559 ]]
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
    onClientRoundStart = function() --[[ Line: 1573 ]]
        stopCameraPrepair();
    end;
    onClientRoundFinish = function(v656, __) --[[ Line: 1576 ]]
        setGameSpeed(getGameSpeed() / 2);
        if not isTimer(decelerationSpeed) then
            decelerationSpeed = setTimer(function() --[[ Line: 1579 ]]
                if getGameSpeed() > 0 then
                    setGameSpeed(math.max(0, getGameSpeed() - 0.02));
                else
                    killTimer(decelerationSpeed);
                end;
            end, 50, 0);
        end;
        local l_name_0 = getRoundMapInfo().name;
        if v656 then
            local v659 = "";
            if type(v656) == "table" then
                if type(v656[1]) == "string" then
                    local v660 = v656[1];
                    local l_v656_0 = v656;
                    table.remove(l_v656_0, 1);
                    v659 = string.format(getLanguageString(tostring(v660)), unpack(l_v656_0));
                else
                    local v662 = v656[4];
                    local l_v656_1 = v656;
                    table.remove(l_v656_1, 1);
                    table.remove(l_v656_1, 1);
                    table.remove(l_v656_1, 1);
                    table.remove(l_v656_1, 1);
                    v659 = string.format(getLanguageString(tostring(v662)), unpack(l_v656_1));
                end;
            elseif type(v656) == "string" then
                v659 = getLanguageString(v656);
                if #v659 == 0 then
                    v659 = tostring(v656);
                end;
            else
                v659 = tostring(v656);
            end;
            outputLangString("round_finish_result", l_name_0, v659);
        else
            outputLangString("round_finish", l_name_0);
        end;
        playMusic("audio/music_gta3.mp3");
        if respawn_countdown then
            removeEventHandler("onClientPreRender", root, onClientRespawnRender);
        end;
        respawn_countdown = nil;
    end;
    onClientRoundTimesup = function() --[[ Line: 1616 ]]
        playVoice("audio/times_up.mp3");
    end;
    doReloadWeapon = function() --[[ Line: 1619 ]]
        if not getPedControlState("jump") and getPedTask(localPlayer, "primary", 4) == "TASK_SIMPLE_PLAYER_ON_FOOT" and getPedTask(localPlayer, "primary", 1) ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and getPedTask(localPlayer, "primary", 3) ~= "TASK_COMPLEX_JUMP" then
            callServerFunction("reloadPedWeapon", localPlayer);
        end;
    end;
    onClientVehicleEnter = function(v664, v665) --[[ Line: 1624 ]]
        local v666 = getElementData(source, "Blip");
        if v666 and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            setBlipColor(v666, 0, 0, 0, 0);
        end;
        if v665 == 0 then
            local v667 = getTacticsData("settings", "ghostmode");
            for __, v669 in ipairs(getElementsByType("vehicle", root, true)) do
                if v667 == "team" and getVehicleController(v669) and getPlayerTeam(getVehicleController(v669)) == getPlayerTeam(v664) then
                    setElementCollidableWith(v669, source, false);
                elseif v667 == "all" then
                    setElementCollidableWith(v669, source, false);
                else
                    setElementCollidableWith(v669, source, true);
                end;
            end;
        end;
    end;
    onClientVehicleStartExit = function(v670, v671, __) --[[ Line: 1644 ]]
        local v673 = getElementData(source, "Blip");
        if v673 and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            local v674 = false;
            local v675 = getVehicleOccupants(source);
            for v676 = 0, getVehicleMaxPassengers(source) do
                if v675[v676] and v676 ~= v671 then
                    v674 = true;
                    break;
                end;
            end;
            local v677 = getVehicleController(source);
            if not v674 and (not v677 or v677 == v670) then
                setBlipColor(v673, 128, 128, 128, 128);
            end;
        end;
    end;
    onClientVehicleExit = function(v678, v679) --[[ Line: 1664 ]]
        local v680 = getElementData(source, "Blip");
        if v680 and getTacticsData("settings", "vehicle_radarblip") == "unoccupied" then
            local v681 = false;
            local v682 = getVehicleOccupants(source);
            for v683 = 0, getVehicleMaxPassengers(source) do
                if v682[v683] and v683 ~= v679 then
                    v681 = true;
                    break;
                end;
            end;
            local v684 = getVehicleController(source);
            if not v681 and (not v684 or v684 == v678) then
                setBlipColor(v680, 128, 128, 128, 128);
            end;
        end;
        if v679 == 0 and getTacticsData("settings", "ghostmode") == "team" then
            for __, v686 in ipairs(getElementsByType("vehicle", root, true)) do
                setElementCollidableWith(v686, source, true);
                setElementCollidableWith(source, v686, true);
            end;
        end;
    end;
    onClientPlayerRoundSpawn = function() --[[ Line: 1690 ]]
        if not getElementData(localPlayer, "Loading") then
            fadeCamera(true, 2);
        end;
        setTimer(function() --[[ Line: 1692 ]]
            if getElementData(localPlayer, "Status") ~= "Spectate" then
                return;
            else
                local v687 = getTacticsData("Restores") or {};
                for __, v689 in ipairs(v687) do
                    if v689[1] == getPlayerName(localPlayer) then
                        outputInfo(string.format(getLanguageString("help_restore"), "R"));
                        return;
                    end;
                end;
                local v690 = getTacticsData("Map");
                if (getTacticsData("modes", v690, "respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
                    outputInfo(string.format(getLanguageString("help_restore"), "R"));
                end;
                return;
            end;
        end, 1000, 1);
    end;
    onClientPlayerRoundRespawn = function() --[[ Line: 1708 ]]
        if not getElementData(localPlayer, "Loading") then
            fadeCamera(true, 2);
        end;
        if respawn_countdown then
            removeEventHandler("onClientPreRender", root, onClientRespawnRender);
            respawn_countdown = nil;
        end;
    end;
    local v691 = {};
    updateWeatherBlend = function() --[[ Line: 1716 ]]
        -- upvalues: v691 (ref)
        v691 = {};
        local v692 = getTacticsData("Weather");
        local v693 = (getTime() + 1) % 24;
        for v694 = v693, v693 + 22 do
            local v695 = v694 % 24;
            if v692[v695] then
                v691[2] = {
                    hour = v695, 
                    wind = {
                        x = v692[v695].wind[1], 
                        y = v692[v695].wind[2], 
                        z = v692[v695].wind[3]
                    }, 
                    rain = v692[v695].rain, 
                    far = v692[v695].far, 
                    fog = v692[v695].fog, 
                    sky = {
                        rt = v692[v695].sky[1], 
                        gt = v692[v695].sky[2], 
                        bt = v692[v695].sky[3], 
                        rb = v692[v695].sky[4], 
                        gb = v692[v695].sky[5], 
                        bb = v692[v695].sky[6]
                    }, 
                    clouds = v692[v695].clouds, 
                    birds = v692[v695].birds, 
                    sun = {
                        rc = v692[v695].sun[1], 
                        gc = v692[v695].sun[2], 
                        bc = v692[v695].sun[3], 
                        rs = v692[v695].sun[4], 
                        gs = v692[v695].sun[5], 
                        bs = v692[v695].sun[6], 
                        size = v692[v695].sunsize
                    }, 
                    water = {
                        r = v692[v695].water[1], 
                        g = v692[v695].water[2], 
                        b = v692[v695].water[3], 
                        a = v692[v695].water[4], 
                        lvl = v692[v695].level, 
                        wave = v692[v695].wave
                    }, 
                    heat = v692[v695].heat, 
                    effect = v692[v695].effect
                };
                break;
            end;
        end;
        v693 = (v693 - 1) % 24;
        for v696 = v693, v693 - 23, -1 do
            local v697 = v696 % 24;
            if v692[v697] then
                v691[1] = {
                    hour = v697, 
                    wind = {
                        x = v692[v697].wind[1], 
                        y = v692[v697].wind[2], 
                        z = v692[v697].wind[3]
                    }, 
                    rain = v692[v697].rain, 
                    far = v692[v697].far, 
                    fog = v692[v697].fog, 
                    sky = {
                        rt = v692[v697].sky[1], 
                        gt = v692[v697].sky[2], 
                        bt = v692[v697].sky[3], 
                        rb = v692[v697].sky[4], 
                        gb = v692[v697].sky[5], 
                        bb = v692[v697].sky[6]
                    }, 
                    clouds = v692[v697].clouds, 
                    birds = v692[v697].birds, 
                    sun = {
                        rc = v692[v697].sun[1], 
                        gc = v692[v697].sun[2], 
                        bc = v692[v697].sun[3], 
                        rs = v692[v697].sun[4], 
                        gs = v692[v697].sun[5], 
                        bs = v692[v697].sun[6], 
                        size = v692[v697].sunsize
                    }, 
                    water = {
                        r = v692[v697].water[1], 
                        g = v692[v697].water[2], 
                        b = v692[v697].water[3], 
                        a = v692[v697].water[4], 
                        lvl = v692[v697].level, 
                        wave = v692[v697].wave
                    }, 
                    heat = v692[v697].heat, 
                    effect = v692[v697].effect
                };
                break;
            end;
        end;
    end;
    local v698 = 0;
    local v699 = 0;
    updateWeather = function(v700) --[[ Line: 1764 ]]
        -- upvalues: v698 (ref), v699 (ref), v691 (ref)
        local v701, v702 = getTime();
        if v698 == v701 and v699 == v702 and not v700 then
            return;
        else
            local l_v701_0 = v701;
            v699 = v702;
            v698 = l_v701_0;
            if #v691 ~= 2 then
                updateWeatherBlend();
            end;
            l_v701_0 = (v701 + v702 / 60 - v691[1].hour) / ((v691[2].hour >= v691[1].hour and v691[2].hour or v691[2].hour + 24) - v691[1].hour);
            if l_v701_0 < 0 or l_v701_0 >= 1 then
                updateWeatherBlend();
                l_v701_0 = (v701 + v702 / 60 - v691[1].hour) / (v691[2].hour - v691[1].hour);
            end;
            local function v706(v704, v705) --[[ Line: 1774 ]]
                -- upvalues: l_v701_0 (ref)
                return v704 + l_v701_0 * (v705 - v704);
            end;
            setWeather(v691[1].effect or 0);
            setWindVelocity(v706(v691[1].wind.x, v691[2].wind.x), v706(v691[1].wind.y, v691[2].wind.y), 0);
            setRainLevel(v706(v691[1].rain, v691[2].rain));
            setFarClipDistance(v706(v691[1].far, v691[2].far));
            setFogDistance(v706(v691[1].fog, v691[2].fog));
            setSkyGradient(v706(v691[1].sky.rt, v691[2].sky.rt), v706(v691[1].sky.gt, v691[2].sky.gt), v706(v691[1].sky.bt, v691[2].sky.bt), v706(v691[1].sky.rb, v691[2].sky.rb), v706(v691[1].sky.gb, v691[2].sky.gb), v706(v691[1].sky.bb, v691[2].sky.bb));
            setCloudsEnabled(v691[1].clouds);
            setBirdsEnabled(v691[1].birds);
            setSunColor(v706(v691[1].sun.rc, v691[2].sun.rc), v706(v691[1].sun.gc, v691[2].sun.gc), v706(v691[1].sun.bc, v691[2].sun.bc), v706(v691[1].sun.rs, v691[2].sun.rs), v706(v691[1].sun.gs, v691[2].sun.gs), v706(v691[1].sun.bs, v691[2].sun.bs));
            setSunSize(v706(v691[1].sun.size, v691[2].sun.size));
            setWaterColor(v706(v691[1].water.r, v691[2].water.r), v706(v691[1].water.g, v691[2].water.g), v706(v691[1].water.b, v691[2].water.b), v706(v691[1].water.a, v691[2].water.a));
            setWaterLevel(v706(v691[1].water.lvl, v691[2].water.lvl), false, false);
            setWaveHeight(v706(v691[1].water.wave, v691[2].water.wave));
            setHeatHaze(v706(v691[1].heat, v691[2].heat), 0, 12, 18, 75, 80, 80, 85, true);
            return;
        end;
    end;
    onClientPlayerVehiclepackGot = function(v707, __, v709) --[[ Line: 1790 ]]
        if getVehicleType(v707) == "Helicopter" then
            setVehicleRotorSpeed(v707, 0.2);
        end;
        if v709 then
            local v710 = getElementDistanceFromCentreOfMassToBaseOfModel(v707);
            local v711, v712, v713 = getElementPosition(v707);
            setElementPosition(v707, v711, v712, v713 + v710 - v709);
        end;
    end;
    getRestoreCount = function() --[[ Line: 1800 ]]
        return #(getTacticsData("Restores") or {});
    end;
    getRestoreData = function(v714) --[[ Line: 1803 ]]
        local v715 = getTacticsData("Restores") or {};
        if not v715[v714] then
            return false;
        else
            local v716, v717, v718, v719, v720, v721, v722, v723, v724, v725, v726, v727, v728, v729, v730, v731, v732, v733, __ = unpack(v715[v714]);
            return {
                name = v716, 
                posX = v725, 
                posY = v726, 
                posZ = v727, 
                rotation = v728, 
                interior = v721, 
                team = v717, 
                skin = v718, 
                health = v719, 
                armour = v720, 
                velocityX = v729, 
                velocityY = v730, 
                velocityZ = v731, 
                onfire = v732, 
                weapons = v722, 
                weaponslot = v723, 
                vehicle = v724, 
                vehicleseat = v733
            };
        end;
    end;
    onClientPlayerRPS = function() --[[ Line: 1826 ]]
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
    addEventHandler("onClientRender", root, function() --[[ Line: 1880 ]]
        if isElementFrozen(localPlayer) then
            setElementVelocity(localPlayer, 0, 0, 0);
        end;
    end);
    addCommandHandler("team_change", forcedChangeTeam, false);
    addCommandHandler("help_me", callHelpme, false);
    addCommandHandler("rsp", forceRespawnPlayer, false);
    addCommandHandler("credits", showCredits, false);
    addCommandHandler("reload", doReloadWeapon, false);
    bindKey("action", "down", function() --[[ Line: 1886 ]]
        setPedControlState("action", false);
    end);
end)();
(function(...) --[[ Line: 0 ]]
    local v735 = 480;
    local v736 = 480;
    local v737 = false;
    local v738 = {};
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
    onClientResourceStart = function(__) --[[ Line: 246 ]]
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
    createAdminPanel = function() --[[ Line: 263 ]]
        -- upvalues: v735 (ref), v736 (ref)
        admin_window = guiCreateWindow(xscreen * 0.5 - v735 * 0.5 - 80, yscreen * 0.5 - v736 * 0.5 - 15, v735 + 160, v736 + 30, "Tactics " .. getTacticsData("version") .. " - Gamemode Control Panel", false);
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
        for v740 in pairs(convertWeaponNamesToID) do
            table.insert(sortWeaponNames, v740);
        end;
        local v741 = {
            [2] = 1, 
            [3] = 2, 
            [4] = 2, 
            [5] = 3, 
            [6] = 3
        };
        table.sort(sortWeaponNames, function(v742, v743) --[[ Line: 490 ]]
            -- upvalues: v741 (ref)
            local v744 = convertWeaponNamesToID[v742] or 46;
            local v745 = convertWeaponNamesToID[v743] or 46;
            local v746 = getSlotFromWeapon(v744);
            local v747 = getSlotFromWeapon(v745);
            local v748 = v741[v746] or 4;
            local v749 = v741[v747] or 4;
            return v748 == v749 and not (v744 >= v745) or v748 < v749;
        end);
        weapons_addnames = guiCreateComboBox(302, 9, 161, 300, sortWeaponNames[1], false, admin_tab_weapons);
        for __, v751 in ipairs(sortWeaponNames) do
            guiComboBoxAddItem(weapons_addnames, v751);
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
        local v752 = {};
        for v753 = 400, 611 do
            if getVehicleNameFromModel(v753) and #getVehicleNameFromModel(v753) > 0 then
                table.insert(v752, getVehicleNameFromModel(v753));
            end;
        end;
        table.sort(v752, function(v754, v755) --[[ Line: 660 ]]
            return v754 < v755;
        end);
        handling_model = guiCreateComboBox(0.02, 0.02, 0.54, 0.85, getVehicleNameFromModel(411), true, admin_tab_handling);
        for __, v757 in ipairs(v752) do
            guiComboBoxAddItem(handling_model, v757);
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
        local v758 = {};
        local v759 = {};
        local v760 = {};
        local v761 = {};
        sirens_minalpha = {};
        sirens_color = v761;
        sirens_zcenter = v760;
        sirens_ycenter = v759;
        sirens_xcenter = v758;
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
        for v762, v763 in ipairs(weatherSAData) do
            guiComboBoxAddItem(weather_default, string.format("[%i] %s", v762 - 1, v763.name));
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
        for v764 = 0, 23 do
            guiComboBoxAddItem(weather_hour, tostring(v764));
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
    createAdminRenameConfig = function() --[[ Line: 1165 ]]
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
    createAdminAddConfig = function() --[[ Line: 1176 ]]
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
    createAdminSaveConfig = function() --[[ Line: 1187 ]]
        save_window = guiCreateWindow(xscreen * 0.5 - 120, yscreen * 0.5 - 130, 240, 260, "Save Config", false);
        guiWindowSetSizable(save_window, false);
        guiSetFont(guiCreateLabel(0.05, 0.1, 0.25, 0.08, "Name", true, save_window), "default-bold-small");
        local v765 = "";
        if isElement(admin_window) then
            local v766 = guiGridListGetSelectedItem(config_list);
            if v766 > -1 then
                v765 = guiGridListGetItemText(config_list, v766, 1);
            end;
        end;
        save_name = guiCreateEdit(0.25, 0.1, 0.75, 0.08, v765, true, save_window);
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
    createAdminScreen = function() --[[ Line: 1228 ]]
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
        local v767 = xmlLoadFile("screenshots/_list.xml");
        if v767 then
            local v768 = nil;
            for __, v770 in ipairs(xmlNodeGetChildren(v767)) do
                v768 = xmlNodeGetAttribute(v770, "src");
                if v768 then
                    if fileExists("screenshots/" .. v768 .. ".jpg") then
                        guiComboBoxAddItem(screen_list, v768);
                    else
                        xmlDestroyNode(v770);
                    end;
                end;
            end;
            if v768 then
                guiSetText(screen_list, v768);
            end;
            xmlSaveFile(v767);
            xmlUnloadFile(v767);
        end;
        guiSetVisible(screen_list, false);
        guiSetFont(screen_save, "default-bold-small");
        guiEditSetReadOnly(screen_name, true);
        guiSetAlpha(screen_menu, 0.2);
        return screen_window;
    end;
    createAdminRedirect = function() --[[ Line: 1263 ]]
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
    createAdminRestore = function() --[[ Line: 1281 ]]
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
    createAdminRules = function() --[[ Line: 1295 ]]
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
    createAdminPalette = function() --[[ Line: 1312 ]]
        palette_window = guiCreateWindow(xscreen * 0.5 - 150, yscreen * 0.5 - 165, 300, 330, "Color Palette", false);
        guiWindowSetSizable(palette_window, false);
        guiSetAlpha(palette_window, 1);
        palette_hue = guiCreateStaticImage(0.05, 0.09, 0.75, 0.65, "images/color_hue.png", true, palette_window);
        palette_color2 = guiCreateStaticImage(0.05, 0.76, 0.25, 0.12, "images/color_pixel.png", true, palette_window);
        palette_color1 = guiCreateStaticImage(0.83, 0.09, 0.1, 0.65, "images/color_pixel.png", true, palette_window);
        palette_light = guiCreateStaticImage(0.83, 0.09, 0.1, 0.65, "images/color_light.png", true, palette_window);
        palette_aim = guiCreateStaticImage(0.03, 0.07, 0.04, 0.04, "images/color_aim.png", true, palette_window);
        palette_aim2 = guiCreateStaticImage(0.93, 0.07, 0.04, 0.04, "images/color_aim2.png", true, palette_window);
        local v771 = 0;
        local v772 = 0;
        local v773 = 0;
        palette_element = nil;
        palette_L = v773;
        palette_S = v772;
        palette_H = v771;
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
    createAdminMods = function() --[[ Line: 1353 ]]
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
    refreshAnticheatSearch = function() --[[ Line: 1370 ]]
        if not isElement(admin_window) then
            return;
        else
            local v774 = getTacticsData("anticheat", "modslist") or {};
            local v775 = guiGridListGetRowCount(anticheat_modslist);
            for v776 = 0, math.max(v775, #v774) do
                if v776 < #v774 then
                    if v775 <= v776 then
                        guiGridListAddRow(anticheat_modslist);
                    end;
                    guiGridListSetItemText(anticheat_modslist, v776, 1, tostring(v774[v776 + 1].name), false, false);
                    guiGridListSetItemText(anticheat_modslist, v776, 2, tostring(v774[v776 + 1].search), false, false);
                    guiGridListSetItemData(anticheat_modslist, v776, 2, tostring(v774[v776 + 1].type));
                else
                    guiGridListRemoveRow(anticheat_modslist, v776);
                end;
            end;
            return;
        end;
    end;
    refreshSettingsConfig = function() --[[ Line: 1385 ]]
        if not isElement(admin_window) then
            return;
        else
            local v777 = guiGridListGetSelectedItem(modes_list);
            local v778 = false;
            if v777 ~= -1 then
                v778 = guiGridListGetItemText(modes_list, v777, 1);
            end;
            guiGridListClear(modes_list);
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Tactics", true, false);
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "settings", false, false);
            if v778 == "settings" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "glitches", false, false);
            if v778 == "glitches" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "cheats", false, false);
            if v778 == "cheats" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "limites", false, false);
            if v778 == "limites" then
                guiGridListSetSelectedItem(modes_list, guiGridListGetRowCount(modes_list) - 1, 1);
            end;
            guiGridListSetItemText(modes_list, guiGridListAddRow(modes_list), 1, "Modes", true, false);
            local v779 = {};
            local l_pairs_0 = pairs;
            local v781 = getTacticsData("modes") or {};
            for v782, v783 in l_pairs_0(v781) do
                table.insert(v779, {v782, v783});
            end;
            table.sort(v779, function(v784, v785) --[[ Line: 1413 ]]
                return v784[1] < v785[1];
            end);
            for __, v787 in ipairs(v779) do
                local v788 = tostring(v787[1]);
                local v789 = v787[2] or {};
                local v790 = guiGridListAddRow(modes_list);
                guiGridListSetItemText(modes_list, v790, 1, v788, false, false);
                if v789.enable == "false" then
                    guiGridListSetItemColor(modes_list, v790, 1, 255, 0, 0);
                end;
                if v778 == v788 then
                    guiGridListSetSelectedItem(modes_list, v790, 1);
                end;
            end;
            triggerEvent("onClientGUIClick", modes_list, "left");
            return;
        end;
    end;
    refreshWeatherConfig = function() --[[ Line: 1427 ]]
        if not isElement(admin_window) then
            return;
        else
            while guiGridListGetColumnCount(weather_record) > 0 do
                guiGridListRemoveColumn(weather_record, 1);
            end;
            local v791 = 0;
            local v792 = getTacticsData("Weather") or {};
            local v793 = getTime();
            for v794 = 0, 23 do
                if v792[v794] then
                    local v795 = guiGridListAddColumn(weather_record, tostring(v794) .. "h", 0.08);
                    guiGridListAddRow(weather_record);
                    guiGridListAddRow(weather_record);
                    guiGridListSetItemText(weather_record, 0, v795, " ", false, false);
                    guiGridListSetItemText(weather_record, 1, v795, " ", false, false);
                    guiGridListSetItemData(weather_record, 1, v795, tostring(v794));
                    if tonumber(v794) <= v793 then
                        v791 = v795;
                    end;
                end;
            end;
            if guiGridListGetSelectedItem(weather_record) < 0 then
                if v791 == 0 then
                    v791 = guiGridListGetColumnCount(weather_record);
                end;
                guiGridListSetSelectedItem(weather_record, 0, v791);
                triggerEvent("onClientGUIDoubleClick", weather_record, "left");
            end;
            return;
        end;
    end;
    refreshConfiglist = function(v796) --[[ Line: 1452 ]]
        if not isElement(admin_window) then
            return;
        else
            guiGridListClear(config_list);
            for __, v798 in ipairs(v796) do
                row = guiGridListAddRow(config_list);
                guiGridListSetItemText(config_list, row, 1, v798[1], false, false);
                guiGridListSetItemData(config_list, row, 1, v798[3]);
                guiGridListSetItemColor(config_list, row, 1, v798[2], 255, v798[2]);
            end;
            return;
        end;
    end;
    updateAdmin = function() --[[ Line: 1462 ]]
        if not isElement(admin_window) then
            return;
        else
            local v799 = {};
            for __, v801 in ipairs(getElementsByType("player")) do
                if not getPlayerTeam(v801) then
                    table.insert(v799, {v801, nil});
                end;
            end;
            for __, v803 in ipairs(getElementsByType("team")) do
                for __, v805 in ipairs(getPlayersInTeam(v803)) do
                    table.insert(v799, {v805, v803});
                end;
            end;
            local v806 = guiGridListGetRowCount(player_list);
            local v807 = {};
            for __, v809 in ipairs(guiGridListGetSelectedItems(player_list)) do
                if v809.column == player_id then
                    v807[guiGridListGetItemText(player_list, v809.row, player_id)] = true;
                end;
            end;
            guiGridListSetSelectedItem(player_list, 0, 0);
            for v810 = 0, math.max(v806, #v799) do
                if v810 < #v799 then
                    local v811 = v799[v810 + 1][1];
                    local v812 = v799[v810 + 1][2];
                    if v806 <= v810 then
                        guiGridListAddRow(player_list);
                    end;
                    --guiGridListSetItemText(player_list, v810, player_id, getElementID(v811), false, false);
                    guiGridListSetItemText(player_list, v810, player_id, tostring(getElementID(v811)), false, false)
                    if v807[getElementID(v811)] then
                        guiGridListSetSelectedItem(player_list, v810, player_id, false);
                    end;
                    guiGridListSetItemText(player_list, v810, player_name, removeColorCoding(getPlayerName(v811)), false, false);
                    if not v812 then
                        guiGridListSetItemColor(player_list, v810, player_name, 255, 255, 255);
                    else
                        guiGridListSetItemColor(player_list, v810, player_name, getTeamColor(v812));
                    end;
                    local v813 = getElementData(v811, "Status") or "";
                    if v813 == "Play" and getTacticsData("settings", "player_information") == "true" then
                        v813 = tostring(math.floor(getElementHealth(v811) + getPedArmor(v811)));
                    end;
                    if v813 == "Spectate" then
                        v813 = "";
                    end;
                    guiGridListSetItemText(player_list, v810, player_status, v813, false, false);
                else
                    guiGridListRemoveRow(player_list, #v799);
                end;
            end;
            local v814 = guiGridListGetSelectedItems(player_list);
            if #v814 == 3 then
                local v815 = getElementByID(guiGridListGetItemText(player_list, v814[1].row, player_id));
                if v815 and isElement(v815) then
                    local v816 = "Nickname: " .. getPlayerName(v815) .. "\nSerial: " .. tostring(getElementData(v815, "Serial")) .. "\nIP: " .. tostring(getElementData(v815, "IP")) .. "\nVersion: " .. tostring(getElementData(v815, "Version")) .. "\n";
                    if guiGetText(player_info) ~= v816 then
                        guiSetText(player_info, v816);
                    end;
                    if getElementData(v815, "Status") == "Play" then
                        if guiGetText(player_add) ~= "Remove" then
                            guiSetText(player_add, "Remove");
                        end;
                    elseif guiGetText(player_add) ~= "Add" then
                        guiSetText(player_add, "Add");
                    end;
                    guiCheckBoxSetSelected(player_specskin, getElementData(v815, "spectateskin") and true or false);
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
            local v817, v818 = isRoundPaused();
            if v817 then
                if v818 then
                    guiSetText(player_pause, "Unpause ... " .. string.format("%.0f", v818 / 1000));
                else
                    guiSetText(player_pause, "Unpause");
                end;
                guiSetProperty(player_pause, "NormalTextColour", "C00080FF");
            end;
            return;
        end;
    end;
    refreshCyclerResources = function() --[[ Line: 1534 ]]
        if not isElement(admin_window) then
            return;
        else
            local v819 = getTacticsData("Resources");
            if v819 and #v819 > 0 then
                local v820 = getTacticsData("ResourceCurrent");
                local v821 = guiGridListGetRowCount(server_cycler);
                for v822 = 1, math.max(v821, #v819) do
                    if v822 <= #v819 then
                        local v823 = v819[v822][1];
                        local v824 = v819[v822][2];
                        local v825 = v819[v822][3];
                        if v821 < v822 then
                            guiGridListAddRow(server_cycler);
                        end;
                        guiGridListSetItemText(server_cycler, v822 - 1, 1, tostring(v822), true, false);
                        guiGridListSetItemText(server_cycler, v822 - 1, 2, v824, false, false);
                        guiGridListSetItemData(server_cycler, v822 - 1, 2, v823);
                        guiGridListSetItemText(server_cycler, v822 - 1, 3, v825, false, false);
                        if v820 == v822 then
                            guiGridListSetItemColor(server_cycler, v822 - 1, 1, 255, 40, 0);
                            guiGridListSetItemColor(server_cycler, v822 - 1, 2, 255, 40, 0);
                            guiGridListSetItemColor(server_cycler, v822 - 1, 3, 255, 40, 0);
                        else
                            guiGridListSetItemColor(server_cycler, v822 - 1, 1, 255, 255, 255);
                            guiGridListSetItemColor(server_cycler, v822 - 1, 2, 255, 255, 255);
                            guiGridListSetItemColor(server_cycler, v822 - 1, 3, 255, 255, 255);
                        end;
                    else
                        guiGridListRemoveRow(server_cycler, #v819);
                    end;
                end;
            else
                guiGridListClear(server_cycler);
            end;
            return;
        end;
    end;
    refreshRestores = function() --[[ Line: 1565 ]]
        if not isElement(restore_window) then
            return;
        else
            guiGridListClear(restore_list);
            local v826 = getTacticsData("Restores");
            if not v826 then
                return;
            else
                for __, v828 in ipairs(v826) do
                    local v829 = guiGridListAddRow(restore_list);
                    guiGridListSetItemText(restore_list, v829, restore_name, tostring(v828[1]), false, false);
                    guiGridListSetItemText(restore_list, v829, restore_team, getTeamName(v828[2]), false, false);
                end;
                return;
            end;
        end;
    end;
    refreshTeamConfig = function() --[[ Line: 1576 ]]
        if not isElement(admin_window) then
            return;
        else
            for v830, v831 in ipairs(teams_teams) do
                destroyElement(v831.name);
                destroyElement(v831.color);
                if v830 > 1 then
                    destroyElement(v831.side);
                    destroyElement(v831.skin);
                    destroyElement(v831.score);
                    destroyElement(v831.remove);
                end;
                teams_teams[v830] = nil;
            end;
            teams_teams = {};
            local v832 = 0;
            local v833 = getElementsByType("team");
            for v834, v835 in ipairs(v833) do
                local v836 = nil;
                local v837 = nil;
                local v838 = nil;
                local v839 = nil;
                local v840 = guiCreateEdit(53, v832 * 25, 120, 21, getTeamName(v835), false, teams_scroller);
                if v834 > 1 then
                    local v841 = getElementData(v835, "Side") or v834;
                    v836 = guiCreateEdit(8, v832 * 25, 40, 21, tostring(v841), false, teams_scroller);
                    guiEditSetReadOnly(v836, true);
                    guiSetProperty(v836, "WantsMultiClickEvents", "False");
                    if v833[v841 + 1] then
                        guiSetProperty(v836, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(v833[v841 + 1])));
                    end;
                    local v842 = "";
                    local l_ipairs_0 = ipairs;
                    local v844 = getElementData(v835, "Skins") or {};
                    for v845, v846 in l_ipairs_0(v844) do
                        if v845 > 1 then
                            v842 = v842 .. "," .. tostring(v846);
                        else
                            v842 = tostring(v846);
                        end;
                    end;
                    v837 = guiCreateEdit(178, v832 * 25, 80, 21, tostring(v842), false, teams_scroller);
                    l_ipairs_0 = getElementData(v835, "Score") or 0;
                    v838 = guiCreateEdit(263, v832 * 25, 50, 21, tostring(l_ipairs_0), false, teams_scroller);
                end;
                local v847 = guiCreateEdit(318, v832 * 25, 50, 21, "", false, teams_scroller);
                guiEditSetReadOnly(v847, true);
                guiSetProperty(v847, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(v835)));
                if v834 > 1 then
                    v839 = guiCreateButton(373, v832 * 25, 70, 21, "Remove", false, teams_scroller);
                    guiSetFont(v839, "default-bold-small");
                    guiSetProperty(v839, "NormalTextColour", "C0FF0000");
                end;
                if v834 > 1 then
                    table.insert(teams_teams, {name = v840, color = v847, side = v836, skin = v837, score = v838, remove = v839});
                else
                    table.insert(teams_teams, {name = v840, color = v847});
                end;
                v832 = v832 + 1;
            end;
            guiSetPosition(teams_apply, 298, v832 * 25, false);
            guiSetPosition(teams_addteam, 373, v832 * 25, false);
            return;
        end;
    end;
    refreshVehicleConfig = function() --[[ Line: 1629 ]]
        if not isElement(admin_window) then
            return;
        else
            local v848 = {};
            local v849 = {};
            local v850 = getTacticsData("disabled_vehicles") or {};
            for v851 = 400, 611 do
                if #getVehicleNameFromModel(v851) > 0 then
                    if v850[v851] then
                        table.insert(v849, {v851, getVehicleNameFromModel(v851)});
                    else table.insert(v848, {v851, getVehicleNameFromModel(v851)});
                    end;
                end;
            end;
            table.sort(v848, function(v852, v853) --[[ Line: 1643 ]]
                return v852[2] < v853[2];
            end);
            table.sort(v849, function(v854, v855) --[[ Line: 1644 ]]
                return v854[2] < v855[2];
            end);
            local v856 = guiGridListGetRowCount(vehicles_disabled);
            local v857 = guiGridListGetRowCount(vehicles_enabled);
            for v858 = 0, math.max(#v849, v856) do
                if v858 < #v849 then
                    local v859, v860 = unpack(v849[v858 + 1]);
                    if v858 < v856 then
                        guiGridListSetItemText(vehicles_disabled, v858, 1, v860, false, false);
                        guiGridListSetItemData(vehicles_disabled, v858, 1, tostring(v859));
                    else
                        local v861 = guiGridListAddRow(vehicles_disabled);
                        guiGridListSetItemText(vehicles_disabled, v861, 1, v860, false, false);
                        guiGridListSetItemData(vehicles_disabled, v861, 1, tostring(v859));
                        guiGridListSetItemColor(vehicles_disabled, v861, 1, 255, 0, 0);
                    end;
                else
                    guiGridListRemoveRow(vehicles_disabled, #v849);
                end;
            end;
            for v862 = 0, math.max(#v848, v857) do
                if v862 < #v848 then
                    local v863, v864 = unpack(v848[v862 + 1]);
                    if v862 < v857 then
                        guiGridListSetItemText(vehicles_enabled, v862, 1, v864, false, false);
                        guiGridListSetItemData(vehicles_enabled, v862, 1, tostring(v863));
                    else
                        local v865 = guiGridListAddRow(vehicles_enabled);
                        guiGridListSetItemText(vehicles_enabled, v865, 1, v864, false, false);
                        guiGridListSetItemData(vehicles_enabled, v865, 1, tostring(v863));
                        guiGridListSetItemColor(vehicles_enabled, v865, 1, 0, 255, 0);
                    end;
                else
                    guiGridListRemoveRow(vehicles_enabled, #v848);
                end;
            end;
            return;
        end;
    end;
    toggleAdmin = function() --[[ Line: 1680 ]]
        -- upvalues: v737 (ref)
        if guiGetInputEnabled() then
            return;
        else
            if not isElement(admin_window) or not guiGetVisible(admin_window) then
                callServerFunction("showAdminPanel", localPlayer);
            else
                if isTimer(v737) then
                    killTimer(v737);
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
    showClientAdminPanel = function(v866) --[[ Line: 1712 ]]
        -- upvalues: v737 (ref)
        if not isElement(admin_window) or not guiGetVisible(admin_window) then
            if not isElement(admin_window) then
                createAdminPanel();
            end;
            callServerFunction("refreshConfiglist", localPlayer);
            if isTimer(v737) then
                killTimer(v737);
            end;
            v737 = setTimer(updateAdmin, 500, 0);
            guiSetEnabled(config_list, v866.configs);
            guiSetEnabled(config_delete, v866.configs);
            guiSetEnabled(config_save, v866.configs);
            guiSetEnabled(config_rename, v866.configs);
            guiSetEnabled(config_add, v866.configs);
            guiSetEnabled(admin_tab_players, v866.tab_players);
            guiSetEnabled(admin_tab_maps, v866.tab_maps);
            guiSetEnabled(admin_tab_settings, v866.tab_settings);
            guiSetEnabled(admin_tab_teams, v866.tab_teams);
            guiSetEnabled(admin_tab_weapons, v866.tab_weapons);
            guiSetEnabled(admin_tab_vehicles, v866.tab_vehicles);
            guiSetEnabled(admin_tab_weather, v866.tab_weather);
            guiSetEnabled(admin_tab_shooting, v866.tab_shooting);
            guiSetEnabled(admin_tab_handling, v866.tab_handling);
            guiSetEnabled(admin_tab_anticheat, v866.tab_anticheat);
            guiBringToFront(admin_window);
            guiSetVisible(admin_window, true);
            showCursor(true);
        end;
    end;
    onClientGUIAccepted = function(__) --[[ Line: 1738 ]]
        if source == rules_edit then
            triggerEvent("onClientGUIClick", rules_ok, "left", "up");
        end;
    end;
    onClientGUIScroll = function(__) --[[ Line: 1743 ]]
        if source == wind_slide then
            local v869 = guiScrollBarGetScrollPosition(wind_slide);
            guiSetText(wind_speed, string.format("%.1f", 0.5 * v869));
        end;
        if source == rain_slide then
            local v870 = guiScrollBarGetScrollPosition(rain_slide);
            guiSetText(rain_level, string.format("%.1f", 0.02 * v870));
        end;
        if source == sun_sizeslide then
            local v871 = guiScrollBarGetScrollPosition(sun_sizeslide);
            guiSetText(sun_size, string.format("%.1f", 0.5 * v871));
        end;
        if source == farclip_slide then
            local v872 = guiScrollBarGetScrollPosition(farclip_slide);
            guiSetText(farclip_distance, string.format("%.1f", 30 * v872));
        end;
        if source == fog_slide then
            local v873 = guiScrollBarGetScrollPosition(fog_slide);
            guiSetText(fog_distance, string.format("%.1f", 40 * v873 - 1000));
        end;
        if source == heat_levelslide then
            local v874 = guiScrollBarGetScrollPosition(heat_levelslide);
            guiSetText(heat_level, string.format("%.1f", 2.55 * v874));
        end;
        if source == wave_heightslide then
            local v875 = guiScrollBarGetScrollPosition(wave_heightslide);
            guiSetText(wave_height, string.format("%.1f", 0.1 * v875));
        end;
        if source == water_levelslide then
            local v876 = guiScrollBarGetScrollPosition(water_levelslide);
            guiSetText(water_level, string.format("%.1f", 4 * v876 - 200));
        end;
    end;
    onClientGUIClick = function(v877, __, __, __) --[[ Line: 1777 ]]
        -- upvalues: v738 (ref)
        if isElement(admin_window) and guiGetVisible(player_list) then
            v738 = {};
            local v881 = guiGridListGetSelectedItems(player_list);
            if v881 then
                for __, v883 in ipairs(v881) do
                    if v883.column == player_id then
                        local v884 = getElementByID(tostring(guiGridListGetItemText(player_list, v883.row, player_id)));
                        if v884 == localPlayer then
                            table.insert(v738, v884);
                        else
                            table.insert(v738, 1, v884);
                        end;
                    end;
                end;
            end;
            if #v738 == 0 then
                v738 = nil;
            end;
        end;
        if source == rules_time_up or source == rules_time_down then
            local v885 = guiGetText(rules_time);
            local v886 = tonumber(guiGetProperty(rules_time, "CaratIndex"));
            local v887 = gettok(v885, 1, string.byte("."));
            local v888 = tonumber(gettok(v887, 1, string.byte(":"))) or 0;
            local v889 = tonumber(gettok(v887, 2, string.byte(":"))) or 0;
            local v890 = tonumber(gettok(v887, 3, string.byte(":"))) or 0;
            local v891 = tonumber(gettok(v885, 2, string.byte("."))) or 0;
            if v886 < 3 then
                if source == rules_time_up then
                    v888 = (v888 + 1) % 24;
                else
                    v888 = (v888 - 1) % 24;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v888, v889, v890, v891));
                guiEditSetCaretIndex(rules_time, 2);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            elseif v886 < 6 then
                if source == rules_time_up then
                    v889 = (v889 + 1) % 60;
                else
                    v889 = (v889 - 1) % 60;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v888, v889, v890, v891));
                guiEditSetCaretIndex(rules_time, 5);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            elseif v886 < 9 then
                if source == rules_time_up then
                    v890 = (v890 + 1) % 60;
                else
                    v890 = (v890 - 1) % 60;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v888, v889, v890, v891));
                guiEditSetCaretIndex(rules_time, 8);
                guiSetProperty(rules_time, "SelectionLength", "-2");
            else
                if source == rules_time_up then
                    v891 = (v891 + 1) % 10;
                else
                    v891 = (v891 - 1) % 10;
                end;
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v888, v889, v890, v891));
                guiEditSetCaretIndex(rules_time, 10);
                guiSetProperty(rules_time, "SelectionLength", "-1");
            end;
            guiBringToFront(rules_time);
        end;
        if v877 ~= "left" and isElement(admin_window) and guiGetVisible(admin_tab_teams) then
            for __, v893 in ipairs(teams_teams) do
                if source == v893.side then
                    local v894 = getElementsByType("team");
                    table.remove(v894, 1);
                    local v895 = tonumber(guiGetText(source));
                    v895 = v895 <= 1 and #v894 or v895 - 1;
                    guiSetText(source, tostring(v895));
                    guiSetProperty(source, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(v894[v895])));
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
            if not v738 then
                return;
            else
                local v896 = getTeamFromName(guiGetText(player_setteam));
                for __, v898 in ipairs(v738) do
                    triggerServerEvent("onPlayerTeamSelect", v898, v896, true);
                end;
                return;
            end;
        elseif source == player_balance then
            callServerFunction("balanceTeams", localPlayer);
            return;
        elseif source == player_specskinbtn then
            if not v738 or #v738 > 1 then
                return;
            else
                guiCheckBoxSetSelected(player_specskin, not guiCheckBoxGetSelected(player_specskin));
                callServerFunction("setElementData", v738[1], "spectateskin", guiCheckBoxGetSelected(player_specskin));
                return;
            end;
        elseif source == player_specskin then
            if not v738 or #v738 > 1 then
                return;
            else
                callServerFunction("setElementData", v738[1], "spectateskin", guiCheckBoxGetSelected(player_specskin));
                return;
            end;
        elseif source == player_heal then
            if not v738 then
                return;
            else
                for __, v900 in ipairs(v738) do
                    callServerFunction("setElementHealth", v900, 200);
                    callServerFunction("callClientFunction", root, "outputLangString", "player_healed", getPlayerName(v900));
                end;
                return;
            end;
        elseif source == player_fix then
            if not v738 then
                return;
            else
                for __, v902 in ipairs(v738) do
                    local v903 = getPedOccupiedVehicle(v902);
                    if v903 then
                        callServerFunction("fixVehicle", v903);
                        callServerFunction("callClientFunction", root, "outputLangString", "vehicle_healed", getPlayerName(v902));
                    end;
                end;
                return;
            end;
        elseif source == player_healall then
            for __, v905 in ipairs(getElementsByType("player")) do
                callServerFunction("setElementHealth", v905, 1000);
            end;
            callServerFunction("callClientFunction", root, "outputLangString", "player_all_healed");
            return;
        elseif source == player_fixall then
            for __, v907 in ipairs(getElementsByType("player")) do
                local v908 = getPedOccupiedVehicle(v907);
                if v908 then
                    callServerFunction("fixVehicle", v908);
                end;
            end;
            callServerFunction("callClientFunction", root, "outputLangString", "vehicle_all_healed");
            return;
        elseif source == player_swapsides then
            callServerFunction("swapTeams");
            callServerFunction("callClientFunction", root, "outputLangString", "team_swaped");
            return;
        elseif source == player_add then
            if not v738 then
                return;
            else
                for __, v910 in ipairs(v738) do
                    if getPlayerTeam(v910) and getPlayerTeam(v910) ~= getElementsByType("team")[1] and not getElementData(v910, "Loading") then
                        if getElementData(v910, "Status") == "Play" then
                            callServerFunction("removePlayer", localPlayer, "", getElementID(v910));
                        else
                            callServerFunction("addPlayer", localPlayer, "", getElementID(v910));
                        end;
                    end;
                end;
                return;
            end;
        elseif source == player_restore then
            if not v738 or #v738 > 1 then
                return;
            else
                callServerFunction("restorePlayer", localPlayer, "", getElementID(v738[1]));
                return;
            end;
        elseif source == restore_yes then
            local v911 = guiGridListGetSelectedItem(restore_list);
            if v911 == -1 then
                return;
            else
                callServerFunction("restorePlayerLoad", restore_player, v911 + 1);
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
            if not v738 then
                return;
            else
                for __, v913 in ipairs(v738) do
                    callServerFunction("setElementData", v913, "Weapons", true);
                    callServerFunction("callClientFunction", root, "outputLangString", "player_can_weapon_choice", getPlayerName(v913));
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
            local v914 = guiGridListGetSelectedItems(server_maps);
            if #v914 ~= 2 then
                return;
            else
                local v915 = guiGridListGetItemData(server_maps, v914[1].row, 1);
                callServerFunction("setNextMap", tostring(v915));
                return;
            end;
        elseif source == maps_cancelnext then
            callServerFunction("cancelNextMap");
            return;
        elseif source == maps_switch then
            local v916 = guiGridListGetSelectedItems(server_maps);
            if not v916 then
                return;
            else
                local v917 = getTacticsData("Resources") or {};
                local v918 = 1;
                for __, v920 in ipairs(v916) do
                    if v920.column == 1 then
                        local v921 = guiGridListGetItemData(server_maps, v920.row, 1);
                        local v922 = guiGridListGetItemText(server_maps, v920.row, 1);
                        local v923 = guiGridListGetItemText(server_maps, v920.row, 2);
                        local v924 = guiGridListGetSelectedItems(server_cycler);
                        if #v924 == 2 then
                            table.insert(v917, v924[1].row + v918, {v921, v922, v923});
                        else
                            table.insert(v917, {v921, v922, v923});
                        end;
                        v918 = v918 + 1;
                    end;
                end;
                setTacticsData(v917, "Resources");
                return;
            end;
        elseif source == maps_disable then
            local v925 = guiGridListGetSelectedItems(server_maps);
            if not v925 then
                return;
            else
                local v926 = getTacticsData("map_disabled") or {};
                local __ = 1;
                for __, v929 in ipairs(v925) do
                    if v929.column == 1 then
                        local v930 = guiGridListGetItemData(server_maps, v929.row, 1);
                        local v931 = guiGridListGetItemText(server_maps, v929.row, 1);
                        if #v930 > #v931 then
                            local __ = guiGridListGetItemColor(server_maps, v929.row, 1);
                            if not v926[v930] then
                                v926[v930] = true;
                            else
                                v926[v930] = nil;
                            end;
                        end;
                    end;
                end;
                setTacticsData(v926, "map_disabled");
                return;
            end;
        elseif source == maps_end then
            callServerFunction("onRoundStop", localPlayer);
            return;
        elseif source == cycler_switch then
            local v933 = guiGridListGetSelectedItems(server_cycler);
            if not v933 then
                return;
            else
                local v934 = getTacticsData("Resources") or {};
                local v935 = 1;
                for __, v937 in ipairs(v933) do
                    if v937.column == 1 then
                        table.remove(v934, v937.row + v935);
                        v935 = v935 - 1;
                    end;
                end;
                setTacticsData(v934, "Resources");
                return;
            end;
        elseif source == cycler_moveup then
            local v938 = guiGridListGetSelectedItem(server_cycler);
            if v938 and v938 > 0 then
                local v939 = getTacticsData("Resources") or {};
                local v940 = v939[v938 + 1];
                if v940 then
                    table.remove(v939, v938 + 1);
                    table.insert(v939, v938, v940);
                    setTacticsData(v939, "Resources");
                    guiGridListSetSelectedItem(server_cycler, v938 - 1, 2);
                end;
            end;
            return;
        elseif source == cycler_movedown then
            local v941 = guiGridListGetSelectedItem(server_cycler);
            if v941 > -1 then
                local v942 = getTacticsData("Resources") or {};
                if v941 + 1 < #v942 then
                    local v943 = v942[v941 + 1];
                    if v943 then
                        table.remove(v942, v941 + 1);
                        table.insert(v942, v941 + 2, v943);
                        setTacticsData(v942, "Resources");
                        guiGridListSetSelectedItem(server_cycler, v941 + 1, 2);
                    end;
                end;
            end;
            return;
        elseif source == cycler_clear then
            setTacticsData({}, "Resources");
            return;
        elseif source == cycler_randomize then
            local v944 = getTacticsData("Resources") or {};
            local v945 = {};
            while #v944 > 0 do
                local v946 = math.random(#v944);
                table.insert(v945, v944[v946]);
                table.remove(v944, v946);
            end;
            setTacticsData(v945, "Resources");
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
            if not v738 then
                return;
            else
                local v947 = nil;
                local v948 = nil;
                local v949 = nil;
                if not guiCheckBoxGetSelected(redirect_reconnect) then
                    v947 = guiGetText(redirect_ip);
                    v948 = guiGetText(redirect_port);
                    v949 = guiGetText(redirect_password);
                    if #v949 == 0 then
                        v949 = false;
                    end;
                end;
                callServerFunction("connectPlayers", localPlayer, v738, v947, v948, v949);
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
                for v950, v951 in ipairs(teams_teams) do
                    if source == v951.side then
                        local v952 = getElementsByType("team");
                        table.remove(v952, 1);
                        local v953 = tonumber(guiGetText(source));
                        v953 = #v952 <= v953 and 1 or v953 + 1;
                        guiSetText(source, tostring(v953));
                        guiSetProperty(source, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", getTeamColor(v952[v953])));
                        return;
                    elseif source == v951.color then
                        if not isElement(palette_window) then
                            createAdminPalette();
                        end;
                        palette_element = source;
                        local v954 = guiGetProperty(source, "ReadOnlyBGColour");
                        local v955, v956, v957 = getColorFromString("#" .. string.sub(v954, 3, -1));
                        guiSetText(palette_rr, tostring(v955));
                        guiSetText(palette_gg, tostring(v956));
                        guiSetText(palette_bb, tostring(v957));
                        guiBringToFront(palette_window);
                        guiSetVisible(palette_window, true);
                        return;
                    elseif source == v951.remove then
                        local v958 = getElementsByType("team");
                        callServerFunction("removeServerTeam", v958[v950]);
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
                local v959 = {};
                for v960, __ in ipairs(getElementsByType("team")) do
                    local v962 = {};
                    if v960 > 1 then
                        v962.side = guiGetText(teams_teams[v960].side);
                        v962.skin = guiGetText(teams_teams[v960].skin);
                        v962.score = tonumber(guiGetText(teams_teams[v960].score));
                    end;
                    v962.name = guiGetText(teams_teams[v960].name);
                    local v963 = guiGetProperty(teams_teams[v960].color, "ReadOnlyBGColour");
                    local v964, v965, v966, v967 = getColorFromString("#" .. v963);
                    v962.bb = v967;
                    v962.gg = v966;
                    v962.rr = v965;
                    _ = v964;
                    table.insert(v959, v962);
                end;
                callServerFunction("saveTeamsConfig", v959);
                return;
            elseif source == teams_addteam then
                callServerFunction("addServerTeam");
                callServerFunction("callClientFunction", root, "refreshTeamConfig");
                return;
            elseif source == vehicles_enable then
                local v968 = guiGridListGetSelectedItems(vehicles_disabled);
                if not v968 then
                    return;
                else
                    local v969 = getTacticsData("disabled_vehicles") or {};
                    for __, v971 in ipairs(v968) do
                        v969[tonumber(guiGridListGetItemData(vehicles_disabled, v971.row, 1))] = nil;
                    end;
                    setTacticsData(v969, "disabled_vehicles");
                    return;
                end;
            elseif source == vehicles_disable then
                local v972 = guiGridListGetSelectedItems(vehicles_enabled);
                if not v972 then
                    return;
                else
                    local v973 = getTacticsData("disabled_vehicles") or {};
                    for __, v975 in ipairs(v972) do
                        v973[tonumber(guiGridListGetItemData(vehicles_enabled, v975.row, 1))] = true;
                    end;
                    setTacticsData(v973, "disabled_vehicles");
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
                    local v976 = guiGridListGetSelectedItem(config_list);
                    if v976 == -1 then
                        return;
                    else
                        local v977 = guiGridListGetItemText(config_list, v976, 1);
                        if v977 == "_default" then
                            return outputChatBox("Not available", 255, 0, 0);
                        else
                            if not isElement(rename_window) then
                                createAdminRenameConfig();
                            end;
                            guiSetText(rename_name, v977);
                            guiBringToFront(rename_window);
                            guiSetVisible(rename_window, true);
                            return;
                        end;
                    end;
                end;
            elseif source == rename_ok then
                local v978 = guiGridListGetSelectedItem(config_list);
                if v978 == -1 then
                    return;
                else
                    local v979 = guiGridListGetItemText(config_list, v978, 1);
                    if v979 == "_default" then
                        return outputChatBox("Not available", 255, 0, 0);
                    else
                        local v980 = guiGetText(rename_name);
                        if #v980 == 0 or not v980 then
                            return;
                        else
                            callServerFunction("renameConfig", v979, v980, localPlayer);
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
                local v981 = guiGetText(add_name);
                if #v981 == 0 or not v981 then
                    return;
                else
                    callServerFunction("addConfig", v981, localPlayer);
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
                local v982 = guiGetText(save_name);
                if #v982 == 0 or not v982 then
                    return;
                elseif v982 == "_default" then
                    return outputChatBox("Not available", 255, 0, 0);
                else
                    local v983 = {};
                    if guiCheckBoxGetSelected(save_all) then
                        v983 = {
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
                        v983 = {
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
                        v983.Shooting = false;
                        v983.Handling = false;
                        v983.AC = false;
                    end;
                    callServerFunction("saveConfig", v982, localPlayer, v983);
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
                local v984 = guiGridListGetSelectedItem(config_list);
                if v984 == -1 then
                    return;
                else
                    local v985 = guiGridListGetItemText(config_list, v984, 1);
                    if v985 == "_default" then
                        return outputChatBox("Not available", 255, 0, 0);
                    else
                        callServerFunction("deleteConfig", v985, localPlayer);
                        return;
                    end;
                end;
            elseif source == config_list then
                local v986 = guiGridListGetSelectedItem(config_list);
                if v986 == -1 then
                    guiSetText(config_flags, "");
                    return;
                else
                    local v987 = guiGridListGetItemText(config_list, v986, 1);
                    local v988 = guiGridListGetItemData(config_list, v986, 1);
                    if isElement(save_window) then
                        guiSetText(save_name, v987);
                    end;
                    guiSetText(config_flags, v988);
                    return;
                end;
            elseif source == modes_list then
                local v989 = guiGridListGetSelectedItem(modes_list);
                if v989 == -1 then
                    return guiGridListClear(modes_rules);
                else
                    local v990 = guiGridListGetItemText(modes_list, v989, 1);
                    local v991 = {};
                    if v990 == "settings" then
                        local l_pairs_1 = pairs;
                        local v993 = getTacticsData("settings") or {};
                        for v994, v995 in l_pairs_1(v993) do
                            local v996 = string.find(tostring(v995), "|");
                            if v996 then
                                table.insert(v991, {v994, string.sub(v995, 1, v996 - 1), v995});
                            else
                                table.insert(v991, {v994, v995, v995});
                            end;
                        end;
                    elseif v990 == "glitches" then
                        local l_pairs_2 = pairs;
                        local v998 = getTacticsData("glitches") or {};
                        for v999, v1000 in l_pairs_2(v998) do
                            local v1001 = string.find(tostring(v1000), "|");
                            if v1001 then
                                table.insert(v991, {v999, string.sub(v1000, 1, v1001 - 1), v1000});
                            else
                                table.insert(v991, {v999, v1000, v1000});
                            end;
                        end;
                    elseif v990 == "cheats" then
                        local l_pairs_3 = pairs;
                        local v1003 = getTacticsData("cheats") or {};
                        for v1004, v1005 in l_pairs_3(v1003) do
                            local v1006 = string.find(tostring(v1005), "|");
                            if v1006 then
                                table.insert(v991, {v1004, string.sub(v1005, 1, v1006 - 1), v1005});
                            else
                                table.insert(v991, {v1004, v1005, v1005});
                            end;
                        end;
                    elseif v990 == "limites" then
                        local l_pairs_4 = pairs;
                        local v1008 = getTacticsData("limites") or {};
                        for v1009, v1010 in l_pairs_4(v1008) do
                            local v1011 = string.find(tostring(v1010), "|");
                            if v1011 then
                                table.insert(v991, {v1009, string.sub(v1010, 1, v1011 - 1), v1010});
                            else
                                table.insert(v991, {v1009, v1010, v1010});
                            end;
                        end;
                    else
                        local l_pairs_5 = pairs;
                        local v1013 = getTacticsData("modes", v990) or {};
                        for v1014, v1015 in l_pairs_5(v1013) do
                            if v1014 ~= "name" then
                                local v1016 = string.find(tostring(v1015), "|");
                                if v1016 then
                                    table.insert(v991, {v1014, string.sub(v1015, 1, v1016 - 1), v1015});
                                else
                                    table.insert(v991, {v1014, v1015, v1015});
                                end;
                            end;
                        end;
                    end;
                    table.sort(v991, function(v1017, v1018) --[[ Line: 2450 ]]
                        return v1017[1] < v1018[1];
                    end);
                    local v1019 = guiGridListGetRowCount(modes_rules);
                    for v1020 = 0, math.max(v1019, #v991) do
                        if v1020 < #v991 then
                            local v1021 = tostring(v991[v1020 + 1][1]);
                            local v1022 = tostring(v991[v1020 + 1][2]);
                            local v1023 = tostring(v991[v1020 + 1][3]);
                            if v1020 < v1019 then
                                guiGridListSetItemText(modes_rules, v1020, 1, v1021, false, false);
                                guiGridListSetItemText(modes_rules, v1020, 2, v1022, false, false);
                                guiGridListSetItemData(modes_rules, v1020, 2, v1023);
                                if v1022 == "true" then
                                    guiGridListSetItemColor(modes_rules, v1020, 2, 0, 255, 0);
                                elseif v1022 == "false" then
                                    guiGridListSetItemColor(modes_rules, v1020, 2, 255, 0, 0);
                                elseif v1022 ~= v1023 then
                                    guiGridListSetItemColor(modes_rules, v1020, 2, 255, 255, 0);
                                else
                                    guiGridListSetItemColor(modes_rules, v1020, 2, 255, 255, 255);
                                end;
                            else
                                local v1024 = guiGridListAddRow(modes_rules);
                                guiGridListSetItemText(modes_rules, v1024, 1, v1021, false, false);
                                guiGridListSetItemText(modes_rules, v1024, 2, v1022, false, false);
                                guiGridListSetItemData(modes_rules, v1024, 2, v1023);
                                if v1022 == "true" then
                                    guiGridListSetItemColor(modes_rules, v1024, 2, 0, 255, 0);
                                elseif v1022 == "false" then
                                    guiGridListSetItemColor(modes_rules, v1024, 2, 255, 0, 0);
                                elseif v1022 ~= v1023 then
                                    guiGridListSetItemColor(modes_rules, v1024, 2, 255, 255, 0);
                                else
                                    guiGridListSetItemColor(modes_rules, v1024, 2, 255, 255, 255);
                                end;
                            end;
                        else
                            guiGridListRemoveRow(modes_rules, #v991, 1);
                        end;
                    end;
                    return;
                end;
            elseif source == rules_ok then
                local v1025 = guiGridListGetSelectedItem(modes_list);
                local v1026 = guiGridListGetSelectedItem(modes_rules);
                local v1027 = nil;
                if guiGetVisible(rules_edit) then
                    v1027 = guiGetText(rules_edit);
                    if getDataType(v1027) ~= "string" then
                        v1027 = nil;
                    end;
                elseif guiGetVisible(rules_list) then
                    local v1028 = guiGridListGetSelectedItem(rules_list);
                    if v1028 > -1 then
                        v1027 = guiGridListGetItemText(rules_list, v1028, 1);
                    end;
                elseif guiGetVisible(rules_time) then
                    local v1029 = guiGetText(rules_time);
                    local v1030 = tonumber(gettok(v1029, 1, string.byte(":"))) or 0;
                    local v1031 = tonumber(gettok(v1029, 2, string.byte(":"))) or 0;
                    local v1032 = gettok(v1029, 3, string.byte(":")) or "0";
                    local v1033 = tonumber(gettok(v1032, 2, string.byte("."))) or 0;
                    v1032 = tonumber(gettok(v1032, 1, string.byte("."))) or 0;
                    v1027 = string.format("%02i", v1032);
                    if v1030 > 0 then
                        v1027 = string.format("%i:%02i:", v1030, v1031) .. v1027;
                    else
                        v1027 = string.format("%i:", v1031) .. v1027;
                    end;
                    if v1033 > 0 then
                        v1027 = v1027 .. string.format(".%i", v1033);
                    end;
                end;
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rules_window);
                else
                    guiSetVisible(rules_window, false);
                end;
                if v1027 ~= nil and isElement(admin_window) then
                    if v1025 == -1 or v1026 == -1 then
                        return;
                    else
                        local v1034 = guiGridListGetItemText(modes_list, v1025, 1);
                        local v1035 = guiGridListGetItemText(modes_rules, v1026, 1);
                        if v1034 == "settings" then
                            setTacticsData(v1027, "settings", v1035, true);
                        elseif v1034 == "glitches" then
                            setTacticsData(v1027, "glitches", v1035, true);
                        elseif v1034 == "cheats" then
                            setTacticsData(v1027, "cheats", v1035, true);
                        elseif v1034 == "limites" then
                            setTacticsData(v1027, "limites", v1035, true);
                        else
                            setTacticsData(v1027, "modes", v1034, v1035, true);
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
                local v1036 = guiGridListGetSelectedItem(modes_list);
                if v1036 == -1 then
                    return;
                else
                    local v1037 = guiGridListGetItemText(modes_list, v1036, 1);
                    if getTacticsData("modes", v1037, "enable") == "true" then
                        setTacticsData("false", "modes", v1037, "enable", true);
                    elseif getTacticsData("modes", v1037) then
                        setTacticsData("true", "modes", v1037, "enable", true);
                    end;
                    return;
                end;
            elseif source == sky_topcolor or source == sky_bottomcolor or source == sun_colora or source == sun_colorb or source == water_color then
                if not isElement(palette_window) then
                    createAdminPalette();
                end;
                palette_element = source;
                local v1038 = guiGetProperty(source, "ReadOnlyBGColour");
                local v1039, v1040, v1041, v1042 = getColorFromString("#" .. string.sub(v1038, 1, -1));
                guiSetText(palette_rr, tostring(v1040));
                guiSetText(palette_gg, tostring(v1041));
                guiSetText(palette_bb, tostring(v1042));
                guiSetText(palette_aa, tostring(v1039));
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
                local v1043 = guiComboBoxGetSelected(weather_default);
                if not weatherSAData[v1043 + 1] then
                    return;
                else
                    local v1044 = getTacticsData("Weather") or {};
                    local v1045 = {
                        [0] = true, 
                        [9] = true,
                        [8] = true, 
                        [10] = true, 
                        [19] = true
                    };
                    local v1046 = {};
                    for v1047, v1048 in pairs(weatherSAData[v1043 + 1].hours) do
                        local v1049 = 0;
                        local v1050 = 0;
                        local v1051 = 0;
                        if v1044[v1047] then
                            local v1052, v1053, v1054 = unpack(v1044[v1047].wind);
                            v1051 = v1054;
                            v1050 = v1053;
                            v1049 = v1052;
                        end;
                        local v1055, v1056, v1057, v1058, v1059, v1060 = unpack(v1048.sky);
                        local v1061, v1062, v1063, v1064, v1065, v1066, v1067 = unpack(v1048.sun);
                        local v1068, v1069, v1070, v1071 = unpack(v1048.water);
                        v1046[v1047] = {
                            wind = {not v1049 and 0 or v1049, 
                                not v1050 and 0 or v1050, 
                                not v1051 and 0 or v1051}, 
                            rain = tonumber(v1048.rain or 0), 
                            far = tonumber(v1048.far), 
                            fog = tonumber(v1048.fog), 
                            sky = {v1055, v1056, v1057, v1058, v1059, v1060}, 
                            clouds = true, birds = true, 
                            sun = {v1061, v1062, v1063, v1064, v1065, v1066}, 
                            sunsize = tonumber(v1067), 
                            water = {v1068, v1069, v1070, v1071}, 
                            level = 0, wave = 0, heat = 0, 
                            effect = v1045[v1043] and v1043 or 0
                        };
                    end;
                    setTacticsData(v1046, "Weather");
                    return;
                end;
            elseif source == weather_loadhour then
                local v1072 = guiComboBoxGetSelected(weather_default);
                if not weatherSAData[v1072 + 1] then
                    return;
                else
                    local __, v1074 = guiGridListGetSelectedItem(weather_record);
                    if v1074 < 1 then
                        return;
                    else
                        local v1075 = tonumber(guiGridListGetItemData(weather_record, 1, v1074));
                        if not v1075 then
                            return;
                        elseif not weatherSAData[v1072 + 1].hours[v1075] then
                            return;
                        else
                            local v1076 = getTacticsData("Weather") or {};
                            local v1077 = {
                                [0] = true, 
                                [10] = true, 
                                [8] = true, 
                                [19] = true, 
                                [9] = true
                            };
                            local __ = {};
                            local v1079 = weatherSAData[v1072 + 1].hours[v1075];
                            local v1080, v1081, v1082 = unpack(v1076[v1075].wind);
                            local v1083, v1084, v1085, v1086, v1087, v1088 = unpack(v1079.sky);
                            local v1089, v1090, v1091, v1092, v1093, v1094, v1095 = unpack(v1079.sun);
                            local v1096, v1097, v1098, v1099 = unpack(v1079.water);
                            v1076[v1075] = {
                                wind = {
                                    v1080 or 0, 
                                    v1081 or 0, 
                                    v1082 or 0
                                }, 
                                rain = tonumber(v1079.rain or 0), 
                                far = tonumber(v1079.far), 
                                fog = tonumber(v1079.fog), 
                                sky = {
                                    v1083, 
                                    v1084, 
                                    v1085, 
                                    v1086, 
                                    v1087, 
                                    v1088
                                }, 
                                clouds = true, 
                                birds = true, 
                                sun = {
                                    v1089, 
                                    v1090, 
                                    v1091, 
                                    v1092, 
                                    v1093, 
                                    v1094
                                }, 
                                sunsize = tonumber(v1095), 
                                water = {
                                    v1096, 
                                    v1097, 
                                    v1098, 
                                    v1099
                                }, 
                                level = 0, 
                                wave = 0, 
                                heat = 0, 
                                effect = v1077[v1072] and v1072 or 0
                            };
                            setTacticsData(v1076, "Weather");
                            return;
                        end;
                    end;
                end;
            elseif source == weather_insert then
                local v1100 = tonumber(guiGetText(weather_hour));
                if not v1100 then
                    return;
                else
                    local v1101 = getTacticsData("Weather") or {};
                    if v1101[v1100] then
                        return;
                    else
                        local v1102 = {
                            [0] = true, 
                            [10] = true, 
                            [8] = true, 
                            [19] = true, 
                            [9] = true
                        };
                        v1101[v1100] = {
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
                            effect = v1102[getWeather()] and getWeather() or 0
                        };
                        setTacticsData(v1101, "Weather");
                        return;
                    end;
                end;
            elseif source == weather_delete then
                local __, v1104 = guiGridListGetSelectedItem(weather_record);
                if v1104 < 1 then
                    return;
                else
                    local v1105 = tonumber(guiGridListGetItemData(weather_record, 1, v1104));
                    if not v1105 then
                        return;
                    else
                        local v1106 = getTacticsData("Weather") or {};
                        v1106[v1105] = nil;
                        setTacticsData(v1106, "Weather");
                        return;
                    end;
                end;
            elseif source == weather_save then
                local __, v1108 = guiGridListGetSelectedItem(weather_record);
                if v1108 < 1 then
                    return;
                else
                    local v1109 = tonumber(guiGridListGetItemData(weather_record, 1, v1108));
                    if not v1109 then
                        return;
                    else
                        local v1110 = getTacticsData("Weather") or {};
                        local v1111 = math.rad(tonumber(guiGetText(wind_vector))) or 0;
                        local v1112 = tonumber(guiGetText(wind_speed)) * 3.6 / 200 or 0;
                        local v1113 = -v1112 * math.sin(v1111);
                        local v1114 = v1112 * math.cos(v1111);
                        local v1115 = 0;
                        local v1116, v1117, v1118 = getColorFromString("#" .. string.sub(guiGetProperty(sky_topcolor, "ReadOnlyBGColour"), 3, -1));
                        local v1119, v1120, v1121 = getColorFromString("#" .. string.sub(guiGetProperty(sky_bottomcolor, "ReadOnlyBGColour"), 3, -1));
                        local v1122, v1123, v1124 = getColorFromString("#" .. string.sub(guiGetProperty(sun_colora, "ReadOnlyBGColour"), 3, -1));
                        local v1125, v1126, v1127 = getColorFromString("#" .. string.sub(guiGetProperty(sun_colorb, "ReadOnlyBGColour"), 3, -1));
                        local v1128, v1129, v1130, v1131 = getColorFromString("#" .. string.sub(guiGetProperty(water_color, "ReadOnlyBGColour"), 1, -1));
                        local v1132 = {
                            Clear = 0, 
                            Cloudy = 10, 
                            Thunder = 8, 
                            Storm = 19, 
                            Fog = 9
                        };
                        v1110[v1109] = {
                            wind = {
                                v1113, 
                                v1114, 
                                v1115
                            }, 
                            rain = tonumber(guiGetText(rain_level)), 
                            far = tonumber(guiGetText(farclip_distance)), 
                            fog = tonumber(guiGetText(fog_distance)), 
                            sky = {
                                v1116, 
                                v1117, 
                                v1118, 
                                v1119, 
                                v1120, 
                                v1121
                            }, 
                            clouds = guiCheckBoxGetSelected(sky_clouds), 
                            birds = guiCheckBoxGetSelected(sky_birds), 
                            sun = {
                                v1122, 
                                v1123, 
                                v1124, 
                                v1125, 
                                v1126, 
                                v1127
                            }, 
                            sunsize = tonumber(guiGetText(sun_size)), 
                            water = {
                                v1129, 
                                v1130, 
                                v1131, 
                                v1128
                            }, 
                            level = tonumber(guiGetText(water_level)), 
                            wave = tonumber(guiGetText(wave_height)), 
                            heat = tonumber(guiGetText(heat_level)), 
                            effect = v1132[guiGetText(weather_effect)] or tonumber(guiGetText(weather_effect))
                        };
                        setTacticsData(v1110, "Weather");
                        return;
                    end;
                end;
            elseif source == shooting_ok then
                local v1133 = getWeaponIDFromName(guiGetText(shooting_weapon));
                local v1134 = guiGetText(shooting_weapon_range);
                local v1135 = guiGetText(shooting_target_range);
                local v1136 = guiGetText(shooting_accuracy);
                local v1137 = guiGetText(shooting_damage);
                local v1138 = guiGetText(shooting_maximum_clip);
                local v1139 = guiGetText(shooting_move_speed);
                local v1140 = guiGetText(shooting_anim_loop_start);
                local v1141 = guiGetText(shooting_anim_loop_stop);
                local v1142 = guiGetText(shooting_anim_loop_bullet_fire);
                local v1143 = guiGetText(shooting_anim2_loop_start);
                local v1144 = guiGetText(shooting_anim2_loop_stop);
                local v1145 = guiGetText(shooting_anim2_loop_bullet_fire);
                local v1146 = guiGetText(shooting_anim_breakout_time);
                local v1147 = {
                    {}, 
                    {}, 
                    {}, 
                    {}, 
                    {}
                };
                for v1148 = 1, 4 do
                    v1147[v1148][1] = guiCheckBoxGetSelected(shooting_flags[v1148][1]);
                    v1147[v1148][2] = guiCheckBoxGetSelected(shooting_flags[v1148][2]);
                    v1147[v1148][4] = guiCheckBoxGetSelected(shooting_flags[v1148][4]);
                    v1147[v1148][8] = guiCheckBoxGetSelected(shooting_flags[v1148][8]);
                end;
                callServerFunction("changeWeaponProperty", localPlayer, v1133, v1134, v1135, v1136, v1137, v1138, v1139, v1140, v1141, v1142, v1143, v1144, v1145, v1146, v1147);
                return;
            elseif source == shooting_reset then
                local v1149 = getWeaponIDFromName(guiGetText(shooting_weapon));
                callServerFunction("resetWeaponProperty", localPlayer, v1149);
                return;
            elseif source == handling_ok then
                local v1150 = {};
                local v1151 = getVehicleModelFromName(guiGetText(handling_model));
                v1150.mass = tonumber(guiGetText(handling_mass));
                v1150.turnMass = tonumber(guiGetText(handling_turnmass));
                v1150.dragCoeff = tonumber(guiGetText(handling_dragcoeff));
                v1150.centerOfMass = {
                    tonumber(guiGetText(handling_centerofmass_x)), 
                    tonumber(guiGetText(handling_centerofmass_y)), 
                    tonumber(guiGetText(handling_centerofmass_z))
                };
                v1150.percentSubmerged = tonumber(guiGetText(handling_percentsubmerged));
                v1150.tractionMultiplier = tonumber(guiGetText(handling_tractionmultiplier));
                v1150.tractionLoss = tonumber(guiGetText(handling_tractionloss));
                v1150.tractionBias = tonumber(guiGetText(handling_tractionbias));
                v1150.numberOfGears = tonumber(guiGetText(handling_numberofgears));
                v1150.maxVelocity = tonumber(guiGetText(handling_maxvelocity));
                v1150.engineAcceleration = tonumber(guiGetText(handling_engineacceleration));
                v1150.engineInertia = tonumber(guiGetText(handling_engineinertia));
                v1150.driveType = ({
                    ["4x4"] = "awd", 
                    Front = "fwd", 
                    Rear = "rwd"
                })[guiGetText(handling_drivetype)];
                v1150.engineType = ({
                    Petrol = "petrol", 
                    Diesel = "diesel", 
                    Electric = "electric"
                })[guiGetText(handling_enginetype)];
                v1150.brakeDeceleration = tonumber(guiGetText(handling_brakedeceleration));
                v1150.brakeBias = tonumber(guiGetText(handling_brakebias));
                v1150.ABS = guiGetText(handling_abs) == "Enable";
                v1150.steeringLock = tonumber(guiGetText(handling_steeringlock));
                v1150.suspensionForceLevel = tonumber(guiGetText(handling_suspensionforcelevel));
                v1150.suspensionDamping = tonumber(guiGetText(handling_suspensiondamping));
                v1150.suspensionHighSpeedDamping = tonumber(guiGetText(handling_suspensionhighspeeddamping));
                v1150.suspensionUpperLimit = tonumber(guiGetText(handling_suspensionupperlimit));
                v1150.suspensionLowerLimit = tonumber(guiGetText(handling_suspensionlowerlimit));
                v1150.suspensionFrontRearBias = tonumber(guiGetText(handling_suspensionfrontrearbias));
                v1150.suspensionAntiDiveMultiplier = tonumber(guiGetText(handling_suspensionantidivemultiplier));
                v1150.seatOffsetDistance = tonumber(guiGetText(handling_seatoffsetdistance));
                v1150.collisionDamageMultiplier = tonumber(guiGetText(handling_collisiondamagemultiplier));
                local v1152 = "";
                for v1153 = 1, 8 do
                    local v1154 = 0;
                    if guiCheckBoxGetSelected(handling_modelflags[v1153][8]) then
                        v1154 = v1154 + 8;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[v1153][4]) then
                        v1154 = v1154 + 4;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[v1153][2]) then
                        v1154 = v1154 + 2;
                    end;
                    if guiCheckBoxGetSelected(handling_modelflags[v1153][1]) then
                        v1154 = v1154 + 1;
                    end;
                    v1152 = string.format("%01X", v1154) .. v1152;
                end;
                v1150.modelFlags = "0x" .. v1152;
                local v1155 = "";
                for v1156 = 1, 8 do
                    local v1157 = 0;
                    if guiCheckBoxGetSelected(handling_handlingflags[v1156][8]) then
                        v1157 = v1157 + 8;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[v1156][4]) then
                        v1157 = v1157 + 4;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[v1156][2]) then
                        v1157 = v1157 + 2;
                    end;
                    if guiCheckBoxGetSelected(handling_handlingflags[v1156][1]) then
                        v1157 = v1157 + 1;
                    end;
                    v1155 = string.format("%01X", v1157) .. v1155;
                end;
                v1150.handlingFlags = "0x" .. v1155;
                v1150.sirens = {};
                v1150.sirens.count = tonumber(guiGetText(sirens_count)) or 0;
                v1150.sirens.type = ({
                    Invisible = 1, 
                    Single = 2, 
                    Dual = 3, 
                    Triple = 4, 
                    Quadruple = 5, 
                    Quinary = 6
                })[guiGetText(sirens_type)];
                v1150.sirens.flags = {
                    ["360"] = guiCheckBoxGetSelected(sirens_360), 
                    DoLOSCheck = guiCheckBoxGetSelected(sirens_LOS), 
                    UseRandomiser = guiCheckBoxGetSelected(sirens_randomiser), 
                    Silent = guiCheckBoxGetSelected(sirens_silent)
                };
                for v1158 = 1, 8 do
                    v1150.sirens[v1158] = {
                        x = guiGetText(sirens_xcenter[v1158]), 
                        y = guiGetText(sirens_ycenter[v1158]), 
                        z = guiGetText(sirens_zcenter[v1158]), 
                        color = guiGetProperty(sirens_color[v1158], "ReadOnlyBGColour"), 
                        minalpha = guiGetText(sirens_minalpha[v1158])
                    };
                end;
                callServerFunction("changeVehicleHandling", localPlayer, v1151, v1150);
                return;
            elseif source == handling_reset then
                local v1159 = getVehicleModelFromName(guiGetText(handling_model));
                callServerFunction("resetVehicleHandling", localPlayer, v1159);
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
                    local v1160 = guiGetSelectedTab(admin_tabs);
                    if v1160 == admin_tab_shooting or v1160 == admin_tab_handling or v1160 == admin_tab_anticheat then
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
                    local v1161 = guiGetText(mods_name);
                    local v1162 = guiGetText(mods_edit);
                    if #v1161 == 0 or #v1162 == 0 then
                        return;
                    else
                        local v1163 = guiRadioButtonGetSelected(mods_type_name) and "name" or "hash";
                        callServerFunction("addAnticheatModsearch", v1161, v1162, v1163);
                        if guiCheckBoxGetSelected(config_performance_adminpanel) then
                            destroyElement(mods_window);
                        else
                            guiSetVisible(mods_window, false);
                        end;
                    end;
                elseif guiGetText(mods_ok) == "Set" then
                    local v1164 = guiGridListGetSelectedItem(anticheat_modslist);
                    if v1164 == -1 then
                        return;
                    else
                        local v1165 = guiGetText(mods_name);
                        local v1166 = guiGetText(mods_edit);
                        if #v1165 == 0 or #v1166 == 0 then
                            return;
                        else
                            local v1167 = guiRadioButtonGetSelected(mods_type_name) and "name" or "hash";
                            callServerFunction("setAnticheatModsearch", v1164, v1165, v1166, v1167);
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
                local v1168 = guiGridListGetSelectedItem(anticheat_modslist);
                if v1168 == -1 then
                    return;
                else
                    callServerFunction("removeAnticheatModsearch", v1168);
                    return;
                end;
            elseif source == player_infocopy then
                setClipboard(guiGetText(player_info));
                return;
            elseif source == player_takescreen then
                if not v738 or #v738 > 1 then
                    return;
                else
                    callServerFunction("takePlayerScreenShot", v738[1], 320, 240, getPlayerName(localPlayer) .. " 320 240 " .. getPlayerName(v738[1]), 30, 5000);
                    guiSetEnabled(player_takescreen, false);
                    guiSetEnabled(player_takescreencombobox, false);
                    screenTimeout = setTimer(function() --[[ Line: 2912 ]]
                        guiSetEnabled(player_takescreen, true);
                        guiSetEnabled(player_takescreencombobox, true);
                    end, 30000, 1);
                    return;
                end;
            elseif source == screen_save then
                local v1169 = guiGetText(screen_name);
                local v1170 = fileExists("screenshots/" .. v1169 .. ".jpg");
                if v1170 then
                    fileDelete("screenshots/" .. v1169 .. ".jpg");
                end;
                local v1171 = fileOpen("screenshots/_screen.jpg");
                local v1172 = fileCreate("screenshots/" .. v1169 .. ".jpg");
                while not fileIsEOF(v1171) do
                    fileWrite(v1172, fileRead(v1171, 500));
                end;
                fileClose(v1171);
                fileClose(v1172);
                if not v1170 then
                    local v1173 = xmlLoadFile("screenshots/_list.xml") or xmlCreateFile("screenshots/_list.xml", "screenshots");
                    local v1174 = xmlCreateChild(v1173, "screenshot");
                    xmlNodeSetAttribute(v1174, "src", v1169);
                    xmlSaveFile(v1173);
                    xmlUnloadFile(v1173);
                    guiComboBoxAddItem(screen_list, v1169);
                end;
                guiSetVisible(screen_name, false);
                guiSetVisible(screen_save, false);
                guiSetText(screen_list, v1169);
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
                    for __, v1176 in ipairs(sirens_color) do
                        if source == v1176 then
                            if not isElement(palette_window) then
                                createAdminPalette();
                            end;
                            palette_element = source;
                            local v1177 = guiGetProperty(source, "ReadOnlyBGColour");
                            local v1178, v1179, v1180 = getColorFromString("#" .. string.sub(v1177, 3, -1));
                            guiSetText(palette_rr, tostring(v1178));
                            guiSetText(palette_gg, tostring(v1179));
                            guiSetText(palette_bb, tostring(v1180));
                            guiBringToFront(palette_window);
                            guiSetVisible(palette_window, true);
                            return;
                        end;
                    end;
                end;
                if isElement(admin_window) and guiGetVisible(admin_tab_weapons) then
                    if source == weapons_adding then
                        local v1181 = getTacticsData("weaponspack") or {};
                        local v1182 = getTacticsData("weapon_balance") or {};
                        local v1183 = getTacticsData("weapon_cost") or {};
                        local v1184 = getTacticsData("weapon_slot") or {};
                        for __, v1186 in ipairs(sortWeaponNames) do
                            if not v1181[v1186] then
                                guiSetText(weapons_addname, v1186);
                                local v1187 = convertWeaponNamesToID[v1186];
                                local v1188 = v1187 >= 22 and v1187 <= 39 and tonumber(getWeaponProperty(v1187, "pro", "maximum_clip_ammo")) or 1;
                                guiSetText(weapons_addammo, tostring(v1188));
                                guiSetText(weapons_addlimit, v1182[v1186] or "");
                                guiSetText(weapons_addcost, v1183[v1186] or "$");
                                guiSetText(weapons_addslot, v1184[v1186] or v1187 and tostring(getSlotFromWeapon(v1187)) or "13");
                                break;
                            end;
                        end;
                        return;
                    elseif source == weapons_save then
                        local v1189 = guiGetText(weapons_addname);
                        local v1190 = convertWeaponNamesToID[v1189];
                        local v1191 = guiGetText(weapons_addammo);
                        if #v1189 == 0 or #v1191 == 0 or not tonumber(v1191) then
                            return;
                        else
                            local v1192 = guiGetText(weapons_addlimit);
                            local v1193 = guiGetText(weapons_addcost):gsub("%$", "");
                            local v1194 = guiGetText(weapons_addslot);
                            setTacticsData(tostring(v1191), "weaponspack", tostring(v1189));
                            if #v1192 > 0 and tonumber(v1192) then
                                setTacticsData(tostring(v1192), "weapon_balance", tostring(v1189));
                            else
                                setTacticsData(nil, "weapon_balance", tostring(v1189));
                            end;
                            if #v1193 > 0 and tonumber(v1193) then
                                setTacticsData(tostring(v1193), "weapon_cost", tostring(v1189));
                            else
                                setTacticsData(nil, "weapon_cost", tostring(v1189));
                            end;
                            if #v1194 > 0 and tonumber(v1194) and (v1190 and tonumber(v1194) ~= getSlotFromWeapon(v1190) or tonumber(v1194) ~= 13) then
                                setTacticsData(tostring(v1194), "weapon_slot", tostring(v1189));
                            else
                                setTacticsData(nil, "weapon_slot", tostring(v1189));
                            end;
                            return;
                        end;
                    elseif source == weapons_remove then
                        local v1195 = guiGetText(weapons_addname);
                        if #v1195 == 0 then
                            return;
                        else
                            setTacticsData(nil, "weaponspack", tostring(v1195));
                            return;
                        end;
                    elseif source == weapons_apply then
                        local v1196 = guiGetText(weapons_slots);
                        if #v1196 == 0 or not tonumber(v1196) then
                            return;
                        else
                            setTacticsData(tonumber(v1196), "weapon_slots");
                            return;
                        end;
                    else
                        for __, v1198 in ipairs(weapons_items) do
                            if source == v1198.gui then
                                local v1199 = guiGetText(v1198.name);
                                local v1200 = 0;
                                for __, v1202 in ipairs(split(guiGetText(v1198.ammo), string.byte("-"))) do
                                    v1200 = v1200 + tonumber(v1202);
                                end;
                                v1200 = tostring(math.max(v1200, 1));
                                local v1203 = guiGetText(v1198.limit);
                                if #v1203 > 1 then
                                    v1203 = string.sub(v1203, 2);
                                end;
                                guiSetText(weapons_addname, v1199);
                                guiSetText(weapons_addammo, v1200);
                                guiSetText(weapons_addlimit, v1203);
                                local v1204 = convertWeaponNamesToID[v1199];
                                local v1205 = getTacticsData("weapon_cost") or {};
                                local v1206 = getTacticsData("weapon_slot") or {};
                                guiSetText(weapons_addcost, v1205[v1199] or "");
                                guiSetText(weapons_addslot, v1206[v1199] or v1204 and tostring(getSlotFromWeapon(v1204)) or "13");
                                return;
                            end;
                        end;
                    end;
                end;
                return;
            end;
        end;
    end;
    onClientGUIChanged = function(__) --[[ Line: 3196 ]]
        if source == rules_time then
            local v1208 = guiGetText(rules_time):gsub("[^0-9:.]+", "");
            local v1209 = gettok(v1208, 1, string.byte("."));
            local v1210 = tonumber(gettok(v1209, 1, string.byte(":"))) or 0;
            local v1211 = tonumber(gettok(v1209, 2, string.byte(":"))) or 0;
            local v1212 = tonumber(gettok(v1209, 3, string.byte(":"))) or 0;
            local v1213 = tonumber(gettok(v1208, 2, string.byte("."))) or 0;
            if v1210 >= 0 and v1210 < 24 and v1211 >= 0 and v1211 < 60 and v1212 >= 0 and v1212 < 60 and v1213 >= 0 and v1213 < 10 then
                return;
            else
                local v1214 = v1210 % 24;
                local v1215 = v1211 % 60;
                local v1216 = v1212 % 60;
                v1213 = v1213 % 10;
                v1212 = v1216;
                v1211 = v1215;
                v1210 = v1214;
                v1214 = tonumber(guiGetProperty(rules_time, "CaratIndex"));
                guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v1210, v1211, v1212, v1213));
                guiEditSetCaretIndex(rules_time, v1214);
                return;
            end;
        elseif source == maps_search then
            updateAdminMaps();
            return;
        elseif source == palette_rr or source == palette_gg or source == palette_bb then
            local v1217 = tonumber(guiGetText(palette_rr));
            local v1218 = tonumber(guiGetText(palette_gg));
            local v1219 = tonumber(guiGetText(palette_bb));
            local v1220 = tonumber(guiGetText(palette_aa));
            if type(v1217) ~= "number" then
                v1217 = 0;
            end;
            if type(v1218) ~= "number" then
                v1218 = 0;
            end;
            if type(v1219) ~= "number" then
                v1219 = 0;
            end;
            if type(v1220) ~= "number" then
                v1220 = 0;
            end;
            guiSetText(palette_hex, string.format("%02X%02X%02X%02X", v1220, v1217, v1218, v1219));
            return;
        elseif source == palette_hex and not palette_mode then
            local v1221 = guiGetText(palette_hex);
            local v1222, v1223, v1224, v1225 = getColorFromString("#" .. v1221);
            if type(v1223) ~= "number" then
                v1223 = 0;
            end;
            if type(v1224) ~= "number" then
                v1224 = 0;
            end;
            if type(v1225) ~= "number" then
                v1225 = 0;
            end;
            local v1226, v1227, v1228 = RGBtoHSL(v1223, v1224, v1225);
            palette_L = v1228;
            palette_S = v1227;
            palette_H = v1226;
            guiSetPosition(palette_aim, 0.03 + 0.75 * (palette_H / 360), 0.07 + 0.65 * (1 - palette_S), true);
            guiSetPosition(palette_aim2, 0.93, 0.07 + 0.65 * (1 - palette_L), true);
            v1226 = string.format("%02X%02X%02X%02X", v1222, HSLtoRGB(palette_H, palette_S, 0.5));
            guiSetProperty(palette_color1, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", v1226, v1226, v1226, v1226));
            guiSetProperty(palette_color2, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", v1221, v1221, v1221, v1221));
            return;
        elseif source == wind_vector then
            local v1229 = tonumber(guiGetText(wind_vector)) or 0;
            local v1230, v1231 = guiGetPosition(wind_radar, false);
            guiSetPosition(wind_aim, v1230 + 32 - 32 * math.sin(math.rad(v1229)) - 6, v1231 + 32 - 32 * math.cos(math.rad(v1229)) - 6, false);
            return;
        elseif source == fog_distance or source == farclip_distance then
            local v1232 = tonumber(guiGetText(farclip_distance)) or 0;
            if (tonumber(guiGetText(fog_distance)) or 0) > v1232 - 0.1 then
                guiSetText(fog_distance, string.format("%.1f", v1232 - 0.1));
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
            local v1233 = tonumber(guiGetText(sirens_count));
            if not v1233 then
                for v1234 = 1, 8 do
                    guiSetEnabled(sirens_xcenter[v1234], false);
                    guiSetEnabled(sirens_ycenter[v1234], false);
                    guiSetEnabled(sirens_zcenter[v1234], false);
                    guiSetEnabled(sirens_color[v1234], false);
                    guiSetEnabled(sirens_minalpha[v1234], false);
                end;
            else
                for v1235 = 1, 8 do
                    guiSetEnabled(sirens_xcenter[v1235], v1235 <= v1233);
                    guiSetEnabled(sirens_ycenter[v1235], v1235 <= v1233);
                    guiSetEnabled(sirens_zcenter[v1235], v1235 <= v1233);
                    guiSetEnabled(sirens_color[v1235], v1235 <= v1233);
                    guiSetEnabled(sirens_minalpha[v1235], v1235 <= v1233);
                end;
            end;
            return;
        elseif source == weapons_addname then
            local v1236 = guiGetText(weapons_addname);
            guiSetText(weapons_addnames, v1236);
            local v1237 = convertWeaponNamesToID[v1236];
            if v1237 then
                local v1238 = v1237 >= 16 and v1237 <= 43 and getWeaponProperty(v1237, "pro", "maximum_clip_ammo") or 1;
                local v1239 = getSlotFromWeapon(v1237);
                guiSetText(weapons_addammo, tostring(v1238));
                guiSetText(weapons_addlimit, "");
                guiSetText(weapons_addcost, "$");
                guiSetText(weapons_addslot, tostring(v1239));
            end;
            if fileExists("images/hud/" .. v1236 .. ".png") then
                guiStaticImageLoadImage(weapons_addicon, "images/hud/" .. v1236 .. ".png");
            else
                guiStaticImageLoadImage(weapons_addicon, "images/color_pixel.png");
            end;
            return;
        elseif source == weapons_addcost then
            local v1240 = guiGetText(weapons_addcost):gsub("%$", "");
            guiSetText(weapons_addcost, "$" .. v1240);
            if tonumber(guiGetProperty(weapons_addcost, "CaratIndex")) < 1 then
                guiEditSetCaretIndex(weapons_addcost, 1);
            end;
            return;
        elseif source == weapons_addslot then
            local v1241 = 0;
            local v1242 = {};
            local v1243 = getTacticsData("weapon_slot") or {};
            for __, v1245 in ipairs(weapons_items) do
                local v1246 = guiGetText(v1245.name);
                local v1247 = convertWeaponNamesToID[v1246];
                local v1248 = tonumber(v1243[v1246]) or v1247 and getSlotFromWeapon(v1247) or 13;
                if not v1242[v1248] then
                    v1241 = v1241 + 1;
                    v1242[v1248] = v1241;
                end;
            end;
            local v1249 = guiGetText(weapons_addslot);
            if not v1242[v1249] then
                v1241 = v1241 + 1;
                v1242[v1249] = v1241;
            end;
            local v1250 = string.format("%02X%02X%02X", HSLtoRGB(360 * v1242[v1249] / v1241, 0.5, 0.5));
            guiSetProperty(weapons_addicon, "ImageColours", "tl:FF" .. v1250 .. " tr:FF" .. v1250 .. " bl:FF" .. v1250 .. " br:FF" .. v1250 .. "");
            return;
        else
            return;
        end;
    end;
    onClientGUIMouseUp = function(__, __, __) --[[ Line: 3454 ]]
        local v1254 = nil;
        palette_mode = v1254;
        wind_mode = nil;
    end;
    onClientGUIFocus = function() --[[ Line: 3458 ]]
        if source == player_setteamcombobox then
            guiComboBoxClear(player_setteamcombobox);
            local v1255 = getElementsByType("team");
            table.insert(v1255, v1255[1]);
            table.remove(v1255, 1);
            for __, v1257 in ipairs(v1255) do
                guiComboBoxAddItem(player_setteamcombobox, getTeamName(v1257));
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
    onClientGUIMouseDown = function(__, __, __) --[[ Line: 3477 ]]
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
    onClientCursorMove = function(__, __, v1263, v1264, __, __, __) --[[ Line: 3498 ]]
        if isElement(palette_window) and guiGetVisible(palette_window) then
            if palette_mode == 1 then
                local v1268, v1269 = guiGetPosition(palette_window, false);
                local v1270, v1271 = guiGetSize(palette_window, false);
                local v1272 = (v1263 - v1268 - 0.05 * v1270) / (0.75 * v1270);
                local v1273 = (v1264 - v1269 - 0.09 * v1271) / (0.65 * v1271);
                palette_H = 360 * math.min(math.max(v1272, 0), 1);
                palette_S = 1 - math.min(math.max(v1273, 0), 1);
                guiSetPosition(palette_aim, 0.03 + 0.75 * (palette_H / 360), 0.07 + 0.65 * (1 - palette_S), true);
                local v1274 = string.format("%02X%02X%02X", HSLtoRGB(palette_H, palette_S, 0.5));
                local v1275, v1276, v1277 = HSLtoRGB(palette_H, palette_S, palette_L);
                local v1278 = string.format("%02X%02X%02X", v1275, v1276, v1277);
                guiSetProperty(palette_color1, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", v1274, v1274, v1274, v1274));
                guiSetProperty(palette_color2, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", v1278, v1278, v1278, v1278));
                guiSetText(palette_rr, tostring(v1275));
                guiSetText(palette_gg, tostring(v1276));
                guiSetText(palette_bb, tostring(v1277));
                return;
            elseif palette_mode == 2 then
                local __, v1280 = guiGetPosition(palette_window, false);
                local __, v1282 = guiGetSize(palette_window, false);
                local v1283 = (v1264 - v1280 - 0.09 * v1282) / (0.65 * v1282);
                palette_L = 1 - math.min(math.max(v1283, 0), 1);
                guiSetPosition(palette_aim2, 0.93, 0.07 + 0.65 * (1 - palette_L), true);
                local v1284 = string.format("%02X%02X%02X", HSLtoRGB(palette_H, palette_S, 0.5));
                local v1285, v1286, v1287 = HSLtoRGB(palette_H, palette_S, palette_L);
                local v1288 = string.format("%02X%02X%02X", v1285, v1286, v1287);
                guiSetProperty(palette_color1, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", v1284, v1284, v1284, v1284));
                guiSetProperty(palette_color2, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", v1288, v1288, v1288, v1288));
                guiSetText(palette_rr, tostring(v1285));
                guiSetText(palette_gg, tostring(v1286));
                guiSetText(palette_bb, tostring(v1287));
                return;
            elseif wind_mode == 1 then
                local v1289, v1290 = guiGetPosition(admin_window, false);
                local v1291, v1292 = guiGetPosition(wind_radar, false);
                local v1293 = getAngleBetweenPoints2D(v1289 + 160 + v1291 + 32, v1264, v1263, v1290 + 50 + v1292 + 32);
                guiSetText(wind_vector, string.format("%.1f", v1293));
                return;
            end;
        end;
    end;
    onPaletteSetColor = function(v1294) --[[ Line: 3541 ]]
        if source == sky_topcolor then
            local v1295 = guiGetProperty(sky_bottomcolor, "ReadOnlyBGColour");
            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", v1294, v1294, v1295, v1295));
        end;
        if source == sky_bottomcolor then
            local v1296 = guiGetProperty(sky_topcolor, "ReadOnlyBGColour");
            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", v1296, v1296, v1294, v1294));
        end;
    end;
    onClientGUIDoubleClick = function(v1297, __, __, __) --[[ Line: 3551 ]]
        if v1297 ~= "left" then
            return;
        else
            if source == weather_record then
                local __, v1302 = guiGridListGetSelectedItem(weather_record);
                if v1302 < 1 then
                    return;
                else
                    local v1303 = tonumber(guiGridListGetItemData(weather_record, 1, v1302));
                    if not v1303 then
                        return;
                    else
                        local v1304 = getTacticsData("Weather") or {};
                        if not v1304[v1303] then
                            return;
                        else
                            v1304 = v1304[v1303];
                            guiSetText(wind_vector, string.format("%.1f", getAngleBetweenPoints2D(0, 0, v1304.wind[1], v1304.wind[2])));
                            guiSetText(wind_speed, string.format("%.1f", 200 * math.sqrt(v1304.wind[1] ^ 2 + v1304.wind[2] ^ 2) / 3.6));
                            guiScrollBarSetScrollPosition(wind_slide, math.min(200 * math.sqrt(v1304.wind[1] ^ 2 + v1304.wind[2] ^ 2) / 3.6 * 2, 100));
                            guiScrollBarSetScrollPosition(heat_levelslide, math.min(v1304.heat / 2.55, 100));
                            guiSetText(heat_level, string.format("%.1f", v1304.heat));
                            guiScrollBarSetScrollPosition(rain_slide, math.min(50 * v1304.rain, 100));
                            guiSetText(rain_level, string.format("%.1f", v1304.rain));
                            guiScrollBarSetScrollPosition(farclip_slide, math.min(v1304.far / 30, 100));
                            guiSetText(farclip_distance, string.format("%.1f", v1304.far));
                            guiScrollBarSetScrollPosition(fog_slide, math.min((v1304.fog + 1000) / 40, 100));
                            guiSetText(fog_distance, string.format("%.1f", v1304.fog));
                            guiSetProperty(sky_topcolor, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", v1304.sky[1], v1304.sky[2], v1304.sky[3]));
                            guiBringToFront(sky_topcolor);
                            guiSetProperty(sky_bottomcolor, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", v1304.sky[4], v1304.sky[5], v1304.sky[6]));
                            guiBringToFront(sky_bottomcolor);
                            guiSetProperty(sky_gradient, "ImageColours", string.format("tl:FF%02X%02X%02X tr:FF%02X%02X%02X bl:FF%02X%02X%02X br:FF%02X%02X%02X", v1304.sky[1], v1304.sky[2], v1304.sky[3], v1304.sky[1], v1304.sky[2], v1304.sky[3], v1304.sky[4], v1304.sky[5], v1304.sky[6], v1304.sky[4], v1304.sky[5], v1304.sky[6]));
                            guiSetVisible(sky_clouds_img, v1304.clouds);
                            guiCheckBoxSetSelected(sky_clouds, v1304.clouds);
                            guiSetVisible(sky_birds_img, v1304.birds);
                            guiCheckBoxSetSelected(sky_birds, v1304.birds);
                            guiScrollBarSetScrollPosition(sun_sizeslide, math.min(v1304.sunsize * 2, 100));
                            guiSetText(sun_size, string.format("%.1f", v1304.sunsize));
                            guiSetProperty(sun_colora, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", v1304.sun[1], v1304.sun[2], v1304.sun[3]));
                            guiBringToFront(sun_colora);
                            guiSetProperty(sun_colorb, "ReadOnlyBGColour", string.format("FF%02X%02X%02X", v1304.sun[4], v1304.sun[5], v1304.sun[6]));
                            guiBringToFront(sun_colorb);
                            guiSetProperty(water_color, "ReadOnlyBGColour", string.format("%02X%02X%02X%02X", v1304.water[4], v1304.water[1], v1304.water[2], v1304.water[3]));
                            guiBringToFront(water_color);
                            guiScrollBarSetScrollPosition(water_levelslide, math.min((v1304.level + 200) / 4, 100));
                            guiSetText(water_level, string.format("%.1f", v1304.level));
                            guiScrollBarSetScrollPosition(wave_heightslide, math.min(v1304.wave * 10, 100));
                            guiSetText(wave_height, string.format("%.1f", v1304.wave));
                            local v1305 = {
                                [0] = "Clear", 
                                [10] = "Cloudy", 
                                [8] = "Thunder", 
                                [19] = "Storm", 
                                [9] = "Fog"
                            };
                            guiSetText(weather_effect, v1305[v1304.effect] or tostring(v1304.effect));
                        end;
                    end;
                end;
            end;
            if source == server_maps then
                local v1306 = guiGridListGetSelectedItem(server_maps);
                if v1306 == -1 then
                    return;
                else
                    local v1307 = guiGridListGetItemData(server_maps, v1306, 1);
                    callServerFunction("startMap", v1307);
                end;
            end;
            if source == server_cycler then
                local v1308 = guiGridListGetSelectedItem(server_cycler);
                if v1308 == -1 then
                    return;
                else
                    local v1309 = guiGridListGetItemData(server_cycler, v1308, 2);
                    callServerFunction("startMap", v1309, v1308 + 1);
                end;
            end;
            if source == config_list then
                local v1310 = guiGridListGetSelectedItem(config_list);
                if v1310 == -1 then
                    return;
                else
                    local v1311 = guiGridListGetItemText(config_list, v1310, 1);
                    callServerFunction("startConfig", v1311);
                end;
            end;
            if source == restore_list then
                local v1312 = guiGridListGetSelectedItem(restore_list);
                if v1312 == -1 then
                    return;
                else
                    callServerFunction("restorePlayerLoad", restore_player, v1312 + 1);
                    if guiCheckBoxGetSelected(config_performance_adminpanel) then
                        destroyElement(restore_window);
                    else
                        guiSetVisible(restore_window, false);
                    end;
                    restore_player = false;
                end;
            end;
            if source == vehicles_disabled then
                local v1313 = guiGridListGetSelectedItem(vehicles_disabled);
                if v1313 == -1 then
                    return;
                else
                    local v1314 = tonumber(guiGridListGetItemData(vehicles_disabled, v1313, 1));
                    setTacticsData(nil, "disabled_vehicles", v1314);
                end;
            end;
            if source == vehicles_enabled then
                local v1315 = guiGridListGetSelectedItem(vehicles_enabled);
                if v1315 == -1 then
                    return;
                else
                    local v1316 = tonumber(guiGridListGetItemData(vehicles_enabled, v1315, 1));
                    setTacticsData(true, "disabled_vehicles", v1316);
                end;
            end;
            if source == modes_rules then
                local v1317 = guiGridListGetSelectedItem(modes_list);
                local v1318 = guiGridListGetSelectedItem(modes_rules);
                if v1318 == -1 or v1317 == -1 then
                    return;
                else
                    local v1319 = guiGridListGetItemText(modes_list, v1317, 1);
                    local v1320 = guiGridListGetItemText(modes_rules, v1318, 1);
                    local v1321 = guiGridListGetItemData(modes_rules, v1318, 2);
                    if v1321 == "true" then
                        if v1319 == "settings" then
                            setTacticsData("false", "settings", v1320);
                        elseif v1319 == "glitches" then
                            setTacticsData("false", "glitches", v1320);
                        elseif v1319 == "cheats" then
                            setTacticsData("false", "cheats", v1320);
                        elseif v1319 == "limites" then
                            setTacticsData("false", "limites", v1320);
                        else
                            setTacticsData("false", "modes", v1319, v1320);
                        end;
                    elseif v1321 == "false" then
                        if v1319 == "settings" then
                            setTacticsData("true", "settings", v1320);
                        elseif v1319 == "glitches" then
                            setTacticsData("true", "glitches", v1320);
                        elseif v1319 == "cheats" then
                            setTacticsData("true", "cheats", v1320);
                        elseif v1319 == "limites" then
                            setTacticsData("true", "limites", v1320);
                        else
                            setTacticsData("true", "modes", v1319, v1320);
                        end;
                    else
                        if not isElement(rules_window) then
                            createAdminRules();
                        end;
                        if string.find(v1321, "|") then
                            guiSetVisible(rules_edit, false);
                            guiSetVisible(rules_list, true);
                            guiSetVisible(rules_time, false);
                            guiSetVisible(rules_time_up, false);
                            guiSetVisible(rules_time_down, false);
                            guiGridListClear(rules_list);
                            local v1322 = string.sub(v1321, 1, string.find(v1321, "|") - 1);
                            local v1323 = string.sub(v1321, string.find(v1321, "|") + 1, -1);
                            local v1324 = {};
                            local v1325 = 1;
                            local v1326 = 1;
                            local v1327 = nil;
                            while v1326 do
                                v1326 = string.find(v1323, ",", v1325);
                                if v1326 then
                                    v1324 = string.sub(v1323, v1325, v1326 - 1);
                                    v1325 = v1326 + 1;
                                else
                                    v1324 = string.sub(v1323, v1325, -1);
                                end;
                                v1327 = guiGridListAddRow(rules_list);
                                guiGridListSetItemText(rules_list, v1327, 1, v1324, false, false);
                                if v1324 == v1322 then
                                    guiGridListSetSelectedItem(rules_list, v1327, 1);
                                end;
                            end;
                            guiSetPosition(rules_window, xscreen * 0.5 - 120, (yscreen - 130 - 14 * v1327) * 0.5, false);
                            guiSetSize(rules_window, 240, 130 + 14 * v1327, false);
                            guiSetPosition(rules_ok, 60, 100 + 14 * v1327, false);
                            guiSetPosition(rules_cancel, 122.4, 100 + 14 * v1327, false);
                            guiSetSize(rules_list, 192, 50 + 14 * v1327, false);
                            guiSetText(rules_label, "Choise new value for '" .. v1320 .. "'");
                        elseif string.find(v1321, ":") then
                            guiSetVisible(rules_edit, false);
                            guiSetVisible(rules_list, false);
                            guiSetVisible(rules_time, true);
                            guiSetVisible(rules_time_up, true);
                            guiSetVisible(rules_time_down, true);
                            guiSetPosition(rules_window, (xscreen - 240) * 0.5, (yscreen - 120) * 0.5, false);
                            guiSetSize(rules_window, 240, 120, false);
                            guiSetPosition(rules_ok, 60, 90, false);
                            guiSetPosition(rules_cancel, 122.4, 90, false);
                            guiSetText(rules_label, "Choise new time for '" .. v1320 .. "'");
                            local v1328 = split(tostring(v1321), string.byte(":"));
                            local v1329 = tonumber(v1328[#v1328 - 2]) or 0;
                            local v1330 = tonumber(v1328[#v1328 - 1]) or 0;
                            local v1331 = tonumber(gettok(v1328[#v1328], 1, string.byte("."))) or 0;
                            local v1332 = tonumber(gettok(v1328[#v1328], 2, string.byte("."))) or 0;
                            guiSetText(rules_time, string.format("%02i:%02i:%02i.%i", v1329, v1330, v1331, v1332));
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
                            guiSetText(rules_label, "Enter new value for '" .. v1320 .. "'");
                            guiSetText(rules_edit, tostring(v1321));
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
                local v1333 = guiGridListGetSelectedItem(anticheat_modslist);
                if v1333 == -1 then
                    return;
                else
                    local v1334 = guiGridListGetItemText(anticheat_modslist, v1333, 1);
                    local v1335 = guiGridListGetItemText(anticheat_modslist, v1333, 2);
                    local v1336 = guiGridListGetItemData(anticheat_modslist, v1333, 2);
                    guiSetText(mods_name, v1334);
                    guiSetText(mods_edit, v1335);
                    guiSetText(mods_ok, "Set");
                    if v1336 == "name" then
                        guiRadioButtonSetSelected(mods_type_name, true);
                    end;
                    if v1336 == "hash" then
                        guiRadioButtonSetSelected(mods_type_hash, true);
                    end;
                    guiBringToFront(mods_window);
                    guiSetVisible(mods_window, true);
                end;
            end;
            if source == rules_list then
                local v1337 = guiGridListGetSelectedItem(modes_list);
                local v1338 = guiGridListGetSelectedItem(modes_rules);
                local v1339 = guiGridListGetSelectedItem(rules_list);
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    destroyElement(rules_window);
                else
                    guiSetVisible(rules_window, false);
                end;
                if v1339 > -1 and isElement(admin_window) then
                    local v1340 = guiGridListGetItemText(rules_list, v1339, 1);
                    if v1337 == -1 or v1338 == -1 then
                        return;
                    else
                        local v1341 = guiGridListGetItemText(modes_list, v1337, 1);
                        local v1342 = guiGridListGetItemText(modes_rules, v1338, 1);
                        if v1341 == "settings" then
                            setTacticsData(v1340, "settings", v1342, true);
                        elseif v1341 == "glitches" then
                            setTacticsData(v1340, "glitches", v1342, true);
                        elseif v1341 == "cheats" then
                            setTacticsData(v1340, "cheats", v1342, true);
                        elseif v1341 == "limites" then
                            setTacticsData(v1340, "limites", v1342, true);
                        else
                            setTacticsData(v1340, "modes", v1341, v1342, true);
                        end;
                    end;
                end;
            end;
            return;
        end;
    end;
    onClientGUIComboBoxAccepted = function(__) --[[ Line: 3775 ]]
        -- upvalues: v738 (ref)
        if source == shooting_weapon then
            local v1344 = getWeaponIDFromName(guiGetText(shooting_weapon));
            guiSetText(shooting_weapon_range, string.format("%.4f", getWeaponProperty(v1344, "pro", "weapon_range")));
            guiSetText(shooting_target_range, string.format("%.4f", getWeaponProperty(v1344, "pro", "target_range")));
            guiSetText(shooting_accuracy, string.format("%.4f", getWeaponProperty(v1344, "pro", "accuracy")));
            guiSetText(shooting_damage, string.format("%.4f", getWeaponProperty(v1344, "pro", "damage") / 3));
            guiSetText(shooting_maximum_clip, getWeaponProperty(v1344, "pro", "maximum_clip_ammo"));
            guiSetText(shooting_move_speed, string.format("%.4f", getWeaponProperty(v1344, "pro", "move_speed")));
            guiSetText(shooting_anim_loop_start, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim_loop_start")));
            guiSetText(shooting_anim_loop_stop, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim_loop_stop")));
            guiSetText(shooting_anim_loop_bullet_fire, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim_loop_bullet_fire")));
            guiSetText(shooting_anim2_loop_start, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim2_loop_start")));
            guiSetText(shooting_anim2_loop_stop, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim2_loop_stop")));
            guiSetText(shooting_anim2_loop_bullet_fire, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim2_loop_bullet_fire")));
            guiSetText(shooting_anim_breakout_time, string.format("%.4f", getWeaponProperty(v1344, "pro", "anim_breakout_time")));
            local v1345 = string.reverse(string.format("%06X", getWeaponProperty(v1344, "pro", "flags")));
            for v1346 = 1, 4 do
                local v1347 = tonumber(string.sub(v1345, v1346, v1346), 16);
                if v1347 then
                    if v1347 >= 8 then
                        guiCheckBoxSetSelected(shooting_flags[v1346][8], true);
                        v1347 = v1347 - 8;
                    else
                        guiCheckBoxSetSelected(shooting_flags[v1346][8], false);
                    end;
                    if v1347 >= 4 then
                        guiCheckBoxSetSelected(shooting_flags[v1346][4], true);
                        v1347 = v1347 - 4;
                    else
                        guiCheckBoxSetSelected(shooting_flags[v1346][4], false);
                    end;
                    if v1347 >= 2 then
                        guiCheckBoxSetSelected(shooting_flags[v1346][2], true);
                        v1347 = v1347 - 2;
                    else
                        guiCheckBoxSetSelected(shooting_flags[v1346][2], false);
                    end;
                    if v1347 >= 1 then
                        guiCheckBoxSetSelected(shooting_flags[v1346][1], true);
                        v1347 = v1347 - 1;
                    else
                        guiCheckBoxSetSelected(shooting_flags[v1346][1], false);
                    end;
                else
                    guiCheckBoxSetSelected(shooting_flags[v1346][1], false);
                    guiCheckBoxSetSelected(shooting_flags[v1346][2], false);
                    guiCheckBoxSetSelected(shooting_flags[v1346][4], false);
                    guiCheckBoxSetSelected(shooting_flags[v1346][8], false);
                end;
            end;
        end;
        if source == handling_model then
            local v1348 = getVehicleModelFromName(guiGetText(handling_model));
            local v1349 = (getTacticsData("handlings") or {})[v1348] or {};
            local v1350 = getOriginalHandling(v1348);
            guiSetText(handling_mass, string.format("%.1f", v1349.mass or v1350.mass));
            guiSetText(handling_turnmass, string.format("%.1f", v1349.turnMass or v1350.turnMass));
            guiSetText(handling_dragcoeff, string.format("%.3f", v1349.dragCoeff or v1350.dragCoeff));
            guiSetText(handling_centerofmass_x, string.format("%.3f", v1349.centerOfMass and v1349.centerOfMass[1] or v1350.centerOfMass[1]));
            guiSetText(handling_centerofmass_y, string.format("%.3f", v1349.centerOfMass and v1349.centerOfMass[2] or v1350.centerOfMass[2]));
            guiSetText(handling_centerofmass_z, string.format("%.3f", v1349.centerOfMass and v1349.centerOfMass[3] or v1350.centerOfMass[3]));
            guiSetText(handling_percentsubmerged, string.format("%.0f", v1349.percentSubmerged or v1350.percentSubmerged));
            guiSetText(handling_tractionmultiplier, string.format("%.3f", v1349.tractionMultiplier or v1350.tractionMultiplier));
            guiSetText(handling_tractionloss, string.format("%.3f", v1349.tractionLoss or v1350.tractionLoss));
            guiSetText(handling_tractionbias, string.format("%.3f", v1349.tractionBias or v1350.tractionBias));
            guiSetText(handling_numberofgears, string.format("%.0f", v1349.numberOfGears or v1350.numberOfGears));
            guiSetText(handling_maxvelocity, string.format("%.3f", v1349.maxVelocity or v1350.maxVelocity));
            guiSetText(handling_engineacceleration, string.format("%.3f", v1349.engineAcceleration or v1350.engineAcceleration));
            guiSetText(handling_engineinertia, string.format("%.3f", v1349.engineInertia or v1350.engineInertia));
            guiSetText(handling_drivetype, ({
                awd = "4x4", 
                fwd = "Front", 
                rwd = "Rear"
            })[v1349.driveType or v1350.driveType]);
            guiSetText(handling_enginetype, ({
                petrol = "Petrol", 
                diesel = "Diesel", 
                electric = "Electric"
            })[v1349.engineType or v1350.engineType]);
            guiSetText(handling_brakedeceleration, string.format("%.3f", v1349.brakeDeceleration or v1350.brakeDeceleration));
            guiSetText(handling_brakebias, string.format("%.3f", v1349.brakeBias or v1350.brakeBias));
            guiSetText(handling_abs, v1349.ABS ~= nil and (v1349.ABS and "Enable" or "Disable") or v1350.ABS and "Enable" or "Disable");
            guiSetText(handling_steeringlock, string.format("%.3f", v1349.steeringLock or v1350.steeringLock));
            guiSetText(handling_suspensionforcelevel, string.format("%.3f", v1349.suspensionForceLevel or v1350.suspensionForceLevel));
            guiSetText(handling_suspensiondamping, string.format("%.3f", v1349.suspensionDamping or v1350.suspensionDamping));
            guiSetText(handling_suspensionhighspeeddamping, string.format("%.3f", v1349.suspensionHighSpeedDamping or v1350.suspensionHighSpeedDamping));
            guiSetText(handling_suspensionupperlimit, string.format("%.3f", v1349.suspensionUpperLimit or v1350.suspensionUpperLimit));
            guiSetText(handling_suspensionlowerlimit, string.format("%.3f", v1349.suspensionLowerLimit or v1350.suspensionLowerLimit));
            guiSetText(handling_suspensionfrontrearbias, string.format("%.3f", v1349.suspensionFrontRearBias or v1350.suspensionFrontRearBias));
            guiSetText(handling_suspensionantidivemultiplier, string.format("%.3f", v1349.suspensionAntiDiveMultiplier or v1350.suspensionAntiDiveMultiplier));
            guiSetText(handling_seatoffsetdistance, string.format("%.3f", v1349.seatOffsetDistance or v1350.seatOffsetDistance));
            guiSetText(handling_collisiondamagemultiplier, string.format("%.3f", v1349.collisionDamageMultiplier or v1350.collisionDamageMultiplier));
            guiSetText(handling_variant1, string.format("%.3f", v1349.collisionDamageMultiplier or v1350.collisionDamageMultiplier));
            guiComboBoxClear(handling_variant1);
            guiComboBoxClear(handling_variant2);
            guiComboBoxAddItem(handling_variant1, "Random");
            guiComboBoxAddItem(handling_variant2, "Random");
            local l_pairs_6 = pairs;
            local v1352 = convertVehicleVariant[v1348] or {};
            for __, v1354 in l_pairs_6(v1352) do
                guiComboBoxAddItem(handling_variant1, tostring(v1354));
                guiComboBoxAddItem(handling_variant2, tostring(v1354));
            end;
            l_pairs_6 = string.reverse(string.format("%08X", tonumber(v1349.modelFlags) or v1350.modelFlags));
            v1352 = string.reverse(string.format("%08X", tonumber(v1349.handlingFlags) or v1350.handlingFlags));
            for v1355 = 1, 8 do
                local v1356 = tonumber("0x" .. string.sub(l_pairs_6, v1355, v1355)) or 0;
                local v1357 = tonumber("0x" .. string.sub(v1352, v1355, v1355)) or 0;
                for v1358 = 3, 0, -1 do
                    local v1359 = 2 ^ v1358;
                    if v1359 <= v1356 and v1356 % v1359 >= 0 then
                        v1356 = v1356 - v1359;
                        guiCheckBoxSetSelected(handling_modelflags[v1355][v1359], true);
                    else
                        guiCheckBoxSetSelected(handling_modelflags[v1355][v1359], false);
                    end;
                    if v1359 <= v1357 and v1357 % v1359 >= 0 then
                        v1357 = v1357 - v1359;
                        guiCheckBoxSetSelected(handling_handlingflags[v1355][v1359], true);
                    else
                        guiCheckBoxSetSelected(handling_handlingflags[v1355][v1359], false);
                    end;
                end;
            end;
            if not v1349.sirens then
                guiSetText(sirens_count, "Original");
                guiSetText(sirens_type, "Dual");
                guiCheckBoxSetSelected(sirens_360, false);
                guiCheckBoxSetSelected(sirens_LOS, false);
                guiCheckBoxSetSelected(sirens_randomiser, false);
                guiCheckBoxSetSelected(sirens_silent, false);
                for v1360 = 1, 8 do
                    guiSetText(sirens_xcenter[v1360], "0.000");
                    guiSetText(sirens_ycenter[v1360], "0.000");
                    guiSetText(sirens_zcenter[v1360], "0.000");
                    guiSetProperty(sirens_color[v1360], "ReadOnlyBGColour", "FF808080");
                    guiBringToFront(sirens_color[v1360]);
                    guiSetText(sirens_minalpha[v1360], "0");
                    guiSetEnabled(sirens_xcenter[v1360], false);
                    guiSetEnabled(sirens_ycenter[v1360], false);
                    guiSetEnabled(sirens_zcenter[v1360], false);
                    guiSetEnabled(sirens_color[v1360], false);
                    guiSetEnabled(sirens_minalpha[v1360], false);
                end;
            else
                guiSetText(sirens_count, v1349.sirens.count == 0 and "Original" or tostring(v1349.sirens.count));
                guiSetText(sirens_type, ({
                    [1] = "Invisible", 
                    [2] = "Single", 
                    [3] = "Dual", 
                    [4] = "Triple", 
                    [5] = "Quadruple", 
                    [6] = "Quinary"
                })[v1349.sirens.type]);
                guiCheckBoxSetSelected(sirens_360, v1349.sirens.flags["360"]);
                guiCheckBoxSetSelected(sirens_LOS, v1349.sirens.flags.DoLOSCheck);
                guiCheckBoxSetSelected(sirens_randomiser, v1349.sirens.flags.UseRandomiser);
                guiCheckBoxSetSelected(sirens_silent, v1349.sirens.flags.Silent);
                for v1361 = 1, 8 do
                    if v1361 <= v1349.sirens.count then
                        guiSetText(sirens_xcenter[v1361], string.format("%.3f", v1349.sirens[v1361].x));
                        guiSetText(sirens_ycenter[v1361], string.format("%.3f", v1349.sirens[v1361].y));
                        guiSetText(sirens_zcenter[v1361], string.format("%.3f", v1349.sirens[v1361].z));
                        guiSetProperty(sirens_color[v1361], "ReadOnlyBGColour", v1349.sirens[v1361].color);
                        guiBringToFront(sirens_color[v1361]);
                        guiSetText(sirens_minalpha[v1361], tostring(v1349.sirens[v1361].minalpha));
                    else
                        guiSetText(sirens_xcenter[v1361], "0.000");
                        guiSetText(sirens_ycenter[v1361], "0.000");
                        guiSetText(sirens_zcenter[v1361], "0.000");
                        guiSetProperty(sirens_color[v1361], "ReadOnlyBGColour", "FF808080");
                        guiBringToFront(sirens_color[v1361]);
                        guiSetText(sirens_minalpha[v1361], "0");
                    end;
                    guiSetEnabled(sirens_xcenter[v1361], v1361 <= v1349.sirens.count);
                    guiSetEnabled(sirens_ycenter[v1361], v1361 <= v1349.sirens.count);
                    guiSetEnabled(sirens_zcenter[v1361], v1361 <= v1349.sirens.count);
                    guiSetEnabled(sirens_color[v1361], v1361 <= v1349.sirens.count);
                    guiSetEnabled(sirens_minalpha[v1361], v1361 <= v1349.sirens.count);
                end;
            end;
        end;
        if source == anticheat_action then
            local v1362 = ({
                ["Chat message"] = "chat", 
                ["Adminchat message"] = "adminchat", 
                Kick = "kick"
            })[guiGetText(anticheat_action)];
            setTacticsData(v1362, "anticheat", "action_detection", true);
        end;
        if source == anticheat_speedhack then
            local v1363 = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_speedhack)];
            setTacticsData(v1363, "anticheat", "speedhack");
        end;
        if source == anticheat_godmode then
            local v1364 = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_godmode)];
            setTacticsData(v1364, "anticheat", "godmode");
        end;
        if source == anticheat_mods then
            local v1365 = ({
                Enabled = "true", 
                Disabled = "false"
            })[guiGetText(anticheat_mods)];
            setTacticsData(v1365, "anticheat", "mods");
        end;
        if source == player_setteamcombobox then
            local v1366 = getTeamFromName(guiGetText(player_setteamcombobox));
            guiSetText(player_setteam, guiGetText(player_setteamcombobox));
            if not v738 then
                return;
            else
                for __, v1368 in ipairs(v738) do
                    triggerServerEvent("onPlayerTeamSelect", v1368, v1366, true);
                end;
            end;
        end;
        if source == player_balancecombobox then
            local v1369 = guiGetText(player_balancecombobox);
            if v1369 == "Select" then
                callServerFunction("balanceTeams", localPlayer, v1369, v738);
            else
                callServerFunction("balanceTeams", localPlayer, v1369);
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
            elseif not v738 or #v738 > 1 then
                return;
            else
                local v1370 = guiGetText(player_takescreencombobox);
                local v1371 = gettok(v1370, 1, string.byte(":"));
                local v1372 = tonumber(gettok(v1371, 1, string.byte("x")));
                local v1373 = tonumber(gettok(v1371, 2, string.byte("x")));
                local v1374 = tonumber(({
                    gettok(v1370, 2, string.byte(":")):gsub("%%", "")
                })[1]);
                if v1371 then
                    callServerFunction("takePlayerScreenShot", v738[1], v1372, v1373, getPlayerName(localPlayer) .. " " .. v1372 .. " " .. v1373 .. " " .. v1374, v1374, 5000);
                end;
                guiSetText(player_takescreencombobox, "320x240:30%");
                guiSetEnabled(player_takescreen, false);
                guiSetEnabled(player_takescreencombobox, false);
                screenTimeout = setTimer(function() --[[ Line: 3991 ]]
                    guiSetEnabled(player_takescreen, true);
                    guiSetEnabled(player_takescreencombobox, true);
                end, 30000, 1);
            end;
        end;
        if source == sirens_count then
            local v1375 = tonumber(guiGetText(sirens_count));
            if not v1375 then
                for v1376 = 1, 8 do
                    guiSetEnabled(sirens_xcenter[v1376], false);
                    guiSetEnabled(sirens_ycenter[v1376], false);
                    guiSetEnabled(sirens_zcenter[v1376], false);
                    guiSetEnabled(sirens_color[v1376], false);
                    guiSetEnabled(sirens_minalpha[v1376], false);
                end;
            else
                for v1377 = 1, 8 do
                    guiSetEnabled(sirens_xcenter[v1377], v1377 <= v1375);
                    guiSetEnabled(sirens_ycenter[v1377], v1377 <= v1375);
                    guiSetEnabled(sirens_zcenter[v1377], v1377 <= v1375);
                    guiSetEnabled(sirens_color[v1377], v1377 <= v1375);
                    guiSetEnabled(sirens_minalpha[v1377], v1377 <= v1375);
                end;
            end;
        end;
        if source == weapons_addnames then
            local v1378 = guiGetText(weapons_addnames);
            guiStaticImageLoadImage(weapons_addicon, "images/hud/" .. v1378 .. ".png");
            guiSetText(weapons_addname, v1378);
            guiEditSetCaretIndex(weapons_addname, 0);
            guiSetProperty(weapons_addname, "SelectionLength", tostring(#v1378));
            setTimer(guiBringToFront, 50, 1, weapons_addname);
        end;
        if source == cycler_automatics then
            local v1379 = guiGetText(cycler_automatics);
            v1379 = ({
                Lobby = "lobby", 
                Cycle = "cycler", 
                Voting = "voting", 
                Random = "random"
            })[v1379];
            setTacticsData(v1379 or "lobby", "automatics", true);
        end;
    end;
    onClientGUITabSwitched = function(v1380) --[[ Line: 4030 ]]
        if v1380 == admin_tab_settings and guiGridListGetSelectedItem(modes_list) == -1 then
            guiGridListSetSelectedItem(modes_list, 1, 1);
            triggerEvent("onClientGUIClick", modes_list, "left", "up");
        end;
    end;
    refreshWeaponProperties = function() --[[ Line: 4039 ]]
        if not isElement(admin_window) then
            return;
        else
            triggerEvent("onClientGUIComboBoxAccepted", shooting_weapon);
            return;
        end;
    end;
    local v1381 = {};
    onClientMapsUpdate = function(v1382) --[[ Line: 4044 ]]
        -- upvalues: v1381 (ref)
        v1381 = v1382;
        updateAdminMaps();
    end;
    updateAdminMaps = function() --[[ Line: 4048 ]]
        -- upvalues: v1381 (ref)
        if not isElement(admin_window) then
            return;
        else
            local v1383 = getTacticsData("map_disabled") or {};
            local v1384 = guiGetText(maps_search);
            local v1385 = {};
            for __, v1387 in ipairs(v1381) do
                local v1388 = true;
                if #v1384 > 0 then
                    for v1389 in string.gmatch(v1384, "[^ ]+") do
                        if string.sub(v1389, 1, 1) == "-" then
                            if #v1389 > 1 then
                                v1389 = string.sub(v1389, 2, -1);
                                if string.find(string.lower(v1387[2]), string.lower(v1389)) or string.find(string.lower(v1387[3]), string.lower(v1389)) then
                                    v1388 = false;
                                end;
                            end;
                        elseif not string.find(string.lower(v1387[2]), string.lower(v1389)) and not string.find(string.lower(v1387[3]), string.lower(v1389)) then
                            v1388 = false;
                        end;
                    end;
                end;
                if not guiCheckBoxGetSelected(maps_include) and (v1383[tostring(v1387[1])] or getTacticsData("modes", string.lower(v1387[2]), "enable") == "false") then
                    v1388 = false;
                end;
                if v1388 then
                    table.insert(v1385, v1387);
                end;
            end;
            table.sort(v1385, function(v1390, v1391) --[[ Line: 4072 ]]
                return v1390[2] < v1391[2] or v1390[2] == v1391[2] and v1390[3] < v1391[3];
            end);
            table.insert(v1385, true);
            local v1392 = {};
            for v1393, __ in pairs(getTacticsData("modes_defined")) do
                table.insert(v1392, {v1393, string.upper(string.sub(v1393, 1, 1)) .. string.sub(v1393, 2), "Random"});
            end;
            table.sort(v1392, function(v1395, v1396) --[[ Line: 4078 ]]
                return v1395[1] < v1396[1];
            end);
            for __, v1398 in ipairs(v1392) do
                table.insert(v1385, v1398);
            end;
            local v1399 = getTacticsData("MapResName");
            local v1400 = guiGridListGetRowCount(server_maps);
            for v1401 = 1, math.max(v1400, #v1385) do
                if v1401 <= #v1385 then
                    local v1402 = "";
                    local v1403 = "";
                    local v1404 = "-------------";
                    local v1405 = true;
                    if type(v1385[v1401]) == "table" then
                        local v1406, v1407, v1408 = unpack(v1385[v1401]);
                        v1404 = v1408;
                        v1403 = v1407;
                        v1402 = v1406;
                        v1405 = false;
                    end;
                    if v1400 < v1401 then
                        guiGridListAddRow(server_maps);
                    end;
                    guiGridListSetItemText(server_maps, v1401 - 1, 1, v1403, v1405, false);
                    guiGridListSetItemData(server_maps, v1401 - 1, 1, v1402);
                    guiGridListSetItemText(server_maps, v1401 - 1, 2, v1404, v1405, false);
                    if v1399 == v1402 then
                        if getTacticsData("modes", string.lower(v1403), "enable") == "false" then
                            guiGridListSetItemColor(server_maps, v1401 - 1, 1, 0, 128, 0);
                        else
                            guiGridListSetItemColor(server_maps, v1401 - 1, 1, 0, 255, 0);
                        end;
                        if v1383[v1402] then
                            guiGridListSetItemColor(server_maps, v1401 - 1, 2, 0, 128, 0);
                        else
                            guiGridListSetItemColor(server_maps, v1401 - 1, 2, 0, 255, 0);
                        end;
                    else
                        if getTacticsData("modes", string.lower(v1403), "enable") == "false" then
                            guiGridListSetItemColor(server_maps, v1401 - 1, 1, 128, 128, 128);
                        else
                            guiGridListSetItemColor(server_maps, v1401 - 1, 1, 255, 255, 255);
                        end;
                        if v1383[v1402] then
                            guiGridListSetItemColor(server_maps, v1401 - 1, 2, 128, 128, 128);
                        else
                            guiGridListSetItemColor(server_maps, v1401 - 1, 2, 255, 255, 255);
                        end;
                    end;
                else
                    guiGridListRemoveRow(server_maps, #v1385);
                end;
            end;
            return;
        end;
    end;
    onClientTacticsChange = function(v1409, v1410) --[[ Line: 4123 ]]
        if v1409[1] == "version" then
            if not isElement(admin_window) then
                return;
            else
                guiSetText(admin_window, "Tactics " .. getTacticsData("version") .. " - Gamemode Control Panel");
            end;
        end;
        if v1409[1] == "ResourceCurrent" and isElement(server_cycler) then
            if not isElement(admin_window) then
                return;
            else
                for v1411 = 0, guiGridListGetRowCount(server_cycler) do
                    if getTacticsData("ResourceCurrent") == v1411 + 1 then
                        guiGridListSetItemColor(server_cycler, v1411, 1, 255, 40, 0);
                        guiGridListSetItemColor(server_cycler, v1411, 2, 255, 40, 0);
                        guiGridListSetItemColor(server_cycler, v1411, 3, 255, 40, 0);
                    else
                        guiGridListSetItemColor(server_cycler, v1411, 1, 255, 255, 255);
                        guiGridListSetItemColor(server_cycler, v1411, 2, 255, 255, 255);
                        guiGridListSetItemColor(server_cycler, v1411, 3, 255, 255, 255);
                    end;
                end;
            end;
        end;
        if v1409[1] == "Resources" then
            refreshCyclerResources();
        end;
        if v1409[1] == "automatics" then
            if not isElement(admin_window) then
                return;
            else
                local v1412 = getTacticsData("automatics");
                v1412 = ({
                    lobby = "Lobby", 
                    cycler = "Cycle", 
                    voting = "Voting", 
                    random = "Random"
                })[v1412];
                if v1412 then
                    guiSetText(cycler_automatics, v1412);
                end;
            end;
        end;
        if v1409[1] == "disabled_vehicles" then
            refreshVehicleConfig();
        end;
        if v1409[1] == "modes" or v1409[1] == "settings" or v1409[1] == "glitches" or v1409[1] == "cheats" or v1409[1] == "limites" then
            refreshSettingsConfig();
        end;
        if v1409[1] == "weaponspack" or v1409[1] == "weapon_balance" or v1409[1] == "weapon_slot" then
            remakeAdminWeaponsPack();
        end;
        if v1409[1] == "weapon_slots" then
            if not isElement(admin_window) then
                return;
            else
                local v1413 = tostring(getTacticsData("weapon_slots")) or "0";
                guiSetText(weapons_slots, v1413);
            end;
        end;
        if v1409[1] == "Weather" then
            refreshWeatherConfig();
        end;
        if v1409[1] == "settings" then
            if v1409[2] == "dontfire" then
                local v1414 = getTacticsData("settings", "dontfire");
                if v1414 == "true" then
                    bindKey("fire", "down", dontfireKey);
                    bindKey("aim_weapon", "down", dontfireKey);
                    addEventHandler("onClientPlayerDamage", localPlayer, dontfireDamage);
                elseif v1414 == "false" then
                    unbindKey("fire", "down", dontfireKey);
                    unbindKey("aim_weapon", "down", dontfireKey);
                    removeEventHandler("onClientPlayerDamage", localPlayer, dontfireDamage);
                end;
            end;
            if v1409[2] == "streetlamps" then
                local v1415 = {1211, 1214, 1215, 1223, 1226, 1231, 1232, 1257, 1258, 1269, 1270, 1278, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1306, 1307, 1308, 1315, 1319, 1350, 1351, 1352, 1363, 1366, 1367, 1478, 1568, 3398, 3407, 3408, 3447, 3459, 3460, 3463, 3516, 3853, 3854, 3855, 3875};
                if getTacticsData("settings", "streetlamps") == "true" then
                    for __, v1417 in ipairs(v1415) do
                        restoreWorldModel(v1417, 10000, 0, 0, 0);
                    end;
                else
                    for __, v1419 in ipairs(v1415) do
                        removeWorldModel(v1419, 10000, 0, 0, 0);
                    end;
                end;
            end;
        end;
        if v1409[1] == "anticheat" then
            if not isElement(admin_window) then
                return;
            else
                if v1409[2] == "action_detection" then
                    guiSetText(anticheat_action, ({
                        chat = "Chat message", 
                        adminchat = "Adminchat message", 
                        kick = "Kick"
                    })[getTacticsData("anticheat", "action_detection")]);
                end;
                if v1409[2] == "speedhach" then
                    if getTacticsData("anticheat", "speedhach") == "true" then
                        guiSetText(anticheat_speedhack, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_speedhack, "Disable");
                    end;
                end;
                if v1409[2] == "godmode" then
                    if getTacticsData("anticheat", "godmode") == "true" then
                        guiSetText(anticheat_godmode, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_godmode, "Disable");
                    end;
                end;
                if v1409[2] == "mods" then
                    if getTacticsData("anticheat", "mods") == "true" then
                        guiSetText(anticheat_mods, "Enable");
                    elseif new == "false" then
                        guiSetText(anticheat_mods, "Disable");
                    end;
                end;
                if v1409[2] == "modslist" then
                    refreshAnticheatSearch();
                end;
            end;
        end;
        if v1409[1] == "handlings" then
            if not isElement(admin_window) then
                return;
            else
                local v1420 = getTacticsData("handlings");
                local v1421 = getVehicleModelFromName(guiGetText(handling_model));
                if v1420[v1421] or (v1410 or {})[v1421] then
                    triggerEvent("onClientGUIComboBoxAccepted", handling_model);
                end;
            end;
        end;
        if v1409[1] == "map_disabled" or v1409[1] == "modes" and v1409[3] == "enable" then
            updateAdminMaps();
        end;
    end;
    dontfireKey = function(v1422, __) --[[ Line: 4236 ]]
        if isElementInWater(localPlayer) then
            return;
        else
            local v1424 = getPedWeapon(localPlayer);
            if v1424 == 43 or v1424 == 44 or v1424 == 45 or v1424 == 46 then
                return;
            else
                setPedControlState(v1422, false);
                return;
            end;
        end;
    end;
    dontfireDamage = function() --[[ Line: 4242 ]]
        cancelEvent();
    end;
    togglePause = function(__, v1426) --[[ Line: 4245 ]]
        triggerServerEvent("onPause", resourceRoot, v1426, localPlayer);
    end;
    forcePlay = function() --[[ Line: 4248 ]]
        triggerServerEvent("onPlay", resourceRoot);
    end;
    remakeAdminWeaponsPack = function() --[[ Line: 4251 ]]
        if not isElement(admin_window) then
            return;
        else
            local v1427 = getTacticsData("weaponspack") or {};
            local v1428 = getTacticsData("weapon_balance") or {};
            if not getTacticsData("weapon_cost") then
                local __ = {};
            end;
            local v1430 = {};
            for v1431 in pairs(v1427) do
                if v1431 ~= nil then
                    table.insert(v1430, v1431);
                end;
            end;
            local v1432 = {
                [2] = 1, 
                [3] = 2, 
                [4] = 2, 
                [5] = 3, 
                [6] = 3
            };
            table.sort(v1430, function(v1433, v1434) --[[ Line: 4259 ]]
                -- upvalues: v1432 (ref)
                local v1435 = convertWeaponNamesToID[v1433] or 46;
                local v1436 = convertWeaponNamesToID[v1434] or 46;
                local v1437 = getSlotFromWeapon(v1435);
                local v1438 = getSlotFromWeapon(v1436);
                local v1439 = v1432[v1437] or 4;
                local v1440 = v1432[v1438] or 4;
                return v1439 == v1440 and not (v1435 >= v1436) or v1439 < v1440;
            end);
            local v1441 = 0;
            local v1442 = 0;
            for v1443 = 1, math.max(#weapons_items, #v1430) do
                if v1443 <= #v1430 then
                    local v1444 = v1430[v1443];
                    local v1445 = 0;
                    local v1446 = convertWeaponNamesToID[v1444] or 16;
                    if v1446 >= 16 and v1446 <= 18 or v1446 >= 22 and v1446 <= 39 or v1446 >= 41 and v1446 <= 43 then
                        v1445 = tonumber(getWeaponProperty(v1446, "pro", "maximum_clip_ammo")) or 1;
                    end;
                    local v1447 = math.max(0, math.floor(tonumber(v1427[v1444]) - v1445)) .. "-" .. math.min(tonumber(v1427[v1444]), v1445);
                    if #weapons_items < v1443 then
                        local v1448 = guiCreateButton(v1441, v1442, 64, 84, "", false, weapons_scroller);
                        local v1449 = guiCreateStaticImage(2, 5, 60, 64, "images/hud/fist.png", false, v1448);
                        guiSetEnabled(v1449, false);
                        local v1450 = guiCreateLabel(1, 60, 62, 20, v1445 > 1 and v1447 or v1445 == 1 and v1427[v1444] or "", false, v1448);
                        guiLabelSetHorizontalAlign(v1450, "center", false);
                        guiLabelSetVerticalAlign(v1450, "center");
                        guiSetEnabled(v1450, false);
                        local v1451 = guiCreateLabel(1, 5, 62, 20, v1444, false, v1448);
                        guiSetFont(v1451, "default-small");
                        guiSetEnabled(v1451, false);
                        local v1452 = guiCreateLabel(1, 5, 62, 20, v1428[v1444] and "x" .. v1428[v1444] or "", false, v1448);
                        guiLabelSetHorizontalAlign(v1452, "right", false);
                        guiLabelSetColor(v1452, 255, 0, 0);
                        guiSetEnabled(v1452, false);
                        table.insert(weapons_items, {gui = v1448, icon = v1449, name = v1451, ammo = v1450, limit = v1452});
                    else
                        guiSetPosition(weapons_items[v1443].gui, v1441, v1442, false);
                        guiSetText(weapons_items[v1443].ammo, v1445 > 1 and v1447 or v1445 == 1 and v1427[v1444] or "");
                        guiSetText(weapons_items[v1443].name, v1444);
                        guiSetText(weapons_items[v1443].limit, v1428[v1444] and "x" .. v1428[v1444] or "");
                    end;
                    if fileExists("images/hud/" .. v1444 .. ".png") then
                        guiStaticImageLoadImage(weapons_items[v1443].icon, "images/hud/" .. v1444 .. ".png");
                    else
                        guiStaticImageLoadImage(weapons_items[v1443].icon, "images/hud/fist.png");
                    end;
                    guiSetProperty(weapons_items[v1443].gui, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
                    v1441 = v1441 + 66;
                    if v1441 > 198 then
                        v1441 = 0;
                        v1442 = v1442 + 86;
                    end;
                else
                    destroyElement(weapons_items[v1443].gui);
                    weapons_items[v1443] = nil;
                end;
            end;
            local v1453 = 0;
            local v1454 = {};
            local v1455 = getTacticsData("weapon_slot") or {};
            for __, v1457 in ipairs(weapons_items) do
                local v1458 = guiGetText(v1457.name);
                local v1459 = convertWeaponNamesToID[v1458];
                local v1460 = tonumber(v1455[v1458]) or v1459 and getSlotFromWeapon(v1459) or 13;
                if not v1454[v1460] then
                    v1453 = v1453 + 1;
                    v1454[v1460] = v1453;
                end;
            end;
            for __, v1462 in ipairs(weapons_items) do
                local v1463 = guiGetText(v1462.name);
                local v1464 = convertWeaponNamesToID[v1463];
                local v1465 = tonumber(v1455[v1463]) or v1464 and getSlotFromWeapon(v1464) or 13;
                local v1466 = string.format("%02X%02X%02X", HSLtoRGB(360 * v1454[v1465] / v1453, 0.5, 0.5));
                guiSetProperty(v1462.icon, "ImageColours", "tl:FF" .. v1466 .. " tr:FF" .. v1466 .. " bl:FF" .. v1466 .. " br:FF" .. v1466 .. "");
            end;
            guiSetPosition(weapons_adding, v1441, v1442 + 10, false);
            guiComboBoxClear(weapons_addnames);
            for __, v1468 in ipairs(sortWeaponNames) do
                if not v1427[v1468] then
                    guiComboBoxAddItem(weapons_addnames, v1468);
                end;
            end;
            return;
        end;
    end;
    toRestoreChoise = function(v1469) --[[ Line: 4349 ]]
        if not isElement(restore_window) then
            createAdminRestore();
        end;
        restore_player = v1469;
        guiSetText(restore_window, "Restore " .. getPlayerName(v1469));
        refreshRestores();
        guiBringToFront(restore_window);
        guiSetVisible(restore_window, true);
        showCursor(true);
    end;
    RGBtoHSL = function(v1470, v1471, v1472) --[[ Line: 4358 ]]
        local v1473 = v1470 / 255;
        local v1474 = v1471 / 255;
        local v1475 = v1472 / 255;
        local v1476 = math.max(v1473, v1474, v1475);
        local v1477 = math.min(v1473, v1474, v1475);
        local v1478 = v1476 == v1477 and 0 or v1476 == v1473 and v1475 <= v1474 and 60 * ((v1474 - v1475) / (v1476 - v1477)) or v1476 == v1473 and v1474 < v1475 and 60 * ((v1474 - v1475) / (v1476 - v1477)) + 360 or v1476 == v1474 and 60 * ((v1475 - v1473) / (v1476 - v1477)) + 120 or v1476 == v1475 and 60 * ((v1473 - v1474) / (v1476 - v1477)) + 240 or 360;
        local v1479 = 0.5 * (v1476 + v1477);
        return v1478, v1479 == 0 and 0 or v1476 == v1477 and 0 or v1479 > 0 and v1479 <= 0.5 and (v1476 - v1477) / (2 * v1479) or v1479 > 0.5 and v1479 < 1 and (v1476 - v1477) / (2 - 2 * v1479) or 1, v1479;
    end;
    HSLtoRGB = function(v1480, v1481, v1482) --[[ Line: 4374 ]]
        local v1483 = v1482 < 0.5 and v1482 * (1 + v1481) or v1482 + v1481 - v1482 * v1481;
        local v1484 = 2 * v1482 - v1483;
        local v1485 = v1480 / 360;
        local v1486 = v1485 + 0.3333333333333333;
        local l_v1485_0 = v1485;
        local v1488 = v1485 - 0.3333333333333333;
        if v1486 < 0 then
            v1486 = v1486 + 1;
        end;
        if l_v1485_0 < 0 then
            l_v1485_0 = l_v1485_0 + 1;
        end;
        if v1488 < 0 then
            v1488 = v1488 + 1;
        end;
        if v1486 > 1 then
            v1486 = v1486 - 1;
        end;
        if l_v1485_0 > 1 then
            l_v1485_0 = l_v1485_0 - 1;
        end;
        if v1488 > 1 then
            v1488 = v1488 - 1;
        end;
        local v1489 = v1486 < 0.16666666666666666 and v1484 + (v1483 - v1484) * 6 * v1486 or v1486 >= 0.16666666666666666 and v1486 < 0.5 and v1483 or v1486 >= 0.5 and v1486 < 0.6666666666666666 and v1484 + (v1483 - v1484) * (0.6666666666666666 - v1486) * 6 or v1484;
        local v1490 = l_v1485_0 < 0.16666666666666666 and v1484 + (v1483 - v1484) * 6 * l_v1485_0 or l_v1485_0 >= 0.16666666666666666 and l_v1485_0 < 0.5 and v1483 or l_v1485_0 >= 0.5 and l_v1485_0 < 0.6666666666666666 and v1484 + (v1483 - v1484) * (0.6666666666666666 - l_v1485_0) * 6 or v1484;
        local v1491 = v1488 < 0.16666666666666666 and v1484 + (v1483 - v1484) * 6 * v1488 or v1488 >= 0.16666666666666666 and v1488 < 0.5 and v1483 or v1488 >= 0.5 and v1488 < 0.6666666666666666 and v1484 + (v1483 - v1484) * (0.6666666666666666 - v1488) * 6 or v1484;
        return math.floor(255 * v1489), math.floor(255 * v1490), (math.floor(255 * v1491));
    end;
    executeRuncode = function(__, v1493, ...) --[[ Line: 4399 ]]
        local v1494 = table.concat({
            ...
        }, " ");
        if not v1493 or not getPlayerFromName(v1493) then
            v1494 = v1493 .. " " .. v1494;
            v1493 = localPlayer;
        else
            v1493 = getPlayerFromName(v1493);
        end;
        callServerFunction("executeClientRuncode", localPlayer, v1493, v1494);
    end;
    stopRuncode = function(__, v1496) --[[ Line: 4409 ]]
        if not v1496 or not getPlayerFromName(v1496) then
            v1496 = localPlayer;
        else
            v1496 = getPlayerFromName(v1496);
        end;
        callServerFunction("stopClientRuncode", localPlayer, v1496);
    end;
    local v1497 = {};
    local v1498 = {};
    local v1499 = {};
    local v1500 = {};
    local v1501 = {};
    createAddEventHandlerFunction = function(v1502) --[[ Line: 4422 ]]
        -- upvalues: v1498 (ref)
        return function(v1503, v1504, v1505, v1506) --[[ Line: 4423 ]]
            -- upvalues: v1498 (ref), v1502 (ref)
            if type(v1503) == "string" and isElement(v1504) and type(v1505) == "function" then
                if v1506 == nil or type(v1506) ~= "boolean" then
                    v1506 = true;
                end;
                if addEventHandler(v1503, v1504, v1505, v1506) then
                    table.insert(v1498[v1502], {v1503, v1504, v1505});
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createBindKeyFunction = function(v1507) --[[ Line: 4436 ]]
        -- upvalues: v1499 (ref)
        return function(...) --[[ Line: 4437 ]]
            -- upvalues: v1499 (ref), v1507 (ref)
            local v1508 = {
                ...
            };
            local v1509 = table.remove(v1508, 1);
            local v1510 = table.remove(v1508, 1);
            local v1511 = table.remove(v1508, 1);
            local l_v1508_0 = v1508;
            if type(v1509) ~= "string" or type(v1510) ~= "string" or type(v1511) ~= "string" and type(v1511) ~= "function" then
                return false;
            else
                v1508 = {v1509, v1510, v1511, unpack(l_v1508_0)};
                if bindKey(unpack(v1508)) then
                    table.insert(v1499[v1507], v1508);
                    return true;
                else
                    return false;
                end;
            end;
        end;
    end;
    createAddCommandHandlerFunction = function(v1513) --[[ Line: 4454 ]]
        -- upvalues: v1500 (ref)
        return function(v1514, v1515, v1516, __) --[[ Line: 4455 ]]
            -- upvalues: v1500 (ref), v1513 (ref)
            if type(v1514) == "string" and type(v1515) == "function" then
                local v1518 = nil;
                v1518 = {
                    v1514, 
                    v1515, 
                    type(v1516) ~= "boolean" or v1516
                };
                if addCommandHandler(unpack(v1518)) then
                    table.insert(v1500[v1513], v1518);
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createSetTimerFunction = function(v1519) --[[ Line: 4472 ]]
        -- upvalues: v1501 (ref)
        return function(v1520, v1521, v1522, ...) --[[ Line: 4473 ]]
            -- upvalues: v1501 (ref), v1519 (ref)
            if type(v1520) == "function" and type(v1521) == "number" and type(v1522) == "number" then
                local v1523 = setTimer(v1520, v1521, v1522, ...);
                if v1523 then
                    table.insert(v1501[v1519], v1523);
                    return v1523;
                end;
            end;
            return false;
        end;
    end;
    createRemoveEventHandlerFunction = function(v1524) --[[ Line: 4484 ]]
        -- upvalues: v1498 (ref)
        return function(v1525, v1526, v1527) --[[ Line: 4485 ]]
            -- upvalues: v1498 (ref), v1524 (ref)
            if type(v1525) == "string" and isElement(v1526) and type(v1527) == "function" then
                for v1528, v1529 in ipairs(v1498[v1524]) do
                    if v1529[1] == v1525 and v1529[2] == v1526 and v1529[3] == v1527 and removeEventHandler(unpack(v1529)) then
                        table.remove(v1498[v1524], v1528);
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    createUnbindKeyFunction = function(v1530) --[[ Line: 4499 ]]
        -- upvalues: v1499 (ref)
        return function(...) --[[ Line: 4500 ]]
            -- upvalues: v1499 (ref), v1530 (ref)
            local v1531 = {
                ...
            };
            local v1532 = table.remove(v1531, 1);
            local v1533 = table.remove(v1531, 1);
            local v1534 = table.remove(v1531, 1);
            if type(v1532) ~= "string" then
                return false;
            else
                if type(v1533) ~= "string" or not v1533 then
                    v1533 = nil;
                end;
                if type(v1534) ~= "string" and type(v1534) ~= "function" or not v1534 then
                    v1534 = nil;
                end;
                v1531 = {
                    v1532, 
                    v1533, 
                    v1534
                };
                local v1535 = false;
                for v1536, v1537 in ipairs(v1499[v1530]) do
                    if v1537[1] == v1531[1] and (not v1531[2] or v1531[2] == v1537[2]) and (not v1531[3] or v1531[3] == v1537[3]) and unbindKey(unpack(v1537)) then
                        table.remove(v1499[v1530], v1536);
                        v1535 = true;
                    end;
                end;
                return v1535;
            end;
        end;
    end;
    createRemoveCommandHandlerFunction = function(v1538) --[[ Line: 4523 ]]
        -- upvalues: v1500 (ref)
        return function(v1539, v1540) --[[ Line: 4524 ]]
            -- upvalues: v1500 (ref), v1538 (ref)
            local v1541 = false;
            if type(v1539) == "string" and type(v1540) == "function" then
                for v1542, v1543 in ipairs(v1500[v1538]) do
                    if v1543[1] == v1539 and (not v1543[2] or v1543[2] == v1540) and removeCommandHandler(unpack(v1543)) then
                        table.remove(v1500[v1538], v1542);
                        v1541 = true;
                    end;
                end;
            end;
            return v1541;
        end;
    end;
    createKillTimerFunction = function(v1544) --[[ Line: 4539 ]]
        -- upvalues: v1501 (ref)
        return function(v1545) --[[ Line: 4540 ]]
            -- upvalues: v1501 (ref), v1544 (ref)
            local v1546 = false;
            for v1547, v1548 in ipairs(v1501[v1544]) do
                if v1548 == v1545 and killTimer(v1545) then
                    table.remove(v1501[v1544], v1547);
                    v1546 = true;
                end;
            end;
            return v1546;
        end;
    end;
    cleanEventHandlerContainer = function(v1549) --[[ Line: 4553 ]]
        -- upvalues: v1498 (ref)
        if not v1498[v1549] then
            return;
        else
            for __, v1551 in ipairs(v1498[v1549]) do
                if isElement(v1551[2]) then
                    removeEventHandler(unpack(v1551));
                end;
            end;
            v1498[v1549] = nil;
            return;
        end;
    end;
    cleanKeyBindContainer = function(v1552) --[[ Line: 4562 ]]
        -- upvalues: v1499 (ref)
        if not v1499[v1552] then
            return;
        else
            for __, v1554 in ipairs(v1499[v1552]) do
                unbindKey(unpack(v1554));
            end;
            v1499[v1552] = nil;
            return;
        end;
    end;
    cleanCommandHandlerContainer = function(v1555) --[[ Line: 4569 ]]
        -- upvalues: v1500 (ref)
        if not v1500[v1555] then
            return;
        else
            for __, v1557 in ipairs(v1500[v1555]) do
                removeCommandHandler(unpack(v1557));
            end;
            v1500[v1555] = nil;
            return;
        end;
    end;
    cleanTimerContainer = function(v1558) --[[ Line: 4576 ]]
        -- upvalues: v1501 (ref)
        if not v1501[v1558] then
            return;
        else
            for __, v1560 in ipairs(v1501[v1558]) do
                if isTimer(v1560) then
                    killTimer(v1560);
                end;
            end;
            v1501[v1558] = nil;
            return;
        end;
    end;
    stopClientRuncode = function(v1561) --[[ Line: 4583 ]]
        -- upvalues: v1497 (ref)
        if not v1497[v1561] then
            callServerFunction("outputChatBox", "Not running!", v1561, 0, 128, 0, true);
            return;
        else
            cleanEventHandlerContainer(v1561);
            cleanKeyBindContainer(v1561);
            cleanCommandHandlerContainer(v1561);
            cleanTimerContainer(v1561);
            v1497[v1561] = nil;
            callServerFunction("outputChatBox", "Stopped!", v1561, 0, 128, 0, true);
            return;
        end;
    end;
    executeClientRuncode = function(v1562, v1563) --[[ Line: 4595 ]]
        -- upvalues: v1498 (ref), v1499 (ref), v1500 (ref), v1501 (ref), v1497 (ref)
        if not v1498[v1562] then
            v1498[v1562] = {};
        end;
        if not v1499[v1562] then
            v1499[v1562] = {};
        end;
        if not v1500[v1562] then
            v1500[v1562] = {};
        end;
        if not v1501[v1562] then
            v1501[v1562] = {};
        end;
        if not v1497[v1562] then
            v1497[v1562] = {
                addEventHandler = createAddEventHandlerFunction(v1562), 
                removeEventHandler = createRemoveEventHandlerFunction(v1562), 
                bindKey = createBindKeyFunction(v1562), 
                unbindKey = createUnbindKeyFunction(v1562), 
                addCommandHandler = createAddCommandHandlerFunction(v1562), 
                removeCommandHandler = createRemoveCommandHandlerFunction(v1562), 
                setTimer = createSetTimerFunction(v1562), 
                killTimer = createKillTimerFunction(v1562)
            };
            setmetatable(v1497[v1562], {
                __index = _G
            });
        end;
        local v1564 = false;
        local v1565, v1566 = loadstring("return " .. v1563);
        if v1566 then
            v1564 = true;
            local v1567, v1568 = loadstring(tostring(v1563));
            v1566 = v1568;
            v1565 = v1567;
        end;
        if v1566 then
            callServerFunction("outputChatBox", "ERROR: " .. v1566, v1562, 255, 0, 0, true);
            return;
        else
            v1565 = setfenv(v1565, v1497[v1562]);
            local v1569 = {
                pcall(v1565)
            };
            if not v1569[1] then
                callServerFunction("outputChatBox", "ERROR: " .. v1569[2], v1562, 255, 0, 0, true);
                return;
            else
                if not v1564 then
                    local v1570 = "";
                    for v1571 = 2, #v1569 do
                        local v1572 = "";
                        if v1571 > 2 then
                            v1570 = v1570 .. "#00FF00, ";
                        end;
                        local v1573 = v1569[v1571];
                        if type(v1573) == "table" then
                            for v1574, __ in pairs(v1573) do
                                if #v1572 > 0 then
                                    v1572 = v1572 .. ", ";
                                end;
                                if type(v1574) == "userdata" then
                                    if isElement(v1574) then
                                        v1572 = v1572 .. "#66CC66" .. getElementType(v1573) .. "#B1B100";
                                    else
                                        v1572 = v1572 .. "#66CC66element#B1B100";
                                    end;
                                elseif type(v1574) == "string" then
                                    v1572 = v1572 .. "#FF0000\"" .. v1574 .. "\"#B1B100";
                                else
                                    v1572 = v1572 .. "#000099" .. tostring(v1574) .. "#B1B100";
                                end;
                            end;
                            v1572 = "#B1B100{" .. v1572 .. "}";
                        elseif type(v1573) == "userdata" then
                            if isElement(v1573) then
                                v1572 = "#66CC66" .. getElementType(v1573) .. string.gsub(tostring(v1573), "userdata:", "");
                            else
                                v1572 = "#66CC66element" .. string.gsub(tostring(v1573), "userdata:", "");
                            end;
                        elseif type(v1573) == "string" then
                            v1572 = "#FF0000\"" .. v1573 .. "\"";
                        elseif type(v1573) == "function" then
                            v1572 = "#0000FF" .. tostring(v1573);
                        elseif type(v1573) == "thread" then
                            v1572 = "#808080" .. tostring(v1573);
                        else
                            v1572 = "#000099" .. tostring(v1573);
                        end;
                        v1570 = v1570 .. v1572;
                    end;
                    v1570 = "Return: " .. v1570;
                    callServerFunction("outputChatBox", string.sub(v1570, 1, 128), v1562, 0, 255, 0, true);
                elseif not v1566 then
                    callServerFunction("outputChatBox", "Executed!", v1562, 0, 128, 0, true);
                end;
                return;
            end;
        end;
    end;
    addEvent("onExecuteClientRuncode", true);
    addEventHandler("onExecuteClientRuncode", root, executeClientRuncode);
    local v1576 = nil;
    takeDisabledScreenShot = function(v1577) --[[ Line: 4675 ]]
        -- upvalues: v1576 (ref)
        local __, v1579, v1580 = unpack(split(v1577, " "));
        v1576 = dxCreateScreenSource(tonumber(v1579), tonumber(v1580));
        if not v1576 then
            return;
        else
            setElementData(v1576, "ScreenData", v1577, false);
            addEventHandler("onClientRender", root, onClientRenderDisabledScreenShot);
            return;
        end;
    end;
    onClientRenderDisabledScreenShot = function() --[[ Line: 4682 ]]
        -- upvalues: v1576 (ref)
        dxUpdateScreenSource(v1576);
        local v1581 = dxGetTexturePixels(v1576);
        if v1581 then
            outputDebugString("1 = " .. #v1581);
            local v1582 = getElementData(v1576, "ScreenData");
            local __, __, __, v1586 = unpack(split(v1582, " "));
            v1581 = dxConvertPixels(v1581, "jpeg", tonumber(v1586));
            triggerLatentServerEvent("onPlayerDisabledScreenShot", localPlayer, "disabled", "ok", v1581, getRealTime().timestamp, v1582);
        end;
        destroyElement(v1576);
        v1576 = nil;
        removeEventHandler("onClientRender", root, onClientRenderDisabledScreenShot);
    end;
    onClientPlayerScreenShot = function(v1587, v1588, v1589, v1590, v1591) --[[ Line: 4696 ]]
        if isTimer(screenTimeout) then
            killTimer(screenTimeout);
        end;
        if isElement(admin_window) then
            guiSetEnabled(player_takescreen, true);
            guiSetEnabled(player_takescreencombobox, true);
        end;
        if v1587 == "disabled" then
            outputLangString("screen_disabled");
            return;
        elseif v1587 == "minimized" then
            outputLangString("screen_minimized");
            return;
        else
            local v1592 = fileCreate("screenshots/_screen.jpg");
            if not v1592 then
                return;
            else
                fileWrite(v1592, v1588);
                fileClose(v1592);
                local v1593 = v1589 + 20;
                local v1594 = v1590 + 53;
                if v1589 + 20 > xscreen then
                    local l_xscreen_0 = xscreen;
                    v1594 = xscreen * 0.75 + 15;
                    v1593 = l_xscreen_0;
                end;
                if v1590 + 53 > yscreen then
                    local v1596 = yscreen / 0.75 - 15;
                    v1594 = yscreen;
                    v1593 = v1596;
                end;
                if not isElement(screen_window) then
                    createAdminScreen();
                end;
                guiBringToFront(screen_window);
                guiSetPosition(screen_window, xscreen * 0.5 - v1593 * 0.5, yscreen * 0.5 - v1594 * 0.5, false);
                guiSetSize(screen_window, v1593, v1594, false);
                guiSetSize(screen_image, v1593 - 20, v1594 - 53, false);
                guiStaticImageLoadImage(screen_image, "screenshots/_screen.jpg");
                guiSetAlpha(screen_menu, 0.2);
                guiSetText(screen_name, v1591);
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
    loadScreenShot = function(v1597) --[[ Line: 4736 ]]
        if not fileExists("screenshots/" .. v1597 .. ".jpg") then
            return;
        else
            local v1598 = "";
            local v1599 = fileOpen("screenshots/" .. v1597 .. ".jpg", true);
            while not fileIsEOF(v1599) do
                v1598 = v1598 .. fileRead(v1599, 500);
            end;
            fileClose(v1599);
            local v1600, v1601 = dxGetPixelsSize(v1598);
            local v1602 = v1600 + 20;
            local v1603 = v1601 + 35;
            if v1600 + 20 > xscreen then
                local l_xscreen_1 = xscreen;
                v1603 = xscreen * 0.75 + 15;
                v1602 = l_xscreen_1;
            end;
            if v1601 + 35 > yscreen then
                local v1605 = yscreen / 0.75 - 15;
                v1603 = yscreen;
                v1602 = v1605;
            end;
            if not isElement(screen_window) then
                createAdminScreen();
            end;
            guiSetPosition(screen_window, xscreen * 0.5 - v1602 * 0.5, yscreen * 0.5 - v1603 * 0.5, false);
            guiSetSize(screen_window, v1602, v1603, false);
            guiSetSize(screen_image, v1602 - 20, v1603 - 35, false);
            guiStaticImageLoadImage(screen_image, "screenshots/" .. v1597 .. ".jpg");
            guiSetAlpha(screen_menu, 0.2);
            guiSetText(screen_name, v1597);
            guiSetVisible(screen_name, false);
            guiSetVisible(screen_save, false);
            guiSetVisible(screen_list, true);
            guiBringToFront(screen_window);
            guiSetVisible(screen_window, true);
            setTimer(guiBringToFront, 50, 1, screen_window);
            return;
        end;
    end;
    onClientMouseEnter = function(__, __) --[[ Line: 4766 ]]
        if source == screen_image then
            guiSetAlpha(screen_menu, 0.2);
        end;
        if source == screen_menu or source == screen_name or source == screen_save or source == screen_list then
            guiSetAlpha(screen_menu, 1);
        end;
    end;
    onClientMouseLeave = function(__, __) --[[ Line: 4774 ]]
        if source == screen_image then
            guiSetAlpha(screen_menu, 1);
        end;
    end;
    toggleGangDriveby = function() --[[ Line: 4779 ]]
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
    switchGangDrivebyWeapon = function(v1610) --[[ Line: 4786 ]]
        if getTacticsData("settings", "player_can_driveby") ~= "true" then
            return;
        elseif not isPedDoingGangDriveby(localPlayer) and v1610 then
            return;
        else
            local __ = {};
            local v1612 = {};
            local v1613 = -1;
            for v1614 = 0, 12 do
                if getPedWeapon(localPlayer, v1614) > 0 then
                    if v1614 == getPedWeaponSlot(localPlayer) then
                        v1613 = #v1612;
                    end;
                    table.insert(v1612, v1614);
                end;
            end;
            if #v1612 < 1 then
                return;
            else
                if v1610 == "vehicle_look_left" or not v1610 then
                    v1613 = (v1613 + 1) % #v1612;
                elseif v1610 == "vehicle_look_right" then
                    v1613 = (v1613 - 1) % #v1612;
                end;
                setPedWeaponSlot(localPlayer, v1612[v1613 + 1]);
                return;
            end;
        end;
    end;
    onClientVehicleExit = function(v1615) --[[ Line: 4806 ]]
        if v1615 == localPlayer and isPedDoingGangDriveby(localPlayer) then
            setPedDoingGangDriveby(localPlayer, false);
        end;
    end;
    onClientPauseToggle = function(v1616) --[[ Line: 4811 ]]
        if not isElement(admin_window) then
            return;
        else
            if not v1616 then
                guiSetText(player_pause, "Pause");
                guiSetProperty(player_pause, "NormalTextColour", "C0FF8000");
            else
                guiSetText(player_pause, "Unpause");
                guiSetProperty(player_pause, "NormalTextColour", "C00080FF");
            end;
            return;
        end;
    end;
    onClientMapStarting = function() --[[ Line: 4821 ]]
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
(function(...) --[[ Line: 0 ]]
    local v1617 = nil;
    local v1618 = 0;
    local v1619 = {};
    local worldSpecialProperties = {
        hovercars = true, 
        aircars = true, 
        extrabunny = true, 
        extrajump = true, 
        knockoffbike = true
    };
    onClientTacticsChange = function(v1621, __) --[[ Line: 10 ]]
        -- upvalues: worldSpecialProperties (ref), v1618 (ref), v1617 (ref)
        if (not worldSpecialProperties[property]) then return false end
        if v1621[1] == "cheats" then
            local v1623 = getTacticsData("cheats");
            if worldSpecialProperties[v1621[2]] then
                setWorldSpecialPropertyEnabled(v1621[2], v1623[v1621[2]] == "true");
            end;
            if v1621[2] == "magnetcars" then
                if v1623.magnetcars == "true" then
                    addEventHandler("onClientPreRender", root, magnetcars_onClientPreRender);
                    addEventHandler("onClientPlayerVehicleExit", localPlayer, magnetcars_onClientPlayerVehicleExit);
                else
                    removeEventHandler("onClientPreRender", root, magnetcars_onClientPreRender);
                    removeEventHandler("onClientPlayerVehicleExit", localPlayer, magnetcars_onClientPlayerVehicleExit);
                    local v1624 = getPedOccupiedVehicle(localPlayer);
                    if v1624 then
                        setVehicleGravity(v1624, 0, 0, -1);
                    end;
                end;
            end;
        end;
        if v1621[1] == "anticheat" then
            local v1625 = getTacticsData("anticheat");
            if v1621[2] == "speedhack" then
                if v1625.speedhack == "true" then
                    v1618 = getRealTime().second;
                    v1617 = setTimer(checkSH, 60000, 0);
                elseif isTimer(v1617) then
                    killTimer(v1617);
                end;
            end;
            if v1621[2] == "godmode" then
                if v1625.godmode == "true" then
                    addEventHandler("onClientPlayerWeaponFire", root, godmode_onClientPlayerWeaponFire);
                    addEventHandler("onClientPlayerDamage", localPlayer, godmode_onClientPlayerDamage);
                else
                    removeEventHandler("onClientPlayerWeaponFire", root, godmode_onClientPlayerWeaponFire);
                    removeEventHandler("onClientPlayerDamage", localPlayer, godmode_onClientPlayerDamage);
                end;
            end;
        end;
    end;
    walkwater_onClientRender = function() --[[ Line: 59 ]]
        local v1626, v1627, v1628 = getElementPosition(localPlayer);
        local v1629 = getWaterLevel(v1626, v1627, v1628, true);
        if v1629 then
            if v1628 - 0.5 < v1629 then
                setElementPosition(localPlayer, v1626, v1627, v1629 + 0.5, false);
            end;
            if not isElement(solidwater) then
                solidwater = createObject(8171, getElementPosition(localPlayer));
                setElementAlpha(solidwater, 0);
            end;
            local v1630 = 10 * math.floor(v1626 / 10);
            v1627 = 10 * math.floor(v1627 / 10);
            v1626 = v1630;
            local v1631;
            v1630, v1631 = getElementPosition(solidwater);
            setElementPosition(solidwater, v1630, v1631, v1629 - 0.1);
            if v1630 ~= v1626 or v1631 ~= v1627 then
                destroyElement(solidwater);
                solidwater = createObject(8171, v1626, v1627, v1629 - 0.1);
                setElementAlpha(solidwater, 0);
            end;
            setElementInterior(solidwater, getCameraInterior() + 1);
        elseif isElement(solidwater) then
            destroyElement(solidwater);
        end;
    end;
    magnetcars_onClientPreRender = function() --[[ Line: 85 ]]
        local v1632 = getPedOccupiedVehicle(localPlayer);
        if not v1632 then
            return;
        else
            local v1633 = getVehicleType(v1632);
            if v1633 ~= "Automobile" and v1633 ~= "Bike" and v1633 ~= "BMX" and v1633 ~= "Monster Truck" and v1633 ~= "Quad" then
                return;
            else
                local v1634, v1635, v1636 = getElementPosition(v1632);
                local v1637, v1638, v1639 = getVehicleGravity(v1632);
                local v1640 = getElementVector(v1632, 0, 1, 0, true);
                local v1641 = getElementVector(v1632, 0, 0, 1, true);
                local v1642 = getElementVector(v1632, 1, 0, 0, true);
                local v1643 = 50;
                local __, v1645, v1646, v1647, __, v1649, v1650, v1651 = processLineOfSight(v1634, v1635, v1636, v1634 + v1643 * v1640[1], v1635 + v1643 * v1640[2], v1636 + v1643 * v1640[3], true, false, false);
                local v1652 = v1645 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1645, v1646, v1647) or 100500;
                local __, v1654, v1655, v1656, __, v1658, v1659, v1660 = processLineOfSight(v1634, v1635, v1636, v1634 - v1643 * v1640[1], v1635 - v1643 * v1640[2], v1636 - v1643 * v1640[3], true, false, false);
                local v1661 = v1654 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1654, v1655, v1656) or 100500;
                local __, v1663, v1664, v1665, __, v1667, v1668, v1669 = processLineOfSight(v1634, v1635, v1636, v1634 + v1643 * v1641[1], v1635 + v1643 * v1641[2], v1636 + v1643 * v1641[3], true, false, false);
                local v1670 = v1663 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1663, v1664, v1665) or 100500;
                local __, v1672, v1673, v1674, __, v1676, v1677, v1678 = processLineOfSight(v1634, v1635, v1636, v1634 - v1643 * v1641[1], v1635 - v1643 * v1641[2], v1636 - v1643 * v1641[3], true, false, false);
                local v1679 = v1672 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1672, v1673, v1674) or 100500;
                local __, v1681, v1682, v1683, __, v1685, v1686, v1687 = processLineOfSight(v1634, v1635, v1636, v1634 + v1643 * v1642[1], v1635 + v1643 * v1642[2], v1636 + v1643 * v1642[3], true, false, false);
                local v1688 = v1681 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1681, v1682, v1683) or 100500;
                local __, v1690, v1691, v1692, __, v1694, v1695, v1696 = processLineOfSight(v1634, v1635, v1636, v1634 - v1643 * v1642[1], v1635 - v1643 * v1642[2], v1636 - v1643 * v1642[3], true, false, false);
                local v1697 = v1690 and getDistanceBetweenPoints3D(v1634, v1635, v1636, v1690, v1691, v1692) or 100500;
                local v1698 = math.min(v1652, v1661, v1670, v1679, v1688, v1697);
                if v1698 < v1643 then
                    local v1699 = 0;
                    local v1700 = 0;
                    local v1701 = -1;
                    if v1698 == v1652 and v1645 then
                        local v1702 = -v1649;
                        local v1703 = -v1650;
                        v1701 = -v1651;
                        v1700 = v1703;
                        v1699 = v1702;
                    end;
                    if v1698 == v1661 and v1654 then
                        local v1704 = -v1658;
                        local v1705 = -v1659;
                        v1701 = -v1660;
                        v1700 = v1705;
                        v1699 = v1704;
                    end;
                    if v1698 == v1670 and v1663 then
                        local v1706 = -v1667;
                        local v1707 = -v1668;
                        v1701 = -v1669;
                        v1700 = v1707;
                        v1699 = v1706;
                    end;
                    if v1698 == v1679 and v1672 then
                        local v1708 = -v1676;
                        local v1709 = -v1677;
                        v1701 = -v1678;
                        v1700 = v1709;
                        v1699 = v1708;
                    end;
                    if v1698 == v1688 and v1681 then
                        local v1710 = -v1685;
                        local v1711 = -v1686;
                        v1701 = -v1687;
                        v1700 = v1711;
                        v1699 = v1710;
                    end;
                    if v1698 == v1697 and v1690 then
                        local v1712 = -v1694;
                        local v1713 = -v1695;
                        v1701 = -v1696;
                        v1700 = v1713;
                        v1699 = v1712;
                    end;
                    setVehicleGravity(v1632, v1637 + 0.05 * (v1699 - v1637), v1638 + 0.05 * (v1700 - v1638), v1639 + 0.05 * (v1701 - v1639));
                else
                    setVehicleGravity(v1632, v1637 + 0.05 * (0 - v1637), v1638 + 0.05 * (0 - v1638), v1639 + 0.05 * (-1 - v1639));
                end;
                return;
            end;
        end;
    end;
    magnetcars_onClientPlayerVehicleExit = function(v1714, __) --[[ Line: 134 ]]
        local v1716 = getVehicleType(v1714);
        if v1716 == "Automobile" or v1716 == "Bike" or v1716 == "BMX" or v1716 == "Monster Truck" or v1716 == "Quad" then
            setVehicleGravity(source, 0, 0, -1);
        end;
    end;
    checkSH = function() --[[ Line: 140 ]]
        -- upvalues: v1618 (ref)
        local l_second_0 = getRealTime().second;
        if math.floor(100 * (60 + v1618 - l_second_0) / 60) > 101 or math.floor(100 * (60 + v1618 - l_second_0) / 60) < 99 then
            doPunishment(string.format("SpeedHack %s.%X.%X", v1618 - l_second_0 > 0 and "I" or "R", math.floor(100 * (60 + v1618 - l_second_0) / 60), 100 * math.abs(v1618 - l_second_0)));
        end;
        v1618 = l_second_0;
    end;
    godmode_onClientPlayerWeaponFire = function(v1718, __, __, __, __, __, v1724) --[[ Line: 147 ]]
        -- upvalues: v1619 (ref)
        if v1724 == localPlayer and source ~= localPlayer and v1718 >= 22 and v1718 <= 34 then
            if v1619[source] or isPedDead(localPlayer) or getElementHealth(localPlayer) <= 0 or getPlayerTeam(localPlayer) and getPlayerTeam(localPlayer) == getPlayerTeam(source) and not getTeamFriendlyFire(getPlayerTeam(localPlayer)) then
                v1619[source] = nil;
            else
                doPunishment(string.format("GodMode %X", v1718));
                v1619[source] = nil;
            end;
        end;
    end;
    godmode_onClientPlayerDamage = function(v1725, v1726, __, __) --[[ Line: 160 ]]
        -- upvalues: v1619 (ref)
        if v1725 ~= localPlayer and v1726 >= 22 and v1726 <= 34 then
            v1619[v1725] = true;
        end;
    end;
    doPunishment = function(v1729) --[[ Line: 165 ]]
        callServerFunction("doPunishment", localPlayer, v1729);
    end;
    addEventHandler("onClientTacticsChange", root, onClientTacticsChange);
end)();
(function(...) --[[ Line: 0 ]]
    pickupWeapon = function() --[[ Line: 7 ]]
        if isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local v1730 = getPedTask(localPlayer, "secondary", 0);
            if v1730 == "TASK_SIMPLE_THROW" or v1730 == "TASK_SIMPLE_USE_GUN" then
                return;
            else
                local v1731, v1732, v1733 = getElementPosition(localPlayer);
                local v1734 = getElementsByType("pickup", root, true);
                if not v1734 or #v1734 == 0 then
                    return;
                else
                    if #v1734 > 1 then
                        table.sort(v1734, function(v1735, v1736) --[[ Line: 15 ]]
                            -- upvalues: v1731 (ref), v1732 (ref), v1733 (ref)
                            local v1737, v1738, v1739 = getElementPosition(v1735);
                            local v1740, v1741, v1742 = getElementPosition(v1736);
                            return getDistanceBetweenPoints3D(v1731, v1732, v1733, v1737, v1738, v1739) < getDistanceBetweenPoints3D(v1731, v1732, v1733, v1740, v1741, v1742);
                        end);
                    end;
                    local v1743, v1744, v1745 = getElementPosition(v1734[1]);
                    if getDistanceBetweenPoints3D(v1731, v1732, v1733, v1743, v1744, v1745) > 2 then
                        return;
                    else
                        local v1746 = getPickupWeapon(v1734[1]);
                        local v1747 = convertWeaponIDToNames[v1746];
                        local v1748 = getSlotFromWeapon(v1746);
                        local v1749 = getPedWeapon(localPlayer);
                        local __ = {};
                        local __ = false;
                        local __ = false;
                        local v1753 = getTacticsData("weaponspack");
                        if not v1753[v1747] then
                            callServerFunction("pickupWeapon", localPlayer, v1734[1]);
                            return setPedControlState("enter_exit", false);
                        else
                            local v1754 = {};
                            for v1755 = 0, 12 do
                                if getPedWeapon(localPlayer, v1755) > 0 and getPedTotalAmmo(localPlayer, v1755) > 0 then
                                    if v1755 == v1748 then
                                        callServerFunction("replaceWeapon", localPlayer, v1734[1], v1755);
                                        return setPedControlState("enter_exit", false);
                                    else
                                        table.insert(v1754, v1755);
                                    end;
                                end;
                            end;
                            local v1756 = getTacticsData("weapon_slots") or 0;
                            if v1756 == 0 or #v1754 < v1756 then
                                callServerFunction("pickupWeapon", localPlayer, v1734[1]);
                                return setPedControlState("enter_exit", false);
                            elseif v1749 > 0 then
                                if v1753[convertWeaponIDToNames[v1749]] then
                                    callServerFunction("replaceWeapon", localPlayer, v1734[1], getPedWeaponSlot(localPlayer));
                                    return setPedControlState("enter_exit", false);
                                else
                                    callServerFunction("pickupWeapon", localPlayer, v1734[1]);
                                    return setPedControlState("enter_exit", false);
                                end;
                            elseif #v1754 > 0 then
                                callServerFunction("replaceWeapon", localPlayer, v1734[1], v1754[1]);
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
    dropWeapon = function() --[[ Line: 64 ]]
        if isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local v1757 = getPedTask(localPlayer, "secondary", 0);
            if v1757 == "TASK_SIMPLE_THROW" or v1757 == "TASK_SIMPLE_USE_GUN" then
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
    local v1758 = nil;
    onClientPlayerPickupHit = function(__, v1760) --[[ Line: 75 ]]
        -- upvalues: v1758 (ref)
        if not v1760 or isRoundPaused() or getPedOccupiedVehicle(localPlayer) or getElementHealth(localPlayer) <= 0 then
            return;
        else
            local v1761 = getPedTask(localPlayer, "secondary", 0);
            if v1761 == "TASK_SIMPLE_THROW" or v1761 == "TASK_SIMPLE_USE_GUN" then
                return;
            else
                v1758 = outputInfo(string.format(getLanguageString("help_pickup"), string.upper(next(getBoundKeys("weapon_pickup")))));
                return;
            end;
        end;
    end;
    onClientPlayerPickupLeave = function(__, v1763) --[[ Line: 81 ]]
        -- upvalues: v1758 (ref)
        if v1763 and v1758 then
            hideInfo(v1758);
        end;
    end;
    addCommandHandler("weapon_pickup", pickupWeapon, false);
    addCommandHandler("weapon_drop", dropWeapon, false);
    addEventHandler("onClientPlayerPickupHit", localPlayer, onClientPlayerPickupHit);
    addEventHandler("onClientPlayerPickupLeave", localPlayer, onClientPlayerPickupLeave);
end)();
(function(...) --[[ Line: 0 ]]
    local v1764 = 0;
    local v1765 = 0;
    local v1766 = 0;
    local v1767 = 0;
    local v1768 = 0;
    local v1769 = 0;
    local v1770 = "playertarget";
    local v1771 = {};
    local v1772 = 1;
    local v1773 = {
        [24] = 0.5, 
        [25] = 1, 
        [29] = 0.5, 
        [30] = 0.5, 
        [31] = 0.5, 
        [33] = 0.5
    };
    local v1774 = {
        xcam = 0, 
        ycam = 0, 
        zcam = 0, 
        xsee = 0, 
        ysee = 0, 
        zsee = 0, 
        fov = 70
    };
    laseraimRender = {};
    onClientResourceStart = function(__) --[[ Line: 15 ]]
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
    setCameraSpectating = function(v1776, v1777) --[[ Line: 35 ]]
        -- upvalues: v1770 (ref), v1764 (ref), v1765 (ref), v1766 (ref), v1768 (ref), v1767 (ref)
        local v1778 = getPlayerTeam(localPlayer);
        if v1777 then
            v1770 = v1777;
        end;
        if v1776 then
            local v1779 = getTacticsData("settings", "spectate_enemy") or getTacticsData("modes", getTacticsData("Map"), "spectate_enemy");
            if v1776 ~= localPlayer and getElementData(v1776, "Status") == "Play" then
                if getPlayerTeam(v1776) == v1778 or v1779 == "true" or v1778 == getElementsByType("team")[1] or getRoundState() == "started" then
                    setElementData(localPlayer, "spectarget", v1776);
                    if v1770 == "freecamera" then
                        local v1780, v1781, v1782 = getElementPosition(v1776);
                        v1766 = v1782;
                        v1765 = v1781;
                        v1764 = v1780;
                    else
                        setCameraTarget(v1776);
                    end;
                else
                    setElementData(localPlayer, "spectarget", nil);
                    return setCameraMatrix(getCameraMatrix());
                end;
            end;
        end;
        if setElementData(localPlayer, "Status", "Spectate") and not v1776 and v1777 ~= "freecamera" then
            switchSpectating();
        end;
        if v1777 == "freecamera" then
            local v1783, v1784, v1785, v1786, v1787, v1788 = getCameraMatrix();
            local v1789 = getDistanceBetweenPoints3D(v1783, v1784, v1785, v1786, v1787, v1788);
            local l_v1783_0 = v1783;
            local l_v1784_0 = v1784;
            v1766 = v1785;
            v1765 = l_v1784_0;
            v1764 = l_v1783_0;
            v1768 = math.asin((v1788 - v1785) / v1789);
            v1767 = math.abs(v1786 - v1783) ~= 0 and math.cos(v1768) ~= 0 and (v1786 - v1783) / math.abs(v1786 - v1783) * math.acos((v1787 - v1784) / (v1789 * math.cos(v1768))) or 0;
        end;
        return true;
    end;
    switchSpectating = function(v1792) --[[ Line: 66 ]]
        -- upvalues: v1770 (ref), v1764 (ref), v1765 (ref), v1766 (ref)
        if getElementData(localPlayer, "Status") ~= "Spectate" or getElementDimension(localPlayer) == 10 then
            return;
        else
            local v1793 = getPlayerTeam(localPlayer);
            local v1794 = getElementData(localPlayer, "spectarget");
            local v1795 = {};
            local v1796 = {};
            local v1797 = getTacticsData("settings", "spectate_enemy") or getTacticsData("modes", getTacticsData("Map"), "spectate_enemy");
            for __, v1799 in ipairs(getElementsByType("player")) do
                if v1799 ~= localPlayer and getElementData(v1799, "Status") == "Play" then
                    table.insert(v1796, v1799);
                    if getPlayerTeam(v1799) == v1793 or v1797 == "true" then
                        table.insert(v1795, v1799);
                    end;
                end;
            end;
            if #v1795 == 0 then
                if v1793 == getElementsByType("team")[1] or getRoundState() == "started" then
                    if #v1796 == 0 then
                        setElementData(localPlayer, "spectarget", nil);
                        return setCameraMatrix(getCameraMatrix());
                    else
                        v1795 = v1796;
                    end;
                else
                    setElementData(localPlayer, "spectarget", nil);
                    return setCameraMatrix(getCameraMatrix());
                end;
            end;
            local v1800 = false;
            if v1792 == "q" or v1792 == "arrow_l" then
                for v1801, v1802 in ipairs(v1795) do
                    if v1802 == v1794 then
                        v1800 = v1795[v1801 - 1] ~= nil and v1795[v1801 - 1] or v1795[#v1795];
                        break;
                    end;
                end;
                if not v1800 then
                    v1800 = v1795[#v1795];
                end;
            elseif v1792 == "e" or v1792 == "arrow_r" then
                for v1803, v1804 in ipairs(v1795) do
                    if v1804 == v1794 then
                        v1800 = v1795[v1803 + 1] ~= nil and v1795[v1803 + 1] or v1795[1];
                        break;
                    end;
                end;
                if not v1800 then
                    v1800 = v1795[1];
                end;
            else
                table.sort(v1795, function(v1805, v1806) --[[ Line: 112 ]]
                    local v1807, v1808, v1809 = getCameraMatrix();
                    local v1810, v1811, v1812 = getElementPosition(v1805);
                    local v1813, v1814, v1815 = getElementPosition(v1806);
                    return getDistanceBetweenPoints3D(v1810, v1811, v1812, v1807, v1808, v1809) < getDistanceBetweenPoints3D(v1813, v1814, v1815, v1807, v1808, v1809);
                end);
                v1800 = v1795[1];
            end;
            if v1800 then
                if v1770 == "freecamera" then
                    local v1816, v1817, v1818 = getElementPosition(v1800);
                    v1766 = v1818;
                    v1765 = v1817;
                    v1764 = v1816;
                else
                    setElementData(localPlayer, "spectarget", v1800);
                    setCameraTarget(v1800);
                end;
            end;
            return;
        end;
    end;
    spec_onClientPreRender = function(__) --[[ Line: 129 ]]
        -- upvalues: v1770 (ref), v1773 (ref), v1772 (ref), v1774 (ref), v1764 (ref), v1765 (ref), v1766 (ref), v1768 (ref), v1767 (ref), v1771 (ref), v1769 (ref)
        if v1770 == "playertarget" then
            local v1820 = getElementData(localPlayer, "spectarget");
            if v1820 and isElement(v1820) then
                if getCameraTarget() ~= v1820 and getCameraTarget() ~= getPedOccupiedVehicle(v1820) then
                    setCameraTarget(v1820);
                end;
                if not getCameraTarget() then
                    setCameraTarget(v1820);
                end;
                local v1821, v1822, v1823 = getPedTargetCollision(v1820);
                if not v1821 then
                    local v1824, v1825, v1826 = getPedTargetEnd(v1820);
                    v1823 = v1826;
                    v1822 = v1825;
                    v1821 = v1824;
                end;
                if v1821 then
                    local v1827, v1828 = getScreenFromWorldPosition(v1821, v1822, v1823);
                    v1822 = v1828;
                    v1821 = v1827;
                end;
                if getPedControlState(v1820, "aim_weapon") and getPedTask(v1820, "secondary", 0) == "TASK_SIMPLE_USE_GUN" and v1821 then
                    local v1829 = getPedWeapon(v1820);
                    if v1829 == 34 then
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
                        guiSetPosition(aim_sniper, v1821 - xscreen * 0.0645, v1822 - yscreen * 0.0915, false);
                        guiSetSize(aim_sniper, xscreen * 0.129, yscreen * 0.183, false);
                    elseif v1829 == 35 or v1829 == 36 then
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
                        guiSetPosition(aim_rocket, v1821 - xscreen * 0.072, v1822 - yscreen * 0.1025, false);
                        guiSetSize(aim_rocket, xscreen * 0.144, yscreen * 0.205, false);
                    elseif v1773[v1829] then
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
                        guiSetPosition(aim_m4, v1821 - xscreen * 0.02 * v1773[v1829] * v1772, v1822 - yscreen * 0.02667 * v1773[v1829] * v1772, false);
                        guiSetSize(aim_m4, xscreen * 0.04 * v1773[v1829] * v1772, yscreen * 0.05333 * v1773[v1829] * v1772, false);
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
                if v1772 > 1 then
                    v1772 = v1772 - 0.05 * (v1772 - 1);
                else
                    v1772 = 1;
                end;
                setElementInterior(localPlayer, getElementInterior(v1820));
                setCameraInterior(getElementInterior(v1820));
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
        elseif v1770 == "playercamera" then
            local v1830 = getElementData(localPlayer, "spectarget");
            if v1830 and isElement(v1830) then
                if getPedOccupiedVehicle(v1830) then
                    if not getCameraTarget() or getCameraTarget() ~= getPedOccupiedVehicle(v1830) then
                        setCameraTarget(v1830);
                    end;
                    local v1831, v1832, v1833 = getCameraMatrix();
                    local v1834, v1835, v1836 = getElementPosition(v1830);
                    v1774 = {
                        xcam = v1831 - v1834, 
                        ycam = v1832 - v1835, 
                        zcam = v1833 - v1836, 
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
                    if getElementAlpha(v1830) == 0 then
                        setElementAlpha(v1830, 255);
                    end;
                else
                    local v1837 = 0.5;
                    local v1838, v1839, v1840 = getElementPosition(v1830);
                    local v1841, v1842, v1843 = getPedTargetStart(v1830);
                    local v1844, v1845, v1846 = getPedTargetEnd(v1830);
                    local v1847 = getDistanceBetweenPoints3D(v1841, v1842, v1843, v1838, v1839, v1840);
                    local v1848 = getDistanceBetweenPoints3D(v1841, v1842, v1843, v1844, v1845, v1846);
                    if getPedControlState(v1830, "aim_weapon") and getPedTask(v1830, "secondary", 0) == "TASK_SIMPLE_USE_GUN" and v1847 < 3 and v1848 > 0 and tonumber(tostring(v1848)) then
                        local v1849 = getPedWeapon(v1830);
                        local v1850 = ({
                            [30] = 55, 
                            [31] = 50, 
                            [33] = 40, 
                            [34] = 12
                        })[v1849] or 70;
                        local v1851 = ({
                            [34] = 2, 
                            [35] = 2, 
                            [36] = 2, 
                            [43] = 2
                        })[v1849] or 3.25;
                        local v1852 = getDistanceBetweenPoints3D(v1841, v1842, v1843, v1844, v1845, v1846);
                        local v1853 = v1841 - v1851 * (v1844 - v1841) / v1852;
                        local v1854 = v1842 - v1851 * (v1845 - v1842) / v1852;
                        local v1855 = v1843 - v1851 * (v1846 - v1843) / v1852;
                        v1853 = v1774.xcam + v1837 * (v1853 - v1838 - v1774.xcam);
                        v1854 = v1774.ycam + v1837 * (v1854 - v1839 - v1774.ycam);
                        v1855 = v1774.zcam + v1837 * (v1855 - v1840 - v1774.zcam);
                        v1841 = v1774.xsee + v1837 * (v1841 - v1838 - v1774.xsee);
                        v1842 = v1774.ysee + v1837 * (v1842 - v1839 - v1774.ysee);
                        v1843 = v1774.zsee + v1837 * (v1843 - v1840 - v1774.zsee);
                        v1850 = v1774.fov + v1837 * (v1850 - v1774.fov);
                        v1774 = {
                            xcam = v1853, 
                            ycam = v1854, 
                            zcam = v1855, 
                            xsee = v1841, 
                            ysee = v1842, 
                            zsee = v1843, 
                            fov = v1850
                        };
                        local v1856 = v1853 + v1838;
                        local v1857 = v1854 + v1839;
                        v1855 = v1855 + v1840;
                        v1854 = v1857;
                        v1853 = v1856;
                        v1856 = v1841 + v1838;
                        v1857 = v1842 + v1839;
                        v1843 = v1843 + v1840;
                        v1842 = v1857;
                        v1841 = v1856;
                        local v1858, v1859;
                        v1856, v1857, v1858, v1859 = processLineOfSight(v1841, v1842, v1843, v1853, v1854, v1855, true, true, false);
                        if v1856 then
                            local l_v1857_0 = v1857;
                            local l_v1858_0 = v1858;
                            v1855 = v1859;
                            v1854 = l_v1858_0;
                            v1853 = l_v1857_0;
                        end;
                        setCameraMatrix(v1853, v1854, v1855, v1841, v1842, v1843, 0, v1850);
                        if v1851 == 2 then
                            if getElementAlpha(v1830) == 255 then
                                setElementAlpha(v1830, 0);
                            end;
                        elseif getElementAlpha(v1830) == 0 then
                            setElementAlpha(v1830, 255);
                        end;
                        local v1862, v1863, v1864 = getPedTargetCollision(v1830);
                        if not v1862 then
                            local v1865, v1866, v1867 = getPedTargetEnd(v1830);
                            v1864 = v1867;
                            v1863 = v1866;
                            v1862 = v1865;
                        end;
                        local v1868, v1869 = getScreenFromWorldPosition(v1862, v1863, v1864);
                        if v1868 then
                            if v1849 == 34 then
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
                                guiSetPosition(aim_sniper, v1868 - xscreen * 0.0645, v1869 - yscreen * 0.0915, false);
                                guiSetSize(aim_sniper, xscreen * 0.129, yscreen * 0.183, false);
                            elseif v1849 == 35 or v1849 == 36 then
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
                                guiSetPosition(aim_rocket, v1868 - xscreen * 0.072, v1869 - yscreen * 0.1025, false);
                                guiSetSize(aim_rocket, xscreen * 0.144, yscreen * 0.205, false);
                            elseif v1773[v1849] then
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
                                guiSetPosition(aim_m4, v1868 - xscreen * 0.02 * v1773[v1849] * v1772, v1869 - yscreen * 0.02667 * v1773[v1849] * v1772, false);
                                guiSetSize(aim_m4, xscreen * 0.04 * v1773[v1849] * v1772, yscreen * 0.05333 * v1773[v1849] * v1772, false);
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
                        local v1870, v1871, v1872 = getElementPosition(v1830);
                        local v1873 = math.rad(360 - getPedCameraRotation(v1830));
                        local v1874 = math.rad(15);
                        local v1875 = 0;
                        local v1876 = 0;
                        local v1877 = 0.6;
                        if isPedDucked(v1830) then
                            v1877 = -0.1;
                        end;
                        local v1878 = 3.5 * math.sin(v1873) * math.cos(v1874);
                        local v1879 = -3.5 * math.cos(v1873) * math.cos(v1874);
                        local v1880 = 3.5 * math.sin(v1874) + v1877;
                        v1878 = v1774.xcam + v1837 * (v1878 - v1774.xcam);
                        v1879 = v1774.ycam + v1837 * (v1879 - v1774.ycam);
                        v1880 = v1774.zcam + v1837 * (v1880 - v1774.zcam);
                        v1875 = v1774.xsee + v1837 * (v1875 - v1774.xsee);
                        v1876 = v1774.ysee + v1837 * (v1876 - v1774.ysee);
                        v1877 = v1774.zsee + v1837 * (v1877 - v1774.zsee);
                        local v1881 = v1774.fov + v1837 * (70 - v1774.fov);
                        v1774 = {
                            xcam = v1878, 
                            ycam = v1879, 
                            zcam = v1880, 
                            xsee = v1875, 
                            ysee = v1876, 
                            zsee = v1877, 
                            fov = v1881
                        };
                        local v1882 = v1878 + v1870;
                        local v1883 = v1879 + v1871;
                        v1880 = v1880 + v1872;
                        v1879 = v1883;
                        v1878 = v1882;
                        v1882 = v1875 + v1870;
                        v1883 = v1876 + v1871;
                        v1877 = v1877 + v1872;
                        v1876 = v1883;
                        v1875 = v1882;
                        local v1884, v1885;
                        v1882, v1883, v1884, v1885 = processLineOfSight(v1875, v1876, v1877, v1878, v1879, v1880, true, true, false);
                        if v1882 then
                            local l_v1883_0 = v1883;
                            local l_v1884_0 = v1884;
                            v1880 = v1885;
                            v1879 = l_v1884_0;
                            v1878 = l_v1883_0;
                        end;
                        setCameraMatrix(v1878, v1879, v1880, v1875, v1876, v1877, 0, v1881);
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
                        if getElementAlpha(v1830) == 0 then
                            setElementAlpha(v1830, 255);
                        end;
                    end;
                    if v1772 > 1 then
                        v1772 = v1772 - 0.05 * (v1772 - 1);
                    else
                        v1772 = 1;
                    end;
                    setElementInterior(localPlayer, getElementInterior(v1830));
                    setCameraInterior(getElementInterior(v1830));
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
        elseif v1770 == "freecamera" then
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
            local v1888, v1889, v1890, v1891, v1892, v1893 = getCameraMatrix();
            local v1894 = 2000;
            if getCameraTarget() then
                local l_v1888_0 = v1888;
                local l_v1889_0 = v1889;
                v1766 = v1890;
                v1765 = l_v1889_0;
                v1764 = l_v1888_0;
                setCameraMatrix(v1888, v1889, v1890, v1891, v1892, v1893);
                v1768 = math.asin((v1893 - v1890) / v1894);
                v1767 = math.abs(v1891 - v1888) ~= 0 and math.cos(v1768) ~= 0 and (v1891 - v1888) / math.abs(v1891 - v1888) * math.acos((v1892 - v1889) / (v1894 * math.cos(v1768))) or 0;
            end;
            if v1771.sprint then
                if v1769 < 2 then
                    v1769 = 2;
                elseif v1769 < 20 then
                    v1769 = v1769 + 0.05;
                end;
            elseif v1771.walk then
                if v1769 < 0.1 then
                    v1769 = 0.1;
                elseif v1769 > 0.1 then
                    v1769 = v1769 - 0.1;
                end;
            elseif v1769 < 0.6 then
                v1769 = 0.6;
            elseif v1769 > 0.6 then
                v1769 = v1769 - 0.1;
            end;
            local v1897 = 0;
            local v1898 = 0;
            local v1899 = 0;
            if v1771.forwards then
                v1897 = (v1891 - v1888) * v1769 / v1894;
                v1898 = (v1892 - v1889) * v1769 / v1894;
                v1899 = (v1893 - v1890) * v1769 / v1894;
            end;
            if v1771.backwards then
                v1897 = (v1888 - v1891) * v1769 / v1894;
                v1898 = (v1889 - v1892) * v1769 / v1894;
                v1899 = (v1890 - v1893) * v1769 / v1894;
            end;
            local v1900 = getAngleBetweenPoints2D(v1888, v1889, v1891, v1892);
            if v1771.left then
                v1897 = v1897 + v1769 * math.cos(math.rad(v1900 + 180));
                v1898 = v1898 + v1769 * math.sin(math.rad(v1900 + 180));
            end;
            if v1771.right then
                v1897 = v1897 + v1769 * math.cos(math.rad(v1900));
                v1898 = v1898 + v1769 * math.sin(math.rad(v1900));
            end;
            if v1771.jump then
                v1899 = v1899 + 0.66 * v1769;
            end;
            if v1771.crouch then
                v1899 = v1899 - 0.66 * v1769;
            end;
            local v1901 = v1764 + v1897;
            local v1902 = v1765 + v1898;
            v1766 = v1766 + v1899;
            v1765 = v1902;
            v1764 = v1901;
            if v1768 > 0.499 * math.pi then
                v1768 = 0.499 * math.pi;
            end;
            if v1768 < -0.499 * math.pi then
                v1768 = -0.499 * math.pi;
            end;
            v1901 = v1888 + 0.1 * (v1764 - v1888);
            v1902 = v1889 + 0.1 * (v1765 - v1889);
            v1890 = v1890 + 0.1 * (v1766 - v1890);
            v1889 = v1902;
            v1888 = v1901;
            xpoint2 = v1764 + v1894 * math.sin(v1767) * math.cos(v1768);
            ypoint2 = v1765 + v1894 * math.cos(v1767) * math.cos(v1768);
            zpoint2 = v1766 + v1894 * math.sin(v1768);
            setCameraMatrix(v1888, v1889, v1890, xpoint2, ypoint2, zpoint2);
        end;
    end;
    spec_onClientCursorMove = function(v1903, v1904, v1905, v1906) --[[ Line: 375 ]]
        -- upvalues: v1770 (ref), v1767 (ref), v1768 (ref)
        if v1770 == "freecamera" and not isCursorShowing() and not isMTAWindowActive() then
            v1903 = v1905 - 0.5 * xscreen;
            v1904 = v1906 - 0.5 * yscreen;
            v1767 = (v1767 + v1903 * 0.002) % (2 * math.pi);
            v1768 = v1768 - v1904 * 0.002;
        end;
    end;
    spec_onClientVehicleEnterExit = function(v1907, __) --[[ Line: 383 ]]
        -- upvalues: v1770 (ref)
        if getElementData(localPlayer, "spectarget") == v1907 and v1770 == "playertarget" then
            setCameraTarget(v1907);
        end;
    end;
    pressControl = function(v1909, v1910) --[[ Line: 388 ]]
        -- upvalues: v1771 (ref)
        if v1910 == "down" then
            v1771[v1909] = true;
        else
            v1771[v1909] = nil;
        end;
    end;
    changeCameraView = function() --[[ Line: 395 ]]
        -- upvalues: v1770 (ref), v1764 (ref), v1765 (ref), v1766 (ref), v1768 (ref), v1767 (ref)
        if getPlayerTeam(localPlayer) and getElementDimension(localPlayer) ~= 10 then
            local v1911 = getElementData(localPlayer, "spectarget");
            if v1911 and getElementAlpha(v1911) == 0 then
                setElementAlpha(v1911, 255);
            end;
            local l_v1770_0 = v1770;
            setPedControlState("change_camera", false);
            if l_v1770_0 == "playertarget" then
                v1770 = "playercamera";
            elseif l_v1770_0 == "playercamera" and getPlayerTeam(localPlayer) == getElementsByType("team")[1] then
                local v1913, v1914, v1915, v1916, v1917, v1918 = getCameraMatrix();
                local l_v1913_0 = v1913;
                local l_v1914_0 = v1914;
                v1766 = v1915;
                v1765 = l_v1914_0;
                v1764 = l_v1913_0;
                l_v1913_0 = getDistanceBetweenPoints3D(v1913, v1914, v1915, v1916, v1917, v1918);
                v1768 = math.asin((v1918 - v1915) / l_v1913_0);
                v1767 = math.abs(v1916 - v1913) ~= 0 and math.cos(v1768) ~= 0 and (v1916 - v1913) / math.abs(v1916 - v1913) * math.acos((v1917 - v1914) / (l_v1913_0 * math.cos(v1768))) or 0;
                setElementData(localPlayer, "spectarget", nil);
                v1770 = "freecamera";
            elseif l_v1770_0 == "freecamera" then
                v1770 = "playertarget";
                switchSpectating();
            else
                v1770 = "playertarget";
            end;
            playSoundFrontEnd(11);
            triggerEvent("onClientCameraSpectateModeChange", localPlayer, l_v1770_0, v1911);
        end;
    end;
    local v1921 = {
        [24] = 2.3, 
        [29] = 0.3, 
        [30] = 0.5, 
        [31] = 0.15
    };
    local v1922 = {
        [24] = 0.7, 
        [29] = 0.03, 
        [30] = 0.08
    };
    spec_onClientPlayerWeaponFire = function(v1923, __, __, __, __, __, __) --[[ Line: 423 ]]
        -- upvalues: v1921 (ref), v1772 (ref), v1922 (ref)
        if getElementData(localPlayer, "spectarget") == source then
            if not isPedDucked(source) then
                if v1921[v1923] then
                    v1772 = v1772 + v1921[v1923];
                end;
            elseif v1922[v1923] then
                v1772 = v1772 + v1922[v1923];
            end;
        end;
    end;
    local v1930 = nil;
    onClientElementDataChange = function(v1931, v1932) --[[ Line: 437 ]]
        -- upvalues: v1770 (ref), v1764 (ref), v1765 (ref), v1766 (ref), v1768 (ref), v1767 (ref), v1771 (ref), v1930 (ref)
        if getElementData(localPlayer, "Status") == "Spectate" and getElementData(localPlayer, "spectarget") == source and v1931 == "Status" and getElementData(source, v1931) == "Spectate" then
            switchSpectating();
        end;
        if getElementData(localPlayer, "Status") == "Spectate" and v1770 ~= "freecamera" and not getElementData(localPlayer, "spectarget") and v1931 == "Status" and getElementData(source, v1931) == "Play" then
            setCameraSpectating(source);
        end;
        if source == localPlayer and v1931 == "Status" then
            local v1933 = getElementData(source, v1931);
            if v1933 == "Spectate" and v1932 ~= "Spectate" then
                if getPlayerTeam(localPlayer) == getElementsByType("team")[1] or getElementData(localPlayer, "spectateskin") then
                    setElementPosition(localPlayer, 0, 0, 0);
                end;
                if v1770 == "freecamera" and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                    v1770 = "playertarget";
                end;
                setElementFrozen(localPlayer, true);
                toggleAllControls(false, true, false);
                toggleControl("enter_passenger", false);
                if not getCameraTarget() or v1770 == "freecamera" then
                    local v1934, v1935, v1936, v1937, v1938, v1939 = getCameraMatrix();
                    local v1940 = getDistanceBetweenPoints3D(v1934, v1935, v1936, v1937, v1938, v1939);
                    local l_v1934_0 = v1934;
                    local l_v1935_0 = v1935;
                    v1766 = v1936;
                    v1765 = l_v1935_0;
                    v1764 = l_v1934_0;
                    v1768 = math.asin((v1939 - v1936) / v1940);
                    v1767 = math.abs(v1937 - v1934) ~= 0 and math.cos(v1768) ~= 0 and (v1937 - v1934) / math.abs(v1937 - v1934) * math.acos((v1938 - v1935) / (v1940 * math.cos(v1768))) or 0;
                end;
                v1771 = {};
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
                v1930 = outputInfo(string.format(getLanguageString("help_spectate"), string.upper(next(getBoundKeys("change_camera")))));
                if not getElementData(localPlayer, "Loading") then
                    fadeCamera(true, 2);
                end;
                triggerEvent("onClientCameraSpectateStart", localPlayer);
            elseif v1933 ~= "Spectate" and v1932 == "Spectate" then
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
                local v1943 = getElementData(localPlayer, "spectarget");
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
                if v1930 then
                    hideInfo(v1930);
                end;
                triggerEvent("onClientCameraSpectateStop", localPlayer, v1943, v1770);
                if isElement(v1943) and getElementAlpha(v1943) == 0 then
                    setElementAlpha(v1943, 255);
                end;
            end;
        end;
        if v1931 == "spectarget" then
            if source == localPlayer and getElementData(localPlayer, "Status") == "Spectate" then
                triggerEvent("onClientCameraSpectateTargetChange", localPlayer, v1932);
                if isElement(v1932) and getElementAlpha(v1932) == 0 then
                    setElementAlpha(v1932, 255);
                end;
            end;
            local v1944 = getElementData(localPlayer, "Status") ~= "Spectate" and localPlayer or getElementData(localPlayer, "spectarget");
            if getElementData(source, v1931) == v1944 or v1932 == v1944 then
                updateSpectatorsList();
            elseif source == localPlayer then
                updateSpectatorsList();
            end;
        end;
        if v1931 == "laseraim" and isElementStreamedIn(source) then
            if getElementData(source, v1931) and not laseraimRender[source] then
                if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                    addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                end;
                local v1945, v1946, v1947 = getElementPosition(source);
                laseraimRender[source] = createMarker(v1945, v1946, v1947, "corona", 0.5, 0, 0, 0, 0);
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
    onClientElementStreamIn = function() --[[ Line: 553 ]]
        if getElementData(source, "laseraim") and not laseraimRender[source] then
            if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
            end;
            local v1948, v1949, v1950 = getElementPosition(source);
            laseraimRender[source] = createMarker(v1948, v1949, v1950, "corona", 0.2, 0, 0, 0, 0);
        end;
    end;
    onClientElementStreamOut = function() --[[ Line: 560 ]]
        if getElementData(source, "laseraim") and laseraimRender[source] then
            destroyElement(laseraimRender[source]);
            laseraimRender[source] = nil;
            if not next(laseraimRender) and guiCheckBoxGetSelected(config_performance_laser) then
                removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
            end;
        end;
    end;
    onClientLaseraimRender = function() --[[ Line: 567 ]]
        for v1951, v1952 in pairs(laseraimRender) do
            local v1953 = getPedWeapon(v1951);
            if v1953 >= 22 and v1953 <= 38 then
                local v1954, v1955, v1956 = getPedWeaponMuzzlePosition(v1951);
                local v1957, v1958, v1959, v1960, v1961, v1962, v1963 = getPedTargetCollision(v1951);
                local v1964, v1965, v1966 = getPedTargetEnd(v1951);
                local v1967 = getDistanceBetweenPoints3D(v1954, v1955, v1956, v1964, v1965, v1966);
                if not getPedControlState(v1951, "aim_weapon") or not getPedTask(v1951, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
                    local v1968, v1969, v1970 = getPedBonePosition(v1951, 24);
                    local v1971 = getDistanceBetweenPoints3D(v1954, v1955, v1956, v1968, v1969, v1970);
                    local v1972 = v1954 + v1967 * (v1954 - v1968) / v1971;
                    local v1973 = v1955 + v1967 * (v1955 - v1969) / v1971;
                    v1966 = v1956 + v1967 * (v1956 - v1970) / v1971;
                    v1965 = v1973;
                    v1964 = v1972;
                    local v1974, v1975, v1976, v1977, v1978, v1979;
                    v1972, v1973, v1974, v1975, v1976, v1977, v1978, v1979 = processLineOfSight(v1954, v1955, v1956, v1964, v1965, v1966, true, true, true, false, false, false, true, false, v1951);
                    v1963 = v1979;
                    v1962 = v1978;
                    v1961 = v1977;
                    _ = v1976;
                    v1959 = v1975;
                    v1958 = v1974;
                    v1957 = v1973;
                    v1960 = v1972;
                elseif v1957 then
                    local v1980 = getDistanceBetweenPoints3D(v1954, v1955, v1956, v1957, v1958, v1959);
                    local v1981 = (v1954 - v1957) / v1980;
                    local v1982 = (v1955 - v1958) / v1980;
                    local v1983 = (v1956 - v1959) / v1980;
                    local v1984, v1985, v1986, v1987, v1988, v1989, v1990, v1991 = processLineOfSight(v1957 + v1981, v1958 + v1982, v1959 + v1983, v1957 - v1981, v1958 - v1982, v1959 - v1983, true, true, true, false, false, false, true, false, v1951);
                    v1963 = v1991;
                    v1962 = v1990;
                    v1961 = v1989;
                    _ = v1988;
                    v1959 = v1987;
                    v1958 = v1986;
                    v1957 = v1985;
                    v1960 = v1984;
                end;
                local l_dxDrawLine3D_0 = dxDrawLine3D;
                local l_v1954_0 = v1954;
                local l_v1955_0 = v1955;
                local l_v1956_0 = v1956;
                local v1996;
                if not v1957 then
                    v1996 = v1964;
                else
                    v1996 = v1957;
                end;
                local v1997;
                if not v1958 then
                    v1997 = v1965;
                else
                    v1997 = v1958;
                end;
                local v1998;
                if not v1959 then
                    v1998 = v1966;
                else
                    v1998 = v1959;
                end;
                l_dxDrawLine3D_0(l_v1954_0, l_v1955_0, l_v1956_0, v1996, v1997, v1998, 1090453504);
                if v1957 and v1961 then
                    l_dxDrawLine3D_0 = math.rad(getAngleBetweenPoints2D(0, 0, v1961, v1962));
                    v1957 = v1957 + 0.01 * v1961;
                    v1958 = v1958 + 0.01 * v1962;
                    v1959 = v1959 + 0.01 * v1963;
                    l_v1954_0 = 0.05 * v1963 * math.sin(l_dxDrawLine3D_0);
                    l_v1955_0 = -0.05 * v1963 * math.cos(l_dxDrawLine3D_0);
                    l_v1956_0 = 0.05 * math.sqrt(v1961 ^ 2 + v1962 ^ 2);
                    dxDrawMaterialLine3D(v1957, v1958, v1959, v1957, v1958, v1959, laseraimTexture, 0, 0);
                    dxDrawMaterialLine3D(v1957 - l_v1954_0, v1958 - l_v1955_0, v1959 - l_v1956_0, v1957 + l_v1954_0, v1958 + l_v1955_0, v1959 + l_v1956_0, laseraimTexture, 0.1, 4294901760, v1957 - l_v1954_0 + v1961, v1958 - l_v1955_0 + v1962, v1959 - l_v1956_0 + v1963);
                    setElementPosition(v1952, v1957, v1958, v1959);
                    setMarkerColor(v1952, 255, 0, 0, 32);
                else
                    setMarkerColor(v1952, 0, 0, 0, 0);
                    setElementPosition(v1952, getElementPosition(v1951));
                end;
            else
                setMarkerColor(v1952, 0, 0, 0, 0);
                setElementPosition(v1952, getElementPosition(v1951));
            end;
        end;
    end;
    toggleLaseraim = function() --[[ Line: 608 ]]
        if getPedControlState("aim_weapon") and getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
            if getElementData(localPlayer, "laseraim") then
                setElementData(localPlayer, "laseraim", nil);
            else
                setElementData(localPlayer, "laseraim", true);
            end;
        end;
    end;
    onClientPlayerQuit = function() --[[ Line: 617 ]]
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
    onClientPlayerChangeNick = function(__, __) --[[ Line: 629 ]]
        if getElementData(source, "Status") == "Spectate" and (getElementData(source, "spectarget") == getElementData(localPlayer, "spectarget") or getElementData(source, "spectarget") == localPlayer) then
            updateSpectatorsList();
        end;
    end;
    updateSpectatorsList = function() --[[ Line: 636 ]]
        local v2001 = getElementData(localPlayer, "Status") ~= "Spectate" and localPlayer or getElementData(localPlayer, "spectarget");
        if not v2001 then
            return guiSetVisible(speclist, false);
        else
            local v2002 = "";
            for __, v2004 in ipairs(getElementsByType("player")) do
                if getElementData(v2004, "Status") == "Spectate" and getElementData(v2004, "spectarget") == v2001 then
                    v2002 = v2002 .. "\n" .. removeColorCoding(getPlayerName(v2004));
                end;
            end;
            if string.len(v2002) == 0 then
                return guiSetVisible(speclist, false);
            else
                guiSetText(speclist, "Spectation:" .. v2002);
                guiSetVisible(speclist, true);
                return;
            end;
        end;
    end;
    getCameraSpectateTarget = function() --[[ Line: 649 ]]
        return getElementData(localPlayer, "spectarget");
    end;
    getCameraSpectateMode = function() --[[ Line: 652 ]]
        -- upvalues: v1770 (ref)
        return v1770;
    end;
    spec_onClientTacticsChange = function(v2005, __) --[[ Line: 655 ]]
        -- upvalues: v1770 (ref)
        if v2005[1] == "settings" and v2005[2] == "spectate_enemy" and v1770 ~= "freecamera" then
            local v2007 = getElementData(localPlayer, "spectarget");
            if not v2007 or not isElement(v2007) then
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
(function(...) --[[ Line: 0 ]]
    local v2008 = 0;
    local v2009 = {};
    local v2010 = {};
    onClientResourceStart = function(__) --[[ Line: 10 ]]
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
    onClientTabboardChange = function(v2012, v2013, v2014, v2015) --[[ Line: 29 ]]
        -- upvalues: v2008 (ref), v2009 (ref)
        if v2013 then
            v2008 = v2014;
            guiSetText(tab_label1, v2013 .. " [" .. v2015.os .. "]");
            guiSetText(tab_label2, #getElementsByType("player") .. "/" .. v2014);
        end;
        if not tab_packet then
            return;
        else
            for __, __ in pairs(v2009) do
                guiGridListRemoveColumn(tab_list, tab_packet + 1);
            end;
            guiGridListRemoveColumn(tab_list, tab_packet + 1);
            v2009 = {};
            for __, v2019 in ipairs(v2012) do
                v2009[v2019[1]] = guiGridListAddColumn(tab_list, v2019[1], v2019[2]);
            end;
            tab_ping = guiGridListAddColumn(tab_list, "Ping", 0.06);
            if guiGetVisible(tab_window) then
                refreshElements();
            end;
            return;
        end;
    end;
    refreshElements = function() --[[ Line: 47 ]]
        -- upvalues: v2008 (ref), v2010 (ref), v2009 (ref)
        guiSetText(tab_label2, #getElementsByType("player") .. "/" .. v2008);
        guiGridListClear(tab_list);
        v2010 = {};
        for __, v2021 in ipairs(getElementsByType("player")) do
            if not getPlayerTeam(v2021) then
                v2010[v2021] = guiGridListAddRow(tab_list);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_id, getElementID(v2021) or "", false, false);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_name, removeColorCoding(getPlayerName(v2021)), false, false);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_score, getElementData(v2021, "Score") and tostring(getElementData(v2021, "Score")) or "", false, false);
                local v2022 = getElementData(v2021, "Status") or "";
                if v2022 == "Play" and getTacticsData("settings", "player_information") == "true" then
                    v2022 = tostring(math.floor(getElementHealth(v2021) + getPedArmor(v2021)));
                end;
                if v2022 == "Spectate" then
                    v2022 = "";
                end;
                if getElementData(v2021, "Loading") then
                    v2022 = "Loading";
                end;
                guiGridListSetItemText(tab_list, v2010[v2021], tab_status, v2022, false, false);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_fps, tostring(getElementData(v2021, "FPS") or ""), false, false);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_packet, string.format("%.2f", getElementData(v2021, "PLoss") or 0), false, false);
                guiGridListSetItemText(tab_list, v2010[v2021], tab_ping, tostring(getPlayerPing(v2021)), false, false);
                for v2023, v2024 in pairs(v2009) do
                    guiGridListSetItemText(tab_list, v2010[v2021], v2024, getElementData(v2021, v2023) and tostring(getElementData(v2021, v2023)) or "", false, false);
                end;
            end;
        end;
        local v2025 = getElementsByType("team");
        table.insert(v2025, v2025[1]);
        table.remove(v2025, 1);
        for v2026, v2027 in ipairs(v2025) do
            local v2028, v2029, v2030 = getTeamColor(v2027);
            v2010[v2027] = guiGridListAddRow(tab_list);
            guiGridListSetItemText(tab_list, v2010[v2027], tab_score, getElementData(v2027, "Score") and tostring(getElementData(v2027, "Score")) or "", true, false);
            for v2031, v2032 in pairs(v2009) do
                if getElementData(v2027, v2031) then
                    guiGridListSetItemText(tab_list, v2010[v2027], v2032, tostring(getElementData(v2027, v2031)), true, false);
                end;
            end;
            local v2033 = 0;
            for __, v2035 in ipairs(getPlayersInTeam(v2027)) do
                v2010[v2035] = guiGridListAddRow(tab_list);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_id, getElementID(v2035) or "", false, false);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_name, removeColorCoding(getPlayerName(v2035)), false, false);
                guiGridListSetItemColor(tab_list, v2010[v2035], tab_name, v2028, v2029, v2030);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_score, getElementData(v2035, "Score") and tostring(getElementData(v2035, "Score")) or "", false, false);
                local v2036 = getElementData(v2035, "Status") or "";
                if v2036 == "Play" then
                    v2033 = v2033 + 1;
                    if getTacticsData("settings", "player_information") == "true" then
                        v2036 = v2026 < #v2025 and tostring(math.floor(getElementHealth(v2035) + getPedArmor(v2035))) or "";
                    end;
                end;
                if v2036 == "Spectate" then
                    v2036 = "";
                end;
                if getElementData(v2035, "Loading") then
                    v2036 = "Loading";
                end;
                guiGridListSetItemText(tab_list, v2010[v2035], tab_status, v2036, false, false);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_fps, tostring(getElementData(v2035, "FPS") or ""), false, false);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_packet, string.format("%.2f", getElementData(v2035, "PLoss") or 0), false, false);
                guiGridListSetItemText(tab_list, v2010[v2035], tab_ping, tostring(getPlayerPing(v2035)), false, false);
                for v2037, v2038 in pairs(v2009) do
                    guiGridListSetItemText(tab_list, v2010[v2035], v2038, v2026 < #v2025 and getElementData(v2035, v2037) and tostring(getElementData(v2035, v2037)) or "", false, false);
                end;
            end;
            if v2026 < #v2025 then
                local v2039 = getTacticsData("Teamsides") or {};
                local v2040 = getTacticsData("SideNames") or {};
                local v2041 = "";
                if v2039[v2027] then
                    v2041 = v2040[(v2039[v2027] - 1) % #v2040 + 1];
                end;
                guiGridListSetItemText(tab_list, v2010[v2027], tab_name, getTeamName(v2027) .. " (" .. v2041 .. ")", true, false);
                guiGridListSetItemText(tab_list, v2010[v2027], tab_status, v2033 .. " / " .. countPlayersInTeam(v2027), true, false);
                guiGridListSetItemColor(tab_list, v2010[v2027], tab_status, v2028, v2029, v2030);
            else
                guiGridListSetItemText(tab_list, v2010[v2027], tab_name, getTeamName(v2027), true, false);
            end;
            guiGridListSetItemColor(tab_list, v2010[v2027], tab_name, v2028, v2029, v2030);
        end;
        guiGridListSetSelectedItem(tab_list, v2010[localPlayer], tab_name);
        local v2042 = guiGridListGetRowCount(tab_list);
        local v2043 = math.min(14 * v2042 + 60, yscreen);
        local __, v2045 = guiGetSize(tab_list, false);
        if v2043 ~= v2045 then
            guiSetSize(tab_window, 560, v2043, false);
            guiSetPosition(tab_window, 0.5 * xscreen - 280, 0.5 * yscreen - 0.5 * v2043, false);
            guiSetSize(tab_list, 550, v2043 - 20 - 5, false);
        end;
    end;
    refreshData = function(v2046, v2047, v2048) --[[ Line: 127 ]]
        -- upvalues: v2010 (ref), v2009 (ref)
        if not v2010[v2046] then
            return;
        else
            v2048 = not v2048 and "" or tostring(v2048);
            if getElementType(v2046) == "team" then
                if v2009[v2047] then
                    guiGridListSetItemText(tab_list, v2010[v2046], v2009[v2047], v2048, true, false);
                end;
            elseif v2047 == "Status" then
                local v2049 = getElementData(v2046, "Status") or "";
                if v2049 == "Play" and getTacticsData("settings", "player_information") == "true" then
                    v2049 = tostring(math.floor(getElementHealth(v2046) + getPedArmor(v2046)));
                end;
                if v2049 == "Spectate" then
                    v2049 = "";
                end;
                if getElementData(v2046, "Loading") then
                    v2049 = "Loading";
                end;
                guiGridListSetItemText(tab_list, v2010[v2046], tab_status, v2049, false, false);
            elseif v2047 == "FPS" then
                guiGridListSetItemText(tab_list, v2010[v2046], tab_fps, v2048, false, false);
            elseif v2047 == "PLoss" then
                guiGridListSetItemText(tab_list, v2010[v2046], tab_packet, string.format("%.2f", v2048 or 0), false, false);
            elseif v2009[v2047] then
                guiGridListSetItemText(tab_list, v2010[v2046], v2009[v2047], v2048, false, false);
            end;
            return;
        end;
    end;
    refreshPings = function() --[[ Line: 150 ]]
        -- upvalues: v2010 (ref)
        local v2050 = getElementsByType("team")[1];
        for __, v2052 in ipairs(getElementsByType("player")) do
            if getElementData(v2052, "Status") == "Play" and getPlayerTeam(v2052) ~= v2050 and getTacticsData("settings", "player_information") == "true" and not getElementData(v2052, "Loading") then
                guiGridListSetItemText(tab_list, v2010[v2052], tab_status, tostring(math.floor(getElementHealth(v2052) + getPedArmor(v2052))), false, false);
            end;
            guiGridListSetItemText(tab_list, v2010[v2052], tab_ping, tostring(getPlayerPing(v2052)), false, false);
        end;
        if guiGetVisible(tab_list) then
            setTimer(refreshPings, 500, 1);
        end;
    end;
    toggleTabboard = function(__, v2054) --[[ Line: 160 ]]
        if not guiGetVisible(tab_window) and v2054 == "down" then
            refreshElements();
            setTimer(refreshPings, 500, 1);
            guiBringToFront(tab_window);
            guiSetVisible(tab_window, true);
            addEventHandler("onClientElementDataChange", root, refreshElementData);
            addEventHandler("onClientPlayerChangeNick", root, refreshNick);
            addEventHandler("onClientPlayerJoin", root, refreshElements);
            addEventHandler("onClientPlayerQuit", root, refreshQuit);
            bindKey("mouse2", "both", toggleCursor);
        elseif guiGetVisible(tab_window) and v2054 == "up" then
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
    toggleCursor = function(__, v2056) --[[ Line: 181 ]]
        if guiGetVisible(tab_list) and v2056 == "down" then
            showCursor(true);
        elseif guiGetVisible(tab_list) and v2056 == "up" and isAllGuiHidden() then
            showCursor(false);
        end;
    end;
    refreshElementData = function(v2057, __) --[[ Line: 188 ]]
        if getElementType(source) == "team" or getElementType(source) == "player" then
            if v2057 == "Loading" then
                refreshData(source, "Status");
            else
                refreshData(source, v2057, getElementData(source, v2057));
            end;
        end;
    end;
    refreshNick = function(__, v2060) --[[ Line: 197 ]]
        -- upvalues: v2010 (ref)
        guiGridListSetItemText(tab_list, v2010[source], tab_name, removeColorCoding(v2060), false, false);
    end;
    refreshQuit = function() --[[ Line: 200 ]]
        setTimer(refreshElements, 50, 1);
    end;
    addEvent("onClientTabboardChange", true);
    addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart);
    addEventHandler("onClientTabboardChange", root, onClientTabboardChange);
    bindKey("tab", "both", toggleTabboard);
end)();
(function(...) --[[ Line: 0 ]]
    local v2061 = {
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
    local v2063 = {};
    setPlayerProperty = function(v2064, v2065) --[[ Line: 15 ]]
        -- upvalues: v2061 (ref)
        if not v2061[v2064] then
            return false;
        else
            local v2066 = getElementData(localPlayer, "Properties") or {};
            if v2065 ~= nil and v2065 ~= false then
                v2066[v2064] = v2065;
            else
                v2066[v2064] = nil;
            end;
            return setElementData(localPlayer, "Properties", v2066);
        end;
    end;
    givePlayerProperty = function(v2067, v2068, v2069) --[[ Line: 25 ]]
        -- upvalues: v2061 (ref)
        if not v2061[v2067] then
            return false;
        else
            local v2070 = getElementData(localPlayer, "Properties") or {};
            if v2068 ~= nil and v2068 ~= false then
                v2070[v2067] = {
                    v2068, 
                    v2069
                };
            else
                v2070[v2067] = nil;
            end;
            return setElementData(localPlayer, "Properties", v2070);
        end;
    end;
    getPlayerProperty = function(v2071, v2072) --[[ Line: 35 ]]
        -- upvalues: v2061 (ref)
        if not v2071 or not isElement(v2071) or not v2061[v2072] then
            return false;
        else
            local v2073 = getElementData(localPlayer, "Properties") or {};
            if type(v2073[v2072]) == "table" then
                return unpack(v2073[v2072]);
            else
                return v2073[v2072];
            end;
        end;
    end;
    onClientPlayerInvulnerable = function(__, __, __, __) --[[ Line: 43 ]]
        cancelEvent();
    end;
    onClientMovespeedRender = function() --[[ Line: 46 ]]
        -- upvalues: v2063 (ref)
        local v2078 = type(v2063.movespeed) == "table" and v2063.movespeed[1] or v2063.movespeed;
        local v2079 = 1000 / getElementData(localPlayer, "FPS") * getGameSpeed();
        local v2080, v2081 = getElementVelocity(localPlayer);
        local v2082 = getPedContactElement(localPlayer);
        if v2082 then
            local v2083, v2084 = getElementVelocity(v2082);
            local v2085 = v2080 - v2083;
            v2081 = v2081 - v2084;
            v2080 = v2085;
        end;
        if math.sqrt(v2080 ^ 2 + v2081 ^ 2) > 0.02 then
            local v2086, v2087, v2088 = getElementPosition(localPlayer);
            local v2089 = v2086 + (v2078 - 1) * v2079 * (200 * v2080 / 3600);
            local v2090 = v2087 + (v2078 - 1) * v2079 * (200 * v2081 / 3600);
            local l_v2088_0 = v2088;
            if v2082 then
                local v2092, v2093, v2094 = getElementVelocity(v2082);
                v2089 = v2089 + v2079 * (200 * v2092 / 3600);
                v2090 = v2090 + v2079 * (200 * v2093 / 3600);
                l_v2088_0 = l_v2088_0 + v2079 * (200 * v2094 / 3600);
            end;
            if isLineOfSightClear(v2086, v2087, v2088, v2089, v2090, l_v2088_0, true, true, true, true, true, false, false, localPlayer) then
                setElementPosition(localPlayer, v2089, v2090, l_v2088_0, false);
            end;
        end;
    end;
    onClientPropertiesRender = function(v2095) --[[ Line: 71 ]]
        -- upvalues: v2063 (ref)
        local v2096 = v2095 * getGameSpeed();
        local v2097 = xscreen * 0.06;
        for v2098, v2099 in pairs(v2063) do
            local v2100 = "images/" .. v2098 .. ".png";
            local v2101, v2102, v2103 = unpack(type(v2099) == "table" and v2099 or {
                v2099
            });
            if v2098 == "invulnerable" then
                local v2104 = tonumber(getTacticsData("settings", "player_start_health"));
                setElementHealth(localPlayer, v2104);
            elseif v2098 == "movespeed" then
                v2100 = v2101 < 1 and "images/speeddown.png" or "images/speedup.png";
            elseif v2098 == "regenerable" then
                setElementHealth(localPlayer, getElementHealth(localPlayer) + 0.001 * v2101 * v2096);
            end;
            local v2105 = nil;
            if v2103 then
                v2102 = math.max(v2102 - v2096, 0);
                v2063[v2098] = {
                    v2101, 
                    v2102, 
                    v2103
                };
                v2105 = v2102 / v2103;
                if v2105 <= 0 then
                    v2105 = 0;
                    local v2106 = getElementData(localPlayer, "Properties") or {};
                    v2106[v2098] = nil;
                    setElementData(localPlayer, "Properties", v2106);
                end;
            end;
            dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, v2100, 0, 0, 0, white);
            if v2105 then
                if v2105 >= 1 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_100.png", 0, 0, 0, white);
                elseif v2105 > 0.5 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_50.png", 0, 0, 0, white);
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_50.png", -360 * (v2105 - 0.5), 0, 0, white);
                elseif v2105 > 0.25 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_25.png", 0, 0, 0, white);
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_25.png", -360 * (v2105 - 0.25), 0, 0, white);
                elseif v2105 > 0.125 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_12.png", 0, 0, 0, white);
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_12.png", -360 * (v2105 - 0.125), 0, 0, white);
                elseif v2105 > 0.0625 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_6.png", 0, 0, 0, white);
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_6.png", -360 * (v2105 - 0.0625), 0, 0, white);
                elseif v2105 > 0.03125 then
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_3.png", 0, 0, 0, white);
                    dxDrawImage(v2097, yscreen * 0.75 - 32, 32, 32, "images/factor_3.png", -360 * (v2105 - 0.03125), 0, 0, white);
                end;
            end;
            v2097 = v2097 + 48;
        end;
    end;
    onClientWallhackRender = function() --[[ Line: 121 ]]
        if getCameraGoggleEffect() ~= "thermalvision" then
            return;
        else
            local function v2127(v2107, v2108, v2109) --[[ Line: 123 ]]
                local v2110, v2111, v2112 = getPedBonePosition(v2107, v2108);
                local v2113, v2114, v2115 = getPedBonePosition(v2107, v2109);
                local v2116 = getDistanceBetweenPoints3D(v2110, v2111, v2112, getCameraMatrix());
                local v2117, v2118 = getScreenFromWorldPosition(v2110, v2111, v2112, 360, false);
                local v2119, v2120 = getScreenFromWorldPosition(v2113, v2114, v2115, 360, false);
                if v2117 and v2119 then
                    local v2121 = (v2117 + v2119) / 2;
                    local v2122 = (v2118 + v2120) / 2;
                    local v2123 = xscreen * 0.3 / math.max(1, v2116);
                    local v2124 = 2 * getDistanceBetweenPoints2D(v2117, v2118, v2119, v2120);
                    local v2125 = getAngleBetweenPoints2D(v2117, v2118, v2119, v2120);
                    v2124 = math.max(v2123, v2124);
                    local v2126 = 255 / math.max(1, 0.3 * v2116);
                    dxDrawImage(v2121 - v2123 * 0.5, v2122 - v2124 * 0.5, v2123, v2124, "images/sphere.png", v2125, 0, 0, tocolor(255, 64, 0, v2126));
                end;
            end;
            for __, v2129 in ipairs(getElementsByType("player", root, true)) do
                v2127(v2129, 6, 7);
                for v2130 = 2, 4 do
                    v2127(v2129, v2130 - 1, v2130);
                end;
                for v2131 = 22, 25 do
                    v2127(v2129, v2131 - 1, v2131);
                end;
                for v2132 = 32, 35 do
                    v2127(v2129, v2132 - 1, v2132);
                end;
                for v2133 = 42, 44 do
                    v2127(v2129, v2133 - 1, v2133);
                end;
                for v2134 = 52, 54 do
                    v2127(v2129, v2134 - 1, v2134);
                end;
            end;
            return;
        end;
    end;
    onClientResourceStart = function() --[[ Line: 149 ]]
        for __, v2136 in ipairs(getElementsByType("player")) do
            if (getElementData(localPlayer, "Properties") or {}).invisible then
                setElementAlpha(v2136, 2);
            end;
        end;
    end;
    onClientPlayerPropertiesChange = function(v2137, v2138) --[[ Line: 157 ]]
        if getElementType(source) ~= "player" then
            return;
        elseif v2137 ~= "Properties" then
            return;
        else
            local v2139 = getElementData(source, "Properties");
            if not v2138 or v2139.invisible ~= v2138.invisible then
                if v2139.invisible then
                    setElementAlpha(source, 2);
                else
                    setElementAlpha(source, 255);
                end;
                triggerEvent("onClientPlayerBlipUpdate", source);
            end;
            return;
        end;
    end;
    onClientPropertiesChange = function(v2140, v2141) --[[ Line: 170 ]]
        -- upvalues: v2061 (ref), v2063 (ref)
        if v2140 ~= "Properties" then
            return;
        else
            local v2142 = getElementData(localPlayer, "Properties");
            if (not v2141 or next(v2141)) and not next(v2142) then
                removeEventHandler("onClientPreRender", root, onClientPropertiesRender);
            end;
            for v2143 in pairs(v2061) do
                if not v2141 or type(v2142[v2143]) ~= type(v2141[v2143]) or type(v2142[v2143]) ~= "table" and v2142[v2143] ~= v2141[v2143] or type(v2142[v2143]) == "table" and (v2142[v2143][1] ~= v2141[v2143][1] or v2142[v2143][2] ~= v2141[v2143][2]) then
                    if v2142[v2143] then
                        if type(v2142[v2143]) == "table" then
                            local v2144, v2145 = unpack(v2142[v2143]);
                            v2063[v2143] = {
                                v2144, 
                                v2145, 
                                v2145
                            };
                        else
                            v2063[v2143] = v2142[v2143];
                        end;
                        if not v2141 or not v2141[v2143] then
                            if v2143 == "invulnerable" then
                                addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerInvulnerable);
                            end;
                            if v2143 == "movespeed" then
                                addEventHandler("onClientRender", root, onClientMovespeedRender);
                            end;
                        end;
                    elseif v2141 and v2141[v2143] then
                        if v2143 == "invulnerable" then
                            removeEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerInvulnerable);
                        end;
                        if v2143 == "movespeed" then
                            removeEventHandler("onClientRender", root, onClientMovespeedRender);
                        end;
                        v2063[v2143] = nil;
                    end;
                end;
            end;
            if (not v2141 or not next(v2141)) and next(v2142) then
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
(function(...) --[[ Line: 0 ]]
    local v2146 = nil;
    local v2147 = {};
    local v2148 = nil;
    onClientResourceStart = function(__) --[[ Line: 10 ]]
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
    updateVoting = function() --[[ Line: 36 ]]
        -- upvalues: v2147 (ref), v2146 (ref)
        local v2150 = getTacticsData("voting");
        if v2150 and v2150.rows and #v2150.rows > 0 then
            local v2151 = 0;
            for v2152 = 1, math.max(#v2150.rows + 1, #v2147) do
                if v2152 <= #v2150.rows then
                    local v2153 = v2150.rows[v2152];
                    if #v2147 < v2152 then
                        v2147[v2152] = guiCreateLabel(20, 5 + v2152 * 20, xscreen, 40, v2152 .. " - " .. (v2153.label or v2153.resname) .. " (" .. tonumber(v2153.votes) .. ")", false, voting_window);
                        guiSetFont(v2147[v2152], "default-bold-small");
                    else
                        guiSetText(v2147[v2152], v2152 .. " - " .. (v2153.label or v2153.resname) .. " (" .. tonumber(v2153.votes) .. ")");
                    end;
                    if v2146 == v2152 then
                        guiLabelSetColor(v2147[v2152], 255, 128, 0);
                    else
                        guiLabelSetColor(v2147[v2152], 255, 255, 255);
                    end;
                    local v2154 = dxGetTextWidth(v2152 .. " - " .. (v2153.label or v2153.resname) .. " (" .. tonumber(v2153.votes) .. ")", 1, "default-bold");
                    if v2151 < v2154 + 40 then
                        v2151 = v2154 + 40;
                    end;
                elseif v2152 == #v2150.rows + 1 then
                    if #v2147 < v2152 then
                        v2147[v2152] = guiCreateLabel(20, 5 + v2152 * 20, xscreen, 40, "0 - Cancel (" .. tonumber(v2150.cancel) .. ")", false, voting_window);
                        guiSetFont(v2147[v2152], "default-bold-small");
                    else
                        guiSetText(v2147[v2152], "0 - Cancel (" .. tonumber(v2150.cancel) .. ")");
                    end;
                    if v2146 == 0 then
                        guiLabelSetColor(v2147[v2152], 255, 128, 0);
                    else
                        guiLabelSetColor(v2147[v2152], 255, 255, 255);
                    end;
                    local v2155 = dxGetTextWidth("0 - Cancel (" .. tonumber(v2150.cancel) .. ")", 1, "default-bold");
                    if v2151 < v2155 + 40 then
                        v2151 = v2155 + 40;
                    end;
                else
                    destroyElement(v2147[v2152]);
                    v2147[v2152] = nil;
                end;
            end;
            height = (#v2150.rows + 1) * 20 + 30;
            guiSetPosition(voting_window, xscreen - v2151, yscreen - height, false);
            guiSetSize(voting_window, v2151, height, false);
            guiBringToFront(voting_window);
            guiSetVisible(voting_window, true);
        else
            guiSetVisible(voting_window, false);
            v2146 = nil;
        end;
    end;
    updateVoteTime = function(v2156) --[[ Line: 85 ]]
        -- upvalues: v2148 (ref)
        if v2156 > 0 then
            guiSetText(voting_window, "Voting ... " .. v2156 .. " sec");
            v2148 = setTimer(updateVoteTime, 1000, 1, v2156 - 1);
        end;
    end;
    setVote = function(__, __, v2159) --[[ Line: 91 ]]
        -- upvalues: v2146 (ref)
        local v2160 = getTacticsData("voting");
        if v2160 and v2160.rows and #v2160.rows > 0 and (not v2159 or v2159 <= #v2160.rows) then
            triggerServerEvent("onPlayerVote", localPlayer, v2159, v2146);
            v2146 = v2159;
        end;
    end;
    commandVote = function(__, v2162, v2163) --[[ Line: 98 ]]
        if not v2162 or not v2163 then
            return outputChatBox(getLanguageString("syntax_vote"), 255, 100, 100, true);
        else
            local v2164 = getTacticsData("modes_defined") or {};
            local v2165 = getLanguageString("supported_modes");
            for v2166 in pairs(v2164) do
                v2165 = v2165 .. v2166 .. ", ";
                if v2162 == v2166 then
                    return triggerServerEvent("onPlayerVote", localPlayer, v2162 .. "_" .. v2163, nil, "map");
                end;
            end;
            outputChatBox(string.sub(v2165, 1, -3), 255, 100, 100, true);
            return;
        end;
    end;
    onClientGUIClick_vote_view = function(v2167, __, __, __) --[[ Line: 110 ]]
        if v2167 ~= "left" then
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
                local v2171 = guiGridListGetSelectedItem(vote_maps);
                if v2171 < 0 then
                    return;
                else
                    local v2172 = guiGridListGetItemData(vote_maps, v2171, 1);
                    triggerServerEvent("onPlayerPreview", localPlayer, v2172);
                    guiSetText(vote_view, "Exit");
                    guiSetProperty(vote_view, "NormalTextColour", "C0FF0000");
                end;
            end;
            return;
        end;
    end;
    onClientGUIClick_vote_add = function(v2173, __, __, __) --[[ Line: 136 ]]
        if v2173 ~= "left" then
            return;
        else
            local v2177 = guiGridListGetSelectedItem(vote_maps);
            if v2177 < 0 then
                return;
            else
                local v2178 = guiGridListGetItemData(vote_maps, v2177, 1);
                triggerServerEvent("onPlayerVote", localPlayer, v2178, nil, "map");
                guiSetVisible(vote_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
                return;
            end;
        end;
    end;
    onClientGUIClick_vote_close = function(v2179, __, __, __) --[[ Line: 145 ]]
        if v2179 ~= "left" then
            return;
        else
            guiSetVisible(vote_window, false);
            if isAllGuiHidden() then
                showCursor(false);
            end;
            return;
        end;
    end;
    onClientGUIDoubleClick = function(v2183, __, __, __) --[[ Line: 150 ]]
        if v2183 == "left" and source == vote_maps then
            local v2187 = guiGridListGetSelectedItem(vote_maps);
            if v2187 < 0 then
                return;
            else
                local v2188 = guiGridListGetItemData(vote_maps, v2187, 1);
                triggerServerEvent("onPlayerVote", localPlayer, v2188, nil, "map");
                guiSetVisible(vote_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
        end;
    end;
    onClientGUIChanged = function(__) --[[ Line: 160 ]]
        if source == vote_search then
            updateVoteMaps();
        end;
    end;
    local v2190 = {};
    onClientMapsUpdate = function(v2191) --[[ Line: 166 ]]
        -- upvalues: v2190 (ref)
        v2190 = v2191;
        updateVoteMaps();
    end;
    updateVoteMaps = function() --[[ Line: 170 ]]
        -- upvalues: v2190 (ref)
        local v2192 = getTacticsData("map_disabled") or {};
        local v2193 = guiGetText(vote_search);
        local v2194 = {};
        for __, v2196 in ipairs(v2190) do
            local v2197 = true;
            if #v2193 > 0 then
                for v2198 in string.gmatch(v2193, "[^ ]+") do
                    if string.sub(v2198, 1, 1) == "-" then
                        if #v2198 > 1 then
                            v2198 = string.sub(v2198, 2, -1);
                            if string.find(string.lower(v2196[2]), string.lower(v2198)) or string.find(string.lower(v2196[3]), string.lower(v2198)) then
                                v2197 = false;
                            end;
                        end;
                    elseif not string.find(string.lower(v2196[2]), string.lower(v2198)) and not string.find(string.lower(v2196[3]), string.lower(v2198)) then
                        v2197 = false;
                    end;
                end;
            end;
            if v2192[tostring(v2196[1])] or getTacticsData("modes", string.lower(v2196[2]), "enable") == "false" then
                v2197 = false;
            end;
            if v2197 then
                table.insert(v2194, v2196);
            end;
        end;
        table.sort(v2194, function(v2199, v2200) --[[ Line: 193 ]]
            return v2199[2] < v2200[2] or v2199[2] == v2200[2] and v2199[3] < v2200[3];
        end);
        local v2201 = getTacticsData("MapResName");
        local v2202 = guiGridListGetRowCount(vote_maps);
        for v2203 = 1, math.max(v2202, #v2194) do
            if v2203 <= #v2194 then
                local v2204, v2205, v2206, __, __ = unpack(v2194[v2203]);
                if v2202 < v2203 then
                    guiGridListAddRow(vote_maps);
                end;
                guiGridListSetItemText(vote_maps, v2203 - 1, 1, v2205, false, false);
                guiGridListSetItemData(vote_maps, v2203 - 1, 1, v2204);
                guiGridListSetItemText(vote_maps, v2203 - 1, 2, v2206, false, false);
                if v2201 == v2204 then
                    if v2192[v2204] or getTacticsData("modes", string.lower(v2205), "enable") == "false" then
                        guiGridListSetItemColor(vote_maps, v2203 - 1, 1, 0, 128, 0);
                        guiGridListSetItemColor(vote_maps, v2203 - 1, 2, 0, 128, 0);
                    else
                        guiGridListSetItemColor(vote_maps, v2203 - 1, 1, 0, 255, 0);
                        guiGridListSetItemColor(vote_maps, v2203 - 1, 2, 0, 255, 0);
                    end;
                elseif v2192[v2204] or getTacticsData("modes", string.lower(v2205), "enable") == "false" then
                    guiGridListSetItemColor(vote_maps, v2203 - 1, 1, 128, 128, 128);
                    guiGridListSetItemColor(vote_maps, v2203 - 1, 2, 128, 128, 128);
                else
                    guiGridListSetItemColor(vote_maps, v2203 - 1, 1, 255, 255, 255);
                    guiGridListSetItemColor(vote_maps, v2203 - 1, 2, 255, 255, 255);
                end;
            else
                guiGridListRemoveRow(vote_maps, #v2194);
            end;
        end;
    end;
    toggleVoting = function() --[[ Line: 223 ]]
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
    onClientTacticsChange = function(v2209, v2210) --[[ Line: 234 ]]
        -- upvalues: v2148 (ref)
        if v2209[1] == "map_disabled" or v2209[1] == "modes" and v2209[3] == "enable" then
            updateVoteMaps();
        end;
        if v2209[1] == "voting" then
            local v2211 = getTacticsData("voting");
            if v2211 and not v2210 and v2209[2] == "start" then
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
                local v2212 = v2211.start - (getTickCount() + addTickCount);
                local v2213 = math.floor(v2212 / 1000);
                guiSetText(voting_window, "Voting ... " .. v2213 .. " sec");
                v2148 = setTimer(updateVoteTime, math.max(50, v2212 - v2213 * 1000), 1, v2213);
            elseif not v2211 and v2210 then
                if isTimer(v2148) then
                    killTimer(v2148);
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
    onClientPreviewMapLoading = function(v2214, v2215) --[[ Line: 293 ]]
        local v2216 = {};
        local v2217 = nil;
        local v2218 = {};
        local v2219 = {};
        local v2220 = {};
        for __, v2222 in ipairs(v2215) do
            if v2222[1] == "Anti_Rush_Point" then
                table.insert(v2216, {
                    x = tonumber(v2222[2].posX) or 0, 
                    y = tonumber(v2222[2].posY) or 0, 
                    z = tonumber(v2222[2].posZ) or 0
                });
            end;
            if v2222[1] == "Central_Marker" then
                v2217 = {
                    x = tonumber(v2222[2].posX) or 0, 
                    y = tonumber(v2222[2].posY) or 0, 
                    z = tonumber(v2222[2].posZ) or 0
                };
            end;
            if v2222[1] == "Team1" then
                table.insert(v2218, {
                    x = tonumber(v2222[2].posX) or 0, 
                    y = tonumber(v2222[2].posY) or 0, 
                    z = tonumber(v2222[2].posZ) or 0, 
                    rot = tonumber(v2222[2].rotation) or tonumber(v2222[2].rotZ) or 0
                });
            end;
            if v2222[1] == "Team2" then
                table.insert(v2219, {
                    x = tonumber(v2222[2].posX) or 0, 
                    y = tonumber(v2222[2].posY) or 0, 
                    z = tonumber(v2222[2].posZ) or 0, 
                    rot = tonumber(v2222[2].rotation) or tonumber(v2222[2].rotZ) or 0
                });
            end;
            if v2222[1] == "spawnpoint" then
                table.insert(v2220, {
                    x = tonumber(v2222[2].posX) or 0, 
                    y = tonumber(v2222[2].posY) or 0, 
                    z = tonumber(v2222[2].posZ) or 0, 
                    rot = tonumber(v2222[2].rotation) or tonumber(v2222[2].rotZ) or 0
                });
            end;
        end;
        if not v2217 then
            guiSetText(vote_view, "Preview");
            guiSetProperty(vote_view, "NormalTextColour", "C07C7C7C");
            return;
        else
            setElementDimension(localPlayer, 10);
            if isElement(previewRoot) then
                destroyElement(previewRoot);
            end;
            previewRoot = createElement("preview", "previewRoot");
            for __, v2224 in ipairs(v2218) do
                local v2225 = createPed(0, v2224.x, v2224.y, v2224.z, v2224.rot);
                setElementFrozen(v2225, true);
                setElementParent(v2225, previewRoot);
                setElementDimension(v2225, 10);
                local v2226 = createMarker(v2224.x, v2224.y, v2224.z, "corona", 2, 255, 0, 0, 32);
                attachElements(v2226, v2225);
                setElementDimension(v2226, 10);
                local v2227 = createBlipAttachedTo(v2225, 0, 1, 255, 0, 0, 255, -1);
                setElementParent(v2227, previewRoot);
                setElementDimension(v2227, 10);
            end;
            for __, v2229 in ipairs(v2219) do
                local v2230 = createPed(0, v2229.x, v2229.y, v2229.z, v2229.rot);
                setElementFrozen(v2230, true);
                setElementParent(v2230, previewRoot);
                setElementDimension(v2230, 10);
                local v2231 = createMarker(v2229.x, v2229.y, v2229.z, "corona", 2, 0, 0, 255, 32);
                attachElements(v2231, v2230);
                setElementDimension(v2231, 10);
                local v2232 = createBlipAttachedTo(v2230, 0, 1, 0, 0, 255, 255, -1);
                setElementParent(v2232, previewRoot);
                setElementDimension(v2232, 10);
            end;
            for __, v2234 in ipairs(v2220) do
                local v2235 = createPed(0, v2234.x, v2234.y, v2234.z, v2234.rot);
                setElementFrozen(v2235, true);
                setElementParent(v2235, previewRoot);
                setElementDimension(v2235, 10);
                local v2236 = createMarker(v2234.x, v2234.y, v2234.z, "corona", 2, 255, 255, 255, 32);
                attachElements(v2236, v2235);
                setElementDimension(v2236, 10);
                local v2237 = createBlipAttachedTo(v2235, 0, 1, 255, 255, 255, 255, -1);
                setElementParent(v2237, previewRoot);
                setElementDimension(v2237, 10);
            end;
            if #v2216 > 0 then
                if #v2216 == 2 then
                    v2216 = {
                        {
                            math.min(v2216[1].x, v2216[2].x), 
                            math.min(v2216[1].y, v2216[2].y)
                        }, 
                        {
                            math.max(v2216[1].x, v2216[2].x), 
                            math.min(v2216[1].y, v2216[2].y)
                        }, 
                        {
                            math.max(v2216[1].x, v2216[2].x), 
                            math.max(v2216[1].y, v2216[2].y)
                        }, 
                        {
                            math.min(v2216[1].x, v2216[2].x), 
                            math.max(v2216[1].y, v2216[2].y)
                        }
                    };
                end;
                if #v2216 > 1 then
                    local v2238 = 12;
                    local v2239 = {
                        v2217.x, 
                        v2217.y
                    };
                    for v2240, v2241 in ipairs(v2216) do
                        table.insert(v2239, v2241.x);
                        table.insert(v2239, v2241.y);
                        local v2242 = createObject(3380, v2241.x, v2241.y, v2241.z);
                        setElementParent(v2242, previewRoot);
                        setElementDimension(v2242, 10);
                        local v2243 = v2240 < #v2216 and v2216[v2240 + 1] or v2216[1];
                        local v2244 = math.floor(getDistanceBetweenPoints2D(v2241.x, v2241.y, v2243.x, v2243.y) / 5);
                        local v2245 = (v2243.x - v2241.x) / v2244;
                        local v2246 = (v2243.y - v2241.y) / v2244;
                        for v2247 = 0, v2244 do
                            local v2248 = createRadarArea(v2241.x - v2238 * 0.5 + v2245 * v2247, v2241.y - v2238 * 0.5 + v2246 * v2247, v2238, v2238, 128, 0, 0, 255);
                            setElementParent(v2248, previewRoot);
                            setElementDimension(v2248, 10);
                        end;
                    end;
                end;
            end;
            setCameraMatrix(v2217.x - 50, v2217.y - 50, v2217.z + 40, v2217.x, v2217.y, v2217.z);
            setCameraSpectating(nil, "freecamera");
            addEventHandler("onClientPlayerSpawn", localPlayer, Preview_onClientPlayerSpawn);
            addEventHandler("onClientElementDataChange", localPlayer, Preview_onClientElementDataChange);
            addEventHandler("onClientRender", root, Preview_onClientRender);
            triggerEvent("onClientPreviewMapCreating", previewRoot, v2214, v2215);
            return;
        end;
    end;
    Preview_onClientRender = function() --[[ Line: 397 ]]
        local v2249 = {};
        for __, v2251 in ipairs(getElementsByType("object")) do
            if getElementModel(v2251) == 3380 and getElementDimension(v2251) == 10 then
                local v2252, v2253 = getElementPosition(v2251);
                table.insert(v2249, {v2252, v2253});
            end;
        end;
        if #v2249 > 0 then
            if #v2249 == 2 then
                v2249 = {
                    {
                        math.min(v2249[1][1], v2249[2][1]), 
                        math.min(v2249[1][2], v2249[2][2])
                    }, 
                    {
                        math.max(v2249[1][1], v2249[2][1]), 
                        math.min(v2249[1][2], v2249[2][2])
                    }, 
                    {
                        math.max(v2249[1][1], v2249[2][1]), 
                        math.max(v2249[1][2], v2249[2][2])
                    }, 
                    {
                        math.min(v2249[1][1], v2249[2][1]), 
                        math.max(v2249[1][2], v2249[2][2])
                    }
                };
            end;
            if #v2249 > 1 then
                for v2254, v2255 in ipairs(v2249) do
                    local v2256 = v2254 < #v2249 and v2249[v2254 + 1] or v2249[1];
                    local v2257, v2258 = getScreenFromWorldPosition(v2255[1], v2255[2], getGroundPosition(v2255[1], v2255[2], 1500), 360);
                    local v2259, v2260 = getScreenFromWorldPosition(v2256[1], v2256[2], getGroundPosition(v2256[1], v2256[2], 1500), 360);
                    if v2257 and v2259 then
                        dxDrawLine(v2257, v2258, v2259, v2260, 2157969408, 5);
                    end;
                end;
            end;
        end;
    end;
    Preview_onClientPlayerSpawn = function() --[[ Line: 424 ]]
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
    Preview_onClientElementDataChange = function(v2261, __) --[[ Line: 435 ]]
        if v2261 == "Status" and isElement(previewRoot) then
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
(function(...) --[[ Line: 0 ]]
    local v2263 = dxGetFontHeight(1, "clear");
    addEventHandler("onClientResourceStart", resourceRoot, function() --[[ Line: 8 ]]
        -- upvalues: v2263 (ref)
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
        components.race.rank = guiCreateLabel(0, 0, xscreen, 2 * v2263, "", false, components.race.root);
        guiLabelSetHorizontalAlign(components.race.rank, "right");
        guiSetFont(components.race.rank, fontTactics);
        components.race.players = guiCreateLabel(0, 0, xscreen, 2 * v2263, "", false, components.race.root);
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
        components.timeleft.root = guiCreateStaticImage(xscreen * 0.5 - 31, yscreen * 0.053, 62, v2263, "images/color_pixel.png", false);
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
    showRoundHudComponent = function(v2264, v2265, v2266) --[[ Line: 92 ]]
        if not components[v2264] then
            return nil;
        elseif v2265 and not guiGetVisible(components[v2264].root) then
            updateRoundHudComponent(v2264);
            guiSetVisible(components[v2264].root, true);
            components_update[v2264] = setTimer(updateRoundHudComponent, v2264 == "race" and 50 or 500, 0, v2264);
            if v2266 == true then
                setRoundHudComponent(v2264);
            end;
            return true;
        elseif not v2265 and guiGetVisible(components[v2264].root) then
            guiSetVisible(components[v2264].root, false);
            killTimer(components_update[v2264]);
            if v2266 == nil or v2266 == true then
                setRoundHudComponent(v2264);
            end;
            return true;
        else
            return false;
        end;
    end;
    isShowRoundHudComponent = function(v2267) --[[ Line: 108 ]]
        if not components[v2267] or not isElement(components[v2267].root) then
            return nil;
        else
            return guiGetVisible(components[v2267].root);
        end;
    end;
    setRoundHudComponent = function(v2268, ...) --[[ Line: 112 ]]
        if not components[v2268] then
            return nil;
        else
            local v2269 = {...};
            if v2268 == "elementlist" then
                if v2269[1] ~= nil and type(v2269[1]) ~= "table" and type(v2269[1]) ~= "function" then
                    return false;
                elseif v2269[2] ~= nil and type(v2269[2]) ~= "function" then
                    return false;
                else
                    components.elementlist.custom.elements = v2269[1];
                    components.elementlist.custom.draw = v2269[2];
                    return true;
                end;
            elseif v2268 == "playerlist" then
                if v2269[1] ~= nil and type(v2269[1]) ~= "string" and type(v2269[1]) ~= "function" then
                    return false;
                elseif v2269[2] ~= nil and type(v2269[2]) ~= "function" then
                    return false;
                elseif v2269[3] ~= nil and type(v2269[3]) ~= "boolean" then
                    return false;
                elseif v2269[4] ~= nil and type(v2269[4]) ~= "number" then
                    return false;
                else
                    if v2269[1] and components.playerlist.custom.icon ~= v2269[1] and type(v2269[1]) == "string" then
                        for v2270 = 1, components.playerlist.rows do
                            guiStaticImageLoadImage(components.playerlist.icon[v2270], v2269[1]);
                        end;
                    elseif components.playerlist.custom.icon then
                        for v2271 = 1, components.playerlist.rows do
                            guiStaticImageLoadImage(components.playerlist.icon[v2271], "images/frag.png");
                        end;
                    end;
                    components.playerlist.custom.icon = v2269[1];
                    components.playerlist.custom.func = v2269[2];
                    components.playerlist.custom.sort = v2269[3];
                    components.playerlist.custom.rows = v2269[4];
                    return true;
                end;
            elseif v2268 == "race" then
                if v2269[1] ~= nil and type(v2269[1]) ~= "boolean" then
                    return false;
                elseif v2269[2] ~= nil and type(v2269[2]) ~= "boolean" then
                    return false;
                elseif v2269[3] ~= nil and type(v2269[3]) ~= "function" then
                    return false;
                else
                    components.race.custom.timepass = v2269[1];
                    components.race.custom.checkpoints = v2269[2];
                    components.race.custom.info = v2269[3];
                    return true;
                end;
            elseif v2268 == "teamlist" then
                if v2269[1] ~= nil and type(v2269[1]) ~= "string" and type(v2269[1]) ~= "function" then
                    return false;
                elseif v2269[2] ~= nil and type(v2269[2]) ~= "function" then
                    return false;
                elseif v2269[3] ~= nil and type(v2269[3]) ~= "boolean" then
                    return false;
                elseif v2269[4] ~= nil and type(v2269[4]) ~= "number" then
                    return false;
                else
                    if v2269[1] and components.teamlist.custom.icon ~= v2269[1] and type(v2269[1]) == "string" then
                        for v2272 = 1, components.teamlist.rows do
                            guiStaticImageLoadImage(components.teamlist.icon[v2272], v2269[1]);
                        end;
                    elseif components.teamlist.custom.icon then
                        for v2273 = 1, components.teamlist.rows do
                            guiStaticImageLoadImage(components.teamlist.icon[v2273], "images/score.png");
                        end;
                    end;
                    components.teamlist.custom.icon = v2269[1];
                    components.teamlist.custom.func = v2269[2];
                    components.teamlist.custom.sort = v2269[3];
                    components.teamlist.custom.rows = v2269[4];
                    return true;
                end;
            elseif v2268 == "timeleft" then
                if v2269[1] ~= nil and type(v2269[1]) ~= "function" and type(v2269[1]) ~= "string" then
                    return false;
                elseif v2269[2] ~= nil and type(v2269[2]) ~= "number" then
                    return false;
                elseif v2269[3] ~= nil and type(v2269[3]) ~= "number" then
                    return false;
                elseif v2269[4] ~= nil and type(v2269[4]) ~= "number" then
                    return false;
                else
                    components.timeleft.custom.text = v2269[1];
                    if type(v2269[1]) == "string" then
                        guiSetText(components.timeleft.text, v2269[1]);
                    end;
                    if type(v2269[1]) == "function" then
                        guiSetText(components.timeleft.text, v2269[1]());
                    end;
                    if v2269[2] and v2269[3] and v2269[4] then
                        guiLabelSetColor(components.timeleft.text, v2269[2], v2269[3], v2269[4]);
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
    updateRoundHudComponent = function(v2274) --[[ Line: 188 ]]
        -- upvalues: v2263 (ref)
        if v2274 == "elementlist" then
            local v2275 = type(components.elementlist.custom.elements) == "table" and components.elementlist.custom.elements or type(components.elementlist.custom.elements) == "function" and components.elementlist.custom.elements() or {};
            for v2276 = 1, math.max(#v2275, #components.elementlist.image) do
                if v2276 <= #v2275 then
                    local v2277, v2278, v2279, v2280 = components.elementlist.custom.draw(v2275, v2276);
                    local v2281 = math.min((xscreen * 0.174 - yscreen * 0.04) / 6, (xscreen * 0.174 - yscreen * 0.04) / #v2275);
                    if not components.elementlist.image[v2276] then
                        components.elementlist.image[v2276] = guiCreateStaticImage((v2276 - 1) * v2281, 0, yscreen * 0.04, yscreen * 0.04, v2277, false, components.elementlist.root);
                    else
                        guiStaticImageLoadImage(components.elementlist.image[v2276], v2277);
                    end;
                    local v2282 = string.format("%02X%02X%02X%02X", a or 255, v2278, v2279, v2280);
                    guiSetProperty(components.elementlist.image[v2276], "ImageColours", "tl:" .. v2282 .. " tr:" .. v2282 .. " bl:" .. v2282 .. " br:" .. v2282);
                else
                    destroyElement(components.elementlist.image[v2276]);
                    components.elementlist.image[v2276] = nil;
                end;
            end;
        end;
        if v2274 == "playerlist" then
            local v2283 = {};
            for __, v2285 in ipairs(getElementsByType("player")) do
                if getPlayerGameStatus(v2285) == "Play" or getPlayerGameStatus(v2285) == "Die" then
                    table.insert(v2283, v2285);
                end;
            end;
            if components.playerlist.custom.sort ~= nil and #v2283 > 1 then
                table.sort(v2283, function(v2286, v2287) --[[ Line: 218 ]]
                    local v2288 = components.playerlist.custom.func(v2286);
                    local v2289 = components.playerlist.custom.func(v2287);
                    return components.playerlist.custom.sort and not (v2289 >= v2288) or v2288 < v2289;
                end);
            end;
            local v2290 = {0, 0};
            local v2291 = false;
            local v2292 = math.min(#v2283, components.playerlist.custom.rows or 2);
            for v2293 = 1, math.max(v2292, components.playerlist.rows) do
                if v2293 <= v2292 then
                    local v2294 = v2283[v2293];
                    if v2294 == localPlayer then
                        v2291 = true;
                    end;
                    if v2293 == v2292 and not v2291 and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                        v2294 = localPlayer;
                    end;
                    local v2295 = getPlayerName(v2294);
                    local v2296 = components.playerlist.custom.func and components.playerlist.custom.func(v2294) or tostring(getElementData(v2294, "Kills"));
                    local v2297 = type(components.playerlist.custom.icon) == "string" and components.playerlist.custom.icon or type(components.playerlist.custom.icon) == "function" and components.playerlist.custom.icon(v2294) or "images/frag.png";
                    if not components.playerlist.players[v2293] then
                        components.playerlist.rows = components.playerlist.rows + 1;
                        components.playerlist.players[v2293] = guiCreateLabel(0, (v2293 - 1) * v2263, xscreen, v2263, v2295, false, components.playerlist.players.root);
                        guiSetFont(components.playerlist.players[v2293], "clear-normal");
                        components.playerlist.icon[v2293] = guiCreateStaticImage(0, (v2293 - 1) * v2263, v2263, v2263, v2297, false, components.playerlist.info.root);
                        setElementParent(components.playerlist.icon[v2293], components.playerlist.players[v2293]);
                        components.playerlist.info[v2293] = guiCreateLabel(v2263 + 5, (v2293 - 1) * v2263, xscreen, v2263, v2296, false, components.playerlist.info.root);
                        setElementParent(components.playerlist.info[v2293], components.playerlist.players[v2293]);
                        guiSetFont(components.playerlist.info[v2293], "clear-normal");
                    else
                        if guiGetText(components.playerlist.players[v2293]) ~= v2295 then
                            guiSetText(components.playerlist.players[v2293], v2295);
                        end;
                        if guiGetText(components.playerlist.info[v2293]) ~= v2296 then
                            guiSetText(components.playerlist.info[v2293], v2296);
                        end;
                        if type(components.playerlist.custom.icon) == "function" then
                            guiStaticImageLoadImage(components.playerlist.icon[v2293], v2297);
                        end;
                    end;
                    v2290[1] = math.max(v2290[1], dxGetTextWidth(v2295, 1, "clear"));
                    v2290[2] = math.max(v2290[2], dxGetTextWidth(v2296, 1, "clear"));
                else
                    destroyElement(components.playerlist.players[v2293]);
                    components.playerlist.players[v2293] = nil;
                    components.playerlist.rows = components.playerlist.rows - 1;
                end;
            end;
            components.playerlist.rows = v2292;
            if guiGetSize(components.playerlist.players.root, false) ~= v2290[1] then
                guiSetSize(components.playerlist.players.root, v2290[1], v2292 * v2263, false);
                guiSetPosition(components.playerlist.info.root, 5 + v2290[1] + 5, 2, false);
            end;
            if guiGetSize(components.playerlist.info.root, false) ~= v2263 + 5 + v2290[2] then
                guiSetSize(components.playerlist.info.root, v2263 + 5 + v2290[2], yscreen, false);
            end;
            local v2298, v2299 = guiGetSize(components.playerlist.root, false);
            if v2298 ~= 5 + v2290[1] + 5 + v2263 + 5 + v2290[2] + 5 or v2299 ~= 2 + v2292 * v2263 + 2 then
                guiSetSize(components.playerlist.root, 5 + v2290[1] + 5 + v2263 + 5 + v2290[2] + 5, 2 + v2292 * v2263 + 2, false);
                guiSetPosition(components.playerlist.root, xscreen * 0.95 - (5 + v2290[1] + 5 + v2263 + 5 + v2290[2] + 5), yscreen * 0.935 - (2 + v2292 * v2263 + 2), false);
            end;
        end;
        if v2274 == "race" then
            local v2300 = getCameraTarget();
            if v2300 and getElementType(v2300) == "vehicle" then
                v2300 = getVehicleOccupant(v2300);
            end;
            if not v2300 then
                return;
            else
                local v2301 = 0;
                local v2302 = 2;
                if components.race.custom.timepass and getRoundState() ~= "finished" then
                    local v2303 = 0;
                    local v2304 = getTacticsData("timestart");
                    if v2304 then
                        v2303 = math.max(0, isRoundPaused() and v2304 or getTickCount() + addTickCount - v2304);
                    end;
                    local v2305 = MSecToTime(v2303, 2);
                    v2301 = math.max(v2301, dxGetTextWidth(v2305, 1, "clear"));
                    timepassrow = v2302;
                    v2302 = v2302 + 1;
                    if guiGetText(components.race.timepass) ~= v2305 then
                        guiSetText(components.race.timepass, v2305);
                    end;
                end;
                if components.race.custom.checkpoints then
                    local v2306 = tostring(getElementData(v2300, "Checkpoint")) .. "/" .. #getElementsByType("checkpoint");
                    v2301 = math.max(v2301, dxGetTextWidth(v2306, 1, "clear"));
                    checkpointrow = v2302;
                    v2302 = v2302 + 1;
                    if guiGetText(components.race.checkpoint) ~= v2306 then
                        guiSetText(components.race.checkpoint, v2306);
                    end;
                end;
                if type(components.race.custom.info) == "function" then
                    local v2307 = tostring(components.race.custom.info(v2300));
                    v2301 = math.max(v2301, dxGetTextWidth(v2307, 1, "clear"));
                    inforow = v2302;
                    v2302 = v2302 + 1;
                    if guiGetText(components.race.info) ~= v2307 then
                        guiSetText(components.race.info, v2307);
                    end;
                end;
                local v2308 = getElementData(v2300, "Rank") or 0;
                v2301 = math.max(v2301, 2 * dxGetTextWidth(v2308, 1, "diploma"));
                if guiGetText(components.race.rank) ~= v2308 then
                    guiSetText(components.race.rank, v2308);
                end;
                local v2309 = 0;
                for __, v2311 in ipairs(getTacticsData("Sides")) do
                    v2309 = v2309 + countPlayersInTeam(v2311);
                end;
                v2309 = tostring(v2309);
                local v2312 = (not (v2308 >= 10) or v2308 > 20) and ({
                    [1] = "st", 
                    [2] = "nd", 
                    [3] = "rd"
                })[v2308 % 10] or "th";
                v2301 = math.max(v2301, 2 * dxGetTextWidth(v2312, 1, "clear"), 2 * dxGetTextWidth(v2309, 1, "clear"));
                if guiGetText(components.race.players) ~= v2312 .. "\n/" .. v2309 then
                    guiSetText(components.race.players, v2312 .. "\n/" .. v2309);
                end;
                local v2313, v2314 = guiGetSize(components.race.root, false);
                if v2313 ~= 5 + v2301 + 5 or v2314 ~= 2 + v2302 * v2263 + 2 then
                    guiSetSize(components.race.root, 5 + v2301 + 5, 2 + v2302 * v2263 + 2, false);
                    guiSetPosition(components.race.root, xscreen * 0.95 - (5 + v2301 + 5), yscreen * 0.935 - (2 + v2302 * v2263 + 2), false);
                    guiSetSize(components.race.rank, 5 + v2301 / 2, 2 * v2263, false);
                    guiSetPosition(components.race.players, 5 + v2301 / 2, 0, false);
                    if timepassrow then
                        guiSetPosition(components.race.timepass, 0, 2 + timepassrow * v2263, false);
                        guiSetSize(components.race.timepass, 5 + v2301 + 5, v2263, false);
                    end;
                    if checkpointrow then
                        guiSetPosition(components.race.checkpoint, 0, 2 + checkpointrow * v2263, false);
                        guiSetSize(components.race.checkpoint, 5 + v2301 + 5, v2263, false);
                    end;
                    if inforow then
                        guiSetPosition(components.race.info, 0, 2 + inforow * v2263, false);
                        guiSetSize(components.race.info, 5 + v2301 + 5, v2263, false);
                    end;
                end;
            end;
        end;
        if v2274 == "teamlist" then
            local v2315 = getElementsByType("team");
            table.remove(v2315, 1);
            if components.teamlist.custom.sort ~= nil and #v2315 > 1 then
                table.sort(v2315, function(v2316, v2317) --[[ Line: 357 ]]
                    local v2318 = components.teamlist.custom.func(v2316);
                    local v2319 = components.teamlist.custom.func(v2317);
                    return components.teamlist.custom.sort and not (v2319 >= v2318) or v2318 < v2319;
                end);
            end;
            local v2320 = {0, 0, 0};
            local v2321 = false;
            local v2322 = math.min(#v2315, components.teamlist.custom.rows or 3);
            for v2323 = 1, math.max(v2322, components.teamlist.rows) do
                if v2323 <= v2322 then
                    local v2324 = v2315[v2323];
                    if v2324 == getPlayerTeam(localPlayer) then
                        v2321 = true;
                    end;
                    if v2323 == v2322 and not v2321 and getPlayerTeam(localPlayer) ~= getElementsByType("team")[1] then
                        v2324 = getPlayerTeam(localPlayer) or v2315[v2323];
                    end;
                    local v2325 = getTeamName(v2324);
                    local v2326 = 0;
                    for __, v2328 in ipairs(getPlayersInTeam(v2324)) do
                        if getElementData(v2328, "Status") == "Play" then
                            v2326 = v2326 + 1;
                        end;
                    end;
                    v2326 = tostring(v2326);
                    local v2329 = components.teamlist.custom.func and components.teamlist.custom.func(v2324) or tostring(getElementData(v2324, "Score"));
                    local v2330 = type(components.teamlist.custom.icon) == "string" and components.teamlist.custom.icon or type(components.teamlist.custom.icon) == "function" and components.teamlist.custom.icon(v2324) or "images/score.png";
                    if not components.teamlist.players[v2323] then
                        components.teamlist.rows = components.teamlist.rows + 1;
                        components.teamlist.players[v2323] = guiCreateLabel(0, (v2323 - 1) * v2263, xscreen, v2263, v2326, false, components.teamlist.players.root);
                        guiSetFont(components.teamlist.players[v2323], "clear-normal");
                        components.teamlist.teamname[v2323] = guiCreateLabel(0, (v2323 - 1) * v2263, xscreen, v2263, v2325, false, components.teamlist.teamname.root);
                        guiLabelSetColor(components.teamlist.teamname[v2323], getTeamColor(v2324));
                        setElementParent(components.teamlist.teamname[v2323], components.teamlist.players[v2323]);
                        guiSetFont(components.teamlist.teamname[v2323], "clear-normal");
                        components.teamlist.icon[v2323] = guiCreateStaticImage(0, (v2323 - 1) * v2263, v2263, v2263, v2330, false, components.teamlist.info.root);
                        setElementParent(components.teamlist.icon[v2323], components.teamlist.players[v2323]);
                        components.teamlist.info[v2323] = guiCreateLabel(v2263 + 5, (v2323 - 1) * v2263, xscreen, v2263, v2329, false, components.teamlist.info.root);
                        setElementParent(components.teamlist.info[v2323], components.teamlist.players[v2323]);
                        guiSetFont(components.teamlist.info[v2323], "clear-normal");
                    else
                        if guiGetText(components.teamlist.teamname[v2323]) ~= v2325 then
                            guiSetText(components.teamlist.teamname[v2323], v2325);
                        end;
                        guiLabelSetColor(components.teamlist.teamname[v2323], getTeamColor(v2324));
                        if guiGetText(components.teamlist.players[v2323]) ~= v2326 then
                            guiSetText(components.teamlist.players[v2323], v2326);
                        end;
                        if guiGetText(components.teamlist.info[v2323]) ~= v2329 then
                            guiSetText(components.teamlist.info[v2323], v2329);
                        end;
                        if type(components.teamlist.custom.icon) == "function" then
                            guiStaticImageLoadImage(components.teamlist.icon[v2323], v2330);
                        end;
                    end;
                    v2320[1] = math.max(v2320[1], dxGetTextWidth(v2325, 1, "clear"));
                    v2320[2] = math.max(v2320[2], dxGetTextWidth(v2326, 1, "clear"));
                    v2320[3] = math.max(v2320[3], dxGetTextWidth(v2329, 1, "clear"));
                else
                    destroyElement(components.teamlist.players[v2323]);
                    components.teamlist.players[v2323] = nil;
                    components.teamlist.rows = components.teamlist.rows - 1;
                end;
            end;
            components.teamlist.rows = v2322;
            if guiGetSize(components.teamlist.teamname.root, false) ~= v2320[1] then
                guiSetSize(components.teamlist.teamname.root, v2320[1], yscreen, false);
                guiSetPosition(components.teamlist.players.root, 5 + v2320[1] + 5, 2, false);
                guiSetPosition(components.teamlist.info.root, 5 + v2320[1] + 5 + v2320[2] + 5, 2, false);
            end;
            if guiGetSize(components.teamlist.players.root, false) ~= v2320[2] then
                guiSetSize(components.teamlist.players.root, v2320[2], yscreen, false);
                guiSetPosition(components.teamlist.info.root, 5 + v2320[1] + 5 + v2320[2] + 5, 2, false);
            end;
            if guiGetSize(components.teamlist.info.root, false) ~= v2263 + 5 + v2320[3] then
                guiSetSize(components.teamlist.info.root, v2263 + 5 + v2320[3], yscreen, false);
            end;
            local v2331, v2332 = guiGetSize(components.teamlist.root, false);
            if v2331 ~= 5 + v2320[1] + 5 + v2320[2] + 5 + v2263 + 5 + v2320[3] + 5 or v2332 ~= 2 + v2322 * v2263 + 2 then
                guiSetSize(components.teamlist.root, 5 + v2320[1] + 5 + v2320[2] + 5 + v2263 + 5 + v2320[3] + 5, 2 + v2322 * v2263 + 2, false);
                guiSetPosition(components.teamlist.root, xscreen * 0.95 - (5 + v2320[1] + 5 + v2320[2] + 5 + v2263 + 5 + v2320[3] + 5), yscreen * 0.935 - (2 + v2322 * v2263 + 2), false);
            end;
        end;
        if v2274 == "timeleft" then
            local v2333 = guiGetText(components.timeleft.text);
            local v2334 = "--:--";
            if getRoundState() == "stopped" then
                local v2335 = getTacticsData("modes", getTacticsData("Map"), "timelimit");
                if v2335 then
                    v2334 = v2335;
                end;
            elseif type(components.timeleft.custom.text) == "string" then
                v2334 = components.timeleft.custom.text;
            elseif type(components.timeleft.custom.text) == "function" then
                v2334 = components.timeleft.custom.text();
            else
                local v2336 = getTacticsData("timeleft");
                if v2336 then
                    local v2337 = getTacticsData("Pause") or v2336 - (getTickCount() + addTickCount);
                    if type(v2337) ~= "number" or v2337 < 0 then
                        v2337 = 0;
                    end;
                    v2334 = MSecToTime(v2337, 0);
                end;
            end;
            if v2333 ~= v2334 and getRoundState() ~= "finished" then
                if v2334 == "5:00" and v2333 == "5:01" then
                    playVoice("audio/last_five_minutes.mp3");
                elseif v2334 == "1:00" and v2333 == "1:01" then
                    playVoice("audio/last_minute.mp3");
                end;
                if v2333 ~= v2334 then
                    guiSetText(components.timeleft.text, v2334);
                    local v2338 = dxGetTextWidth(v2334, 1, "clear") + 10;
                    guiSetPosition(components.timeleft.root, (xscreen - v2338) * 0.5, yscreen * 0.053, false);
                    guiSetSize(components.timeleft.root, v2338, 20, false);
                end;
            end;
        end;
    end;
    dxDrawAnimatedImage = function(v2339, v2340) --[[ Line: 469 ]]
        if type(dataAnimatedImages) ~= "table" then
            dataAnimatedImages = {};
        end;
        table.insert(dataAnimatedImages, {v2339, v2340, getTickCount()});
        if #dataAnimatedImages == 1 then
            addEventHandler("onClientRender", root, onClientAnimatedImagesRender);
        end;
        return #dataAnimatedImages;
    end;
    dxStopAnimatedImage = function(v2341) --[[ Line: 475 ]]
        if dataAnimatedImages[v2341] then
            table.remove(dataAnimatedImages, v2341);
            if #dataAnimatedImages == 0 then
                removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
            end;
            return true;
        else
            return false;
        end;
    end;
    onClientAnimatedImagesRender = function() --[[ Line: 483 ]]
        for v2342, v2343 in ipairs(dataAnimatedImages) do
            local v2344, v2345, v2346 = unpack(v2343);
            local v2347 = getTickCount() - v2346;
            if v2345 == 1 then
                if v2347 < 100 then
                    local v2348 = 1 - v2347 / 100;
                    dxDrawImage(xscreen * 0.5 - 64 - yscreen * v2348, yscreen * 0.3 - 32 - yscreen * 0.5 * v2348, yscreen * v2348 + 128, yscreen * v2348 + 64, v2344, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - v2348)), true);
                elseif v2347 < 600 then
                    local v2349 = (v2347 - 100) / 500;
                    dxDrawImage(xscreen * 0.5 - 64 + xscreen * v2349 * 0.1, yscreen * 0.3 - 32, 128, 64, v2344, 0, 0, 0, 4294967295, true);
                elseif v2347 < 700 then
                    local v2350 = (v2347 - 600) / 100;
                    dxDrawImage(xscreen * 0.6 - 64 + xscreen * v2350 * 0.4, yscreen * 0.3 - 32, 128, 64, v2344, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - v2350)), true);
                else
                    table.remove(dataAnimatedImages, v2342);
                    if #dataAnimatedImages == 0 then
                        return removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
                    end;
                end;
            elseif v2345 == 2 then
                if v2347 < 100 then
                    local v2351 = 1 - v2347 / 100;
                    dxDrawImage(xscreen * 0.5 - 64 + 32 * v2351, yscreen * 0.3 - 32 - yscreen * 0.25 * v2351, yscreen * v2351 + 128, yscreen * v2351 + 64, v2344, 30 * v2351, 0, 0, tocolor(255, 255, 255, 255 * (1 - v2351)), true);
                elseif v2347 < 150 then
                    local v2352 = (v2347 - 100) / 50;
                    dxDrawImage(xscreen * 0.5 - 64 - 128 * v2352, yscreen * 0.3 - 32 - 64 * v2352, 256 * v2352 + 128, 128 * v2352 + 64, v2344, 0, 0, 0, 4294967295, true);
                elseif v2347 < 200 then
                    local v2353 = 1 - (v2347 - 150) / 50;
                    dxDrawImage(xscreen * 0.5 - 64 - 128 * v2353, yscreen * 0.3 - 32 - 64 * v2353, 256 * v2353 + 128, 128 * v2353 + 64, v2344, 0, 0, 0, 4294967295, true);
                elseif v2347 < 2200 then
                    local v2354 = (v2347 - 200) / 2000;
                    dxDrawImage(xscreen * 0.5 - 64 + 16 * v2354, yscreen * 0.3 - 32 + 8 * v2354, 128 - 32 * v2354, 64 - 16 * v2354, v2344, 0, 0, 0, 4294967295, true);
                elseif v2347 < 2300 then
                    local v2355 = (v2347 - 2200) / 100;
                    dxDrawImage(xscreen * 0.5 - 48, yscreen * 0.3 - 24 + yscreen * 0.5 * v2355, 96, 48, v2344, 0, 0, 0, tocolor(255, 255, 255, 255 * (1 - v2355)), true);
                else
                    table.remove(dataAnimatedImages, v2342);
                    if #dataAnimatedImages == 0 then
                        return removeEventHandler("onClientRender", root, onClientAnimatedImagesRender);
                    end;
                end;
            end;
        end;
    end;
    nitroLevel = nil;
    local v2356 = nil;
    local v2357 = nil;
    local v2358 = nil;
    onClientNitroPreRender = function(v2359) --[[ Line: 528 ]]
        -- upvalues: v2358 (ref), v2356 (ref), v2357 (ref)
        local v2360 = getPedOccupiedVehicle(localPlayer);
        if v2360 and getVehicleOccupant(v2360) == localPlayer then
            v2358 = v2360;
            local v2361 = getVehicleUpgradeOnSlot(v2360, 8);
            local v2362 = getVehicleType(v2360);
            if (v2361 > 0 or nitroLevel) and (v2362 == "Automobile" or v2362 == "Quad" or v2362 == "Monster Truck") then
                if not nitroLevel then
                    nitroLevel = getElementData(v2360, "nitroLevel") or 20000;
                    guiSetPosition(components.nitro.level, 0, 1 - nitroLevel / 20000, true);
                    guiSetSize(components.nitro.level, 1, nitroLevel / 20000, true);
                    guiSetVisible(components.nitro.root, true);
                end;
                local v2363 = guiGetText(config_gameplay_nitrocontrol);
                if v2363 == "Normal" then
                    if (getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire")) and not v2356 then
                        v2356 = 20000;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                    end;
                elseif v2363 == "Hold" then
                    if getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire") then
                        if not v2356 then
                            v2356 = 20000;
                            guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                            callServerFunction("removeVehicleUpgrade", v2360, v2361);
                            removeVehicleUpgrade(v2360, v2361);
                            addVehicleUpgrade(v2360, v2361);
                            callServerFunction("addVehicleUpgrade", v2360, v2361);
                        end;
                    elseif v2356 then
                        callServerFunction("removeVehicleUpgrade", v2360, v2361);
                        removeVehicleUpgrade(v2360, v2361);
                        setElementData(v2360, "nitroLevel", nitroLevel);
                        v2356 = nil;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                        addVehicleUpgrade(v2360, v2361);
                        callServerFunction("addVehicleUpgrade", v2360, v2361);
                    end;
                elseif v2363 == "Toggle" then
                    if getPedControlState("vehicle_fire") or getPedControlState("vehicle_secondary_fire") then
                        if not v2357 then
                            v2357 = true;
                            if not v2356 then
                                v2356 = 20000;
                                guiSetProperty(components.nitro.level, "ImageColours", "tl:6000C0FF tr:6000C0FF bl:6000C0FF br:6000C0FF");
                            elseif v2356 then
                                v2356 = nil;
                                guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                                setPedControlState("vehicle_fire", false);
                                setPedControlState("vehicle_secondary_fire", false);
                                callServerFunction("removeVehicleUpgrade", v2360, v2361);
                                removeVehicleUpgrade(v2360, v2361);
                                addVehicleUpgrade(v2360, v2361);
                                callServerFunction("addVehicleUpgrade", v2360, v2361);
                            end;
                        end;
                    else
                        v2357 = nil;
                    end;
                end;
                if v2356 then
                    v2356 = v2356 - v2359 * getGameSpeed();
                    nitroLevel = nitroLevel - v2359 * getGameSpeed();
                    guiSetPosition(components.nitro.level, 0, 1 - nitroLevel / 20000, true);
                    guiSetSize(components.nitro.level, 1, nitroLevel / 20000, true);
                    if nitroLevel <= 0 then
                        callServerFunction("removeVehicleUpgrade", v2360, v2361);
                        removeVehicleUpgrade(v2360, v2361);
                        setElementData(v2360, "nitroLevel", nil);
                        guiSetVisible(components.nitro.root, false);
                        nitroLevel = nil;
                        v2356 = nil;
                        guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                    end;
                end;
            elseif nitroLevel then
                nitroLevel = nil;
                v2356 = nil;
                guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
                setElementData(v2360, "nitroLevel", nil);
                guiSetVisible(components.nitro.root, false);
            end;
        elseif nitroLevel then
            if isElement(v2358) then
                setElementData(v2358, "nitroLevel", nitroLevel);
            end;
            nitroLevel = nil;
            v2356 = nil;
            guiSetProperty(components.nitro.level, "ImageColours", "tl:60006080 tr:60006080 bl:60006080 br:60006080");
            guiSetVisible(components.nitro.root, false);
        end;
    end;
    addEventHandler("onClientPreRender", root, onClientNitroPreRender);
    local v2364 = nil;
    local v2365 = 0;
    infowindow = guiCreateStaticImage(0.3, 0.838, 0.7, 0.1, "images/color_pixel.png", true);
    guiSetProperty(infowindow, "ImageColours", "tl:80000000 tr:80000000 bl:80000000 br:80000000");
    guiSetVisible(infowindow, false);
    local v2366 = guiCreateLabel(5, 5, xscreen * 0.7 - 10, yscreen, "", false, infowindow);
    outputInfo = function(v2367, v2368) --[[ Line: 628 ]]
        -- upvalues: v2366 (ref), v2365 (ref), v2364 (ref)
        if type(v2367) ~= "string" or #v2367 < 1 then
            return false;
        else
            if guiGetText(v2366) ~= v2367 then
                guiSetText(v2366, v2367);
                local v2369 = dxGetTextWidth(v2367, 1, "default");
                local v2370 = dxGetFontHeight(1, "default") * (string.count(v2367, "\n") + 1);
                guiSetPosition(infowindow, 0.225, 0.938 - (v2370 + 10) / yscreen, true);
                guiSetSize(infowindow, v2369 + 10, v2370 + 10, false);
                v2365 = v2365 + 1;
            end;
            if not guiGetVisible(infowindow) and guiGetAlpha(infowindow) > 0.1 then
                playSoundFrontEnd(11);
            end;
            guiSetVisible(infowindow, true);
            if not v2368 then
                v2368 = 5000;
            end;
            if isTimer(v2364) then
                killTimer(v2364);
            end;
            v2364 = setTimer(guiSetVisible, v2368, 1, infowindow, false);
            return v2365;
        end;
    end;
    hideInfo = function(v2371) --[[ Line: 645 ]]
        -- upvalues: v2365 (ref), v2364 (ref)
        if v2365 == v2371 or not v2371 then
            if isTimer(v2364) then
                killTimer(v2364);
            end;
            guiSetVisible(infowindow, false);
            return true;
        else
            return false;
        end;
    end;
end)();
(function(...) --[[ Line: 0 ]]
    currentMenu = 1;
    currentTeam = 0;
    currentSkin = {};
    currentPed = {};
    currentCamera = {};
    onClientResourceStart = function(__) --[[ Line: 12 ]]
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
    onClientJoiningRender = function() --[[ Line: 47 ]]
        if guiGetVisible(joining_background) then
            dxDrawRectangle(0, 0, xscreen * 0.4, yscreen, 4278190080);
        end;
        local v2373, v2374, v2375, v2376, v2377, v2378 = getCameraMatrix();
        local v2379, v2380, v2381, v2382, v2383, v2384 = unpack(currentCamera);
        local v2385 = 0.1;
        setCameraMatrix(v2373 + v2385 * (v2379 - v2373), v2374 + v2385 * (v2380 - v2374), v2375 + v2385 * (v2381 - v2375), v2376 + v2385 * (v2382 - v2376), v2377 + v2385 * (v2383 - v2377), v2378 + v2385 * (v2384 - v2378));
    end;
    onClientJoiningTimer = function() --[[ Line: 54 ]]
        if currentTeam == 0 then
            local __ = classtm;
            classtm = (classtm or 1) + 1;
            local v2387 = getElementsByType("team");
            if classtm > #v2387 then
                classtm = 1;
            end;
            local v2388 = v2387[classtm];
            guiLabelSetColor(joining_teamname, getTeamColor(v2388));
        elseif not getPedAnimation(currentPed[currentTeam]) then
            local v2389 = ({
                "shift", 
                "shldr", 
                "stretch", 
                "strleg", 
                "time"
            })[math.random(5)];
            for __, v2391 in ipairs(currentPed) do
                setPedAnimation(v2391, "PLAYIDLES", v2389, -1, false, false, false, false);
            end;
        end;
    end;
    switchCurrentTeam = function(v2392, __, v2394) --[[ Line: 69 ]]
        if type(v2392) == "number" then
            v2394 = v2392;
        end;
        local v2395 = getElementsByType("team");
        table.insert(v2395, v2395[1]);
        table.remove(v2395, 1);
        if currentMenu == 2 then
            local v2396 = getElementData(v2395[currentTeam], "Skins") or {
                71
            };
            currentSkin[currentTeam] = (currentSkin[currentTeam] + v2394) % (#v2396 + 1);
            if currentSkin[currentTeam] > 0 then
                setElementModel(currentPed[currentTeam], v2396[currentSkin[currentTeam]]);
                setPedAnimation(currentPed[currentTeam], "PLAYIDLES", "null");
                guiSetText(joining_skinname, string.format("%i/%i", currentSkin[currentTeam], #v2396));
            else
                guiSetText(joining_skinname, "Spectate");
            end;
        elseif currentMenu == 1 then
            if v2394 > 0 then
                playSoundFrontEnd(18);
            else
                playSoundFrontEnd(17);
            end;
            local l_currentTeam_0 = currentTeam;
            currentTeam = (currentTeam + v2394) % (#v2395 + 1);
            if l_currentTeam_0 and currentPed[l_currentTeam_0] then
                setElementAlpha(currentPed[l_currentTeam_0], 0);
            end;
            if currentTeam > 0 then
                setElementAlpha(currentPed[currentTeam], 255);
                guiSetText(joining_teamname, getTeamName(v2395[currentTeam]));
                guiLabelSetColor(joining_teamname, getTeamColor(v2395[currentTeam]));
                currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      -- Team view
                if currentTeam < #v2395 then
                    if currentSkin[currentTeam] > 0 then
                        local v2398 = getElementData(v2395[currentTeam], "Skins") or {
                            71
                        };
                        guiSetText(joining_skinname, string.format("%i/%i", currentSkin[currentTeam], #v2398));
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
                currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    -- Auto-assign
                guiSetVisible(joining_skinleft, false);
                guiSetVisible(joining_skinname, false);
                guiSetVisible(joining_skinright, false);
            end;
        end;
    end;
    switchCurrentMenu = function(v2399, v2400, v2401) --[[ Line: 120 ]]
        if not v2400 then
            v2401 = v2399;
        end;
        local v2402 = 0;
        if type(v2401) == "number" then
            v2402 = (currentMenu + v2401) % 5;
            if v2402 == 2 and (currentTeam == 0 or currentTeam == #getElementsByType("team")) then
                v2402 = (v2402 + v2401) % 5;
            end;
        else
            v2402 = tonumber(v2401) or 0;
        end;
        if v2402 == 4 then
            currentCamera = {314.7, -140.2, 1005.5, 1343, -1848.7, 1157.2};     -- Lenguage
        elseif v2402 == 3 then
            currentCamera = {315.1, -131.4, 1004.6, 1881.5, 951.9, 394.4};      -- Credits
        elseif currentTeam == 0 then
            currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    -- Auto-assign
        else
            currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      -- Team view
        end;
        if currentMenu ~= v2402 then
            playSoundFrontEnd(3);
            currentMenu = v2402;
            guiSetPosition(joining_selection, 0.04500000000000001, 0.8 - 0.05 * v2402 - 0.005, true);
        end;
    end;
    selectCurrentTeam = function() --[[ Line: 146 ]]
        if currentMenu == 0 or currentMenu == 1 or currentMenu == 2 then
            if currentTeam > 0 then
                currentCamera = {309.9, -132.9, 1004, -1197.3, 1181.2, 963.9};      -- Team selected
            else
                currentCamera = {315.4, -136.7, 1005.3, 2244.4, -506.5, 1382.8};     -- Auto-assign selected
            end;
            unbindKey("arrow_l", "down", switchCurrentTeam);
            unbindKey("arrow_r", "down", switchCurrentTeam);
            unbindKey("arrow_u", "down", switchCurrentMenu);
            unbindKey("arrow_d", "down", switchCurrentMenu);
            unbindKey("enter", "down", selectCurrentTeam);
            guiSetVisible(joining_background, false);
            playSoundFrontEnd(11);
            fadeCamera(false, 1);
            setTimer(function() --[[ Line: 161 ]]
                if currentTeam > 0 then
                    local v2403 = getElementsByType("team");
                    table.insert(v2403, v2403[1]);
                    table.remove(v2403, 1);
                    if not getElementData(v2403[currentTeam], "Skins") then
                        local __ = {
                            71
                        };
                    end;
                    setElementData(localPlayer, "spectateskin", currentSkin[currentTeam] <= 0 or nil);
                    triggerServerEvent("onPlayerTeamSelect", localPlayer, v2403[currentTeam], getElementModel(currentPed[currentTeam]));
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
    onClientElementDataChange = function(v2405, v2406) --[[ Line: 180 ]]
        if v2405 == "Status" then
            if getElementData(source, v2405) == "Joining" and v2406 ~= "Joining" then
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
                    currentCamera = {309.5, -133.3, 1004, -1197.3, 1181.2, 963.9};      -- Team view
                else
                    currentCamera = {315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8};    -- Auto-assign
                end;
                setCameraMatrix(315.6, -136.2, 1005.3, 2244.4, -506.5, 1382.8);         -- Auto-assign
                setElementInterior(localPlayer, 7);
                setCameraInterior(7);
                local v2407 = getElementsByType("team");
                table.insert(v2407, v2407[1]);
                table.remove(v2407, 1);
                for v2408, v2409 in ipairs(v2407) do
                    currentSkin[v2408] = 1;
                    local v2410 = (getElementData(v2409, "Skins") or {
                        71
                    })[1];
                    currentPed[v2408] = createPed(v2410, 308.2, -131.4, 1004, 220);
                    setElementInterior(currentPed[v2408], 7);
                    setElementFrozen(currentPed[v2408], true);
                    if currentTeam ~= v2408 then
                        setElementAlpha(currentPed[v2408], 0);
                    end;
                end;
                guiSetVisible(joining_background, true);
                showCursor(true);
            elseif getElementData(source, v2405) ~= "Joining" and v2406 == "Joining" then
                unbindKey("arrow_l", "down", switchCurrentTeam);
                unbindKey("arrow_r", "down", switchCurrentTeam);
                unbindKey("arrow_u", "down", switchCurrentMenu);
                unbindKey("arrow_d", "down", switchCurrentMenu);
                unbindKey("enter", "down", selectCurrentTeam);
                guiSetVisible(joining_background, false);
                for __, v2412 in ipairs(currentPed) do
                    if isElement(v2412) then
                        destroyElement(v2412);
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
    onClientGUIClick = function(v2413, __, __, __) --[[ Line: 233 ]]
        if v2413 ~= "left" then
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
    onClientMouseEnter = function(__, __) --[[ Line: 251 ]]
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
(function(...) --[[ Line: 0 ]]
    loadedLanguage = false;
    fpsdata = {{0, getTickCount()}};
    plossdata = {{0, getTickCount()}};
    onClientResourceStart = function(__) --[[ Line: 10 ]]
        loadedLanguage = false;
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
        local v2420 = xmlFindChild(_client, "audio", 0);
        if not v2420 then
            v2420 = xmlCreateChild(_client, "audio");
            xmlNodeSetAttribute(v2420, "voice", "true");
            xmlNodeSetAttribute(v2420, "voicevol", "100");
            xmlNodeSetAttribute(v2420, "music", "true");
            xmlNodeSetAttribute(v2420, "musicvol", "100");
        end;
        temp = xmlNodeGetAttribute(v2420, "voice") or "true";
        config_audio_voice = guiCreateCheckBox(0.05, 0.04, 0.33, 0.04, "Voice Sounds", temp == "true", true, config_scrollers.Audio);
        config_audio_voicevol = guiCreateScrollBar(0.42, 0.04, 0.43, 0.04, true, true, config_scrollers.Audio);
        config_audio_voicelab = guiCreateLabel(0.85, 0.04, 0.1, 0.04, "100%", true, config_scrollers.Audio);
        temp = tonumber(xmlNodeGetAttribute(v2420, "voicevol") or "100");
        guiScrollBarSetScrollPosition(config_audio_voicevol, temp);
        temp = xmlNodeGetAttribute(v2420, "music") or "true";
        config_audio_music = guiCreateCheckBox(0.05, 0.1, 0.33, 0.04, "Music", temp == "true", true, config_scrollers.Audio);
        config_audio_musicvol = guiCreateScrollBar(0.42, 0.1, 0.43, 0.04, true, true, config_scrollers.Audio);
        config_audio_musiclab = guiCreateLabel(0.85, 0.1, 0.1, 0.04, "100%", true, config_scrollers.Audio);
        temp = tonumber(xmlNodeGetAttribute(v2420, "musicvol") or "100");
        guiScrollBarSetScrollPosition(config_audio_musicvol, temp);
        config_scrollers.Gameplay = guiCreateGridList(135, 25, 340, 460, false, config_window);
        guiSetVisible(config_scrollers.Gameplay, false);
        local v2421 = xmlFindChild(_client, "gameplay", 0);
        if not v2421 then
            v2421 = xmlCreateChild(_client, "gameplay");
            xmlNodeSetAttribute(v2421, "language", "language/english.lng");
            xmlNodeSetAttribute(v2421, "nitrocontrol", "toggle");
        end;
        guiCreateLabel(0.05, 0.04, 0.43, 0.04, "Language:", true, config_scrollers.Gameplay);
        local v2422 = xmlNodeGetAttribute(v2421, "language") or "language/english.lng";
        config_gameplay_language = guiCreateComboBox(0.52, 0.04, 0.43, 0.6, "", true, config_scrollers.Gameplay);
        config_gameplay_languagelist = {};
        local v2423 = xmlLoadFile("language/languages.xml");
        if v2423 then
            local v2424 = xmlNodeGetChildren(v2423);
            table.sort(v2424, function(v2425, v2426) --[[ Line: 61 ]]
                return xmlNodeGetAttribute(v2425, "src") < xmlNodeGetAttribute(v2426, "src");
            end);
            for __, v2428 in ipairs(v2424) do
                local v2429 = xmlNodeGetAttribute(v2428, "src");
                local v2430 = xmlLoadFile(v2429);
                if v2430 then
                    local v2431 = xmlNodeGetAttribute(v2430, "name");
                    guiComboBoxAddItem(config_gameplay_language, v2431);
                    config_gameplay_languagelist[v2429] = v2431;
                    config_gameplay_languagelist[v2431] = v2429;
                    if v2429 == v2422 then
                        guiSetText(config_gameplay_language, v2431);
                    end;
                    xmlUnloadFile(v2430);
                end;
            end;
            xmlUnloadFile(v2423);
        end;
        guiCreateLabel(0.05, 0.1, 0.43, 0.04, "Nitro Control:", true, config_scrollers.Gameplay);
        local v2432 = xmlNodeGetAttribute(v2421, "nitrocontrol") or "toggle";
        config_gameplay_nitrocontrol = guiCreateComboBox(0.52, 0.1, 0.43, 0.2, ({toggle = "Toggle", hold = "Hold"})[v2432], true, config_scrollers.Gameplay);
        guiComboBoxAddItem(config_gameplay_nitrocontrol, "Toggle");
        guiComboBoxAddItem(config_gameplay_nitrocontrol, "Hold");
        config_scrollers.Performance = guiCreateGridList(135, 25, 340, 460, false, config_window);
        guiSetVisible(config_scrollers.Performance, false);
        local v2433 = xmlFindChild(_client, "performance", 0);
        if not v2433 then
            v2433 = xmlCreateChild(_client, "performance");
            xmlNodeSetAttribute(v2433, "vehmanager", "false");
            xmlNodeSetAttribute(v2433, "weapmanager", "true");
            xmlNodeSetAttribute(v2433, "fpsgraphic", "false");
            xmlNodeSetAttribute(v2433, "plossgraphic", "false");
            xmlNodeSetAttribute(v2433, "speclist", "true");
            xmlNodeSetAttribute(v2433, "roundhud", "false");
            xmlNodeSetAttribute(v2433, "valueshud", "false");
            xmlNodeSetAttribute(v2433, "helpinfo", "true");
            xmlNodeSetAttribute(v2433, "laser", "true");
        end;
        config_performance_usecpu = guiCreateLabel(0.05, 0.04, 0.3, 0.06, "CPU: 0.0%", true, config_scrollers.Performance);
        config_performance_usetiming = guiCreateLabel(0.35, 0.04, 0.3, 0.06, "Timing: 0.000", true, config_scrollers.Performance);
        config_performance_usememory = guiCreateLabel(0.65, 0.04, 0.3, 0.06, "Memory: 0 KB", true, config_scrollers.Performance);
        temp = guiCreateLabel(0.05, 0.1, 0.9, 0.06, "Unload hidden GUI", true, config_scrollers.Performance);
        guiSetFont(temp, "default-bold-small");
        guiLabelSetHorizontalAlign(temp, "center");
        temp = xmlNodeGetAttribute(v2433, "vehmanager") or "false";
        config_performance_vehmanager = guiCreateCheckBox(0.05, 0.16, 0.43, 0.04, "Vehicle manager", temp == "true", true, config_scrollers.Performance);
        if temp ~= "true" then
            guiSetVisible(createVehicleManager(), false);
        end;
        temp = xmlNodeGetAttribute(v2433, "weapmanager") or "false";
        config_performance_weapmanager = guiCreateCheckBox(0.52, 0.16, 0.43, 0.04, "Weapon manager", temp == "true", true, config_scrollers.Performance);
        if temp ~= "true" then
            guiSetVisible(createWeaponManager(), false);
        end;
        temp = xmlNodeGetAttribute(v2433, "adminpanel") or "true";
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
        temp = xmlNodeGetAttribute(v2433, "fpsgraphic") or "true";
        config_performance_fps = guiCreateCheckBox(0.05, 0.33999999999999997, 0.43, 0.04, "FPS Diagram", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "plossgraphic") or "true";
        config_performance_ploss = guiCreateCheckBox(0.05, 0.39999999999999997, 0.43, 0.04, "PacketLoss Diagram", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "helpinfo") or "true";
        config_performance_helpinfo = guiCreateCheckBox(0.05, 0.45999999999999996, 0.43, 0.04, "Help Info", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "speclist") or "true";
        config_performance_spec = guiCreateCheckBox(0.52, 0.33999999999999997, 0.43, 0.04, "Spectate List", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "roundhud") or "true";
        config_performance_roundhud = guiCreateCheckBox(0.52, 0.39999999999999997, 0.43, 0.04, "Round HUD", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "valueshud") or "true";
        config_performance_valueshud = guiCreateCheckBox(0.52, 0.45999999999999996, 0.43, 0.04, "Values of HUD", temp == "true", true, config_scrollers.Performance);
        temp = xmlNodeGetAttribute(v2433, "laser") or "true";
        config_performance_laser = guiCreateCheckBox(0.05, 0.52, 0.43, 0.04, "Aim Lasers", temp == "true", true, config_scrollers.Performance);
        guiGridListClear(config_pagelist);
        for v2434, v2435 in pairs(config_pages) do
            if type(v2435) == "table" then
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, v2434, true, false);
                for v2436 in pairs(v2435) do
                    guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, v2436, false, false);
                end;
            else
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, v2434, false, false);
            end;
        end;
        config_close = guiCreateButton(5, 450, 120, 30, "Close", false, config_window);
        guiSetFont(config_close, "default-bold-small");
        xmlSaveFile(_client);
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
    local v2437 = xscreen * 0.78;
    local v2438 = yscreen * 0.012;
    local v2439 = xscreen * 0.17;
    local v2440 = yscreen * 0.03;
    local v2441 = math.ceil(yscreen * 0.001);
    local __ = xscreen * 0.955;
    local v2443 = 50;
    local v2444 = 0;
    local v2445 = tocolor(0, 255, 0);
    onClientFPSDiagramRender = function() --[[ Line: 204 ]]
        -- upvalues: v2443 (ref), v2444 (ref), v2437 (ref), v2439 (ref), v2438 (ref), v2440 (ref), v2445 (ref), v2441 (ref)
        local v2446 = getTickCount();
        local v2447 = 30000;
        for v2448, v2449 in ipairs(fpsdata) do
            local v2450 = 1 - (math.max(math.min(tonumber(v2449[1]), v2443), v2444) - v2444) / (v2443 - v2444);
            local v2451 = v2448 < #fpsdata and 1 - (math.max(math.min(tonumber(fpsdata[v2448 + 1][1]), v2443), v2444) - v2444) / (v2443 - v2444) or v2450;
            local v2452 = math.min(1, (v2446 - v2449[2]) / v2447);
            if v2448 > 1 then
                local v2453 = (v2446 - fpsdata[v2448 - 1][2]) / v2447;
                if v2453 >= 1 then
                    for __ = v2448, #fpsdata do
                        table.remove(fpsdata, v2448);
                    end;
                    break;
                else
                    dxDrawLine(v2437 + v2439 - v2439 * v2452, v2438 + v2440 * v2451, v2437 + v2439 - v2439 * v2453, v2438 + v2440 * v2450, v2445, v2441);
                end;
            else
                dxDrawLine(v2437 + v2439 - v2439 * v2452, v2438 + v2440 * v2451, v2437 + v2439, v2438 + v2440 * v2450, v2445, v2441);
            end;
        end;
        local v2455 = tostring(fpsdata[1][1]);
        if guiGetText(hud_fps) ~= v2455 then
            guiSetText(hud_fps, v2455);
        end;
    end;
    local v2456 = 10;
    local v2457 = 0;
    local v2458 = tocolor(0, 128, 255);
    onClientPLossDiagramRender = function() --[[ Line: 230 ]]
        -- upvalues: v2456 (ref), v2457 (ref), v2437 (ref), v2439 (ref), v2438 (ref), v2440 (ref), v2458 (ref), v2441 (ref)
        local v2459 = getTickCount();
        local v2460 = 30000;
        for v2461, v2462 in ipairs(plossdata) do
            local v2463 = 1 - (math.max(math.min(tonumber(v2462[1]), v2456), v2457) - v2457) / (v2456 - v2457);
            local v2464 = v2461 < #plossdata and 1 - (math.max(math.min(tonumber(plossdata[v2461 + 1][1]), v2456), v2457) - v2457) / (v2456 - v2457) or v2463;
            local v2465 = math.min(1, (v2459 - v2462[2]) / v2460);
            if v2461 > 1 then
                local v2466 = (v2459 - plossdata[v2461 - 1][2]) / v2460;
                if v2466 >= 1 then
                    for __ = v2461, #plossdata do
                        table.remove(plossdata, v2461);
                    end;
                    break;
                else
                    dxDrawLine(v2437 + v2439 - v2439 * v2465, v2438 + v2440 * v2464, v2437 + v2439 - v2439 * v2466, v2438 + v2440 * v2463, v2458, v2441);
                end;
            else
                dxDrawLine(v2437 + v2439 - v2439 * v2465, v2438 + v2440 * v2464, v2437 + v2439, v2438 + v2440 * v2463, v2458, v2441);
            end;
        end;
        local v2468 = string.format("%.2f", plossdata[1][1]);
        if guiGetText(hud_ploss) ~= v2468 then
            guiSetText(hud_ploss, v2468);
        end;
    end;
    local v2469 = 0;
    local v2470 = 0;
    local v2471 = 0;
    local v2472 = 0;
    local v2473 = 0;
    local v2474 = 100;
    local v2475 = 65536;
    local v2476 = 10;
    local v2477 = 10;
    local v2478 = 3;
    onClientFPSCount = function() --[[ Line: 262 ]]
        -- upvalues: v2469 (ref)
        v2469 = v2469 + 1;
    end;
    updateLimites = function() --[[ Line: 265 ]]
        -- upvalues: v2469 (ref), v2444 (ref), v2471 (ref), v2476 (ref), v2475 (ref), v2472 (ref), v2477 (ref), v2456 (ref), v2473 (ref), v2478 (ref), v2474 (ref), v2470 (ref)
        setElementData(localPlayer, "FPS", tostring(v2469), false);
        setElementData(localPlayer, "PLoss", tostring(getNetworkStats().packetlossLastSecond), false);
        if v2469 < v2444 then
            v2471 = v2471 + 1;
            if v2476 < v2471 then
                callServerFunction("kickPlayer", localPlayer, "Low FPS (" .. v2469 .. " < " .. v2444 .. ")");
                v2471 = 0;
            end;
        else
            v2471 = 0;
        end;
        if getPlayerPing(localPlayer) > v2475 then
            v2472 = v2472 + 1;
            if v2477 < v2472 then
                callServerFunction("kickPlayer", localPlayer, "High Ping (" .. getPlayerPing(localPlayer) .. " > " .. v2475 .. ")");
                v2472 = 0;
            end;
        else
            v2472 = 0;
        end;
        if v2456 > 0 then
            local l_packetlossLastSecond_0 = getNetworkStats().packetlossLastSecond;
            if v2456 < l_packetlossLastSecond_0 then
                v2473 = v2473 + 1;
                if v2478 < v2473 then
                    callServerFunction("kickPlayer", localPlayer, string.format("High Packetloss (%.2f > %.2f)", l_packetlossLastSecond_0, v2456));
                    v2473 = 0;
                end;
            else
                v2473 = 0;
            end;
        end;
        if v2474 > 0 then
            local l_packetlossTotal_0 = getNetworkStats().packetlossTotal;
            if v2474 < l_packetlossTotal_0 then
                callServerFunction("kickPlayer", localPlayer, string.format("High Packetloss Total (%.2f > %.2f)", l_packetlossTotal_0, v2474));
            end;
        end;
        v2469 = -1;
        v2470 = v2470 + 1;
        if v2470 > 10 then
            setElementData(localPlayer, "FPS", getElementData(localPlayer, "FPS"))
            setElementData(localPlayer, "PLoss", getElementData(localPlayer, "PLoss"))
            v2470 = 0;
        end;
    end;
    addUserPanelPage = function(v2481, v2482)
        if config_scrollers[v2482] then
            return false;
        else
            config_pages[v2481][v2482] = true;
            config_scrollers[v2482] = guiCreateGridList(135, 25, 340, 460, false, config_window);
            guiSetVisible(config_scrollers[v2482], false);
            guiGridListClear(config_pagelist);
            for v2483, v2484 in pairs(config_pages) do
                guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, v2483, true, false);
                for v2485 in pairs(v2484) do
                    guiGridListSetItemText(config_pagelist, guiGridListAddRow(config_pagelist), 1, v2485, false, false);
                end;
            end;
            return config_scrollers[v2482];
        end;
    end;
    onClientTacticsChange = function(v2486, __) --[[ Line: 327 ]]
        -- upvalues: v2443 (ref), v2444 (ref), v2456 (ref), v2474 (ref), v2475 (ref), v2476 (ref), v2477 (ref), v2478 (ref)
        if v2486[1] == "version" then
            local v2488 = getTacticsData("version");
            guiSetText(config_window, "Tactics " .. tostring(v2488) .. " - User Panel");
        end;
        if v2486[1] == "limites" then
            if v2486[2] == "fps_limit" then
                v2443 = tonumber(getTacticsData("limites", "fps_limit"));
            elseif v2486[2] == "fps_minimal" then
                v2444 = tonumber(getTacticsData("limites", "fps_minimal"));
            elseif v2486[2] == "packetloss_second" then
                v2456 = tonumber(getTacticsData("limites", "packetloss_second"));
                if v2456 == 0 then
                    v2456 = 10;
                end;
            elseif v2486[2] == "packetloss_total" then
                v2474 = tonumber(getTacticsData("limites", "packetloss_total"));
            elseif v2486[2] == "ping_maximal" then
                v2475 = tonumber(getTacticsData("limites", "ping_maximal"));
            elseif v2486[2] == "warnings_fps" then
                v2476 = tonumber(getTacticsData("limites", "warnings_fps"));
            elseif v2486[2] == "warnings_ping" then
                v2477 = tonumber(getTacticsData("limites", "warnings_ping"));
            elseif v2486[2] == "warnings_packetloss" then
                v2478 = tonumber(getTacticsData("limites", "warnings_packetloss"));
            end;
        end;
    end;
    checkPerformance = function() --[[ Line: 353 ]]
        if not guiGetVisible(config_scrollers.Performance) then
            return killTimer(updPerformance);
        else
            local __, v2490 = getPerformanceStats("Lua timing", "", "tactics");
            local __, v2492 = getPerformanceStats("Lua memory", "", "tactics");
            local v2493 = v2490[1][2];
            local v2494 = v2490[1][3];
            local v2495 = v2492[1][3];
            guiSetText(config_performance_usecpu, "CPU: " .. v2493);
            guiSetText(config_performance_usetiming, "Timing: " .. v2494);
            guiSetText(config_performance_usememory, "Memory: " .. v2495);
            return;
        end;
    end;
    onClientGUIClick = function(v2496, __, __, __) --[[ Line: 364 ]]
        if v2496 ~= "left" then
            return;
        else
            if source == config_pagelist then
                local v2500 = false;
                local v2501 = guiGridListGetSelectedItem(config_pagelist);
                if v2501 >= 0 then
                    v2500 = guiGridListGetItemText(config_pagelist, v2501, 1);
                end;
                for v2502, v2503 in pairs(config_scrollers) do
                    if v2500 == v2502 then
                        guiSetVisible(v2503, true);
                        if v2500 == "Performance" and not isTimer(updPerformance) then
                            updPerformance = setTimer(checkPerformance, 500, 0);
                        end;
                    else
                        guiSetVisible(v2503, false);
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
                local v2504 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_fps) then
                    xmlNodeSetAttribute(v2504, "fpsgraphic", "true");
                    addEventHandler("onClientRefpsgraphicnder", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, true);
                else
                    xmlNodeSetAttribute(v2504, "fpsgraphic", "false");
                    removeEventHandler("onClientRender", root, onClientFPSDiagramRender);
                    guiSetVisible(hud_fps, false);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_ploss then
                local v2505 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_ploss) then
                    xmlNodeSetAttribute(v2505, "plossgraphic", "true");
                    addEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, true);
                else
                    xmlNodeSetAttribute(v2505, "plossgraphic", "false");
                    removeEventHandler("onClientRender", root, onClientPLossDiagramRender);
                    guiSetVisible(hud_ploss, false);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_spec then
                local v2506 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_spec) then
                    xmlNodeSetAttribute(v2506, "speclist", "true");
                    guiSetAlpha(speclist, 0.5);
                else
                    xmlNodeSetAttribute(v2506, "speclist", "false");
                    guiSetAlpha(speclist, 0);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_roundhud then
                local v2507 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_roundhud) then
                    xmlNodeSetAttribute(v2507, "roundhud", "true");
                    for __, v2509 in pairs(components) do
                        guiSetAlpha(v2509.root, 1);
                    end;
                else
                    xmlNodeSetAttribute(v2507, "roundhud", "false");
                    for __, v2511 in pairs(components) do
                        guiSetAlpha(v2511.root, 0);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_helpinfo then
                local v2512 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_helpinfo) then
                    xmlNodeSetAttribute(v2512, "helpinfo", "true");
                    guiSetAlpha(infowindow, 1);
                else
                    xmlNodeSetAttribute(v2512, "helpinfo", "false");
                    guiSetAlpha(infowindow, 0);
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_valueshud then
                local v2513 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_valueshud) then
                    xmlNodeSetAttribute(v2513, "valueshud", "true");
                    guiSetAlpha(values_hud, 1);
                    addEventHandler("onClientElementDataChange", localPlayer, onClientValuesHUDElementDataChange);
                    if getElementData(localPlayer, "Status") == "Play" then
                        addEventHandler("onClientRender", root, onClientValuesHUDRender);
                    end;
                else
                    xmlNodeSetAttribute(v2513, "valueshud", "false");
                    guiSetAlpha(values_hud, 0);
                    removeEventHandler("onClientElementDataChange", localPlayer, onClientValuesHUDElementDataChange);
                    if getElementData(localPlayer, "Status") == "Play" then
                        removeEventHandler("onClientRender", root, onClientValuesHUDRender);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_laser then
                local v2514 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_laser) then
                    xmlNodeSetAttribute(v2514, "laser", "true");
                    if next(laseraimRender) then
                        addEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                    end;
                else
                    xmlNodeSetAttribute(v2514, "laser", "false");
                    if next(laseraimRender) then
                        removeEventHandler("onClientHUDRender", root, onClientLaseraimRender);
                        for __, v2516 in pairs(laseraimRender) do
                            setMarkerColor(v2516, 0, 0, 0, 0);
                        end;
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_audio_voice then
                local v2517 = xmlFindChild(_client, "audio", 0);
                if guiCheckBoxGetSelected(config_audio_voice) then
                    xmlNodeSetAttribute(v2517, "voice", "true");
                else
                    xmlNodeSetAttribute(v2517, "voice", "false");
                end;
                xmlSaveFile(_client);
            end;
            if source == config_audio_music then
                local v2518 = xmlFindChild(_client, "audio", 0);
                if guiCheckBoxGetSelected(config_audio_music) then
                    xmlNodeSetAttribute(v2518, "music", "true");
                else
                    xmlNodeSetAttribute(v2518, "music", "false");
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_vehmanager then
                local v2519 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_vehmanager) then
                    xmlNodeSetAttribute(v2519, "vehmanager", "true");
                    if not guiGetVisible(vehicle_window) then
                        destroyElement(vehicle_window);
                    end;
                else
                    xmlNodeSetAttribute(v2519, "vehmanager", "false");
                    if not isElement(vehicle_window) then
                        guiSetVisible(createVehicleManager(), false);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_weapmanager then
                local v2520 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_weapmanager) then
                    xmlNodeSetAttribute(v2520, "weapmanager", "true");
                    if not guiGetVisible(weapon_window) then
                        destroyElement(weapon_window);
                    end;
                else
                    xmlNodeSetAttribute(v2520, "weapmanager", "false");
                    if not isElement(weapon_window) then
                        guiSetVisible(createWeaponManager(), false);
                    end;
                end;
                xmlSaveFile(_client);
            end;
            if source == config_performance_adminpanel then
                local v2521 = xmlFindChild(_client, "performance", 0);
                if guiCheckBoxGetSelected(config_performance_adminpanel) then
                    xmlNodeSetAttribute(v2521, "adminpanel", "true");
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
                    xmlNodeSetAttribute(v2521, "adminpanel", "false");
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
    onClientGUIScroll = function(__) --[[ Line: 559 ]]
        if source == config_audio_voicevol then
            local v2523 = guiScrollBarGetScrollPosition(config_audio_voicevol);
            guiSetText(config_audio_voicelab, v2523 .. "%");
            for __, v2525 in pairs(voiceThread) do
                if v2525 then
                    setSoundVolume(v2525, 0.01 * v2523);
                end;
            end;
            if isTimer(voiceScroll) then
                resetTimer(voiceScroll);
            else
                voiceScroll = setTimer(function() --[[ Line: 569 ]]
                    local v2526 = xmlFindChild(_client, "audio", 0);
                    local v2527 = guiScrollBarGetScrollPosition(config_audio_voicevol);
                    xmlNodeSetAttribute(v2526, "voicevol", tostring(v2527));
                    if v2527 == 0 and xmlNodeGetAttribute(v2526, "voice") == "true" then
                        xmlNodeSetAttribute(v2526, "voice", "false");
                        guiCheckBoxSetSelected(config_audio_voice, false);
                    end;
                    if v2527 > 0 and xmlNodeGetAttribute(v2526, "voice") == "false" then
                        xmlNodeSetAttribute(v2526, "voice", "true");
                        guiCheckBoxSetSelected(config_audio_voice, true);
                    end;
                    xmlSaveFile(_client);
                end, 500, 1);
            end;
        end;
        if source == config_audio_musicvol then
            local v2528 = guiScrollBarGetScrollPosition(config_audio_musicvol);
            guiSetText(config_audio_musiclab, v2528 .. "%");
            for __, v2530 in pairs(musicThread) do
                if v2530 then
                    setSoundVolume(v2530, 0.01 * v2528);
                end;
            end;
            if isTimer(musicScroll) then
                resetTimer(musicScroll);
            else
                musicScroll = setTimer(function() --[[ Line: 594 ]]
                    local v2531 = xmlFindChild(_client, "audio", 0);
                    local v2532 = guiScrollBarGetScrollPosition(config_audio_musicvol);
                    xmlNodeSetAttribute(v2531, "musicvol", tostring(v2532));
                    if v2532 == 0 and xmlNodeGetAttribute(v2531, "music") == "true" then
                        xmlNodeSetAttribute(v2531, "music", "false");
                        guiCheckBoxSetSelected(config_audio_music, false);
                    end;
                    if v2532 > 0 and xmlNodeGetAttribute(v2531, "music") == "false" then
                        xmlNodeSetAttribute(v2531, "music", "true");
                        guiCheckBoxSetSelected(config_audio_music, true);
                    end;
                    xmlSaveFile(_client);
                end, 500, 1);
            end;
        end;
    end;
    onClientGUIBlur = function() --[[ Line: 611 ]]
        if source == config_audio_voicevol then
            local v2533 = xmlFindChild(_client, "audio", 0);
            local v2534 = guiScrollBarGetScrollPosition(config_audio_voicevol);
            xmlNodeSetAttribute(v2533, "voicevol", tostring(v2534));
            xmlSaveFile(_client);
        end;
        if source == config_audio_musicvol then
            local v2535 = xmlFindChild(_client, "audio", 0);
            local v2536 = guiScrollBarGetScrollPosition(config_audio_musicvol);
            xmlNodeSetAttribute(v2535, "musicvol", tostring(v2536));
            xmlSaveFile(_client);
        end;
    end;
    onClientGUIComboBoxAccepted = function(__) --[[ Line: 625 ]]
        if source == config_gameplay_language then
            local v2538 = config_gameplay_languagelist[guiGetText(config_gameplay_language)];
            loadedLanguage = {};
            local v2539 = xmlLoadFile(v2538);
            if v2539 then
                local v2540 = xmlNodeGetAttribute(v2539, "name") or "";
                local v2541 = xmlNodeGetAttribute(v2539, "author") or "";
                outputChatBox(v2540 .. " (" .. v2541 .. ")", 255, 100, 100, true);
                for __, v2543 in ipairs(xmlNodeGetChildren(v2539)) do
                    loadedLanguage[xmlNodeGetName(v2543)] = xmlNodeGetAttribute(v2543, "string");
                end;
                xmlUnloadFile(v2539);
                local v2544 = xmlFindChild(_client, "gameplay", 0);
                xmlNodeSetAttribute(v2544, "language", v2538);
                xmlSaveFile(_client);
                triggerEvent("onClientLanguageChange", localPlayer, v2538);
            end;
        end;
        if source == config_gameplay_nitrocontrol then
            local v2545 = ({
                Toggle = "toggle", 
                Hold = "hold"
            })[guiGetText(config_gameplay_nitrocontrol)];
            local v2546 = xmlFindChild(_client, "gameplay", 0);
            xmlNodeSetAttribute(v2546, "nitrocontrol", v2545);
            xmlSaveFile(_client);
        end;
    end;
    togglePlayerConfig = function(__, v2548) --[[ Line: 651 ]]
        if guiGetInputEnabled() then
            return;
        else
            if guiGetVisible(config_window) then
                guiSetVisible(config_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            else
                if v2548 then
                    for v2549 = 0, guiGridListGetRowCount(config_pagelist) do
                        if guiGridListGetItemText(config_pagelist, v2549, 1) == v2548 then
                            guiGridListSetSelectedItem(config_pagelist, v2549, 1);
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
    onClientValuesHUDRender = function() --[[ Line: 672 ]]
        local v2550 = tostring(math.ceil(getElementHealth(localPlayer)));
        if guiGetText(hud_health) ~= v2550 then
            guiSetText(hud_health, v2550);
        end;
        local v2551 = getPedArmor(localPlayer);
        if v2551 > 0 then
            if not guiGetVisible(hud_armor) then
                guiSetVisible(hud_armor, true);
            end;
            v2551 = tostring(math.ceil(v2551));
            if guiGetText(hud_armor) ~= v2551 then
                guiSetText(hud_armor, v2551);
            end;
        elseif guiGetVisible(hud_armor) then
            guiSetVisible(hud_armor, false);
        end;
    end;
    onClientValuesHUDElementDataChange = function(v2552, v2553) --[[ Line: 690 ]]
        if v2552 ~= "Status" then
            return;
        else
            if v2553 == "Play" then
                removeEventHandler("onClientRender", root, onClientValuesHUDRender);
                guiSetVisible(values_hud, false);
            elseif getElementData(source, v2552) == "Play" then
                addEventHandler("onClientRender", root, onClientValuesHUDRender);
                guiSetVisible(values_hud, true);
            end;
            return;
        end;
    end;
    onDownloadComplete = function() --[[ Line: 700 ]]
        guiSetAlpha(infowindow, guiCheckBoxGetSelected(config_performance_helpinfo) and 1 or 0);
        guiSetAlpha(speclist, guiCheckBoxGetSelected(config_performance_spec) and 0.5 or 0);
        for __, v2555 in pairs(components) do
            guiSetAlpha(v2555.root, guiCheckBoxGetSelected(config_performance_roundhud) and 1 or 0);
        end;
        guiSetAlpha(values_hud, guiCheckBoxGetSelected(config_performance_valueshud) and 1 or 0);
    end;
    onClientElementDataChange = function(v2556, v2557) --[[ Line: 708 ]]
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
(function(...) --[[ Line: 0 ]]
    local v2558 = {
        {"Damage", 1}, 
        {"Kills", 1}, 
        {"Deaths", -1}
    };
    local v2559 = nil;
    local v2560 = nil;
    onClientResourceStart = function(__) --[[ Line: 9 ]]
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
        local v2562 = 30 + dxGetTextWidth("Players", 1, "default-bold");
        statistic_tabplayersbg = guiCreateStaticImage(15, 445, v2562, 32, "images/color_pixel.png", false, statistic_window);
        guiSetProperty(statistic_tabplayersbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        statistic_tabplayers = guiCreateButton(0, -8, v2562, 32, "Players", false, statistic_tabplayersbg);
        guiSetFont(statistic_tabplayers, "default-bold-small");
        guiSetProperty(statistic_tabplayers, "NormalTextColour", "FFFFFFFF");
        local v2563 = 30 + dxGetTextWidth("Log", 1, "default-bold");
        statistic_tablogbg = guiCreateStaticImage(14 + v2562, 445, v2563, 32, "images/color_pixel.png", false, statistic_window);
        guiSetProperty(statistic_tablogbg, "ImageColours", "tl:00000000 tr:00000000 bl:00000000 br:00000000");
        statistic_tablog = guiCreateButton(0, -8, v2563, 32, "Log", false, statistic_tablogbg);
        guiSetFont(statistic_tablog, "default-bold-small");
        statistic_copy = guiCreateButton(390, 450, 170, 25, "Copy to clipboard", false, statistic_window);
        guiSetFont(statistic_copy, "default-bold-small");
        statistic_close = guiCreateButton(565, 450, 120, 25, "Close", false, statistic_window);
        guiSetFont(statistic_close, "default-bold-small");
    end;
    updateRoundStatistic = function(v2564, v2565, v2566, v2567) --[[ Line: 73 ]]
        -- upvalues: v2558 (ref), v2559 (ref), v2560 (ref)
        if not v2558 or #v2558 == 0 then
            return;
        else
            if #v2565 > 2 then
                table.sort(v2565, function(v2568, v2569) --[[ Line: 76 ]]
                    return v2568.score > v2569.score;
                end);
            end;
            guiSetText(statistic_window, "Round statistic - " .. v2564);
            guiSetPosition(statistic_players, 5, 80, false);
            guiSetSize(statistic_players, 630, 365, false);
            guiSetText(roundScores, " : ");
            for v2570 = 1, math.min(#v2565, 2) do
                local v2571 = v2565[v2570];
                if v2570 == 1 then
                    if v2571.image then
                        v2559 = fileCreate("images/_leftimagefile.jpg");
                    end;
                    if v2571.image and v2559 then
                        fileWrite(v2559, v2571.image);
                        fileClose(v2559);
                        guiStaticImageLoadImage(leftImage, "images/_leftimagefile.jpg");
                        guiSetVisible(leftImage, true);
                        guiSetVisible(leftTeam, false);
                    else
                        guiSetText(leftTeam, v2571.name);
                        guiSetVisible(leftImage, false);
                        guiSetVisible(leftTeam, true);
                    end;
                    guiLabelSetColor(leftTeam, v2571.r, v2571.g, v2571.b);
                    guiSetText(leftSide, v2571.side);
                    guiSetText(roundScores, v2571.score .. guiGetText(roundScores));
                else
                    if v2571.image then
                        v2560 = fileCreate("images/_rightimagefile.jpg");
                    end;
                    if v2571.image and v2560 then
                        fileWrite(v2560, v2571.image);
                        fileClose(v2560);
                        guiStaticImageLoadImage(rightImage, "images/_rightimagefile.jpg");
                        guiSetVisible(rightImage, true);
                        guiSetVisible(rightTeam, false);
                    else
                        guiSetText(rightTeam, v2571.name);
                        guiSetVisible(rightImage, false);
                        guiSetVisible(rightTeam, true);
                    end;
                    guiLabelSetColor(rightTeam, v2571.r, v2571.g, v2571.b);
                    guiSetText(rightSide, v2571.side);
                    guiSetText(roundScores, guiGetText(roundScores) .. v2571.score);
                end;
            end;
            guiGridListClear(statistic_players);
            for __ = 2, guiGridListGetColumnCount(statistic_players) do
                guiGridListRemoveColumn(statistic_players, 2);
            end;
            for __, v2574 in ipairs(v2558) do
                guiGridListAddColumn(statistic_players, v2574[1], 0.65 / #v2558);
            end;
            for __, v2576 in ipairs(v2565) do
                local v2577 = guiGridListAddRow(statistic_players);
                guiGridListSetItemText(statistic_players, v2577, 1, v2576.name .. " - " .. v2576.score, true, false);
                guiGridListSetItemColor(statistic_players, v2577, 1, v2576.r, v2576.g, v2576.b);
                for v2578, v2579 in ipairs(v2558) do
                    if v2576[v2579] then
                        guiGridListSetItemColor(statistic_players, v2577, v2578 + 1, tostring(v2576[v2579]), true, false);
                    end;
                end;
                table.sort(v2576.players, function(v2580, v2581) --[[ Line: 132 ]]
                    -- upvalues: v2558 (ref)
                    for __, v2583 in ipairs(v2558) do
                        if tonumber(v2580[v2583[1]]) > tonumber(v2581[v2583[1]]) then
                            return v2583[2] > 0;
                        elseif tonumber(v2580[v2583[1]]) < tonumber(v2581[v2583[1]]) then
                            return v2583[2] < 0;
                        end;
                    end;
                    return false;
                end);
                for __, v2585 in ipairs(v2576.players) do
                    v2577 = guiGridListAddRow(statistic_players);
                    guiGridListSetItemText(statistic_players, v2577, 1, v2585.name, false, false);
                    guiGridListSetItemColor(statistic_players, v2577, 1, v2576.r, v2576.g, v2576.b);
                    for v2586, v2587 in ipairs(v2558) do
                        guiGridListSetItemText(statistic_players, v2577, v2586 + 1, v2585[v2587[1]] and tostring(v2585[v2587[1]]) or "", false, false);
                    end;
                end;
            end;
            guiSetText(statistic_log, v2566 or "");
            if v2567 then
                return;
            else
                outputInfo(string.format(getLanguageString("help_roundlog"), string.upper(next(getBoundKeys("round_stat")))));
                return;
            end;
        end;
    end;
    toggleRoundStatistic = function() --[[ Line: 155 ]]
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
    onClientGUIClick = function(v2588, __, __, __) --[[ Line: 164 ]]
        -- upvalues: v2558 (ref)
        if v2588 ~= "left" then
            return;
        else
            if source == statistic_close then
                guiSetVisible(statistic_window, false);
                if isAllGuiHidden() then
                    showCursor(false);
                end;
            end;
            if source == statistic_copy then
                local v2592 = 4;
                local v2593 = guiGetText(statistic_window) .. "\n\n";
                for __, v2595 in ipairs(v2558) do
                    v2592 = math.max(v2592, #tostring(v2595[1]));
                end;
                for v2596 = 0, guiGridListGetRowCount(statistic_players) do
                    for v2597 = 1, #v2558 + 1 do
                        local v2598 = guiGridListGetItemText(statistic_players, v2596, v2597);
                        v2592 = math.max(v2592, #tostring(v2598));
                    end;
                end;
                v2592 = v2592 + 3;
                v2593 = v2593 .. "Name" .. string.rep(" ", v2592 - 4);
                for __, v2600 in ipairs(v2558) do
                    local v2601 = v2600[1];
                    v2593 = v2593 .. v2601 .. string.rep(" ", v2592 - #v2601);
                end;
                v2593 = v2593 .. "\n";
                for v2602 = 0, guiGridListGetRowCount(statistic_players) do
                    for v2603 = 1, #v2558 + 1 do
                        local v2604 = guiGridListGetItemText(statistic_players, v2602, v2603);
                        v2593 = v2593 .. v2604 .. string.rep(" ", v2592 - #v2604);
                    end;
                    v2593 = v2593 .. "\n";
                end;
                v2593 = v2593 .. "\n" .. guiGetText(statistic_log);
                setClipboard(v2593);
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
    onClientStatisticChange = function(...) --[[ Line: 212 ]]
        -- upvalues: v2558 (ref)
        v2558 = {};
        for __, v2606 in ipairs({
            ...
        }) do
            if type(v2606) == "string" then
                table.insert(v2558, {
                    tostring(v2606)
                });
            elseif #v2558 > 0 then
                v2558[#v2558][2] = v2606;
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