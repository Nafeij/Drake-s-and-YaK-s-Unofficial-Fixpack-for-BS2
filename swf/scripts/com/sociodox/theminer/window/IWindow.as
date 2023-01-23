package com.sociodox.theminer.window
{
   import flash.display.DisplayObjectContainer;
   
   public interface IWindow
   {
       
      
      function Update() : void;
      
      function Dispose() : void;
      
      function Unlink() : void;
      
      function Link(param1:DisplayObjectContainer, param2:int) : void;
   }
}
