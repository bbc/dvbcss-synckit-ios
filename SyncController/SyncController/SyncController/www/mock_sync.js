
if (window.registerForTimelineUpdates == undefined) {
    
        
    mockOnReady = function()
    {
        mock_registerForTimelineUpdates(interval_in_ms, adhoc_events);
        
    }

    window.addEventListener("load", mockOnReady);
    __functionIndexMap = {};
    
    var interval_in_ms = 1000;
    var adhoc_events = true;
    
    

    onErrorCallingNativeFunction = function(err)
    {
        if (err)
        {
            alert(err.message);
        }
    }

    // Register web client for TS control timestamps.
    //@param period - period in milliseconds
    //@param adhoc - set to 'true' to receive ad hoc TS events? e.g. programme paused
    mock_registerForTimelineUpdates = function(period, adhoc)
    {
        adhoc = typeof adhoc !== 'undefined' ? adhoc : true;
        
        var args= [];
        args[0] = period;
        args[1] = adhoc;
        
        mock_calliOSFunction("registerForTimelineUpdates", args,function(ret){
                        var result = JSON.parse(ret);
                        
                        //document.getElementById("demo").innerHTML = result.result;
                        }, onErrorCallingNativeFunction);
    }





    setUpTSUpdates = function(args)
    {
        var myVar=setInterval(function(){mytimer()},args[0]);
    }

    // called by test stub above
    mytimer = function() {
        mytimer.count =  (++mytimer.count  || 1.000); //mytimer.count is undefined at first
        var time = (mytimer.count*interval_in_ms);

        var contentTime= time/1000+ (Math.random()* 0.01);

        var json_text = '{"contentTime":' + contentTime +
                        ',"timespeedMultiplier":1.0}';
                        
        
        updateTimeline(json_text);

    }

    // mock method
    mock_calliOSFunction = function(functionName, args, successCallback, errorCallback)
    {
        var url = "";
        
        var callInfo = {};
        callInfo.functionname = functionName;
        
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
            
            setUpTSUpdates(args);
        }
        
       var json_reply = '{"result":"registered for timeline updates."}';
        window[callInfo.success](json_reply);

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
}
