package com.ankon.ankonai.ai

import android.content.Context
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TFLiteInterpreter @Inject constructor(
    private val context: Context
) : LLMInterface {

    private var isInitialized = true  // Always return true for dummy

    override suspend fun generateResponse(prompt: String): String {
        // Dummy response - replace with real inference later
        return "Hello from AnkonAI! (Offline mode)\nYou asked: \"$prompt\""
    }

    override fun isModelLoaded(): Boolean = isInitialized

    override fun getModelInfo(): String {
        return "SmolLM-135M-Instruct (dummy implementation)"
    }
}
