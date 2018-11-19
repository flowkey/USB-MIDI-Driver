
private let EXCLUSIVE_START: UInt8 = 0xF0
private let YAMAHA_ID: UInt8 = 0x43
private let CLAVINOVA_ID: UInt8 = 0x73
private let MODEL_ID_COMMON: UInt8 = 0x01
private let SPECIAL_OPERATORS: UInt8 = 0x11
private let MODE_SUBSTATUS: UInt8 = 0x47
private let EXCLUSIVE_STOP: UInt8 = 0xF7

private let GUIDE_ON_SUBSTATUS: UInt8 = 0x1F
private let VOID: UInt8 = 0x00
private let PART_SELECT_LEFT_RIGHT_OFF: UInt8 = 0x03
private let MODEL_ID: UInt8 = 0x4C

typealias YamahaMessages = [UInt8]

extension UInt8 {
    // the channel the piano will listen for noteOn and noteOff messages to control lights
    static let LIGHT_CONTROL_CHANNEL: UInt8 = 10
}

extension Array where Element == UInt8 {
    // light mode control messages
    static let LIGHT_OFF_SOUND = createKeyLEDModeControlMessage(channel: .LIGHT_CONTROL_CHANNEL, mode: 0x00)
    static let LIGHT_ON_NO_SOUND = createKeyLEDModeControlMessage(channel: .LIGHT_CONTROL_CHANNEL, mode: 0x01)
    static let LIGHT_ON_SOUND = createKeyLEDModeControlMessage(channel: .LIGHT_CONTROL_CHANNEL, mode: 0x02)
    static let LIGHT_OFF_NO_SOUND = createKeyLEDModeControlMessage(channel: .LIGHT_CONTROL_CHANNEL, mode: 0x03)
    
    // guide mode control messages
    static let GUIDE_OFF = createGuideModeControlMessage(partSelectLeftRight: PART_SELECT_LEFT_RIGHT_OFF, mode: 0x00)
    static let GUIDE_ON = createGuideModeControlMessage(partSelectLeftRight: PART_SELECT_LEFT_RIGHT_OFF, mode: 0x01)

    // message for Dump Request
    static let DUMP_REQUEST_MODEL = createDumpRequestMessage(addrHigh: 0x01, addrMid: 0x00, addrLow: 0x00)
    static let DUMP_REQUEST_RESPONSE_SIGNATURE: [UInt8] = [
        EXCLUSIVE_START,
        YAMAHA_ID,
        0x00,
        MODEL_ID,
    ]
    
    static let TURN_OFF_ALL_STREAM_LIGHTS: [UInt8] = [
        EXCLUSIVE_START,
        YAMAHA_ID,
        CLAVINOVA_ID,
        MODEL_ID_COMMON,
        0x52,
        0x25,
        0x26,
        VOID,
        VOID,
        0x05,
        0x02,
        MODEL_ID_COMMON,
        MODEL_ID_COMMON,
        VOID,
        MODEL_ID_COMMON,
        VOID,
        VOID,
        MODEL_ID_COMMON,
        VOID,
        EXCLUSIVE_STOP
    ]
};

enum LEDMode: UInt8 {
    case on = 0x01
    case off = 0x00
    case flash = 0x02
}

/**
 Create a midi message to control a certain LED of a CSP piano

 - returns:
    sysex midi message data that can be send to a CSP piano

 - parameters:
    - key: 15 .. 108
    - ledRow: 0 .. 3 (where 0 is the bottom led row)
    - mode: .on, .off or .flash
*/
func createStreamLightsOnOffMessage(key: UInt8, ledRow: UInt8, mode: LEDMode) -> [UInt8] {
    return [
        EXCLUSIVE_START,
        YAMAHA_ID,
        CLAVINOVA_ID,
        MODEL_ID_COMMON,
        0x52,
        0x25,
        0x26,
        VOID,
        VOID,
        0x05,
        0x02,
        VOID,
        MODEL_ID_COMMON,
        key,
        MODEL_ID_COMMON,
        ledRow,
        VOID,
        MODEL_ID_COMMON,
        mode.rawValue,
        EXCLUSIVE_STOP
    ]
}

private func createKeyLEDModeControlMessage(channel: UInt8, mode: UInt8) -> [UInt8] {
    return [
        EXCLUSIVE_START,
        YAMAHA_ID,
        CLAVINOVA_ID,
        MODEL_ID_COMMON,
        SPECIAL_OPERATORS,
        channel,
        MODE_SUBSTATUS,
        mode,
        EXCLUSIVE_STOP,
    ]
}

private func createGuideModeControlMessage(partSelectLeftRight: UInt8, mode: UInt8) -> [UInt8] {
    return [
        EXCLUSIVE_START,
        YAMAHA_ID,
        CLAVINOVA_ID,
        MODEL_ID_COMMON,
        GUIDE_ON_SUBSTATUS,
        VOID,
        partSelectLeftRight,
        mode,
        EXCLUSIVE_STOP,
    ]
}

private func createDumpRequestMessage(addrHigh: UInt8, addrMid: UInt8, addrLow: UInt8, deviceNumber: UInt8 = 0x20) -> [UInt8] {
    // 0x2n = Device Number n=always 0 (when transmit), n=0-F (when receive)
    return [
        EXCLUSIVE_START,
        YAMAHA_ID,
        deviceNumber,
        MODEL_ID,
        addrHigh,
        addrMid,
        addrLow,
        EXCLUSIVE_STOP,
    ]
}


