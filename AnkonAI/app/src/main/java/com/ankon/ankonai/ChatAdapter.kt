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
