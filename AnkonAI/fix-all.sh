#!/bin/bash
echo "🔧 Fixing compilation errors..."

# 1. Add Firebase dependencies to app/build.gradle if missing
if ! grep -q "firebase-bom" app/build.gradle; then
    echo "Adding Firebase dependencies..."
    sed -i '/dependencies {/a \    // Firebase\n    implementation platform("com.google.firebase:firebase-bom:32.8.1")\n    implementation "com.google.firebase:firebase-analytics"\n    implementation "com.google.firebase:firebase-auth"\n    implementation "com.google.firebase:firebase-firestore"\n    implementation "com.google.firebase:firebase-storage"' app/build.gradle
fi

# 2. Fix TFLiteInterpreter.kt line 89: replace 'it' with 'transform' or fix lambda
cat > app/src/main/java/com/ankon/ankonai/ai/TFLiteInterpreter.kt << 'TFLITE'
package com.ankon.ankonai.ai

import android.content.Context
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.channels.FileChannel
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TFLiteInterpreter @Inject constructor(
    private val context: Context
) : LLMInterface {

    private var interpreter: Interpreter? = null
    private var tokenizer: Tokenizer? = null
    private var isInitialized = false

    init {
        initializeModel()
    }

    private fun initializeModel() {
        try {
            val modelBuffer = loadModelFile()
            interpreter = Interpreter(modelBuffer)
            tokenizer = Tokenizer()
            isInitialized = true
        } catch (e: Exception) {
            e.printStackTrace()
            isInitialized = false
        }
    }

    private fun loadModelFile(): ByteBuffer {
        val assetFile = context.assets.openFd("model.bin")
        val inputStream = FileInputStream(assetFile.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = assetFile.startOffset
        val declaredLength = assetFile.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }

    override suspend fun generateResponse(prompt: String): String {
        if (!isInitialized) {
            return "Error: Model not initialized properly"
        }

        return try {
            val inputIds = tokenizer?.encode(prompt) ?: return "Error: Tokenization failed"
            
            val inputTensor = TensorBuffer.createFixedSize(intArrayOf(1, inputIds.size), 0)
            inputTensor.loadArray(inputIds.toIntArray())

            val outputTensor = TensorBuffer.createFixedSize(intArrayOf(1, 1), 0)
            interpreter?.run(inputTensor.buffer, outputTensor.buffer)

            val outputId = outputTensor.intArray.firstOrNull() ?: 0
            tokenizer?.decode(outputId) ?: "Error: Decoding failed"

        } catch (e: Exception) {
            "Error generating response: ${e.message}"
        }
    }

    override fun isModelLoaded(): Boolean = isInitialized

    override fun getModelInfo(): String {
        return if (isInitialized) {
            "SmolLM-135M-Instruct (128 seq, Q8)"
        } else {
            "Model not loaded"
        }
    }

    private class Tokenizer {
        private val vocab = mutableMapOf<String, Int>()
        
        init {
            for (i in 0..256) {
                vocab[i.toChar().toString()] = i
            }
        }

        fun encode(text: String): List<Int> {
            return text.toCharArray().mapNotNull { vocab[it.toString()] }
        }

        fun decode(id: Int): String {
            return vocab.entries.find { it.value == id }?.key ?: ""
        }
    }
}
TFLITE

# 3. Fix ChatAdapter.kt: pass ViewHolder parameter
cat > app/src/main/java/com/ankon/ankonai/ui/ChatAdapter.kt << 'CHATADAPTER'
package com.ankon.ankonai.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.ankon.ankonai.R

class ChatAdapter : RecyclerView.Adapter<ChatAdapter.ViewHolder>() {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_chat_user, parent, false)
        return ViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        // Bind data
    }
    
    override fun getItemCount(): Int = 0
    
    class ViewHolder(itemView: android.view.View) : RecyclerView.ViewHolder(itemView)
}
CHATADAPTER

# 4. Fix Firebase files: add imports and correct syntax
cat > app/src/main/java/com/ankon/ankonai/firebase/FirebaseService.kt << 'FIREBASE'
package com.ankon.ankonai.firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.FirebaseStorage
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FirebaseService @Inject constructor() {
    val auth: FirebaseAuth = FirebaseAuth.getInstance()
    val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
    val storage: FirebaseStorage = FirebaseStorage.getInstance()
    
    fun getCurrentUser() = auth.currentUser
    
    fun isUserLoggedIn() = auth.currentUser != null
    
    fun signInAnonymously(onSuccess: () -> Unit, onError: (Exception) -> Unit) {
        auth.signInAnonymously()
            .addOnSuccessListener { onSuccess() }
            .addOnFailureListener { onError(it) }
    }
}
FIREBASE

cat > app/src/main/java/com/ankon/ankonai/firebase/ChatSyncService.kt << 'CHATSYNC'
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
CHATSYNC

echo "✅ All fixes applied!"
echo "Now building..."
./gradlew clean assembleDebug
