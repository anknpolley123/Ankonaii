package com.ankon.ankonai.data

import android.net.Uri
import java.util.UUID

data class Message(
    val id: String = UUID.randomUUID().toString(),
    val content: String,
    val type: Type,
    val timestamp: Long = System.currentTimeMillis(),
    val imageUri: Uri? = null
) {
    enum class Type {
        USER, AI
    }

    companion object {
        fun createUserMessage(content: String, imageUri: Uri? = null): Message {
            return Message(
                content = content,
                type = Type.USER,
                imageUri = imageUri
            )
        }

        fun createAIMessage(content: String): Message {
            return Message(
                content = content,
                type = Type.AI
            )
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Message

        if (id != other.id) return false
        if (content != other.content) return false
        if (type != other.type) return false
        if (timestamp != other.timestamp) return false
        if (imageUri != other.imageUri) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + content.hashCode()
        result = 31 * result + type.hashCode()
        result = 31 * result + timestamp.hashCode()
        result = 31 * result + (imageUri?.hashCode() ?: 0)
        return result
    }
}