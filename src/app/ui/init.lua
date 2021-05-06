-- Author: Jam
-- Date: 2015.04.30

local pokerUI = {}

pokerUI.ProgressBar         = import(".ProgressBar")
pokerUI.Button 				= import(".Button")
pokerUI.Loading             = import(".Loading")
pokerUI.LongLoading 		= import(".LongLoading");
pokerUI.SlidingBar 			= import(".SlidingBar");
pokerUI.LoadingProgress     = import(".LoadingProgress")
pokerUI.Progress            = import(".Progress")
pokerUI.NumberImage         = import(".NumberImage")
pokerUI.DJListView 			= import(".DJListView")
pokerUI.DJExtendListView 	= import(".DJExtendListView")
pokerUI.RichLabel 			= import(".RichLabel")
pokerUI.SmallLongLoading 	= import(".SmallLongLoading")
pokerUI.SmallLoading        = import(".SmallLoading")
pokerUI.DJPageView 			= import(".DJPageView")
pokerUI.DJSlidingBar        = import(".DJSlidingBar")
pokerUI.DJCustomSlidingBar  = import(".DJCustomSlidingBar")
pokerUI.NickLabel           = import(".NickLabel")

--添加点击音效
function buttonHandler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

return pokerUI
