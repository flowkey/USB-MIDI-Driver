
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

private let clavinovaChannel: UInt8 = 10


typealias ClavinovaMessages = [UInt8]

extension Array where Element == UInt8 {
    // light mode control messages
    static let LIGHT_OFF_SOUND = createLightModeControlMessage(channel: clavinovaChannel, mode: 0x00)
    static let LIGHT_ON_NO_SOUND = createLightModeControlMessage(channel: clavinovaChannel, mode: 0x01)
    static let LIGHT_ON_SOUND = createLightModeControlMessage(channel: clavinovaChannel, mode: 0x02)
    static let LIGHT_OFF_NO_SOUND = createLightModeControlMessage(channel: clavinovaChannel, mode: 0x03)
    
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
};

private func createLightModeControlMessage(channel: UInt8, mode: UInt8) -> [UInt8] {
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


