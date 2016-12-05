
var iOS = false,
p = navigator.platform;

if( p === 'iPad' || p === 'iPhone' || p === 'iPod' ){
    iOS = true;
}


if (iOS) {
        
    window.addEventListener("load", onReady);
    __functionIndexMap = {};
    
    onReady = function()
    {
        
        registerForTimelineUpdates();
        
        
    }
    
    
    closeWebViewAndShowExperienceView = function()
    {
        calliOSFunction("closeWebViewport", null, null, null);
        
    }
    
    
    // get me home!
    loadHomePage = function()
    {
        calliOSFunction("loadMediaAssetURL", null, null, null);
    }
    
    
    loadUrl = function(url)
    {
        window.location.assign(url);
    }
    
    onErrorCallingNativeFunction = function(err)
    {
        if (err)
        {
            alert(err.message);
        }
    }
    
    // Register web client for TS control timestamps. Called by JS code.
    registerForTimelineUpdates = function()
    {
        
        
        calliOSFunction("registerForTimelineUpdates", null,function(ret){
                        var result = JSON.parse(ret);
                        
                        document.getElementById("msg").innerHTML = result.result;
                        }, onErrorCallingNativeFunction);
    }
    
    
    calliOSFunction = function(functionName, args, successCallback, errorCallback)
    {
        var url = "js2ios://";
        
        var callInfo = {};
        callInfo.functionname = functionName;
        //eval(callbackFuncName + "({message:'This is a test<br>'})");
        
        
        
        if (successCallback)
        {
            if (typeof successCallback == 'function')
            {
                var callbackFuncName = createCallbackFunction(functionName + "_" + "successCallback", successCallback);
                callInfo.success = callbackFuncName;
            }
            else
                callInfo.success = successCallback;
        }
        
        if (errorCallback)
        {
            if (typeof errorCallback == 'function')
            {
                var callbackFuncName = createCallbackFunction(functionName + "_" + "errorCallback", errorCallback);
                callInfo.error = callbackFuncName;
            }
            else
                callInfo.error = errorCallback;
        }
        
        if (args)
        {
            callInfo.args = args;
        }
        
        url += JSON.stringify(callInfo)
        
        
        //eval(callbackFuncName + "({message:'This is a test<br>'})");
        
        var iFrame = createIFrame(url);
        //remove the frame now
        iFrame.parentNode.removeChild(iFrame);
    }
    
    createCallbackFunction = function(funcName, callbackFunc)
    {
        if (callbackFunc && callbackFunc.name != null && callbackFunc.name.length > 0)
        {
            return callbackFunc.name;
        }
        
        if (typeof window[funcName+0] != 'function')
        {
            window[funcName+0] = callbackFunc;
            __functionIndexMap[funcName] = 0;
            return funcName+0
            
        } else
        {
            var maxIndex = __functionIndexMap[funcName];
            var callbackFuncStr = callbackFunc.toString();
            for (var i = 0; i <= maxIndex; i++)
            {
                var tmpName = funcName + i;
                if (window[tmpName].toString() == callbackFuncStr)
                    return tmpName;
            }
            
            var newIndex = ++__functionIndexMap[funcName];
            window[funcName+newIndex] = callbackFunc;
            return funcName+newIndex;
        }
    }
    
    createIFrame = function(src)
    {
        var rootElm = document.documentElement;
        var newFrameElm = document.createElement("IFRAME");
        newFrameElm.setAttribute("src",src);
        rootElm.appendChild(newFrameElm);
        return newFrameElm;
    }
}




