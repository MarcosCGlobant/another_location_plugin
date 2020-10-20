package com.marcoscifuentes.another_location_plugin

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class ForOrderActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_for_order)

        this.findViewById<Button>(R.id.button_activity).setOnClickListener {
            this.returnFromActivity()
        }
        this.findViewById<TextView>(R.id.tv_intent_result).text = intent.getStringExtra(ORDER)
    }


    private fun returnFromActivity() {
        val intent = Intent()
        intent.putExtra(ORDER, RETURN_MESSAGE)
        setResult(RESULT_OK, intent)
        finish()
    }


    companion object {
        const val ORDER = "order"
        private const val DATA = "Return to read your new message"
        private const val RETURN_MESSAGE = "Hello world"

        fun getIntent(context: Context): Intent =
                Intent(context, ForOrderActivity::class.java).apply {
                    putExtra(ORDER, DATA)
                }
    }
}
