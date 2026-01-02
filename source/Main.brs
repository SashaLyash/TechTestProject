sub Main()
    ' Load channels from JSON file
    jsonString = ReadAsciiFile("pkg:/resources/channels.json")
    channels = ParseJson(jsonString)
    if channels = invalid
        channels = []
    end if

    ' Create the Scene
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' Create the Scene Graph scene
    scene = screen.CreateScene("ChannelSearchScene")
    scene.channels = channels
    screen.show()

    ' Event loop
    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then exit while
        end if
    end while
end sub
