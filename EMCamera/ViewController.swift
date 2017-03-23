//
//  ViewController.swift
//  EMCamera
//
//  Created by Митько Евгений on 09.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit


class ViewController: UIViewController, BurnCameraDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Camera.show(on: self)
    }
    
    func didTakePhoto(_ photo: UIImage) {
        
    }
    
    func didCaptureVideo(storedAt url: URL) {
        
    }

}



