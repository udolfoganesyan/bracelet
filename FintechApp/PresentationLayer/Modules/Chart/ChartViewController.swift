//
//  ChartViewController.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 23.05.2021.
//  Copyright © 2021 Рудольф О. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var chartContainer: BarChartView!
    @IBOutlet weak var farChartCOntainer: BarChartView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Статистика"
        
        chartContainer.animate(yAxisDuration: 2.0)
        chartContainer.pinchZoomEnabled = false
        chartContainer.drawBarShadowEnabled = false
        chartContainer.drawBordersEnabled = false
        chartContainer.doubleTapToZoomEnabled = false
        chartContainer.drawGridBackgroundEnabled = true
        
        farChartCOntainer.animate(yAxisDuration: 2.0)
        farChartCOntainer.pinchZoomEnabled = false
        farChartCOntainer.drawBarShadowEnabled = false
        farChartCOntainer.drawBordersEnabled = false
        farChartCOntainer.doubleTapToZoomEnabled = false
        farChartCOntainer.drawGridBackgroundEnabled = true
        
        setChart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = ThemeService(themeCore: ThemeCore()).currentTheme.backgroundColor
    }
    
    func setChart() {
        chartContainer.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<31 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(Int.random(in: 0..<15)))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Ближние контакты")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartContainer.data = chartData
        
        var farDataEntries: [BarChartDataEntry] = []
        
        for i in 0..<31 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(Int.random(in: 0..<30)))
            farDataEntries.append(dataEntry)
        }
        
        let farChartDataSet = BarChartDataSet(entries: farDataEntries, label: "Дальние контакты")
        farChartDataSet.colors = [#colorLiteral(red: 0.6235294118, green: 0.9882352941, blue: 0.662745098, alpha: 1)]
        let farChartData = BarChartData(dataSet: farChartDataSet)
        farChartCOntainer.data = farChartData
    }
    
}
