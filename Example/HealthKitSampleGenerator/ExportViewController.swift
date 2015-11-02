//
//  ExportViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 02.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import HealthKitSampleGenerator

class ExportViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfProfileName:       UITextField!
    @IBOutlet weak var btnExport:           UIButton!
    @IBOutlet weak var avExporting:         UIActivityIndicatorView!
    @IBOutlet weak var lbOutputFileName:    UILabel!
    @IBOutlet weak var swOverwriteIfExist:  UISwitch!
    @IBOutlet weak var scExportType:        UISegmentedControl!
    @IBOutlet weak var lbExportDescription: UILabel!
    @IBOutlet weak var pvExportProgress:    UIProgressView!
    @IBOutlet weak var lbExportMessages:    UILabel!
    
    let healthStore  = HKHealthStore()
    
    var exportConfigurationValid = false {
        didSet {
            btnExport.enabled = exportConfigurationValid
        }
    }
    
    var exportConfiguration : HealthDataFullExportConfiguration? {
        didSet {
            if let config = exportConfiguration {
                switch config.exportType {
                case .ALL:
                    self.lbExportDescription.text = "All accessable health data wil be exported."
                case .ADDED_BY_THIS_APP :
                    self.lbExportDescription.text = "All health data will be exported, that has been added by this app - e.g. they are imported from a profile."
                case .GENERATED_BY_THIS_APP :
                    self.lbExportDescription.text = "All health data will be exported that has been generated by this app - e.g. they are not created through an import of a profile but generated by code. "
                }
            }
        }
    }
    
    var exportTarget : JsonSingleDocAsFileExportTarget? {
        didSet {
            if let target = exportTarget {
                lbOutputFileName.text = target.outputFileName
            }
            
        }
    }
    
    var exportInProgress = false {
        didSet {
            avExporting.hidden      = !exportInProgress
            btnExport.enabled       = !exportInProgress
            pvExportProgress.hidden = !exportInProgress
        }
    }
    
    var outputFielName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfProfileName.text                  = "output" + UIUtil.sharedInstance.formatDateForFileName(NSDate())
        tfProfileName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        tfProfileName.delegate              = self
        
        scExportType.selectedSegmentIndex   = HealthDataToExportType.allValues.indexOf(HealthDataToExportType.ALL)!
        
        lbExportMessages.text               = ""
        
        exportInProgress = false
        createAndAnalyzeExportConfiguration()
    }
    
    @IBAction func scEpxortDataTypeChanged(sender: AnyObject) {
        createAndAnalyzeExportConfiguration()
    }
    
    @IBAction func doExport(_: AnyObject) {
        exportInProgress = true
        self.pvExportProgress.progress = 0.0
        
        HealthKitDataExporter(healthStore:healthStore).export(
            
            exportTargets: [exportTarget!],
            exportConfiguration: exportConfiguration!,
            
            onProgress: {(message: String, progressInPercent: NSNumber?)->Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.lbExportMessages.text = message
                    if let progress = progressInPercent {
                        self.pvExportProgress.progress = progress.floatValue
                    }
                })
            },
            
            onCompletion: {(error: ErrorType?)-> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let exportError = error {
                        self.lbExportMessages.text = "Export error: \(exportError)"
                        print(exportError)
                    }
                    
                    self.exportInProgress = false
                })
            }
        )
    }
    
    @IBAction func swOverwriteIfExistChanged(sender: AnyObject) {
        createAndAnalyzeExportConfiguration()
    }
    
    func createAndAnalyzeExportConfiguration(){
        var fileName = "output"
        if let text = tfProfileName.text where !text.isEmpty {
            fileName = FileNameUtil.normalizeName(text)
        }
        
        let documentsUrl    = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        print(documentsUrl)
        let outputFileName  = documentsUrl.URLByAppendingPathComponent(fileName+".json.hsg").path!
        
        exportTarget = JsonSingleDocAsFileExportTarget(
            outputFileName: outputFileName,
            overwriteIfExist: swOverwriteIfExist.on)
        
        exportConfiguration = HealthDataFullExportConfiguration(profileName: tfProfileName.text!, exportType: HealthDataToExportType.allValues[scExportType.selectedSegmentIndex])

        
        exportConfigurationValid = exportTarget!.isValid()
    }

    func textFieldDidChange(_: UITextField) {
       createAndAnalyzeExportConfiguration()
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
