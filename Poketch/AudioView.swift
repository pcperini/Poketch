//
//  AudioView.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/25/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import EZAudio
import ZLSinusWaveView

@IBDesignable
class AudioView: ZLSinusWaveView {
    // MARK: Properties
    private let output = EZOutput()
    private var atEndOfFile: ObjCBool = false
    
    @IBInspectable var backingColor: UIColor = .clearColor() {
        didSet {
            self.backgroundColor = self.backingColor
        }
    }
    
    @IBInspectable var waveColor: UIColor = .blackColor() {
        didSet {
            self.color = self.waveColor
        }
    }
    
    @IBInspectable var mirrors: Bool = true {
        didSet {
            self.shouldMirror = self.mirrors
        }
    }
    
    var audioFile: EZAudioFile? {
        didSet {
            self.stop()
            guard let audioFile = self.audioFile else { return }
            
            audioFile.audioFileDelegate = self
            self.output.setAudioStreamBasicDescription(audioFile.clientFormat())
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.plotType = .Buffer
        self.output.outputDataSource = self
        self.maxAmplitude = 0.75
    }
    
    // MARK: State Handlers
    func start(fromStart: Bool = true) {
        if fromStart {
            self.audioFile?.seekToFrame(0)
        }
        
        self.output.startPlayback()
    }
    
    func stop() {
        self.output.stopPlayback()
    }
}

extension AudioView: EZAudioFileDelegate {
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.output.isPlaying() {
                self.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
}

extension AudioView: EZOutputDataSource {
    func output(output: EZOutput!, shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>, withNumberOfFrames frames: UInt32) {
        if let audioFile = self.audioFile {
            var bufferSize: UInt32 = 0
            audioFile.readFrames(frames,
               audioBufferList: audioBufferList,
               bufferSize: &bufferSize,
               eof: &self.atEndOfFile)
        }
    }
}

extension EZAudioFile {
    convenience init?(name: String) {
        let types = ["wav", "mp3"]
        let resourceURL = types.flatMap { NSBundle.mainBundle().URLForResource(name, withExtension: $0) }
            .first
        guard let audioFileURL = resourceURL else { return nil }
        self.init(URL: audioFileURL)
    }
}