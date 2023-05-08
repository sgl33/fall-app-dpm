#pragma once

enum class AccelerometerBmi160Register : uint8_t {
    POWER_MODE = 1,
    DATA_INTERRUPT_ENABLE,
    DATA_CONFIG,
    DATA_INTERRUPT,
    DATA_INTERRUPT_CONFIG,
    
    MOTION_INTERRUPT_ENABLE = 0x9,
    MOTION_CONFIG,
    MOTION_INTERRUPT,

    TAP_INTERRUPT_ENABLE,
    TAP_CONFIG,
    TAP_INTERRUPT,

    ORIENT_INTERRUPT_ENABLE = 0xf,
    ORIENT_CONFIG,
    ORIENT_INTERRUPT,

    ///<step counter/detector BMI160 only
    STEP_DETECTOR_INTERRUPT_EN = 0x17,
    STEP_DETECTOR_CONFIG,
    STEP_DETECTOR_INTERRUPT,
    STEP_COUNTER_DATA,
    STEP_COUNTER_RESET,
    PACKED_ACC_DATA
};

enum class AccelerometerBmi270Register : uint8_t {
    POWER_MODE = 1,
    DATA_INTERRUPT_ENABLE,
    DATA_CONFIG,
    DATA_INTERRUPT,

    PACKED_ACC_DATA = 0x5,
    
    FEATURE_ENABLE = 0x6,
    FEATURE_INTERRUPT_ENABLE,
    FEATURE_CONFIG,

    MOTION_INTERRUPT = 0x9,

    WRIST_INTERRUPT,
    
    STEP_COUNT_INTERRUPT,
    
    ACTIVITY_INTERRUPT,
    TEMP_INTERRUPT,    
    TEMP_ENABLE,
    TEMP,
    
    OFFSET,
    
    DOWNSAMPLING
};
