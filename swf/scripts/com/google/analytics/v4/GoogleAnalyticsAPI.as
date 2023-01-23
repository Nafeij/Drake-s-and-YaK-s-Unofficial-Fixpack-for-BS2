package com.google.analytics.v4
{
   import com.google.analytics.core.EventTracker;
   import com.google.analytics.core.ServerOperationMode;
   
   public interface GoogleAnalyticsAPI
   {
       
      
      function getAccount() : String;
      
      function getVersion() : String;
      
      function resetSession() : void;
      
      function setSampleRate(param1:Number) : void;
      
      function setSessionTimeout(param1:int) : void;
      
      function setVar(param1:String) : void;
      
      function trackPageview(param1:String = "") : void;
      
      function setAllowAnchor(param1:Boolean) : void;
      
      function setCampContentKey(param1:String) : void;
      
      function setCampMediumKey(param1:String) : void;
      
      function setCampNameKey(param1:String) : void;
      
      function setCampNOKey(param1:String) : void;
      
      function setCampSourceKey(param1:String) : void;
      
      function setCampTermKey(param1:String) : void;
      
      function setCampaignTrack(param1:Boolean) : void;
      
      function setCookieTimeout(param1:int) : void;
      
      function cookiePathCopy(param1:String) : void;
      
      function getLinkerUrl(param1:String = "", param2:Boolean = false) : String;
      
      function link(param1:String, param2:Boolean = false) : void;
      
      function linkByPost(param1:Object, param2:Boolean = false) : void;
      
      function setAllowHash(param1:Boolean) : void;
      
      function setAllowLinker(param1:Boolean) : void;
      
      function setCookiePath(param1:String) : void;
      
      function setDomainName(param1:String) : void;
      
      function addItem(param1:String, param2:String, param3:String, param4:String, param5:Number, param6:int) : void;
      
      function addTrans(param1:String, param2:String, param3:Number, param4:Number, param5:Number, param6:String, param7:String, param8:String) : void;
      
      function trackTrans() : void;
      
      function createEventTracker(param1:String) : EventTracker;
      
      function trackEvent(param1:String, param2:String, param3:String = null, param4:Number = NaN) : Boolean;
      
      function addIgnoredOrganic(param1:String) : void;
      
      function addIgnoredRef(param1:String) : void;
      
      function addOrganic(param1:String, param2:String) : void;
      
      function clearIgnoredOrganic() : void;
      
      function clearIgnoredRef() : void;
      
      function clearOrganic() : void;
      
      function getClientInfo() : Boolean;
      
      function getDetectFlash() : Boolean;
      
      function getDetectTitle() : Boolean;
      
      function setClientInfo(param1:Boolean) : void;
      
      function setDetectFlash(param1:Boolean) : void;
      
      function setDetectTitle(param1:Boolean) : void;
      
      function getLocalGifPath() : String;
      
      function getServiceMode() : ServerOperationMode;
      
      function setLocalGifPath(param1:String) : void;
      
      function setLocalRemoteServerMode() : void;
      
      function setLocalServerMode() : void;
      
      function setRemoteServerMode() : void;
   }
}
