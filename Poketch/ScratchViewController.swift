//
//  ScratchViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import EZAudio
import ZLSinusWaveView

class ScratchViewController: UIViewController {
    
    @IBOutlet var audioView: ZLSinusWaveView!
    var audioFile: EZAudioFile?
    var eof: ObjCBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioView.backgroundColor = UIColor.whiteColor()
        self.audioView.color = UIColor.purpleColor()
        
        EZOutput.sharedOutput().stopPlayback()
        self.audioFile = EZAudioFile(URL: NSBundle.mainBundle().URLForResource("001", withExtension: "wav"))
        self.audioFile?.audioFileDelegate = self
        EZOutput.sharedOutput().setAudioStreamBasicDescription(self.audioFile!.clientFormat())
        
        self.audioView.plotType = .Buffer
        self.audioView.shouldMirror = true
        self.audioFile?.getWaveformDataWithCompletionBlock { (data, length) in
            self.audioView.updateBuffer(data, withBufferSize: length)
        }
        
        self.audioFile?.seekToFrame(0)
        EZOutput.sharedOutput().outputDataSource = self
        EZOutput.sharedOutput().startPlayback()
    }
}

extension ScratchViewController: EZAudioFileDelegate {
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            if EZOutput.sharedOutput().isPlaying() {
                self.audioView.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
}

extension ScratchViewController: EZOutputDataSource {
    func output(output: EZOutput!, shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>, withNumberOfFrames frames: UInt32) {
        if let audioFile = self.audioFile {
            var bufferSize: UInt32 = 0
            audioFile.readFrames(frames,
                audioBufferList: audioBufferList,
                bufferSize: &bufferSize,
                eof: &self.eof)
            
            if self.eof {
                dispatch_after(1.0) {
                    audioFile.seekToFrame(0)
                }
            }
        }
    }
    
}
