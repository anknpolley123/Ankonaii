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
