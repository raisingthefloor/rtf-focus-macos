script BrowserBridge
    
    property parent : class "NSObject"
    property b_list : {}
    global isFocusing
    property block_url : "http://127.0.0.1"
    
    -- block the blocklist page in browser
    on runBlockBrowser()
        
        set urls to b_list as list
        log (urls)
        
        tell application "System Events" to set activeApp to get the name of every process whose background only is false
        
        set isFocusing to true
        
        repeat until isFocusing is false
            if "Safari" is in activeApp then
                if application "Safari" is running then
                    tell application "Safari"
                        repeat with theURL in urls
                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
                        end repeat
                    end tell
                end if
            end if
            if "Google Chrome" is in activeApp then
                if application "Google Chrome" is running then
                    
                    tell application "Google Chrome"
                        repeat with theURL in urls
                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
                        end repeat
                    end tell

--                    tell application "Google Chrome"
--                        set theWindows to windows
--                        repeat with theWindow in theWindows
--                            set theTabs to tabs of theWindow
--                            repeat with t_info in theTabs
--                                set url_name to URL of t_info
--                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--                                repeat with b_url in urls
--                                    if b_url contains domainName then
--                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
--                                        exit repeat
--                                    end if
--                                end repeat
--                            end repeat
--                        end repeat
--                    end tell

--                    tell application "Google Chrome"
--                        repeat with theURL in urls
--                            log(URL of every tab of every window)
--                            set theDomain to (do shell script "echo " & URL of every tab of every window & " | awk -F/ '{print $3}' $1") as list
--                            log(theDomain)
--                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
--                        end repeat
--                    end tell
                end if
            end if
            
            
            
            
            if "Opera" is in activeApp then
                if application "Opera" is running then
                    tell application "Opera"
                        set theWindows to windows
                        repeat with theWindow in theWindows
                            set theTabs to tabs of theWindow
                            repeat with t_info in theTabs
                                set url_name to URL of t_info
                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
                                repeat with b_url in urls
                                    if b_url contains domainName then
                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
                                        exit repeat
                                    end if
                                end repeat
                            end repeat
                        end repeat
--                        repeat with theURL in urls
--                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
--                        end repeat
                    end tell
                end if
            end if
            if "Brave Browser" is in activeApp then
                if application "Brave Browser" is running then
                    tell application "Brave Browser"
                        set theWindows to windows
                        repeat with theWindow in theWindows
                            set theTabs to tabs of theWindow
                            repeat with t_info in theTabs
                                set url_name to URL of t_info
                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
                                repeat with b_url in urls
                                    if b_url contains domainName then
                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
                                        exit repeat
                                    end if
                                end repeat
                            end repeat
                        end repeat
--                        repeat with theURL in urls
--                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
--                        end repeat
                    end tell
                end if
            end if
            if "Vivaldi" is in activeApp then
                if application "Vivaldi" is running then
                    tell application "Vivaldi"
                        set theWindows to windows
                        repeat with theWindow in theWindows
                            set theTabs to tabs of theWindow
                            repeat with t_info in theTabs
                                set url_name to URL of t_info
                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
                                repeat with b_url in urls
                                    if b_url contains domainName then
                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
                                        exit repeat
                                    end if
                                end repeat
                            end repeat
                        end repeat
--                        repeat with theURL in urls
--                            set (URL of every tab of every window where URL contains (contents of theURL)) to block_url
--                        end repeat
                    end tell
                end if
            end if

        end repeat
        
    end runBlockBrowser
        
    -- To revert the previous page of browser
    on runUnblockBrowser()
                
        tell application "System Events" to set activeApp to get the name of every process whose background only is false
        
            if "Safari" is in activeApp then
                if application "Safari" is running then
                    tell application "Safari"
                        do JavaScript "history.back()" in every tab of every window
                    end tell
                end if
            end if
            if "Google Chrome" is in activeApp then
                if application "Google Chrome" is running then
                    tell application "Google Chrome"
        --                execute javascript "history.go(-1)" in every tab of every window
                    end tell
                end if
            end if
        
    end runUnblockBrowser

    on stopScript()
        log("Stop Script")
        set isFocusing to false
    end stopScript
    
    
--    on isUIScriptingOn()
--        tell application "System Events" to set isUIScriptingEnabled to UI elements enabled
--        return isUIScriptingEnabled
--    end isUIScriptingOn
--
--    on turnUIScriptingOn(switch)
--        tell application "System Events"
--            activate
--            set UI elements enabled to switch
--        end tell
--    end turnUIScriptingOn
--
--    on runPermission()
--        if not isUIScriptingOn() then
--            display dialog "Enable Access for assistive devices (found in the Universal Access System Preference) must be on for this software to correctly work. This program will enable this setting for you"
--            turnUIScriptingOn(true)
--            display dialog "Access for assistive devices in now on"
--        end if
--    end runPermission
    
end script
