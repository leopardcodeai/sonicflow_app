package com.sonicflow.app.di

import com.sonicflow.app.audio.AudioServiceController
import com.sonicflow.app.audio.FlowTonesSessionController
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class AudioModule {
    @Binds
    @Singleton
    abstract fun bindFlowTonesController(controller: AudioServiceController): FlowTonesSessionController
}
