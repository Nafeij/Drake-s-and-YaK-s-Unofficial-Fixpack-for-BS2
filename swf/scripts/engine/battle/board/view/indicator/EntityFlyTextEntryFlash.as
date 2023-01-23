package engine.battle.board.view.indicator
{
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   
   public class EntityFlyTextEntryFlash extends EntityFlyTextEntry
   {
       
      
      private var bmp:Bitmap;
      
      public function EntityFlyTextEntryFlash(param1:String, param2:EntityFlyText, param3:BitmapData)
      {
         this.bmp = new Bitmap();
         this.bmp.bitmapData = param3;
         this.bmp.x = -param3.width / 2;
         this.bmp.y = -param3.height / 2;
         bmpWrapper = new DisplayObjectWrapperFlash(this.bmp);
         super(param1,param2,param3);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
   }
}
