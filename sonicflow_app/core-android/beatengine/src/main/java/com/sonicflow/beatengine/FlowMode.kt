package com.sonicflow.beatengine

enum class FlowMode(val beatHz: Int, val carrierHz: Int) {
    FOCUS(40, 200),
    FLOW(10, 200),
    MEDITATION(6, 180),
    SLEEP(2, 150)
}
