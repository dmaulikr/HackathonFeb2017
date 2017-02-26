//
//  CeateClipsViewController.swift
//  PinVid
//
//  Created by Sida Wang on 2/25/17.
//  Copyright © 2017 SantaClaraiOSConnect. All rights reserved.
//

import UIKit

class CreateClipsViewController: UIViewController, VideoViewDelegate {

    var videoId:String = "TgqiSBxvdws"
    var videoView: VideoView!
    var scrubberView = ScrubberView()
    var clipsView = ClipsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNav()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrubberView.rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(sender:)), for: .valueChanged)
        scrubberView.addClip.addTarget(self, action: #selector(addClipPressed(sender:)), for: .touchUpInside)
        scrubberView.timerButton.addTarget(self, action: #selector(tappedTimer(sender:)), for: .touchUpInside)
        scrubberView.tenSecBack.addTarget(self, action: #selector(bigRewind(sender:)), for: .touchUpInside)
        scrubberView.oneSecBack.addTarget(self, action: #selector(smallRewind(sender:)), for: .touchUpInside)
        scrubberView.oneSecForward.addTarget(self, action: #selector(smallFastForward(sender:)), for: .touchUpInside)
        scrubberView.tenSecForward.addTarget(self, action: #selector(bigFastForward(sender:)), for: .touchUpInside)
    }
    
    func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addTapped))
    }
    
    func setupView() {
        videoView = VideoView(frame: .zero)
        videoView.videoId = videoId
        videoView.player.load(withVideoId: videoView.videoId, playerVars:videoView.playerVars)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.backgroundColor = UIColor.orange
        videoView.delegate = self
        self.view.addSubview(videoView)
        
        scrubberView.translatesAutoresizingMaskIntoConstraints = false
        scrubberView.backgroundColor = UIColor.cyan
        self.view.addSubview(scrubberView)
        
        clipsView.translatesAutoresizingMaskIntoConstraints = false
        clipsView.backgroundColor = UIColor.lightGray
        self.view.addSubview(clipsView)
    }
    
    override func viewWillLayoutSubviews() {
        clipsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        clipsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        clipsView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5).isActive = true
        clipsView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        
        videoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: clipsView.bottomAnchor).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2).isActive = true
        
        scrubberView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrubberView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrubberView.topAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
        scrubberView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        
        
    }

    func addTapped(sender: UIButton) {
        
        print("done")
    }
    
    func rangeSliderValueChanged(sender:RangeSlider){
        
        updateEndTime(to: sender.upperValue)
        updateStartTime(to: sender.lowerValue)
 
    }
    
    func updateEndTime(to time:Double) {
        if scrubberView.prevEndTime != time {
            scrubberView.prevEndTime = time
            videoView.player.seek(toSeconds: Float(time - 3.0), allowSeekAhead: true)
            print("updated end time to \(scrubberView.prevEndTime) - 3 sec")
        }
    }
    
    func updateStartTime(to time:Double) {
        if scrubberView.prevStartTime != time {
            scrubberView.prevStartTime = time
            videoView.player.seek(toSeconds: Float(time), allowSeekAhead: true)
            print("updated start time to \(scrubberView.prevStartTime)")
        }
    }
    
    func ready(playerView: YTPlayerView) {
        scrubberView.rangeSlider.maximumValue = playerView.duration()

        scrubberView.rangeSlider.upperValue = playerView.duration()
        scrubberView.rangeSlider.lowerValue = 0
        
        scrubberView.prevStartTime = scrubberView.rangeSlider.lowerValue
        scrubberView.prevEndTime = scrubberView.rangeSlider.upperValue
    }
    
    func getStartTime() -> Float? {
        return scrubberView.prevStartTime.map({return Float($0)})
    }
    
    func getEndTime() -> Float? {
        return scrubberView.prevEndTime.map({return Float($0)})
    }
    
    func updateTimer(time: Double) {
        scrubberView.timerButton.setTitle(time.secondsToString(), for: .normal)
    }
    
    func addClipPressed(sender:UIButton){
        if let startTime = scrubberView.prevStartTime, let endTime = scrubberView.prevEndTime {
            print("clipped: start \(startTime) | end \(endTime)")
            CoreDataManager.sharedInstance.addClip(startTime: startTime, endTime: endTime)
        } else {
            print("need to customized both start and end time")
        }
    }
    
    func tappedTimer(sender: UIButton) {
        print("tapped on timer \(videoView.player.currentTime())")
        switch scrubberView.rangeSlider.activeThumb {
        case 1:
            scrubberView.rangeSlider.lowerValue = Double(videoView.player.currentTime())
            break
        case 2:
            scrubberView.rangeSlider.upperValue = Double(videoView.player.currentTime())
            break
        default:
            break
        }
    }
        
    func bigRewind(sender:UIButton) {
        print("bigRewind")
        baseUpdate(seconds: -10)
    }
    
    func smallRewind(sender:UIButton) {
        print("smallRewind")
        baseUpdate(seconds: -1)
    }
    
    func baseUpdate(seconds:Double) {
        if scrubberView.rangeSlider.activeThumb == 1 {
            if scrubberView.rangeSlider.lowerValue + seconds <= scrubberView.rangeSlider.upperValue &&
                scrubberView.rangeSlider.lowerValue + seconds >= scrubberView.rangeSlider.minimumValue {
                scrubberView.rangeSlider.lowerValue += seconds
                updateStartTime(to: scrubberView.rangeSlider.lowerValue)
            }
        } else if scrubberView.rangeSlider.activeThumb == 2 {
            if scrubberView.rangeSlider.upperValue + seconds <= scrubberView.rangeSlider.maximumValue &&
                scrubberView.rangeSlider.upperValue + seconds >= scrubberView.rangeSlider.lowerValue {
                scrubberView.rangeSlider.upperValue += seconds
            }
        }
    }
    
    func smallFastForward(sender:UIButton) {
        print("smallFastForward")
        baseUpdate(seconds: 1)
    }
    
    func bigFastForward(sender:UIButton){
        print("bigFastForward")
        baseUpdate(seconds: 10)
    }
}

extension Double {
    func secondsToString() -> String {
        let minutes:Int = Int(self / 60.0)
        let minString:String = String(format: "%02d", minutes)
        
        let secondsLeft:Int = Int(self - Double(60 * minutes))
        let secondsString:String = String(format: "%02d", secondsLeft)
        
        return "\(minString):\(secondsString)"
    }
}
