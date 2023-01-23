package com.google.analytics.debug
{
   import com.google.analytics.core.GIFRequest;
   import flash.display.DisplayObject;
   import flash.net.URLRequest;
   
   public interface ILayout
   {
       
      
      function init() : void;
      
      function destroy() : void;
      
      function addToStage(param1:DisplayObject) : void;
      
      function addToPanel(param1:String, param2:DisplayObject) : void;
      
      function bringToFront(param1:DisplayObject) : void;
      
      function isAvailable() : Boolean;
      
      function createVisualDebug() : void;
      
      function createPanel(param1:String, param2:uint, param3:uint) : void;
      
      function createInfo(param1:String) : void;
      
      function createWarning(param1:String) : void;
      
      function createAlert(param1:String) : void;
      
      function createFailureAlert(param1:String) : void;
      
      function createSuccessAlert(param1:String) : void;
      
      function createGIFRequestAlert(param1:String, param2:URLRequest, param3:GIFRequest) : void;
   }
}
