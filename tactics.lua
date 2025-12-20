(function(...)
    if localPlayer == nil then
        local v0 = createElement("Tactics", "Tactics");
        setElementData(v0, "version", "1.2 r20");
        do
            local l_v0_0 = v0;
            getAllTacticsData = function()
                return getElementData(l_v0_0, "AllData") or {};
            end;
            getTacticsData = function(...)
                local v2 = true;
                local v3 = {...};
                if type(v3[#v3]) == "boolean" then
                    v2 = table.remove(v3);
                end;
                if #v3 == 1 then
                    local v4 = getElementData(l_v0_0, v3[1]);
                    if v2 and type(v4) == "string" and string.find(v4, "|") then
                        return gettok(v4, 1, string.byte("|")), split(gettok(v4, 2, string.byte("|")), ",");
                    else
                        return v4;
                    end;
                elseif #v3 > 1 then
                    local v5 = nil;
                    for v6, v7 in ipairs(v3) do
                        if v6 == 1 then
                            v5 = getElementData(l_v0_0, v7);
                        else
                            v5 = v5[v7];
                        end;
                        if not v5 then
                            return nil;
                        end;
                    end;
                    if v2 and type(v5) == "string" and string.find(v5, "|") then
                        return gettok(v5, 1, string.byte("|")), split(gettok(v5, 2, string.byte("|")), ",");
                    else
                        return v5;
                    end;
                else
                    return nil;
                end;
            end;
            getDataType = function(v8) --[[ Line: 42 ]]
                if type(v8) == "string" then
                    if string.find(v8, "|") then
                        return "parameter";
                    elseif string.find(v8, ":") then
                        return "time";
                    elseif v8 == "true" or v8 == "false" then
                        return "toggle";
                    end;
                end;
                return type(v8);
            end;
            setTacticsData = function(v9, ...) --[[ Line: 50 ]]
                -- upvalues: l_v0_0 (ref)
                local v10 = false;
                local v11 = {...};
                if type(v11[#v11]) == "boolean" then
                    v10 = table.remove(v11);
                end;
                local v12 = nil;
                local v13 = {};
                if #v11 > 1 then
                    v13[1] = getElementData(l_v0_0, v11[1]);
                    if type(v13[1]) ~= "table" then
                        v13[1] = {};
                    end;
                    for v14 = 2, #v11 - 1 do
                        v13[v14] = type(v13[v14 - 1][v11[v14]]) == "table" and v13[v14 - 1][v11[v14]] or {};
                    end;
                    if type(v9) == "table" or v13[#v11 - 1][v11[#v11]] ~= v9 then
                        v12 = v13[#v11 - 1][v11[#v11]];
                        if v10 and getDataType(v12) == "parameter" then
                            v13[#v11 - 1][v11[#v11]] = tostring(v9) .. string.sub(v12, string.find(v12, "|"), -1);
                        elseif type(v9) == "string" then
                            v13[#v11 - 1][v11[#v11]] = tostring(v9);
                        else
                            v13[#v11 - 1][v11[#v11]] = v9;
                        end;
                        for v15 = #v11 - 1, 2, -1 do
                            v13[v15 - 1][v11[v15]] = v13[v15];
                        end;
                    else
                        return false;
                    end;
                elseif #v11 == 1 then
                    if type(v9) == "table" or getElementData(l_v0_0, v11[1]) ~= v9 then
                        v12 = getElementData(l_v0_0, v11[1]);
                        if v10 and getDataType(v12) == "parameter" then
                            v13[1] = tostring(v9) .. string.sub(v12, string.find(v12, "|"), -1);
                        elseif type(v9) == "string" then
                            v13[1] = tostring(v9);
                        else
                            v13[1] = v9;
                        end;
                    else
                        return false;
                    end;
                else
                    return false;
                end;
                setElementData(l_v0_0, v11[1], v13[1]);
                triggerEvent("onTacticsChange", root, v11, v12);
                return true;
            end;
            addEvent("onTacticsChange");
            addEvent("onSetTacticsData", true);
            addEventHandler("onSetTacticsData", resourceRoot, function(v16, ...) --[[ Line: 101 ]]
                if hasObjectPermissionTo(client, "general.tactics_players") then
                    setTacticsData(v16, ...);
                end
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
                for _, v29 in ipairs(getAllTacticsData()) do
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
                    for _, v72 in ipairs(xmlNodeGetChildren(v68)) do
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
                    for _, v78 in ipairs(xmlNodeGetChildren(v76)) do
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
                for _, v82 in ipairs(getElementsByType("gui-window", resourceRoot)) do
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
            for _, v105 in ipairs(replaceCustom) do
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
            triggerServerEvent("onClientCallsServerFunction", root, v113, unpack(v114));
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
                    for _, v126 in ipairs(xmlNodeGetChildren(v124)) do
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

        callClientFunction = function(v150, v151, ...)
            if not v150 or (type(v150) ~= "table" and not isElement(v150) and v150 ~= root and v150 ~= getRootElement()) then
                return false;
            end;
            if not v151 or type(v151) ~= "string" or v151 == "" then
                return false;
            end;   
            local v152 = {...};
            if v152[1] then
                for v153, v154 in next, v152 do
                    if type(v154) == "number" then
                        v152[v153] = tostring(v154);
                    end;
                end;
            end;  
            local sourceElement = v150;
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
                return triggerClientEvent(v150, "onServerCallsClientFunction", sourceElement, v151, unpack(v152 or {}));
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
        for _, v186 in ipairs(getElementsByType("player")) do
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
    wastedTimer = {};
    waitingTimer = nil;
    startTimer = nil;
    winTimer = nil;
    overtimeTimer = nil;
    restartTimer = nil;
    unpauseTimer = nil;
    playersVeh = {};
    addServerTeam = function(v188, v189, v190, v191) --[[ Line: 15 ]]
        local v192 = #getElementsByType("team");
        if not v188 then
            v188 = "Team" .. v192;
        end;
        if not v189 then
            local v193 = math.random(7, 288);
            while v193 == 8 or v193 == 42 or v193 == 65 or v193 == 74 or v193 == 86 or v193 == 119 or v193 == 149 or v193 == 208 or v193 == 239 or v193 == 265 or v193 == 266 or v193 == 267 or v193 == 268 or v193 == 269 or v193 == 270 or v193 == 271 or v193 == 272 or v193 == 273 do
                v193 = math.random(7, 288);
            end;
            v189 = {v193};
        end;
        if not v190 then
            v190 = {math.random(255), math.random(255), math.random(255)};
        end;
        if not v191 then
            v191 = 0;
        end;
        local v194 = createTeam(v188, v190[1], v190[2], v190[3]);
        local v195 = getTacticsData("settings", "friendly_fire") == "true";
        setTeamFriendlyFire(v194, v195);
        if v192 > 0 then
            setElementData(v194, "Skins", v189);
            setElementData(v194, "Score", v191);
            setElementData(v194, "Side", v192);
            local v196 = getTacticsData("Sides");
            if not v196 or #v196 == 0 then
                v196 = {};
            end;
            table.insert(v196, v194);
            setTacticsData(v196, "Sides");
            local v197 = {};
            for v198, v199 in ipairs(v196) do
                v197[v199] = v198;
            end;
            setTacticsData(v197, "Teamsides");
        end;
        return v194;
    end;
    removeServerTeam = function(v200) --[[ Line: 44 ]]
        if #getElementsByType("team") <= 1 then
            return false;
        else
            local v201 = getTacticsData("Sides") or {};
            for v202, v203 in ipairs(v201) do
                if v203 == v200 then
                    table.remove(v201, v202);
                end;
            end;
            setTacticsData(v201, "Sides");
            local v204 = {};
            for v205, v206 in ipairs(v201) do
                v204[v206] = v205;
            end;
            setTacticsData(v204, "Teamsides");
            return destroyElement(v200);
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
    applyStats = function(v207) --[[ Line: 63 ]]
        for v208 in pairs(convertWeaponSkillToNames) do
            setPedStat(v207, v208, 999);
        end;
        local v209 = {
            [22] = 999, 
            [225] = 999, 
            [160] = 999, 
            [229] = 999, 
            [230] = 999
        };
        for v210, v211 in pairs(v209) do
            setPedStat(v207, v210, v211);
        end;
    end;
    fixPlayerID = function(v212) --[[ Line: 78 ]]
        if getElementID(v212) ~= "" then
            return false;
        else
            local v213 = 1;
            while getElementByID(tostring(v213)) do
                v213 = v213 + 1;
            end;
            setElementID(v212, tostring(v213));
            return v213;
        end;
    end;
    setSideNames = function(v214, v215) --[[ Line: 87 ]]
        local v216 = getTacticsData("SideNames") or {"", ""};
        if not v214 then
            v214 = v216[1];
        end;
        if not v215 then
            v215 = v216[2];
        end;
        setTacticsData({v214, v215}, "SideNames");
    end;
    onResourceStop = function(_) --[[ Line: 93 ]]
        for _, v219 in ipairs(getElementsByType("player")) do
            setElementData(v219, "Status", nil);
        end;
    end;
    onResourceStart = function(v220) --[[ Line: 100 ]]
        if getThisResource() == v220 then
            setGameType("Tactics " .. getTacticsData("version"));
            setTacticsData({
                "Attack", 
                "Defend"
            }, "SideNames");
            if not fileExists("config/configs.xml") then
                local v221 = xmlCreateFile("config/configs.xml", "configs");
                local v222 = xmlCreateChild(v221, "current");
                xmlNodeSetAttribute(v222, "src", "_default");
                xmlSaveFile(v221);
                xmlUnloadFile(v221);
                if fileExists("config/_default.xml") then
                    fileDelete("config/_default.xml");
                end;
                defaultConfig(true);
            else
                local v223 = getCurrentConfig();
                defaultConfig(true);
                startConfig(v223, true);
            end;
            local v224 = {};
            for v225 in pairs(getAllElementData(getElementByID("Tactics"))) do
                table.insert(v224, v225);
            end;
            setTacticsData(v224, "AllData");
            for _, v227 in ipairs(getElementsByType("player")) do
                fixPlayerID(v227);
                applyStats(v227);
            end;
            setTimer(nextMap, 50, 1);
        elseif getResourceInfo(v220, "type") == "map" and getResourceName(v220) == getTacticsData("MapResName") then
            local v228 = {
                modename = getTacticsData("Map"), 
                name = getTacticsData("MapName", false) or "unnamed", 
                author = getTacticsData("MapAuthor", false), 
                resname = getResourceName(v220), 
                resource = v220
            };
            triggerEvent("onMapStarting", root, v228, {}, {
                statsKey = "name"
            });
            local v229 = getTacticsData("MapName", false);
            outputServerLog("* Change map to " .. v229);
        end;
    end;
    onMapStarting = function(_) --[[ Line: 139 ]]
        waitingTimer = "wait";
        local v231 = TimeToSec(getTacticsData("settings", "time") or "12:00");
        setTime(math.floor(v231 / 60), v231 - 60 * math.floor(v231 / 60));
        for _, v233 in ipairs(getElementsByType("player")) do
            removeElementData(v233, "RespawnLives");
        end;
    end;
    onResourcePreStart = function(v234) --[[ Line: 147 ]]
        if getResourceInfo(v234, "type") == "map" then
            local v235 = getTacticsData("modes_defined") or {};
            local v236 = false;
            for v237 in pairs(v235) do
                if string.find(getResourceName(v234), v237) == 1 then
                    v236 = v237;
                end;
            end;
            if v236 then
                local v238 = {
                    modename = getTacticsData("Map"), 
                    name = getTacticsData("MapName", false) or "unnamed", 
                    author = getTacticsData("MapAuthor", false), 
                    resname = getTacticsData("MapResName")
                };
                triggerClientEvent(root, "onClientMapStopping", root, v238);
                triggerEvent("onMapStopping", root, v238);
                local v239 = getResourceInfo(v234, "name");
                if not v239 then
                    v239 = string.sub(string.gsub(getResourceName(v234), "_", " "), #v236 + 2);
                    if #v239 > 1 then
                        v239 = string.upper(string.sub(v239, 1, 1)) .. string.sub(v239, 2);
                    end;
                end;
                v239 = string.upper(string.sub(v236, 1, 1)) .. string.sub(v236, 2) .. ": " .. v239;
                setMapName(v239);
                setTacticsData(v236, "Map");
                setTacticsData(v239, "MapName");
                setTacticsData(getResourceInfo(v234, "author"), "MapAuthor");
                setTacticsData(getResourceName(v234), "MapResName");
                local v240 = get(getResourceName(v234) .. ".Interior");
                if v240 then
                    setTacticsData(tonumber(v240), "Interior");
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
    forcedStartRound = function(v241) --[[ Line: 192 ]]
        if getRoundState() == "started" then
            return;
        elseif not v241 and isTimer(startTimer) then
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
            if v241 == "faststart" then
                callClientFunction(root, "showCountdown", 0);
                callClientFunction(root, "fixTickCount", getTickCount());
                for _, v243 in ipairs(getElementsByType("player")) do
                    if getElementData(v243, "Status") == "Play" then
                        local v244 = getPedOccupiedVehicle(v243);
                        if isElement(v244) then
                            setElementFrozen(v244, false);
                        end;
                        setElementFrozen(v243, false);
                        toggleAllControls(v243, true);
                    end;
                end;
                local v245 = getTacticsData("Map");
                local v246 = TimeToSec(getTacticsData("modes", v245, "timelimit") or "0:00");
                if v246 <= 0 then
                    setTacticsData(nil, "timeleft");
                    if isTimer(overtimeTimer) then
                        killTimer(overtimeTimer);
                    end;
                else
                    setTacticsData(getTickCount() + v246 * 1000, "timeleft");
                    if isTimer(overtimeTimer) then
                        killTimer(overtimeTimer);
                    end;
                    overtimeTimer = setTimer(triggerEvent, v246 * 1000, 1, "onRoundTimesup", root);
                end;
                triggerEvent("onRoundStart", root);
                triggerClientEvent(root, "onClientRoundStart", root);
            elseif v241 == "notround" then
                setTacticsData(nil, "timeleft");
                if isTimer(overtimeTimer) then
                    killTimer(overtimeTimer);
                end;
                for _, v248 in ipairs(getElementsByType("player")) do
                    if getElementData(v248, "Status") == "Play" then
                        local v249 = getPedOccupiedVehicle(v248);
                        if isElement(v249) then
                            setElementFrozen(v249, false);
                        end;
                        setElementFrozen(v248, false);
                        toggleAllControls(v248, true);
                    end;
                end;
                triggerEvent("onRoundStart", root);
                triggerClientEvent(root, "onClientRoundStart", root);
            else
                local v250 = tonumber(getTacticsData("settings", "countdown_start")) or 3;
                startTimer = setTimer(onStartCount, 2000, 1, v250);
                triggerEvent("onRoundCountdownStarted", root, 2000 + v250 * 1000);
                for _, v252 in ipairs(getElementsByType("player")) do
                    if getElementData(v252, "Status") then
                        triggerClientEvent(v252, "onClientRoundCountdownStarted", root, 2000 + v250 * 1000);
                    end;
                end;
            end;
            return;
        end;
    end;
    onStartCount = function(v253) --[[ Line: 245 ]]
        if v253 > 0 then
            callClientFunction(root, "showCountdown", v253);
            startTimer = setTimer(onStartCount, 1000, 1, v253 - 1);
        else
            forcedStartRound("faststart");
        end;
    end;
    endRound = function(v254, v255, v256) --[[ Line: 253 ]]
        local l_pairs_0 = pairs;
        local v258 = v256 or {};
        for v259, v260 in l_pairs_0(v258) do
            local v261 = getElementData(v259, "Score") or 0;
            setElementData(v259, "Score", v261 + v260);
        end;
        triggerEvent("onRoundFinish", root, v254, v255, v256);
        triggerClientEvent(root, "onClientRoundFinish", root, v254, v255, v256);
        l_pairs_0 = getTacticsData("MapName", false);
        setTacticsData({v254, v255}, "message");
        if v254 then
            v258 = "";
            if type(v254) == "table" then
                if type(v254[1]) == "string" then
                    local l_v254_0 = v254;
                    local v263 = table.remove(l_v254_0, 1);
                    v258 = string.format(getString(tostring(v263)), unpack(l_v254_0));
                else
                    local v264 = v254[4];
                    local l_v254_1 = v254;
                    table.remove(l_v254_1, 1);
                    table.remove(l_v254_1, 1);
                    table.remove(l_v254_1, 1);
                    table.remove(l_v254_1, 1);
                    v258 = string.format(getString(tostring(v264)), unpack(l_v254_1));
                end;
            elseif type(v254) == "string" then
                v258 = getString(v254);
                if #v258 == 0 then
                    v258 = tostring(v254);
                end;
            else
                v258 = tostring(v254);
            end;
            outputServerLog("* Map " .. removeColorCoding(l_pairs_0) .. " ended [" .. removeColorCoding(v258) .. "]");
        else
            outputServerLog("* Map " .. removeColorCoding(l_pairs_0) .. " ended");
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
    clearMap = function() --[[ Line: 292 ]]
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
        for v266, v267 in pairs(wastedTimer) do
            if isTimer(v267) then
                killTimer(v267);
                wastedTimer[v266] = nil;
            end;
        end;
        for _, v269 in ipairs(getElementsByType("player")) do
            setElementData(v269, "Loading", true);
        end;
        restartTimer = setTimer(nextMap, 3000, 1);
    end;
    startMap = function(v270, v271) --[[ Line: 313 ]]
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
            local v272 = getTacticsData("modes_defined");
            local v273 = getTacticsData("map_disabled") or {};
            if v270 then
                if type(v270) == "string" and v272[v270] then
                    local v274 = {};
                    for _, v276 in ipairs(getResources()) do
                        if getResourceInfo(v276, "type") == "map" and string.find(getResourceName(v276), v270) == 1 then
                            table.insert(v274, v276);
                        end;
                    end;
                    if #v274 > 0 then
                        local v277 = v274[math.random(#v274)];
                        startMap(v277, "random");
                        return true;
                    else
                        return false;
                    end;
                else
                    if type(v270) == "string" then
                        v270 = getResourceFromName(v270);
                    end;
                    if v270 and getResourceInfo(v270, "type") == "map" then
                        if type(v271) == "string" and v271 == "vote" then
                            local v278 = getResourceName(v270);
                            local v279 = string.lower(string.sub(v278, 1, string.find(v278, "_") - 1));
                            if getTacticsData("modes", v279, "enable") == "false" or v273[v278] then
                                return false;
                            end;
                        end;
                        if type(v271) == "number" then
                            setTacticsData(v271, "ResourceCurrent");
                        end;
                        for _, v281 in ipairs(getResources()) do
                            if getResourceState(v281) == "running" and getResourceInfo(v281, "type") == "map" then
                                for _, v283 in ipairs(getElementChildren(getResourceRootElement(v281))) do
                                    destroyElement(v283);
                                end;
                                if v270 ~= v281 then
                                    stopResource(v281);
                                end;
                            end;
                        end;
                        clearMap();
                        if not startResource(v270) then
                            restartResource(v270);
                        end;
                        local v284 = getResourceInfo(v270, "name");
                        local v285 = getResourceName(v270);
                        local v286 = "";
                        for v287 in pairs(v272) do
                            if string.find(v285, v287) == 1 then
                                v286 = v287;
                                break;
                            end;
                        end;
                        if not v284 then
                            v284 = string.sub(string.gsub(v285, "_", " "), #v286 + 2);
                            if #v284 > 1 then
                                v284 = string.upper(string.sub(v284, 1, 1)) .. string.sub(v284, 2);
                            end;
                        end;
                        v284 = string.upper(string.sub(v286, 1, 1)) .. string.sub(v286, 2) .. ": " .. v284;
                        if type(v271) == "string" and v271 == "random" then
                            outputLangString(root, "map_change_random", v284);
                        else
                            outputLangString(root, "map_change", v284);
                        end;
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    nextMap = function() --[[ Line: 389 ]]
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
            local v288 = getTacticsData("ResourceNext");
            local v289 = getTacticsData("map_disabled") or {};
            if v288 then
                local v290 = getResourceFromName(v288);
                return startMap(v290);
            else
                if getTacticsData("automatics") == "cycler" then
                    local v291 = getTacticsData("Resources");
                    if v291 and #v291 > 0 then
                        local v292 = getTacticsData("ResourceCurrent");
                        if not v292 or #v291 <= v292 then
                            v292 = 1;
                        else
                            v292 = v292 + 1;
                        end;
                        local v293 = v291[v292][1];
                        if v289[v293] then
                            return false;
                        else
                            setTacticsData(v292, "ResourceCurrent");
                            return startMap(v293);
                        end;
                    end;
                end;
                if getTacticsData("automatics") == "lobby" then
                    local v294 = {};
                    for _, v296 in ipairs(getResources()) do
                        if getResourceInfo(v296, "type") == "map" and string.find(getResourceName(v296), "lobby") == 1 and not v289[getResourceName(v296)] then
                            table.insert(v294, v296);
                        end;
                    end;
                    if #v294 > 0 then
                        local v297 = v294[math.random(#v294)];
                        return startMap(v297);
                    end;
                end;
                if getTacticsData("automatics") == "voting" then
                    local v298 = getTacticsData("modes_defined");
                    local v299 = {};
                    for _, v301 in ipairs(getResources()) do
                        if getResourceInfo(v301, "type") == "map" then
                            for v302 in pairs(v298) do
                                if v302 ~= "lobby" and string.find(getResourceName(v301), v302) == 1 and getTacticsData("modes", v302, "enable") ~= "false" and not v289[getResourceName(v301)] then
                                    table.insert(v299, getResourceName(v301));
                                end;
                            end;
                        end;
                    end;
                    if #v299 > 0 then
                        local v303 = {};
                        for _ = 1, math.min(8, #v299) do
                            local v305 = math.random(#v299);
                            local v306 = v299[v305];
                            table.remove(v299, v305);
                            table.insert(v303, {
                                v306
                            });
                        end;
                        table.insert(v303, {
                            getTacticsData("MapResName"), 
                            "Play again"
                        });
                        triggerEvent("onPlayerVote", root, v303);
                        winTimer = "voting";
                        setGameSpeed(tonumber(getTacticsData("settings", "gamespeed") or 1));
                        return true;
                    end;
                end;
                local v307 = getTacticsData("modes_defined");
                local v308 = {};
                for _, v310 in ipairs(getResources()) do
                    if getResourceInfo(v310, "type") == "map" then
                        for v311 in pairs(v307) do
                            if string.find(getResourceName(v310), v311) == 1 and getTacticsData("modes", v311, "enable") ~= "false" and not v289[getResourceName(v310)] then
                                table.insert(v308, v310);
                            end;
                        end;
                    end;
                end;
                if #v308 > 0 then
                    local v312 = v308[math.random(#v308)];
                    return startMap(v312);
                else
                    return false;
                end;
            end;
        end;
    end;
    swapTeams = function() --[[ Line: 475 ]]
        local v313 = getTacticsData("Sides") or {};
        local v314 = getElementsByType("team");
        table.remove(v314, 1);
        if #v313 ~= #v314 then
            v313 = {
                unpack(v314)
            };
        end;
        table.insert(v313, v313[1]);
        table.remove(v313, 1);
        setTacticsData(v313, "Sides");
        local v315 = {};
        for v316, v317 in ipairs(v313) do
            v315[v317] = v316;
        end;
        setTacticsData(v315, "Teamsides");
    end;
    onPlayerConnect = function(v318, v319, _, _, _, _) --[[ Line: 490 ]]
        outputLangString(root, "connect", v318, v319);
    end;
    onPlayerJoin = function() --[[ Line: 493 ]]
        setElementData(source, "Status", nil);
        fixPlayerID(source);
        applyStats(source);
        bindKey(source, "R", "down", userRestore);
    end;
    userRestore = function(v324) --[[ Line: 499 ]]
        if getElementData(v324, "Status") ~= "Spectate" then
            return;
        else
            local v325 = getTacticsData("Restores") or {};
            for v326, v327 in ipairs(v325) do
                if v327[1] == getPlayerName(v324) then
                    restorePlayerLoad(v324, v326);
                    return;
                end;
            end;
            local v328 = getTacticsData("Map");
            if (getTacticsData("modes", v328, "respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
                outputLangString(root, "add_to_round", getPlayerName(v324));
                triggerEvent("onPlayerRoundRespawn", v324);
            end;
            return;
        end;
    end;
    onPlayerDownloadComplete = function() --[[ Line: 515 ]]
        callClientFunction(client, "fixTickCount", getTickCount());
        callClientFunction(client, "setTime", getTime());
        setElementData(client, "Status", "Joining");
        if isRoundPaused() then
            fadeCamera(client, true, 0);
        else
            fadeCamera(client, true, 2);
        end;
    end;
    onPlayerMapLoad = function() --[[ Line: 525 ]]
        local v329 = getPlayerTeam(client);
        if not v329 or getElementData(client, "ChangeTeam") then
            setPlayerTeam(client, nil);
            setElementData(client, "ChangeTeam", nil);
            setElementData(client, "Status", "Joining");
        elseif v329 == getElementsByType("team")[1] or getElementData(client, "spectateskin") then
            spawnPlayer(client, 0, 0, 0, 0, getElementModel(client), 0, 0, v329);
            setElementData(client, "Status", "Spectate");
            callClientFunction(client, "setCameraSpectating", nil, "playertarget");
        else
            triggerEvent("onPlayerRoundSpawn", client);
        end;
        triggerClientEvent(root, "onClientPlayerBlipUpdate", client);
    end;
    onPlayerMapReady = function() --[[ Line: 542 ]]
        if getRoundState() == "stopped" and client then
            local v330 = getPlayerTeam(client);
            if v330 and v330 ~= getElementsByType("team")[1] and not getElementData(client, "spectateskin") then
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
    onPlayerTeamSelect = function(v331, v332, adm) --[[ Line: 557 ]]
        --if client ~= source and not adm then return end
        if not v331 then
            local v333 = getElementsByType("team");
            table.remove(v333, 1);
            table.sort(v333, function(v334, v335) --[[ Line: 561 ]]
                return countPlayersInTeam(v334) < countPlayersInTeam(v335);
            end);
            v331 = v333[1];
        end;
        setPlayerTeam(source, v331);
        if not v332 or type(v332) ~= "number" then
            local skins = getElementData(v331, "Skins")
            if type(skins) == "table" and type(skins[1]) == "number" then
                v332 = skins[1]
            else
                v332 = 71
            end
        end;
        setElementModel(source, v332);
        if v331 == getElementsByType("team")[1] or getElementData(source, "spectateskin") then
            spawnPlayer(source, 0, 0, 0, 0, v332, 0, 0, v331);
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
    onPlayerRoundSpawn = function() --[[ Line: 583 ]]
        triggerClientEvent(root, "onClientPlayerRoundSpawn", source);
    end;
onPlayerRoundRespawn = function() --[[ Line: 586 ]]
    if isTimer(wastedTimer[client]) then
        killTimer(wastedTimer[client])
    end
    
    -- Validación del elemento client antes de usar triggerClientEvent
    local sourceElement = client
    
    if not sourceElement or (not isElement(sourceElement) and sourceElement ~= root and sourceElement ~= getRootElement()) then
        -- Si client no es válido, salir de la función o manejar el error
        return false
    end
    
    -- Usar pcall para manejar errores en la llamada a triggerClientEvent
    local success, result = pcall(function()
        return triggerClientEvent(root, "onClientPlayerRoundRespawn", sourceElement)
    end)
    
    if not success then
        -- Manejar el error según sea necesario
        return false
    end
    
    return result
end
    onPlayerSpawn = function() --[[ Line: 590 ]]
        giveWeapon(source, 44);
        takeWeapon(source, 44);
        applyStats(source);
        local v336 = tonumber(getTacticsData("settings", "player_start_health"));
        local v337 = tonumber(getTacticsData("settings", "player_start_armour"));
        setElementHealth(source, v336);
        setPedArmor(source, v337);
    end;
    onPlayerQuit = function(v338, v339, _) --[[ Line: 599 ]]
        if getElementData(source, "Status") == "Play" and getTacticsData("Map") ~= "lobby" and getTacticsData("settings", "timeout_to_pause") == "true" then
            triggerEvent("onPause", root, true);
        end;
        if (isTimer(waitingTimer) or waitingTimer == "wait") and getTacticsData("settings", "countdown_auto") == "true" and (not getUnreadyPlayers() or getUnreadyPlayers() == source) then
            forcedStartRound();
        end;
        if v339 then
            v339 = " [" .. v339 .. "]";
        else
            v339 = "";
        end;
        if restorePlayerSave(source) then
            outputLangString(root, "disconnect_save", getPlayerName(source), v338, v339);
        else
            outputLangString(root, "disconnect", getPlayerName(source), v338, v339);
        end;
    end;
    local v341 = {};
    onPlayerChangeNick = function(v342, v343) --[[ Line: 616 ]]
        -- upvalues: v341 (ref)
        if v341[source] and v341[source] > getTickCount() - 5000 then
            cancelEvent();
            outputLangString(source, "change_nick_cancel");
            return;
        else
            v341[source] = getTickCount();
            outputLangString(root, "change_nick", tostring(v342), tostring(v343));
            return;
        end;
    end;
    onRoundTimesup = function() --[[ Line: 625 ]]
        triggerClientEvent(root, "onClientRoundTimesup", root);
    end;
    restorePlayerSave = function(v344) --[[ Line: 628 ]]
        if not isElement(v344) or getElementData(v344, "Status") ~= "Play" or getElementData(v344, "Loading") or not getPlayerTeam(v344) then
            return false;
        else
            local v345 = getTacticsData("Restores") or {};
            local v346 = getPlayerName(v344);
            local v347 = getPlayerTeam(v344) or nil;
            local v348 = getElementModel(v344);
            local v349 = getElementHealth(v344);
            local v350 = getPedArmor(v344);
            local v351 = getElementInterior(v344);
            local v352 = {};
            for v353 = 0, 12 do
                local v354 = getPedWeapon(v344, v353);
                local v355 = getPedTotalAmmo(v344, v353);
                local v356 = getPedAmmoInClip(v344, v353);
                if v354 > 0 and v355 > 0 then
                    table.insert(v352, {
                        v354, 
                        v355, 
                        v356
                    });
                end;
            end;
            local v357 = getPedWeaponSlot(v344);
            local v358 = 0;
            local v359 = 0;
            local v360 = 0;
            local v361 = 0;
            local v362 = 0;
            local v363 = 0;
            local v364 = 0;
            local v365 = false;
            local v366 = 0;
            local v367 = getPedOccupiedVehicle(v344);
            if not v367 then
                local v368, v369, v370 = getElementPosition(v344);
                v360 = v370;
                v359 = v369;
                v358 = v368;
                v361 = getPedRotation(v344);
                v368, v369, v370 = getElementVelocity(v344);
                v364 = v370;
                v363 = v369;
                v362 = v368;
                isfire = isElementOnFire(v344);
            else
                v366 = getPedOccupiedVehicleSeat(v344);
            end;
            local v371 = getAllElementData(v344) or {};
            table.insert(v345, {
                v346, 
                v347, 
                v348, 
                v349, 
                v350, 
                v351, 
                v352, 
                v357, 
                v367, 
                v358, 
                v359, 
                v360, 
                v361, 
                v362, 
                v363, 
                v364, 
                v365, 
                v366, 
                v371
            });
            setTacticsData(v345, "Restores");
            triggerEvent("onPlayerStored", v344, #v345);
            return #v345;
        end;
    end;
    restorePlayerLoad = function(v372, v373) --[[ Line: 664 ]]
        local v374 = getTacticsData("Restores");
        if isElement(v372) and v374[v373] then
            local v375, v376, v377, v378, v379, v380, v381, v382, v383, v384, v385, v386, v387, v388, v389, v390, v391, v392, v393 = unpack(v374[v373]);
            setCameraTarget(v372, v372);
            spawnPlayer(v372, v384, v385, v386, v387, v377, v380, 0, v376);
            callClientFunction(source, "setCameraInterior", v380);
            setElementHealth(v372, v378);
            setPedArmor(v372, v379);
            for _, v395 in ipairs(v381) do
                giveWeapon(v372, v395[1], v395[3]);
                if v395[2] > v395[3] then
                    giveWeapon(v372, v395[1], v395[2] - v395[3]);
                end;
            end;
            setPedWeaponSlot(v372, v382);
            if v383 then
                warpPedIntoVehicle(v372, v383, v392);
            else
                setElementVelocity(v372, v388, v389, v390);
                setElementOnFire(v372, v391);
            end;
            for v396, v397 in pairs(v393) do
                if v396 ~= "ID" then
                    setElementData(v372, v396, v397);
                end;
            end;
            fadeCamera(v372, true, 0);
            outputLangString(root, "player_restored", getPlayerName(v372), v375);
            triggerEvent("onPlayerRestored", v372, v373);
            return true;
        else
            return false;
        end;
    end;
    getRestoreCount = function() --[[ Line: 698 ]]
        return #(getTacticsData("Restores") or {});
    end;
    getRestoreData = function(v398) --[[ Line: 701 ]]
        local v399 = getTacticsData("Restores") or {};
        if not v399[v398] then
            return false;
        else
            local v400, v401, v402, v403, v404, v405, v406, v407, v408, v409, v410, v411, v412, v413, v414, v415, v416, v417, v418 = unpack(v399[v398]);
            return {
                name = v400, 
                posX = v409, 
                posY = v410, 
                posZ = v411, 
                rotation = v412, 
                interior = v405, 
                team = v401, 
                skin = v402, 
                health = v403, 
                armour = v404 or 0, 
                velocityX = v413 or 0, 
                velocityY = v414 or 0, 
                velocityZ = v415 or 0, 
                onfire = v416 or false, 
                weapons = v406 or {}, 
                weaponslot = v407 or 0, 
                vehicle = v408 or nil, 
                vehicleseat = v417 or nil, 
                data = v418 or {}
            };
        end;
    end;
    onPlayerWeaponpackChose = function(v419, v420) --[[ Line: 725 ]]
        if getRoundState() ~= "started" then
            return;
        else
            takeAllWeapons(v419);
            local v421 = getTacticsData("weapon_balance") or {};
            local v422 = 0;
            for _, v424 in ipairs(v420) do
                if v424.id then
                    local v425 = getPlayerTeam(v419);
                    local v426 = getSlotFromWeapon(v424.id);
                    if v421[v424.name] and v425 then
                        local v427 = 0;
                        for _, v429 in ipairs(getPlayersInTeam(v425)) do
                            if getPedWeapon(v429, v426) == v424.id then
                                v427 = v427 + 1;
                            end;
                        end;
                        if tonumber(v421[v424.name]) <= v427 then
                            outputLangString(v419, "weapon_limited", v424.name, tonumber(v421[v424.name]));
                        else
                            giveWeapon(v419, v424.id, v424.ammo);
                            setWeaponAmmo(v419, v424.id, v424.ammo);
                        end;
                    else
                        giveWeapon(v419, v424.id, v424.ammo);
                        setWeaponAmmo(v419, v424.id, v424.ammo);
                    end;
                    if v422 == 0 then
                        v422 = v426;
                    end;
                end;
            end;
            setPedWeaponSlot(v419, v422);
            triggerEvent("onPlayerWeaponpackGot", v419, v420);
            triggerClientEvent(root, "onClientPlayerWeaponpackGot", v419, v420);
            return;
        end;
    end;
    onPlayerVehicleSelect = function(v430, v431, v432) --[[ Line: 756 ]]
        if getElementData(v430, "Status") ~= "Play" then
            return;
        else
            local v433 = getPedOccupiedVehicle(v430);
            local v434 = false;
            if v433 then
                setElementModel(v433, v431);
                local v435 = getVehicleSirensOn(v433);
                removeVehicleSirens(v433);
                local v436 = getTacticsData("handlings")[v431];
                if v436 then
                    for v437, v438 in pairs(v436) do
                        if v437 == "sirens" then
                            addVehicleSirens(v433, v438.count, v438.type, v438.flags["360"], v438.flags.DoLOSCheck, v438.flags.UseRandomiser, v438.flags.Silent);
                            for v439 = 1, v438.count do
                                local v440, v441, v442, v443 = getColorFromString("#" .. v438[v439].color);
                                setVehicleSirens(v433, v439, v438[v439].x, v438[v439].y, v438[v439].z, v441, v442, v443, v440, v438[v439].minalpha);
                            end;
                            setVehicleSirensOn(v433, v435 or false);
                        elseif v437 == "modelFlags" or v437 == "handlingFlags" then
                            setVehicleHandling(v433, v437, tonumber(v436[v437]));
                        elseif type(v436[v437]) == "table" then
                            setVehicleHandling(v433, v437, {
                                unpack(v436[v437])
                            });
                        else
                            setVehicleHandling(v433, v437, v436[v437]);
                        end;
                    end;
                end;
            else
                local v444 = tonumber(getTacticsData("settings", "vehicle_per_player") or 2);
                local v445, v446, v447 = getElementPosition(v430);
                local v448, v449, v450 = getElementVelocity(v430);
                local v451 = 0;
                local v452 = 0;
                local v453 = getPedRotation(v430);
                v433 = createMapVehicle(v431, v445, v446, v447 + 1, v451, v452, v453);
                setElementInterior(v433, getElementInterior(v430));
                setElementVelocity(v433, v448, v449, v450);
                warpPedIntoVehicle(v430, v433);
                if not playersVeh[v430] then
                    playersVeh[v430] = {};
                end;
                table.insert(playersVeh[v430], 1, v433);
                while v444 < #playersVeh[v430] and v444 > 0 do
                    if isElement(playersVeh[v430][#playersVeh[v430]]) then
                        destroyElement(playersVeh[v430][#playersVeh[v430]]);
                    end;
                    table.remove(playersVeh[v430]);
                end;
                local v454 = getTacticsData("handlings")[v431];
                if v454 and v454.sirens then
                    local l_sirens_0 = v454.sirens;
                    addVehicleSirens(v433, l_sirens_0.count, l_sirens_0.type, l_sirens_0.flags["360"], l_sirens_0.flags.DoLOSCheck, l_sirens_0.flags.UseRandomiser, l_sirens_0.flags.Silent);
                    for v456 = 1, l_sirens_0.count do
                        local v457, v458, v459, v460 = getColorFromString("#" .. l_sirens_0[v456].color);
                        setVehicleSirens(v433, v456, l_sirens_0[v456].x, l_sirens_0[v456].y, l_sirens_0[v456].z, v458, v459, v460, v457, l_sirens_0[v456].minalpha);
                    end;
                end;
                v434 = true;
            end;
            addVehicleUpgrade(v433, 1008);
            if getVehicleType(v433) == "Train" then
                setTrainDerailed(v433, true);
            end;
            triggerEvent("onPlayerVehiclepackGot", v430, v433, v434);
            triggerClientEvent(root, "onClientPlayerVehiclepackGot", v430, v433, v434, v432);
            return;
        end;
    end;
    onTacticsChange = function(v461, _) --[[ Line: 818 ]]
        if v461[1] == "settings" then
            if v461[2] == "countdown_auto" and getTacticsData("settings", "countdown_auto") == "true" and getRoundState() ~= "started" then
                if not getUnreadyPlayers() then
                    forcedStartRound();
                elseif waitingTimer == "wait" then
                    waitingTimer = setTimer(forcedStartRound, 1000 * TimeToSec(getTacticsData("settings", "countdown_force") or "0:10"), 1);
                end;
            end;
            if v461[2] == "player_dead_visible" then
                if getTacticsData("settings", "player_dead_visible") == "false" then
                    for _, v464 in ipairs(getElementsByType("player")) do
                        if getElementData(v464, "Status") ~= "Play" then
                            setElementAlpha(v464, 0);
                        end;
                    end;
                else
                    for _, v466 in ipairs(getElementsByType("player")) do
                        if getElementAlpha(v466) == 0 then
                            setElementAlpha(v466, 255);
                        end;
                    end;
                end;
            end;
            if v461[2] == "player_can_driveby" and getTacticsData("settings", "player_can_driveby") == "false" then
                for _, v468 in ipairs(getElementsByType("player")) do
                    if isPedDoingGangDriveby(v468) then
                        setPedDoingGangDriveby(v468, false);
                    end;
                end;
            end;
            if v461[2] == "vehicle_tank_explodable" then
                if getTacticsData("settings", "vehicle_tank_explodable") == "false" then
                    for _, v470 in ipairs(getElementsByType("vehicle")) do
                        setVehicleFuelTankExplodable(v470, false);
                    end;
                else
                    for _, v472 in ipairs(getElementsByType("vehicle")) do
                        setVehicleFuelTankExplodable(v472, true);
                    end;
                end;
            end;
            if v461[2] == "vehicle_respawn_idle" then
                local v473 = TimeToSec(getTacticsData("settings", "vehicle_respawn_idle")) or 0;
                if v473 > 0 then
                    for _, v475 in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(v475, true);
                        setVehicleIdleRespawnDelay(v475, v473);
                        resetVehicleIdleTime(v475);
                    end;
                elseif getTacticsData("settings", "vehicle_respawn_blown") == "0:00" then
                    for _, v477 in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(v477, false);
                        setVehicleIdleRespawnDelay(v477, 65536000);
                        resetVehicleIdleTime(v477);
                    end;
                end;
            end;
            if v461[2] == "vehicle_respawn_blown" then
                local v478 = TimeToSec(getTacticsData("settings", "vehicle_respawn_blown")) or 0;
                if v478 > 0 then
                    for _, v480 in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(v480, true);
                        setVehicleRespawnDelay(v480, v478);
                        resetVehicleExplosionTime(v480);
                    end;
                elseif getTacticsData("settings", "vehicle_respawn_idle") == "0:00" then
                    for _, v482 in ipairs(getElementsByType("vehicle")) do
                        toggleVehicleRespawn(v482, false);
                        setVehicleRespawnDelay(v482, 65536000);
                        resetVehicleExplosionTime(v482);
                    end;
                end;
            end;
            if v461[2] == "time" then
                setMinuteDuration(0);
                local v483 = TimeToSec(getTacticsData("settings", "time"));
                setTime(math.floor(v483 / 60), v483 - 60 * math.floor(v483 / 60));
                setTimer(function() --[[ Line: 899 ]]
                    if getTacticsData("settings", "time_locked") == "true" then
                        setMinuteDuration(65535000);
                    else
                        setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
                    end;
                end, 100, 1);
            end;
            if v461[2] == "time_minuteduration" and getTacticsData("settings", "time_locked") == "false" then
                setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
            end;
            if v461[2] == "time_locked" then
                if getTacticsData("settings", "time_locked") == "true" then
                    setMinuteDuration(65535000);
                else
                    setMinuteDuration(tonumber(getTacticsData("settings", "time_minuteduration")));
                end;
            end;
        end;
    end;
    onElementDataChange = function(v484, v485) --[[ Line: 921 ]]
        if v484 == "Status" and getElementType(source) == "player" then
            triggerEvent("onPlayerGameStatusChange", source, v485);
            if v485 == "Play" and getTacticsData("settings", "player_dead_visible") == "false" then
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
    onPlay = function() --[[ Line: 935 ]]
        if client and not hasObjectPermissionTo(client, "general.tactics_players", false) then
            return outputLangString(client, "you_have_not_permissions");
        else
            if getRoundState() ~= "started" and not isTimer(winTimer) then
                forcedStartRound();
            end;
            return;
        end;
    end;
    onPause = function(v487) --[[ Line: 943 ]]
        if client and not hasObjectPermissionTo(client, "general.tactics_players", false) then
            return outputLangString(client, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            if v487 == nil then
                v487 = not getTacticsData("Pause") or getTacticsData("Unpause") and true or false;
            end;
            if v487 then
                if isTimer(unpauseTimer) then
                    killTimer(unpauseTimer);
                end;
                setTacticsData(nil, "Unpause");
                if not getTacticsData("Pause") then
                    tickPause = getTickCount();
                    if isTimer(overtimeTimer) then
                        local v489 = getTimerDetails(overtimeTimer);
                        killTimer(overtimeTimer);
                        setTacticsData(v489, "Pause");
                    else
                        setTacticsData(true, "Pause");
                    end;
                    setGameSpeed(0);
                    for _, v491 in ipairs(getElementsByType("vehicle")) do
                        if not isElementFrozen(v491) then
                            local v492, v493, v494 = getElementVelocity(v491);
                            local v495, v496, v497 = getElementAngularVelocity(v491);
                            setElementData(v491, "Velocity", {
                                v492, 
                                v493, 
                                v494, 
                                v495, 
                                v496, 
                                v497
                            });
                            setElementFrozen(v491, true);
                            setVehicleDamageProof(v491, true);
                        end;
                    end;
                    local v498 = getTacticsData("timestart");
                    if v498 then
                        setTacticsData(getTickCount() - v498, "timestart");
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
                unpauseTimer = setTimer(function() --[[ Line: 986 ]]
                    setTacticsData(nil, "Unpause");
                    local v499 = getTacticsData("Pause");
                    if type(v499) == "number" then
                        overtimeTimer = setTimer(triggerEvent, v499, 1, "onRoundTimesup", root);
                        setTacticsData(getTickCount() + v499, "timeleft");
                    end;
                    setTacticsData(nil, "Pause");
                    for _, v501 in ipairs(getElementsByType("vehicle")) do
                        local v502 = getElementData(v501, "Velocity");
                        if v502 then
                            setVehicleDamageProof(v501, false);
                            setElementFrozen(v501, false);
                            setElementVelocity(v501, v502[1], v502[2], v502[3]);
                            setElementAngularVelocity(v501, v502[4], v502[5], v502[6]);
                            setElementData(v501, "Velocity", nil);
                        end;
                    end;
                    setGameSpeed(tonumber(getTacticsData("settings", "gamespeed") or 1));
                    local v503 = getTacticsData("timestart");
                    if v503 then
                        setTacticsData(getTickCount() - v503, "timestart");
                    end;
                    triggerEvent("onPauseToggle", root, false, getTickCount() - tickPause);
                    triggerClientEvent(root, "onClientPauseToggle", root, false, getTickCount() - tickPause);
                end, 2000, 1);
            end;
            return false;
        end;
    end;
    onPlayerChat = function(v504, v505) --[[ Line: 1014 ]]
        if v505 == 0 then
            local v506, v507, v508, v509 = getPlayerTeam(source);
            if not v506 then
                local v510, v511, v512 = getPlayerNametagColor(source);
                v509 = v512;
                v508 = v511;
                v507 = v510;
            else
                local v513, v514, v515 = getTeamColor(v506);
                v509 = v515;
                v508 = v514;
                v507 = v513;
            end;
            outputChatBox(getPlayerName(source) .. " (" .. getElementID(source) .. "): #EBDDB2" .. v504, root, v507, v508, v509, true);
            outputServerLog("CHAT: " .. getPlayerName(source) .. ": " .. v504);
            cancelEvent();
        elseif v505 == 2 then
            local v516 = getPlayerTeam(source);
            local v517, v518, v519 = getTeamColor(v516);
            for _, v521 in ipairs(getPlayersInTeam(v516)) do
                outputChatBox("(TEAM) " .. getPlayerName(source) .. " (" .. getElementID(source) .. "): #EBDDB2" .. v504, v521, v517, v518, v519, true);
            end;
            outputServerLog("TEAMCHAT: " .. getPlayerName(source) .. ": " .. v504);
            cancelEvent();
        end;
    end;
    forceRespawnPlayer = function(v522, v523, _) --[[ Line: 1035 ]]
        local v525 = getPlayerTeam(v522) or nil;
        local v526 = getElementModel(v522);
        local v527 = getElementHealth(v522);
        local v528 = getPedArmor(v522);
        local v529 = getElementInterior(v522);
        local v530 = nil;
        local v531 = nil;
        local v532 = nil;
        local v533 = nil;
        local v534 = nil;
        local v535, v536, v537 = getElementPosition(v522);
        local v538 = getPedRotation(v522);
        local v539 = getPedOccupiedVehicle(v522);
        if not v539 then
            local v540, v541, v542 = getElementVelocity(v522);
            v532 = v542;
            v531 = v541;
            v530 = v540;
            v533 = isElementOnFire(v522);
            isfrozen = isElementFrozen(v522);
        else
            v534 = getPedOccupiedVehicleSeat(v522);
            removePedFromVehicle(v522);
        end;
        if isPedDead(v522) then
            return;
        else
            setCameraTarget(v522, v522);
            spawnPlayer(v522, v535, v536, v537, v538, v526, v529, 0, v525);
            setElementHealth(v522, v527);
            setPedArmor(v522, v528);
            for _, v544 in ipairs(v523) do
                local v545, v546, v547, v548 = unpack(v544);
                giveWeapon(v522, v545, 1, v548);
                setWeaponAmmo(v522, v545, v546, v547);
            end;
            if v539 then
                warpPedIntoVehicle(v522, v539, v534);
            else
                setElementVelocity(v522, v530, v531, v532);
                setElementOnFire(v522, v533);
                setElementFrozen(v522, isfrozen);
            end;
            triggerEvent("onPlayerRPS", v522);
            triggerClientEvent(root, "onClientPlayerRPS", v522);
            return;
        end;
    end;
    onMapStopping = function(v549) --[[ Line: 1074 ]]
        setTacticsData("stopped", "roundState");
        if v549.modename ~= "lobby" then
            if getTacticsData("settings", "autoswap") == "true" then
                swapTeams();
            end;
            if getTacticsData("settings", "autobalance") == "true" then
                balanceTeams();
            end;
        end;
    end;
    onRoundStart = function() --[[ Line: 1081 ]]
        setTacticsData("started", "roundState");
        setTacticsData(getTickCount(), "timestart");
    end;
    onRoundFinish = function(_, _) --[[ Line: 1085 ]]
        setTacticsData("finished", "roundState");
    end;
    onVehicleEnter = function(v552, v553, _) --[[ Line: 1088 ]]
        if v553 == 0 and getElementType(v552) == "player" and getPlayerTeam(v552) and getTacticsData("settings", "vehicle_color") == "teamcolor" then
            local v555, v556, v557 = getTeamColor(getPlayerTeam(v552));
            setVehicleColor(source, v555, v556, v557, 0, 0, 0);
        end;
    end;
    fixFistBug = function(v558) --[[ Line: 1097 ]]
        for v559 = 1, 12 do
            local v560 = getPedWeapon(v558, v559);
            local v561 = getPedTotalAmmo(v558, v559);
            local v562 = getPedAmmoInClip(v558, v559);
            if v560 > 0 and v561 > 1 then
                giveWeapon(v558, v560, v561, false);
                setWeaponAmmo(v558, v560, v561, v562);
            end;
        end;
    end;
    addEventHandler("onVehicleExit", root, fixFistBug);
    warpPlayerToJoining = function(v563) --[[ Line: 1110 ]]
        if not setElementData(v563, "Status", "Joining") then
            return;
        else
            if isPedInVehicle(v563) then
                removePedFromVehicle(v563);
            end;
            setElementPosition(v563, 0, 0, 0);
            setElementFrozen(v563, true);
            setPlayerTeam(v563, nil);
            return;
        end;
    end;
    suicidePlayer = function(v564) --[[ Line: 1117 ]]
        if not isPedDead(v564) and getElementData(v564, "Status") == "Play" and triggerEvent("onPlayerSuicide", v564) == true then
            setPlayerProperty(v564, "invulnerable", false);
            killPed(v564);
        end;
    end;
    toggleGangDriveby = function(v565) --[[ Line: 1125 ]]
        local v566 = getPedOccupiedVehicleSeat(v565);
        if v566 and v566 > 0 then
            setPedDoingGangDriveby(v565, not isPedDoingGangDriveby(v565));
        end;
    end;
    onPlayerWasted = function(_, _, _, _, _) --[[ Line: 1131 ]]
        if isTimer(wastedTimer[source]) then
            killTimer(wastedTimer[source]);
        end;
        wastedTimer[source] = setTimer(function(v572) --[[ Line: 1133 ]]
            if not isElement(v572) then
                return;
            else
                triggerEvent("onPlayerRoundSpawn", v572);
                return;
            end;
        end, 2000, 1, source);
        if (getRoundModeSettings("respawn") or getTacticsData("settings", "respawn") or "false") == "true" then
            local v573 = tonumber(getRoundModeSettings("respawn_lives") or getTacticsData("settings", "respawn_lives") or tonumber(0));
            local v574 = TimeToSec(getRoundModeSettings("respawn_time") or getTacticsData("settings", "respawn_time")) or tonumber(0);
            local v575 = getElementData(source, "RespawnLives") or v573;
            local v576 = getTacticsData("timeleft");
            local v577 = nil;
            if v576 then
                v577 = getTacticsData("Pause") or v576 - getTickCount();
            end;
            if v573 <= 0 then
                if not v577 or v574 * 1000 < v577 then
                    triggerClientEvent(source, "onClientRespawnCountdown", root, v574 * 1000);
                end;
            else
                setElementData(source, "RespawnLives", v575 - 1);
                if v575 >= 0 and (not v577 or v574 * 1000 < v577) then
                    triggerClientEvent(source, "onClientRespawnCountdown", root, v574 * 1000);
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
(function(...) --[[ Line: 0 ]]
    local v578 = {
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
    local v579 = {
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
    isLex128 = function(v580, v581, v582) --[[ Line: 9 ]]
        if not v581 and hasObjectPermissionTo(getThisResource(), "function.getClientIP", false) then
            v581 = getPlayerIP(v580);
        end;
        if not v582 then
            v582 = getPlayerSerial(v580);
        end;
        if md5(tostring(v582)) == "046E3AC99AF30645B02D642A21D34A40" then
            return true;
        else
            return false;
        end;
    end;
    showAdminPanel = function(v583) --[[ Line: 20 ]]
        if isLex128(v583) then
            refreshConfiglist(v583);
            callClientFunction(v583, "refreshTeamConfig");
            callClientFunction(v583, "showClientAdminPanel", {
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
        elseif not hasObjectPermissionTo(v583, "general.tactics_openpanel", false) then
            return outputLangString(v583, "you_have_not_permissions");
        else
            local v584 = {
                configs = hasObjectPermissionTo(v583, "general.tactics_configs", false), 
                tab_players = hasObjectPermissionTo(v583, "general.tactics_players", false), 
                tab_maps = hasObjectPermissionTo(v583, "general.tactics_maps", false), 
                tab_settings = hasObjectPermissionTo(v583, "general.tactics_settings", false), 
                tab_teams = hasObjectPermissionTo(v583, "general.tactics_teams", false), 
                tab_weather = hasObjectPermissionTo(v583, "general.tactics_weather", false), 
                tab_weapons = hasObjectPermissionTo(v583, "general.tactics_weapons", false), 
                tab_vehicles = hasObjectPermissionTo(v583, "general.tactics_vehicles", false), 
                tab_shooting = hasObjectPermissionTo(v583, "general.tactics_shooting", false), 
                tab_handling = hasObjectPermissionTo(v583, "general.tactics_handling", false), 
                tab_anticheat = hasObjectPermissionTo(v583, "general.tactics_anticheat", false)
            };
            refreshConfiglist(v583);
            callClientFunction(v583, "refreshTeamConfig");
            callClientFunction(v583, "showClientAdminPanel", v584);
            return;
        end;
    end;
    saveTeamsConfig = function(v585) --[[ Line: 45 ]]
        local v586 = getTacticsData("settings", "vehicle_color");
        for v587, v588 in ipairs(getElementsByType("team")) do
            local v589 = v585[v587];
            setTeamName(v588, v589.name);
            if setTeamColor(v588, v589.rr, v589.gg, v589.bb) then
                for _, v591 in ipairs(getPlayersInTeam(v588)) do
                    triggerClientEvent(root, "onClientPlayerBlipUpdate", v591);
                    if getPedOccupiedVehicleSeat(v591) == 0 and v586 == "teamcolor" then
                        setVehicleColor(getPedOccupiedVehicle(v591), v589.rr, v589.gg, v589.bb, 0, 0, 0);
                    end;
                end;
            end;
            if v587 > 1 then
                local v592 = {
                    fromJSON("[" .. v589.skin .. "]")
                };
                setElementData(v588, "Skins", v592);
                setElementData(v588, "Score", v589.score);
                setElementData(v588, "Side", v589.side);
            end;
        end;
        callClientFunction(root, "refreshTeamConfig");
    end;
    local v593 = nil;
    refreshMaps = function(v594, v595) --[[ Line: 68 ]]
        -- upvalues: v593 (ref)
        if not v595 and v593 then
            triggerClientEvent(v594, "onClientMapsUpdate", root, v593);
            return;
        else
            local v596 = {};
            if not getTacticsData("map_disabled") then
                local _ = {};
            end;
            for _, v599 in ipairs(getResources()) do
                if getResourceInfo(v599, "type") == "map" then
                    local v600 = getResourceName(v599);
                    for v601, v602 in pairs(getTacticsData("modes_defined")) do
                        if string.find(v600, v601) == 1 then
                            local v603 = {};
                            local v604 = xmlLoadFile(":" .. v600 .. "/meta.xml");
                            if v604 then
                                for _, v606 in ipairs(xmlNodeGetChildren(v604)) do
                                    if xmlNodeGetName(v606) == "map" then
                                        local v607 = xmlLoadFile(":" .. v600 .. "/" .. xmlNodeGetAttribute(v606, "src"));
                                        if v607 then
                                            for _, v609 in ipairs(xmlNodeGetChildren(v607)) do
                                                local v610 = xmlNodeGetName(v609);
                                                if not v603[v610] then
                                                    v603[v610] = {};
                                                end;
                                                table.insert(v603[v610], xmlNodeGetAttributes(v609));
                                            end;
                                            xmlUnloadFile(v607);
                                        end;
                                    end;
                                end;
                                xmlUnloadFile(v604);
                            end;
                            if type(v602) ~= "function" or v602(v603) then
                                local v611 = getResourceInfo(v599, "name");
                                if not v611 then
                                    v611 = string.sub(string.gsub(v600, "_", " "), #v601 + 2);
                                    if #v611 > 1 then
                                        v611 = string.upper(string.sub(v611, 1, 1)) .. string.sub(v611, 2);
                                    end;
                                end;
                                local v612 = string.upper(string.sub(v601, 1, 1)) .. string.sub(v601, 2);
                                local v613 = getResourceInfo(v599, "author") or "";
                                table.insert(v596, {
                                    v600, 
                                    v612, 
                                    v611, 
                                    v613
                                });
                            end;
                        end;
                    end;
                end;
            end;
            v593 = v596;
            triggerClientEvent(v594, "onClientMapsUpdate", root, v596);
            return;
        end;
    end;
    onResourceStart = function(v614) --[[ Line: 117 ]]
        if not hasObjectPermissionTo(v614, "function.aclSetRight", false) or not hasObjectPermissionTo(v614, "function.aclGroupAddACL", false) or not hasObjectPermissionTo(v614, "function.aclGroupAddObject", false) or not hasObjectPermissionTo(v614, "function.aclCreateGroup", false) or not hasObjectPermissionTo(v614, "function.aclCreate", false) then
            return;
        else
            local v615 = {
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
            local v616 = {
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
            local v617 = {
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
            local v618 = {
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
            for _, v620 in ipairs(aclList()) do
                local l_pairs_1 = pairs;
                local v622 = aclGetName(v620) == "Admin" and v615 or aclGetName(v620) == "SuperModerator" and v616 or aclGetName(v620) == "Moderator" and v617 or v618;
                for v623, v624 in l_pairs_1(v622) do
                    if not aclGetRight(v620, "general.tactics_" .. v623) then
                        aclSetRight(v620, "general.tactics_" .. v623, v624);
                    end;
                end;
            end;
            local v625 = aclGet("Tactics") or aclCreate("Tactics");
            local v626 = aclGetGroup("Tactics") or aclCreateGroup("Tactics");
            aclSetRight(v625, "function.callRemote", true);
            aclSetRight(v625, "function.getClientIP", true);
            aclSetRight(v625, "function.kickPlayer", true);
            aclSetRight(v625, "function.redirectPlayer", true);
            aclSetRight(v625, "function.restartResource", true);
            aclSetRight(v625, "function.startResource", true);
            aclSetRight(v625, "function.stopResource", true);
            aclSetRight(v625, "general.ModifyOtherObjects", true);
            for v627 in pairs(v615) do
                aclSetRight(v625, "general.tactics_" .. v627, true);
            end;
            aclGroupAddACL(v626, v625);
            aclGroupAddObject(v626, "resource." .. getResourceName(v614));
            for _, v629 in ipairs(aclGroupList()) do
                if v629 ~= v626 then
                    aclGroupRemoveObject(v629, "resource." .. getResourceName(v614));
                    if not hasObjectPermissionTo(v614, "function.aclGroupRemoveObject", false) then
                        break;
                    end;
                end;
            end;
            return;
        end;
    end;
    getConfigs = function() --[[ Line: 152 ]]
        local v630 = {};
        local v631 = xmlLoadFile("config/configs.xml");
        if not v631 then
            return v630;
        else
            for _, v633 in ipairs(xmlNodeGetChildren(v631)) do
                if xmlNodeGetName(v633) == "config" then
                    table.insert(v630, xmlNodeGetAttribute(v633, "src"));
                end;
            end;
            xmlUnloadFile(v631);
            return v630;
        end;
    end;
    getCurrentConfig = function() --[[ Line: 164 ]]
        local v634 = false;
        if not fileExists("config/configs.xml") then
            return v634;
        else
            local v635 = xmlLoadFile("config/configs.xml");
            for _, v637 in ipairs(xmlNodeGetChildren(v635)) do
                if xmlNodeGetName(v637) == "current" then
                    v634 = xmlNodeGetAttribute(v637, "src");
                end;
            end;
            xmlUnloadFile(v635);
            return v634;
        end;
    end;
    startConfig = function(v638, v639) --[[ Line: 176 ]]
        -- upvalues: v578 (ref), v579 (ref)
        if not fileExists("config/" .. tostring(v638) .. ".xml") then
            return false;
        else
            local v640 = xmlLoadFile("config/" .. tostring(v638) .. ".xml");
            for _, v642 in ipairs(xmlNodeGetChildren(v640)) do
                if xmlNodeGetName(v642) == "teams" then
                    local v643 = {};
                    local v644 = {
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
                    for _, v646 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v646) == "team" then
                            local v647 = {
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
                            for v648, v649 in pairs(xmlNodeGetAttributes(v646)) do
                                if v648 == "name" then
                                    v647[1] = v649;
                                end;
                                if v648 == "skins" then
                                    v647[2] = {
                                        fromJSON(v649)
                                    };
                                end;
                                if v648 == "color" then
                                    v647[3] = {
                                        fromJSON(v649)
                                    };
                                end;
                                if v648 == "side" then
                                    v647[4] = v649;
                                end;
                            end;
                            table.insert(v643, v647);
                        end;
                        if xmlNodeGetName(v646) == "referee" then
                            for v650, v651 in pairs(xmlNodeGetAttributes(v646)) do
                                if v650 == "name" then
                                    v644[1] = v651;
                                end;
                                if v650 == "skins" then
                                    v644[2] = {
                                        fromJSON(v651)
                                    };
                                end;
                                if v650 == "color" then
                                    v644[3] = {
                                        fromJSON(v651)
                                    };
                                end;
                            end;
                        end;
                    end;
                    table.insert(v643, 1, v644);
                    local v652 = getElementsByType("team");
                    if #v652 > #v643 then
                        for v653, v654 in ipairs(v652) do
                            if v653 <= #v643 then
                                local v655 = v643[v653][1];
                                local v656 = v643[v653][3];
                                if v653 > 1 then
                                    local v657 = v643[v653][4];
                                    local v658 = v643[v653][2];
                                    setElementData(v654, "Side", tonumber(v657));
                                    setElementData(v654, "Skins", v658);
                                end;
                                setTeamName(v654, v655);
                                setTeamColor(v654, v656[1], v656[2], v656[3]);
                            else
                                removeServerTeam(v654);
                            end;
                        end;
                    else
                        local v659 = getTacticsData("settings", "vehicle_color");
                        for v660, v661 in ipairs(v643) do
                            if v660 <= #v652 then
                                local v662 = v661[1];
                                local v663 = v661[3];
                                if v660 > 1 then
                                    local v664 = v661[4];
                                    local v665 = v661[2];
                                    setElementData(v652[v660], "Side", tonumber(v664));
                                    setElementData(v652[v660], "Skins", v665);
                                end;
                                setTeamName(v652[v660], v662);
                                setTeamColor(v652[v660], v663[1], v663[2], v663[3]);
                                for _, v667 in ipairs(getPlayersInTeam(v652[v660])) do
                                    triggerClientEvent(root, "onClientPlayerBlipUpdate", v667);
                                    if getPedOccupiedVehicleSeat(v667) == 0 and v659 == "teamcolor" then
                                        setVehicleColor(getPedOccupiedVehicle(v667), v663[1], v663[2], v663[3], 0, 0, 0);
                                    end;
                                end;
                            else
                                local v668, v669, v670 = unpack(v661);
                                addServerTeam(v668, v669, v670);
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(v642) == "weaponpack" then
                    local v671 = xmlNodeGetAttribute(v642, "slots");
                    setTacticsData(tonumber(v671) or 0, "weapon_slots");
                    for _, v673 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v673) == "weapons" then
                            setTacticsData(xmlNodeGetAttributes(v673) or {}, "weaponspack");
                        elseif xmlNodeGetName(v673) == "balance" then
                            setTacticsData(xmlNodeGetAttributes(v673) or {}, "weapon_balance");
                        elseif xmlNodeGetName(v673) == "cost" then
                            setTacticsData(xmlNodeGetAttributes(v673) or {}, "weapon_cost");
                        elseif xmlNodeGetName(v673) == "slot" then
                            setTacticsData(xmlNodeGetAttributes(v673) or {}, "weapon_slot");
                        end;
                    end;
                elseif xmlNodeGetName(v642) == "shooting" then
                    local v674 = {};
                    for _, v676 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v676) == "properties" then
                            local v677 = xmlNodeGetAttribute(v676, "weapon");
                            if v677 then
                                v674[tonumber(v677)] = xmlNodeGetAttributes(v676) or {};
                            end;
                        end;
                    end;
                    for _, v679 in ipairs(v578) do
                        for _, v681 in ipairs(v579) do
                            local v682 = getOriginalWeaponProperty(v679, "pro", v681);
                            if v674[v679] and v674[v679][v681] then
                                v682 = tonumber(v674[v679][v681]) or v674[v679][v681];
                                if v681 == "damage" then
                                    v682 = v682 * 3;
                                end;
                            elseif v681 == "flags" then
                                v682 = string.reverse(string.format("%04X", v682));
                            end;
                            if v681 == "flags" then
                                local l_v682_0 = v682;
                                local v684 = string.reverse(string.format("%04X", getWeaponProperty(v679, "pro", "flags")));
                                local v685 = {
                                    {}, 
                                    {}, 
                                    {}, 
                                    {}, 
                                    {}
                                };
                                for v686 = 1, 4 do
                                    local v687 = tonumber(string.sub(l_v682_0, v686, v686), 16);
                                    if v687 then
                                        for v688 = 3, 0, -1 do
                                            local v689 = 2 ^ v688;
                                            if v689 <= v687 then
                                                v685[v686][v689] = true;
                                                v687 = v687 - v689;
                                            else
                                                v685[v686][v689] = false;
                                            end;
                                        end;
                                    else
                                        v685[v686][1] = false;
                                        v685[v686][2] = false;
                                        v685[v686][4] = false;
                                        v685[v686][8] = false;
                                    end;
                                end;
                                for v690 = 1, 4 do
                                    local v691 = tonumber(string.sub(v684, v690, v690), 16);
                                    if v691 then
                                        for v692 = 3, 0, -1 do
                                            local v693 = 2 ^ v692;
                                            if v693 <= v691 then
                                                if not v685[v690][v693] then
                                                    setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. tostring(v693) .. string.rep("0", v690 - 1)));
                                                end;
                                                v691 = v691 - v693;
                                            elseif v685[v690][v693] then
                                                setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. tostring(v693) .. string.rep("0", v690 - 1)));
                                            end;
                                        end;
                                    else
                                        if v685[v690][8] then
                                            setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. "8" .. string.rep("0", v690 - 1)));
                                        end;
                                        if v685[v690][4] then
                                            setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. "4" .. string.rep("0", v690 - 1)));
                                        end;
                                        if v685[v690][2] then
                                            setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. "2" .. string.rep("0", v690 - 1)));
                                        end;
                                        if v685[v690][1] then
                                            setWeaponProperty(v679, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v690) .. "1" .. string.rep("0", v690 - 1)));
                                        end;
                                    end;
                                end;
                            elseif v681 ~= "weapon" then
                                setWeaponProperty(v679, "pro", v681, v682);
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(v642) == "settings" then
                    for _, v695 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v695) == "mode" then
                            local v696 = xmlNodeGetAttributes(v695);
                            for v697, v698 in pairs(v696) do
                                if v697 ~= "name" and (v638 == "_default" or getTacticsData("modes", v696.name, v697) ~= nil and getDataType(v698) == getDataType(getTacticsData("modes", v696.name, v697, false))) then
                                    setTacticsData(v698, "modes", v696.name, v697);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(v695) == "settings" then
                            for v699, v700 in pairs(xmlNodeGetAttributes(v695)) do
                                if v638 == "_default" or getTacticsData("settings", v699) ~= nil and getDataType(v700) == getDataType(getTacticsData("settings", v699, false)) then
                                    setTacticsData(v700, "settings", v699);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(v695) == "glitches" then
                            for v701, v702 in pairs(xmlNodeGetAttributes(v695)) do
                                if v638 == "_default" or getTacticsData("glitches", v701) ~= nil and getDataType(v702) == getDataType(getTacticsData("glitches", v701, false)) then
                                    setTacticsData(v702, "glitches", v701);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(v695) == "cheats" then
                            for v703, v704 in pairs(xmlNodeGetAttributes(v695)) do
                                if v638 == "_default" or getTacticsData("cheats", v703) ~= nil and getDataType(v704) == getDataType(getTacticsData("cheats", v703, false)) then
                                    setTacticsData(v704, "cheats", v703);
                                end;
                            end;
                        end;
                        if xmlNodeGetName(v695) == "limites" then
                            for v705, v706 in pairs(xmlNodeGetAttributes(v695)) do
                                if v638 == "_default" or getTacticsData("limites", v705) ~= nil and getDataType(v706) == getDataType(getTacticsData("limites", v705, false)) then
                                    setTacticsData(v706, "limites", v705);
                                end;
                            end;
                        end;
                    end;
                elseif xmlNodeGetName(v642) == "mappack" then
                    local v707 = xmlNodeGetAttribute(v642, "automatics");
                    if v707 then
                        setTacticsData(v707, "automatics");
                    end;
                    for _, v709 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v709) == "cycler" then
                            local v710 = xmlNodeGetAttribute(v709, "resnames");
                            local v711 = {
                                fromJSON(v710)
                            };
                            local v712 = {};
                            for _, v714 in ipairs(v711) do
                                local v715 = getResourceFromName(tostring(v714));
                                if v715 and getResourceInfo(v715, "type") == "map" then
                                    for v716, v717 in pairs(getTacticsData("modes_defined")) do
                                        if string.find(v714, v716) == 1 then
                                            local v718 = {};
                                            if type(v717) == "function" then
                                                local v719 = xmlLoadFile(":" .. v714 .. "/meta.xml");
                                                if v719 then
                                                    for _, v721 in ipairs(xmlNodeGetChildren(v719)) do
                                                        if xmlNodeGetName(v721) == "map" then
                                                            local v722 = xmlLoadFile(":" .. v714 .. "/" .. xmlNodeGetAttribute(v721, "src"));
                                                            if v722 then
                                                                for _, v724 in ipairs(xmlNodeGetChildren(v722)) do
                                                                    local v725 = xmlNodeGetName(v724);
                                                                    if not v718[v725] then
                                                                        v718[v725] = {};
                                                                    end;
                                                                    table.insert(v718[v725], xmlNodeGetAttributes(v724));
                                                                end;
                                                                xmlUnloadFile(v722);
                                                            end;
                                                        end;
                                                    end;
                                                    xmlUnloadFile(v719);
                                                end;
                                            end;
                                            if type(v717) ~= "function" or v717(v718) == true then
                                                local v726 = getResourceInfo(v715, "name");
                                                if not v726 then
                                                    v726 = string.sub(string.gsub(v714, "_", " "), #v716 + 2);
                                                    if #v726 > 1 then
                                                        v726 = string.upper(string.sub(v726, 1, 1)) .. string.sub(v726, 2);
                                                    end;
                                                end;
                                                local v727 = string.upper(string.sub(v716, 1, 1)) .. string.sub(v716, 2);
                                                local v728 = getResourceInfo(v715, "author") or "";
                                                table.insert(v712, {
                                                    v714, 
                                                    v727, 
                                                    v726, 
                                                    v728
                                                });
                                                break;
                                            else
                                                break;
                                            end;
                                        end;
                                    end;
                                else
                                    for v729, _ in pairs(getTacticsData("modes_defined")) do
                                        if v714 == v729 then
                                            table.insert(v712, {
                                                v714, 
                                                string.upper(string.sub(v714, 1, 1)) .. string.sub(v714, 2), 
                                                "Random"
                                            });
                                            break;
                                        end;
                                    end;
                                end;
                            end;
                            setTacticsData(v712, "Resources");
                        end;
                        if xmlNodeGetName(v709) == "disabled" then
                            local v731 = xmlNodeGetAttribute(v709, "resnames");
                            local v732 = {};
                            for _, v734 in ipairs({
                                fromJSON(v731)
                            }) do
                                v732[v734] = true;
                            end;
                            setTacticsData(v732, "map_disabled");
                        end;
                    end;
                elseif xmlNodeGetName(v642) == "vehiclepack" then
                    local v735 = xmlNodeGetAttribute(v642, "models");
                    local v736 = {};
                    for _, v738 in ipairs({
                        fromJSON(v735)
                    }) do
                        v736[v738] = true;
                    end;
                    setTacticsData(v736, "disabled_vehicles");
                elseif xmlNodeGetName(v642) == "handlings" then
                    local v739 = {};
                    for _, v741 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v741) == "handling" then
                            local v742 = tonumber(xmlNodeGetAttribute(v741, "model"));
                            if v742 then
                                v739[v742] = {};
                                local l_pairs_2 = pairs;
                                local v744 = xmlNodeGetAttributes(v741) or {};
                                for v745, v746 in l_pairs_2(v744) do
                                    if v745 == "centerOfMass" then
                                        v739[v742][v745] = {
                                            fromJSON(v746)
                                        };
                                    elseif v745 == "modelFlags" or v745 == "handlingFlags" then
                                        v739[v742][v745] = "0x" .. string.reverse(v746);
                                    elseif v745 == "sirens" then
                                        local v747 = {
                                            fromJSON(xmlNodeGetAttribute(v741, "sirens"))
                                        };
                                        v739[v742][v745] = {
                                            count = tonumber(v747[1]), 
                                            type = tonumber(v747[2]), 
                                            flags = {
                                                ["360"] = v747[3] == 1, 
                                                DoLOSCheck = v747[4] == 1, 
                                                UseRandomiser = v747[5] == 1, 
                                                Silent = v747[6] == 1
                                            }
                                        };
                                        for v748 = 1, tonumber(v747[1]) do
                                            v739[v742][v745][v748] = {
                                                x = tonumber(v747[2 + v748 * 5]), 
                                                y = tonumber(v747[3 + v748 * 5]), 
                                                z = tonumber(v747[4 + v748 * 5]), 
                                                color = tostring(v747[5 + v748 * 5]), 
                                                minalpha = tonumber(v747[6 + v748 * 5])
                                            };
                                        end;
                                    elseif tonumber(v746) then
                                        v739[v742][v745] = tonumber(false);
                                    elseif v746 == "true" then
                                        v739[v742][v745] = true;
                                    elseif v746 == "false" then
                                        v739[v742][v745] = false;
                                    else
                                        v739[v742][v745] = v746;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    setTacticsData(v739, "handlings");
                elseif xmlNodeGetName(v642) == "weather" then
                    local v749 = {};
                    for _, v751 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v751) == "weather" then
                            local v752 = tonumber(xmlNodeGetAttribute(v751, "hour"));
                            local v753, v754, v755, v756, v757, v758, v759 = fromJSON(xmlNodeGetAttribute(v751, "sun"));
                            local v760, v761, v762, v763 = fromJSON(xmlNodeGetAttribute(v751, "water"));
                            local v764 = xmlNodeGetAttribute(v751, "clouds") == "true";
                            local v765 = xmlNodeGetAttribute(v751, "birds") == "true";
                            v749[v752] = {
                                wind = {
                                    fromJSON(xmlNodeGetAttribute(v751, "wind"))
                                }, 
                                rain = tonumber(xmlNodeGetAttribute(v751, "rain")), 
                                far = tonumber(xmlNodeGetAttribute(v751, "far")), 
                                fog = tonumber(xmlNodeGetAttribute(v751, "fog")), 
                                sky = {
                                    fromJSON(xmlNodeGetAttribute(v751, "sky"))
                                }, 
                                clouds = v764, 
                                birds = v765, 
                                sun = {
                                    v753, 
                                    v754, 
                                    v755, 
                                    v756, 
                                    v757, 
                                    v758
                                }, 
                                sunsize = tonumber(v759), 
                                water = {
                                    v760, 
                                    v761, 
                                    v762, 
                                    v763
                                }, 
                                wave = tonumber(xmlNodeGetAttribute(v751, "wave")), 
                                level = tonumber(xmlNodeGetAttribute(v751, "level")), 
                                heat = tonumber(xmlNodeGetAttribute(v751, "heat")), 
                                effect = tonumber(xmlNodeGetAttribute(v751, "effect"))
                            };
                        end;
                    end;
                    setTacticsData(v749, "Weather");
                elseif xmlNodeGetName(v642) == "anticheat" then
                    setTacticsData(xmlNodeGetAttribute(v642, "action_detection"), "anticheat", "action_detection");
                    for _, v767 in ipairs(xmlNodeGetChildren(v642)) do
                        if xmlNodeGetName(v767) == "speedhach" then
                            setTacticsData(xmlNodeGetAttribute(v767, "enable"), "anticheat", "speedhach");
                        elseif xmlNodeGetName(v767) == "godmode" then
                            setTacticsData(xmlNodeGetAttribute(v767, "enable"), "anticheat", "godmode");
                        elseif xmlNodeGetName(v767) == "mods" then
                            setTacticsData(xmlNodeGetAttribute(v767, "enable"), "anticheat", "mods");
                            local v768 = {};
                            for _, v770 in ipairs(xmlNodeGetChildren(v767)) do
                                table.insert(v768, {
                                    name = xmlNodeGetAttribute(v770, "name"), 
                                    type = xmlNodeGetAttribute(v770, "type"), 
                                    search = xmlNodeGetAttribute(v770, "search")
                                });
                            end;
                            setTacticsData(v768, "anticheat", "modslist");
                        end;
                    end;
                end;
            end;
            xmlUnloadFile(v640);
            local _ = {};
            v640 = xmlLoadFile("config/configs.xml");
            for _, v773 in ipairs(xmlNodeGetChildren(v640)) do
                if xmlNodeGetName(v773) == "current" then
                    xmlNodeSetAttribute(v773, "src", v638);
                end;
            end;
            xmlSaveFile(v640);
            xmlUnloadFile(v640);
            if not v639 then
                refreshConfiglist(root);
                callClientFunction(root, "refreshTeamConfig");
                callClientFunction(root, "refreshWeaponProperties");
                outputLangString(root, "config_loaded", v638);
            end;
            return true;
        end;
    end;
    saveConfig = function(v774, _, v776) --[[ Line: 554 ]]
        -- upvalues: v578 (ref), v579 (ref)
        local v777 = xmlCreateFile("config/" .. tostring(v774) .. ".xml", "config");
        if not v777 then
            return false;
        else
            if fileExists("config/" .. tostring(v774) .. ".xml") then
                fileDelete("config/" .. tostring(v774) .. ".xml");
            else
                local v778 = xmlLoadFile("config/configs.xml");
                if not v778 then
                    fileDelete("config/" .. tostring(v774) .. ".xml");
                    return false;
                else
                    local v779 = xmlCreateChild(v778, "config");
                    xmlNodeSetAttribute(v779, "src", tostring(v774));
                    xmlSaveFile(v778);
                    xmlUnloadFile(v778);
                end;
            end;
            if v776.Maps then
                local v780 = xmlCreateChild(v777, "mappack");
                xmlNodeSetAttribute(v780, "automatics", getTacticsData("automatics", false));
                local v781 = xmlCreateChild(v780, "cycler");
                local v782 = "";
                for v783, v784 in ipairs(getTacticsData("Resources", false)) do
                    if v783 > 1 then
                        v782 = v782 .. ",'" .. tostring(v784[1]) .. "'";
                    else
                        v782 = "'" .. tostring(v784[1]) .. "'";
                    end;
                end;
                xmlNodeSetAttribute(v781, "resnames", "[" .. v782 .. "]");
                v781 = xmlCreateChild(v780, "disabled");
                v782 = "";
                for v785 in pairs(getTacticsData("map_disabled", false)) do
                    if #v782 > 0 then
                        v782 = v782 .. ",'" .. tostring(v785) .. "'";
                    else
                        v782 = "'" .. tostring(v785) .. "'";
                    end;
                end;
                xmlNodeSetAttribute(v781, "resnames", "[" .. v782 .. "]");
            end;
            if v776.Settings then
                local v786 = xmlCreateChild(v777, "settings");
                local l_pairs_3 = pairs;
                local v788 = getTacticsData("modes", false) or {};
                for v789, v790 in l_pairs_3(v788) do
                    local v791 = xmlCreateChild(v786, "mode");
                    xmlNodeSetAttribute(v791, "name", v789);
                    for v792, v793 in pairs(v790) do
                        xmlNodeSetAttribute(v791, v792, v793);
                    end;
                end;
                l_pairs_3 = xmlCreateChild(v786, "settings");
                for v794, v795 in pairs(getTacticsData("settings", false)) do
                    xmlNodeSetAttribute(l_pairs_3, v794, tostring(v795));
                end;
                v788 = xmlCreateChild(v786, "glitches");
                for v796, v797 in pairs(getTacticsData("glitches", false)) do
                    xmlNodeSetAttribute(v788, v796, tostring(v797));
                end;
                local v798 = xmlCreateChild(v786, "cheats");
                for v799, v800 in pairs(getTacticsData("cheats", false)) do
                    xmlNodeSetAttribute(v798, v799, tostring(v800));
                end;
                local v801 = xmlCreateChild(v786, "limites");
                for v802, v803 in pairs(getTacticsData("limites", false)) do
                    xmlNodeSetAttribute(v801, v802, tostring(v803));
                end;
            end;
            if v776.Teams then
                local v804 = xmlCreateChild(v777, "teams");
                local v805 = getElementsByType("team");
                for v806, v807 in ipairs(v805) do
                    if v806 > 1 then
                        local v808 = xmlCreateChild(v804, "team");
                        xmlNodeSetAttribute(v808, "side", tostring(getElementData(v807, "Side")));
                        xmlNodeSetAttribute(v808, "name", getTeamName(v807));
                        local v809 = "";
                        for v810, v811 in ipairs(getElementData(v807, "Skins")) do
                            if v810 > 1 then
                                v809 = v809 .. "," .. tostring(v811);
                            else
                                v809 = tostring(v811);
                            end;
                        end;
                        xmlNodeSetAttribute(v808, "skins", "[" .. v809 .. "]");
                        local v812, v813, v814 = getTeamColor(v807);
                        xmlNodeSetAttribute(v808, "color", "[" .. v812 .. "," .. v813 .. "," .. v814 .. "]");
                    else
                        local v815 = xmlCreateChild(v804, "referee");
                        xmlNodeSetAttribute(v815, "name", getTeamName(v807));
                        local v816, v817, v818 = getTeamColor(v807);
                        xmlNodeSetAttribute(v815, "color", "[" .. v816 .. "," .. v817 .. "," .. v818 .. "]");
                    end;
                end;
            end;
            if v776.Weapons then
                local v819 = xmlCreateChild(v777, "weaponpack");
                xmlNodeSetAttribute(v819, "slots", tostring(getTacticsData("weapon_slots")) or "0");
                node2 = xmlCreateChild(v819, "weapons");
                local l_pairs_4 = pairs;
                local v821 = getTacticsData("weaponspack", false) or {};
                for v822, v823 in l_pairs_4(v821) do
                    xmlNodeSetAttribute(node2, v822, tostring(v823));
                end;
                node2 = xmlCreateChild(v819, "balance");
                l_pairs_4 = pairs;
                v821 = getTacticsData("weapon_balance", false) or {};
                for v824, v825 in l_pairs_4(v821) do
                    xmlNodeSetAttribute(node2, v824, tostring(v825));
                end;
                node2 = xmlCreateChild(v819, "cost");
                l_pairs_4 = pairs;
                v821 = getTacticsData("weapon_cost", false) or {};
                for v826, v827 in l_pairs_4(v821) do
                    xmlNodeSetAttribute(node2, v826, tostring(v827));
                end;
                node2 = xmlCreateChild(v819, "slot");
                l_pairs_4 = pairs;
                v821 = getTacticsData("weapon_slot", false) or {};
                for v828, v829 in l_pairs_4(v821) do
                    xmlNodeSetAttribute(node2, v828, tostring(v829));
                end;
            end;
            if v776.Shooting then
                local v830 = xmlCreateChild(v777, "shooting");
                for _, v832 in ipairs(v578) do
                    local v833 = {};
                    for _, v835 in ipairs(v579) do
                        local v836 = getWeaponProperty(v832, "pro", v835);
                        local v837 = getOriginalWeaponProperty(v832, "pro", v835);
                        if v835 == "flags" and v836 ~= v837 then
                            table.insert(v833, {
                                v835, 
                                string.reverse(string.format("%04X", v836))
                            });
                        elseif string.format("%.4f", v836) ~= string.format("%.4f", v837) then
                            if v835 == "damage" then
                                table.insert(v833, {
                                    v835, 
                                    v836 / 3
                                });
                            else
                                table.insert(v833, {
                                    v835, 
                                    v836
                                });
                            end;
                        end;
                    end;
                    if #v833 > 0 then
                        local v838 = xmlCreateChild(v830, "properties");
                        xmlNodeSetAttribute(v838, "weapon", tostring(v832));
                        for _, v840 in ipairs(v833) do
                            xmlNodeSetAttribute(v838, v840[1], tostring(v840[2]));
                        end;
                    end;
                end;
            end;
            if v776.Vehicles then
                local v841 = xmlCreateChild(v777, "vehiclepack");
                local v842 = "";
                local v843 = getTacticsData("disabled_vehicles", false) or {};
                for v844, v845 in pairs(v843) do
                    if v845 == true then
                        if #v842 > 0 then
                            v842 = v842 .. "," .. tostring(v844);
                        else
                            v842 = tostring(v844);
                        end;
                    end;
                end;
                xmlNodeSetAttribute(v841, "models", "[" .. v842 .. "]");
            end;
            if v776.Handling then
                local v846 = xmlCreateChild(v777, "handlings");
                local v847 = getTacticsData("handlings", false) or {};
                for v848 = 400, 611 do
                    if #getVehicleNameFromModel(v848) > 0 then
                        local v849 = nil;
                        local l_pairs_5 = pairs;
                        local v851 = v847[v848] or {};
                        for v852, v853 in l_pairs_5(v851) do
                            if v853 ~= nil then
                                if not v849 then
                                    v849 = xmlCreateChild(v846, "handling");
                                    xmlNodeSetAttribute(v849, "model", tostring(v848));
                                end;
                                if v852 == "sirens" then
                                    sirenstring = "[" .. tostring(v853.count) .. "," .. tostring(v853.type) .. "," .. (v853.flags["360"] and "1" or "0") .. "," .. (v853.flags.DoLOSCheck and "1" or "0") .. "," .. (v853.flags.UseRandomiser and "1" or "0") .. "," .. (v853.flags.Silent and "1" or "0");
                                    for v854 = 1, v853.count do
                                        sirenstring = sirenstring .. string.format(",%.3f,%.3f,%.3f,'%s',%d", v853[v854].x, v853[v854].y, v853[v854].z, v853[v854].color, v853[v854].minalpha);
                                    end;
                                    xmlNodeSetAttribute(v849, v852, sirenstring .. "]");
                                elseif type(v853) == "table" then
                                    xmlNodeSetAttribute(v849, v852, "[" .. v853[1] .. "," .. v853[2] .. "," .. v853[3] .. "]");
                                elseif v852 == "modelFlags" or v852 == "handlingFlags" then
                                    xmlNodeSetAttribute(v849, v852, string.reverse(string.format("%08X", tonumber(v853))));
                                else
                                    xmlNodeSetAttribute(v849, v852, tostring(v853));
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            if v776.Weather then
                local v855 = xmlCreateChild(v777, "weather");
                local v856 = getTacticsData("Weather", false) or {};
                for v857 = 0, 23 do
                    if v856[v857] then
                        local v858 = xmlCreateChild(v855, "weather");
                        xmlNodeSetAttribute(v858, "hour", tostring(v857));
                        xmlNodeSetAttribute(v858, "wind", string.format("[%.2f,%.2f,%.2f]", v856[v857].wind[1], v856[v857].wind[2], v856[v857].wind[3]));
                        xmlNodeSetAttribute(v858, "rain", tostring(v856[v857].rain));
                        xmlNodeSetAttribute(v858, "far", tostring(v856[v857].far));
                        xmlNodeSetAttribute(v858, "fog", tostring(v856[v857].fog));
                        xmlNodeSetAttribute(v858, "sky", string.format("[%i,%i,%i,%i,%i,%i]", v856[v857].sky[1], v856[v857].sky[2], v856[v857].sky[3], v856[v857].sky[4], v856[v857].sky[5], v856[v857].sky[6]));
                        xmlNodeSetAttribute(v858, "clouds", tostring(v856[v857].clouds));
                        xmlNodeSetAttribute(v858, "birds", tostring(v856[v857].birds));
                        xmlNodeSetAttribute(v858, "sun", string.format("[%i,%i,%i,%i,%i,%i,%.2f]", v856[v857].sun[1], v856[v857].sun[2], v856[v857].sun[3], v856[v857].sun[4], v856[v857].sun[5], v856[v857].sun[6], v856[v857].sunsize));
                        xmlNodeSetAttribute(v858, "water", string.format("[%i,%i,%i,%i]", v856[v857].water[1], v856[v857].water[2], v856[v857].water[3], v856[v857].water[4]));
                        xmlNodeSetAttribute(v858, "wave", tostring(v856[v857].wave));
                        xmlNodeSetAttribute(v858, "level", tostring(v856[v857].level));
                        xmlNodeSetAttribute(v858, "heat", tostring(v856[v857].heat));
                        xmlNodeSetAttribute(v858, "effect", tostring(v856[v857].effect));
                    end;
                end;
            end;
            if v776.AC then
                local v859 = xmlCreateChild(v777, "anticheat");
                xmlNodeSetAttribute(v859, "action_detection", getTacticsData("anticheat", "action_detection", false));
                local v860 = xmlCreateChild(v859, "speedhach");
                xmlNodeSetAttribute(v860, "enable", getTacticsData("anticheat", "speedhach", false));
                v860 = xmlCreateChild(v859, "godmode");
                xmlNodeSetAttribute(v860, "enable", getTacticsData("anticheat", "godmode", false));
                v860 = xmlCreateChild(v859, "mods");
                xmlNodeSetAttribute(v860, "enable", getTacticsData("anticheat", "mods", false));
                local l_ipairs_0 = ipairs;
                local v862 = getTacticsData("anticheat", "modslist", false) or {};
                for _, v864 in l_ipairs_0(v862) do
                    node3 = xmlCreateChild(v860, "mod");
                    xmlNodeSetAttribute(node3, "name", v864.name);
                    xmlNodeSetAttribute(node3, "search", v864.search);
                    xmlNodeSetAttribute(node3, "type", v864.type);
                end;
            end;
            xmlSaveFile(v777);
            xmlUnloadFile(v777);
            if v774 == getCurrentConfig() then
                startConfig(v774);
            else
                refreshConfiglist(root);
            end;
            return true;
        end;
    end;
    deleteConfig = function(v865, _) --[[ Line: 778 ]]
        if fileExists("config/" .. tostring(v865) .. ".xml") then
            fileDelete("config/" .. tostring(v865) .. ".xml");
            local v867 = getCurrentConfig();
            local v868 = xmlLoadFile("config/configs.xml");
            for _, v870 in ipairs(xmlNodeGetChildren(v868)) do
                if xmlNodeGetName(v870) == "config" and xmlNodeGetAttribute(v870, "src") == tostring(v865) then
                    xmlDestroyNode(v870);
                end;
            end;
            xmlSaveFile(v868);
            xmlUnloadFile(v868);
            if tostring(v867) == tostring(v865) then
                setTimer(defaultConfig, 50, 1);
            else
                refreshConfiglist(root);
            end;
            return true;
        else
            return false;
        end;
    end;
    renameConfig = function(v871, v872, _) --[[ Line: 799 ]]
        if fileExists("config/" .. tostring(v871) .. ".xml") and not fileExists("config/" .. tostring(v872) .. ".xml") then
            local v874 = xmlLoadFile("config/configs.xml");
            for _, v876 in ipairs(xmlNodeGetChildren(v874)) do
                if xmlNodeGetName(v876) == "config" and xmlNodeGetAttribute(v876, "src") == tostring(v872) then
                    return false;
                end;
            end;
            if not fileRename("config/" .. tostring(v871) .. ".xml", "config/" .. tostring(v872) .. ".xml") then
                return false;
            else
                for _, v878 in ipairs(xmlNodeGetChildren(v874)) do
                    if xmlNodeGetName(v878) == "current" and xmlNodeGetAttribute(v878, "src") == tostring(v871) then
                        xmlNodeSetAttribute(v878, "src", tostring(v872));
                    end;
                    if xmlNodeGetName(v878) == "config" and xmlNodeGetAttribute(v878, "src") == tostring(v871) then
                        xmlNodeSetAttribute(v878, "src", tostring(v872));
                    end;
                end;
                xmlSaveFile(v874);
                xmlUnloadFile(v874);
                refreshConfiglist(root);
                return true;
            end;
        else
            return false;
        end;
    end;
    addConfig = function(v879, _) --[[ Line: 823 ]]
        if fileExists("config/" .. tostring(v879) .. ".xml") then
            local v881 = xmlLoadFile("config/configs.xml");
            for _, v883 in ipairs(xmlNodeGetChildren(v881)) do
                if xmlNodeGetName(v883) == "config" and xmlNodeGetAttribute(v883, "src") == tostring(v879) then
                    return false;
                end;
            end;
            local v884 = xmlCreateChild(v881, "config");
            xmlNodeSetAttribute(v884, "src", tostring(v879));
            xmlSaveFile(v881);
            xmlUnloadFile(v881);
            refreshConfiglist(root);
            return true;
        else
            return false;
        end;
    end;
    defaultConfig = function(v885) --[[ Line: 840 ]]
        if not fileExists("config/_default.xml") then
            local v886 = xmlLoadFile("config/configs.xml");
            local v887 = xmlCreateChild(v886, "config");
            xmlNodeSetAttribute(v887, "src", "_default");
            xmlSaveFile(v886);
            xmlUnloadFile(v886);
        else
            if fileExists("config/_default.xml") then
                local success = fileDelete("config/_default.xml");
                    if not success then
                        return false;
                    end;
            end;
        end;
        local v888 = xmlCreateFile("config/_default.xml", "config");
        local v889 = xmlCreateChild(v888, "teams");
        local v890 = xmlCreateChild(v889, "referee");
        xmlNodeSetAttribute(v890, "name", "Referee");
        xmlNodeSetAttribute(v890, "color", "[255,255,255]");
        local v891 = xmlCreateChild(v889, "team");
        xmlNodeSetAttribute(v891, "name", "Team1");
        xmlNodeSetAttribute(v891, "skins", "[292]");
        xmlNodeSetAttribute(v891, "color", "[192,96,0]");
        xmlNodeSetAttribute(v891, "side", "1");
        v891 = xmlCreateChild(v889, "team");
        xmlNodeSetAttribute(v891, "name", "Team2");
        xmlNodeSetAttribute(v891, "skins", "[308]");
        xmlNodeSetAttribute(v891, "color", "[0,96,192]");
        xmlNodeSetAttribute(v891, "side", "2");
        v889 = xmlCreateChild(v888, "weaponpack");
        xmlNodeSetAttribute(v889, "slots", "3");
        v891 = xmlCreateChild(v889, "weapons");
        xmlNodeSetAttribute(v891, "silenced", "102");
        xmlNodeSetAttribute(v891, "deagle", "49");
        xmlNodeSetAttribute(v891, "shotgun", "80");
        xmlNodeSetAttribute(v891, "spas12", "49");
        xmlNodeSetAttribute(v891, "mp5", "210");
        xmlNodeSetAttribute(v891, "ak47", "300");
        xmlNodeSetAttribute(v891, "m4", "200");
        xmlNodeSetAttribute(v891, "rifle", "100");
        xmlNodeSetAttribute(v891, "sniper", "50");
        xmlNodeSetAttribute(v891, "grenade", "1");
        xmlNodeSetAttribute(v891, "teargas", "1");
        xmlNodeSetAttribute(v891, "molotov", "1");
        xmlNodeSetAttribute(v891, "knife", "1");
        v891 = xmlCreateChild(v889, "balance");
        v891 = xmlCreateChild(v889, "cost");
        v891 = xmlCreateChild(v889, "slot");
        v889 = xmlCreateChild(v888, "shooting");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "22");
        xmlNodeSetAttribute(v891, "maximum_clip_ammo", "17");
        xmlNodeSetAttribute(v891, "flags", "3303");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "26");
        xmlNodeSetAttribute(v891, "maximum_clip_ammo", "2");
        xmlNodeSetAttribute(v891, "flags", "3303");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "28");
        xmlNodeSetAttribute(v891, "maximum_clip_ammo", "50");
        xmlNodeSetAttribute(v891, "flags", "3303");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "30");
        xmlNodeSetAttribute(v891, "damage", "12");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "32");
        xmlNodeSetAttribute(v891, "maximum_clip_ammo", "50");
        xmlNodeSetAttribute(v891, "flags", "3303");
        v891 = xmlCreateChild(v889, "properties");
        xmlNodeSetAttribute(v891, "weapon", "33");
        xmlNodeSetAttribute(v891, "flags", "830A");
        v889 = xmlCreateChild(v888, "handlings");
        v889 = xmlCreateChild(v888, "settings");
        v891 = xmlCreateChild(v889, "settings");
        xmlNodeSetAttribute(v891, "autobalance", "false");
        xmlNodeSetAttribute(v891, "autoswap", "true");
        xmlNodeSetAttribute(v891, "blurlevel", "0");
        xmlNodeSetAttribute(v891, "countdown_auto", "true");
        xmlNodeSetAttribute(v891, "countdown_force", "0:10");
        xmlNodeSetAttribute(v891, "countdown_start", "3");
        xmlNodeSetAttribute(v891, "dontfire", "false");
        xmlNodeSetAttribute(v891, "friendly_fire", "false");
        xmlNodeSetAttribute(v891, "gamespeed", "1.0");
        xmlNodeSetAttribute(v891, "ghostmode", "none|none,team,all");
        xmlNodeSetAttribute(v891, "gravity", "0.008");
        xmlNodeSetAttribute(v891, "heli_killing", "true");
        xmlNodeSetAttribute(v891, "player_can_driveby", "true");
        xmlNodeSetAttribute(v891, "player_dead_visible", "true");
        xmlNodeSetAttribute(v891, "player_nametag", "all|none,team,all");
        xmlNodeSetAttribute(v891, "player_radarblip", "team|none,team,all");
        xmlNodeSetAttribute(v891, "player_information", "true");
        xmlNodeSetAttribute(v891, "player_start_armour", "0");
        xmlNodeSetAttribute(v891, "player_start_health", "100");
        xmlNodeSetAttribute(v891, "respawn", "false");
        xmlNodeSetAttribute(v891, "respawn_lives", "0");
        xmlNodeSetAttribute(v891, "respawn_time", "0:05");
        xmlNodeSetAttribute(v891, "spectate_enemy", "false");
        xmlNodeSetAttribute(v891, "stealth_killing", "true");
        xmlNodeSetAttribute(v891, "streetlamps", "true");
        xmlNodeSetAttribute(v891, "time", "12:00");
        xmlNodeSetAttribute(v891, "time_locked", "false");
        xmlNodeSetAttribute(v891, "time_minuteduration", "1000");
        xmlNodeSetAttribute(v891, "timeout_to_pause", "false");
        xmlNodeSetAttribute(v891, "vehicle_color", "teamcolor|default,teamcolor");
        xmlNodeSetAttribute(v891, "vehicle_per_player", "2");
        xmlNodeSetAttribute(v891, "vehicle_nametag", "true");
        xmlNodeSetAttribute(v891, "vehicle_radarblip", "unoccupied|none,unoccupied,always");
        xmlNodeSetAttribute(v891, "vehicle_respawn_blown", "0:00");
        xmlNodeSetAttribute(v891, "vehicle_respawn_idle", "0:00");
        xmlNodeSetAttribute(v891, "vehicle_tank_explodable", "false");
        xmlNodeSetAttribute(v891, "vote", "true");
        xmlNodeSetAttribute(v891, "vote_duration", "0:20");
        v891 = xmlCreateChild(v889, "glitches");
        xmlNodeSetAttribute(v891, "quickreload", "false");
        xmlNodeSetAttribute(v891, "fastmove", "true");
        xmlNodeSetAttribute(v891, "fastfire", "true");
        xmlNodeSetAttribute(v891, "crouchbug", "true");
        xmlNodeSetAttribute(v891, "fastsprint", "true");
        xmlNodeSetAttribute(v891, "quickstand", "true");
        v891 = xmlCreateChild(v889, "cheats");
        xmlNodeSetAttribute(v891, "hovercars", "false");
        xmlNodeSetAttribute(v891, "aircars", "false");
        xmlNodeSetAttribute(v891, "extrabunny", "false");
        xmlNodeSetAttribute(v891, "extrajump", "false");
        xmlNodeSetAttribute(v891, "magnetcars", "false");
        xmlNodeSetAttribute(v891, "knockoffbike", "true");
        v891 = xmlCreateChild(v889, "limites");
        xmlNodeSetAttribute(v891, "fps_limit", "50");
        xmlNodeSetAttribute(v891, "fps_minimal", "0");
        xmlNodeSetAttribute(v891, "ping_maximal", "65536");
        xmlNodeSetAttribute(v891, "packetloss_second", "0");
        xmlNodeSetAttribute(v891, "packetloss_total", "0");
        xmlNodeSetAttribute(v891, "warnings_fps", "10");
        xmlNodeSetAttribute(v891, "warnings_ping", "10");
        xmlNodeSetAttribute(v891, "warnings_packetloss", "3");
        local l_pairs_6 = pairs;
        local v893 = getTacticsData("modes_defined") or {};
        for v894 in l_pairs_6(v893) do
            v891 = xmlCreateChild(v889, "mode");
            xmlNodeSetAttribute(v891, "name", v894);
            xmlNodeSetAttribute(v891, "enable", "true");
            local l_pairs_7 = pairs;
            local v896 = getTacticsData("modes_settings", v894) or {};
            for v897, v898 in l_pairs_7(v896) do
                xmlNodeSetAttribute(v891, v897, v898);
            end;
        end;
        v889 = xmlCreateChild(v888, "mappack");
        xmlNodeSetAttribute(v889, "automatics", "lobby|lobby,cycler,voting,random");
        v891 = xmlCreateChild(v889, "cycler");
        xmlNodeSetAttribute(v891, "resnames", "[]");
        v891 = xmlCreateChild(v889, "disabled");
        xmlNodeSetAttribute(v891, "resnames", "[]");
        v889 = xmlCreateChild(v888, "vehiclepack");
        xmlNodeSetAttribute(v889, "models", "[407,425,430,432,435,441,447,449,450,464,465,476,501,520,584,591,601,537,538,564,569,570,590,594,606,607,610,608,611]");
        v889 = xmlCreateChild(v888, "weather");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "0");
        xmlNodeSetAttribute(v891, "sky", "[0,23,24,0,31,32]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "false");
        xmlNodeSetAttribute(v891, "sun", "[255,128,0,5,0,0,0.00]");
        xmlNodeSetAttribute(v891, "water", "[85,85,65,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "400.00");
        xmlNodeSetAttribute(v891, "fog", "100.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "5");
        xmlNodeSetAttribute(v891, "sky", "[0,20,20,0,31,32]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,128,0,255,128,0,0.00]");
        xmlNodeSetAttribute(v891, "water", "[53,104,104,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "400.00");
        xmlNodeSetAttribute(v891, "fog", "100.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "6");
        xmlNodeSetAttribute(v891, "sky", "[90,205,255,200,144,85]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,128,0,255,128,0,8.40]");
        xmlNodeSetAttribute(v891, "water", "[90,170,170,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "100.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "7");
        xmlNodeSetAttribute(v891, "sky", "[90,205,255,90,200,255]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,255,255,255,255,255,2.20]");
        xmlNodeSetAttribute(v891, "water", "[145,170,170,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "100.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "12");
        xmlNodeSetAttribute(v891, "sky", "[68,117,210,36,117,199]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,255,255,255,255,255,1.10]");
        xmlNodeSetAttribute(v891, "water", "[90,170,170,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "10.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "19");
        xmlNodeSetAttribute(v891, "sky", "[68,117,210,36,117,194]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[222,88,0,122,55,0,3.90]");
        xmlNodeSetAttribute(v891, "water", "[50,97,97,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "10.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "20");
        xmlNodeSetAttribute(v891, "sky", "[181,150,84,167,108,65]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,128,0,255,128,0,2.00]");
        xmlNodeSetAttribute(v891, "water", "[67,67,67,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "10.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v891 = xmlCreateChild(v889, "weather");
        xmlNodeSetAttribute(v891, "hour", "22");
        xmlNodeSetAttribute(v891, "sky", "[137,100,84,60,50,52]");
        xmlNodeSetAttribute(v891, "clouds", "true");
        xmlNodeSetAttribute(v891, "birds", "true");
        xmlNodeSetAttribute(v891, "sun", "[255,128,0,5,8,0,1.00]");
        xmlNodeSetAttribute(v891, "water", "[67,67,62,240]");
        xmlNodeSetAttribute(v891, "wave", "0.5");
        xmlNodeSetAttribute(v891, "level", "0");
        xmlNodeSetAttribute(v891, "wind", "[0.16,0.15,0.00]");
        xmlNodeSetAttribute(v891, "rain", "0");
        xmlNodeSetAttribute(v891, "heat", "0");
        xmlNodeSetAttribute(v891, "far", "800.00");
        xmlNodeSetAttribute(v891, "fog", "10.00");
        xmlNodeSetAttribute(v891, "effect", "0");
        v889 = xmlCreateChild(v888, "anticheat");
        xmlNodeSetAttribute(v889, "action_detection", "chat|chat,adminchat,kick");
        v891 = xmlCreateChild(v889, "speedhach");
        xmlNodeSetAttribute(v891, "enable", "true");
        v891 = xmlCreateChild(v889, "godmode");
        xmlNodeSetAttribute(v891, "enable", "true");
        v891 = xmlCreateChild(v889, "mods");
        xmlNodeSetAttribute(v891, "enable", "true");
        node3 = xmlCreateChild(v891, "mod");
        xmlNodeSetAttribute(node3, "name", "Animations");
        xmlNodeSetAttribute(node3, "search", "*.ifp");
        xmlNodeSetAttribute(node3, "type", "name");
        node3 = xmlCreateChild(v891, "mod");
        xmlNodeSetAttribute(node3, "name", "Collisions");
        xmlNodeSetAttribute(node3, "search", "*.col");
        xmlNodeSetAttribute(node3, "type", "name");
        xmlSaveFile(v888);
        xmlUnloadFile(v888);
        startConfig("_default", v885);
    end;
    refreshConfiglist = function(v899) --[[ Line: 1128 ]]
        local v900 = {};
        local v901 = nil;
        local v902 = nil;
        local v903 = nil;
        local v904 = nil;
        v901 = xmlLoadFile("config/configs.xml");
        for _, v906 in ipairs(xmlNodeGetChildren(v901)) do
            if xmlNodeGetName(v906) == "current" then
                v902 = xmlNodeGetAttribute(v906, "src");
                v904 = v906;
            end;
            if xmlNodeGetName(v906) == "config" then
                v903 = xmlNodeGetAttribute(v906, "src");
                if not fileExists("config/" .. v903 .. ".xml") then
                    xmlDestroyNode(v906);
                    if v903 == v902 then
                        xmlNodeSetAttribute(v904, "src", "_default");
                    end;
                else
                    local v907 = "";
                    local v908 = xmlLoadFile("config/" .. v903 .. ".xml");
                    if xmlFindChild(v908, "mappack", 0) then
                        v907 = v907 .. "M ";
                    end;
                    if xmlFindChild(v908, "settings", 0) then
                        v907 = v907 .. "S ";
                    end;
                    if xmlFindChild(v908, "teams", 0) then
                        v907 = v907 .. "T ";
                    end;
                    if xmlFindChild(v908, "weaponpack", 0) then
                        v907 = v907 .. "Wp ";
                    end;
                    if xmlFindChild(v908, "vehiclepack", 0) then
                        v907 = v907 .. "V ";
                    end;
                    if xmlFindChild(v908, "weather", 0) then
                        v907 = v907 .. "Wh ";
                    end;
                    if xmlFindChild(v908, "shooting", 0) then
                        v907 = v907 .. "Sh ";
                    end;
                    if xmlFindChild(v908, "handlings", 0) then
                        v907 = v907 .. "H ";
                    end;
                    if xmlFindChild(v908, "anticheat", 0) then
                        v907 = v907 .. "AC ";
                    end;
                    xmlUnloadFile(v908);
                    if v903 == v902 then
                        table.insert(v900, {
                            v903, 
                            0, 
                            v907
                        });
                    else
                        table.insert(v900, {
                            v903, 
                            255, 
                            v907
                        });
                    end;
                end;
            end;
        end;
        xmlSaveFile(v901);
        xmlUnloadFile(v901);
        callClientFunction(v899, "refreshConfiglist", v900);
    end;
    onPlayerJoin = function() --[[ Line: 1167 ]]
        setElementData(source, "IP", hasObjectPermissionTo(getThisResource(), "function.getClientIP", false) and getPlayerIP(source) or "Not Permission");
        setElementData(source, "Serial", getPlayerSerial(source));
        setElementData(source, "Version", getPlayerVersion(source));
    end;
    onRoundCommandStart = function(v909, v910, v911) --[[ Line: 1172 ]]
        if not hasObjectPermissionTo(v909, "general.tactics_maps", false) then
            return outputLangString(v909, "you_have_not_permissions");
        elseif not v911 then
            return startMap(v910);
        else
            local v912 = getResourceFromName(string.lower(v910 .. "_" .. v911));
            if v912 and getResourceInfo(v912, "type") == "map" then
                startMap(v912);
                return true;
            else
                return false;
            end;
        end;
    end;
    onRoundStop = function(v913) --[[ Line: 1187 ]]
        if not hasObjectPermissionTo(v913, "general.tactics_maps", false) then
            outputLangString(v913, "you_have_not_permissions");
            return false;
        else
            local v914 = getTacticsData("map_disabled") or {};
            local v915 = {};
            for _, v917 in ipairs(getResources()) do
                if getResourceInfo(v917, "type") == "map" and string.find(getResourceName(v917), "lobby") == 1 and not v914[getResourceName(v917)] then
                    table.insert(v915, v917);
                end;
            end;
            if #v915 > 0 then
                local v918 = v915[math.random(#v915)];
                startMap(v918, "random");
                return true;
            else
                return false;
            end;
        end;
    end;
    createTacticsMode = function(v919, v920, v921) --[[ Line: 1206 ]]
        setTacticsData(v921 or true, "modes_defined", tostring(v919));
        addCommandHandler(tostring(v919), onRoundCommandStart, false, false);
        setTacticsData(v920, "modes_settings", tostring(v919));
    end;
    addPlayer = function(v922, _, v924) --[[ Line: 1211 ]]
        if not hasObjectPermissionTo(v922, "general.tactics_players", false) then
            return outputLangString(v922, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local v925 = getElementByID(tostring(v924));
            if v925 then
                if not getPlayerTeam(v925) then
                    outputLangString(v922, "player_without_team");
                elseif getPlayerTeam(v925) == getElementsByType("team")[1] then
                    outputLangString(v922, "player_is_referee");
                elseif getElementData(v925, "Loading") then
                    outputLangString(v922, "player_do_not_loaded");
                elseif getElementData(v925, "Status") == "Play" then
                    outputLangString(v922, "player_play_already");
                else
                    outputLangString(root, "add_to_round", getPlayerName(v925));
                    triggerEvent("onPlayerRoundRespawn", v925);
                end;
            end;
            return;
        end;
    end;
    removePlayer = function(v926, _, v928) --[[ Line: 1232 ]]
        if not hasObjectPermissionTo(v926, "general.tactics_players", false) then
            return outputLangString(v926, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local v929 = getElementByID(tostring(v928));
            if v929 then
                if getElementData(v929, "Status") ~= "Play" then
                    outputLangString(v926, "player_not_play_yet");
                elseif triggerEvent("onPlayerRemoveFromRound", v929) == true then
                    killPed(v929);
                    outputLangString(root, "remove_from_round", getPlayerName(v929));
                end;
            end;
            return;
        end;
    end;
    restorePlayer = function(v930, _, v932) --[[ Line: 1249 ]]
        if not hasObjectPermissionTo(v930, "general.tactics_players", false) then
            return outputLangString(v930, "you_have_not_permissions");
        elseif getRoundState() ~= "started" then
            return false;
        else
            local v933 = getElementByID(tostring(v932));
            if v933 then
                callClientFunction(v930, "toRestoreChoise", v933);
            end;
            return;
        end;
    end;
    resetStats = function(_) --[[ Line: 1259 ]]
        for _, v936 in ipairs(getElementsByType("team")) do
            setElementData(v936, "Score", 0);
        end;
        for _, v938 in ipairs(getElementsByType("player")) do
            setElementData(v938, "Kills", 0);
            setElementData(v938, "Deaths", 0);
            setElementData(v938, "Damage", 0);
        end;
        outputLangString(root, "stats_cleaned");
    end;
    setNextMap = function(v939) --[[ Line: 1270 ]]
        local v940 = getResourceFromName(v939);
        if v940 then
            local v941 = string.sub(v939, 1, string.find(v939, "_") - 1);
            if #v941 > 1 then
                v941 = string.upper(string.sub(v941, 1, 1)) .. string.sub(v941, 2);
            end;
            local v942 = getResourceInfo(v940, "name");
            if not v942 then
                v942 = string.sub(string.gsub(v939, "_", " "), #v941 + 2);
                if #v942 > 1 then
                    v942 = string.upper(string.sub(v942, 1, 1)) .. string.sub(v942, 2);
                end;
            end;
            setTacticsData(v939, "ResourceNext");
            if getTacticsData("Map") == "lobby" then
                startMap(v940);
            else
                outputLangString(root, "map_set_next", v941 .. ": " .. v942);
            end;
        else
            outputLangString(root, "voting_falied");
        end;
    end;
    cancelNextMap = function() --[[ Line: 1292 ]]
        if not getTacticsData("ResourceNext") then
            return;
        else
            setTacticsData(nil, "ResourceNext");
            outputLangString(root, "map_cancel_next");
            return;
        end;
    end;
    balanceTeams = function(v943, v944, ...) --[[ Line: 1297 ]]
        if v943 and not hasObjectPermissionTo(v943, "general.tactics_players", false) then
            return outputLangString(v943, "you_have_not_permissions");
        else
            local v945 = {
                ...
            };
            v944 = string.lower(tostring(v944));
            if v944 == "lite" then
                local v946 = 0;
                local v947 = {};
                for v948, v949 in ipairs(getElementsByType("team")) do
                    if v948 > 1 then
                        v946 = v946 + countPlayersInTeam(v949);
                        table.insert(v947, {
                            v949, 
                            getPlayersInTeam(v949)
                        });
                    end;
                end;
                if #v947 == 0 then
                    return;
                else
                    local v950 = math.ceil(v946 / #v947);
                    table.sort(v947, function(v951, v952) --[[ Line: 1315 ]]
                        return #v951[2] > #v952[2];
                    end);
                    local v953 = {};
                    for _, v955 in ipairs(v947) do
                        local v956, v957 = unpack(v955);
                        for v958 = math.min(#v957, v950), math.max(#v957, v950) do
                            if v958 <= #v957 then
                                table.insert(v953, v957[v958]);
                            else
                                local v959 = getElementData(v956, "Skins") or {
                                    71
                                };
                                setPlayerTeam(v953[1], v956);
                                setElementModel(v953[1], v959[1]);
                                triggerClientEvent(root, "onClientPlayerBlipUpdate", v953[1]);
                                table.remove(v953, 1);
                            end;
                        end;
                    end;
                    outputLangString(root, "team_balanced_mode", "Lite");
                end;
            elseif v944 == "select" then
                local v960 = getElementsByType("team")[1];
                local v961 = getTacticsData("Sides");
                if #v961 < 2 then
                    return;
                else
                    local v962 = {};
                    local l_ipairs_1 = ipairs;
                    local v964 = v945[1] or {};
                    for _, v966 in l_ipairs_1(v964) do
                        v962[v966] = true;
                        local v967 = getElementData(v961[1], "Skins") or {
                            71
                        };
                        setPlayerTeam(v966, v961[1]);
                        setElementModel(v966, v967[1]);
                        triggerClientEvent(root, "onClientPlayerBlipUpdate", v966);
                    end;
                    for _, v969 in ipairs(getElementsByType("player")) do
                        if getPlayerTeam(v969) and getPlayerTeam(v969) ~= v960 and not v962[v969] then
                            local v970 = getElementData(v961[2], "Skins") or {
                                71
                            };
                            setPlayerTeam(v969, v961[2]);
                            setElementModel(v969, v970[1]);
                            triggerClientEvent(root, "onClientPlayerBlipUpdate", v969);
                        end;
                    end;
                    outputLangString(root, "team_balanced_mode", "Select");
                end;
            else
                local v971 = {};
                local v972 = getElementsByType("team")[1];
                for _, v974 in ipairs(getElementsByType("player")) do
                    if getPlayerTeam(v974) and getPlayerTeam(v974) ~= v972 then
                        table.insert(v971, v974);
                    end;
                end;
                table.sort(v971, function(v975, v976) --[[ Line: 1363 ]]
                    local v977 = getElementData(v975, "Kills") or 0;
                    local v978 = getElementData(v975, "Deaths") or 0;
                    local v979 = 0.5 * (v977 + 0.01 * (getElementData(v975, "Damage") or 0)) - v978;
                    local v980 = getElementData(v976, "Kills") or 0;
                    local v981 = getElementData(v976, "Deaths") or 0;
                    return 0.5 * (v980 + 0.01 * (getElementData(v976, "Damage") or 0)) - v981 < v979;
                end);
                local v982 = getTacticsData("Sides");
                table.sort(v982, function(v983, v984) --[[ Line: 1375 ]]
                    return (getElementData(v983, "Score") or 0) < (getElementData(v984, "Score") or 0);
                end);
                for v985, v986 in ipairs(v982) do
                    for v987, v988 in ipairs(v971) do
                        if (v987 - 1) % #v982 == v985 - 1 then
                            local v989 = getElementData(v986, "Skins") or {
                                71
                            };
                            setPlayerTeam(v988, v986);
                            setElementModel(v988, v989[1]);
                            triggerClientEvent(root, "onClientPlayerBlipUpdate", v988);
                        end;
                    end;
                end;
                outputLangString(root, "team_balanced");
            end;
            return;
        end;
    end;
    onPlayerLogin = function(_, _, _) --[[ Line: 1393 ]]
        if hasObjectPermissionTo(source, "general.tactics_openpanel", false) then
            outputLangString(source, "for_open_controlpanel");
        end;
    end;
    onElementDataChange = function(v993, _) --[[ Line: 1398 ]]
        if v993 == "Skins" and getElementType(source) == "team" then
            local v995 = getElementData(source, v993);
            for _, v997 in ipairs(getPlayersInTeam(source)) do
                setElementModel(v997, v995[1]);
            end;
        end;
    end;
    onTacticsChange = function(v998, _) --[[ Line: 1406 ]]
        if v998[1] == "settings" then
            if v998[2] == "gamespeed" and not isRoundPaused() then
                setGameSpeed(tonumber(getTacticsData("settings", "gamespeed")));
            end;
            if v998[2] == "gravity" then
                setGravity(tonumber(getTacticsData("settings", "gravity")));
            end;
            if v998[2] == "friendly_fire" then
                local v1000 = getTacticsData("settings", "friendly_fire") == "true";
                for _, v1002 in ipairs(getElementsByType("team")) do
                    setTeamFriendlyFire(v1002, v1000);
                end;
            end;
        end;
        if v998[1] == "glitches" then
            if v998[2] == "quickreload" then
                setGlitchEnabled("quickreload", getTacticsData("glitches", "quickreload") == "true");
            end;
            if v998[2] == "fastmove" then
                setGlitchEnabled("fastmove", getTacticsData("glitches", "fastmove") == "true");
            end;
            if v998[2] == "fastfire" then
                setGlitchEnabled("fastfire", getTacticsData("glitches", "fastfire") == "true");
            end;
            if v998[2] == "crouchbug" then
                setGlitchEnabled("crouchbug", getTacticsData("glitches", "crouchbug") == "true");
            end;
            if v998[2] == "fastsprint" then
                setGlitchEnabled("fastsprint", getTacticsData("glitches", "fastsprint") == "true");
            end;
            if v998[2] == "quickstand" then
                setGlitchEnabled("quickstand", getTacticsData("glitches", "quickstand") == "true");
            end;
        end;
        if v998[1] == "limites" and v998[2] == "fps_limit" then
            setFPSLimit(tonumber(getTacticsData("limites", "fps_limit")));
        end;
        if v998[1] == "handlings" then
            local v1003 = getTacticsData("handlings") or {};
            for v1004 = 400, 611 do
                if #getVehicleNameFromModel(v1004) > 0 then
                    local v1005 = getOriginalHandling(v1004);
                    v1005.monetary = nil;
                    v1005.animGroup = nil;
                    v1005.tailLight = nil;
                    v1005.headLight = nil;
                    local v1006 = getModelHandling(v1004);
                    local _ = nil;
                    for v1008, v1009 in pairs(v1005) do
                        if v1003[v1004] and v1003[v1004][v1008] ~= nil then
                            if v1008 == "modelFlags" or v1008 == "handlingFlags" then
                                setModelHandling(v1004, v1008, tonumber(v1003[v1004][v1008]));
                                for _, v1011 in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(v1011) == v1004 then
                                        setVehicleHandling(v1011, v1008, tonumber(v1003[v1004][v1008]));
                                    end;
                                end;
                            elseif type(v1003[v1004][v1008]) == "table" then
                                setModelHandling(v1004, v1008, {
                                    unpack(v1003[v1004][v1008])
                                });
                                for _, v1013 in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(v1013) == v1004 then
                                        setVehicleHandling(v1013, v1008, {
                                            unpack(v1003[v1004][v1008])
                                        });
                                    end;
                                end;
                            else
                                setModelHandling(v1004, v1008, v1003[v1004][v1008]);
                                for _, v1015 in ipairs(getElementsByType("vehicle")) do
                                    if getElementModel(v1015) == v1004 then
                                        setVehicleHandling(v1015, v1008, v1003[v1004][v1008]);
                                    end;
                                end;
                            end;
                        elseif v1006[v1008] ~= v1009 then
                            setModelHandling(v1004, v1008, v1009);
                            for _, v1017 in ipairs(getElementsByType("vehicle")) do
                                if getElementModel(v1017) == v1004 then
                                    setVehicleHandling(v1017, v1008, v1009);
                                end;
                            end;
                        end;
                    end;
                    if not v1003[v1004] or not v1003[v1004].sirens then
                        for _, v1019 in ipairs(getElementsByType("vehicle")) do
                            if getElementModel(v1019) == v1004 then
                                removeVehicleSirens(v1019);
                            end;
                        end;
                    else
                        for _, v1021 in ipairs(getElementsByType("vehicle")) do
                            if getElementModel(v1021) == v1004 then
                                addVehicleSirens(v1021, v1003[v1004].sirens.count, v1003[v1004].sirens.type, v1003[v1004].sirens.flags["360"], v1003[v1004].sirens.flags.DoLOSCheck, v1003[v1004].sirens.flags.UseRandomiser, v1003[v1004].sirens.flags.Silent);
                                for v1022 = 1, v1003[v1004].sirens.count do
                                    local v1023, v1024, v1025, v1026 = getColorFromString("#" .. v1003[v1004].sirens[v1022].color);
                                    setVehicleSirens(v1021, v1022, v1003[v1004].sirens[v1022].x, v1003[v1004].sirens[v1022].y, v1003[v1004].sirens[v1022].z, v1024, v1025, v1026, v1023, v1003[v1004].sirens[v1022].minalpha);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    executeClientRuncode = function(v1027, v1028, v1029) --[[ Line: 1526 ]]
        if not isLex128(v1027) then
            return;
        else
            callClientFunction(v1028, "executeClientRuncode", v1027, v1029);
            return;
        end;
    end;
    stopClientRuncode = function(v1030, v1031) --[[ Line: 1530 ]]
        if not isLex128(v1030) then
            return;
        else
            callClientFunction(v1031, "stopClientRuncode", v1030);
            return;
        end;
    end;
    local v1032 = {};
    local v1033 = {};
    local v1034 = {};
    local v1035 = {};
    local v1036 = {};
    createAddEventHandlerFunction = function(v1037) --[[ Line: 1539 ]]
        -- upvalues: v1033 (ref)
        return function(v1038, v1039, v1040, v1041) --[[ Line: 1540 ]]
            -- upvalues: v1033 (ref), v1037 (ref)
            if type(v1038) == "string" and isElement(v1039) and type(v1040) == "function" then
                if v1041 == nil or type(v1041) ~= "boolean" then
                    v1041 = true;
                end;
                if addEventHandler(v1038, v1039, v1040, v1041) then
                    table.insert(v1033[v1037], {
                        v1038, 
                        v1039, 
                        v1040
                    });
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createBindKeyFunction = function(v1042) --[[ Line: 1553 ]]
        -- upvalues: v1034 (ref)
        return function(...) --[[ Line: 1554 ]]
            -- upvalues: v1034 (ref), v1042 (ref)
            local v1043 = {
                ...
            };
            local v1044 = table.remove(v1043, 1);
            local v1045 = table.remove(v1043, 1);
            local v1046 = table.remove(v1043, 1);
            local v1047 = table.remove(v1043, 1);
            local l_v1043_0 = v1043;
            if not isElement(v1044) or getElementType(v1044) ~= "player" or type(v1045) ~= "string" or type(v1046) ~= "string" or type(v1047) ~= "string" and type(v1047) ~= "function" then
                return false;
            else
                v1043 = {
                    v1044, 
                    v1045, 
                    v1046, 
                    v1047, 
                    unpack(l_v1043_0)
                };
                if bindKey(unpack(v1043)) then
                    table.insert(v1034[v1042], v1043);
                    return true;
                else
                    return false;
                end;
            end;
        end;
    end;
    createAddCommandHandlerFunction = function(v1049) --[[ Line: 1572 ]]
        -- upvalues: v1035 (ref)
        return function(v1050, v1051, v1052, v1053) --[[ Line: 1573 ]]
            -- upvalues: v1035 (ref), v1049 (ref)
            if type(v1050) == "string" and type(v1051) == "function" then
                local v1054 = nil;
                if type(v1052) ~= "boolean" then
                    v1052 = false;
                end;
                if type(v1053) ~= "boolean" then
                    v1053 = true;
                end;
                v1054 = {
                    v1050, 
                    v1051, 
                    v1052, 
                    v1053
                };
                if addCommandHandler(unpack(v1054)) then
                    table.insert(v1035[v1049], v1054);
                    return true;
                end;
            end;
            return false;
        end;
    end;
    createSetTimerFunction = function(v1055) --[[ Line: 1591 ]]
        -- upvalues: v1036 (ref)
        return function(v1056, v1057, v1058, ...) --[[ Line: 1592 ]]
            -- upvalues: v1036 (ref), v1055 (ref)
            if type(v1056) == "function" and type(v1057) == "number" and type(v1058) == "number" then
                local v1059 = setTimer(v1056, v1057, v1058, ...);
                if v1059 then
                    table.insert(v1036[v1055], v1059);
                    return v1059;
                end;
            end;
            return false;
        end;
    end;
    createRemoveEventHandlerFunction = function(v1060) --[[ Line: 1603 ]]
        -- upvalues: v1033 (ref)
        return function(v1061, v1062, v1063) --[[ Line: 1604 ]]
            -- upvalues: v1033 (ref), v1060 (ref)
            if type(v1061) == "string" and isElement(v1062) and type(v1063) == "function" then
                for v1064, v1065 in ipairs(v1033[v1060]) do
                    if v1065[1] == v1061 and v1065[2] == v1062 and v1065[3] == v1063 and removeEventHandler(unpack(v1065)) then
                        table.remove(v1033[v1060], v1064);
                        return true;
                    end;
                end;
            end;
            return false;
        end;
    end;
    createUnbindKeyFunction = function(v1066) --[[ Line: 1618 ]]
        -- upvalues: v1034 (ref)
        return function(...) --[[ Line: 1619 ]]
            -- upvalues: v1034 (ref), v1066 (ref)
            local v1067 = {
                ...
            };
            local v1068 = table.remove(v1067, 1);
            local v1069 = table.remove(v1067, 1);
            local v1070 = table.remove(v1067, 1);
            local v1071 = table.remove(v1067, 1);
            if not isElement(v1068) or getElementType(v1068) ~= "player" or type(v1069) ~= "string" then
                return false;
            else
                if type(v1070) ~= "string" or not v1070 then
                    v1070 = nil;
                end;
                if type(v1071) ~= "string" and type(v1071) ~= "function" or not v1071 then
                    v1071 = nil;
                end;
                v1067 = {
                    v1068, 
                    v1069, 
                    v1070, 
                    v1071
                };
                local v1072 = false;
                for v1073, v1074 in ipairs(v1034[v1066]) do
                    if v1074[1] == v1067[1] and v1074[2] == v1067[2] and (not v1067[3] or v1067[3] == v1074[3]) and (not v1067[4] or v1067[4] == v1074[4]) and unbindKey(unpack(v1074)) then
                        table.remove(v1034[v1066], v1073);
                        v1072 = true;
                    end;
                end;
                return v1072;
            end;
        end;
    end;
    createRemoveCommandHandlerFunction = function(v1075) --[[ Line: 1643 ]]
        -- upvalues: v1035 (ref)
        return function(v1076, v1077) --[[ Line: 1644 ]]
            -- upvalues: v1035 (ref), v1075 (ref)
            local v1078 = false;
            if type(v1076) == "string" and type(v1077) == "function" then
                for v1079, v1080 in ipairs(v1035[v1075]) do
                    if v1080[1] == v1076 and (not v1080[2] or v1080[2] == v1077) and removeCommandHandler(unpack(v1080)) then
                        table.remove(v1035[v1075], v1079);
                        v1078 = true;
                    end;
                end;
            end;
            return v1078;
        end;
    end;
    createKillTimerFunction = function(v1081) --[[ Line: 1659 ]]
        -- upvalues: v1036 (ref)
        return function(v1082) --[[ Line: 1660 ]]
            -- upvalues: v1036 (ref), v1081 (ref)
            local v1083 = false;
            for v1084, v1085 in ipairs(v1036[v1081]) do
                if v1085 == v1082 and killTimer(v1082) then
                    table.remove(v1036[v1081], v1084);
                    v1083 = true;
                end;
            end;
            return v1083;
        end;
    end;
    cleanEventHandlerContainer = function(v1086) --[[ Line: 1673 ]]
        -- upvalues: v1033 (ref)
        if not v1033[v1086] then
            return;
        else
            for _, v1088 in ipairs(v1033[v1086]) do
                if isElement(v1088[2]) then
                    removeEventHandler(unpack(v1088));
                end;
            end;
            v1033[v1086] = nil;
            return;
        end;
    end;
    cleanKeyBindContainer = function(v1089) --[[ Line: 1682 ]]
        -- upvalues: v1034 (ref)
        if not v1034[v1089] then
            return;
        else
            for _, v1091 in ipairs(v1034[v1089]) do
                unbindKey(unpack(v1091));
            end;
            v1034[v1089] = nil;
            return;
        end;
    end;
    cleanCommandHandlerContainer = function(v1092) --[[ Line: 1689 ]]
        -- upvalues: v1035 (ref)
        if not v1035[v1092] then
            return;
        else
            for _, v1094 in ipairs(v1035[v1092]) do
                removeCommandHandler(unpack(v1094));
            end;
            v1035[v1092] = nil;
            return;
        end;
    end;
    cleanTimerContainer = function(v1095) --[[ Line: 1696 ]]
        -- upvalues: v1036 (ref)
        if not v1036[v1095] then
            return;
        else
            for _, v1097 in ipairs(v1036[v1095]) do
                if isTimer(v1097) then
                    killTimer(v1097);
                end;
            end;
            v1036[v1095] = nil;
            return;
        end;
    end;
    stopRuncode = function(v1098) --[[ Line: 1703 ]]
        -- upvalues: v1032 (ref)
        if not isLex128(v1098) then
            return;
        elseif not v1032[v1098] then
            outputChatBox("Not running!", v1098, 0, 128, 0, true);
            return;
        else
            cleanEventHandlerContainer(v1098);
            cleanKeyBindContainer(v1098);
            cleanCommandHandlerContainer(v1098);
            cleanTimerContainer(v1098);
            v1032[v1098] = nil;
            outputChatBox("Stopped!", v1098, 0, 128, 0, true);
            return;
        end;
    end;
    executeRuncode = function(v1099, _, ...) --[[ Line: 1716 ]]
        -- upvalues: v1033 (ref), v1034 (ref), v1035 (ref), v1036 (ref), v1032 (ref)
        if not isLex128(v1099) then
            return;
        else
            local v1101 = "";
            for _, v1103 in pairs({
                ...
            }) do
                v1101 = v1101 .. " " .. v1103;
            end;
            if not v1033[v1099] then
                v1033[v1099] = {};
            end;
            if not v1034[v1099] then
                v1034[v1099] = {};
            end;
            if not v1035[v1099] then
                v1035[v1099] = {};
            end;
            if not v1036[v1099] then
                v1036[v1099] = {};
            end;
            if not v1032[v1099] then
                v1032[v1099] = {
                    addEventHandler = createAddEventHandlerFunction(v1099), 
                    removeEventHandler = createRemoveEventHandlerFunction(v1099), 
                    bindKey = createBindKeyFunction(v1099), 
                    unbindKey = createUnbindKeyFunction(v1099), 
                    addCommandHandler = createAddCommandHandlerFunction(v1099), 
                    removeCommandHandler = createRemoveCommandHandlerFunction(v1099), 
                    setTimer = createSetTimerFunction(v1099), 
                    killTimer = createKillTimerFunction(v1099)
                };
                setmetatable(v1032[v1099], {
                    __index = _G
                });
            end;
            local v1104 = false;
            local v1105, v1106 = loadstring("return " .. v1101);
            if v1106 then
                v1104 = true;
                local v1107, v1108 = loadstring(tostring(v1101));
                v1106 = v1108;
                v1105 = v1107;
            end;
            if v1106 then
                outputChatBox("ERROR: " .. v1106, v1099, 255, 0, 0, true);
                return;
            else
                v1105 = setfenv(v1105, v1032[v1099]);
                local v1109 = {
                    pcall(v1105)
                };
                if not v1109[1] then
                    outputChatBox("ERROR: " .. v1109[2], v1099, 255, 0, 0, true);
                    return;
                else
                    if not v1104 then
                        local v1110 = "";
                        for v1111 = 2, #v1109 do
                            local v1112 = "";
                            if v1111 > 2 then
                                v1110 = v1110 .. "#00FF00, ";
                            end;
                            local v1113 = v1109[v1111];
                            if type(v1113) == "table" then
                                for v1114, _ in pairs(v1113) do
                                    if #v1112 > 0 then
                                        v1112 = v1112 .. ", ";
                                    end;
                                    if type(v1114) == "userdata" then
                                        if isElement(v1114) then
                                            v1112 = v1112 .. "#66CC66" .. getElementType(v1113) .. "#B1B100";
                                        else
                                            v1112 = v1112 .. "#66CC66element#B1B100";
                                        end;
                                    elseif type(v1114) == "string" then
                                        v1112 = v1112 .. "#FF0000\"" .. v1114 .. "\"#B1B100";
                                    else
                                        v1112 = v1112 .. "#000099" .. tostring(v1114) .. "#B1B100";
                                    end;
                                end;
                                v1112 = "#B1B100{" .. v1112 .. "}";
                            elseif type(v1113) == "userdata" then
                                if isElement(v1113) then
                                    v1112 = "#66CC66" .. getElementType(v1113) .. string.gsub(tostring(v1113), "userdata:", "");
                                else
                                    v1112 = "#66CC66element" .. string.gsub(tostring(v1113), "userdata:", "");
                                end;
                            elseif type(v1113) == "string" then
                                v1112 = "#FF0000\"" .. v1113 .. "\"";
                            elseif type(v1113) == "function" then
                                v1112 = "#0000FF" .. tostring(v1113);
                            elseif type(v1113) == "thread" then
                                v1112 = "#808080" .. tostring(v1113);
                            else
                                v1112 = "#000099" .. tostring(v1113);
                            end;
                            v1110 = v1110 .. v1112;
                        end;
                        v1110 = "Return: " .. v1110;
                        outputChatBox(string.sub(v1110, 1, 128), v1099, 0, 255, 0, true);
                    elseif not v1106 then
                        outputChatBox("Executed!", v1099, 0, 255, 0, true);
                    end;
                    return;
                end;
            end;
        end;
    end;
    onPlayerCheckUpdates = function(v1116) --[[ Line: 1798 ]]
        if not hasObjectPermissionTo(getThisResource(), "function.callRemote", false) then
            outputLangString(v1116, "resource_have_not_permissions", getResourceName(getThisResource()), "function.callRemote");
            return;
        else
            callRemote("http://bpb-team.ru/lex128/tactics-wiki/tacticscall.php", onCallRemoteResult, "latest", v1116);
            return;
        end;
    end;
    onCallRemoteResult = function(v1117, ...) --[[ Line: 1805 ]]
        if v1117 == "ERROR" then
            return;
        else
            if v1117 == "latest" then
                local v1118, v1119, v1120 = unpack({
                    ...
                });
                local v1121, v1122, v1123 = unpack(split(v1119, string.byte(" ")));
                local v1124, v1125 = unpack(split(getTacticsData("version"), string.byte(" ")));
                local v1126 = tonumber(({
                    string.gsub(v1123, "[^0-9]+", "")
                })[1]) or math.huge;
                local v1127 = tonumber(({
                    string.gsub(v1125, "[^0-9]+", "")
                })[1]) or math.huge;
                if v1124 < v1122 or v1122 == v1124 and v1127 < v1126 then
                    outputLangString(v1118, "new_version_available", v1121 .. " " .. v1122 .. " " .. v1123 .. " - " .. v1120);
                else
                    outputLangString(v1118, "this_last_version", "Tactics " .. v1124 .. " " .. v1125);
                end;
            end;
            return;
        end;
    end;
    onPlayerAdminchat = function(v1128, _, ...) --[[ Line: 1820 ]]
        if isPlayerMuted(v1128) then
            return outputChatBox("adminsay: You are muted", v1128, 255, 168, 0);
        else
            local v1130 = table.concat({
                ...
            }, " ");
            outputServerLog("ADMINCHAT: " .. getPlayerName(v1128) .. ": " .. v1130);
            local v1131 = "FFFFFF";
            local v1132 = getPlayerTeam(v1128);
            if v1132 then
                v1131 = string.format("%02X%02X%02X", getTeamColor(v1132));
            end;
            v1130 = "(ADMIN) #" .. v1131 .. getPlayerName(v1128) .. " (" .. getElementID(v1128) .. "): #EBDDB2" .. v1130;
            for _, v1134 in ipairs(getElementsByType("player")) do
                if v1134 == v1128 or hasObjectPermissionTo(v1134, "general.tactics_adminchat", false) then
                    outputChatBox(v1130, v1134, 255, 100, 100, true);
                end;
            end;
            return;
        end;
    end;
    nextCyclerMap = function(v1135) --[[ Line: 1835 ]]
        if not hasObjectPermissionTo(v1135, "general.tactics_maps", false) then
            return outputLangString(v1135, "you_have_not_permissions");
        else
            local v1136 = getTacticsData("Resources");
            local _ = getTacticsData("ResourceNext");
            if v1136 and #v1136 > 0 then
                local v1138 = (getTacticsData("ResourceCurrent") or tonumber(0)) + 1;
                if #v1136 < v1138 then
                    v1138 = 1;
                end;
                startMap(v1136[v1138][1], v1138);
            elseif getTacticsData("ResourceNext") then
                nextMap();
            end;
            return;
        end;
    end;
    previousCyclerMap = function(v1139) --[[ Line: 1849 ]]
        if not hasObjectPermissionTo(v1139, "general.tactics_maps", false) then
            return outputLangString(v1139, "you_have_not_permissions");
        else
            local v1140 = getTacticsData("Resources");
            if not v1140 or #v1140 == 0 then
                return;
            else
                local v1141 = (getTacticsData("ResourceCurrent") or #v1140 + 1) - 1;
                if v1141 <= 0 then
                    v1141 = #v1140;
                end;
                startMap(v1140[v1141][1], v1141);
                return;
            end;
        end;
    end;
    sayFromAdmin = function(v1142, _, ...) --[[ Line: 1859 ]]
        if not hasObjectPermissionTo(v1142, "general.tactics_adminchat", false) then
            return outputLangString(v1142, "you_have_not_permissions");
        elseif isPlayerMuted(v1142) then
            return outputChatBox("asay: You are muted", v1142, 255, 168, 0);
        else
            local v1144 = table.concat({
                ...
            }, " ");
            outputServerLog("ADMIN: " .. v1144);
            v1144 = "ADMIN: #EBDDB2" .. v1144;
            outputChatBox(v1144, root, 255, 100, 100, true);
            return;
        end;
    end;
    changeWeaponProperty = function(v1145, v1146, v1147, v1148, v1149, v1150, v1151, v1152, v1153, v1154, v1155, v1156, v1157, v1158, v1159, v1160) --[[ Line: 1870 ]]
        if not hasObjectPermissionTo(v1145, "general.tactics_shooting", false) then
            return outputLangString(v1145, "you_have_not_permissions");
        else
            setWeaponProperty(v1146, "pro", "weapon_range", v1147);
            setWeaponProperty(v1146, "pro", "target_range", v1148);
            setWeaponProperty(v1146, "pro", "accuracy", v1149);
            setWeaponProperty(v1146, "pro", "damage", tostring(tonumber(v1150) * 3));
            setWeaponProperty(v1146, "pro", "maximum_clip_ammo", v1151);
            setWeaponProperty(v1146, "pro", "move_speed", v1152);
            setWeaponProperty(v1146, "pro", "anim_loop_start", v1153);
            setWeaponProperty(v1146, "pro", "anim_loop_stop", v1154);
            setWeaponProperty(v1146, "pro", "anim_loop_bullet_fire", v1155);
            setWeaponProperty(v1146, "pro", "anim2_loop_start", v1156);
            setWeaponProperty(v1146, "pro", "anim2_loop_stop", v1157);
            setWeaponProperty(v1146, "pro", "anim2_loop_bullet_fire", v1158);
            setWeaponProperty(v1146, "pro", "anim_breakout_time", v1159);
            local v1161 = string.reverse(string.format("%04X", getWeaponProperty(v1146, "pro", "flags")));
            for v1162 = 1, 4 do
                local v1163 = tonumber(string.sub(v1161, v1162, v1162), 16);
                if v1163 then
                    for v1164 = 3, 0, -1 do
                        local v1165 = 2 ^ v1164;
                        if v1165 <= v1163 then
                            if not v1160[v1162][v1165] then
                                setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. tostring(v1165) .. string.rep("0", v1162 - 1)));
                            end;
                            v1163 = v1163 - v1165;
                        elseif v1160[v1162][v1165] then
                            setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. tostring(v1165) .. string.rep("0", v1162 - 1)));
                        end;
                    end;
                else
                    if v1160[v1162][1] then
                        setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. "1" .. string.rep("0", v1162 - 1)));
                    end;
                    if v1160[v1162][2] then
                        setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. "2" .. string.rep("0", v1162 - 1)));
                    end;
                    if v1160[v1162][3] then
                        setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. "4" .. string.rep("0", v1162 - 1)));
                    end;
                    if v1160[v1162][4] then
                        setWeaponProperty(v1146, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1162) .. "8" .. string.rep("0", v1162 - 1)));
                    end;
                end;
            end;
            return callClientFunction(v1145, "refreshWeaponProperties");
        end;
    end;
    resetWeaponProperty = function(v1166, v1167) --[[ Line: 1911 ]]
        if not hasObjectPermissionTo(v1166, "general.tactics_shooting", false) then
            return outputLangString(v1166, "you_have_not_permissions");
        else
            setWeaponProperty(v1167, "pro", "weapon_range", getOriginalWeaponProperty(v1167, "pro", "weapon_range"));
            setWeaponProperty(v1167, "pro", "target_range", getOriginalWeaponProperty(v1167, "pro", "target_range"));
            setWeaponProperty(v1167, "pro", "accuracy", getOriginalWeaponProperty(v1167, "pro", "accuracy"));
            setWeaponProperty(v1167, "pro", "damage", getOriginalWeaponProperty(v1167, "pro", "damage"));
            setWeaponProperty(v1167, "pro", "maximum_clip_ammo", getOriginalWeaponProperty(v1167, "pro", "maximum_clip_ammo"));
            setWeaponProperty(v1167, "pro", "move_speed", getOriginalWeaponProperty(v1167, "pro", "move_speed"));
            setWeaponProperty(v1167, "pro", "anim_loop_start", getOriginalWeaponProperty(v1167, "pro", "anim_loop_start"));
            setWeaponProperty(v1167, "pro", "anim_loop_stop", getOriginalWeaponProperty(v1167, "pro", "anim_loop_stop"));
            setWeaponProperty(v1167, "pro", "anim_loop_bullet_fire", getOriginalWeaponProperty(v1167, "pro", "anim_loop_bullet_fire"));
            setWeaponProperty(v1167, "pro", "anim2_loop_start", getOriginalWeaponProperty(v1167, "pro", "anim2_loop_start"));
            setWeaponProperty(v1167, "pro", "anim2_loop_stop", getOriginalWeaponProperty(v1167, "pro", "anim2_loop_stop"));
            setWeaponProperty(v1167, "pro", "anim2_loop_bullet_fire", getOriginalWeaponProperty(v1167, "pro", "anim2_loop_bullet_fire"));
            setWeaponProperty(v1167, "pro", "anim_breakout_time", getOriginalWeaponProperty(v1167, "pro", "anim_breakout_time"));
            local v1168 = string.reverse(string.format("%04X", getOriginalWeaponProperty(v1167, "pro", "flags")));
            local v1169 = string.reverse(string.format("%04X", getWeaponProperty(v1167, "pro", "flags")));
            local v1170 = {
                {}, 
                {}, 
                {}, 
                {}, 
                {}
            };
            for v1171 = 1, 4 do
                local v1172 = tonumber(string.sub(v1168, v1171, v1171), 16);
                if v1172 then
                    for v1173 = 3, 0, -1 do
                        local v1174 = 2 ^ v1173;
                        if v1174 <= v1172 then
                            v1170[v1171][v1174] = true;
                            v1172 = v1172 - v1174;
                        else
                            v1170[v1171][v1174] = false;
                        end;
                    end;
                else
                    v1170[v1171][1] = false;
                    v1170[v1171][2] = false;
                    v1170[v1171][4] = false;
                    v1170[v1171][8] = false;
                end;
            end;
            for v1175 = 1, 4 do
                local v1176 = tonumber(string.sub(v1169, v1175, v1175), 16);
                if v1176 then
                    for v1177 = 3, 0, -1 do
                        local v1178 = 2 ^ v1177;
                        if v1178 <= v1176 then
                            if not v1170[v1175][v1178] then
                                setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. tostring(v1178) .. string.rep("0", v1175 - 1)));
                            end;
                            v1176 = v1176 - v1178;
                        elseif v1170[v1175][v1178] then
                            setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. tostring(v1178) .. string.rep("0", v1175 - 1)));
                        end;
                    end;
                else
                    if v1170[v1175][8] then
                        setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. "8" .. string.rep("0", v1175 - 1)));
                    end;
                    if v1170[v1175][4] then
                        setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. "4" .. string.rep("0", v1175 - 1)));
                    end;
                    if v1170[v1175][2] then
                        setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. "2" .. string.rep("0", v1175 - 1)));
                    end;
                    if v1170[v1175][1] then
                        setWeaponProperty(v1167, "pro", "flags", tonumber("0x" .. string.rep("0", 6 - v1175) .. "1" .. string.rep("0", v1175 - 1)));
                    end;
                end;
            end;
            return callClientFunction(v1166, "refreshWeaponProperties");
        end;
    end;
    addAnticheatModsearch = function(v1179, v1180, v1181) --[[ Line: 1973 ]]
        local v1182 = getTacticsData("anticheat", "modslist") or {};
        table.insert(v1182, {
            name = v1179, 
            search = v1180, 
            type = v1181
        });
        setTacticsData(v1182, "anticheat", "modslist");
    end;
    setAnticheatModsearch = function(v1183, v1184, v1185, v1186) --[[ Line: 1978 ]]
        local v1187 = getTacticsData("anticheat", "modslist") or {};
        if not v1187[v1183 + 1] then
            return;
        else
            v1187[v1183 + 1] = {
                name = v1184, 
                search = v1185, 
                type = v1186
            };
            setTacticsData(v1187, "anticheat", "modslist");
            return;
        end;
    end;
    removeAnticheatModsearch = function(v1188) --[[ Line: 1984 ]]
        local v1189 = getTacticsData("anticheat", "modslist") or {};
        table.remove(v1189, v1188 + 1);
        setTacticsData(v1189, "anticheat", "modslist");
    end;
    changeVehicleHandling = function(v1190, v1191, v1192) --[[ Line: 1989 ]]
        if not hasObjectPermissionTo(v1190, "general.tactics_handling", false) then
            return outputLangString(v1190, "you_have_not_permissions");
        else
            local v1193 = getTacticsData("handlings") or {};
            if not v1193[v1191] then
                v1193[v1191] = {
                    nil
                };
            end;
            local v1194 = getOriginalHandling(v1191);
            for v1195, v1196 in pairs(v1192) do
                if type(v1196) == "boolean" and v1194[v1195] == v1196 then
                    v1193[v1191][v1195] = nil;
                elseif v1195 == "sirens" then
                    if v1196.count == 0 then
                        v1193[v1191][v1195] = nil;
                    else
                        v1193[v1191][v1195] = v1196;
                    end;
                elseif type(v1196) == "table" and string.format("%.3f", v1194[v1195][1]) == string.format("%.3f", v1196[1]) and string.format("%.3f", v1194[v1195][2]) == string.format("%.3f", v1196[2]) and string.format("%.3f", v1194[v1195][3]) == string.format("%.3f", v1196[3]) then
                    v1193[v1191][v1195] = nil;
                elseif type(v1196) == "number" and string.format("%.3f", v1194[v1195]) == string.format("%.3f", v1196) then
                    v1193[v1191][v1195] = nil;
                elseif type(v1196) == "string" and (v1195 == "modelFlags" or v1195 == "handlingFlags") and string.format("0x%08X", v1194[v1195]) == v1196 then
                    v1193[v1191][v1195] = nil;
                elseif type(v1196) == "string" and v1194[v1195] == v1196 then
                    v1193[v1191][v1195] = nil;
                elseif v1196 ~= nil then
                    v1193[v1191][v1195] = v1196;
                end;
            end;
            setTacticsData(v1193, "handlings");
            return;
        end;
    end;
    resetVehicleHandling = function(v1197, v1198) --[[ Line: 2026 ]]
        if not hasObjectPermissionTo(v1197, "general.tactics_handling", false) then
            return outputLangString(v1197, "you_have_not_permissions");
        else
            local v1199 = getTacticsData("handlings") or {};
            v1199[v1198] = nil;
            setTacticsData(v1199, "handlings");
            return;
        end;
    end;
    onPlayerScreenShot = function(v1200, v1201, v1202, _, v1204) --[[ Line: 2034 ]]
        if v1200 ~= getThisResource() and v1200 ~= "disabled" then
            return;
        else
            local v1205 = getRealTime();
            local v1206, v1207, v1208, _ = unpack(split(v1204, " "));
            local v1210 = string.format("%s_%04i-%02i-%02i_%02i-%02i-%02i", getPlayerName(source):gsub("[\\/:*?\"<>|]", "-"):gsub("-+", "-"):gsub("-$", ""):gsub("^-", ""), v1205.year + 1900, v1205.month + 1, v1205.monthday, v1205.hour, v1205.minute, v1205.second);
            local v1211 = getPlayerFromName(v1206);
            if not v1211 then
                return;
            elseif v1201 == "disabled" then
                outputDebugString("takeDisabledScreenShot");
                triggerClientEvent(source, "takeDisabledScreenShot", source, v1204);
                return;
            else
                outputDebugString("2 = " .. #v1202);
                triggerClientEvent(v1211, "onClientPlayerScreenShot", source, v1201, v1202, v1207, v1208, v1210);
                return;
            end;
        end;
    end;
    connectPlayers = function(v1212, v1213, v1214, v1215, v1216) --[[ Line: 2049 ]]
        if not hasObjectPermissionTo(getThisResource(), "function.redirectPlayer", false) then
            return outputLangString(v1212, "resource_have_not_permissions", getResourceName(getThisResource()), "function.redirectPlayer");
        else
            if v1214 and v1215 then
                for _, v1218 in ipairs(v1213) do
                    redirectPlayer(v1218, tostring(v1214), tonumber(v1215), v1216);
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
(function(...) --[[ Line: 0 ]]
    onTacticsChange = function(v1219, _) --[[ Line: 7 ]]
        if v1219[1] == "anticheat" then
            if v1219[2] == "mods" then
                if getTacticsData("anticheat", "mods") == "true" then
                    addEventHandler("onPlayerModInfo", root, modifications_onPlayerModInfo);
                    for _, v1222 in ipairs(getElementsByType("player")) do
                        resendPlayerModInfo(v1222);
                    end;
                else
                    removeEventHandler("onPlayerModInfo", root, modifications_onPlayerModInfo);
                end;
            end;
            if v1219[2] == "modslist" and getTacticsData("anticheat", "mods") == "true" then
                for _, v1224 in ipairs(getElementsByType("player")) do
                    resendPlayerModInfo(v1224);
                end;
            end;
        end;
    end;
    addEventHandler("onTacticsChange", root, onTacticsChange);
    modifications_onPlayerModInfo = function(_, v1226) --[[ Line: 27 ]]
        local v1227 = getTacticsData("anticheat", "modslist");
        local v1228 = {};
        local v1229 = {};
        local v1230 = {};
        for _, v1232 in ipairs(v1227) do
            table.insert(v1228, {
                search = v1232.search:gsub("*", ".+"), 
                type = v1232.type
            });
            table.insert(v1229, 0);
            table.insert(v1230, "");
        end;
        local v1233 = false;
        for _, v1235 in ipairs(v1226) do
            for v1236, v1237 in ipairs(v1228) do
                if string.match(v1235[v1237.type], v1237.search) then
                    v1233 = true;
                    v1229[v1236] = v1229[v1236] + 1;
                    v1230[v1236] = v1235.name;
                end;
            end;
        end;
        if v1233 then
            local v1238 = "";
            for v1239 in ipairs(v1228) do
                if v1229[v1239] > 0 then
                    v1238 = v1238 .. string.format(" %i/%s", v1229[v1239], v1230[v1239]);
                end;
            end;
            doPunishment(source, "Mods" .. v1238);
        end;
    end;
    doPunishment = function(v1240, v1241) --[[ Line: 55 ]]
        local v1242 = getTacticsData("anticheat", "action_detection");
        if v1242 == "chat" then
            outputLangString(root, "player_cheat_detected", getPlayerName(v1240), v1241);
        elseif v1242 == "adminchat" then
            for _, v1244 in ipairs(getElementsByType("player")) do
                if hasObjectPermissionTo(v1244, "general.tactics_adminchat", false) then
                    outputLangString(v1244, "player_cheat_detected", getPlayerName(v1240), v1241);
                end;
            end;
        elseif v1242 == "kick" then
            if hasObjectPermissionTo(getThisResource(), "function.kickPlayer", false) then
                kickPlayer(v1240, v1241);
            else
                for _, v1246 in ipairs(getElementsByType("player")) do
                    if hasObjectPermissionTo(v1246, "general.tactics_adminchat", false) then
                        outputLangString(v1246, "resource_have_not_permissions", getResourceName(getThisResource()), "function.kickPlayer");
                    end;
                end;
            end;
        end;
    end;
end)();
(function(...) --[[ Line: 0 ]]
    pickupWeapon = function(v1247, v1248) --[[ Line: 7 ]]
        if not isElement(v1248) then
            return;
        elseif triggerEvent("onWeaponPickup", v1247, v1248) == false then
            return;
        else
            local v1249 = getPickupWeapon(v1248);
            local v1250 = getPickupAmmo(v1248);
            local v1251 = getElementData(v1248, "Clip");
            destroyElement(v1248);
            giveWeapon(v1247, v1249, v1250, true);
            if v1251 then
                setWeaponAmmo(v1247, v1249, v1250, v1251);
            end;
            return;
        end;
    end;
    replaceWeapon = function(v1252, v1253, v1254) --[[ Line: 18 ]]
        if not isElement(v1253) then
            return;
        elseif triggerEvent("onWeaponPickup", v1252, v1253) == false then
            return;
        else
            local v1255 = getPedWeapon(v1252, v1254);
            local v1256 = getPedTotalAmmo(v1252, v1254);
            local v1257 = getPedAmmoInClip(v1252, v1254);
            if v1255 > 0 then
                local v1258 = createWeaponUnderPlayer(v1252, v1255, v1256, v1257);
                if triggerEvent("onWeaponDrop", v1252, v1258) == false then
                    if isElement(v1258) then
                        destroyElement(v1258);
                    end;
                    return;
                else
                    takeWeapon(v1252, v1255);
                end;
            end;
            local v1259 = getPickupWeapon(v1253);
            local v1260 = getPickupAmmo(v1253);
            local v1261 = getElementData(v1253, "Clip");
            destroyElement(v1253);
            giveWeapon(v1252, v1259, v1260, true);
            if v1261 then
                setWeaponAmmo(v1252, v1259, v1260, v1261);
            end;
            return;
        end;
    end;
    dropWeapon = function(v1262, v1263) --[[ Line: 41 ]]
        local v1264 = getPedWeapon(v1262, v1263);
        local v1265 = getPedTotalAmmo(v1262, v1263);
        local v1266 = getPedAmmoInClip(v1262, v1263);
        if v1264 > 0 then
            local v1267 = createWeaponUnderPlayer(v1262, v1264, v1265, v1266);
            if triggerEvent("onWeaponDrop", v1262, v1267) == false then
                if isElement(v1267) then
                    destroyElement(v1267);
                end;
            else
                takeWeapon(v1262, v1264);
            end;
        end;
    end;
    createWeaponUnderPlayer = function(v1268, v1269, v1270, v1271) --[[ Line: 55 ]]
        if v1269 > 0 and v1270 > 0 and v1271 then
            local v1272, v1273, v1274 = getElementPosition(v1268);
            local v1275 = createPickup(v1272 + 0.2 * math.random(-5, 5), v1273 + 0.2 * math.random(-5, 5), v1274 - 0.5, 2, v1269, 0, v1270);
            setElementParent(v1275, getRoundMapDynamicRoot());
            setElementData(v1275, "Clip", v1271);
            setElementInterior(v1275, getElementInterior(v1268));
            setElementDimension(v1275, getElementDimension(v1268));
            return v1275;
        else
            return false;
        end;
    end;
    onPlayerWasted = function(_, _, _, _, _) --[[ Line: 67 ]]
        dropWeapon(source);
    end;
    onPickupUse = function(_) --[[ Line: 70 ]]
        cancelEvent();
    end;
    addEvent("onWeaponDrop");
    addEvent("onWeaponPickup");
    addEventHandler("onPlayerWasted", root, onPlayerWasted);
    addEventHandler("onPickupUse", root, onPickupUse);
end)();
(function(...) --[[ Line: 0 ]]
    local v1282 = {};
    setTabboardColumns = function(v1283) --[[ Line: 8 ]]
        -- upvalues: v1282 (ref)
        if not v1283 then
            v1283 = {};
        end;
        v1282 = v1283;
        triggerClientEvent(root, "onClientTabboardChange", root, v1283);
    end;
    onPlayerDownloadComplete = function() --[[ Line: 13 ]]
        -- upvalues: v1282 (ref)
        triggerClientEvent(client, "onClientTabboardChange", root, v1282, getServerName(), getMaxPlayers(), getVersion());
    end;
    getElementStat = function(v1284, v1285) --[[ Line: 16 ]]
        if not isElement(v1284) or getElementType(v1284) ~= "player" and getElementType(v1284) ~= "team" then
            return false;
        else
            local v1286 = getElementData(v1284, v1285);
            if type(v1286) == "nil" then
                v1286 = 0;
            end;
            if type(v1286) ~= "number" then
                return false;
            else
                return v1286;
            end;
        end;
    end;
    setElementStat = function(v1287, v1288, v1289) --[[ Line: 23 ]]
        if not isElement(v1287) or getElementType(v1287) ~= "player" and getElementType(v1287) ~= "team" then
            return false;
        else
            local v1290 = getElementData(v1287, v1288);
            if type(v1290) == "nil" then
                v1290 = 0;
            end;
            if type(v1290) ~= "number" then
                return false;
            else
                return setElementData(v1287, v1290, v1289);
            end;
        end;
    end;
    giveElementStat = function(v1291, v1292, v1293) --[[ Line: 30 ]]
        if not isElement(v1291) or getElementType(v1291) ~= "player" and getElementType(v1291) ~= "team" then
            return false;
        else
            local v1294 = getElementData(v1291, v1292);
            if type(v1294) == "nil" then
                v1294 = 0;
            end;
            if type(v1294) ~= "number" then
                return false;
            else
                return setElementData(v1291, v1294, v1294 + v1293);
            end;
        end;
    end;
    addEventHandler("onPlayerDownloadComplete", root, onPlayerDownloadComplete);
end)();
(function(...) --[[ Line: 0 ]]
    local v1295 = {
        invulnerable = true, 
        invisible = true, 
        freezable = true, 
        flammable = true, 
        movespeed = true, 
        regenerable = true, 
        wallhack = true
    };
    setPlayerProperty = function(v1296, v1297, v1298) --[[ Line: 14 ]]
        -- upvalues: v1295 (ref)
        if not v1295[v1297] then
            return false;
        else
            local v1299 = getElementData(v1296, "Properties") or {};
            if v1298 ~= nil and v1298 ~= false then
                v1299[v1297] = v1298;
            else
                v1299[v1297] = nil;
            end;
            return setElementData(v1296, "Properties", v1299);
        end;
    end;
    givePlayerProperty = function(v1300, v1301, v1302, v1303) --[[ Line: 24 ]]
        -- upvalues: v1295 (ref)
        if not v1295[v1301] then
            return false;
        else
            local v1304 = getElementData(v1300, "Properties") or {};
            if v1302 ~= nil and v1302 ~= false then
                v1304[v1301] = {
                    v1302, 
                    v1303
                };
            else
                v1304[v1301] = nil;
            end;
            return setElementData(v1300, "Properties", v1304);
        end;
    end;
    getPlayerProperty = function(v1305, v1306) --[[ Line: 34 ]]
        -- upvalues: v1295 (ref)
        if not v1305 or not isElement(v1305) or not v1295[v1306] then
            return false;
        else
            local v1307 = getElementData(v1305, "Properties") or {};
            if type(v1307[v1306]) == "table" then
                return unpack(v1307[v1306]);
            else
                return v1307[v1306];
            end;
        end;
    end;
end)();
(function(...) --[[ Line: 0 ]]
    local v1308 = nil;
    local v1309 = {};
    local function v1312(v1310) --[[ Line: 9 ]]
        local v1311 = getResourceFromName(v1310.resname);
        if v1311 then
            setTacticsData(nil, "voting");
            if getTacticsData("Map") == "lobby" then
                startMap(v1311, "vote");
            elseif getTacticsData("automatics") == "voting" and winTimer == "voting" then
                startMap(v1311, "vote");
            else
                setTacticsData(v1310.resname, "ResourceNext");
                outputLangString(root, "map_set_next", v1310.label);
            end;
            return true;
        else
            return false;
        end;
    end;
    createVoting = function(v1313, v1314) --[[ Line: 25 ]]
        -- upvalues: v1308 (ref), v1309 (ref)
        local v1315 = getTacticsData("voting");
        if v1315 and v1315.finish and v1315.finish < getTickCount() then
            if isTimer(v1308) then
                killTimer(v1308);
            end;
            setTacticsData(nil, "voting");
        elseif not v1315 then
            local v1316 = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
            v1309 = {};
            for v1317 in ipairs(v1313) do
                table.insert(v1309, v1313[v1317].func);
                v1313[v1317].num = v1317;
            end;
            v1315 = {
                rows = v1313, 
                cancel = 0, 
                finish = getTickCount() + v1316 * 1000, 
                name = v1314
            };
            if isTimer(v1308) then
                killTimer(v1308);
            end;
            v1308 = setTimer(onVotingFinish, v1316 * 1000, 1, v1314);
            setTacticsData(v1315, "voting");
            return true;
        end;
        return false;
    end;
    stopVoting = function(v1318) --[[ Line: 45 ]]
        -- upvalues: v1308 (ref)
        if not getTacticsData("voting") or type(v1318) == "userdata" and not hasObjectPermissionTo(v1318, "general.tactics_maps", false) then
            return false;
        elseif type(v1318) == "string" and v1318 ~= getTacticsData("voting").name then
            return false;
        else
            if isTimer(v1308) then
                killTimer(v1308);
            end;
            setTacticsData(nil, "voting");
            outputLangString(root, "voting_canceled");
            return true;
        end;
    end;
    getVotingInfo = function() --[[ Line: 53 ]]
        return getTacticsData("voting") or {};
    end;
    onPlayerVote = function(v1319, v1320, v1321) --[[ Line: 56 ]]
        if source ~= client then return end
        -- upvalues: v1308 (ref), v1309 (ref), v1312 (ref)
        local v1322 = getElementType(source) == "player" and getPlayerName(source) or getElementType(source) == "team" and getTeamName(source) or "Console";
        local v1323 = getTacticsData("voting");
        if v1321 ~= nil and v1323 and v1321 ~= v1323.name then
            return;
        elseif v1323 and v1323.finish and v1323.finish < getTickCount() then
            if isTimer(v1308) then
                killTimer(v1308);
            end;
            return setTacticsData(nil, "voting");
        else
            if not v1319 then
                v1323 = getTacticsData("voting");
                if v1323 and v1323.rows and #v1323.rows > 0 and v1323.cancel then
                    if v1320 and v1320 > 0 then
                        v1323.rows[v1320].votes = v1323.rows[v1320].votes - 1;
                    end;
                    if v1320 == 0 then
                        v1323.cancel = v1323.cancel - 1;
                    end;
                    return setTacticsData(v1323, "voting");
                end;
            elseif type(v1319) == "table" then
                v1323 = getTacticsData("voting");
                local v1324 = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
                local v1325 = "";
                local v1326 = getTacticsData("map_disabled") or {};
                for _, v1328 in ipairs(v1319) do
                    local v1329, _ = unpack(v1328);
                    local v1331 = "";
                    local v1332 = "";
                    if string.find(v1329, "_") ~= nil then
                        v1332 = string.lower(string.sub(v1329, 1, string.find(v1329, "_") - 1));
                    end;
                    local v1333 = getResourceFromName(v1329);
                    if v1333 and #v1332 > 0 and getTacticsData("modes", v1332, "enable") ~= "false" and not v1326[v1329] then
                        v1331 = getResourceInfo(v1333, "name");
                        if not v1331 then
                            v1331 = string.sub(string.gsub(getResourceName(v1333), "_", " "), #v1332 + 2);
                            if #v1331 > 1 then
                                v1331 = string.upper(string.sub(v1331, 1, 1)) .. string.sub(v1331, 2);
                            end;
                        end;
                        v1331 = string.upper(string.sub(v1332, 1, 1)) .. string.sub(v1332, 2) .. ": " .. v1331;
                    elseif v1322 ~= "Console" then
                        outputLangString(source, "voting_notexist");
                        return;
                    end;
                    if v1323 and v1323.rows and #v1323.rows > 0 and v1323.cancel then
                        if #v1323.rows > 8 then
                            return;
                        else
                            for _, v1335 in ipairs(v1323.rows) do
                                if v1335[1] == v1329 then
                                    return;
                                end;
                            end;
                            table.insert(v1309, v1312);
                            table.insert(v1323.rows, {
                                resname = v1329, 
                                votes = 0, 
                                cteator = v1322, 
                                label = v1331, 
                                num = #v1309
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
                        v1323 = {
                            rows = {
                                {
                                    resname = v1329, 
                                    votes = 0, 
                                    creator = v1322, 
                                    label = v1331, 
                                    num = 1
                                }
                            }, 
                            cancel = 0, 
                            start = getTickCount() + v1324 * 1000, 
                            name = v1321
                        };
                        v1309 = {
                            v1312
                        };
                    end;
                    if #v1325 == 0 then
                        v1325 = v1331;
                    else
                        v1325 = v1325 .. ", " .. v1331;
                    end;
                end;
                if isTimer(v1308) then
                    killTimer(v1308);
                end;
                v1308 = setTimer(onVotingFinish, v1324 * 1000, 1);
                if v1322 ~= "Console" then
                    outputLangString(root, "voting_start", v1322, v1325);
                end;
                return setTacticsData(v1323, "voting");
            elseif type(v1319) == "string" then
                v1323 = getTacticsData("voting");
                local v1336 = "";
                local v1337 = "";
                if string.find(v1319, "_") ~= nil then
                    v1337 = string.lower(string.sub(v1319, 1, string.find(v1319, "_") - 1));
                end;
                local v1338 = getTacticsData("map_disabled") or {};
                local v1339 = getResourceFromName(v1319);
                if v1339 and #v1337 > 0 and getTacticsData("modes", v1337, "enable") ~= "false" and not v1338[v1319] then
                    v1336 = getResourceInfo(v1339, "name");
                    if not v1336 then
                        v1336 = string.sub(string.gsub(getResourceName(v1339), "_", " "), #v1337 + 2);
                        if #v1336 > 1 then
                            v1336 = string.upper(string.sub(v1336, 1, 1)) .. string.sub(v1336, 2);
                        end;
                    end;
                    v1336 = string.upper(string.sub(v1337, 1, 1)) .. string.sub(v1337, 2) .. ": " .. v1336;
                elseif v1322 ~= "Console" then
                    outputLangString(source, "voting_notexist");
                    return;
                end;
                if v1323 and v1323.rows and #v1323.rows > 0 and v1323.cancel then
                    if #v1323.rows > 8 then
                        return;
                    else
                        for _, v1341 in ipairs(v1323.rows) do
                            if v1341[1] == v1319 then
                                return;
                            end;
                        end;
                        table.insert(v1309, v1312);
                        table.insert(v1323.rows, {
                            resname = v1319, 
                            votes = 0, 
                            creator = v1322, 
                            label = v1336, 
                            num = #v1309
                        });
                        if v1322 ~= "Console" then
                            outputLangString(root, "voting_start", v1322, v1336);
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
                    local v1342 = TimeToSec(getTacticsData("settings", "vote_duration") or "0:20");
                    v1323 = {
                        rows = {
                            {
                                resname = v1319, 
                                votes = 0, 
                                creator = v1322, 
                                label = v1336, 
                                num = 1
                            }
                        }, 
                        cancel = 0, 
                        start = getTickCount() + v1342 * 1000, 
                        name = v1321
                    };
                    v1309 = {
                        v1312
                    };
                    if isTimer(v1308) then
                        killTimer(v1308);
                    end;
                    v1308 = setTimer(onVotingFinish, v1342 * 1000, 1);
                    if v1322 ~= "Console" then
                        outputLangString(root, "voting_start", v1322, v1336);
                    end;
                end;
                return setTacticsData(v1323, "voting");
            elseif type(v1319) == "number" then
                v1323 = getTacticsData("voting");
                if v1323 and v1323.rows and #v1323.rows > 0 and v1323.cancel and v1319 <= #v1323.rows then
                    if v1320 and v1320 > 0 then
                        v1323.rows[v1320].votes = v1323.rows[v1320].votes - 1;
                    end;
                    if v1320 == 0 then
                        v1323.cancel = v1323.cancel - 1;
                    end;
                    if v1319 > 0 then
                        v1323.rows[v1319].votes = v1323.rows[v1319].votes + 1;
                        if v1323.rows[v1319].votes > 0.5 * getPlayerCount() then
                            setTacticsData(v1323, "voting");
                            onVotingFinish();
                            return;
                        end;
                    else
                        v1323.cancel = v1323.cancel + 1;
                        if v1323.cancel > 0.5 * getPlayerCount() then
                            setTacticsData(v1323, "voting");
                            onVotingFinish();
                            return;
                        end;
                    end;
                    return setTacticsData(v1323, "voting");
                end;
            end;
            return;
        end;
    end;
    onVotingFinish = function() --[[ Line: 201 ]]
        -- upvalues: v1308 (ref), v1309 (ref)
        if isTimer(v1308) then
            killTimer(v1308);
        end;
        local v1343 = getTacticsData("voting");
        if v1343 and #v1343.rows > 0 and v1343.cancel then
            if #v1343.rows > 1 then
                table.sort(v1343.rows, function(v1344, v1345) --[[ Line: 206 ]]
                    return v1344.votes > v1345.votes;
                end);
            end;
            local v1346 = v1343.rows[1];
            if v1346.votes > 0 and v1346.votes > v1343.cancel and type(v1309[v1346.num]) == "function" then
                triggerEvent("onVotingResult", root, v1346);
                if v1309[v1346.num](v1346) then
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
    onPlayerPreview = function(v1347) --[[ Line: 222 ]]
        if source ~= client then return end
        if not hasObjectPermissionTo(getThisResource(), "general.ModifyOtherObjects", false) then
            triggerClientEvent(source, "onClientPreviewMapLoading", root, false, {});
            outputLangString(source, "resource_have_not_permissions", getResourceName(getThisResource()), "general.ModifyOtherObjects");
            return;
        else
            local v1348 = {};
            local v1349 = xmlLoadFile(":" .. v1347 .. "/meta.xml");
            for _, v1351 in ipairs(xmlNodeGetChildren(v1349)) do
                if xmlNodeGetName(v1351) == "map" then
                    local v1352 = xmlLoadFile(":" .. v1347 .. "/" .. xmlNodeGetAttribute(v1351, "src"));
                    for _, v1354 in ipairs(xmlNodeGetChildren(v1352)) do
                        table.insert(v1348, {
                            xmlNodeGetName(v1354), 
                            xmlNodeGetAttributes(v1354)
                        });
                    end;
                    xmlUnloadFile(v1352);
                end;
            end;
            xmlUnloadFile(v1349);
            local v1355 = false;
            local l_pairs_8 = pairs;
            local v1357 = getTacticsData("modes_defined") or {};
            for v1358 in l_pairs_8(v1357) do
                if string.find(v1347, v1358) == 1 then
                    v1355 = v1358;
                end;
            end;
            triggerClientEvent(source, "onClientPreviewMapLoading", root, v1355, v1348);
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
(function(...) --[[ Line: 0 ]]
    local v1359 = {};
    local v1360 = {};
    local v1361 = "";
    local v1362 = "";
    local v1363 = "";
    local v1364 = "";
    local v1365 = {
        Damage = true, 
        Kills = true, 
        Deaths = true
    };
    local v1366 = {};
    setRoundStatisticData = function(...) --[[ Line: 15 ]]
        -- upvalues: v1365 (ref)
        v1365 = {};
        for _, v1368 in ipairs({
            ...
        }) do
            if type(v1368) == "string" then
                v1365[v1368] = true;
            end;
        end;
        triggerClientEvent(root, "onClientStatisticChange", root, ...);
        return true;
    end;
    onMapStarting = function(v1369) --[[ Line: 26 ]]
        -- upvalues: v1359 (ref), v1361 (ref), v1366 (ref), v1363 (ref)
        v1359 = {};
        v1361 = "";
        v1366 = {};
        v1363 = v1369.name;
        local v1370 = getElementsByType("team");
        table.remove(v1370, 1);
        local v1371 = getTacticsData("Teamsides");
        local v1372 = getTacticsData("SideNames");
        local v1373 = getTacticsData("LogoLink") or "http://gta-rating.ru/forum/images/rml/";
        for _, v1375 in ipairs(v1370) do
            local v1376, v1377, v1378 = getTeamColor(v1375);
            table.insert(v1359, {
                name = getTeamName(v1375), 
                score = tonumber(getElementData(v1375, "Score")), 
                side = v1372[2 - v1371[v1375] % 2], 
                r = v1376, 
                g = v1377, 
                b = v1378, 
                players = {}, 
                image = nil
            });
            v1366[v1375] = #v1359;
            fetchRemote(v1373 .. getTeamName(v1375) .. ".png", onStatisticImageLoad, "", false, v1375);
        end;
    end;
    onStatisticImageLoad = function(v1379, v1380, v1381) --[[ Line: 51 ]]
        -- upvalues: v1366 (ref), v1359 (ref)
        if v1380 ~= 0 or not v1366[v1381] then
            return;
        else
            v1359[v1366[v1381]].image = v1379;
            return;
        end;
    end;
    outputRoundLog = function(v1382, v1383) --[[ Line: 55 ]]
        -- upvalues: v1361 (ref)
        v1361 = v1361 .. "\n";
        if not v1383 then
            local v1384 = 0;
            local v1385 = getTacticsData("timestart");
            if v1385 then
                v1384 = math.max(0, isRoundPaused() and v1385 or getTickCount() - v1385);
            end;
            local v1386 = MSecToTime(v1384, 0);
            v1361 = v1361 .. string.format("[%s] ", v1386);
        end;
        v1361 = v1361 .. removeColorCoding(v1382);
    end;
    onRoundStart = function() --[[ Line: 68 ]]
        -- upvalues: v1361 (ref), v1366 (ref), v1365 (ref), v1359 (ref)
        local v1387 = getRealTime();
        v1361 = string.format("[%02i:%02i - %i.%02i.%04i] Round start", v1387.hour, v1387.minute, v1387.monthday, v1387.month + 1, v1387.year + 1900);
        for _, v1389 in ipairs(getTacticsData("Sides")) do
            local v1390 = "";
            for _, v1392 in ipairs(getPlayersInTeam(v1389)) do
                if getPlayerGameStatus(v1392) == "Play" then
                    if not v1366[v1392] then
                        local v1393 = {
                            name = removeColorCoding(getPlayerName(v1392))
                        };
                        for v1394 in pairs(v1365) do
                            v1393[v1394] = 0;
                        end;
                        table.insert(v1359[v1366[v1389]].players, v1393);
                        v1366[v1392] = #v1359[v1366[v1389]].players;
                    end;
                    v1390 = v1390 .. ", " .. removeColorCoding(getPlayerName(v1392));
                end;
            end;
            outputRoundLog(getTeamName(v1389) .. ": " .. (#v1390 > 0 and string.sub(v1390, 3) or ""), true);
        end;
        outputRoundLog("", true);
    end;
    onRoundFinish = function(v1395, v1396, _) --[[ Line: 90 ]]
        -- upvalues: v1366 (ref), v1359 (ref), v1363 (ref), v1361 (ref), v1364 (ref), v1360 (ref), v1362 (ref)
        if v1395 then
            local v1398 = "";
            local v1399 = "";
            if type(v1395) == "table" then
                if type(v1395[1]) == "string" then
                    local l_v1395_0 = v1395;
                    local v1401 = table.remove(l_v1395_0, 1);
                    v1398 = string.format(getString(tostring(v1401)), unpack(l_v1395_0));
                else
                    local v1402 = v1395[4];
                    local l_v1395_1 = v1395;
                    table.remove(l_v1395_1, 1);
                    table.remove(l_v1395_1, 1);
                    table.remove(l_v1395_1, 1);
                    table.remove(l_v1395_1, 1);
                    v1398 = string.format(getString(tostring(v1402)), unpack(l_v1395_1));
                end;
            elseif type(v1395) == "string" then
                v1398 = getString(v1395);
                if #v1398 == 0 then
                    v1398 = tostring(v1395);
                end;
            else
                v1398 = tostring(v1395);
            end;
            if v1396 then
                if type(v1396) == "table" then
                    local l_v1396_0 = v1396;
                    local v1405 = table.remove(l_v1396_0, 1);
                    v1399 = string.format(getString(tostring(v1405)), unpack(l_v1396_0));
                elseif type(v1396) == "string" then
                    v1399 = getString(v1396);
                    if #v1399 == 0 then
                        v1399 = tostring(v1396);
                    end;
                else
                    v1399 = tostring(v1396);
                end;
                v1399 = " (" .. v1399 .. ")";
            end;
            outputRoundLog(v1398 .. v1399);
        end;
        local v1406 = getElementsByType("team");
        table.remove(v1406, 1);
        for _, v1408 in ipairs(v1406) do
            if v1366[v1408] then
                v1359[v1366[v1408]].score = tonumber(getElementData(v1408, "Score"));
            end;
        end;
        setTimer(callClientFunction, 1000, 1, root, "updateRoundStatistic", v1363, v1359, v1361);
        v1364 = v1363;
        v1360 = {
            unpack(v1359)
        };
        v1362 = v1361;
    end;
    onPlayerDownloadComplete = function() --[[ Line: 137 ]]
        -- upvalues: v1364 (ref), v1360 (ref), v1362 (ref)
        callClientFunction(source, "updateRoundStatistic", v1364, v1360, v1362, true);
    end;
    onElementDataChange = function(v1409, v1410) --[[ Line: 140 ]]
        -- upvalues: v1366 (ref), v1365 (ref), v1359 (ref)
        local v1411 = getElementType(source);
        if v1411 == "player" and v1409 == "Status" and getElementData(source, v1409) == "Play" and not v1366[source] then
            local v1412 = getPlayerTeam(source);
            if not v1366[v1412] then
                return;
            else
                local v1413 = {
                    name = removeColorCoding(getPlayerName(source))
                };
                for v1414 in pairs(v1365) do
                    v1413[v1414] = 0;
                end;
                table.insert(v1359[v1366[v1412]].players, v1413);
                v1366[source] = #v1359[v1366[v1412]].players;
            end;
        end;
        if (v1411 == "player" or v1411 == "team") and v1365[v1409] and v1366[source] then
            local v1415 = tonumber(getElementData(source, v1409));
            if type(v1415) == "number" and type(v1410) == "number" then
                v1415 = v1415 - v1410;
            else
                v1415 = 0;
            end;
            if v1411 == "team" then
                v1359[v1366[source]][v1409] = v1359[v1366[source]][v1409] + v1415;
            else
                local v1416 = getPlayerTeam(source);
                if v1366[v1416] then
                    v1359[v1366[v1416]].players[v1366[source]][v1409] = v1359[v1366[v1416]].players[v1366[source]][v1409] + v1415;
                end;
            end;
        end;
    end;
    onPlayerWasted = function(_, v1418, v1419, v1420) --[[ Line: 167 ]]
        local v1421 = nil;
        if v1418 then
            if v1418 ~= source then
                local v1422 = getElementType(v1418);
                if v1422 == "player" then
                    v1421 = getPlayerName(v1418) .. " killed " .. getPlayerName(source);
                elseif v1422 == "vehicle" then
                    v1421 = getPlayerName(getVehicleController(v1418)) .. " killed " .. getPlayerName(source) .. " (" .. getVehicleName(v1418) .. ")";
                end;
            else
                v1421 = getPlayerName(source) .. " committed suicide";
            end;
        else
            v1421 = getPlayerName(source) .. " died";
        end;
        if v1419 then
            local v1423 = getWeaponNameFromID(v1419);
            if v1423 then
                v1421 = v1421 .. " (" .. v1423 .. ")";
            end;
        end;
        if v1420 and getBodyPartName(v1420) then
            v1421 = v1421 .. " (" .. getBodyPartName(v1420) .. ")";
        end;
        outputRoundLog(removeColorCoding(v1421));
    end;
    onPauseToggle = function(v1424, v1425) --[[ Line: 197 ]]
        if v1424 then
            outputRoundLog("Game paused");
        else
            local v1426 = MSecToTime(v1425, 0);
            outputRoundLog(string.format("[+%s] Game unpaused", v1426), true);
        end;
    end;

    dataAntiChange = function(theKey, oldValue, newValue)
        if client and client ~= nil and source ~= nil then
            if getElementType(client) == "player" and getElementType(source) == "player" then
                if client ~= source then
                    if theKey == "spectateskin" and not hasObjectPermissionTo(client, "general.tactics_openpanel", false) then
                        setElementData(source, theKey, oldValue)
                    elseif theKey ~= "spectateskin" then
                        setElementData(source, theKey, oldValue)
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
