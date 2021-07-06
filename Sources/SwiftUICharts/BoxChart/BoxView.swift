//
//  BoxView.swift
//  
//
//  Created by Vincent Young on 7/5/21.
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct BoxView: View {
    
    var style: ChartStyle
    var data: [BoxChartData]
    
    var title: String?
    var subtext: String?
    var boxesPerRow: Int
    
    public init(style: ChartStyle, data: [BoxChartData], title: String?, subtext: String?, boxesPerRow: Int) {
        self.style = style
        self.data = data
        self.title = title
        self.subtext = subtext
        self.boxesPerRow = boxesPerRow
    }
    
    @available(iOS 14.0, *)
    var vGridItems: [GridItem] {
        var gridItems: [GridItem] = []
        for _ in 0 ..< boxesPerRow {
            gridItems.append(GridItem())
        }
        return gridItems
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            if let titleString = self.title {
                Text(titleString)
                    .bold()
                    .font(.title)
                    .foregroundColor(self.style.textColor)
            }
            
            if let subtextString = self.subtext {
                Text(subtextString)
                    .font(.callout)
                    .foregroundColor(self.style.textColor)
            }
            
            ForEach(0 ..< data.count, id: \.self) { groupIdx in
                
                if #available(iOS 14.0, *) {
                    LazyVGrid(columns: vGridItems) {
                        
                        ForEach(0 ..< data[groupIdx].onlyPoints().count, id: \.self) { idx in
                            Rectangle()
                                .foregroundColor(data[groupIdx].getColor(data[groupIdx].onlyPoints()[idx]))
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
}

#endif
