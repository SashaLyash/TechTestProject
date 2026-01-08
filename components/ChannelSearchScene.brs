
' Scene Component Implementation

' init: Initializes the scene component
' Sets up UI elements, loads channel data, and normalizes for search
sub init()
    initUI()
    addObservers()
    setFocus()
    initializeDebounceTimer()

    if m.top.channels <> invalid
        loadChannels()
        normalizeChannels()
    end if
end sub

' initUI: Initializes UI components
sub initUI()
    m.top.backgroundColor = "0x000000FF"
    m.searchButton = m.top.FindNode("searchButton")
    m.searchKeyboard = m.top.FindNode("searchKeyboard")
    m.searchTermLabel = m.top.FindNode("searchTermLabel")
    m.resultsCountLabel = m.top.FindNode("resultsCountLabel")
    m.channelList = m.top.FindNode("channelList")
end sub

' addObservers: Attaches event observers to UI components
sub addObservers()
    m.searchButton.ObserveField("buttonSelected", "onSearchButtonPressed")
    m.searchKeyboard.ObserveField("buttonSelected", "onKeyboardButtonSelected")
    m.searchKeyboard.ObserveField("text", "onKeyboardTextChanged")
    m.top.ObserveField("channels", "onChannelsSet")
end sub

' onChannelsSet: Called when channels field is set from Main.brs
sub onChannelsSet(event as object)
    loadChannels()
    normalizeChannels()
end sub

' setFocus: Sets initial focus on UI components
sub setFocus()
    m.searchButton.SetFocus(true)
end sub

' loadChannels: Loads channel data from scene field set by Main.brs
sub loadChannels()
    m.channels = m.top.channels
    if m.channels = invalid
        m.channels = []
    end if
end sub

' normalizeChannels: Pre-normalizes channel titles to lowercase
' This optimization allows case-insensitive search without repeated LCase() calls
' Performed once during initialization for optimal performance
' Stores index reference to original channel for memory-efficient result returns
sub normalizeChannels()
    m.normalizedChannels = []
    if m.channels = invalid or m.channels.Count() = 0
        return
    end if
    index = 0
    for each channel in m.channels
        m.normalizedChannels.Push({
            index: index
            normalizedTitle: LCase(channel.title)
        })
        index = index + 1
    end for
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    return false
end function

' Search Logic
' Case-insensitive search on title and category fields
' Uses linear search with pre-normalized strings for optimal performance
'
' Performance Notes:
' - Algorithm: Linear search (O(n)) where n = number of channels
' - Why Linear Search?
'   1. Roku devices have limited CPU - complex algorithms (trees, hashing)
'      have higher overhead than simple iteration
'   2. Memory is constrained - pre-computed indexes would consume valuable RAM
'   3. For 5,000 items, linear search completes imperceptibly to users
'   4. Simple code = fewer bugs and easier maintenance
' - Optimizations:
'   - Pre-normalized strings (LCase done once during init, not per search)
'   - Single pass through channels checking both title and category
'   - Early exit for empty search terms
'   - Minimal object creation during search



' searchChannels: Performs case-insensitive search on title and category
'
' Requirements: Filters by title and category fields (case-insensitive)
' Returns all channels if search term is empty (consistent data structure)
'
' Memory Optimization: Returns references to existing channel objects
' instead of creating new objects, reducing garbage collection overhead
'
' searchTerm - Search query string
'
' Returns: Array of channel object references (same structure for empty/filtered)
function searchChannels(searchTerm as string) as object
    results = []

    if m.channels = invalid or m.normalizedChannels = invalid
        return results
    end if

    normalizedSearchTerm = LCase(searchTerm)

    if normalizedSearchTerm = ""
        return m.channels
    end if

    for each normalizedChannel in m.normalizedChannels
        channel = m.channels[normalizedChannel.index]

        ' Match by title
        if Instr(1, normalizedChannel.normalizedTitle, normalizedSearchTerm) > 0
            results.Push(channel)
            continue for
        end if

        ' Match by category name
        if channel.category <> invalid and channel.category.name <> invalid
            normalizedCategory = LCase(channel.category.name)
            if Instr(1, normalizedCategory, normalizedSearchTerm) > 0
                results.Push(channel)
                continue for
            end if
        end if

        ' Match by subCategory name
        if channel.category <> invalid and channel.category.subCategory <> invalid and channel.category.subCategory.name <> invalid
            normalizedSubCategory = LCase(channel.category.subCategory.name)
            if Instr(1, normalizedSubCategory, normalizedSearchTerm) > 0
                results.Push(channel)
                continue for
            end if
        end if

        ' Match by subSubCategory name
        if channel.category <> invalid and channel.category.subCategory <> invalid and channel.category.subCategory.subCategory <> invalid and channel.category.subCategory.subCategory.name <> invalid
            normalizedSubSubCategory = LCase(channel.category.subCategory.subCategory.name)
            if Instr(1, normalizedSubSubCategory, normalizedSearchTerm) > 0
                results.Push(channel)
                continue for
            end if
        end if
    end for

    return results
end function


' initializeDebounceTimer: Creates debounce timer once during initialization
' Timer is reused by stopping and restarting, preventing garbage collection overhead
sub initializeDebounceTimer()
    m.debounceTimer = CreateObject("roSGNode", "Timer")
    m.debounceTimer.duration = 0.3
    m.debounceTimer.repeat = false
    m.debounceTimer.ObserveField("fire", "onDebounceTimerFired")
    m.pendingSearchTerm = invalid
end sub

' searchDebounced: Implements debounce mechanism to prevent excessive processing
'
' Requirements: Debounce to prevent excessive processing during typing
' Cancels previous timer if new search comes in quickly (300ms delay)
' Prevents UI blocking during quick typing
'
' Timer Lifecycle Optimization: Reuses existing timer by stopping and restarting
' instead of creating new Timer nodes, preventing garbage collection overhead
'
' searchTerm - Search query string
sub searchDebounced(searchTerm as string)
    if m.debounceTimer = invalid
        return
    end if
    m.debounceTimer.control = "stop"
    m.pendingSearchTerm = searchTerm
    m.debounceTimer.control = "start"
end sub

' onDebounceTimerFired: Event handler for debounce timer
' Executes the pending search when timer fires after debounce delay
' Timer remains valid for reuse in subsequent searches
sub onDebounceTimerFired(event as object)
    if m.pendingSearchTerm <> invalid
        searchTerm = m.pendingSearchTerm
        m.pendingSearchTerm = invalid
        updateChannelList(searchChannels(searchTerm))
    end if
end sub

' onSearchButtonPressed: Handles search button press event
' Shows the keyboard dialog for user input
sub onSearchButtonPressed(event as object)
    m.searchKeyboard.visible = true
    m.searchKeyboard.text = ""
    m.searchKeyboard.SetFocus(true)
end sub

' onKeyboardButtonSelected: Handles keyboard dialog button selection
' Button 0 = Search, triggers immediate search
sub onKeyboardButtonSelected(event as object)
    if event.GetData() = 0
        performSearch(m.searchKeyboard.text)
    end if
    m.searchKeyboard.visible = false
    m.searchButton.SetFocus(true)
end sub

' onKeyboardTextChanged: Handles text input changes in keyboard dialog
' Updates search term display and triggers debounced search as user types
' Shows all channels if search term is cleared
sub onKeyboardTextChanged(event as object)
    searchTerm = event.GetData()
    m.searchTermLabel.text = "Search Term: " + searchTerm

    if m.channels = invalid or m.normalizedChannels = invalid
        return
    end if

    if searchTerm <> ""
        searchDebounced(searchTerm)
    else
        updateChannelList(m.channels)
    end if
end sub

' performSearch: Executes immediate search without debounce
' Used when user explicitly presses the Search button
sub performSearch(searchTerm as string)
    if m.channels = invalid or m.normalizedChannels = invalid
        return
    end if

    m.searchTermLabel.text = "Search Term: " + searchTerm
    updateChannelList(searchChannels(searchTerm))
end sub

' updateChannelList: Updates the UI with search results
' Limits display to 50 items for performance, shows count of remaining if more exist
sub updateChannelList(channels as object)
    if channels = invalid
        channels = []
    end if

    m.resultsCountLabel.text = "Results: " + channels.Count().ToStr()

    contentNode = CreateObject("roSGNode", "ContentNode")

    if channels.Count() = 0
        m.channelList.content = contentNode
        return
    end if

    maxDisplay = 50
    endIndex = maxDisplay - 1
    if channels.Count() < maxDisplay
        endIndex = channels.Count() - 1
    end if

    for i = 0 to endIndex
        channel = channels[i]
        itemNode = contentNode.CreateChild("ContentNode")

        ' Build category display string from nested category structure
        categoryDisplay = ""
        if channel.category <> invalid and channel.category.name <> invalid
            categoryDisplay = channel.category.name
        end if

        displayText = channel.title
        if categoryDisplay <> ""
            displayText = displayText + " (" + categoryDisplay + ")"
        end if

        itemNode.title = displayText
    end for

    if channels.Count() > maxDisplay
        itemNode = contentNode.CreateChild("ContentNode")
        itemNode.title = "... and " + (channels.Count() - maxDisplay).ToStr() + " more results"
    end if

    m.channelList.content = contentNode
end sub
