script BrowserBridge
    
    property parent : class "NSObject"
    property b_list : class "Array"
            
    to runBlockBrowser:isFocusing

        set urls to blist as list -- {"yahoo.com", "facebook.com", "instagram.com"}
        log(urls)
        tell application "System Events" to set activeApp to get the name of every process whose background only is false
        set val to isFocusing
        
        repeat until val is false
            if "Safari" is in activeApp then
                if application "Safari" is running then
                    (* repeat until application "Safari" is not running *)
                    tell application "Safari"
                        repeat with theURL in urls
                            set (URL of every tab of every window where URL contains (contents of theURL)) to "http://127.0.0.1"
                        end repeat
                        delay 0.9
                    end tell
                    (* end repeat *)
                end if
            end if
            if "Google Chrome" is in activeApp then
                if application "Google Chrome" is running then
                    (* repeat until application "Google Chrome" is not running *)
                    tell application "Google Chrome"
                        repeat with theURL in urls
                            set (URL of every tab of every window where URL contains (contents of theURL)) to "http://127.0.0.1"
                        end repeat
                        delay 0.9
                    end tell
                    (* end repeat *)
                end if
            end if
        end repeat

    end runBlockBrowser

end script
