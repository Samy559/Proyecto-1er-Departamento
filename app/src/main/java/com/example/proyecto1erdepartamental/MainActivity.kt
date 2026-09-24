package com.example.proyecto1erdepartamental

import android.app.AlertDialog
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.os.Bundle
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : AppCompatActivity() {

    private var currentImageIndex = 0
    private val images = mutableListOf(
        R.drawable.gundam_1,
        R.drawable.gundam_2,
        R.drawable.rx_0_1,
        R.drawable.rx_0_2,
        R.drawable.unicorn
    )
    private val favoriteImages = mutableSetOf<Int>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val photoImageView = findViewById<ImageView>(R.id.photoImageView)
        val drawingView = findViewById<DrawingView>(R.id.drawingView)
        val btnPrev = findViewById<ImageButton>(R.id.btnPrev)
        val btnNext = findViewById<ImageButton>(R.id.btnNext)
        val btnEdit = findViewById<LinearLayout>(R.id.btnEdit)
        val btnFavorite = findViewById<LinearLayout>(R.id.btnFavorite)
        val btnDelete = findViewById<LinearLayout>(R.id.btnDelete)

        val iconFavorite = findViewById<ImageView>(R.id.iconFavorite)
        val textFavorite = findViewById<TextView>(R.id.textFavorite)

        fun updateFavoriteUi() {
            if (images.isEmpty()) {
                iconFavorite.imageTintList = ColorStateList.valueOf(Color.parseColor("#424242"))
                textFavorite.setTextColor(Color.parseColor("#424242"))
                return
            }
            val currentResId = images[currentImageIndex]
            val isFavorite = favoriteImages.contains(currentResId)
            
            if (isFavorite) {
                iconFavorite.imageTintList = ColorStateList.valueOf(Color.parseColor("#E91E63"))
                textFavorite.setTextColor(Color.parseColor("#E91E63"))
            } else {
                iconFavorite.imageTintList = ColorStateList.valueOf(Color.parseColor("#424242"))
                textFavorite.setTextColor(Color.parseColor("#424242"))
            }
        }

        fun displayCurrentImage() {
            if (images.isEmpty()) {
                photoImageView.setImageResource(android.R.drawable.ic_menu_gallery)
                resetImageEffects(photoImageView, drawingView)
                updateFavoriteUi()
                return
            }
            photoImageView.setImageResource(images[currentImageIndex])
            resetImageEffects(photoImageView, drawingView)
            updateFavoriteUi()
        }

        displayCurrentImage()

        btnPrev.setOnClickListener {
            if (images.isNotEmpty()) {
                currentImageIndex = if (currentImageIndex - 1 < 0) images.size - 1 else currentImageIndex - 1
                displayCurrentImage()
            }
        }

        btnNext.setOnClickListener {
            if (images.isNotEmpty()) {
                currentImageIndex = (currentImageIndex + 1) % images.size
                displayCurrentImage()
            }
        }

        btnEdit.setOnClickListener {
            if (images.isEmpty()) {
                Toast.makeText(this, "No hay imágenes para editar", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            val options = arrayOf("Rotar 90°", "Filtro: Blanco y Negro", "Redimensionar", "Pintar", "Restablecer")
            val builder = AlertDialog.Builder(this)
            builder.setTitle("Opciones de Edición")
            builder.setItems(options) { _, which ->
                when (which) {
                    0 -> {
                        photoImageView.rotation = photoImageView.rotation + 90f
                    }
                    1 -> {
                        val matrix = ColorMatrix()
                        matrix.setSaturation(0f)
                        photoImageView.colorFilter = ColorMatrixColorFilter(matrix)
                    }
                    2 -> {
                        val seekBar = SeekBar(this@MainActivity)
                        seekBar.max = 300
                        seekBar.progress = (photoImageView.scaleX * 100).toInt()
                        
                        seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                                val scale = progress / 100f
                                val finalScale = if (scale < 0.1f) 0.1f else scale
                                photoImageView.scaleX = finalScale
                                photoImageView.scaleY = finalScale
                            }
                            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
                            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
                        })

                        val container = LinearLayout(this@MainActivity)
                        container.setPadding(64, 64, 64, 64)
                        val params = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
                        container.addView(seekBar, params)

                        AlertDialog.Builder(this@MainActivity)
                            .setTitle("Ajustar Tamaño")
                            .setView(container)
                            .setPositiveButton("Aceptar", null)
                            .show()
                    }
                    3 -> {
                        val colorOptions = arrayOf("Rojo", "Azul", "Verde", "Negro")
                        AlertDialog.Builder(this@MainActivity)
                            .setTitle("Elige un color de pincel")
                            .setItems(colorOptions) { _, colorWhich ->
                                val color = when(colorWhich) {
                                    0 -> Color.RED
                                    1 -> Color.BLUE
                                    2 -> Color.GREEN
                                    3 -> Color.BLACK
                                    else -> Color.RED
                                }
                                drawingView.setBrushColor(color)
                                drawingView.isDrawingEnabled = true
                                Toast.makeText(this@MainActivity, "Modo pintar activado", Toast.LENGTH_SHORT).show()
                            }
                            .show()
                    }
                    4 -> {
                        resetImageEffects(photoImageView, drawingView)
                    }
                }
            }
            builder.show()
        }

        btnFavorite.setOnClickListener {
            if (images.isEmpty()) return@setOnClickListener
            
            val currentResId = images[currentImageIndex]
            if (favoriteImages.contains(currentResId)) {
                favoriteImages.remove(currentResId)
                Toast.makeText(this, "Eliminado de favoritos", Toast.LENGTH_SHORT).show()
            } else {
                favoriteImages.add(currentResId)
                Toast.makeText(this, "Añadido a favoritos", Toast.LENGTH_SHORT).show()
            }
            updateFavoriteUi()
        }

        btnDelete.setOnClickListener {
            if (images.isEmpty()) {
                Toast.makeText(this, "No hay imágenes para eliminar", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            AlertDialog.Builder(this)
                .setTitle("Eliminar imagen")
                .setMessage("¿Estás seguro de que deseas eliminar esta imagen de la galería?")
                .setPositiveButton("Eliminar") { _, _ ->
                    // Eliminamos la imagen actual de la lista real
                    val removedId = images.removeAt(currentImageIndex)
                    favoriteImages.remove(removedId) // La quitamos de favoritos por seguridad
                    
                    if (images.isEmpty()) {
                        Toast.makeText(this, "No quedan más imágenes", Toast.LENGTH_SHORT).show()
                        currentImageIndex = 0
                    } else {
                        // Ajustamos el índice por si borramos la última de la lista
                        if (currentImageIndex >= images.size) {
                            currentImageIndex = images.size - 1
                        }
                        Toast.makeText(this, "Imagen eliminada", Toast.LENGTH_SHORT).show()
                    }
                    displayCurrentImage()
                }
                .setNegativeButton("Cancelar", null)
                .show()
        }
    }

    private fun resetImageEffects(photoImageView: ImageView, drawingView: DrawingView) {
        photoImageView.rotation = 0f
        photoImageView.scaleX = 1f
        photoImageView.scaleY = 1f
        photoImageView.clearColorFilter()

        drawingView.isDrawingEnabled = false
        drawingView.clear()
    }
}