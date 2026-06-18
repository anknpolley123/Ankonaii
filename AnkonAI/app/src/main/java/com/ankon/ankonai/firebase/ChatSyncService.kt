package com.ankon.ankonai.firebase

import com.ankon.ankonai.data.Message
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ChatSyncService @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    private val CHATS_COLLECTION = "chats"
    
    suspend fun saveChatMessage(userId: String, message: Message) {
        val data = mapOf(
            "id" to message.id,
            "content" to message.content,
            "type" to message.type.name,
            "timestamp" to message.timestamp,
            "imageUri" to message.imageUri?.toString()
        )
        
        firestore.collection(CHATS_COLLECTION)
            .document(userId)
            .collection("messages")
            .document(message.id)
            .set(data)
            .await()
    }
    
    suspend fun getChatHistory(userId: String): List<Message> {
        val snapshot = firestore.collection(CHATS_COLLECTION)
            .document(userId)
            .collection("messages")
            .orderBy("timestamp")
            .get()
            .await()
        
        return snapshot.documents.mapNotNull { doc ->
            val content = doc.getString("content") ?: return@mapNotNull null
            val typeStr = doc.getString("type") ?: return@mapNotNull null
            val type = if (typeStr == "USER") Message.Type.USER else Message.Type.AI
            val timestamp = doc.getLong("timestamp") ?: System.currentTimeMillis()
            
            Message(
                id = doc.id,
                content = content,
                type = type,
                timestamp = timestamp
            )
        }
    }
    
    suspend fun clearChatHistory(userId: String) {
        val messages = firestore.collection(CHATS_COLLECTION)
            .document(userId)
            .collection("messages")
            .get()
            .await()
        
        for (doc in messages.documents) {
            doc.reference.delete().await()
        }
    }
}
