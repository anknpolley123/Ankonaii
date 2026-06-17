package com.ankon.ankonai.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.ankon.ankonai.data.Message
import com.ankon.ankonai.databinding.ItemChatAiBinding
import com.ankon.ankonai.databinding.ItemChatUserBinding
import io.noties.markwon.Markwon

class ChatAdapter : ListAdapter<Message, RecyclerView.ViewHolder>(MessageDiffCallback()) {

    private val markwon = Markwon.create()

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position).type) {
            Message.Type.USER -> VIEW_TYPE_USER
            Message.Type.AI -> VIEW_TYPE_AI
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            VIEW_TYPE_USER -> {
                val binding = ItemChatUserBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                UserViewHolder(binding)
            }
            else -> {
                val binding = ItemChatAiBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                AIViewHolder(binding, markwon)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val message = getItem(position)
        when (holder) {
            is UserViewHolder -> holder.bind(message)
            is AIViewHolder -> holder.bind(message)
        }
    }

    fun clearMessages() {
        submitList(emptyList())
    }

    class UserViewHolder(private val binding: ItemChatUserBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(message: Message) {
            binding.messageText.text = message.content
            
            message.imageUri?.let { uri ->
                binding.imageView.visibility = android.view.View.VISIBLE
                binding.imageView.setImageURI(uri)
            } ?: run {
                binding.imageView.visibility = android.view.View.GONE
            }
        }
    }

    class AIViewHolder(
        private val binding: ItemChatAiBinding,
        private val markwon: Markwon
    ) : RecyclerView.ViewHolder(binding.root) {
        fun bind(message: Message) {
            markwon.setMarkdown(binding.messageText, message.content)
        }
    }

    companion object {
        private const val VIEW_TYPE_USER = 0
        private const val VIEW_TYPE_AI = 1
    }
}

class MessageDiffCallback : DiffUtil.ItemCallback<Message>() {
    override fun areItemsTheSame(oldItem: Message, newItem: Message): Boolean {
        return oldItem.id == newItem.id
    }

    override fun areContentsTheSame(oldItem: Message, newItem: Message): Boolean {
        return oldItem == newItem
    }
}