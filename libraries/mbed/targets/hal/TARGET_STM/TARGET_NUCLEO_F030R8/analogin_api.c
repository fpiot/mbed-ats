/* mbed Microcontroller Library
 * Copyright (c) 2014, STMicroelectronics
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of STMicroelectronics nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#include "analogin_api.h"

#if DEVICE_ANALOGIN

#include "cmsis.h"
#include "pinmap.h"
#include "error.h"
#include "wait_api.h"

static const PinMap PinMap_ADC[] = {
    {PA_0, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN0
    {PA_1, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN1
    {PA_2, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN2
    {PA_3, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN3
    {PA_4, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN4
    {PA_5, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN5
    {PA_6, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN6
    {PA_7, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN7
    {PB_0, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN8
    {PB_1, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN9
    {PC_0, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN10
    {PC_1, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN11
    {PC_2, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN12
    {PC_3, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN13
    {PC_4, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN14
    {PC_5, ADC_1, STM_PIN_DATA(GPIO_Mode_AN, GPIO_OType_PP, GPIO_PuPd_NOPULL, 0xFF)}, // ADC_IN15
    {NC,   NC,    0}
};

int adc_inited = 0;

void analogin_init(analogin_t *obj, PinName pin) {

    ADC_TypeDef     *adc;
    ADC_InitTypeDef ADC_InitStructure;

    // Get the peripheral name (ADC_1, ADC_2...) from the pin and assign it to the object
    obj->adc = (ADCName)pinmap_peripheral(pin, PinMap_ADC);

    if (obj->adc == (ADCName)NC) {
        error("ADC pin mapping failed");
    }

    // Configure GPIO
    pinmap_pinout(pin, PinMap_ADC);

    // Save pin number for the read function
    obj->pin = pin;

    // The ADC initialization is done once
    if (adc_inited == 0) {
        adc_inited = 1;

        // Get ADC registers structure address
        adc = (ADC_TypeDef *)(obj->adc);

        // Enable ADC clock
        RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);

        // Configure ADC
        ADC_InitStructure.ADC_Resolution           = ADC_Resolution_12b;
        ADC_InitStructure.ADC_ContinuousConvMode   = DISABLE;
        ADC_InitStructure.ADC_ExternalTrigConvEdge = ADC_ExternalTrigConvEdge_None;
        ADC_InitStructure.ADC_ExternalTrigConv     = ADC_ExternalTrigConv_T1_TRGO;
        ADC_InitStructure.ADC_DataAlign            = ADC_DataAlign_Right;
        ADC_InitStructure.ADC_ScanDirection        = ADC_ScanDirection_Upward;
        ADC_Init(adc, &ADC_InitStructure);

        // Calibrate ADC
        ADC_GetCalibrationFactor(adc);

        // Enable ADC
        ADC_Cmd(adc, ENABLE);
    }
}

static inline uint16_t adc_read(analogin_t *obj) {
    // Get ADC registers structure address
    ADC_TypeDef *adc = (ADC_TypeDef *)(obj->adc);

    adc->CHSELR = 0; // Clear all channels first

    // Configure ADC channel
    switch (obj->pin) {
        case PA_0:
            ADC_ChannelConfig(adc, ADC_Channel_0, ADC_SampleTime_7_5Cycles);
            break;
        case PA_1:
            ADC_ChannelConfig(adc, ADC_Channel_1, ADC_SampleTime_7_5Cycles);
            break;
        case PA_2:
            ADC_ChannelConfig(adc, ADC_Channel_2, ADC_SampleTime_7_5Cycles);
            break;
        case PA_3:
            ADC_ChannelConfig(adc, ADC_Channel_3, ADC_SampleTime_7_5Cycles);
            break;
        case PA_4:
            ADC_ChannelConfig(adc, ADC_Channel_4, ADC_SampleTime_7_5Cycles);
            break;
        case PA_5:
            ADC_ChannelConfig(adc, ADC_Channel_5, ADC_SampleTime_7_5Cycles);
            break;
        case PA_6:
            ADC_ChannelConfig(adc, ADC_Channel_6, ADC_SampleTime_7_5Cycles);
            break;
        case PA_7:
            ADC_ChannelConfig(adc, ADC_Channel_7, ADC_SampleTime_7_5Cycles);
            break;
        case PB_0:
            ADC_ChannelConfig(adc, ADC_Channel_8, ADC_SampleTime_7_5Cycles);
            break;
        case PB_1:
            ADC_ChannelConfig(adc, ADC_Channel_9, ADC_SampleTime_7_5Cycles);
            break;
        case PC_0:
            ADC_ChannelConfig(adc, ADC_Channel_10, ADC_SampleTime_7_5Cycles);
            break;
        case PC_1:
            ADC_ChannelConfig(adc, ADC_Channel_11, ADC_SampleTime_7_5Cycles);
            break;
        case PC_2:
            ADC_ChannelConfig(adc, ADC_Channel_12, ADC_SampleTime_7_5Cycles);
            break;
        case PC_3:
            ADC_ChannelConfig(adc, ADC_Channel_13, ADC_SampleTime_7_5Cycles);
            break;
        case PC_4:
            ADC_ChannelConfig(adc, ADC_Channel_14, ADC_SampleTime_7_5Cycles);
            break;
        case PC_5:
            ADC_ChannelConfig(adc, ADC_Channel_15, ADC_SampleTime_7_5Cycles);
            break;
        default:
            return 0;
    }

    while (!ADC_GetFlagStatus(adc, ADC_FLAG_ADRDY)); // Wait ADC ready

    ADC_StartOfConversion(adc); // Start conversion

    while (ADC_GetFlagStatus(adc, ADC_FLAG_EOC) == RESET); // Wait end of conversion

    return (ADC_GetConversionValue(adc)); // Get conversion value
}

uint16_t analogin_read_u16(analogin_t *obj) {
    return (adc_read(obj));
}

float analogin_read(analogin_t *obj) {
    uint16_t value = adc_read(obj);
    return (float)value * (1.0f / (float)0xFFF); // 12 bits range
}

#endif
