package engine.battle.board.view.underlay
{
   import engine.landscape.view.DisplayObjectWrapper;
   
   public class DisplayAppearEntry
   {
       
      
      public var remaining:int = 0;
      
      public var elapsed:int = 0;
      
      public var duration:int = 0;
      
      public var bmp:DisplayObjectWrapper;
      
      public var scaleX:Number = 1;
      
      public var scaleY:Number = 1;
      
      public var tx:Number = 0;
      
      public var ty:Number = 0;
      
      private var sx:Number = 0;
      
      private var sy:Number = 0;
      
      public function DisplayAppearEntry()
      {
         super();
      }
      
      public function toString() : String
      {
         return "" + this.bmp + " " + this.duration.toString() + " " + this.remaining.toString();
      }
      
      public function beginAppear(param1:int, param2:DisplayObjectWrapper, param3:Number, param4:Number, param5:Number, param6:Number) : DisplayAppearEntry
      {
         if(param2)
         {
            this.sx = param2.x;
            this.sy = param2.y;
         }
         this.duration = param1;
         this.elapsed = 0;
         this.remaining = param1;
         this.bmp = param2;
         this.scaleX = param3;
         this.scaleY = param4;
         this.tx = param5;
         this.ty = param6;
         return this;
      }
      
      public function setRemaining(param1:int) : DisplayAppearEntry
      {
         this.remaining = param1;
         return this;
      }
      
      public function update(param1:int) : Boolean
      {
         if(this.elapsed >= this.duration)
         {
            return false;
         }
         this.elapsed += param1;
         this.remaining = Math.max(0,this.duration - this.elapsed);
         var _loc2_:Number = Math.min(1,1 * this.elapsed / this.duration);
         if(this.bmp)
         {
            this.bmp.scaleX = this.scaleX * _loc2_;
            this.bmp.scaleY = this.scaleY * _loc2_;
            this.bmp.x = this.sx + (this.tx - this.sx) * _loc2_;
            this.bmp.y = this.sy + (this.ty - this.sy) * _loc2_;
         }
         return this.elapsed < this.duration;
      }
   }
}
