package com.sociodox.theminer.ui
{
   import com.sociodox.theminer.manager.SkinManager;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ToolTip extends Sprite
   {
      
      private static var mInstance:ToolTip = null;
      
      private static var myformat:TextFormat = null;
      
      private static var myglow:GlowFilter = null;
      
      public static var width:int = 0;
      
      public static var height:int = 0;
       
      
      private var mText:TextField = null;
      
      public function ToolTip()
      {
         super();
         this.mouseChildren = false;
         this.mouseEnabled = false;
         myformat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,true);
         myglow = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.visible = false;
         this.mText = new TextField();
         this.mText.width = 800;
         this.mText.selectable = false;
         this.mText.defaultTextFormat = myformat;
         this.mText.filters = [myglow];
         this.mText.x = 2;
         addChild(this.mText);
         mInstance = this;
      }
      
      public static function UpdateSkin() : void
      {
         if(myformat != null)
         {
            myformat.color = SkinManager.COLOR_GLOBAL_TEXT;
            myglow.color = SkinManager.COLOR_GLOBAL_TEXT_GLOW;
         }
         mInstance.mText.defaultTextFormat = myformat;
         mInstance.mText.filters = [myglow];
      }
      
      public static function get Visible() : Boolean
      {
         return mInstance.visible;
      }
      
      public static function set Visible(param1:Boolean) : void
      {
         mInstance.visible = param1;
      }
      
      public static function SetToolTip(param1:String, param2:int, param3:int) : void
      {
         mInstance.SetToolTipText(param1);
         if(param2 > mInstance.stage.stageWidth - ToolTip.width)
         {
            param2 = mInstance.stage.stageWidth - ToolTip.width;
         }
         if(param3 > mInstance.stage.stageHeight - ToolTip.height)
         {
            param3 = mInstance.stage.stageHeight - ToolTip.height;
         }
         mInstance.x = param2;
         mInstance.y = param3;
      }
      
      public static function set Text(param1:String) : void
      {
         mInstance.SetToolTipText(param1);
         if(mInstance.x > mInstance.stage.stageWidth - ToolTip.width)
         {
            mInstance.x = mInstance.stage.stageWidth - ToolTip.width;
         }
         if(mInstance.y > mInstance.stage.stageHeight - ToolTip.height)
         {
            mInstance.y = mInstance.stage.stageHeight - ToolTip.height;
         }
      }
      
      public static function SetPosition(param1:int, param2:int) : void
      {
         mInstance.x = param1;
         mInstance.y = param2;
      }
      
      public function SetToolTipText(param1:String) : void
      {
         this.mText.text = param1;
         var _loc2_:int = this.mText.textWidth + 7;
         var _loc3_:int = this.mText.textHeight + 4;
         ToolTip.width = _loc2_;
         ToolTip.height = _loc3_;
         this.graphics.clear();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.5);
         this.graphics.drawRect(0,0,_loc2_,_loc3_);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.5);
         this.graphics.drawRect(1,1,_loc2_ - 2,_loc3_ - 2);
         this.graphics.endFill();
      }
   }
}
