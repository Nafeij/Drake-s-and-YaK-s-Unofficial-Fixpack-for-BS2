package engine.gui.core
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   
   public class GuiImage extends GuiSprite
   {
       
      
      private var m_image:Bitmap;
      
      private var m_bitmapData:BitmapData;
      
      public var withCenter:Boolean = true;
      
      public function GuiImage()
      {
         super();
      }
      
      public function get bitmapData() : BitmapData
      {
         return this.m_bitmapData;
      }
      
      public function set bitmapData(param1:BitmapData) : void
      {
         if(this.m_bitmapData != param1)
         {
            this.m_bitmapData = param1;
            this.image = !!this.m_bitmapData ? new Bitmap(this.m_bitmapData) : null;
         }
      }
      
      private function get image() : Bitmap
      {
         return this.m_image;
      }
      
      private function set image(param1:Bitmap) : void
      {
         if(this.m_image != param1)
         {
            if(this.m_image)
            {
               removeChild(this.m_image);
            }
            this.m_image = param1;
            if(this.m_image)
            {
               this.m_image.smoothing = true;
               addChild(this.m_image);
               this.resizeHandler();
            }
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(this.image)
         {
            if(this.withCenter)
            {
               _loc1_ = Math.min(width,height) - 10;
               _loc2_ = this.image.bitmapData.width / this.image.bitmapData.height;
               _loc3_ = _loc1_ / this.image.bitmapData.width;
               _loc4_ = _loc1_ / this.image.bitmapData.height;
               _loc5_ = Math.min(_loc3_,_loc4_);
               this.image.width = this.image.bitmapData.width * _loc5_;
               this.image.height = this.image.bitmapData.height * _loc5_;
               this.image.x = (width - this.image.width) / 2;
               this.image.y = (height - this.image.height) / 2;
            }
         }
         super.resizeHandler();
      }
   }
}
