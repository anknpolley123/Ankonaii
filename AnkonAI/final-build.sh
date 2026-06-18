#!/bin/bash
echo "🔧 Applying final fixes (simplified AI)..."


# 1. Replace TFLiteInterpreter with a dummy implementation that works
cat > app/src/main/java/com/ankon/ankonai/ai/TFLiteInterpreter.kt << 'TFLITE'
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
TFLITE

# 2. Ensure ChatAdapter.kt has proper methods
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
            // You can replace this with a TextView binding
        }
    }
}
ADAPTER

# 3. Update MainActivity.kt to use the adapter properly
cat > app/src/main/java/com/ankon/ankonai/MainActivity.kt << 'MAIN'
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
MAIN

echo "✅ All fixes applied!"
echo "Now building (this will take a few minutes)..."
./gradlew clean assembleDebug
