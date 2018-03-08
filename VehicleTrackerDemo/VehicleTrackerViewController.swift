//
//  ViewController.swift
//  VehicleTrackerDemo
//
//  Created by Drivool on 2/15/17.
//  Copyright © 2017 Drivool. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , UIWebViewDelegate, CLLocationManagerDelegate {
    static let PREF_ZOOMTO = "pref_zoomto"
    var blnVTLoaded = false;
    var mLocationManager: CLLocationManager?
    var mCurrentLocation: CLLocation?
    var mWebView: UIWebView!
    var mUrlRequest: URLRequest!
    var mstrGAPN: String = ""
    let mAppPref = UserDefaults.standard
    

    @IBOutlet weak var progressLoading: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var webView1: UIWebView!
    
    
//    @IBAction func btnBack(_ sender: UIButton) {
//        if webView1.canGoBack == true {
//            webView1.goBack()
//        }else{
//            webView1.loadRequest(mUrlRequest);
//        }
//    }
    
    
    func getQueryStringParameter(_ url: String,_ param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            return false
        }
        
        if request.url?.scheme == "csf" {
            
            //print("absoluteString " + (request.url?.absoluteString)!)
            
            let strUrl = (request.url?.absoluteString)!
            //print("absoluteString " + strUrl)
            
            let strMethod = getQueryStringParameter(strUrl, "method")
            let strParam = getQueryStringParameter(strUrl, "param")
            
                switch strMethod! {
                    case "log" :
                        print("JavaScript :" + strParam!)
                    case "locate":
                        mLocationManager?.startUpdatingLocation()
                    case "save":
                        let jsonKeyValue = convertToDictionary(text: strParam!)
                        let strValueZoomTo = jsonKeyValue!["lsv"]
                            print(strValueZoomTo!)
                            mAppPref.set(jsonKeyValue?["lsv"], forKey: ViewController.PREF_ZOOMTO)
                    
                        //savePrefereance(strParam!)
                    default :
                        print("strParam :" + strParam!)
                    
                }

        }
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print ("viewDidAppear \(animated)");
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print ("viewDidDisappear \(animated)");
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print ("viewWillAppear \(animated)");
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print ("viewWillDisappear \(animated)");
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //btnBack.isHidden = true
        if mstrGAPN.characters.count == 0 {
            return;
        }
        let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "VTLib")

        if path != nil {
            
            mUrlRequest = URLRequest(url: URL(fileURLWithPath: path!),
                                             cachePolicy:NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                             timeoutInterval: 30.0);
            
            webView1.scrollView.isScrollEnabled = false;
            webView1.scrollView.bounces = false;
            webView1.delegate = self;
            webView1.loadRequest(mUrlRequest);
            progressLoading.startAnimating();
            
        }else{
            print ("Path " + path!);
        }
        
        mLocationManager = CLLocationManager()
        mLocationManager?.delegate = self
        mLocationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        mLocationManager?.requestAlwaysAuthorization()
       
        
    }

 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mLocationManager?.stopUpdatingLocation()
        mCurrentLocation = locations[0]
        setDeviceLocation(myLocation: mCurrentLocation!)
        print ("mstrGAPN " + mstrGAPN);

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if !blnVTLoaded {
            blnVTLoaded = true
            mWebView = webView;

            /*
            startVehicleTrackerScene("mum-intel-camp",  // GAPN
                "CAMPMU1610SCH0466",  // User Id
                "camproute003",  // Application will focus on this vehcile. Pass nil to select first vehicle in the list (in case multiple vehicles are shown)
                ["camproute003"] // Only listed vehicles will be visible, pass nil to show all vehicles
            );
            
            */
            
            let objZoomTo = mAppPref.object(forKey: ViewController.PREF_ZOOMTO)
            
            if(objZoomTo != nil){
            
                let strZoomTo:String  = objZoomTo as! String
                print ("Last Selected Vehicle  \(strZoomTo) ");
                
                startVehicleTrackerScene(mstrGAPN,  // GAPN
                    "mail4satya",  // User Id
                    strZoomTo,  // Application will focus on this vehcile. Pass nil to select first vehicle in the list (in case multiple vehicles are shown)
                    nil // Only listed vehicles will be visible, pass nil to show all vehicles
                )
            }else{
                startVehicleTrackerScene(mstrGAPN,  // GAPN
                    "mail4satya",  // User Id
                    nil,  // Application will focus on this vehcile. Pass nil to select first vehicle in the list (in case multiple vehicles are shown)
                    nil // Only listed vehicles will be visible, pass nil to show all vehicles
                )
            }
 

       } // end of if !blnVTLoaded
    }
    
    func startVehicleTrackerScene(_ strGAPN: String, _ strUserId:String, _ strZoomToVehicleId:String?, _ arrVisibleVehicleIds:[String]?){

        let strZoomTo = strZoomToVehicleId != nil ?  "'\(strZoomToVehicleId!)'" : "null"
        var strShowOnlyVehicles:String = "null"
        
        if arrVisibleVehicleIds != nil {
            do{
                let jarrVisibleVehicles = try JSONSerialization.data(withJSONObject:arrVisibleVehicleIds!, options: [])
                if let strVisibleVehicles = String(data: jarrVisibleVehicles,encoding: String.Encoding.utf8){
                    strShowOnlyVehicles =  "'\(strVisibleVehicles)'"
                    
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        
        let javaScriptInvokeVT = "startVT('\(strGAPN)','\(strUserId)',\(strZoomTo),\(strShowOnlyVehicles))"

        self.mWebView.stringByEvaluatingJavaScript(from: javaScriptInvokeVT)
        
        progressLoading.stopAnimating()
        progressLoading.isHidden = true
        lblLoading.isHidden = true
        
    }

    func setDeviceLocation(myLocation: CLLocation ){
        let javaScript = "setMyLocation(\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude))"
        print ("setDeviceLocation " + javaScript);
        self.mWebView.stringByEvaluatingJavaScript(from: javaScript)
    }

}

