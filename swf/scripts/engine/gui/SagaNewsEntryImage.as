package engine.gui
{
   import engine.core.logging.ILogger;
   import engine.def.RectangleVars;
   import flash.geom.Rectangle;
   
   public class SagaNewsEntryImage
   {
       
      
      public var rect:Rectangle;
      
      public var url:String;
      
      public function SagaNewsEntryImage()
      {
         this.rect = new Rectangle(-336,0,672,200);
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaNewsEntryImage
      {
         var _loc3_:Object = null;
         if(!param1)
         {
            return this;
         }
         this.url = param1.url;
         RectangleVars.parseString(param1.rect,this.rect,param2);
         return this;
      }
   }
}
