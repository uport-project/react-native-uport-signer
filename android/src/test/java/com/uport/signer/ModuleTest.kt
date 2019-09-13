package com.uport.signer

import org.junit.Test
import java.util.*

class ModuleTest {

    @Test
    fun `can scale recovery param`() {
        val rec = byteArrayOf(0, 1, 27, 28, 37, 38)
        val expected = intArrayOf(0, 1, 0, 1, 0, 1)

        val scaled = rec.map { recParam: Byte ->
            if (recParam > 1) (recParam + 1) % 2 else recParam.toInt()
        }.toIntArray()

        assert(Arrays.equals(expected, scaled))
    }
}