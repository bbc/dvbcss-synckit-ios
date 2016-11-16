window.addEventListener("load", onReady);
__functionIndexMap = {};

//
function onReady()
{
    registerForTimelineUpdates();
                    
}

// Register web client for TS control timestamps. Called by JS code.
//@param period - period in milliseconds
//@param adhoc - set to 'true' to receive ad hoc TS events? e.g. programme paused
function registerForTimelineUpdates()
{
    adhoc = typeof adhoc !== 'undefined' ? adhoc : true;
    
//    var args= [];
//    args[0] = period;
//    args[1] = adhoc;
    
    calliOSFunction("registerForTimelineUpdates", null,function(ret){
                    var result = JSON.parse(ret);
                    
                    document.getElementById("demo").innerHTML = result.result;
                    }, onErrorCallingNativeFunction);
}


function calliOSFunction(functionName, args, successCallback, errorCallback)
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

function createCallbackFunction (funcName, callbackFunc)
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

function createIFrame(src)
{
    var rootElm = document.documentElement;
    var newFrameElm = document.createElement("IFRAME");
    newFrameElm.setAttribute("src",src);
    rootElm.appendChild(newFrameElm);
    return newFrameElm;
}

