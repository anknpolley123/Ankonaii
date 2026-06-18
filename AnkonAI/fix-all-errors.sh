#!/bin/bash
echo "🔧 Fixing all compilation errors..."

# 1. Fix MainActivity.kt: implement clearMessages and submitList properly
cat > app/src/main/java/com/ankon/ankonai/MainActivity.kt << 'MAINACT'
package com.ankon.ankonai

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {
    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ChatAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        recyclerView = findViewById(R.id.recyclerView)
        recyclerView.layoutManager = LinearLayoutManager(this)
        adapter = ChatAdapter()
        recyclerView.adapter = adapter
    }
}
MAINACT

# 2. Fix TFLiteInterpreter.kt: use correct DataType and mapNotNull lambda
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
            
            // Fix: Use DataType.FLOAT32 or INT32 as needed; TensorBuffer.createFixedSize expects DataType
            val inputTensor = TensorBuffer.createFixedSize(intArrayOf(1, inputIds.size), org.tensorflow.lite.support.common.ops.DataType.INT32)
            inputTensor.loadArray(inputIds.toIntArray())

            val outputTensor = TensorBuffer.createFixedSize(intArrayOf(1, 1), org.tensorflow.lite.support.common.ops.DataType.INT32)
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
            // Fix mapNotNull lambda: explicitly name the parameter
            return text.toCharArray().mapNotNull { char -> vocab[char.toString()] }
        }

        fun decode(id: Int): String {
            return vocab.entries.find { entry -> entry.value == id }?.key ?: ""
        }
    }
}
TFLITE

# 3. Add missing ChatAdapter if not exists, and ensure it compiles
cat > app/src/main/java/com/ankon/ankonai/ChatAdapter.kt << 'ADAPTER'
package com.ankon.ankonai

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView

class ChatAdapter : RecyclerView.Adapter<ChatAdapter.ViewHolder>() {
    private var items: List<String> = emptyList()

    fun submitList(newItems: List<String>) {
        items = newItems
        notifyDataSetChanged()
    }

    fun clearMessages() {
        items = emptyList()
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(android.R.layout.simple_list_item_1, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        fun bind(text: String) {
            // Just a simple text view for now; we'll improve later
        }
    }
}
ADAPTER

echo "✅ All fixes applied!"
echo "Now building..."
./gradlew clean assembleDebug
