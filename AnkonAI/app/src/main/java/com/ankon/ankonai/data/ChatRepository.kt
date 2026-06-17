package com.ankon.ankonai.data

import android.net.Uri
import androidx.room.withTransaction
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ChatRepository @Inject constructor(
    private val database: ChatDatabase
) {
    private val messageDao = database.messageDao()

    suspend fun saveMessage(message: Message) {
        database.withTransaction {
            messageDao.insert(MessageEntity.fromMessage(message))
        }
    }

    suspend fun getChatHistory(): List<Message> {
        return messageDao.getAllMessages().map { it.toMessage() }
    }

    suspend fun clearChatHistory() {
        database.withTransaction {
            messageDao.deleteAll()
        }
    }
}