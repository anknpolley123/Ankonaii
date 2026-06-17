package com.ankon.ankonai.ui

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ankon.ankonai.ai.LLMInterface
import com.ankon.ankonai.data.ChatRepository
import com.ankon.ankonai.data.Message
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ChatViewModel @Inject constructor(
    private val repository: ChatRepository,
    private val llm: LLMInterface
) : ViewModel() {

    private val _messages = MutableStateFlow<List<Message>>(emptyList())
    val messages: StateFlow<List<Message>> = _messages.asStateFlow()

    private val _loadingState = MutableStateFlow(false)
    val loadingState: StateFlow<Boolean> = _loadingState.asStateFlow()

    private val _errorState = MutableStateFlow<String?>(null)
    val errorState: StateFlow<String?> = _errorState.asStateFlow()

    private val _imageState = MutableStateFlow<Uri?>(null)
    val imageState: StateFlow<Uri?> = _imageState.asStateFlow()

    init {
        loadChatHistory()
    }

    private fun loadChatHistory() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val history = repository.getChatHistory()
                _messages.value = history
            } catch (e: Exception) {
                _errorState.value = "Failed to load chat history"
            }
        }
    }

    fun sendMessage(content: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                _loadingState.value = true
                
                val userMessage = Message.createUserMessage(content)
                repository.saveMessage(userMessage)
                val currentMessages = _messages.value.toMutableList()
                currentMessages.add(userMessage)
                _messages.value = currentMessages

                val response = llm.generateResponse(content)
                
                val aiMessage = Message.createAIMessage(response)
                repository.saveMessage(aiMessage)
                val updatedMessages = _messages.value.toMutableList()
                updatedMessages.add(aiMessage)
                _messages.value = updatedMessages

            } catch (e: Exception) {
                _errorState.value = "Failed to generate response: ${e.message}"
            } finally {
                _loadingState.value = false
            }
        }
    }

    fun uploadImage(uri: Uri) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                _imageState.value = uri
                val message = Message.createUserMessage("📷 Image uploaded", imageUri = uri)
                repository.saveMessage(message)
                val currentMessages = _messages.value.toMutableList()
                currentMessages.add(message)
                _messages.value = currentMessages
                _imageState.value = null
            } catch (e: Exception) {
                _errorState.value = "Failed to upload image"
            }
        }
    }

    fun clearChat() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                repository.clearChatHistory()
                _messages.value = emptyList()
            } catch (e: Exception) {
                _errorState.value = "Failed to clear chat"
            }
        }
    }

    fun clearError() {
        _errorState.value = null
    }
}