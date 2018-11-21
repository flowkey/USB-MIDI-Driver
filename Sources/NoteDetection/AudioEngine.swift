public typealias AudioTime = Double
public typealias SampleRateChangedCallback = ((_ sampleRate: Double) -> Void)
public typealias AudioDataCallback = (([Float], AudioTime) -> Void)

public protocol AudioEngineProtocol: class {
    var sampleRate: Double { get }
    var onSampleRateChanged: SampleRateChangedCallback? { get set }
    func set(onAudioData: AudioDataCallback?)
    func startMicrophone() throws
    func stopMicrophone() throws
}
