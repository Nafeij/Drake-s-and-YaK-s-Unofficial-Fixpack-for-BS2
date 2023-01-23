package com.sociodox.theminer.window
{
   import com.junkbyte.console.Cc;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Stage2D;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.utils.getTimer;
   
   public class ConsoleContainer extends Sprite implements IWindow
   {
       
      
      private var mTimeSpent:int = 0;
      
      public function ConsoleContainer()
      {
         super();
         this.mTimeSpent = getTimer();
         Cc.start(this);
         Cc.instance.cl.base = Stage2D;
         Cc.config.commandLineAllowed = true;
         Cc.y = 17;
         Cc.width = Stage2D.stageWidth;
         Cc.height = Number(Stage2D.stageHeight) - 17;
         Analytics.Track("Tab","Console","Console Enter");
      }
      
      public function Dispose() : void
      {
         trace("Dispose");
         Cc.remove();
         Cc.visible = false;
         this.mTimeSpent = getTimer() - this.mTimeSpent;
         this.mTimeSpent /= 1000;
         Analytics.Track("Tab","Console","Console Exit",this.mTimeSpent);
      }
      
      public function Unlink() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
      
      public function Link(param1:DisplayObjectContainer, param2:int) : void
      {
         param1.addChildAt(this,param2);
      }
      
      public function Update() : void
      {
      }
   }
}
