package com.ankon.ankonai.ai

interface LLMInterface {
    suspend fun generateResponse(prompt: String): String
    fun isModelLoaded(): Boolean
    fun getModelInfo(): String
}