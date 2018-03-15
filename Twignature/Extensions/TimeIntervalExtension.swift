//
// Created by mac on 06.12.2017.
// Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

extension TimeInterval {

    func timecodeForTimeInterval() -> String {
        var seconds: Int
        var hours: Int
        var minutes: Int
        var timecode: String

        let time = abs(self);
        hours = Int(time/60/24);
        minutes = Int((time - Double(hours*24))/60)
        seconds = Int((time - Double(hours*24)) - Double(minutes*60))

        if hours > 0 {
            timecode = String(format: "%d:%02d:%02d", arguments: [hours, minutes, seconds])
        }
        else {
            timecode = String(format: "%02d:%02d", arguments: [minutes, seconds])
        }

        return timecode;
    }
    

}
