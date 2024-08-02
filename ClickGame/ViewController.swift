//
//  ViewController.swift
//  ClickGame
//
//  Created by Adam Chen on 2024/8/2.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var eatButton: UIButton!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bunImageView: UIImageView!
    @IBOutlet weak var teaImageView: UIImageView!
    
    var gameTime = 30           //建立遊戲時間30秒
    var gameTimer:Timer?        //建立一個遊戲時間Timer變數
    var state:Float = 0.0       //建立一個Float的變數，來儲存Progress的Value
    var progressTimer:Timer?    //建立一個進度條Timer變數
    var clickCount = 0          //建立點擊次數為0
    var player = AVPlayer()     //建立播放器
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        clickCount = 0
        scoreLabel.text = "\(clickCount)"   //顯示分數
        gameTime = 30
        gameTimeLabel.text = "\(gameTime)"  //顯示遊戲時間
        
        //設定進度條樣式、大小
        state = 0.0
        progressView.progress = state
        progressView.progressViewStyle = .bar
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 5)
        progressView.progressTintColor = UIColor.red
        progressView.trackTintColor = UIColor.lightGray
        progressView.layer.cornerRadius = 10
        progressView.clipsToBounds = true
        progressView.layer.sublayers![1].cornerRadius = 10
        progressView.subviews[1].clipsToBounds = true
        
        //設定按鈕
        startGameButton.isEnabled = true
        eatButton.isEnabled = false     //遊戲開始前不能點擊
        drinkButton.isEnabled = false   //遊戲開始前不能點擊
        bunImageView.isHidden = true    //隱藏動畫圖片
        teaImageView.isHidden = true    //隱藏動畫圖片
    }
    
    //點擊包子
    @IBAction func eatBun(_ sender: Any) {
        //設定吃包子的音效，forResource：檔案名稱，withExtension：附檔名
        let eatBunUrl = Bundle.main.url(forResource: "eat", withExtension: "mp3")!
        let eatBunPlayerItem = AVPlayerItem(url: eatBunUrl)
        player.replaceCurrentItem(with: eatBunPlayerItem)
        player.play()
        
        //設定包子動畫
        bunImageView.isHidden = false
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
            //設定包子圖案向上移動40點
            self.bunImageView.frame.origin.y -= 40
        }
        //動畫完成後的處理(這裡隱藏包子圖案並移回原始位置)
        animator.addCompletion { (position) in
            if position == .end {
                self.bunImageView.isHidden = true
                self.bunImageView.frame.origin.y += 40
            }
        }
        animator.startAnimation()   //開始動畫
        
        //增加分數
        clickCount += 1
        scoreLabel.text = "\(clickCount)"
        
        //吃包子增加進度條
        if state >= 1.0 {
            progressView.progress = 1.0
            endGameAlert()
        }else {
            state += 0.02
            progressView.progress = state
        }
        
    }
    
    //點擊茶
    @IBAction func drinkTea(_ sender: Any) {
        //設定喝茶的音效，forResource：檔案名稱，withExtension：附檔名
        let drinkTeaUrl = Bundle.main.url(forResource: "drink", withExtension: "mp3")!
        let drinkTeaPlayerItem = AVPlayerItem(url: drinkTeaUrl)
        player.replaceCurrentItem(with: drinkTeaPlayerItem)
        player.play()
        
        //設定動畫
        teaImageView.isHidden = false
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
            //設定茶圖案向上移動40點
            self.teaImageView.frame.origin.y -= 40
        }
        
        //動畫完成後的處理(這裡隱藏茶圖案並移回原始位置)
        animator.addCompletion { (position) in
            if position == .end {
                self.teaImageView.isHidden = true
                self.teaImageView.frame.origin.y += 40
            }
        }
        animator.startAnimation()   //開始動畫
        
        //喝茶減少進度條
        state -= 0.05
        progressView.progress = state
    }
    
    //開始遊戲
    @IBAction func startGame(_ sender: Any) {
        startGameButton.isEnabled = false
        eatButton.isEnabled = true
        drinkButton.isEnabled = true
        
        //倒計時功能
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] Timer in
            //判斷遊戲時間是否結束
            if gameTime >= 1 {
                gameTime -= 1
                gameTimeLabel.text = "\(gameTime)"
            }else{
                endGameAlert()
            }
        })
        
        //更新進度條功能
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [self] Timer in
            //progress是0到1的範圍
            if state < 1.0 {
                state += 0.05
                progressView.progress = state
            }else {
                progressView.progress = 1.0
                endGameAlert()
            }
        })
        
    }
    
    //重新開始
    @IBAction func resetGame(_ sender: Any) {
        //停止計時器
        gameTimer?.invalidate()
        progressTimer?.invalidate()
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 0.2)
        
        viewDidLoad()
    }
    
    //遊戲結束彈窗通知
    func endGameAlert(){
        //遊戲結束，不在更新Timer
        gameTimer?.invalidate()
        progressTimer?.invalidate()
        
        //停用按鈕
        eatButton.isEnabled = false
        drinkButton.isEnabled = false
        
        //彈窗內容
        let controller = UIAlertController(title: "遊戲結束!\n恭喜得到\(clickCount)分", message: "再玩一次吧", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        controller.addAction(okAction)
        present(controller, animated: true)
        
    }
    
}

