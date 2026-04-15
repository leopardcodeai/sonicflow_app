package com.sonicflow.app.ui

import com.sonicflow.beatengine.FlowMode

val FlowMode.label: String
    get() = when (this) {
        FlowMode.FOCUS -> "Focus"
        FlowMode.FLOW -> "Flow"
        FlowMode.MEDITATION -> "Meditation"
        FlowMode.SLEEP -> "Sleep"
    }

val FlowMode.accentColor: String
    get() = when (this) {
        FlowMode.FOCUS -> "#378ADD"
        FlowMode.FLOW -> "#7F77DD"
        FlowMode.MEDITATION -> "#1D9E75"
        FlowMode.SLEEP -> "#534AB7"
    }
