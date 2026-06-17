package com.ankon.ankonai.ai

import android.content.Context
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
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