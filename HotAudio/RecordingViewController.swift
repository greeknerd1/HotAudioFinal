//
//  ViewController.swift
//  MicrophoneAnalysis
//
//  Created by Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit
import Foundation

class RecordingViewController: UIViewController {
    
    @IBOutlet private var frequencyLabel: UILabel!
    @IBOutlet private var audioInputPlot: EZAudioPlot!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    static var frequencies = [0.0]
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecordingViewController.frequencies = [0.0]
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(RecordingViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func updateUI() {
        if tracker.amplitude > 0.075 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            RecordingViewController.frequencies.append(tracker.frequency)
        }
    }
    
    static func average() -> Double {
        var sum : Double = 0
        var count : Double = 0
        for frequency in RecordingViewController.frequencies {
            if (frequency < 250) {
                sum += frequency
                count += 1
            }
        }
        return sum/count
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "stopRecording"), object: nil)
        do {
            try AudioKit.stop()
        } catch {
            print ("didn't stop")

        }
        print ("stopped")
        
    }
    
}

