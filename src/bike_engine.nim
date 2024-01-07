import playdate/api
import utils

const
    idleRpm = 1300.0f
    ## The RPM of the first throttle sound in throttlePlayers. The second throttle sound is 200 RPM higher.
    baseThrottleRpm: float = 1700.0f

var 
    idlePlayer: SamplePlayer
    curRpm: float = idleRpm
    throttlePlayer: SamplePlayer
    currentPlayer: SamplePlayer
    targetPlayer: SamplePlayer
    fadeoutPlayer: SamplePlayer

proc initBikeEngine*()=
    try:
        idlePlayer = playdate.sound.newSamplePlayer("/audio/engine/1300rpm_idle")
        throttlePlayer = playdate.sound.newSamplePlayer("/audio/engine/1700rpm_throttle")
    except:
        print(getCurrentExceptionMsg())

    currentPlayer = idlePlayer
    currentPlayer.play(0, 1.0f)

proc updateBikeEngine*(throttle: bool, wheelAngularVelocity: float) =
    let targetRpm = 
        if throttle: 
            1300.0f + (wheelAngularVelocity * 100.0f) 
        else: 
            idleRpm

    curRpm = lerp(curRpm, targetRpm, 0.1f)
    print("RPM: " & $curRpm)
    targetPlayer = if throttle: throttlePlayer else: idlePlayer
    if currentPlayer != targetPlayer:
        # print("switch from currentPlayer: " & $currentPlayer.repr & " targetPlayer: " & targetPlayer.repr)
        fadeoutPlayer = currentPlayer
        currentPlayer = targetPlayer
        currentPlayer.play(0, 1.0f) # rate and volume is set below

    # rate
    let playerBaseRpm: float = 
        if throttle: 
            baseThrottleRpm
        else:
            idleRpm
    currentPlayer.rate=curRpm / playerBaseRpm

    # volume
    if currentPlayer.volume.left < 1.0f:
        currentPlayer.volume = min(1.0f, currentPlayer.volume.left + 0.1f)
    if fadeoutPlayer != nil:
        print("fadeoutPlayer volume: " & $fadeoutPlayer.volume.left & " currentPlayer volume: " & $currentPlayer.volume.left)
        if fadeoutPlayer.volume.left > 0.0f:
            fadeoutPlayer.volume = max(0.0f, fadeoutPlayer.volume.left - 0.1f)
        else:
            fadeoutPlayer.stop()
            fadeoutPlayer = nil

    # print("playerBaseRpm: " & $playerBaseRpm & "throttlePlayerIndex" & " rate: " & $currentPlayer.rate)
