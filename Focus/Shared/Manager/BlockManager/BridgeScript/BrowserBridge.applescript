-- Copyright 2020 Raising the Floor - International

-- Licensed under the New BSD license. You may not use this file except in
-- compliance with this License.

-- You may obtain a copy of the License at
-- https://github.com/GPII/universal/blob/master/LICENSE.txt

-- The R&D leading to these results received funding from the:
-- * Rehabilitation Services Administration, US Dept. of Education under
--   grant H421A150006 (APCP)
-- * National Institute on Disability, Independent Living, and
--   Rehabilitation Research (NIDILRR)
-- * Administration for Independent Living & Dept. of Education under grants
--   H133E080022 (RERC-IT) and H133E130028/90RE5003-01-00 (UIITA-RERC)
-- * European Union's Seventh Framework Programme (FP7/2007-2013) grant
--   agreement nos. 289016 (Cloud4all) and 610510 (Prosperity4All)
-- * William and Flora Hewlett Foundation
-- * Ontario Ministry of Research and Innovation
-- * Canadian Foundation for Innovation
-- * Adobe Foundation
-- * Consumer Electronics Association Foundation

script BrowserBridge
    
    property parent : class "NSObject"
    property b_list : {}
    property app_list : {}
    property isFocusing_status: boolean
    global isFocusing
    property block_url : "https://morphic.org/websiteblocked"
    
    -- block the blocklist page in browser
    on runBlockBrowser()
        
        set urls to b_list as list
        log (urls)
        set isFocusing to true
        
        repeat until isFocusing is false
            log("Script Running :::::::")
--            log("urls :::::::  " & urls)
--            log("isFocusing :::::::  " & isFocusing)
                if application "Safari" is running then
                    log("isFocusing :::::::  " & isFocusing)
                    tell application "Safari"
                        set theWindows to windows
                        repeat with theWindow in theWindows
                            set theTabs to tabs of theWindow
--                            log("theTabs :::::::  " & theTabs)
                            repeat with t_info in theTabs
                                set url_name to URL of t_info
--                                                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--                                                                set domainName to split(url_name, "/")
--                                log("t_info :::::::  " & url_name)
                                
                                set AppleScript's text item delimiters to "/"
                                set split_item to url_name's text items
                                set AppleScript's text item delimiters to {""} --> restore delimiters to default value
                                set domainName to split_item's item 3
--                                log("domainName :::::::  " & domainName)
                                repeat with b_url in urls
                                    if domainName contains b_url then
                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
                                        exit repeat
                                    end if
                                end repeat
                            end repeat
                        end repeat
                    end tell
                end if
--                log("Out Side IFFF isFocusing :::::::  " & isFocusing)
--                if application "Google Chrome" is running then
--                    tell application "Google Chrome"
--                        set theWindows to windows
--                        repeat with theWindow in theWindows
--                            set theTabs to tabs of theWindow
--                            repeat with t_info in theTabs
--                                set url_name to URL of t_info
--                                --                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--                                --                                set domainName to split(url_name, "/")
--                                set AppleScript's text item delimiters to "/"
--                                set split_item to url_name's text items
--                                set AppleScript's text item delimiters to {""} --> restore delimiters to default value
--                                set domainName to split_item's item 3
----                                log("Domain Name :::::::  " & domainName)
--                                repeat with b_url in urls
--                                    if b_url contains domainName then
--                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
--                                        exit repeat
--                                    end if
--                                end repeat
--                            end repeat
--                        end repeat
--                    end tell
--                end if
--
--                if application "Opera" is running then
--                    tell application "Opera"
--                        set theWindows to windows
--                        repeat with theWindow in theWindows
--                            set theTabs to tabs of theWindow
--                            repeat with t_info in theTabs
--                                set url_name to URL of t_info
--                                --                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--
--                                set AppleScript's text item delimiters to "/"
--                                set split_item to url_name's text items
--                                set AppleScript's text item delimiters to {""} --> restore delimiters to default value
--                                set domainName to split_item's item 3
----                                log("Domain Name :::::::  " & domainName)
--                                repeat with b_url in urls
--                                    if b_url contains domainName then
--                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
--                                        exit repeat
--                                    end if
--                                end repeat
--                            end repeat
--                        end repeat
--                    end tell
--                end if
--
--                if application "Brave Browser" is running then
--                    tell application "Brave Browser"
--                        set theWindows to windows
--                        repeat with theWindow in theWindows
--                            set theTabs to tabs of theWindow
--                            repeat with t_info in theTabs
--                                set url_name to URL of t_info
--                                --                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--
--                                set AppleScript's text item delimiters to "/"
--                                set split_item to url_name's text items
--                                set AppleScript's text item delimiters to {""} --> restore delimiters to default value
--                                set domainName to split_item's item 3
----                                log("Domain Name :::::::  " & domainName)
--                                repeat with b_url in urls
--                                    if b_url contains domainName then
--                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
--                                        exit repeat
--                                    end if
--                                end repeat
--                            end repeat
--                        end repeat
--                    end tell
--                end if
--
--                if application "Vivaldi" is running then
--                    tell application "Vivaldi"
--                        set theWindows to windows
--                        repeat with theWindow in theWindows
--                            set theTabs to tabs of theWindow
--                            repeat with t_info in theTabs
--                                set url_name to URL of t_info
--                                --                                set domainName to (do shell script "echo  " & url_name & " | cut -d'/' -f3")
--                                set AppleScript's text item delimiters to "/"
--                                set split_item to url_name's text items
--                                set AppleScript's text item delimiters to {""} --> restore delimiters to default value
--                                set domainName to split_item's item 3
----                                log("Domain Name :::::::  " & domainName)
--                                repeat with b_url in urls
--                                    if b_url contains domainName then
--                                        set (URL of every tab of every window where URL contains (url_name)) to block_url
--                                        exit repeat
--                                    end if
--                                end repeat
--                            end repeat
--                        end repeat
--                    end tell
--                end if
            
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
    
    -- Method to stop block script
    on stopScript()
        log ("Stop Script")
        set isFocusing to false
    end stopScript
    
    -- Method to split the String
    to split(urlStr, delimiter)
        set AppleScript's text item delimiters to delimiter
        set split_item to urlStr's text items
        set AppleScript's text item delimiters to {""} --> restore delimiters to default value
        return split_item's item 3
    end split
    
    
    -- Method to stop block script
    on blockApplication()
        log ("Block Application")
        repeat until isFocusing is false
            repeat with thisApp in app_list
                tell application thisApp to quit
            end repeat
        end repeat
        return true
    end blockApplication
    
    -- Method to Display Logout Dialogue
    on logoutAlert()
        log("Logout")
        tell application "System Events" to log out
    end logoutAlert
        
    on launchMyApp()
--        tell application "Focus" to quit
        tell application "Focus" to launch
    end launchMyApp
    
end script
