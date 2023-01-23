package game.gui.page
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiCredits extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:DisplayObject, param3:Bitmap) : void;
      
      function cleanup() : void;
      
      function addSectionBitmap(param1:MovieClip, param2:String, param3:String) : void;
      
      function addSection1(param1:MovieClip, param2:String, param3:String) : void;
      
      function addSection2(param1:GuiCreditsSectionConfig, param2:MovieClip, param3:String, param4:String, param5:String) : void;
      
      function addSection3(param1:MovieClip, param2:String, param3:String, param4:String, param5:String) : void;
      
      function layoutCredits(param1:Number, param2:Number) : void;
      
      function rollCredits() : void;
      
      function resetCredits() : void;
      
      function stopCredits() : void;
      
      function update(param1:int) : void;
      
      function addAlternatingImagePad(param1:int) : void;
      
      function addAlternatingImage(param1:BitmapData, param2:uint) : void;
      
      function set imageSpeed(param1:Number) : void;
      
      function set textColor(param1:uint) : void;
      
      function set headerColor(param1:uint) : void;
      
      function setBackgroundBitmapdata(param1:BitmapData) : void;
   }
}
