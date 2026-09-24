package com.example.proyecto1erdepartamental

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View

class DrawingView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private var drawPath = Path()
    private var drawPaint = Paint()
    private val paths = mutableListOf<Pair<Path, Paint>>()

    var isDrawingEnabled = false

    init {
        setupPaint(Color.RED)
    }

    private fun setupPaint(color: Int) {
        drawPaint = Paint().apply {
            this.color = color
            isAntiAlias = true
            strokeWidth = 15f
            style = Paint.Style.STROKE
            strokeJoin = Paint.Join.ROUND
            strokeCap = Paint.Cap.ROUND
        }
    }

    fun setBrushColor(color: Int) {
        setupPaint(color)
    }

    fun clear() {
        paths.clear()
        drawPath.reset()
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        for ((path, paint) in paths) {
            canvas.drawPath(path, paint)
        }
        if (!drawPath.isEmpty) {
            canvas.drawPath(drawPath, drawPaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isDrawingEnabled) return false

        val touchX = event.x
        val touchY = event.y

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                drawPath.moveTo(touchX, touchY)
            }
            MotionEvent.ACTION_MOVE -> {
                drawPath.lineTo(touchX, touchY)
            }
            MotionEvent.ACTION_UP -> {
                drawPath.lineTo(touchX, touchY)
                // Guardar el trazo terminado en la lista
                paths.add(Pair(drawPath, drawPaint))
                // Reiniciar el path actual pero conservar el color
                val currentColor = drawPaint.color
                drawPath = Path()
                setupPaint(currentColor)
            }
            else -> return false
        }
        invalidate()
        return true
    }
}