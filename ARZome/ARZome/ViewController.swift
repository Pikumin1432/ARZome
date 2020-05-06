//
//  ViewController.swift
//  ARZome
//
//  Created by Gouta Hayashi on 2020/05/04.
//  Copyright © 2020 Gouta Hayashi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
        
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var graph = [[[Int]]]()
    
    var showName = ""
    
    let phi = (1 + sqrt(5)) / 2.0
    
    var basePointReal = SCNVector3()
    var baseQuaternion = SCNQuaternion()
    
    var baseCameraPosition = SCNVector3()
    
    var baseCameraQuaternion = SCNQuaternion()
    
    var show = false
    var mode = 0
    
    var scale0 = 1
    
    let baseBlueLength = 0.075
    
    @IBOutlet weak var CatchB: UIButton!
    @IBOutlet weak var ReleaseB: UIButton!
    
    
    @IBAction func catchButton(_ sender: UIButton) {
        if(show){
            if(mode == 0){
                guard let cameraNode = sceneView.pointOfView else {
                    return
                }
                mode = 1
                baseCameraQuaternion = cameraNode.orientation
                baseQuaternion = sceneView.scene.rootNode.childNodes[0].orientation
                
                baseCameraPosition = cameraNode.convertPosition(sceneView.scene.rootNode.childNodes[0].position,from:nil)
            }
        }
    }
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func releaseButton(_ sender: UIButton) {
        if(show){
            if(mode == 1){
                basePointReal = sceneView.scene.rootNode.childNodes[0].position
                baseQuaternion = sceneView.scene.rootNode.childNodes[0].orientation
                mode = 0
            }
        }
    }
    
    
    @IBAction func showButton(_ sender: UIButton) {
        
        if(show){
            if(showName == ""){
                let baseball = SCNSphere(radius:CGFloat(0.01))
                baseball.firstMaterial?.diffuse.contents = UIColor.black
                
                let basenode = SCNNode(geometry: baseball)
                
                basenode.position = basePointReal
                basenode.orientation = baseQuaternion
                
                sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: basenode)
                
                show = false
            }else{
                graph = graphfromfile(name:"model/"+showName)
                
                let graphVReal = graphrotationreal(points: graph[0], v: [SCNVector3(1,0,0),SCNVector3(0,1,0),SCNVector3(0,0,1)])
                
                let node = writegraph(graphV: graph[0], graphVreal: graphVReal, graphE: graph[1])
                sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: node)
                
                show = true
            }
        }else{
            if(showName != ""){
                graph = graphfromfile(name:"model/"+showName)
                
                let graphVReal = graphrotationreal(points: graph[0], v: [SCNVector3(1,0,0),SCNVector3(0,1,0),SCNVector3(0,0,1)])
                
                let node = writegraph(graphV: graph[0], graphVreal: graphVReal, graphE: graph[1])
                sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: node)
                
                show = true
            }
        }
        
    }
    
    
    @IBAction func scaleUp(_ sender: UIButton) {
        if(show){
            if(scale0 < 3){
                scale0 = scale0 + 1
            }
            
            let graphVReal = graphrotationreal(points: graph[0], v: [SCNVector3(1,0,0),SCNVector3(0,1,0),SCNVector3(0,0,1)])
            
            let node = writegraph(graphV: graph[0], graphVreal: graphVReal, graphE: graph[1])
            sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: node)
        }
    }
    
    @IBAction func scaleDown(_ sender: UIButton) {
        if(show){
            if(scale0 > 0){
                scale0 = scale0 - 1
            }
            
            let graphVReal = graphrotationreal(points: graph[0], v: [SCNVector3(1,0,0),SCNVector3(0,1,0),SCNVector3(0,0,1)])
            
            let node = writegraph(graphV: graph[0], graphVreal: graphVReal, graphE: graph[1])
            sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: node)
        }
    }
    
    @IBOutlet weak var modelPickerView: UIPickerView!
    
    
    var model_list = [""]
    
    
    
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model_list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,forComponent component: Int) -> String?{
        return model_list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        showName = model_list[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelPickerView.dataSource = self
        modelPickerView.delegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let path = Bundle.main.bundlePath
        let files = try! FileManager.default.contentsOfDirectory(atPath: path+"/model")
        //print(files)
        
        var lists = [""]
        for i in 0..<files.count{
            var char = files[i]
            if let range = char.range(of: ".vef") {
                char.replaceSubrange(range, with: "")
                lists.append(char)
            }
        }
        model_list = lists
        
        var index = 0
        if(model_list.count>=2){
            index = 1
        }
        
        showName = model_list[index]
        modelPickerView.selectRow(index, inComponent: 0, animated: false)
        
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = SCNScene()
        
        let baseball = SCNSphere(radius:CGFloat(0.01))
        baseball.firstMaterial?.diffuse.contents = UIColor.black
        
        let basenode = SCNNode(geometry: baseball)
        
        basePointReal = basenode.position
        baseQuaternion = basenode.orientation
        
        scene.rootNode.addChildNode(basenode)
        
        sceneView.scene = scene
        
        if(showName != ""){
            graph = graphfromfile(name:"model/"+showName)
            
            let graphVReal = graphrotationreal(points: graph[0], v: [SCNVector3(1,0,0),SCNVector3(0,1,0),SCNVector3(0,0,1)])
            
            let node = writegraph(graphV: graph[0], graphVreal: graphVReal, graphE: graph[1])
            sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: node)
            
            show = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        CatchB.frame = CGRect(x:screenWidth / 10,y:screenHeight - screenHeight / 4 ,width:100,height:100)
        CatchB.layer.masksToBounds = true
        CatchB.layer.cornerRadius = 50.0
        
        ReleaseB.frame = CGRect(x:screenWidth - screenWidth / 10 - 100,y:screenHeight - screenHeight / 4,width:100,height:100)
        ReleaseB.layer.masksToBounds = true
        ReleaseB.layer.cornerRadius = 50.0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
        if(mode == 1){
        
            guard let cameraNode = sceneView.pointOfView else {
                return
            }
            //sceneView.scene.rootNode.childNodes[0].eulerAngles = eulerg
            sceneView.scene.rootNode.childNodes[0].position = cameraNode.convertPosition(baseCameraPosition, to: nil)
        
            let position = cameraNode.convertPosition(baseCameraPosition, to: nil)
            sceneView.scene.rootNode.childNodes[0].position = position
            
            let q_c = cameraNode.orientation
        
            let q_n = qproduct(q1:qproduct(q1: q_c, q2: qinverse(q: baseCameraQuaternion)),q2:baseQuaternion)
        
            sceneView.scene.rootNode.childNodes[0].orientation = q_n
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    func writegraph(graphV:[[Int]],graphVreal:[SCNVector3],graphE:[[Int]]) -> SCNNode{
         //sceneView.scene = scene
        let baseball = SCNSphere(radius:CGFloat(0.01))
        baseball.firstMaterial?.diffuse.contents = UIColor.black
         
        let basenode = SCNNode(geometry: baseball)
        basenode.position = basePointReal
        basenode.orientation = baseQuaternion
        //scene.rootNode.addChildNode(basenode)
         
        //let graphV = graphtranslation(points: basedgraph[0], v: translate)
        //let graphE = basedgraph[1]
        
        let a = 4 * phi + 2
        let b = baseBlueLength
        var scale = b / a
        //let scale = 1.0
        
        switch(scale0){
        case 0:
            scale = scale / phi
        case 1:
            break
        case 2:
            scale = scale * phi
        case 3:
            scale = scale * phi * phi
        default: break
        }
        
        for i in 0 ..< graphVreal.count {
             
            let x = graphVreal[i].x
            let y = graphVreal[i].y
            let z = graphVreal[i].z
             
             
            let ball = SCNSphere(radius:CGFloat(0.01))
            let ballnode = SCNNode(geometry: ball)
            //ballnode.pivot = SCNMatrix4MakeTranslation(-x*Float(scale), -y*Float(scale), -z*Float(scale))
            ballnode.opacity = 0.75
            
            ballnode.position = SCNVector3(x: Float(x*Float(scale)), y: Float(y*Float(scale)), z: Float(z*Float(scale)))
            basenode.addChildNode(ballnode)
        }
        
        for i in 0..<graphE.count{
            let xreal1 = graphVreal[graphE[i][0]]
            let xreal2 = graphVreal[graphE[i][1]]
             
            let realedgevector = realedge(x:xreal1,y:xreal2)
            let reallen = lengthfromreal(x:realedgevector)
             
            let edge = edgeVector(x: graphV[graphE[i][0]], y: graphV[graphE[i][1]])
            let edgelen = edgelength(x: edge)
             
            let angle = acos(Double(realedgevector.y)/reallen)
            
            
            let edgegeometry = SCNCylinder(radius: 0.001, height: CGFloat(reallen*scale))
            
             //color
            if(isblue(l: edgelen)){
                edgegeometry.firstMaterial?.diffuse.contents = UIColor.blue
            }else if(isred(l: edgelen)){
                edgegeometry.firstMaterial?.diffuse.contents = UIColor.red
            }else if(isyellow(l: edgelen)){
                edgegeometry.firstMaterial?.diffuse.contents = UIColor.yellow
            }
             
             
            let edgenode = SCNNode(geometry: edgegeometry)
            edgenode.rotation = SCNVector4(Double(realedgevector.z),0,Double(-realedgevector.x),angle)
             
             
            let x1 = ( xreal1.x + xreal2.x ) / 2
            let y1 = ( xreal1.y + xreal2.y ) / 2
            let z1 = ( xreal1.z + xreal2.z ) / 2
             
             //edgenode.pivot = SCNMatrix4MakeTranslation(0,Float(-reallen/2.0*scale),0)
            edgenode.position = SCNVector3(x:x1*Float(scale), y:y1*Float(scale), z:z1*Float(scale))
            //edgenode.opacity = 0.75
             
            basenode.addChildNode(edgenode)
        }
        return basenode
    }
    
    func realedge(x:SCNVector3,y:SCNVector3) -> SCNVector3{
        return SCNVector3(x.x-y.x,x.y-y.y,x.z-y.z)
    }
    
    func lengthfromreal(x:SCNVector3) -> Double{
        return Double(sqrt(x.x*x.x + x.y*x.y + x.z*x.z))
    }
    
    func edgeVector(x: [Int],y: [Int]) -> Array<Int>{
        var ans = [0,0,0,0,0,0]
        for i in 0..<6 {
            ans[i] = x[i] - y[i]
        }
        return ans
    }
    
    func graphfromfile(name:String) -> [[[Int]]]{
        
        //file
        var fileV = [[Int]]()
        var fileE = [[Int]]()
        
        guard let path = Bundle.main.path(forResource:name, ofType:"vef") else {
            return [[[0]]]
        }
        do {
            let contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            
            var index = 0
            var mode = 0
            var v = 0
            var e = 0
            contents.enumerateLines{
                line, stop in
                
                if(mode == 3){
                    var edge = [0,0]
                    let text = line.components(separatedBy: " ")
                    edge[0] = Int(text[0])!
                    edge[1] = Int(text[1])!
                    fileE.append(edge)
                    e -= 1
                    if(e == 0){
                        mode = 4
                    }
                }else if(mode == 2){
                    if(line != ""){
                        mode = 3
                        e = Int(line)!
                        
                    }
                }else if(mode == 1){
                    var vertex = [0,0,0,0,0,0]
                    //print(line)
                    let text = line.components(separatedBy: " ")
                    for i in 1..<text.count {
                        let separatetext = text[i]
                        let partString = separatetext[separatetext.index(separatetext.startIndex, offsetBy: 1)..<separatetext.index(separatetext.startIndex, offsetBy: separatetext.count-1)]
                        let moreseparate = partString.components(separatedBy: ",")
                        vertex[2*(i-1)] = Int(moreseparate[0])!
                        vertex[2*(i-1)+1] = Int(moreseparate[1])!
                    }
                    
                    fileV.append(vertex)
                    v -= 1
                    //print(v)
                    if(v == 0){
                        mode = 2
                    }
                }else if(mode == 0){
                    if(index == 2){
                        v = Int(line)!
                        mode = 1
                    }
                }
                index += 1
            }
            
        } catch let error as NSError {
            print("error: \(error)")
            return [[[0]]]
        }
        return [fileV,fileE]
    }
    
    func edgelength(x:[Int]) -> Array<Int>{
       
       var a = 0
       var b = 0
       for i in 0..<3{
           a += 2*x[2*i]*x[2*i+1] + x[2*i] * x[2*i]
           b += x[2*i] * x[2*i] + x[2*i+1]*x[2*i+1]
       }
       let ans = [a,b]
       return ans
    }

    func timesphi2(l:[Int]) -> Array<Int>{
       return [2*l[0]+l[1],l[0]+l[1]]
    }

    func dividephi2(l:[Int]) -> Array<Int>{
       return [l[0]-l[1],-l[0]+2*l[1]]
    }

    func eql(l:[Int],m:[Int]) -> Bool{
       var ans = false
       if(l[0] == m[0] && l[1] == m[1]){ ans = true}
       return ans
    }

    func eqv(x:[Int],y:[Int]) -> Bool{
       var ans = true
       for i in 0..<x.count{
           if(x[i] != y[i]){
               ans = false
           }
       }
       return ans
    }

    func isblue(l:[Int]) -> Bool{
       var ans = false
       var base1 = [0,4]
       var base2 = [0,4]
       for i in 1..<10{
           if(eql(l:l,m:base1)){ ans = true }
           if(eql(l:l,m:base2)){ ans = true }
           base1 = timesphi2(l:base1)
           base2 = dividephi2(l: base2)
       }
       return ans
    }

    func isred(l:[Int]) -> Bool{
       var ans = false
       var base1 = [1,2]
       var base2 = [1,2]
       for i in 1..<10{
           if(eql(l:l,m:base1)){ ans = true }
           if(eql(l:l,m:base2)){ ans = true }
           base1 = timesphi2(l:base1)
           base2 = dividephi2(l: base2)
       }
       return ans
    }

    func isyellow(l:[Int]) -> Bool{
       var ans = false
       var base1 = [0,3]
       var base2 = [0,3]
       for i in 1..<10{
           if(eql(l:l,m:base1)){ ans = true }
           if(eql(l:l,m:base2)){ ans = true }
           base1 = timesphi2(l:base1)
           base2 = dividephi2(l: base2)
       }
       return ans
    }

    func productM(x:[Int],m:[Int]) -> Array<Int>{
        let a = productx(x:x,y:Array(m[0..<6]))
        let b = productx(x:x,y:Array(m[6..<12]))
        let c = productx(x:x,y:Array(m[12..<18]))
        return [a[0],a[1],b[0],b[1],c[0],c[1]]
    }
    func productx(x:[Int],y:[Int]) -> Array<Int>{
        return sumx(x:sumx(x:timesx(x:[x[0],x[1]],y:[y[0],y[1]]),
                           y:timesx(x:[x[2],x[3]],y:[y[2],y[3]])),
                    y:timesx(x:[x[4],x[5]],y:[y[4],y[5]]))
    }
    func timesx(x:[Int],y:[Int]) -> Array<Int>{
        return [x[0]*y[0]+x[0]*y[1]+x[1]*y[0],x[0]*y[0]+x[1]*y[1]]
    }

    func sumx(x:[Int],y:[Int]) -> Array<Int>{
        return [x[0]+y[0],x[1]+y[1]]
    }

    func sumv(x:[Int],y:[Int]) -> Array<Int>{
        var ans = [0,0,0,0,0,0]
        for i in 0..<x.count{
            ans[i] = x[i] + y[i]
        }
       
        return ans
    }
    
    func graphrotationreal(points:[[Int]],v:[SCNVector3]) -> [SCNVector3]{
        var ans = [SCNVector3()]
        for i in 0..<points.count{
            let x = zometoreal(x:points[i])
            let  v1 = SCNVector3(x:v[0].x,y:v[1].x,z:v[2].x)
            let  v2 = SCNVector3(x:v[0].y,y:v[1].y,z:v[2].y)
            let  v3 = SCNVector3(x:v[0].z,y:v[1].z,z:v[2].z)
            
            let x1 = realproduct(x: x, y: v1)
            let x2 = realproduct(x: x, y: v2)
            let x3 = realproduct(x: x, y: v3)
            
            let xprime = SCNVector3(x:x1,y:x2,z:x3)
            
            if(i == 0){
                ans[0] = xprime
            }else{
                ans.append(xprime)
            }
        }
        return ans
    }
    
    func zometoreal(x:[Int]) -> SCNVector3{
        return SCNVector3(Double(x[0]) * phi + Double(x[1]), Double(x[2]) * phi + Double(x[3]), Double(x[4]) * phi + Double(x[5]))
    }
    
    func realproduct(x:SCNVector3,y:SCNVector3) -> Float{
        return (x.x * y.x + x.y * y.y + x.z * y.z)
    }
    
    func qinverse(q:SCNQuaternion) -> SCNQuaternion{
        return SCNQuaternion(x:-q.x,y:-q.y,z:-q.z,w:q.w)
    }
    
    func qproduct(q1:SCNQuaternion,q2:SCNQuaternion) -> SCNQuaternion{
        let x = q1.x * q2.w + q1.w*q2.x - q1.z*q2.y + q1.y*q2.z
        let y = q1.y * q2.w + q1.z*q2.x + q1.w*q2.y - q1.x*q2.z
        let z = q1.z * q2.w - q1.y*q2.x + q1.x*q2.y + q1.w*q2.z
        let w = q1.w * q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z
        return SCNQuaternion(x:x,y:y,z:z,w:w)
    }
    
}
