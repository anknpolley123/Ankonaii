package com.ankon.ankonai.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import android.net.Uri

@Entity(tableName = "messages")
data class MessageEntity(
    @PrimaryKey
    val id: String,
    val content: String,
    val type: String,
    val timestamp: Long,
    val imageUri: String? = null
) {
    fun toMessage(): Message {
        return Message(
            id = id,
            content = content,
            type = if (type == "USER") Message.Type.USER else Message.Type.AI,
            timestamp = timestamp,
            imageUri = imageUri?.let { Uri.parse(it) }
        )
    }

    companion object {
        fun fromMessage(message: Message): MessageEntity {
            return MessageEntity(
                id = message.id,
                content = message.content,
                type = if (message.type == Message.Type.USER) "USER" else "AI",
                timestamp = message.timestamp,
                imageUri = message.imageUri?.toString()
            )
        }
    }
}