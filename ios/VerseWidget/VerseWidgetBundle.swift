//
//  VerseWidgetBundle.swift
//  VerseWidget
//
//  Created by KC Dacre8tor on 12/16/25.
//

import WidgetKit
import SwiftUI

@main
struct VerseWidgetBundle: WidgetBundle {
    var body: some Widget {
        VerseWidget()
        VerseWidgetControl()
        VerseWidgetLiveActivity()
    }
}
