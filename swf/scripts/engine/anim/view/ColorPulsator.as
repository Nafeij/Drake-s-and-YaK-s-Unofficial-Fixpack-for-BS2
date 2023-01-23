package engine.anim.view
{
   public class ColorPulsator
   {
      
      public static var lastId:int = 0;
       
      
      public var id:String;
      
      public var def:ColorPulsatorDef;
      
      public var color:uint = 4294967295;
      
      public var alpha:Number = 1;
      
      private var _elapsed:int = 0;
      
      public var hasColor:Boolean;
      
      public function ColorPulsator(param1:ColorPulsatorDef)
      {
         super();
         this.def = param1;
         this.id = param1.id + "_" + ++lastId;
         this.hasColor = param1.hasColor;
      }
      
      public function update(param1:int) : void
      {
         this._elapsed += param1;
         this.color = this.def.computeColor(this._elapsed);
         this.alpha = (this.color >> 24 & 255) / 255;
      }
      
      public function cleanup() : void
      {
      }
   }
}
