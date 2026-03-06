package com.example.citizenlabguinee

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

// InAppWebView and some other plugins require the activity to be a FragmentActivity
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // No additional setup needed; plugins register automatically
    }
}
